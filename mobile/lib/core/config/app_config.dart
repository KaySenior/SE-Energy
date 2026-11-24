import 'package:flutter/foundation.dart';

/// Resolves the backend base URL.
///
/// Override it at build/run time:
/// `flutter run --dart-define=API_BASE_URL=https://api.example.com`
class AppConfig {
  const AppConfig({required this.apiBaseUrl});

  final String apiBaseUrl;

  static const _override = String.fromEnvironment('API_BASE_URL');

  factory AppConfig.resolve() {
    if (_override.isNotEmpty) {
      return AppConfig(apiBaseUrl: _trimTrailingSlash(_override));
    }
    // Android emulators reach the host machine through 10.0.2.2.
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return const AppConfig(apiBaseUrl: 'http://10.0.2.2:8000');
    }
    return const AppConfig(apiBaseUrl: 'http://localhost:8000');
  }

  static String _trimTrailingSlash(String value) {
    return value.endsWith('/') ? value.substring(0, value.length - 1) : value;
  }
}
