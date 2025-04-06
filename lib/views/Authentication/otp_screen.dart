import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';

class OtpScreen extends StatefulWidget {
  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> otpControllers =
  List.generate(6, (_) => TextEditingController());
  late final bool fromForgetPass;
  late final String? email;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    fromForgetPass = args['fromForgetPass'] ?? false;
    email = args['email'];
  }


  void verifyOtp() {
    final authController = Get.find<AuthController>();
    String enteredOtp =
    otpControllers.map((controller) => controller.text).join();

    authController.verifyOtp(
      enteredOtp.trim(),
      fromForgetPass: fromForgetPass,
      emailForReset: email,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool fromForgetPass = Get.arguments?['fromForgetPass'] ?? false;
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: size.height * 0.45,
                width: double.infinity,
                color: Colors.grey.shade200,
                child: Center(
                  child: SvgPicture.asset(
                    'assets/svg/loginPageImage.svg',
                    height: 100,
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Here will be again client's \nrecommended text ",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(5, (index) {
                  return SizedBox(
                    width: 50,
                    child: TextField(
                      controller: otpControllers[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      decoration: InputDecoration(
                        counterText: '',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty && index < 5) {
                          FocusScope.of(context).nextFocus();
                        }
                      },
                    ),
                  );
                }),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: verifyOtp,
                    child: const Text(
                      "Verify",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () async {
                  final authController = Get.find<AuthController>();
                  String newOtp = authController.generateOtp();
                  authController.generatedOtp.value = newOtp;
                  await authController.sendOtpToEmail(authController.tempEmailOrPhone.value, newOtp);
                  Get.snackbar("OTP Sent", "A new OTP has been sent to your email.");
                },
                child: Text.rich(
                  TextSpan(
                    text: "Didn't receive code? ",
                    style: TextStyle(color: Colors.black),
                    children: [
                      TextSpan(
                        text: "Resend",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

}
