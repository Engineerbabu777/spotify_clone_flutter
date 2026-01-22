import 'package:client/features/auth/view/widgets/custom_field.dart';
import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          const Text(
            "Sign up",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 44),
          ),

          // FIELDS!
          CustomField(hintText: "Name"),
        ],
      ),
    );
  }
}
