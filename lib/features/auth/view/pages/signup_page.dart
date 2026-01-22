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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Sign up",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 44),
            ),
            const SizedBox(height: 30),

            // FIELDS!
            CustomField(hintText: "Name"),
            const SizedBox(height: 20),

            CustomField(hintText: "Email"),
            const SizedBox(height: 20),

            CustomField(hintText: "Password"),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
