/// Premium Password Strength Indicator widget.
///
/// Displays a multi-segment strength bar (Red -> Gold -> Emerald) and
/// a detailed visual checklist of required rules.
library;

import 'package:flutter/material.dart';
import 'package:rug/features/splash/widgets/splash_animation_constants.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  const PasswordStrengthIndicator({required this.password, super.key});

  final String password;

  @override
  Widget build(BuildContext context) {
    final hasMinLength = password.length >= 8;
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasLowercase = password.contains(RegExp(r'[a-z]'));
    final hasNumber = password.contains(RegExp(r'[0-9]'));
    final hasSpecial = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    int score = 0;
    if (hasMinLength) score++;
    if (hasUppercase) score++;
    if (hasLowercase) score++;
    if (hasNumber) score++;
    if (hasSpecial) score++;

    Color strengthColor;
    String strengthText;
    double progress;

    if (password.isEmpty) {
      strengthColor = Colors.white24;
      strengthText = 'None';
      progress = 0.0;
    } else if (score <= 2) {
      strengthColor = const Color(0xFFCF6679); // Premium error red
      strengthText = 'Weak';
      progress = 0.33;
    } else if (score <= 4) {
      strengthColor = SplashAnimationConstants.gold;
      strengthText = 'Medium';
      progress = 0.66;
    } else {
      strengthColor = SplashAnimationConstants.emerald;
      strengthText = 'Strong';
      progress = 1.0;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Strength bar and Label row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Password Strength',
              style: TextStyle(
                color: Colors.white60,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              strengthText,
              style: TextStyle(
                color: strengthColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Custom animated progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Stack(
            children: [
              Container(
                height: 6,
                color: Colors.white.withValues(alpha: 0.08),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 6,
                width: MediaQuery.of(context).size.width * 0.9 * progress,
                decoration: BoxDecoration(
                  color: strengthColor,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: strengthColor.withValues(alpha: 0.3),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Checklist requirements
        _buildRequirementRow('Minimum 8 characters', hasMinLength),
        const SizedBox(height: 6),
        _buildRequirementRow('At least one uppercase letter (A-Z)', hasUppercase),
        const SizedBox(height: 6),
        _buildRequirementRow('At least one lowercase letter (a-z)', hasLowercase),
        const SizedBox(height: 6),
        _buildRequirementRow('At least one number (0-9)', hasNumber),
        const SizedBox(height: 6),
        _buildRequirementRow('At least one special character (!@#\$%^&*)', hasSpecial),
      ],
    );
  }

  Widget _buildRequirementRow(String text, bool isMet) {
    return AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 200),
      style: TextStyle(
        color: isMet ? Colors.white.withValues(alpha: 0.9) : Colors.white.withValues(alpha: 0.35),
        fontSize: 12,
        fontWeight: isMet ? FontWeight.w500 : FontWeight.normal,
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isMet
                  ? SplashAnimationConstants.emerald.withValues(alpha: 0.15)
                  : Colors.transparent,
            ),
            child: Icon(
              isMet ? Icons.check_circle_outline : Icons.circle_outlined,
              size: 14,
              color: isMet
                  ? SplashAnimationConstants.emerald
                  : Colors.white.withValues(alpha: 0.3),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
