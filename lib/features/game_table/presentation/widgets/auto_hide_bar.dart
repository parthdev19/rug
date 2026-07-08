/// Reusable auto-hide bar widget with swipe-to-reveal and timed auto-dismiss.
///
/// Used for both the top toolbar and bottom action bar. Slides in/out with
/// opacity animation. Auto-hides after ~3 seconds of inactivity unless
/// [forceVisible] is true.
library;

import 'dart:async';
import 'package:flutter/material.dart';

class AutoHideBar extends StatefulWidget {
  const AutoHideBar({
    required this.child,
    required this.direction,
    this.autoHideDuration = const Duration(seconds: 3),
    this.forceVisible = false,
    super.key,
  });

  /// The bar content.
  final Widget child;

  /// Which edge the bar slides from. Use [AxisDirection.up] for a top bar
  /// (slides up to hide) and [AxisDirection.down] for a bottom bar
  /// (slides down to hide).
  final AxisDirection direction;

  /// How long the bar stays visible before auto-hiding.
  final Duration autoHideDuration;

  /// If true, the bar remains visible regardless of the timer (e.g., when
  /// it's the current player's turn for the bottom action bar).
  final bool forceVisible;

  @override
  State<AutoHideBar> createState() => AutoHideBarState();
}

class AutoHideBarState extends State<AutoHideBar> {
  bool _visible = true;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _startHideTimer();
  }

  @override
  void didUpdateWidget(covariant AutoHideBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.forceVisible && !oldWidget.forceVisible) {
      _show();
    } else if (!widget.forceVisible && oldWidget.forceVisible) {
      _startHideTimer();
    }
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  /// Show the bar. Called externally by the swipe detector.
  void show() => _show();

  void _show() {
    if (!mounted) return;
    setState(() => _visible = true);
    _startHideTimer();
  }

  void _hide() {
    if (!mounted || widget.forceVisible) return;
    setState(() => _visible = false);
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    if (widget.forceVisible) return;
    _hideTimer = Timer(widget.autoHideDuration, _hide);
  }

  /// The offset to slide to when hidden.
  Offset get _hiddenOffset {
    return switch (widget.direction) {
      AxisDirection.up => const Offset(0, -1),
      AxisDirection.down => const Offset(0, 1),
      AxisDirection.left => const Offset(-1, 0),
      AxisDirection.right => const Offset(1, 0),
    };
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: _visible ? Offset.zero : _hiddenOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: _visible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}
