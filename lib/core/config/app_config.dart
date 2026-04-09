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
    baseUrl: 'https://lungcare.runasp.net',
    useApi: true,
  );

  static const prod = AppConfig(
    env: AppEnv.prod,
    baseUrl: 'https://lungcare.runasp.net',
    useApi: true,
  );
}
