/// Styled card container widget.
library;

import 'package:flutter/material.dart';
import 'package:rug/theme/app_radius.dart';
import 'package:rug/theme/app_spacing.dart';

class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.padding, this.margin, this.onTap, this.borderRadius, this.color, this.border});
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final Color? color;
  final Border? border;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).cardTheme.color,
        borderRadius: borderRadius ?? AppRadius.cardRadius,
        border: border ?? Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3)),
      ),
      child: Padding(padding: padding ?? const EdgeInsets.all(AppSpacing.cardPadding), child: child),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: card);
    }
    return card;
  }
}
