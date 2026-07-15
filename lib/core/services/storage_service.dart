import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/supabase_provider.dart';

class StorageService {
  final SupabaseClient _client;

  StorageService(this._client);

  Future<String> uploadProformaPdf({
    required String userId,
    required String proformaId,
    required Uint8List bytes,
  }) async {
    final path = '$userId/$proformaId.pdf';
    
    await _client.storage.from('proformas').uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(contentType: 'application/pdf', upsert: true),
        );
        
    return path;
  }

  Future<String> getSignedUrl(String bucket, String path, {int expiresIn = 3600}) async {
    return await _client.storage.from(bucket).createSignedUrl(path, expiresIn);
  }

  Future<String> uploadAiImage({
    required String userId,
    required String projectId,
    required Uint8List bytes,
  }) async {
    final path = '$userId/$projectId.png';
    
    await _client.storage.from('ai-suggestions').uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(contentType: 'image/png', upsert: true),
        );
        
    return path;
  }
}

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService(ref.watch(supabaseProvider));
});
