/// BuildContext extension methods for quick access to theme, media query, and navigation.
library;

import 'package:flutter/material.dart';

extension ContextExtensions on BuildContext {
  // === Theme ===
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;
  bool get isDarkMode => theme.brightness == Brightness.dark;

  // === Media Query ===
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => mediaQuery.size;
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;
  EdgeInsets get viewPadding => mediaQuery.viewPadding;
  EdgeInsets get viewInsets => mediaQuery.viewInsets;
  double get statusBarHeight => viewPadding.top;
  double get bottomSafeArea => viewPadding.bottom;
  Orientation get orientation => mediaQuery.orientation;
  bool get isLandscape => orientation == Orientation.landscape;
  bool get isPortrait => orientation == Orientation.portrait;

  // === Responsive Breakpoints ===
  bool get isMobile => screenWidth < 600;
  bool get isTablet => screenWidth >= 600 && screenWidth < 1024;
  bool get isDesktop => screenWidth >= 1024;

  // === Navigation ===
  void pop<T>([T? result]) => Navigator.of(this).pop(result);
  bool get canPop => Navigator.of(this).canPop();

  // === Snackbar ===
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).hideCurrentSnackBar();
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colorScheme.error : null,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // === Focus ===
  void unfocus() => FocusScope.of(this).unfocus();
}
