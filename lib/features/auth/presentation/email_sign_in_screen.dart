/// Email Sign In Screen for the RUG application.
///
/// Implements a dark, luxury, minimal UI with a centered authentication form.
/// Fully responsive, keyboard-resilient, and adheres to the app's dark visual theme.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rug/features/auth/widgets/auth_widgets.dart';
import 'package:rug/features/splash/widgets/splash_animation_constants.dart';
import 'package:rug/routes/route_names.dart';

class EmailSignInScreen extends StatefulWidget {
  const EmailSignInScreen({super.key});

  @override
  State<EmailSignInScreen> createState() => _EmailSignInScreenState();
}

class _EmailSignInScreenState extends State<EmailSignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _handleSignIn() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      // Simulate authenticating
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          // Show verification success placeholder
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xFF0F8A64),
              content: const Text(
                'Authenticated successfully! (Demo)',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
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
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.black,
          gradient: RadialGradient(
            center: Alignment(0.0, -0.05),
            radius: 0.9,
            colors: [
              Color(0xFF04180F), // Very subtle emerald glow
              Colors.black,
            ],
            stops: [0.0, 1.0],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 16.0,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Spacer(flex: 2),

                            // ── TITLE ───────────────────────────────────────────
                            const Text(
                              'SIGN IN',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2.0,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Enter your credentials to access the RUG arena',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                                fontSize: 13,
                                letterSpacing: 0.3,
                              ),
                            ),

                            const Spacer(flex: 2),

                            // ── EMAIL FIELD ──────────────────────────────────────
                            EmailTextField(
                              controller: _emailController,
                              focusNode: _emailFocusNode,
                              onFieldSubmitted: (_) {
                                FocusScope.of(context).requestFocus(_passwordFocusNode);
                              },
                            ),

                            const SizedBox(height: 20),

                            // ── PASSWORD FIELD ───────────────────────────────────
                            PasswordTextField(
                              controller: _passwordController,
                              focusNode: _passwordFocusNode,
                              onFieldSubmitted: (_) => _handleSignIn(),
                            ),

                            const SizedBox(height: 28),

                            // ── SIGN IN BUTTON ───────────────────────────────────
                            PrimaryButton(
                              label: 'Sign In',
                              isLoading: _isLoading,
                              onPressed: _handleSignIn,
                            ),

                            const SizedBox(height: 24),

                            // ── ACTIONS ROW ──────────────────────────────────────
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _TextAction(
                                  label: 'Create New Account',
                                  onPressed: () {
                                    context.push(RouteNames.register);
                                  },
                                ),
                                _TextAction(
                                  label: 'Forgot Password?',
                                  onPressed: () {
                                    // Navigation placeholder recovery screen
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: const Color(0xFF161B22),
                                        content: const Text(
                                          'Forgot Password screen placeholder',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),

                            const Spacer(flex: 4),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Helper text button action.
class _TextAction extends StatefulWidget {
  const _TextAction({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  State<_TextAction> createState() => _TextActionState();
}

class _TextActionState extends State<_TextAction> {
  double _opacity = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _opacity = 0.6),
      onTapUp: (_) {
        setState(() => _opacity = 1.0);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _opacity = 1.0),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 100),
        opacity: _opacity,
        child: Text(
          widget.label,
          style: const TextStyle(
            color: SplashAnimationConstants.gold,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}
