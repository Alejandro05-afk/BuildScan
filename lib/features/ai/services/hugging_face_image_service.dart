import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';

class HuggingFaceImageService {
  final Dio _dio = Dio();

  // Con cuenta Pro, el endpoint hf-inference es el más estable y rápido.
  // Se incluyen fallbacks en caso de que un proveedor esté saturado.
  static const List<String> _endpoints = [
    'https://router.huggingface.co/hf-inference/models/black-forest-labs/FLUX.1-schnell',
    'https://api-inference.huggingface.co/models/black-forest-labs/FLUX.1-schnell',
    'https://router.huggingface.co/together/models/black-forest-labs/FLUX.1-schnell',
  ];

  // FLUX.1-schnell tiene un límite aproximado de 77 tokens CLIP.
  // Truncamos prompts largos para evitar errores 400 Bad Request.
  static const int _maxPromptLength = 300;

  String _truncatePrompt(String prompt) {
    if (prompt.length <= _maxPromptLength) return prompt;
    final truncated = prompt.substring(0, _maxPromptLength);
    final lastSpace = truncated.lastIndexOf(' ');
    final clean = lastSpace > 0 ? truncated.substring(0, lastSpace) : truncated;
    if (clean.endsWith(',')) return '$clean modern style';
    return '$clean, modern style';
  }

  Future<File> generateConstructionImage({
    required String prompt,
  }) async {
    final apiKey = dotenv.env['HF_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('No se encontró la API Key de Hugging Face');
    }

    final safePrompt = _truncatePrompt(prompt);
    debugPrint('=== HuggingFace prompt (${safePrompt.length} chars): $safePrompt ===');

    const maxRetries = 3;
    for (var attempt = 1; attempt <= maxRetries; attempt++) {
      for (final endpoint in _endpoints) {
        try {
          debugPrint('=== HuggingFace intento $attempt/$maxRetries — $endpoint ===');
          final response = await _dio.post<List<int>>(
            endpoint,
            data: {'inputs': safePrompt},
            options: Options(
              headers: {
                'Authorization': 'Bearer $apiKey',
                'Content-Type': 'application/json',
              },
              responseType: ResponseType.bytes,
              sendTimeout: const Duration(seconds: 60),
              receiveTimeout: const Duration(minutes: 3),
            ),
          );

          if (response.data == null || response.data!.isEmpty) {
            throw DioException(
              requestOptions: response.requestOptions,
              message: 'Respuesta vacía del servidor',
            );
          }

          final dir = await getTemporaryDirectory();
          final file = File('${dir.path}/construction_suggestion.png');
          await file.writeAsBytes(Uint8List.fromList(response.data!));
          debugPrint('=== HuggingFace imagen generada correctamente ===');
          return file;

        } on DioException catch (e) {
          final status = e.response?.statusCode;
          debugPrint('=== HuggingFace error en $endpoint — Status: $status — ${e.type} ===');

          // Errores terminales para este endpoint: saltar al siguiente
          if (status == 410 || status == 404 || status == 400 ||
              e.type == DioExceptionType.connectionError ||
              e.type == DioExceptionType.connectionTimeout) {
            continue;
          }

          // 429/503 = límite de tasa o servidor ocupado: esperar y reintentar
          if (attempt == maxRetries) {
            final msg = 'DioError [${e.type}]: ${e.message}\n'
                'URI: ${e.requestOptions.uri}\n'
                'Status: ${e.response?.statusCode}';
            debugPrint('=== HuggingFace ERROR FINAL ===\n$msg');
            rethrow;
          }
          await Future.delayed(Duration(seconds: attempt * 5));
        }
      }
    }
    throw Exception(
        'No se pudo generar la imagen después de $maxRetries intentos en todos los proveedores.');
  }
}