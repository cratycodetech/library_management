import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'one_to_one_chat_screen.dart'; // Import the chat screen

class AllPeopleScreen extends StatelessWidget {
  const AllPeopleScreen({Key? key}) : super(key: key);

  Future<List<Map<String, dynamic>>> fetchUsers() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('users').get();
    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("All People")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No users found"));
          }

          List<Map<String, dynamic>> users = snapshot.data!;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              var user = users[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: user['photoURL'] != null && user['photoURL'].isNotEmpty
                      ? NetworkImage(user['photoURL'])
                      : null,
                  child: user['photoURL'] == null || user['photoURL'].isEmpty
                      ? const Icon(Icons.person)
                      : null,
                ),
                title: Text(user['name'] ?? "Unknown"),
                subtitle: Text(user['email'] ?? "No Email"),
                onTap: () {
                  Get.to(() => ChatScreen(
                    receiverId: user['uid'],
                    receiverName: user['name'] ?? "Unknown",
                    receiverPhotoURL: user['photoURL'] ?? "",
                  ));
                },
              );
            },
          );
        },
      ),
    );
  }
}
