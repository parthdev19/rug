/// Color palette for the RUG card game.
///
/// A card-game-themed palette with deep greens (felt table),
/// gold accents, card whites, and suit-specific colors.
library;

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // === Primary Palette (Card Table Greens) ===
  static const Color primary = Color(0xFF1B5E20);
  static const Color primaryLight = Color(0xFF2E7D32);
  static const Color primaryDark = Color(0xFF0D3B14);
  static const Color primarySurface = Color(0xFF1A3A1E);

  // === Accent / Gold ===
  static const Color accent = Color(0xFFFFD700);
  static const Color accentLight = Color(0xFFFFE44D);
  static const Color accentDark = Color(0xFFC7A600);

  // === Card Colors ===
  static const Color cardWhite = Color(0xFFFFFBF0);
  static const Color cardBorder = Color(0xFFE0D6C2);
  static const Color cardShadow = Color(0x40000000);

  // === Suit Colors ===
  static const Color suitRed = Color(0xFFD32F2F);
  static const Color suitBlack = Color(0xFF212121);
  static const Color suitClub = Color(0xFF1B5E20);

  // === Dark Theme ===
  static const Color darkBackground = Color(0xFF0D1117);
  static const Color darkSurface = Color(0xFF161B22);
  static const Color darkCard = Color(0xFF1C2333);
  static const Color darkBorder = Color(0xFF30363D);
  static const Color darkText = Color(0xFFE6EDF3);
  static const Color darkTextSecondary = Color(0xFF8B949E);
  static const Color darkElevated = Color(0xFF21262D);

  // === Light Theme ===
  static const Color lightBackground = Color(0xFFF6F8FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFD0D7DE);
  static const Color lightText = Color(0xFF1F2328);
  static const Color lightTextSecondary = Color(0xFF656D76);
  static const Color lightElevated = Color(0xFFF6F8FA);

  // === Semantic Colors ===
  static const Color success = Color(0xFF2EA043);
  static const Color successLight = Color(0xFF56D364);
  static const Color error = Color(0xFFDA3633);
  static const Color errorLight = Color(0xFFF85149);
  static const Color warning = Color(0xFFD29922);
  static const Color warningLight = Color(0xFFE3B341);
  static const Color info = Color(0xFF388BFD);
  static const Color infoLight = Color(0xFF58A6FF);

  // === Gradient Presets ===
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLight, primaryDark],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentLight, accent, accentDark],
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [darkCard, darkSurface],
  );

  // === Overlays ===
  static const Color overlayLight = Color(0x1AFFFFFF);
  static const Color overlayDark = Color(0x80000000);
  static const Color shimmerBase = Color(0xFF2A2A2A);
  static const Color shimmerHighlight = Color(0xFF3A3A3A);
}
