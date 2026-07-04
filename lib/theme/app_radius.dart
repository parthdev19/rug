/// Border radius constants for consistent rounding.
library;

import 'package:flutter/material.dart';

class AppRadius {
  AppRadius._();

  // === Values ===
  static const double smValue = 4;
  static const double mdValue = 8;
  static const double lgValue = 12;
  static const double xlValue = 16;
  static const double xxlValue = 24;
  static const double fullValue = 999;

  // === Semantic ===
  static const double card = 12;
  static const double button = 8;
  static const double dialog = 20;
  static const double input = 8;
  static const double chip = 20;
  static const double avatar = 999;
  static const double bottomSheet = 24;

  // === BorderRadius ===
  static final BorderRadius sm = BorderRadius.circular(smValue);
  static final BorderRadius md = BorderRadius.circular(mdValue);
  static final BorderRadius lg = BorderRadius.circular(lgValue);
  static final BorderRadius xl = BorderRadius.circular(xlValue);
  static final BorderRadius xxl = BorderRadius.circular(xxlValue);
  static final BorderRadius full = BorderRadius.circular(fullValue);

  static final BorderRadius cardRadius = BorderRadius.circular(card);
  static final BorderRadius buttonRadius = BorderRadius.circular(button);
  static final BorderRadius dialogRadius = BorderRadius.circular(dialog);
  static final BorderRadius inputRadius = BorderRadius.circular(input);
  static final BorderRadius chipRadius = BorderRadius.circular(chip);
  static const BorderRadius bottomSheetRadius = BorderRadius.only(
    topLeft: Radius.circular(bottomSheet),
    topRight: Radius.circular(bottomSheet),
  );
}
