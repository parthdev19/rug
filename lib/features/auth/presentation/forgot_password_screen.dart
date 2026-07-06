/// Screen 1 of the Forgot Password flow.
///
/// Prompts the user to enter their registered Email Address or Username.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rug/features/auth/controller/forgot_password_controller.dart';
import 'package:rug/features/auth/widgets/auth_widgets.dart';
import 'package:rug/features/splash/widgets/splash_animation_constants.dart';
import 'package:rug/routes/route_names.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _inputController = TextEditingController();
  final _inputFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Reset state when entering the screen
    Future.microtask(() {
      ref.read(forgotPasswordControllerProvider.notifier).reset();
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(forgotPasswordControllerProvider.notifier)
          .updateEmailOrUsername(_inputController.text.trim());
      
      final success = await ref.read(forgotPasswordControllerProvider.notifier).sendOtp();
      if (success && mounted) {
        // Navigation is handled by the state listener in build()
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(forgotPasswordControllerProvider);

    // Listen for success or error states
    ref.listen(forgotPasswordControllerProvider, (previous, next) {
      if (next.emailSubmitSuccess && !(previous?.emailSubmitSuccess ?? false)) {
        context.push(RouteNames.verifyOtp);
      }
      if (next.emailSubmitError != null && next.emailSubmitError != previous?.emailSubmitError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFDA3633),
            content: Text(
              next.emailSubmitError!,
              style: const TextStyle(color: Colors.white),
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF050807), // Deep black background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: SplashAnimationConstants.gold,
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          // ── Radial background glow ───────────────────────────────────────────
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  radius: 1.2,
                  colors: [
                    SplashAnimationConstants.emerald.withValues(alpha: 0.03),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── Content Form ─────────────────────────────────────────────────────
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── TITLE ──────────────────────────────────────────────────
                      const Text(
                        'Forgot Password',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // ── SUBTITLE ───────────────────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          'Enter your registered Email Address or Username to receive a verification code.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),

                      // ── EMAIL / USERNAME FIELD ──────────────────────────────────
                      CustomTextField(
                        controller: _inputController,
                        focusNode: _inputFocusNode,
                        labelText: 'Email or Username',
                        hintText: 'Enter your email or username',
                        prefixIcon: Icons.person_outline,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _submit(),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your email address or username';
                          }
                          final trimmed = value.trim();
                          
                          // Accept standard email pattern OR username alphanumeric pattern
                          final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                          final usernameRegex = RegExp(r'^[a-zA-Z0-9_]{3,25}$');

                          if (!emailRegex.hasMatch(trimmed) && !usernameRegex.hasMatch(trimmed)) {
                            return 'Enter a valid email address or username (3-25 chars)';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),

                      // ── SUBMIT BUTTON ──────────────────────────────────────────
                      PrimaryButton(
                        label: 'Submit',
                        isLoading: state.isEmailSubmitLoading,
                        onPressed: _submit,
                      ),
                    ],
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
