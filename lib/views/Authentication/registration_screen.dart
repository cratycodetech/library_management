import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';

class RegistrationScreen extends StatelessWidget {
  final AuthController authController = Get.put(AuthController());

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Image / Logo
            Container(
              height: size.height * 0.2,
              alignment: Alignment.center,
              child: SvgPicture.asset(
                'assets/svg/loginPageImage.svg',
                height: 100,
              ),
            ),


            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Here will be placed client's \nsuggested text",
                style: TextStyle(color: Colors.grey),
              ),
            ),


            const SizedBox(height: 32),

            _RoundedTextField(label: "User Name", controller: nameController),
            const SizedBox(height: 16),
            _RoundedTextField(label: "Email", controller: emailController),
            const SizedBox(height: 16),
            _RoundedTextField(label: "Password", controller: passwordController, obscureText: true),
            const SizedBox(height: 16),
            _RoundedTextField(label: "Confirm Password", controller: confirmPasswordController, obscureText: true),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  if (passwordController.text != confirmPasswordController.text) {
                    Get.snackbar("Error", "Passwords do not match",
                        backgroundColor: Colors.redAccent, colorText: Colors.white);
                    return;
                  }

                  authController.registerUser(
                    nameController.text.trim(),
                    emailController.text.trim(),
                    passwordController.text.trim(),
                  );
                },
                child: const Text(
                  "Register",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
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
            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
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

