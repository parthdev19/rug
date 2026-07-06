import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:rug/features/splash/widgets/splash_animation_constants.dart';

class SettingsCard extends StatelessWidget {
  const SettingsCard({
    required this.title,
    required this.child,
    this.icon,
    super.key,
  });

  final String title;
  final Widget child;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            color: const Color(0xFF0C100E).withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: SplashAnimationConstants.gold.withValues(alpha: 0.2),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 16,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      color: SplashAnimationConstants.gold,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    title,
                    style: const TextStyle(
                      color: SplashAnimationConstants.gold,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
