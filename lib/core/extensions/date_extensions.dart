/// DateTime extension methods.
library;

import 'package:intl/intl.dart';

extension DateExtensions on DateTime {
  /// Formats as 'Jan 15, 2026'.
  String get formatted => DateFormat.yMMMd().format(this);

  /// Formats as '3:45 PM'.
  String get timeFormatted => DateFormat.jm().format(this);

  /// Formats as 'Jan 15, 2026 3:45 PM'.
  String get fullFormatted => DateFormat.yMMMd().add_jm().format(this);

  /// Formats as '15/01/2026'.
  String get shortDate => DateFormat('dd/MM/yyyy').format(this);

  /// Returns relative time string (e.g., '5 min ago', 'Yesterday').
  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(this);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}mo ago';
    return '${(diff.inDays / 365).floor()}y ago';
  }

  /// Checks if the date is today.
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Checks if the date is yesterday.
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }
}
