/// Legal Section footer for the Authentication Screen.
///
/// Displays the terms and prestige protocol with underlines in a low-opacity grey.
library;

import 'package:flutter/material.dart';

class LegalSection extends StatelessWidget {
  const LegalSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.0),
      child: Opacity(
        opacity: 0.55,
        child: Text.rich(
          TextSpan(
            text: 'By continuing, you agree to the ',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 11,
              height: 1.5,
              fontWeight: FontWeight.w400,
            ),
            children: [
              TextSpan(
                text: 'Terms of Play',
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextSpan(text: ' and our '),
              TextSpan(
                text: 'Prestige Protocol',
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextSpan(text: '.'),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
