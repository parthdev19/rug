/// Environment configuration for dev, staging, and production.
///
/// Values are resolved at runtime via `--dart-define` flags or
/// by the [AppFlavor] selection in [main.dart].
library;

import 'package:rug/core/constants/api_constants.dart';
import 'package:rug/core/enums/app_enums.dart';

class EnvConfig {
  const EnvConfig._({
    required this.flavor,
    required this.apiBaseUrl,
    required this.wsBaseUrl,
    required this.enableLogging,
    required this.enableCrashlytics,
  });

  final AppFlavor flavor;
  final String apiBaseUrl;
  final String wsBaseUrl;
  final bool enableLogging;
  final bool enableCrashlytics;

  /// Current environment — set during app initialization.
  static late final EnvConfig instance;

  /// Initialize with a specific flavor.
  static void init(AppFlavor flavor) {
    instance = switch (flavor) {
      AppFlavor.dev => const EnvConfig._(
          flavor: AppFlavor.dev,
          apiBaseUrl: ApiConstants.devBaseUrl,
          wsBaseUrl: ApiConstants.devWsUrl,
          enableLogging: true,
          enableCrashlytics: false,
        ),
      AppFlavor.staging => const EnvConfig._(
          flavor: AppFlavor.staging,
          apiBaseUrl: ApiConstants.stagingBaseUrl,
          wsBaseUrl: ApiConstants.stagingWsUrl,
          enableLogging: true,
          enableCrashlytics: true,
        ),
      AppFlavor.prod => const EnvConfig._(
          flavor: AppFlavor.prod,
          apiBaseUrl: ApiConstants.prodBaseUrl,
          wsBaseUrl: ApiConstants.prodWsUrl,
          enableLogging: false,
          enableCrashlytics: true,
        ),
    };
  }

  /// Resolve flavor from `--dart-define=FLAVOR=dev|staging|prod`.
  static AppFlavor resolveFlavor() {
    const flavorStr = String.fromEnvironment('FLAVOR', defaultValue: 'dev');
    return switch (flavorStr) {
      'prod' || 'production' => AppFlavor.prod,
      'staging' => AppFlavor.staging,
      _ => AppFlavor.dev,
    };
  }

  bool get isDev => flavor == AppFlavor.dev;
  bool get isStaging => flavor == AppFlavor.staging;
  bool get isProd => flavor == AppFlavor.prod;
}
