/// Shadow definitions for elevation and depth effects.
library;

import 'package:flutter/material.dart';
import 'package:rug/theme/app_colors.dart';

class AppShadows {
  AppShadows._();

  /// Subtle shadow for cards and surfaces.
  static const List<BoxShadow> card = [
    BoxShadow(
      color: AppColors.cardShadow,
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  /// Elevated shadow for floating elements.
  static const List<BoxShadow> elevated = [
    BoxShadow(
      color: AppColors.cardShadow,
      blurRadius: 16,
      offset: Offset(0, 4),
      spreadRadius: 1,
    ),
  ];

  /// Heavy shadow for modals and overlays.
  static const List<BoxShadow> overlay = [
    BoxShadow(
      color: AppColors.overlayDark,
      blurRadius: 32,
      offset: Offset(0, 8),
      spreadRadius: 4,
    ),
  ];

  /// Glow effect for gold accents.
  static List<BoxShadow> goldGlow = [
    BoxShadow(
      color: AppColors.accent.withValues(alpha: 0.3),
      blurRadius: 20,
      spreadRadius: 2,
    ),
  ];

  /// Glow effect for primary color.
  static List<BoxShadow> primaryGlow = [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.3),
      blurRadius: 20,
      spreadRadius: 2,
    ),
  ];

  /// Success glow.
  static List<BoxShadow> successGlow = [
    BoxShadow(
      color: AppColors.success.withValues(alpha: 0.3),
      blurRadius: 16,
      spreadRadius: 1,
    ),
  ];

  /// Error glow.
  static List<BoxShadow> errorGlow = [
    BoxShadow(
      color: AppColors.error.withValues(alpha: 0.3),
      blurRadius: 16,
      spreadRadius: 1,
    ),
  ];
}
