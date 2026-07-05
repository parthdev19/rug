/// Premium Email Text Field wrapper for the RUG registration screen.
library;

import 'package:flutter/material.dart';
import 'package:rug/features/auth/widgets/email_text_field.dart';

class EmailField extends StatelessWidget {
  const EmailField({
    required this.controller,
    this.focusNode,
    this.textInputAction = TextInputAction.next,
    this.onFieldSubmitted,
    super.key,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    return EmailTextField(
      controller: controller,
      focusNode: focusNode,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
    );
  }
}
