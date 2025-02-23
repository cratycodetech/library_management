import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';
import 'package:library_app/views/widgets/video_message_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import '../routes/routes.dart';
import '../services/agora_service.dart';
import '../services/file_upload_service.dart';
import '../services/group_service.dart';
import '../views/group_call_screen.dart';
import 'group_documents_screen.dart';

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

  FilePickerResult? _selectedFile;

  @override
  void initState() {
    super.initState();
    _listenForActiveCall();
  }

  void _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null) {
      setState(() {
        _selectedFile = result;
      });
    }
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty && _selectedFile == null) return;

    String userId = _auth.currentUser!.uid;
    String userName = _auth.currentUser!.displayName ?? "Unknown User";
    String? fileUrl;

    if (_selectedFile != null) {
      fileUrl = await FileUploadService()
          .uploadFile(_selectedFile!.files.single.path!);
      if (fileUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("File upload failed!")),
        );
        return;
      }

      String fileName = _selectedFile!.files.single.name;
      String fileType = _selectedFile!.files.single.extension ?? 'unknown';

      await _groupService.sendMessage(
        widget.groupId,
        userId,
        userName,
        _messageController.text.trim(),
        fileUrl: fileUrl,
        fileName: fileName,
        fileType: fileType,
      );
    } else {
      await _groupService.sendMessage(
        widget.groupId,
        userId,
        userName,
        _messageController.text.trim(),
      );
    }

    _messageController.clear();
    setState(() {
      _selectedFile = null;
    });
  }

  void _startCall() async {
    DocumentReference groupRef =
        FirebaseFirestore.instance.collection('groups').doc(widget.groupId);

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

    Get.to(() =>
        GroupCallScreen(channelName: widget.groupId, token: activeToken!));
  }

  void _joinCall() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .get();

    if (snapshot.exists && snapshot['isCallActive'] == true) {
      String activeToken = snapshot['callToken'];
      print("🔹 Fetching token from Firestore: $activeToken");

      Get.to(() =>
          GroupCallScreen(channelName: widget.groupId, token: activeToken));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No active call found!")),
      );
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupName),
        actions: [
          IconButton(
            icon: Icon(Icons.description, color: Colors.blue),
            onPressed: () {
              Get.to(() => GroupDocumentsScreen(groupId: widget.groupId));
            },
          ),
          IconButton(
            icon: Icon(Icons.call, color: Colors.green),
            onPressed: _startCall,
          ),
          IconButton(
            icon: Icon(Icons.attach_file),
            onPressed: _pickFile,
          ),
        ],
      ),
      body: Column(
        children: [
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
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('groups')
                  .doc(widget.groupId)
                  .snapshots(),
              builder:
                  (context, AsyncSnapshot<DocumentSnapshot> groupSnapshot) {
                if (!groupSnapshot.hasData)
                  return Center(child: CircularProgressIndicator());

                return StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('groups')
                      .doc(widget.groupId)
                      .collection('messages')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder:
                      (context, AsyncSnapshot<QuerySnapshot> messageSnapshot) {
                    return StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('groups')
                          .doc(widget.groupId)
                          .collection('files')
                          .orderBy('timestamp', descending: true)
                          .snapshots(),
                      builder:
                          (context, AsyncSnapshot<QuerySnapshot> fileSnapshot) {
                        if (!messageSnapshot.hasData || !fileSnapshot.hasData) {
                          return Center(child: CircularProgressIndicator());
                        }

                        List<Map<String, dynamic>> combinedList = [];

                        messageSnapshot.data!.docs.forEach((doc) {
                          combinedList.add({'type': 'message', 'data': doc});
                        });

                        fileSnapshot.data!.docs.forEach((doc) {
                          combinedList.add({'type': 'file', 'data': doc});
                        });

                        combinedList.sort((a, b) {
                          Timestamp timeA = (a['data']['timestamp'] ??
                              Timestamp(0, 0)) as Timestamp;
                          Timestamp timeB = (b['data']['timestamp'] ??
                              Timestamp(0, 0)) as Timestamp;
                          return timeB.compareTo(timeA);
                        });

                        return ListView.builder(
                          reverse: true,
                          itemCount: combinedList.length,
                          itemBuilder: (context, index) {
                            var item = combinedList[index];

                            if (item['type'] == 'message') {
                              var message = item['data'];
                              bool isMe =
                                  message['senderId'] == _auth.currentUser!.uid;
                              String? text = message['text'];

                              return Align(
                                alignment: isMe
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 10),
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: isMe
                                        ? Colors.blueAccent
                                        : Colors.grey[300],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Sender name
                                      Text(
                                        message['senderName'] ?? 'Unknown',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: isMe
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 5),

                                      // If text is present, show text; otherwise assume it's a file
                                      if (text != null && text.isNotEmpty) ...[
                                        // Normal text message
                                        Text(
                                          text,
                                          style: TextStyle(
                                            color: isMe
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                      ] else ...[
                                        // Possibly a file message
                                        if ((message['fileType'] ?? '')
                                                .toLowerCase() ==
                                            'pdf')
                                          // Wrap PDF fileName in GestureDetector to open PDFViewer
                                          GestureDetector(
                                            onTap: () {
                                              Get.toNamed('/pdf-viewer',
                                                  arguments: {
                                                    'pdfUrl':
                                                        message['fileUrl'] ?? ''
                                                  });
                                            },
                                            child: Text(
                                              message['fileName'] ??
                                                  'Unknown File',
                                              style: TextStyle(
                                                color: isMe
                                                    ? Colors.white
                                                    : Colors.black,
                                                decoration:
                                                    TextDecoration.underline,
                                              ),
                                            ),
                                          )
                                        else if ((message['fileType'] ?? '').toLowerCase() == 'jpg' ||
                                            (message['fileType'] ?? '').toLowerCase() == 'jpeg' ||
                                            (message['fileType'] ?? '').toLowerCase() == 'png')
                                        // Wrap the image in a GestureDetector to handle taps
                                          GestureDetector(
                                            onTap: () {
                                              // Navigate to the photo download page with the image URL as an argument
                                              Get.toNamed(AppRoutes.photoDownload, arguments: {
                                                'photoUrl': message['fileUrl'] ?? '',
                                                // add more arguments if needed
                                              });
                                            },
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(10),
                                              child: SizedBox(
                                                width: 300,
                                                height: 300,
                                                child: Image.network(
                                                  message['fileUrl'] ?? '',
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) => Container(
                                                    color: isMe ? Colors.blueAccent : Colors.grey[300],
                                                    width: 300,
                                                    height: 300,
                                                    child: Center(
                                                      child: Text(
                                                        'Image could not be loaded',
                                                        style: TextStyle(
                                                          color: isMe ? Colors.white : Colors.black,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )

                                        else if ((message['fileType'] ?? '')
                                                .toLowerCase() ==
                                            'mp4')
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: InlineVideoPlayer(
                                              videoUrl:
                                                  message['fileUrl'] ?? '',
                                              thumbnailGenerator: _groupService
                                                  .generateThumbnail,
                                            ),
                                          )
                                        else
                                          // Other file types
                                          Text(
                                            message['fileName'] ??
                                                'Unknown File',
                                            style: TextStyle(
                                              color: isMe
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                          ),
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            } else {
                              var file = item['data'];
                              return ListTile(
                                title: Text(file['fileName']),
                                subtitle: Text(file['fileType']),
                                trailing: IconButton(
                                  icon: Icon(Icons.download),
                                  onPressed: () async {
                                    final url = file['url'];
                                    await launch(url);
                                  },
                                ),
                              );
                            }
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                // 🔹 Display selected file before sending
                if (_selectedFile != null)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.attach_file, color: Colors.blue),
                        SizedBox(width: 5),
                        Text(_selectedFile!.files.single.name,
                            overflow: TextOverflow.ellipsis),
                        SizedBox(width: 5),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedFile = null;
                            });
                          },
                          child: Icon(Icons.close, color: Colors.red, size: 18),
                        ),
                      ],
                    ),
                  ),
                SizedBox(width: 5),

                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20)),
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
