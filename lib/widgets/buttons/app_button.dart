/// Primary app button widget.
library;

import 'package:flutter/material.dart';
import 'package:rug/theme/app_radius.dart';
import 'package:rug/theme/app_colors.dart';

enum AppButtonVariant { primary, secondary, outline, text, gold }

class AppButton extends StatelessWidget {
  const AppButton({super.key, required this.label, this.onPressed, this.variant = AppButtonVariant.primary, this.isLoading = false, this.icon, this.fullWidth = false});
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final IconData? icon;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final button = switch (variant) {
      AppButtonVariant.primary => ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: _buildChild(context),
      ),
      AppButtonVariant.secondary => ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.surface, foregroundColor: Theme.of(context).colorScheme.primary),
        child: _buildChild(context),
      ),
      AppButtonVariant.outline => OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        child: _buildChild(context),
      ),
      AppButtonVariant.text => TextButton(
        onPressed: isLoading ? null : onPressed,
        child: _buildChild(context),
      ),
      AppButtonVariant.gold => ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonRadius)),
        child: _buildChild(context),
      ),
    };

    return fullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }

  Widget _buildChild(BuildContext context) {
    if (isLoading) return const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2));
    if (icon != null) return Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 18), const SizedBox(width: 8), Text(label)]);
    return Text(label);
  }
}
