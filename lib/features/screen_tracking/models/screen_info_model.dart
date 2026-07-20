/// Data model for a single screen info entry.
library;

/// Immutable model representing one screen visit event.
class ScreenInfoModel {
  const ScreenInfoModel({
    required this.screenName,
    required this.screenTime,
  });

  /// Snake_case screen name, e.g. `home_screen`.
  final String screenName;

  /// UTC timestamp when the user entered the screen.
  final DateTime screenTime;

  Map<String, dynamic> toJson() => {
        'screen_name': screenName,
        'screen_time': screenTime.toUtc().toIso8601String(),
      };
}
