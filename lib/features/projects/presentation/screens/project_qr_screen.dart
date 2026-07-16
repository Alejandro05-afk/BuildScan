import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../providers/projects_provider.dart';

final _projectNameProvider = FutureProvider.family.autoDispose<String, String>((ref, String id) async {
  final repo = ref.watch(projectRepositoryProvider);
  final project = await repo.getProjectById(id);
  return project?.nombre ?? 'Proyecto';
});

class ProjectQrScreen extends ConsumerWidget {
  final String projectId;

  const ProjectQrScreen({
    super.key,
    required this.projectId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameAsync = ref.watch(_projectNameProvider(projectId));
    final projectName = nameAsync.value ?? 'Cargando...';
    final qrData = 'buildscan://project/$projectId';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Código QR'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.teal.withValues(alpha: 0.2),
                      blurRadius: 24,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: QrImageView(
                  data: qrData,
                  version: QrVersions.auto,
                  size: 260,
                  backgroundColor: Colors.white,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Colors.teal,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Colors.black87,
                  ),
                  embeddedImage: const AssetImage('assets/images/logo.jpeg'),
                  embeddedImageStyle: const QrEmbeddedImageStyle(
                    size: Size(48, 48),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                projectName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Escanea para ver detalles del proyecto',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
