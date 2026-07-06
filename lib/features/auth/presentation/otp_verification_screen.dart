/// Screen 2 of the Forgot Password flow.
///
/// Verifies the 6-digit OTP code sent to the user's account.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rug/features/auth/controller/forgot_password_controller.dart';
import 'package:rug/features/auth/widgets/auth_widgets.dart';
import 'package:rug/features/splash/widgets/splash_animation_constants.dart';
import 'package:rug/routes/route_names.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  ConsumerState<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _verifyOtp() {
    final otpCode = _controllers.map((c) => c.text).join();
    if (otpCode.length == 6) {
      ref.read(forgotPasswordControllerProvider.notifier).verifyOtpCode(otpCode);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFDA3633),
          content: const Text('Please enter all 6 digits of the verification code.'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _autoSubmitIfComplete() {
    final otpCode = _controllers.map((c) => c.text).join();
    if (otpCode.length == 6) {
      _verifyOtp();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(forgotPasswordControllerProvider);

    // Listen for state success
    ref.listen(forgotPasswordControllerProvider, (previous, next) {
      if (next.otpVerifySuccess && !(previous?.otpVerifySuccess ?? false)) {
        context.push(RouteNames.resetPassword);
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

          // ── Content ──────────────────────────────────────────────────────────
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── TITLE ──────────────────────────────────────────────────
                    const Text(
                      'Verify Your Account',
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
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        state.emailOrUsername.contains('@')
                            ? 'Enter the 6-digit verification code sent to ${state.emailOrUsername}.'
                            : 'Enter the 6-digit verification code sent to your registered account.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),

                    // ── OTP INPUT GRID ─────────────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (index) {
                        return SizedBox(
                          width: 48,
                          height: 58,
                          child: _OtpDigitField(
                            controller: _controllers[index],
                            focusNode: _focusNodes[index],
                            autofocus: index == 0,
                            onChanged: (value) {
                              if (value.length > 1) {
                                // Handle Paste
                                final pasted = value.trim();
                                if (pasted.length <= 6) {
                                  for (int i = 0; i < pasted.length; i++) {
                                    _controllers[i].text = pasted[i];
                                  }
                                  final nextFocus = pasted.length < 6 ? pasted.length : 5;
                                  FocusScope.of(context).requestFocus(_focusNodes[nextFocus]);
                                  _autoSubmitIfComplete();
                                }
                              } else if (value.isNotEmpty) {
                                if (index < 5) {
                                  FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
                                } else {
                                  _focusNodes[index].unfocus();
                                  _autoSubmitIfComplete();
                                }
                              } else {
                                if (index > 0) {
                                  FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
                                }
                              }
                            },
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 24),

                    // ── ERROR MESSAGE ──────────────────────────────────────────
                    if (state.otpVerifyError != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: Text(
                          state.otpVerifyError!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFFCF6679),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                    // ── RESEND AND TIMER ROW ───────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (state.countdownSeconds > 0)
                          Text(
                            'Resend code in ${state.countdownSeconds}s',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.4),
                              fontSize: 14,
                            ),
                          )
                        else
                          _ResendButton(
                            onPressed: () async {
                              final success = await ref
                                  .read(forgotPasswordControllerProvider.notifier)
                                  .resendOtp();
                              if (success && context.mounted) {
                                // Reset fields on success resend
                                for (final controller in _controllers) {
                                  controller.clear();
                                }
                                FocusScope.of(context).requestFocus(_focusNodes[0]);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: SplashAnimationConstants.deepEmerald,
                                    content: const Text(
                                      'A new verification code has been sent!',
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                );
                              }
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // ── VERIFY BUTTON ──────────────────────────────────────────
                    PrimaryButton(
                      label: 'Verify OTP',
                      isLoading: state.isOtpVerifyLoading,
                      onPressed: _verifyOtp,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Single digit OTP field component with RUG styling.
class _OtpDigitField extends StatefulWidget {
  const _OtpDigitField({
    required this.controller,
    required this.focusNode,
    this.autofocus = false,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool autofocus;
  final ValueChanged<String> onChanged;

  @override
  State<_OtpDigitField> createState() => _OtpDigitFieldState();
}

class _OtpDigitFieldState extends State<_OtpDigitField> {
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = widget.focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: SplashAnimationConstants.emerald.withValues(alpha: 0.20),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: TextFormField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        maxLength: 6, // We set to 6 so paste value isn't cut off immediately before we handle it
        buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: const Color(0xFF0C100E),
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: SplashAnimationConstants.gold.withValues(alpha: 0.15),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: SplashAnimationConstants.gold.withValues(alpha: 0.15),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: SplashAnimationConstants.gold,
              width: 1.5,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFFCF6679),
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFFCF6679),
              width: 1.5,
            ),
          ),
        ),
        onChanged: widget.onChanged,
      ),
    );
  }
}

/// Resend Code text action button with subtle tap opacity.
class _ResendButton extends StatefulWidget {
  const _ResendButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  State<_ResendButton> createState() => _ResendButtonState();
}

class _ResendButtonState extends State<_ResendButton> {
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
        child: const Text(
          'Resend Code',
          style: TextStyle(
            color: SplashAnimationConstants.gold,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}
