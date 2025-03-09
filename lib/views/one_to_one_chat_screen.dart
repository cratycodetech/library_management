import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:library_app/services/notification_remote_service.dart';

import '../services/agora_service.dart';
import 'one_to_one_call_screen.dart';

class ChatScreen extends StatefulWidget {
  final String receiverId;
  final String receiverName;
  final String receiverPhotoURL;

  const ChatScreen({
    Key? key,
    required this.receiverId,
    required this.receiverName,
    required this.receiverPhotoURL,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _messageController = TextEditingController();
  final AgoraService _agoraService = AgoraService();
  final NotificationRemoteService _notificationRemoteService =NotificationRemoteService();

  late String chatRoomId;
  late String senderId;
  Map<String, dynamic>? incomingCallData;

  @override
  void initState() {
    super.initState();
    senderId = _auth.currentUser!.uid;
    chatRoomId = _getChatRoomId(senderId, widget.receiverId);
    _listenForIncomingCall();
    _setUserActiveStatus(true);
  }

  @override
  void dispose() {
    _setUserActiveStatus(false);
    super.dispose();
  }



  String _getChatRoomId(String user1, String user2) {
    return user1.hashCode <= user2.hashCode
        ? '$user1\_$user2'
        : '$user2\_$user1';
  }


  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    await _firestore.collection('chats').doc(chatRoomId).collection('messages').add({
      'senderId': senderId,
      'receiverId': widget.receiverId,
      'text': _messageController.text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    });


    DocumentSnapshot senderDoc = await _firestore.collection('users').doc(senderId).get();
    String senderName = senderDoc.exists ? senderDoc.get('name') ?? 'Unknown' : 'Unknown';

    DocumentSnapshot chatDoc = await _firestore.collection('chats').doc(chatRoomId).get();
    if (chatDoc.exists) {
      Map<String, dynamic>? isActiveMap = chatDoc.get('isActive');
      bool isRecipientActive = isActiveMap?[widget.receiverId] ?? false;

      if (!isRecipientActive) {
        print("📢 User is inactive, sending push notification...");

        // Create an instance of NotificationRemoteService
        NotificationRemoteService notificationService = NotificationRemoteService();

        await notificationService.sendNotificationRequest(  // ✅ Use instance method
          userId: widget.receiverId,
          title: senderName,  // ✅ Use sender's name
          body: _messageController.text.trim(),
        );
      } else {
        print("✅ User is active, no need for a push notification.");
      }
    }

    _messageController.clear();
  }


  Future<void> _startCall() async {
    try {
      String callerId = _auth.currentUser!.uid;


      DocumentSnapshot userDoc = await _firestore.collection('users').doc(callerId).get();
      String callerName = userDoc.exists ? (userDoc['name'] ?? "Unknown") : "Unknown";

      String receiverId = widget.receiverId;
      String channelName = chatRoomId;



      String? token = await _agoraService.generateToken(channelName, 0);
      if (token == null) {
        print("❌ Failed to generate Agora token.");
        return;
      }


      Map<String, dynamic> callData = {
        'callerId': callerId,
        'callerName': callerName,
        'receiverId': receiverId,
        'receiverName': widget.receiverName,
        'channelName': channelName,
        'token': token,
        'status': 'ringing',
        'timestamp': FieldValue.serverTimestamp(),
      };

      print("📌 Storing call data in Firestore: $callData");

      await _firestore.collection('calls').doc(channelName).set(callData, SetOptions(merge: true));

      print("✅ Successfully stored call data in Firestore.");
      print("channel Name $channelName");
      // Navigate to Call Screen
      Get.to(() => CallScreen(channelName: channelName, token: token));
    } catch (e, stackTrace) {
      print("❌ Firestore write error: $e");
      print("📜 Stack Trace: $stackTrace");
    }
  }


  void _listenForIncomingCall() {
    _firestore.collection('calls').doc(chatRoomId).snapshots().listen((snapshot) {
      if (snapshot.exists) {
        Map<String, dynamic>? callData = snapshot.data();
        String callStatus = callData?['status'] ?? '';

        if (callStatus == 'ringing' || callStatus == 'accepted') {
          print("🔹 Incoming call detected: $callData");

          setState(() {
            incomingCallData = callData;
          });
        } else if (callStatus == 'ended') {
          print("🚨 Call ended, hiding UI...");
          setState(() {
            incomingCallData = null;
          });
        }
      } else {
        setState(() {
          incomingCallData = null;
        });
      }
    });
  }


  void _joinCall() async {
    if (incomingCallData == null) {
      print("❌ Error: No call data found.");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No active call found!")),
      );
      return;
    }

    String? channelName = incomingCallData?['channelName'];
    String? token = incomingCallData?['token'];

    if (channelName == null || token == null) {
      print("❌ Error: Call data is incomplete.");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Call data is incomplete!")),
      );
      return;
    }

    print("🔹 Fetching token from Firestore: $token");

    await _firestore.collection('calls').doc(channelName).update({
      'status': 'accepted',
      'receiverId': senderId,
    });

    setState(() {
      incomingCallData = null;
    });

    Get.to(() => CallScreen(
      channelName: channelName,
      token: token,
    ));
  }


  Future<void> _setUserActiveStatus(bool isActive) async {
    await _firestore.collection('chats').doc(chatRoomId).set({
      'isActive': {senderId: isActive},
    }, SetOptions(merge: true));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: widget.receiverPhotoURL.isNotEmpty
                  ? NetworkImage(widget.receiverPhotoURL)
                  : null,
              child: widget.receiverPhotoURL.isEmpty ? const Icon(Icons.person) : null,
            ),
            const SizedBox(width: 10),
            Text(widget.receiverName),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.call, color: Colors.green),
            onPressed: _startCall,
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('chats')
                      .doc(chatRoomId)
                      .collection('messages')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    var messages = snapshot.data!.docs;

                    return ListView.builder(
                      reverse: true,
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        var message = messages[index].data() as Map<String, dynamic>;
                        bool isMe = message['senderId'] == senderId;
                        return Align(
                          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isMe ? Colors.blueAccent : Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(message['text'] ?? ""),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: "Type a message...",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: _sendMessage,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
