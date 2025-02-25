import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../group_chat_screen.dart';


class SelectChatScreen extends StatefulWidget {
  @override
  _SelectChatScreenState createState() => _SelectChatScreenState();
}

class _SelectChatScreenState extends State<SelectChatScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get forwarded message details from arguments
  final Map<String, dynamic>? forwardedMessage = Get.arguments;

  void _forwardMessage(String groupId, String groupName) async {
    if (forwardedMessage == null) {
      return; // No message to forward
    }

    String userId = _auth.currentUser!.uid;
    String userName = _auth.currentUser!.displayName ?? "Unknown User";

    // Construct message payload with "isForwarded" flag
    Map<String, dynamic> messageData = {
      "senderId": userId,
      "senderName": userName,
      "text": forwardedMessage?['text'] ?? '',
      "fileUrl": forwardedMessage?['fileUrl'],
      "fileName": forwardedMessage?['fileName'],
      "fileType": forwardedMessage?['fileType'],
      "isForwarded": true,
      "timestamp": FieldValue.serverTimestamp(),
    };

    // Save message to the selected group's Firestore collection
    await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .add(messageData);

    // Navigate to the selected group chat
    Get.to(() => GroupChatScreen(groupId: groupId, groupName: groupName));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Select Group Chat")),
      body: FutureBuilder<QuerySnapshot>(
        future: _firestore.collection('groups').get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No groups found"));
          }

          String userId = _auth.currentUser!.uid;
          var userGroups = snapshot.data!.docs.where((doc) {
            List<dynamic> members = doc['members'] ?? [];
            return members.contains(userId);
          }).toList();

          if (userGroups.isEmpty) {
            return Center(child: Text("You're not a member of any groups"));
          }

          return ListView.builder(
            itemCount: userGroups.length,
            itemBuilder: (context, index) {
              var group = userGroups[index];
              return ListTile(
                leading: CircleAvatar(
                  child: Icon(Icons.group),
                ),
                title: Text(group['name'] ?? 'Unknown Group'),
                subtitle: Text("Members: ${group['members'].length}"),
                onTap: () => _forwardMessage(group.id, group['name']),
              );
            },
          );
        },
      ),
    );
  }
}
