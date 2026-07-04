/// Riverpod theme provider for dynamic theme switching using code generation.
library;

import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_provider.g.dart';

/// Manages theme mode state with persistence.
@riverpod
class ThemeModeNotifier extends _$ThemeModeNotifier {
  @override
  ThemeMode build() => ThemeMode.dark;

  /// Switch to light mode.
  void setLight() => state = ThemeMode.light;

  /// Switch to dark mode.
  void setDark() => state = ThemeMode.dark;

  /// Follow system theme.
  void setSystem() => state = ThemeMode.system;

  /// Toggle between light and dark.
  void toggle() {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }

  /// Set from stored preference string.
  void setFromString(String? value) {
    state = switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      'system' => ThemeMode.system,
      _ => ThemeMode.dark, // Default to dark for a card game
    };
  }

  /// Get string representation for storage.
  String get asString => switch (state) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        ThemeMode.system => 'system',
      };
}
