/// Responsive layout builder for adaptive UI.
library;

import 'package:flutter/material.dart';

class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({super.key, required this.mobile, this.tablet, this.desktop});
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;

  static bool isMobile(BuildContext context) => MediaQuery.sizeOf(context).width < mobileBreakpoint;
  static bool isTablet(BuildContext context) => MediaQuery.sizeOf(context).width >= mobileBreakpoint && MediaQuery.sizeOf(context).width < tabletBreakpoint;
  static bool isDesktop(BuildContext context) => MediaQuery.sizeOf(context).width >= tabletBreakpoint;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= tabletBreakpoint && desktop != null) return desktop!;
    if (width >= mobileBreakpoint && tablet != null) return tablet!;
    return mobile;
  }
}
