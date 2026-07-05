/// Premium Register Account Screen for the RUG application.
///
/// Implements a dark, luxury, minimal UI with a subtle emerald background glow,
/// custom profile photo picker, validated text fields, and full-width actions.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rug/features/auth/controller/register_controller.dart';
import 'package:rug/features/auth/widgets/auth_widgets.dart';
import 'package:rug/features/splash/widgets/splash_animation_constants.dart';
import 'package:rug/shared/providers/common_providers.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _usernameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    _usernameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      final controller = ref.read(registerControllerProvider.notifier);
      
      // Update form values in state
      controller.updateUsername(_usernameController.text);
      controller.updateEmail(_emailController.text);
      controller.updatePassword(_passwordController.text);
      controller.updateConfirmPassword(_confirmPasswordController.text);

      final success = await controller.register();
      if (success && mounted) {
        // Update global authentication provider
        ref.read(isAuthenticatedProvider.notifier).setAuthenticated(true);
        // Clean state
        controller.reset();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registerControllerProvider);

    // Listen to registration error
    ref.listen(registerControllerProvider, (previous, next) {
      if (next.errorMessage != null && next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFDA3633),
            content: Text(next.errorMessage!),
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
                    SplashAnimationConstants.emerald.withValues(alpha: 0.04),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── Scrollable form ──────────────────────────────────────────────────
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // ── Profile Photo Picker ─────────────────────────────────────
                      ProfileImagePicker(
                        imagePath: state.profileImagePath,
                        onImageSelected: (path) {
                          ref.read(registerControllerProvider.notifier).updateProfileImagePath(path);
                        },
                      ),
                      const SizedBox(height: 32),

                      // ── Username Field ───────────────────────────────────────────
                      UsernameField(
                        controller: _usernameController,
                        focusNode: _usernameFocusNode,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_emailFocusNode);
                        },
                      ),
                      const SizedBox(height: 20),

                      // ── Email Field ──────────────────────────────────────────────
                      EmailField(
                        controller: _emailController,
                        focusNode: _emailFocusNode,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_passwordFocusNode);
                        },
                      ),
                      const SizedBox(height: 20),

                      // ── Password Field ───────────────────────────────────────────
                      PasswordField(
                        controller: _passwordController,
                        focusNode: _passwordFocusNode,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_confirmPasswordFocusNode);
                        },
                      ),
                      const SizedBox(height: 20),

                      // ── Confirm Password Field ───────────────────────────────────
                      ConfirmPasswordField(
                        controller: _confirmPasswordController,
                        passwordController: _passwordController,
                        focusNode: _confirmPasswordFocusNode,
                        onFieldSubmitted: (_) => _submitForm(),
                      ),
                      const SizedBox(height: 32),

                      // ── Create Account Button ────────────────────────────────────
                      PrimaryButton(
                        label: 'Create Account',
                        isLoading: state.isLoading,
                        onPressed: _submitForm,
                      ),
                      const SizedBox(height: 24),

                      // ── Secondary Action ─────────────────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Already have an account? ',
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 14,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.pop(),
                            child: const Text(
                              'Sign In',
                              style: TextStyle(
                                color: SplashAnimationConstants.gold,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
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
