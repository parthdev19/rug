/// Numeric extension methods for responsive sizing and formatting.
library;

import 'package:flutter/material.dart';

extension NumExtensions on num {
  /// Creates vertical spacing.
  SizedBox get verticalSpace => SizedBox(height: toDouble());

  /// Creates horizontal spacing.
  SizedBox get horizontalSpace => SizedBox(width: toDouble());

  /// Creates symmetric padding.
  EdgeInsets get allPadding => EdgeInsets.all(toDouble());

  /// Creates horizontal padding.
  EdgeInsets get horizontalPadding =>
      EdgeInsets.symmetric(horizontal: toDouble());

  /// Creates vertical padding.
  EdgeInsets get verticalPadding => EdgeInsets.symmetric(vertical: toDouble());

  /// Creates a circular border radius.
  BorderRadius get circularRadius => BorderRadius.circular(toDouble());

  /// Formats as currency string.
  String toCurrency({String symbol = '₹'}) =>
      '$symbol${toStringAsFixed(2)}';

  /// Formats as compact number (1K, 1M, etc.).
  String get compact {
    if (this >= 1000000) return '${(this / 1000000).toStringAsFixed(1)}M';
    if (this >= 1000) return '${(this / 1000).toStringAsFixed(1)}K';
    return toString();
  }

  /// Duration helpers.
  Duration get milliseconds => Duration(milliseconds: toInt());
  Duration get seconds => Duration(seconds: toInt());
  Duration get minutes => Duration(minutes: toInt());
}
