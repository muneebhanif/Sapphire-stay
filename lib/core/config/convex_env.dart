/// Convex runtime config.
///
/// URLs are injected at build/run time via `--dart-define-from-file=.env`.
/// Never hardcode these values in source code.
class ConvexEnv {
  // Convex Cloud DB URL (query/mutation endpoint).
  static const String url = String.fromEnvironment('FLUTTER_CONVEX_URL');

  // Convex HTTP Actions URL (file uploads, API proxy).
  static const String httpUrl = String.fromEnvironment('FLUTTER_CONVEX_HTTP_URL');

  static bool get isConfigured => url.isNotEmpty;
}
