/// إعدادات عامة للتطبيق.
/// الهدف: مفيش baseUrl أو flags تتكتب في 10 أماكن.

enum AppEnv { dev, prod }

class AppConfig {
  final AppEnv env;
  final String baseUrl;

  /// Feature flag: هل نستعمل API repositories؟
  final bool useApi;

  const AppConfig({
    required this.env,
    required this.baseUrl,
    required this.useApi,
  });

  bool get isDev => env == AppEnv.dev;
  bool get isProd => env == AppEnv.prod;

  static const dev = AppConfig(
    env: AppEnv.dev,
    baseUrl: 'https://example.com', // placeholder دلوقتي
    useApi: false, // يظل false لحين استكمال ربط الشاشات بالمستودعات البعيدة
  );

  static const prod = AppConfig(
    env: AppEnv.prod,
    baseUrl: 'https://example.com', // placeholder
    useApi: false,
  );
}
