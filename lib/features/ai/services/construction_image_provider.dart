import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'hugging_face_image_service.dart';

class AiImageResult {
  final File file;
  final String source; // 'ai' or 'placeholder'
  
  AiImageResult({required this.file, required this.source});
}

final huggingFaceImageServiceProvider = Provider<HuggingFaceImageService>((ref) {
  return HuggingFaceImageService();
});

final constructionImageControllerProvider =
    AsyncNotifierProvider<ConstructionImageController, AiImageResult?>(
  ConstructionImageController.new,
);

class ConstructionImageController extends AsyncNotifier<AiImageResult?> {
  @override
  Future<AiImageResult?> build() async => null;

  Future<void> generate({required String prompt}) async {
    state = const AsyncLoading();
    try {
      final service = ref.read(huggingFaceImageServiceProvider);
      final file = await service.generateConstructionImage(prompt: prompt);
      state = AsyncData(AiImageResult(file: file, source: 'ai'));
    } catch (e) {
      // Fallback a placeholder si falla
      try {
        final byteData = await rootBundle.load('assets/images/placeholder_construction.png');
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/placeholder.png');
        await file.writeAsBytes(byteData.buffer.asUint8List());
        state = AsyncData(AiImageResult(file: file, source: 'placeholder'));
      } catch (innerErr) {
        state = AsyncError('No se pudo generar la imagen ni cargar el placeholder', StackTrace.current);
      }
    }
  }
}
