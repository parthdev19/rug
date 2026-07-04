/// Root application widget.
///
/// Configures MaterialApp.router with GoRouter, theme provider,
/// and global error handling.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rug/routes/app_router.dart';
import 'package:rug/theme/app_theme.dart';
import 'package:rug/theme/theme_provider.dart';

/// The root widget of the RUG application.
class RUGApp extends ConsumerWidget {
  const RUGApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'RUG',
      debugShowCheckedModeBanner: false,

      // Theme
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,

      // Routing
      routerConfig: router,

      // Global error widget
      builder: (context, child) {
        // Apply global text scaling limits
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: MediaQuery.of(context).textScaler.clamp(
              minScaleFactor: 0.8,
              maxScaleFactor: 1.2,
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
