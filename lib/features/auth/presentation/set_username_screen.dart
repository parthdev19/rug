/// Screen shown after login when the backend reports is_username_set: false.
///
/// The user must choose a username before being admitted to the home screen.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rug/features/auth/controller/set_username_controller.dart';
import 'package:rug/features/auth/widgets/auth_widgets.dart';
import 'package:rug/features/splash/widgets/splash_animation_constants.dart';
import 'package:rug/routes/route_names.dart';

class SetUsernameScreen extends ConsumerStatefulWidget {
  const SetUsernameScreen({super.key});

  @override
  ConsumerState<SetUsernameScreen> createState() => _SetUsernameScreenState();
}

class _SetUsernameScreenState extends ConsumerState<SetUsernameScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _usernameFocusNode = FocusNode();

  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _usernameFocusNode.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      final username = _usernameController.text.trim();
      final success = await ref
          .read(setUsernameControllerProvider.notifier)
          .setUsername(username);

      if (success && mounted) {
        context.go(RouteNames.home);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(setUsernameControllerProvider);
    final isLoading = asyncState.isLoading;

    ref.listen<AsyncValue<void>>(setUsernameControllerProvider, (_, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFDA3633),
            content: Text(
              next.error.toString(),
              style: const TextStyle(color: Colors.white),
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF050807),
      body: Stack(
        children: [
          // ── Radial background glow ──────────────────────────────────────────
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  radius: 1.2,
                  colors: [
                    SplashAnimationConstants.gold.withValues(alpha: 0.04),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── Decorative top card icon ────────────────────────────────────────
          Positioned(
            top: -40,
            right: -40,
            child: Opacity(
              opacity: 0.04,
              child: Icon(
                Icons.person_outline_rounded,
                size: 280,
                color: SplashAnimationConstants.gold,
              ),
            ),
          ),

          // ── Main content ────────────────────────────────────────────────────
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Center(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28.0,
                    vertical: 24.0,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ── Badge / icon ────────────────────────────────────
                        Center(
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: SplashAnimationConstants.gold
                                    .withValues(alpha: 0.4),
                                width: 1.5,
                              ),
                              gradient: RadialGradient(
                                colors: [
                                  SplashAnimationConstants.gold
                                      .withValues(alpha: 0.15),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                            child: const Icon(
                              Icons.badge_outlined,
                              color: SplashAnimationConstants.gold,
                              size: 34,
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // ── Title ───────────────────────────────────────────
                        const Text(
                          'Choose your name',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // ── Subtitle ────────────────────────────────────────
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Text(
                            'Pick a unique username. This is how other players will know you at the table.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.55),
                              fontSize: 13.5,
                              height: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 44),

                        // ── Username field ──────────────────────────────────
                        CustomTextField(
                          controller: _usernameController,
                          focusNode: _usernameFocusNode,
                          labelText: 'Username',
                          hintText: 'e.g. card_shark99',
                          prefixIcon: Icons.alternate_email_rounded,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _submit(),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a username';
                            }
                            final trimmed = value.trim();
                            if (trimmed.length < 3) {
                              return 'Username must be at least 3 characters';
                            }
                            if (trimmed.length > 20) {
                              return 'Username must not exceed 20 characters';
                            }
                            final regex = RegExp(r'^[a-zA-Z0-9_]+$');
                            if (!regex.hasMatch(trimmed)) {
                              return 'Only letters, numbers, and underscores';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),

                        // ── CTA ─────────────────────────────────────────────
                        PrimaryButton(
                          label: 'Set Username',
                          isLoading: isLoading,
                          onPressed: _submit,
                        ),

                        const SizedBox(height: 24),

                        // ── Hint ────────────────────────────────────────────
                        Text(
                          'You can change this later from your profile.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.3),
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
