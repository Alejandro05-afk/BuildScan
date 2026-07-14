import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'hugging_face_image_service.dart';

final huggingFaceImageServiceProvider = Provider<HuggingFaceImageService>((ref) {
  return HuggingFaceImageService();
});

final constructionImageControllerProvider =
    AsyncNotifierProvider<ConstructionImageController, File?>(
  ConstructionImageController.new,
);

class ConstructionImageController extends AsyncNotifier<File?> {
  @override
  Future<File?> build() async => null;

  Future<void> generate({required String prompt}) async {
    state = const AsyncLoading();
    try {
      final service = ref.read(huggingFaceImageServiceProvider);
      final file = await service.generateConstructionImage(prompt: prompt);
      state = AsyncData(file);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
