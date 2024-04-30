import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  const InputField({
    super.key,
    required this.controller,
    required this.hintText,
    this.width = 600,
    this.isPassword = false,
  });

  final TextEditingController controller;
  final String hintText;
  final double width;
  final bool isPassword;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          hintText: hintText,
        ),
        obscureText: isPassword,
        autocorrect: !isPassword,
        enableSuggestions: !isPassword,
      ),
    );
  }
}
