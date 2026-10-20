class AppConfig {
  // Configurable via --dart-define=API_BASE_URL=...
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );

  static String get wsBaseUrl {
    if (apiBaseUrl.startsWith('https://')) {
      return apiBaseUrl.replaceFirst('https://', 'wss://');
    } else {
      return apiBaseUrl.replaceFirst('http://', 'ws://');
    }
  }

  static const String defaultCarId = 'swift_2016';
}
