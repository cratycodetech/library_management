import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/agora_service.dart';
import '../services/group_service.dart';
import '../views/group_call_screen.dart';

class GroupChatScreen extends StatefulWidget {
  final String groupId;
  final String groupName;

  GroupChatScreen({required this.groupId, required this.groupName});

  @override
  _GroupChatScreenState createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final GroupService _groupService = GroupService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AgoraService _agoraService = AgoraService();
  bool isCallActive = false;
  String? activeCallToken;

  @override
  void initState() {
    super.initState();
    _listenForActiveCall();
  }

  /// 🔴 Listen for active call status in Firestore
  void _listenForActiveCall() {
    FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        setState(() {
          isCallActive = snapshot.data()?['isCallActive'] ?? false;
          activeCallToken = snapshot.data()?['callToken'];
        });
      }
    });
  }

  void _startCall() async {
    DocumentReference groupRef = FirebaseFirestore.instance.collection('groups').doc(widget.groupId);

    DocumentSnapshot snapshot = await groupRef.get();
    String? activeToken = snapshot.exists ? snapshot['callToken'] : null;

    if (activeToken == null) {
      activeToken = await _agoraService.generateToken(widget.groupId, 0);
      print("🔹 Generating new Agora token: $activeToken");

      await groupRef.set({
        'isCallActive': true,
        'callToken': activeToken,
      }, SetOptions(merge: true));
    } else {
      print("🔹 Reusing existing token from Firestore: $activeToken");
    }

    Get.to(() => GroupCallScreen(channelName: widget.groupId, token: activeToken!));
  }




  void _joinCall() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .get();

    if (snapshot.exists && snapshot['isCallActive'] == true) {
      String activeToken = snapshot['callToken']; // ✅ Always use stored token
      print("🔹 Fetching token from Firestore: $activeToken");

      // Navigate to GroupCallScreen with the same token for all users
      Get.to(() => GroupCallScreen(channelName: widget.groupId, token: activeToken));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No active call found!")),
      );
    }
  }




  /// 📝 Send message
  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;


    String userId = _auth.currentUser!.uid;
    String userName = _auth.currentUser!.displayName ?? "Unknown User";

    await _groupService.sendMessage(widget.groupId, userId, userName, _messageController.text.trim());

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupName),
        actions: [
          IconButton(
            icon: Icon(Icons.call, color: Colors.white),
            onPressed: _startCall,
          ),
        ],
      ),
      body: Column(
        children: [
          // 🔔 Show Join Call Button if a call is active
          if (isCallActive)
            Container(
              color: Colors.green[100],
              padding: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.call, color: Colors.green),
                  SizedBox(width: 10),
                  Text("A call is in progress"),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _joinCall,
                    child: Text("Join Call"),
                  ),
                ],
              ),
            ),

          // 📩 Message List
          Expanded(
            child: StreamBuilder(
              stream: _groupService.getMessages(widget.groupId),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                return ListView.builder(
                  reverse: true,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var message = snapshot.data!.docs[index];
                    bool isMe = message['senderId'] == _auth.currentUser!.uid;

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blueAccent : Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              message['senderName'],
                              style: TextStyle(fontWeight: FontWeight.bold, color: isMe ? Colors.white : Colors.black),
                            ),
                            SizedBox(height: 5),
                            Text(
                              message['text'],
                              style: TextStyle(color: isMe ? Colors.white : Colors.black),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // ✏️ Message Input Box
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blue),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
