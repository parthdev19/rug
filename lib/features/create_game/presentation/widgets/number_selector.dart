import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rug/features/splash/widgets/splash_animation_constants.dart';

class NumberSelector extends StatelessWidget {
  const NumberSelector({
    required this.value,
    required this.onDecrement,
    required this.onIncrement,
    required this.label,
    required this.minValue,
    required this.maxValue,
    super.key,
  });

  final int value;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final String label;
  final int minValue;
  final int maxValue;

  @override
  Widget build(BuildContext context) {
    final canDecrement = value > minValue;
    final canIncrement = value < maxValue;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Decrement button
        _SelectorButton(
          icon: Icons.remove_rounded,
          isEnabled: canDecrement,
          onPressed: () {
            if (canDecrement) {
              HapticFeedback.lightImpact();
              onDecrement();
            }
          },
        ),

        // Value text (Animated)
        Expanded(
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              transitionBuilder: (Widget child, Animation<double> animation) {
                // Premium slide + fade transition
                final offsetAnimation = Tween<Offset>(
                  begin: const Offset(0.0, 0.25),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                );

                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: offsetAnimation,
                    child: child,
                  ),
                );
              },
              child: Text(
                '$value $label',
                key: ValueKey<int>(value),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),

        // Increment button
        _SelectorButton(
          icon: Icons.add_rounded,
          isEnabled: canIncrement,
          onPressed: () {
            if (canIncrement) {
              HapticFeedback.lightImpact();
              onIncrement();
            }
          },
        ),
      ],
    );
  }
}

class _SelectorButton extends StatefulWidget {
  const _SelectorButton({
    required this.icon,
    required this.isEnabled,
    required this.onPressed,
  });

  final IconData icon;
  final bool isEnabled;
  final VoidCallback onPressed;

  @override
  State<_SelectorButton> createState() => _SelectorButtonState();
}

class _SelectorButtonState extends State<_SelectorButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.isEnabled;

    return GestureDetector(
      onTapDown: isEnabled ? (_) => setState(() => _scale = 0.90) : null,
      onTapUp: isEnabled
          ? (_) {
              setState(() => _scale = 1.0);
              widget.onPressed();
            }
          : null,
      onTapCancel: isEnabled ? () => setState(() => _scale = 1.0) : null,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: Opacity(
          opacity: isEnabled ? 1.0 : 0.35,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF0C100E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isEnabled
                    ? SplashAnimationConstants.emerald.withValues(alpha: 0.3)
                    : SplashAnimationConstants.gold.withValues(alpha: 0.1),
                width: 1.5,
              ),
              boxShadow: isEnabled
                  ? [
                      BoxShadow(
                        color: SplashAnimationConstants.emerald.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              widget.icon,
              color: isEnabled
                  ? SplashAnimationConstants.emerald
                  : SplashAnimationConstants.gold,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}
