import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService(Supabase.instance.client);
});

class StorageService {
  final SupabaseClient _client;

  StorageService(this._client);

  /// Sube un archivo a un bucket específico y retorna la URL pública.
  Future<String> uploadFile({
    required String bucketName,
    required String filePath,
    required File file,
  }) async {
    try {
      await _client.storage.from(bucketName).upload(
        filePath,
        file,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
      );

      final String publicUrl = _client.storage.from(bucketName).getPublicUrl(filePath);
      return publicUrl;
    } catch (e) {
      throw Exception('Error al subir archivo a $bucketName: $e');
    }
  }

  /// Ejemplo: Subir PDF de Proforma
  Future<String> uploadProformaPdf(String proformaId, File pdfFile) async {
    final filePath = 'proformas/$proformaId.pdf';
    return uploadFile(
      bucketName: 'proformas',
      filePath: filePath,
      file: pdfFile,
    );
  }

  /// Ejemplo: Subir Logo de Ferretería
  Future<String> uploadFerreteriaLogo(String ferreteriaId, File imageFile) async {
    final filePath = 'logos/$ferreteriaId.png';
    return uploadFile(
      bucketName: 'hardware-store-logos',
      filePath: filePath,
      file: imageFile,
    );
  }
}
