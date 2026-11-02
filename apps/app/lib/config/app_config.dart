class AppConfig {
  const AppConfig({required this.baseUrl});

  /// Reads values supplied through `--dart-define-from-file=config/<flavor>.json`.
  factory AppConfig.fromEnvironment() =>
      const AppConfig(baseUrl: String.fromEnvironment('BASE_URL'));

  final String baseUrl;
}
