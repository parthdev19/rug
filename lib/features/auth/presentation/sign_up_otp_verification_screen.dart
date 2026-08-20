/// Post-registration OTP Verification Screen.
///
/// After a user registers with email/password, they are directed here to
/// verify their email address by entering the 4-digit code sent to their inbox.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rug/features/auth/controller/register_controller.dart';
import 'package:rug/features/auth/controller/sign_up_otp_controller.dart';
import 'package:rug/features/auth/widgets/auth_widgets.dart';
import 'package:rug/features/splash/widgets/splash_animation_constants.dart';
import 'package:rug/routes/route_names.dart';

class SignUpOtpVerificationScreen extends ConsumerStatefulWidget {
  const SignUpOtpVerificationScreen({
    required this.email,
    super.key,
  });

  final String email;

  @override
  ConsumerState<SignUpOtpVerificationScreen> createState() =>
      _SignUpOtpVerificationScreenState();
}

class _SignUpOtpVerificationScreenState
    extends ConsumerState<SignUpOtpVerificationScreen> {
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(signUpOtpControllerProvider.notifier).startTimer();
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _currentOtp => _controllers.map((c) => c.text).join();

  Future<void> _verifyOtp() async {
    final code = _currentOtp;
    if (code.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFDA3633),
          content: const Text('Please enter all 4 digits of the verification code.'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    await ref.read(signUpOtpControllerProvider.notifier).verifyOtp(
          email: widget.email,
          code: code,
        );
  }

  void _autoSubmitIfComplete() {
    if (_currentOtp.length == 4) {
      _verifyOtp();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(signUpOtpControllerProvider);

    // Navigate to login on success
    ref.listen(signUpOtpControllerProvider, (previous, next) {
      if (next.isVerifySuccess && !(previous?.isVerifySuccess ?? false)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xFF0F8A64),
              content: const Text(
                'Email verified! Entering the app...',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
          ref.read(signUpOtpControllerProvider.notifier).reset();
          ref.read(registerControllerProvider.notifier).reset();
          context.go(RouteNames.postLoginLoading);
        }
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF050807),
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
          // Background glow
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

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Icon
                    const Icon(
                      Icons.mark_email_unread_outlined,
                      color: SplashAnimationConstants.gold,
                      size: 56,
                    ),
                    const SizedBox(height: 24),

                    // Title
                    const Text(
                      'Verify Your Email',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Subtitle
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 14,
                            height: 1.5,
                          ),
                          children: [
                            const TextSpan(text: 'We sent a 4-digit code to\n'),
                            TextSpan(
                              text: widget.email,
                              style: const TextStyle(
                                color: SplashAnimationConstants.gold,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),

                    // 4-digit OTP grid
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(4, (index) {
                        return Padding(
                          padding: EdgeInsets.only(right: index < 3 ? 16.0 : 0),
                          child: SizedBox(
                            width: 68,
                            height: 72,
                            child: _OtpDigitField(
                              controller: _controllers[index],
                              focusNode: _focusNodes[index],
                              autofocus: index == 0,
                              onChanged: (value) {
                                if (value.length > 1) {
                                  final pasted = value.trim();
                                  if (pasted.length <= 4) {
                                    for (int i = 0; i < pasted.length; i++) {
                                      _controllers[i].text = pasted[i];
                                    }
                                    final nextFocus = pasted.length < 4 ? pasted.length : 3;
                                    FocusScope.of(context).requestFocus(_focusNodes[nextFocus]);
                                    _autoSubmitIfComplete();
                                  }
                                } else if (value.isNotEmpty) {
                                  if (index < 3) {
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
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 24),

                    // Error message
                    if (state.verifyError != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          state.verifyError!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFFCF6679),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                    // Resend / Countdown row
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
                        else if (state.isResendLoading)
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: SplashAnimationConstants.gold.withValues(alpha: 0.7),
                            ),
                          )
                        else
                          GestureDetector(
                            onTap: () async {
                              final success = await ref
                                  .read(signUpOtpControllerProvider.notifier)
                                  .resendOtp(email: widget.email);
                              if (success && mounted) {
                                for (final c in _controllers) c.clear();
                                FocusScope.of(context).requestFocus(_focusNodes[0]);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: SplashAnimationConstants.deepEmerald,
                                    content: const Text(
                                      'A new code has been sent!',
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                );
                              }
                            },
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
                      ],
                    ),
                    const SizedBox(height: 40),

                    // Verify button
                    PrimaryButton(
                      label: 'Verify Email',
                      isLoading: state.isVerifyLoading,
                      onPressed: _verifyOtp,
                    ),

                    const SizedBox(height: 16),

                    // Info text
                    Text(
                      "Didn't receive the code? Check your spam folder.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.35),
                        fontSize: 12,
                      ),
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

/// Single digit OTP field — styled consistently with the rest of the auth screens.
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
    setState(() => _isFocused = widget.focusNode.hasFocus);
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
                  color: SplashAnimationConstants.gold.withValues(alpha: 0.25),
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
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        maxLength: 4,
        buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
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
        ),
        onChanged: widget.onChanged,
      ),
    );
  }
}
