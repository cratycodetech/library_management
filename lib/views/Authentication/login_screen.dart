import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/login_controller.dart';
import '../../routes/routes.dart';

class LoginScreen extends StatelessWidget {
  final loginController = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.arrow_back, size: 28),
              SizedBox(height: 30),
              Center(
                child: Column(
                  children: [
                    Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(Icons.image_outlined, size: 50),
                    ),
                    SizedBox(height: 20),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Here will be placed client's \nsuggested text",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              Text("Email", style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              _buildRoundedInput(controller: loginController.emailOrPhoneController),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Password", style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(height: 8),
              _buildRoundedInput(
                controller: loginController.passwordController,
                obscureText: true,
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Spacer(),
                  GestureDetector(
                    onTap: () {
                      Get.toNamed(AppRoutes.forgetPassword);
                    },
                    child: Text(
                      "Forget Password?",
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: StadiumBorder(),
                  ),
                  onPressed: loginController.login, // ✅ Hooked login function
                  child: Text("Login", style: TextStyle(fontSize: 16, color: Color(0xFFFFFFFF))),
                ),
              ),
              SizedBox(height: 30),
              Row(
                children: [
                  Expanded(child: Divider(thickness: 1)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text("Or Login With"),
                  ),
                  Expanded(child: Divider(thickness: 1)),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSocialButton(FontAwesomeIcons.facebookF, () {
                    Get.find<AuthController>().signInWithFacebook();
                  }),
                  _buildSocialButton(FontAwesomeIcons.google, () {
                    Get.find<AuthController>().signInWithGoogle();
                  }),
                  _buildSocialButton(FontAwesomeIcons.xTwitter, () {
                    Get.find<AuthController>().signInWithTwitter();
                  }),
                ],
              ),
              SizedBox(height: 30),
              Center(
                child: Text.rich(
                  TextSpan(
                    text: "Don’t have an account? ",
                    children: [
                      TextSpan(
                        text: "Register",
                        style: TextStyle(fontWeight: FontWeight.bold),
                        recognizer: TapGestureRecognizer()..onTap = () {
                          Get.toNamed("/registration");
                        },
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoundedInput({
    bool obscureText = false,
    required TextEditingController controller,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black12),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Center(
          child: FaIcon(icon, size: 20),
        ),
      ),
    );
  }
}
