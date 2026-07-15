import 'dart:io';
import 'dart:ui';
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
      try {
        final file = await _generatePlaceholder();
        state = AsyncData(AiImageResult(file: file, source: 'placeholder'));
      } catch (innerErr) {
        state = AsyncError('No se pudo generar la imagen ni cargar el placeholder', StackTrace.current);
      }
    }
  }

  Future<File> _generatePlaceholder() async {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    const size = Size(512, 512);

    final bgPaint = Paint()..color = const Color(0xFFE0E0E0);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final iconPaint = Paint()..color = const Color(0xFF9E9E9E);
    final iconRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2 - 20),
      width: 120,
      height: 120,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(iconRect, const Radius.circular(16)),
      iconPaint,
    );

    final crossPaint = Paint()
      ..color = const Color(0xFFBDBDBD)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(size.width / 2 - 20, size.height / 2 - 20),
      Offset(size.width / 2 + 20, size.height / 2 + 20),
      crossPaint,
    );
    canvas.drawLine(
      Offset(size.width / 2 + 20, size.height / 2 - 20),
      Offset(size.width / 2 - 20, size.height / 2 + 20),
      crossPaint,
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.width.toInt(), size.height.toInt());
    final byteData = await image.toByteData(format: ImageByteFormat.png);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/placeholder.png');
    await file.writeAsBytes(byteData!.buffer.asUint8List());
    return file;
  }
}
