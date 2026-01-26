import 'package:client/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';

class AuthGradientButton extends StatelessWidget {
  final VoidCallback fnHandler;
  final String text;

  const AuthGradientButton({
    super.key,
    required this.fnHandler,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentGeometry.bottomLeft,
          end: AlignmentGeometry.topRight,

          colors: [Pallete.gradient1, Pallete.gradient2],
        ),
        borderRadius: BorderRadius.circular(7),
      ),
      child: ElevatedButton(
        onPressed: fnHandler,
        style: ElevatedButton.styleFrom(
          fixedSize: Size(395, 55),
          backgroundColor: Pallete.transparentColor,
          shadowColor: Pallete.transparentColor,
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
