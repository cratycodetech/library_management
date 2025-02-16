import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:library_app/views/widgets/bottomNavigationBar_widget.dart';
import '../controllers/auth_controller.dart';
import '../routes/routes.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthController authController = Get.find();
  int _currentIndex = 0; // Default index for BottomNavBar

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
          if (authController.userModel.value != null) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundImage:
                  NetworkImage(authController.userModel.value!.photoURL),
                  radius: 40,
                ),
                SizedBox(height: 10),
                Text(authController.userModel.value!.name),
                Text(authController.userModel.value!.email),
                ElevatedButton(
                  onPressed: () {
                    Get.toNamed(AppRoutes.createGroup);
                  },
                  child: Text("Create Group"),
                ),
              ],
            );
          } else {
            return Text("No user logged in");
          }
        }),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

          if (index == 2) { // Group tab index
            Get.toNamed(AppRoutes.groupList);
          }
        },
      ),
    );
  }
}
