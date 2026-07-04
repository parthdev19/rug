/// Custom page transition builders for GoRouter.
///
/// Provides fade, slide, scale, and combined transitions
/// for seamless screen navigation.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rug/animations/animation_constants.dart';

class PageTransitions {
  PageTransitions._();

  /// Fade transition.
  static CustomTransitionPage<T> fade<T>({
    required Widget child,
    required GoRouterState state,
    Duration duration = AnimationConstants.normal,
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  /// Slide from right transition.
  static CustomTransitionPage<T> slideRight<T>({
    required Widget child,
    required GoRouterState state,
    Duration duration = AnimationConstants.normal,
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).chain(CurveTween(curve: AnimationConstants.defaultCurve));

        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }

  /// Slide from bottom transition.
  static CustomTransitionPage<T> slideUp<T>({
    required Widget child,
    required GoRouterState state,
    Duration duration = AnimationConstants.normal,
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).chain(CurveTween(curve: AnimationConstants.defaultCurve));

        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }

  /// Scale transition (zoom in).
  static CustomTransitionPage<T> scale<T>({
    required Widget child,
    required GoRouterState state,
    Duration duration = AnimationConstants.normal,
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final scaleAnimation = Tween(begin: 0.85, end: 1.0)
            .chain(CurveTween(curve: AnimationConstants.sharpCurve))
            .animate(animation);

        final fadeAnimation = Tween(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn))
            .animate(animation);

        return FadeTransition(
          opacity: fadeAnimation,
          child: ScaleTransition(scale: scaleAnimation, child: child),
        );
      },
    );
  }

  /// No transition (instant).
  static CustomTransitionPage<T> none<T>({
    required Widget child,
    required GoRouterState state,
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: Duration.zero,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return child;
      },
    );
  }
}
