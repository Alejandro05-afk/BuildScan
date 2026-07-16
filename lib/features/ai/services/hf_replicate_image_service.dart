import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';

class HfReplicateImageService {
  final Dio _dio = Dio();
  static const String _hfRouterBase = 'https://router.huggingface.co/replicate';
  static const String _model = 'black-forest-labs/flux-schnell';
  static const int _maxPollAttempts = 90;
  static const int _pollIntervalSeconds = 2;

  Future<File> generateConstructionImage({
    required String prompt,
  }) async {
    final apiKey = dotenv.env['HF_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('No se encontró la API Key de Hugging Face');
    }

    try {
      return await _generateSync(apiKey, prompt);
    } catch (e) {
      debugPrint('=== HF Replicate modo sincrono falló, intentando polling: $e ===');
      try {
        return await _generateWithPolling(apiKey, prompt);
      } catch (pollErr) {
        debugPrint('=== HF Replicate polling también falló: $pollErr ===');
        rethrow;
      }
    }
  }

  Future<File> _generateSync(String apiKey, String prompt) async {
    debugPrint('=== HF Replicate modo sincrono ===');
    final response = await _dio.post<Map<String, dynamic>>(
      '$_hfRouterBase/v1/models/$_model/predictions',
      data: {
        'input': {
          'prompt': prompt,
          'num_inference_steps': 4,
          'output_format': 'png',
        },
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
          'Prefer': 'wait',
        },
        sendTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(minutes: 3),
      ),
    );

    final status = response.data!['status'] as String;
    debugPrint('=== HF Replicate sync status: $status ===');

    if (status == 'succeeded') {
      final output = response.data!['output'];
      final imageUrl = output is List ? output[0] as String : output as String;
      return _downloadImage(apiKey, imageUrl);
    }

    throw Exception('Predicción no completada: status=$status');
  }

  Future<File> _generateWithPolling(String apiKey, String prompt) async {
    debugPrint('=== HF Replicate modo polling ===');

    final predictionId = await _createPrediction(apiKey, prompt);
    final imageUrl = await _pollPrediction(apiKey, predictionId);
    return _downloadImage(apiKey, imageUrl);
  }

  Future<String> _createPrediction(String apiKey, String prompt) async {
    const maxRetries = 3;
    for (var attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        debugPrint('=== HF Replicate crear predicción intento $attempt ===');
        final response = await _dio.post<Map<String, dynamic>>(
          '$_hfRouterBase/v1/models/$_model/predictions',
          data: {
            'input': {
              'prompt': prompt,
              'num_inference_steps': 4,
              'output_format': 'png',
            },
          },
          options: Options(
            headers: {
              'Authorization': 'Bearer $apiKey',
              'Content-Type': 'application/json',
            },
            sendTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),
          ),
        );
        return response.data!['id'] as String;
      } on DioException catch (e) {
        debugPrint('=== HF Replicate crear error intento $attempt: ${e.type} ===');
        if (attempt == maxRetries) rethrow;
        await Future.delayed(Duration(seconds: attempt * 5));
      }
    }
    throw Exception('No se pudo crear la predicción');
  }

  Future<String> _pollPrediction(String apiKey, String predictionId) async {
    for (var i = 0; i < _maxPollAttempts; i++) {
      await Future.delayed(const Duration(seconds: _pollIntervalSeconds));

      try {
        final response = await _dio.get<Map<String, dynamic>>(
          '$_hfRouterBase/v1/predictions/$predictionId',
          options: Options(
            headers: {'Authorization': 'Bearer $apiKey'},
            sendTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
          ),
        );

        final status = response.data!['status'] as String;
        debugPrint('=== HF Replicate poll ${i + 1}: status=$status ===');

        if (status == 'succeeded') {
          final output = response.data!['output'];
          if (output == null) {
            throw Exception('Predicción completada pero sin output');
          }
          return output is List ? output[0] as String : output as String;
        } else if (status == 'failed') {
          throw Exception(
            'Predicción falló: ${response.data!['error'] ?? 'Error desconocido'}',
          );
        } else if (status == 'canceled') {
          throw Exception('Predicción cancelada');
        }
      } on DioException {
        debugPrint('=== HF Replicate poll error intento ${i + 1} ===');
      }
    }
    throw Exception(
      'Timeout: predicción no completada en ${_maxPollAttempts * _pollIntervalSeconds}s',
    );
  }

  Future<File> _downloadImage(String apiKey, String imageUrl) async {
    debugPrint('=== HF Replicate descargando imagen ===');
    final response = await _dio.get<List<int>>(
      imageUrl,
      options: Options(
        responseType: ResponseType.bytes,
        headers: {'Authorization': 'Bearer $apiKey'},
        sendTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(minutes: 2),
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/construction_suggestion.png');
    await file.writeAsBytes(response.data!);
    debugPrint('=== Imagen guardada: ${file.path} ===');
    return file;
  }
}
