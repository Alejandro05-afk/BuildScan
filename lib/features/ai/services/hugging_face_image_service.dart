import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';

class HuggingFaceImageService {
  final Dio _dio = Dio();
  final String _endpoint =
      'https://api-inference.huggingface.co/models/stabilityai/stable-diffusion-xl-base-1.0';

  Future<File> generateConstructionImage({
    required String prompt,
  }) async {
    final apiKey = dotenv.env['HF_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('No se encontró la API Key de Hugging Face');
    }

    final response = await _dio.post<List<int>>(
      _endpoint,
      data: {
        'inputs': prompt,
        'parameters': {
          'negative_prompt': 'blurry, distorted, low quality, unrealistic proportions, text, watermark',
          'num_inference_steps': 25,
          'guidance_scale': 7.5,
        },
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        responseType: ResponseType.bytes,
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/construction_suggestion.png');
    await file.writeAsBytes(Uint8List.fromList(response.data!));
    return file;
  }
}
