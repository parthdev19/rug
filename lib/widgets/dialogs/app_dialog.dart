/// App dialog widgets.
library;

import 'package:flutter/material.dart';
import 'package:rug/theme/app_radius.dart';
import 'package:rug/theme/app_spacing.dart';

class AppDialog {
  AppDialog._();

  static Future<bool?> showConfirmation(BuildContext context, {required String title, required String message, String confirmText = 'Confirm', String cancelText = 'Cancel'}) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.dialogRadius),
        title: Text(title),
        content: Text(message),
        contentPadding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.sm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(cancelText)),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: Text(confirmText)),
        ],
      ),
    );
  }

  static Future<void> showAlert(BuildContext context, {required String title, required String message, String buttonText = 'OK'}) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.dialogRadius),
        title: Text(title),
        content: Text(message),
        actions: [ElevatedButton(onPressed: () => Navigator.pop(context), child: Text(buttonText))],
      ),
    );
  }
}
