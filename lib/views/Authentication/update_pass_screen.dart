import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../controllers/auth_controller.dart';

class UpdatePassScreen extends StatefulWidget {
  const UpdatePassScreen({super.key});

  @override
  State<UpdatePassScreen> createState() => _UpdatePassScreenState();
}

class _UpdatePassScreenState extends State<UpdatePassScreen> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final authController = Get.find<AuthController>();
  final String email = Get.arguments?['email'] ?? '';


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24), // optional extra padding
          child: Column(
            children: [
              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.all(32.0),
                child: const Text(
                  "Here will be placed client's suggested text in two lines",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    // Login Button
                    _RoundedTextField(
                        label: "New Password", controller: passwordController ),
                    const SizedBox(height: 24),
                    _RoundedTextField(
                        label: "Confirm Password", controller: newPasswordController),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          backgroundColor: Colors.black,
                        ),
                        onPressed: () {
                          final newPassword = passwordController.text.trim();
                          final confirmPassword = newPasswordController.text.trim();

                          if (newPassword.isEmpty || confirmPassword.isEmpty) {
                            Get.snackbar("Error", "Please fill in all fields.");
                            return;
                          }

                          if (newPassword != confirmPassword) {
                            Get.snackbar("Error", "Passwords do not match.");
                            return;
                          }

                          authController.updateUserPassword(email, newPassword);
                        },
                        child: const Text(
                          'Reset Password',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Register Button
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundedTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscureText;

  const _RoundedTextField({
    required this.label,
    required this.controller,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Align label to the left
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8), // space between label and box
        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade100,
            contentPadding:
            const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}

