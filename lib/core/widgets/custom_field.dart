import 'package:flutter/material.dart';

class CustomField extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final bool isObscure;
  final bool? readOnly;
  final VoidCallback? onTap;

  const CustomField({
    super.key,
    required this.hintText,
    this.controller,
    this.isObscure = false,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(hintText: hintText),
      controller: controller,
      validator: (val) {
        if (val!.isEmpty) {
          return "$hintText is missing";
        }
        return null;
      },
      readOnly: readOnly ?? false,
      obscureText: isObscure,
      onTap: onTap,
    );
  }
}
