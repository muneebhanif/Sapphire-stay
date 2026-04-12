import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/convex_env.dart';

final convexStorageServiceProvider = Provider<ConvexStorageService>((ref) {
  return ConvexStorageService();
});

class ConvexStorageService {
  /// Upload image bytes to Convex HTTP storage endpoint.
  ///
  /// Returns the `storageId` string, or null on failure.
  /// Retries once on transient failures.
  Future<String?> uploadImage(Uint8List bytes, String mimeType) async {
    // Retry up to 2 times
    for (int attempt = 0; attempt < 2; attempt++) {
      try {
        final url = Uri.parse('${ConvexEnv.httpUrl}/uploadImage');
        
        debugPrint('[Storage] Attempt ${attempt + 1}: Uploading ${bytes.length} bytes to $url');

        final response = await http.post(
          url,
          headers: {
            'Content-Type': mimeType,
          },
          body: bytes,
        ).timeout(const Duration(seconds: 30));

        debugPrint('[Storage] Response status: ${response.statusCode}');
        debugPrint('[Storage] Response body: ${response.body}');

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final storageId = data['storageId'];
          if (storageId != null) {
            final id = storageId.toString();
            debugPrint('[Storage] Upload OK, storageId=$id');
            return id;
          } else {
            debugPrint('[Storage] Upload returned null storageId');
            // Don't retry this - it's a logic error
            return null;
          }
        } else {
          debugPrint('[Storage] Upload failed: ${response.statusCode} ${response.body}');
          if (attempt == 0) {
            debugPrint('[Storage] Will retry...');
            await Future.delayed(const Duration(milliseconds: 500));
            continue;
          }
          return null;
        }
      } catch (e) {
        debugPrint('[Storage] Upload exception (attempt ${attempt + 1}): $e');
        if (attempt == 0) {
          debugPrint('[Storage] Will retry...');
          await Future.delayed(const Duration(milliseconds: 500));
          continue;
        }
        return null;
      }
    }
    return null;
  }

  /// Build a URL that serves the image for the given storageId.
  String getImageUrl(String storageId) {
    final encoded = Uri.encodeComponent(storageId);
    return '${ConvexEnv.httpUrl}/getImage?storageId=$encoded';
  }
}