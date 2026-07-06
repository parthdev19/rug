/// Screen 3 of the Forgot Password flow.
///
/// Prompts the user to create a new password and verifies strength criteria.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rug/features/auth/controller/forgot_password_controller.dart';
import 'package:rug/features/auth/widgets/auth_widgets.dart';
import 'package:rug/features/splash/widgets/splash_animation_constants.dart';
import 'package:rug/routes/route_names.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  
  final _passwordFocusNode = FocusNode();
  final _confirmFocusNode = FocusNode();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_onPasswordChange);
    _confirmController.addListener(_onConfirmChange);
  }

  @override
  void dispose() {
    _passwordController.removeListener(_onPasswordChange);
    _confirmController.removeListener(_onConfirmChange);
    _passwordController.dispose();
    _confirmController.dispose();
    _passwordFocusNode.dispose();
    _confirmFocusNode.dispose();
    super.dispose();
  }

  void _onPasswordChange() {
    setState(() {});
  }

  void _onConfirmChange() {
    setState(() {});
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      final success = await ref
          .read(forgotPasswordControllerProvider.notifier)
          .resetPassword(_passwordController.text, _confirmController.text);
      
      if (success && mounted) {
        _showSuccessDialog();
      }
    }
  }

  void _showSuccessDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const _SuccessDialog();
      },
    );

    // Auto navigate after 3 seconds
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) {
        // Clear success dialog
        context.pop(); 
        // Go back to sign in
        context.go(RouteNames.login);
        // Reset recovery state
        ref.read(forgotPasswordControllerProvider.notifier).reset();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(forgotPasswordControllerProvider);

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

          // ── Content ──────────────────────────────────────────────────────────
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
                        'Create New Password',
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
                      Text(
                        'Choose a strong password for your account.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 36),

                      // ── NEW PASSWORD FIELD ─────────────────────────────────────
                      CustomTextField(
                        controller: _passwordController,
                        focusNode: _passwordFocusNode,
                        labelText: 'New Password',
                        hintText: 'Enter your new password',
                        prefixIcon: Icons.lock_outline,
                        obscureText: _obscurePassword,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_confirmFocusNode);
                        },
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: Colors.white.withValues(alpha: 0.5),
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password';
                          }
                          if (value.length < 8) {
                            return 'Password must be at least 8 characters';
                          }
                          if (!value.contains(RegExp(r'[A-Z]'))) {
                            return 'Include at least one uppercase letter';
                          }
                          if (!value.contains(RegExp(r'[a-z]'))) {
                            return 'Include at least one lowercase letter';
                          }
                          if (!value.contains(RegExp(r'[0-9]'))) {
                            return 'Include at least one number';
                          }
                          if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
                            return 'Include at least one special character';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // ── STRENGTH INDICATOR (NEW PASSWORD) ──────────────────────
                      PasswordStrengthIndicator(password: _passwordController.text),
                      const SizedBox(height: 28),

                      // ── CONFIRM PASSWORD FIELD ─────────────────────────────────
                      CustomTextField(
                        controller: _confirmController,
                        focusNode: _confirmFocusNode,
                        labelText: 'Confirm New Password',
                        hintText: 'Re-enter your password',
                        prefixIcon: Icons.lock_outline,
                        obscureText: _obscureConfirm,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _submit(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: Colors.white.withValues(alpha: 0.5),
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirm = !_obscureConfirm;
                            });
                          },
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // ── STRENGTH INDICATOR (CONFIRM PASSWORD) ──────────────────
                      PasswordStrengthIndicator(password: _confirmController.text),
                      const SizedBox(height: 36),

                      // ── ERROR MESSAGE ──────────────────────────────────────────
                      if (state.resetPasswordError != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 24.0),
                          child: Text(
                            state.resetPasswordError!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFFCF6679),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                      // ── UPDATE PASSWORD BUTTON ──────────────────────────────────
                      PrimaryButton(
                        label: 'Update Password',
                        isLoading: state.isResetPasswordLoading,
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

/// Premium visual success dialog.
class _SuccessDialog extends StatefulWidget {
  const _SuccessDialog();

  @override
  State<_SuccessDialog> createState() => _SuccessDialogState();
}

class _SuccessDialogState extends State<_SuccessDialog> with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.elasticOut,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            decoration: BoxDecoration(
              color: const Color(0xFF0C100E), // Match input background
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: SplashAnimationConstants.gold.withValues(alpha: 0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: SplashAnimationConstants.emerald.withValues(alpha: 0.1),
                  blurRadius: 24,
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.6),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated green gradient checkmark ring
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF18C88A),
                        Color(0xFF0F8A64),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 44,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Success text headers
                const Text(
                  'Success!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Password updated successfully.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
