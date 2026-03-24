import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/convex_env.dart';

final convexStorageServiceProvider = Provider<ConvexStorageService>((ref) {
  return ConvexStorageService();
});

class ConvexStorageService {
  Future<String?> uploadImage(Uint8List bytes, String mimeType) async {
    try {
      final url = Uri.parse('${ConvexEnv.httpUrl}/uploadImage');
      final request = http.Request('POST', url)
        ..headers['Content-Type'] = mimeType
        ..bodyBytes = bytes;
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['storageId'] as String?;
      } else {
        debugPrint('Upload failed with status: \${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error uploading image: \$e');
      return null;
    }
  }

  String getImageUrl(String storageId) {
    return '\${ConvexEnv.httpUrl}/getImage?storageId=\$storageId';
  }
}