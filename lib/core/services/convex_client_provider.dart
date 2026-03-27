import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../config/convex_env.dart';

class ConvexClient {
  final String baseUrl;

  ConvexClient(this.baseUrl);

  Future<dynamic> query(String path, [Map<String, dynamic>? args]) async {
    return _callEndpoint(path, args ?? {}, false);
  }

  Future<dynamic> mutation(String path, [Map<String, dynamic>? args]) async {
    return _callEndpoint(path, args ?? {}, true);
  }

  Future<dynamic> _callEndpoint(String path, Map<String, dynamic> args, bool isMutation) async {
    if (baseUrl.trim().isEmpty) {
      throw Exception('Convex Base URL is empty. Did you pass --dart-define-from-file=.env or set FLUTTER_CONVEX_HTTP_URL?');
    }
    
    // Ensure we don't have double slashes if baseUrl has a trailing slash.
    final cleanBaseUrl = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final uri = Uri.parse('$cleanBaseUrl/api');
    
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'path': path,
        'args': args,
        'isMutation': isMutation,
      }),
    );
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map && decoded.containsKey('error')) {
        throw Exception(decoded['error']);
      }
      return decoded;
    }
    throw Exception('Failed fetching from Convex: ${response.statusCode} - ${response.body}');
  }

  void close() {}
}

final convexClientProvider = Provider<ConvexClient>((ref) {
  final client = ConvexClient(ConvexEnv.httpUrl);
  ref.onDispose(() => client.close());
  return client;
});
