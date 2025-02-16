import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../controllers/auth_controller.dart';
import '../routes/routes.dart';

class GroupListScreen extends StatelessWidget {
  final AuthController authController = Get.find();

  @override
  Widget build(BuildContext context) {
    String userId = authController.userModel.value?.uid ?? "";

    return Scaffold(
      appBar: AppBar(title: Text("Your Groups")),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('groups')
            .where('members', arrayContains: userId)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No groups found"));
          }

          var groups = snapshot.data!.docs;

          return ListView.builder(
            itemCount: groups.length,
            itemBuilder: (context, index) {
              var group = groups[index];
              return ListTile(
                title: Text(group['name']),
                subtitle: Text("Group ID: ${group.id}"),
                onTap: () {
                  Get.toNamed(AppRoutes.groupChat, arguments: {
                    "groupId": group.id,
                    "groupName": group['name'],
                  });
                },
              );
            },
          );
        },
      ),
    );
  }
}
