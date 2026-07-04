/// Screen size utilities and helpers.
library;

import 'package:flutter/material.dart';

class ScreenUtils {
  ScreenUtils._();

  static double width(BuildContext context) => MediaQuery.sizeOf(context).width;
  static double height(BuildContext context) => MediaQuery.sizeOf(context).height;
  static double statusBarHeight(BuildContext context) => MediaQuery.viewPaddingOf(context).top;
  static double bottomSafeArea(BuildContext context) => MediaQuery.viewPaddingOf(context).bottom;
  static bool isKeyboardVisible(BuildContext context) => MediaQuery.viewInsetsOf(context).bottom > 0;
  static Orientation orientation(BuildContext context) => MediaQuery.orientationOf(context);

  /// Returns a value scaled to the screen width (based on 375px design width).
  static double wp(BuildContext context, double percentage) => width(context) * percentage / 100;

  /// Returns a value scaled to the screen height (based on 812px design height).
  static double hp(BuildContext context, double percentage) => height(context) * percentage / 100;
}
