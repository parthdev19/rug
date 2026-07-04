/// Reusable animated wrapper widgets.
library;

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:rug/animations/animation_constants.dart';

/// Fades a child widget in.
class FadeIn extends StatefulWidget {
  const FadeIn({
    super.key,
    required this.child,
    this.duration = AnimationConstants.normal,
    this.delay = Duration.zero,
    this.curve = AnimationConstants.defaultCurve,
  });

  final Widget child;
  final Duration duration;
  final Duration delay;
  final Curve curve;

  @override
  State<FadeIn> createState() => _FadeInState();
}

class _FadeInState extends State<FadeIn> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = CurvedAnimation(parent: _controller, curve: widget.curve);
    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _animation, child: widget.child);
  }
}

/// Scales a child widget in.
class ScaleIn extends StatefulWidget {
  const ScaleIn({
    super.key,
    required this.child,
    this.duration = AnimationConstants.normal,
    this.delay = Duration.zero,
    this.curve = AnimationConstants.springCurve,
    this.beginScale = 0.0,
  });

  final Widget child;
  final Duration duration;
  final Duration delay;
  final Curve curve;
  final double beginScale;

  @override
  State<ScaleIn> createState() => _ScaleInState();
}

class _ScaleInState extends State<ScaleIn> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _scale = Tween(begin: widget.beginScale, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: widget.curve));
    _fade = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    Future.delayed(widget.delay, () { if (mounted) _controller.forward(); });
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _fade, child: ScaleTransition(scale: _scale, child: widget.child));
  }
}

/// Slides a child widget in from a given direction.
class SlideIn extends StatefulWidget {
  const SlideIn({
    super.key,
    required this.child,
    this.duration = AnimationConstants.normal,
    this.delay = Duration.zero,
    this.curve = AnimationConstants.defaultCurve,
    this.beginOffset = const Offset(0, 0.3),
  });

  final Widget child;
  final Duration duration;
  final Duration delay;
  final Curve curve;
  final Offset beginOffset;

  @override
  State<SlideIn> createState() => _SlideInState();
}

class _SlideInState extends State<SlideIn> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slide;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _slide = Tween(begin: widget.beginOffset, end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: widget.curve));
    _fade = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    Future.delayed(widget.delay, () { if (mounted) _controller.forward(); });
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _fade, child: SlideTransition(position: _slide, child: widget.child));
  }
}

/// Blurs a child widget in (blurry → clear).
class BlurIn extends StatefulWidget {
  const BlurIn({super.key, required this.child, this.duration = AnimationConstants.slow, this.delay = Duration.zero, this.maxBlur = 10.0});
  final Widget child;
  final Duration duration;
  final Duration delay;
  final double maxBlur;

  @override
  State<BlurIn> createState() => _BlurInState();
}

class _BlurInState extends State<BlurIn> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    Future.delayed(widget.delay, () { if (mounted) _controller.forward(); });
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final blur = widget.maxBlur * (1 - _controller.value);
        return ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Opacity(opacity: _controller.value, child: child),
        );
      },
      child: widget.child,
    );
  }
}
