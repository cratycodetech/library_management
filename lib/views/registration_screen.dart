import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';

class RegistrationScreen extends StatelessWidget {
  final AuthController authController = Get.put(AuthController());
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailPhoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Name Field
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),

            // Email or Phone Field
            TextField(
              controller: emailPhoneController,
              decoration: InputDecoration(
                labelText: "Email or Phone Number",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),

            // Password Field
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),

            // Submit Button
            ElevatedButton(
              onPressed: () {
                authController.registerUser(
                  nameController.text.trim(),
                  emailPhoneController.text.trim(),
                  passwordController.text.trim(),
                );
              },
              child: Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}
