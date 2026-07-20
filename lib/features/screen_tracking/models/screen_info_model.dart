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
        'screen_time': _toUtcMillisIso(screenTime),
      };

  /// Formats [dt] as UTC ISO-8601 with millisecond precision.
  ///
  /// Dart's [DateTime.toIso8601String] produces up to 6 decimal places
  /// (microseconds), e.g. `2026-07-20T14:37:47.087049Z`. The backend's
  /// class-validator `@IsDateString()` only accepts up to 3 decimal places
  /// (milliseconds). This helper ensures the format is always
  /// `YYYY-MM-DDTHH:mm:ss.mmmZ`.
  static String _toUtcMillisIso(DateTime dt) {
    final utc = dt.toUtc();
    final ms = utc.millisecond.toString().padLeft(3, '0');
    return '${utc.year.toString().padLeft(4, '0')}'
        '-${utc.month.toString().padLeft(2, '0')}'
        '-${utc.day.toString().padLeft(2, '0')}'
        'T${utc.hour.toString().padLeft(2, '0')}'
        ':${utc.minute.toString().padLeft(2, '0')}'
        ':${utc.second.toString().padLeft(2, '0')}'
        '.$ms'
        'Z';
  }
}
