/// Premium menu icon button and slide-down popup panel for the game table.
///
/// Replaces the full toolbar with a single ☰ icon in the top-left corner.
/// On tap, opens a glassmorphism panel showing room info, settings, and exit.
library;

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rug/features/splash/widgets/splash_animation_constants.dart';

class TableMenuButton extends StatelessWidget {
  const TableMenuButton({
    required this.roomCode,
    required this.currentRound,
    required this.totalRounds,
    required this.totalPlayers,
    required this.defaultPoints,
    required this.onLeavePressed,
    super.key,
  });

  final String roomCode;
  final int currentRound;
  final int totalRounds;
  final int totalPlayers;
  final int defaultPoints;
  final VoidCallback onLeavePressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showMenuPanel(context),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: const Color(0xFF0C100E).withValues(alpha: 0.7),
          shape: BoxShape.circle,
          border: Border.all(
            color: SplashAnimationConstants.gold.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
            ),
          ],
        ),
        child: Icon(
          Icons.menu_rounded,
          color: SplashAnimationConstants.gold.withValues(alpha: 0.8),
          size: 18,
        ),
      ),
    );
  }

  void _showMenuPanel(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Menu',
      barrierColor: Colors.black.withValues(alpha: 0.4),
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final slideAnimation = Tween<Offset>(
          begin: const Offset(0, -0.3),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        ));
        final fadeAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        );
        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: child,
          ),
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) {
        return _MenuPanelDialog(
          roomCode: roomCode,
          currentRound: currentRound,
          totalRounds: totalRounds,
          totalPlayers: totalPlayers,
          defaultPoints: defaultPoints,
          onLeavePressed: () {
            Navigator.of(context).pop();
            onLeavePressed();
          },
        );
      },
    );
  }
}

class _MenuPanelDialog extends StatelessWidget {
  const _MenuPanelDialog({
    required this.roomCode,
    required this.currentRound,
    required this.totalRounds,
    required this.totalPlayers,
    required this.defaultPoints,
    required this.onLeavePressed,
  });

  final String roomCode;
  final int currentRound;
  final int totalRounds;
  final int totalPlayers;
  final int defaultPoints;
  final VoidCallback onLeavePressed;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: 16, top: 50),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 220,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0C100E).withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: SplashAnimationConstants.gold.withValues(alpha: 0.2),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: SplashAnimationConstants.emerald.withValues(alpha: 0.05),
                        blurRadius: 20,
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Room code
                      _MenuRow(
                        icon: Icons.tag_rounded,
                        label: 'Room Code',
                        value: roomCode,
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: roomCode));
                          HapticFeedback.lightImpact();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Room code copied!'),
                              backgroundColor: SplashAnimationConstants.emerald.withValues(alpha: 0.8),
                              duration: const Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        trailing: Icon(
                          Icons.copy_rounded,
                          color: Colors.white.withValues(alpha: 0.3),
                          size: 12,
                        ),
                      ),
                      _divider(),

                      // Current round
                      _MenuRow(
                        icon: Icons.loop_rounded,
                        label: 'Round',
                        value: '$currentRound / $totalRounds',
                      ),
                      _divider(),

                      // Target points
                      _MenuRow(
                        icon: Icons.stars_rounded,
                        label: 'Target Points',
                        value: '$defaultPoints pts',
                      ),
                      _divider(),

                      // Players
                      _MenuRow(
                        icon: Icons.people_alt_outlined,
                        label: 'Players',
                        value: '$totalPlayers',
                      ),
                      _divider(),

                      const SizedBox(height: 4),

                      // Leave button
                      GestureDetector(
                        onTap: onLeavePressed,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDA3633).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFFDA3633).withValues(alpha: 0.25),
                              width: 0.8,
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.exit_to_app_rounded,
                                color: Color(0xFFDA3633),
                                size: 16,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Leave Game',
                                style: TextStyle(
                                  color: Color(0xFFDA3633),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        height: 0.5,
        color: Colors.white.withValues(alpha: 0.06),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final content = Row(
      children: [
        Icon(
          icon,
          color: SplashAnimationConstants.gold.withValues(alpha: 0.6),
          size: 14,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 4),
          trailing!,
        ],
      ],
    );

    return onTap != null
        ? GestureDetector(onTap: onTap, child: content)
        : content;
  }
}
