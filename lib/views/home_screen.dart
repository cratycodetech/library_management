import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class HomeScreen extends StatelessWidget {
  final AuthController authController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              authController.signOut();
            },
          )
        ],
      ),
      body: Center(
        child: Obx(() {
          if (authController.firebaseUser.value != null) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(authController.firebaseUser.value!.photoURL ?? ""),
                  radius: 40,
                ),
                SizedBox(height: 10),
                Text(authController.firebaseUser.value!.displayName ?? ""),
                Text(authController.firebaseUser.value!.email ?? ""),
              ],
            );
          } else {
            return Text("No user logged in");
          }
        }),
      ),
    );
  }
}
