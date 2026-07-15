import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';

class HuggingFaceImageService {
  final Dio _dio = Dio();
  final String _endpoint =
      'https://router.huggingface.co/hf-inference/models/black-forest-labs/FLUX.1-schnell';

  Future<File> generateConstructionImage({
    required String prompt,
  }) async {
    final apiKey = dotenv.env['HF_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('No se encontró la API Key de Hugging Face');
    }

    const maxRetries = 3;
    for (var attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        print('=== HuggingFace intento $attempt de $maxRetries ===');
        final response = await _dio.post<List<int>>(
          _endpoint,
          data: {
            'inputs': prompt,
            'parameters': {
              'negative_prompt':
                  'blurry, distorted, low quality, unrealistic proportions, text, watermark',
              'num_inference_steps': 4,
            },
          },
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

        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/construction_suggestion.png');
        await file.writeAsBytes(Uint8List.fromList(response.data!));
        return file;
      } on DioException catch (e) {
        print('=== HuggingFace error intento $attempt: ${e.type} ===');
        if (attempt == maxRetries) {
          final msg = 'DioError [${e.type}]: ${e.message}\n'
              'URI: ${e.requestOptions.uri}\n'
              'Status: ${e.response?.statusCode}';
          print('=== HuggingFace ERROR FINAL ===\n$msg');
          rethrow;
        }
        await Future.delayed(Duration(seconds: attempt * 5));
      }
    }
    throw Exception('No se pudo generar la imagen después de $maxRetries intentos');
  }
}
