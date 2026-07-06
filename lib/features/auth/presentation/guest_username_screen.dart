import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rug/features/auth/controller/guest_controller.dart';
import 'package:rug/features/auth/widgets/auth_widgets.dart';
import 'package:rug/features/splash/widgets/splash_animation_constants.dart';
import 'package:rug/routes/route_names.dart';

class GuestUsernameScreen extends ConsumerStatefulWidget {
  const GuestUsernameScreen({super.key});

  @override
  ConsumerState<GuestUsernameScreen> createState() => _GuestUsernameScreenState();
}

class _GuestUsernameScreenState extends ConsumerState<GuestUsernameScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _usernameFocusNode = FocusNode();

  @override
  void dispose() {
    _usernameController.dispose();
    _usernameFocusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      final username = _usernameController.text.trim();
      final success = await ref
          .read(guestControllerProvider.notifier)
          .registerGuest(username);
      
      if (success && mounted) {
        // Clear auth screen stack and go directly to home
        context.go(RouteNames.home);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final guestState = ref.watch(guestControllerProvider);
    final isLoading = guestState.isLoading;

    // Listen for error messages
    ref.listen<AsyncValue<void>>(guestControllerProvider, (previous, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFDA3633),
            content: Text(
              next.error.toString(),
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
                        'Play as Guest',
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
                          'Enter a username to continue as a guest.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),

                      // ── USERNAME TEXT FIELD ────────────────────────────────────
                      CustomTextField(
                        controller: _usernameController,
                        focusNode: _usernameFocusNode,
                        labelText: 'Username',
                        hintText: 'Enter guest username',
                        prefixIcon: Icons.person_outline,
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
                            return 'Only letters, numbers, and underscores are allowed';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),

                      // ── CONTINUE BUTTON ────────────────────────────────────────
                      PrimaryButton(
                        label: 'Continue',
                        isLoading: isLoading,
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
