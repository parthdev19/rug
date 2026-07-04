/// String extension methods.
library;

extension StringExtensions on String {
  /// Capitalizes the first letter.
  String get capitalized =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  /// Capitalizes every word.
  String get titleCase =>
      split(' ').map((word) => word.capitalized).join(' ');

  /// Checks if the string is a valid email.
  bool get isValidEmail =>
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);

  /// Checks if the string is a valid phone number (basic).
  bool get isValidPhone => RegExp(r'^\+?[\d\s-]{10,15}$').hasMatch(this);

  /// Returns null if empty, otherwise returns the string.
  String? get nullIfEmpty => isEmpty ? null : this;

  /// Truncates the string to [maxLength] with an optional [suffix].
  String truncate(int maxLength, {String suffix = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - suffix.length)}$suffix';
  }

  /// Removes all whitespace from the string.
  String get removeWhitespace => replaceAll(RegExp(r'\s+'), '');
}

extension NullableStringExtensions on String? {
  /// Returns true if the string is null or empty.
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  /// Returns true if the string is not null and not empty.
  bool get isNotNullOrEmpty => !isNullOrEmpty;
}
