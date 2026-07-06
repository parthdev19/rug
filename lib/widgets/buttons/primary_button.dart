/// Premium Primary Button widget for the RUG application.
///
/// Implements an emerald gradient, subtle press animation, and premium glow shadow.
library;

import 'package:flutter/material.dart';

class PrimaryButton extends StatefulWidget {
  const PrimaryButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = widget.onPressed != null && !widget.isLoading;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: isEnabled ? (_) => _controller.forward() : null,
        onTapUp: isEnabled
            ? (_) {
                _controller.reverse();
                widget.onPressed?.call();
              }
            : null,
        onTapCancel: isEnabled ? () => _controller.reverse() : null,
        child: Opacity(
          opacity: isEnabled ? 1.0 : 0.6,
          child: Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF18C88A), // Top
                  Color(0xFF0F8A64), // Bottom
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F8A64).withValues(alpha: 0.35),
                  blurRadius: 14,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.30),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: widget.isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      widget.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
