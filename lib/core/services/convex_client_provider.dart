import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
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

  Future<dynamic> _callEndpoint(
      String path, Map<String, dynamic> args, bool isMutation) async {
    if (baseUrl.trim().isEmpty) {
      throw Exception(
          'Convex Base URL is empty. Did you pass --dart-define-from-file=.env or set FLUTTER_CONVEX_HTTP_URL?');
    }

    final cleanBaseUrl = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final uri = Uri.parse('$cleanBaseUrl/api');

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('convex_auth_token');

    // Remove null values so Convex v.optional(...) doesn't crash on JSON null.
    final cleanArgs = Map<String, dynamic>.from(args)
      ..removeWhere((k, v) => v == null);

    final body = jsonEncode({
      'path': path,
      'args': cleanArgs,
      'isMutation': isMutation,
    });

    debugPrint('[Convex] ${isMutation ? "MUT" : "QRY"} $path  args=${cleanArgs.keys.toList()}');

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty)
          'Authorization': 'Bearer $token',
      },
      body: body,
    );

    debugPrint('[Convex] $path → ${response.statusCode}');

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map && decoded.containsKey('error')) {
        debugPrint('[Convex] ERROR from $path: ${decoded['error']}');
        throw Exception('Convex error in $path: ${decoded['error']}');
      }
      return decoded;
    }

    // Non-200: include status + body for debugging.
    final errBody = response.body.length > 500
        ? '${response.body.substring(0, 500)}…'
        : response.body;
    debugPrint('[Convex] FAIL $path: ${response.statusCode} $errBody');
    throw Exception(
        'Convex $path failed (${response.statusCode}): $errBody');
  }

  void close() {}
}

final convexClientProvider = Provider<ConvexClient>((ref) {
  final client = ConvexClient(ConvexEnv.httpUrl);
  ref.onDispose(() => client.close());
  return client;
});
