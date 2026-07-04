/// Formatters for currency, numbers, and dates.
library;

import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static String currency(double amount, {String symbol = '₹'}) => NumberFormat.currency(symbol: symbol, decimalDigits: 2).format(amount);
  static String compactNumber(num value) => NumberFormat.compact().format(value);
  static String percentage(double value) => '${value.toStringAsFixed(1)}%';
  static String date(DateTime dt) => DateFormat.yMMMd().format(dt);
  static String time(DateTime dt) => DateFormat.jm().format(dt);
  static String dateTime(DateTime dt) => DateFormat.yMMMd().add_jm().format(dt);
  static String duration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
