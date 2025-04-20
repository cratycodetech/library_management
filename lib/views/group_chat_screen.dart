import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:library_app/views/study_room/controllers/group_call_controller.dart';
import 'package:library_app/views/study_room/group_info_screen.dart';
import 'package:library_app/views/study_room/widgets/mini_share_button.dart';
import 'package:library_app/views/widgets/video_message_widget.dart';
import 'package:library_app/views/widgets/voice_message_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:record/record.dart';
import 'package:url_launcher/url_launcher.dart';
import '../routes/routes.dart';
import '../services/agora_service.dart';
import '../services/file_upload_service.dart';
import '../services/group_service.dart';
import '../views/group_call_screen.dart';
import 'group_documents_screen.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

class GroupChatScreen extends StatefulWidget {
  final String groupId;
  final String groupName;

  GroupChatScreen({required this.groupId, required this.groupName});

  @override
  _GroupChatScreenState createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final GroupService _groupService = Get.put(GroupService());
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AgoraService _agoraService = AgoraService();
  bool isCallActive = false;
  String? activeCallToken;
  final ScrollController _scrollController = ScrollController();
  FilePickerResult? _selectedFile;
  List<AssetEntity> mediaList = [];
  int currentPage = 0;
  bool isLoading = false;
  AssetEntity? _selectedAsset;
  String? _filePath;
  final _audioRecorder = AudioRecorder();
  bool isRecording = false;
  String? filePath;
  Timer? _recordingTimer;
  int _recordDuration = 0;
  final GroupCallController callController = Get.put(GroupCallController());
  int memberCount = 0;
  String? groupPhotoUrl;
  bool _showEmojiPicker = false;






  @override
  void initState() {
    super.initState();
    _listenForActiveCall();
    _fetchRecentMedia();
    _groupService.loadMoreMessages(widget.groupId);
    _scrollController.addListener(_loadMoreMedia);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 100) {
        _groupService.loadMoreMessages(widget.groupId);
      }
    });

    FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data()!;
        setState(() {
          memberCount = (data['members'] as List).length;
          groupPhotoUrl = data['groupPhotoUrl'];
        });
      }
    });

    _markAllUnreadMessagesAsRead();

  }

  Future<void> _markAllUnreadMessagesAsRead() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final query = await FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .get();

    for (var doc in query.docs) {
      final data = doc.data();
      final readBy = List<String>.from(data['readBy'] ?? []);
      if (!readBy.contains(userId)) {
        await doc.reference.update({
          'readBy': FieldValue.arrayUnion([userId]),
        });
      }
    }

  }


  Future<void> _toggleRecording() async {
    if (isRecording) {
      final path = await _audioRecorder.stop();
      _recordingTimer?.cancel();
      setState(() {
        isRecording = false;
        filePath = path;
        _recordDuration = 0;
      });
      print('🎤 Recording saved: $filePath');

      if (filePath != null) {
        File recordedFile = File(filePath!);

        String fileName =
            "${DateTime.now().millisecondsSinceEpoch}_${p.basename(filePath!)}";

        String? uploadedUrl =
            await FileUploadService().uploadRecordingToSupabase(recordedFile);

        if (uploadedUrl != null) {
          // Get current user ID and name
          String userId = _auth.currentUser!.uid;
          String userName = _auth.currentUser!.displayName ?? "Unknown User";

          // Send voice SMS using _groupService
          await _groupService.sendVoiceSMS(
              widget.groupId, userId, userName, uploadedUrl, fileName);
        }
      }
    } else {
      if (await _audioRecorder.hasPermission()) {
        final path = await _getFilePath();
        await _audioRecorder.start(RecordConfig(), path: path);
        setState(() {
          isRecording = true;
          filePath = path;
          _recordDuration = 0; // Reset timer
        });

        // Start recording timer
        _recordingTimer = Timer.periodic(Duration(seconds: 1), (timer) {
          setState(() {
            _recordDuration++;
          });
        });

        print('🎤 Recording started: $filePath');
      } else {
        print('🚫 No permission for recording');
      }
    }
  }

  String _formatDuration(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Future<String> _getFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/recorded_audio.m4a';
  }

  void _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      PlatformFile file = result.files.first;

      if (file.path != null) {
        File selectedFile = File(file.path!);
        print("✅ File selected: ${file.name}, Size: ${file.size} bytes");
        _selectedFile = result;
        _sendSelectedFile(selectedFile, file.name);
      } else {
        print("🚫 File path is null.");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to pick file!")),
        );
      }
    } else {
      print("🚫 No file selected.");
    }
  }

  void _forwardMessage(
      String fileUrl, String fileType, String fileName, String? text) {
    Get.toNamed('/select-chat', arguments: {
      'fileUrl': fileUrl,
      'fileType': fileType,
      'fileName': fileName,
      'text': text,
    });
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    String userId = _auth.currentUser!.uid;
    String userName = _auth.currentUser!.displayName ?? "Unknown User";

    await _groupService.sendMessage(
      widget.groupId,
      userId,
      userName,
      _messageController.text.trim(),
    );

    _messageController.clear();
    setState(() {
      _selectedFile = null;
    });
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

  Future<void> _shareDownloadedFile(
      String? fileUrl,
      Map<String, dynamic>? localPaths,
      String groupId,
      String userId,
      String userName,
      String messageId) async {
    try {
      File? file;
      if (localPaths != null && localPaths.containsKey(userId)) {
        String? localPath = localPaths[userId];

        if (localPath != null && localPath.isNotEmpty) {
          file = File(localPath);
          if (await file.exists()) {
            _shareFile(file);
            return;
          } else {
            if (fileUrl != null) {
              if (Platform.isAndroid && !(await _requestStoragePermission())) {
                return;
              }

              final response = await http.get(Uri.parse(fileUrl));
              if (response.statusCode == 200) {
                Uint8List fileData = response.bodyBytes;

                RegExp regex =
                    RegExp(r"/([^/]+\.(jpg|jpeg|png|gif|bmp|webp|mp4|avi))");
                Match? match = regex.firstMatch(fileUrl);
                String fileName =
                    match != null ? match.group(1)! : "downloaded_file";

                int androidVersion = await _androidVersion();
                if (androidVersion >= 29) {
                  final result = await ImageGallerySaverPlus.saveImage(fileData,
                      name: fileName);
                  if (result['isSuccess'] == true) {
                    _filePath = await _getRealPathFromUri(result['filePath']);
                    if (_filePath != null) {
                      File savedFile = File(_filePath!);
                      print("✅ File saved at: $_filePath");
                      await _updateLocalPathInFirestore(
                          groupId, messageId, userId, _filePath!);
                      _shareFile(savedFile);
                    }
                  } else {
                    print("❌ Failed to save file.");
                  }
                } else {
                  // Save manually in Downloads/Messenger (Android <10)
                  final directory =
                      Directory("/storage/emulated/0/Download/library");
                  if (!(await directory.exists())) {
                    await directory.create(recursive: true);
                  }

                  String filePath = "${directory.path}/$fileName";
                  File file = File(filePath);
                  await file.writeAsBytes(fileData);

                  if (await file.exists()) {
                    _filePath = filePath;
                    print("✅ File saved at: $_filePath");

                    await _updateLocalPathInFirestore(
                        groupId, messageId, userId, _filePath!);
                    _shareFile(file);
                  } else {
                    print("❌ Failed to save file.");
                  }
                }
              } else {
                print("❌ Failed to download file.");
              }
            } else {
              throw Exception("File unavailable for sharing!");
            }
          }
        }
      }

      if (fileUrl != null) {
        if (Platform.isAndroid && !(await _requestStoragePermission())) {
          return;
        }

        final response = await http.get(Uri.parse(fileUrl));
        if (response.statusCode == 200) {
          Uint8List fileData = response.bodyBytes;

          RegExp regex =
              RegExp(r"/([^/]+\.(jpg|jpeg|png|gif|bmp|webp|mp4|avi))");
          Match? match = regex.firstMatch(fileUrl);
          String fileName = match != null ? match.group(1)! : "downloaded_file";

          int androidVersion = await _androidVersion();
          if (androidVersion >= 29) {
            final result =
                await ImageGallerySaverPlus.saveImage(fileData, name: fileName);
            if (result['isSuccess'] == true) {
              _filePath = await _getRealPathFromUri(result['filePath']);
              if (_filePath != null) {
                File savedFile = File(_filePath!);
                print("✅ File saved at: $_filePath");
                await _updateLocalPathInFirestore(
                    groupId, messageId, userId, _filePath!);
                _shareFile(savedFile);
              }
            } else {
              print("❌ Failed to save file.");
            }
          } else {
            // Save manually in Downloads/Messenger (Android <10)
            final directory = Directory("/storage/emulated/0/Download/library");
            if (!(await directory.exists())) {
              await directory.create(recursive: true);
            }

            String filePath = "${directory.path}/$fileName";
            File file = File(filePath);
            await file.writeAsBytes(fileData);

            if (await file.exists()) {
              _filePath = filePath;
              print("✅ File saved at: $_filePath");

              await _updateLocalPathInFirestore(
                  groupId, messageId, userId, _filePath!);
              _shareFile(file);
            } else {
              print("❌ Failed to save file.");
            }
          }
        } else {
          print("❌ Failed to download file.");
        }
      } else {
        throw Exception("File unavailable for sharing!");
      }
    } catch (e) {
      print("❌ Error sharing file: $e");
    }
  }

  Future<void> _updateLocalPathInFirestore(
      String groupId, String messageId, String userId, String localPath) async {
    try {
      DocumentReference docRef = FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .collection('messages')
          .doc(messageId);

      DocumentSnapshot docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        Map<String, dynamic>? localPaths =
            docSnapshot['localPaths'] as Map<String, dynamic>?;

        if (localPaths != null && localPaths.containsKey(userId)) {
          print("🔄 User ID exists, updating path...");
          await docRef.update({
            'localPaths.$userId': localPath,
          });
        } else {
          print("🆕 User ID not found, adding new entry...");
          await docRef.set({
            'localPaths': {userId: localPath}
          }, SetOptions(merge: true));
        }

        print("✅ Firestore updated successfully.");
      } else {
        print("❌ Message document not found.");
      }
    } catch (e) {
      print("❌ Firestore Update Error: ${e.toString()}");
    }
  }

  Future<int> _androidVersion() async {
    final String version = await Platform.operatingSystemVersion;
    return int.tryParse(version.split(".")[0]) ?? 30; // Default to API 30+
  }

  Future<String?> _getRealPathFromUri(String uri) async {
    if (uri.startsWith("content://")) {
      try {
        const platform = MethodChannel('file_provider');
        final realPath =
            await platform.invokeMethod('getRealPath', {"uri": uri});
        return realPath;
      } catch (e) {
        print("❌ Error getting real path: $e");
        return null;
      }
    }
    return uri;
  }

  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      int androidVersion = await _androidVersion();
      if (androidVersion >= 30) {
        print(
            "✅ Android 11+ does NOT require storage permission for MediaStore.");
        return true;
      }
      if (await Permission.storage.request().isGranted) {
        print("✅ Storage permission granted.");
        return true;
      } else {
        print("❌ Storage permission denied.");

        return false;
      }
    }
    return true; // iOS does not need this permission
  }


  void markMessageAsRead(String groupId, String messageId, String userId) async {
    DocumentReference messageRef = FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .doc(messageId);

    await messageRef.update({
      'readBy': FieldValue.arrayUnion([userId]),
      'unread.$userId': FieldValue.delete(),
    });

  }
  Future<List<DocumentSnapshot>> getUnreadMessages(String groupId, String userId) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .where('readBy', arrayContains: userId)
        .get();

    return snapshot.docs;
  }

  void _markMessageAsRead(String messageId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final messageRef = FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .collection('messages')
        .doc(messageId);

    await messageRef.update({
      'readBy': FieldValue.arrayUnion([userId]),
      'unread.$userId': FieldValue.delete(),
    });

  }





  Future<void> sendMessage(
      String groupId, String userId, String userName, String text,
      {String? fileUrl,
      String? fileName,
      String? fileType,
      String? localPath}) async {
    try {
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .collection('messages')
          .add({
        'senderId': userId,
        'senderName': userName,
        'fileUrl': fileUrl,
        'fileName': fileName,
        'fileType': fileType,
        'localPath': localPath,
        'timestamp': FieldValue.serverTimestamp(),
        'readBy': [userId], // ✅ sender has read it
      });

    } catch (e) {
      print("Error sending message: $e");
    }
  }

  void _shareFile(File file) {
    Share.shareXFiles([XFile(file.path)],
        text: "Here is the file you requested.");
  }

  void _showMediaOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.insert_drive_file, color: Colors.blue),
              title: Text("File"),
              onTap: () {
                Navigator.pop(context);
                _pickFile(); // Call function to pick a file
              },
            ),
            ListTile(
              leading: Icon(Icons.image, color: Colors.green),
              title: Text("Photos & Videos"),
              onTap: () {
                Navigator.pop(context);
                _showMediaBottomSheet(); // Call function to show media picker
              },
            ),
          ],
        );
      },
    );
  }

  void _showMediaBottomSheet() async {
    if (mediaList.isEmpty) {
      await _fetchRecentMedia();
    }
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          // Allows UI updates inside BottomSheet
          builder: (context, setSheetState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: GridView.builder(
                    controller: _scrollController,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                    ),
                    itemCount: mediaList.length,
                    itemBuilder: (context, index) {
                      final asset = mediaList[index];

                      return FutureBuilder<Uint8List?>(
                        future: asset.thumbnailData,
                        builder: (context, thumbSnapshot) {
                          if (thumbSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (thumbSnapshot.hasError ||
                              thumbSnapshot.data == null) {
                            return Container(color: Colors.grey);
                          }

                          final isSelected =
                              _selectedAsset == asset; // Check selection

                          return GestureDetector(
                            onTap: () {
                              setSheetState(() {
                                _selectedAsset = asset; // Store selected media
                              });
                            },
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Positioned.fill(
                                  child: Image.memory(thumbSnapshot.data!,
                                      fit: BoxFit.cover),
                                ),
                                // Show play icon if the media is a video
                                if (asset.type == AssetType.video)
                                  Positioned(
                                    child: Icon(Icons.play_circle_fill,
                                        color: Colors.white, size: 50),
                                  ),
                                // Show selection overlay
                                if (isSelected)
                                  Positioned.fill(
                                    child: Container(
                                      color: Colors.black.withOpacity(0.5),
                                      child: const Center(
                                        child: Icon(Icons.check_circle,
                                            color: Colors.white, size: 30),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                if (_selectedAsset != null)
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _sendSelectedMedia();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 15),
                          textStyle: TextStyle(fontSize: 18),
                        ),
                        child: Text("Send"),
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  void _sendSelectedMedia() async {
    if (_selectedAsset == null) return;

    File? file = await _selectedAsset!.file;
    if (file == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load file!")),
      );
      return;
    }

    String userId = _auth.currentUser!.uid;
    String userName = _auth.currentUser!.displayName ?? "Unknown User";
    String localFilePath = file.path;
    String fileType = p.extension(file.path).replaceFirst('.', '').toLowerCase();
    String fileName = p.basename(file.path);

    // Step 1: Create Firestore doc with sending: true
    DocumentReference docRef = FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .collection('messages')
        .doc();

    await docRef.set({
      'senderId': userId,
      'senderName': userName,
      'fileType': fileType,
      'fileName': fileName,
      'localPath': localFilePath,
      'timestamp': FieldValue.serverTimestamp(),
      'sending': true,
      'readBy': [userId],
    });

    // Step 2: Upload file
    String? fileUrl = await FileUploadService().uploadFile(userId, file);

    // Step 3: Update Firestore with final URL and sending: false
    if (fileUrl != null) {
      await docRef.update({
        'fileUrl': fileUrl,
        'sending': false,
      });
    } else {
      await docRef.update({
        'sending': false,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Upload failed!")),
      );
    }

    setState(() {
      _selectedAsset = null;
    });

    print("✅ Media sent: $fileUrl (Local Path: $localFilePath)");
  }


  void _sendSelectedFile(File file, String fileName) async {
    String userId = _auth.currentUser!.uid;
    String userName = _auth.currentUser!.displayName ?? "Unknown User";

    String? fileUrl = await FileUploadService().uploadFile(userId, file);
    if (fileUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("File upload failed!")),
      );
      return;
    }

    String fileType =
        p.extension(file.path).replaceFirst('.', '').toLowerCase();

    await _groupService.sendMessage(
      widget.groupId,
      userId,
      userName,
      "",
      fileUrl: fileUrl,
      fileName: fileName,
      fileType: fileType,
    );

    setState(() {
      _selectedFile = null;
    });

    print("✅ File sent: $fileUrl");
  }

  Future<void> _fetchRecentMedia() async {
    if (isLoading) return;
    isLoading = true;

    final PermissionState permission =
        await PhotoManager.requestPermissionExtend();

    if (permission.isAuth) {
      final List<AssetPathEntity> albums =
          await PhotoManager.getAssetPathList(type: RequestType.common);
      if (albums.isNotEmpty) {
        final int totalAssets = await albums.first.assetCountAsync;
        final List<AssetEntity> newMedia = await albums.first
            .getAssetListPaged(page: currentPage, size: totalAssets);
        if (newMedia.isNotEmpty) {
          setState(() {
            mediaList.addAll(newMedia);
            currentPage++;
          });
        }
      }
    } else {
      if (kDebugMode) {
        print("❌ Permission denied for accessing media!");
      }
    }

    isLoading = false;
  }

  void _loadMoreMedia() {
    if (!isLoading &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100) {
      _fetchRecentMedia();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80.h),
        child: Container(
          color: Colors.black,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          child: SafeArea(
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Get.back(),
                  child: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                SizedBox(width: 8.w),
                CircleAvatar(
                  radius: 20.r,
                  backgroundColor: Colors.white,
                  backgroundImage: (groupPhotoUrl != null && groupPhotoUrl!.isNotEmpty)
                      ? NetworkImage(groupPhotoUrl!)
                      : null,
                  child: (groupPhotoUrl == null || groupPhotoUrl!.isEmpty)
                      ? Icon(Icons.group, color: Colors.black)
                      : null,
                ),
                SizedBox(width: 8.w),


                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(widget.groupName,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp)),
                      Text('$memberCount members',
                          style: TextStyle(color: Colors.white70, fontSize: 12.sp)),
                    ],
                  ),
                ),

                /// Wrap icons tightly
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.videocam, color: Colors.white),
                      onPressed: () => callController.startCall(widget.groupId, withVideo: true),
                    ),
                    SizedBox(width: 4.w),
                    IconButton(
                      icon: const Icon(Icons.call, color: Colors.white),
                      onPressed: () => callController.startCall(widget.groupId, withVideo: false),
                    ),

                    SizedBox(width: 4.w),
                    IconButton(
                      icon: const Icon(Icons.description, color: Colors.white),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        Get.to(() => GroupDocumentsScreen(groupId: widget.groupId));
                      },
                    ),
                    SizedBox(width: 4.w),
                    IconButton(
                      icon: const Icon(Icons.info_outline, color: Colors.white),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        Get.toNamed(AppRoutes.groupInfoScreen, arguments: {
                          "groupId": widget.groupId,
                        });

                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
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
            child: StreamBuilder<List<DocumentSnapshot>>(
              stream: _groupService.streamMessages(widget.groupId),
              builder: (context, snapshot) {
                final liveMessages = snapshot.data ?? [];
                final allMessages = [...liveMessages, ..._groupService.messages];

                if (allMessages.isEmpty && _groupService.isLoadingMore) {
                  return const Center(child: CircularProgressIndicator());
                }

                return NotificationListener<ScrollNotification>(
                  onNotification: (scrollInfo) {
                    if (scrollInfo.metrics.pixels >=
                        scrollInfo.metrics.maxScrollExtent - 100) {
                      _groupService.loadMoreMessages(widget.groupId);
                    }
                    return false;
                  },
                  child: ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    itemCount: allMessages.length + (_groupService.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == allMessages.length) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final doc = allMessages[index];
                      final message = doc.data() as Map<String, dynamic>;
                      message['id'] = doc.id;

                      final isMe = message['senderId'] == _auth.currentUser?.uid;
                      final text = message['text'];
                      final messageId = doc.id;
                      if (!isMe) {
                        _markMessageAsRead(messageId);
                      }


                      return Padding(
                        padding: EdgeInsets.only(
                          left: isMe ? 50 : 8,
                          right: isMe ? 8 : 50,
                          top: 6,
                        ),
                        child: Row(
                          mainAxisAlignment:
                          isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!isMe)
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0, left: 8),
                                child: CircleAvatar(
                                  radius: 18,
                                  backgroundImage: (message['photoURL'] != null &&
                                      message['photoURL'].toString().isNotEmpty)
                                      ? NetworkImage(message['photoURL'])
                                      : const AssetImage('assets/images/default_user.png')
                                  as ImageProvider,
                                ),
                              ),
                            Flexible(
                              child: Column(
                                crossAxisAlignment: isMe
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  if (!isMe)
                                    Padding(
                                      padding:
                                      const EdgeInsets.only(left: 8.0, bottom: 2),
                                      child: Text(
                                        message['senderName'] ?? 'Unknown',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 13,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ),
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 5, horizontal: 4),
                                    padding: (text != null && text.isNotEmpty)
                                        ? const EdgeInsets.all(10)
                                        : EdgeInsets.zero,
                                    decoration: (text != null && text.isNotEmpty)
                                        ? BoxDecoration(
                                      color:
                                      isMe ? Colors.blueAccent : Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    )
                                        : const BoxDecoration(),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (text != null && text.isNotEmpty)
                                          Text(
                                            text,
                                            style: TextStyle(
                                              color:
                                              isMe ? Colors.white : Colors.black,
                                            ),
                                          )
                                        else
                                          _buildMediaWidget(message, isMe),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),


          // Padding(
          //   padding: EdgeInsets.all(8.0),
          //   child: Row(
          //     children: [
          //       // 🔹 Display selected file before sending
          //       IconButton(
          //         icon: Icon(Icons.attach_file),
          //         onPressed: _showMediaOptions,
          //       ),
          //       IconButton(
          //         icon: Icon(isRecording ? Icons.stop : Icons.mic),
          //         color: isRecording ? Colors.red : null,
          //         onPressed: _toggleRecording,
          //       ),
          //       if (isRecording) // Show time when recording
          //         Text(
          //           _formatDuration(_recordDuration),
          //           style: TextStyle(
          //               fontSize: 16,
          //               fontWeight: FontWeight.bold,
          //               color: Colors.red),
          //         ),
          //       SizedBox(
          //         width: 8,
          //       ),
          //       Expanded(
          //         child: TextField(
          //           controller: _messageController,
          //           decoration: InputDecoration(
          //             hintText: "Type a message...",
          //             border: OutlineInputBorder(
          //                 borderRadius: BorderRadius.circular(20)),
          //             contentPadding: EdgeInsets.symmetric(horizontal: 16),
          //           ),
          //         ),
          //       ),
          //
          //       IconButton(
          //         icon: Icon(Icons.send, color: Colors.blue),
          //         onPressed: _sendMessage,
          //       ),
          //     ],
          //   ),
          // ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Type your message...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 8.h),
                  ),
                  style: TextStyle(fontSize: 14.sp),
                ),
                Divider(height: 1.h, thickness: 1.h),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    GestureDetector(
                      onTap: _showMediaOptions,
                      child: Icon(Icons.add_circle_outline,
                          color: Colors.grey.shade600, size: 22.sp),
                    ),
                    SizedBox(width: 16.w),
                    GestureDetector(
                      onTap: _toggleRecording,
                      child: Icon(
                        isRecording ? Icons.stop : Icons.mic_none,
                        color: isRecording ? Colors.red : Colors.grey.shade600,
                        size: 22.sp,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    GestureDetector(
                      onTap: () {
                        FocusScope.of(context).unfocus(); // Hide keyboard
                        setState(() {
                          _showEmojiPicker = !_showEmojiPicker;
                        });
                      },
                      child: Icon(Icons.emoji_emotions_outlined,
                          color: Colors.grey.shade600, size: 22.sp),
                    ),
                    SizedBox(width: 16.w),
                    Icon(Icons.attach_file, color: Colors.grey.shade600, size: 22.sp),
                    SizedBox(width: 16.w),
                    Icon(Icons.auto_awesome, color: Colors.grey.shade600, size: 22.sp),
                    Spacer(),
                    GestureDetector(
                      onTap: _sendMessage,
                      child: CircleAvatar(
                        backgroundColor: Colors.black,
                        radius: 20.r,
                        child: Icon(Icons.send, color: Colors.white, size: 20.sp),
                      ),
                    ),
                  ],

                ),
                // if (_showEmojiPicker)
                //   SizedBox(
                //     height: 250.h,
                //     child: EmojiPicker(
                //       onEmojiSelected: (category, emoji) {
                //         _messageController.text += emoji.emoji;
                //       },
                //       config: Config(
                //         columns: 7,
                //         emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                //         verticalSpacing: 0,
                //         horizontalSpacing: 0,
                //         bgColor: Colors.white,
                //         indicatorColor: Colors.black,
                //         iconColor: Colors.grey,
                //         iconColorSelected: Colors.black,
                //         backspaceColor: Colors.red,
                //         recentsLimit: 28,
                //         noRecents: const Text('No Recents'),
                //         tabIndicatorAnimDuration: kTabScrollDuration,
                //         categoryIcons: const CategoryIcons(),
                //         buttonMode: ButtonMode.MATERIAL,
                //       ),
                //     ),
                //   ),


              ],
            ),
          )

        ],

      ),

    );
  }
  Widget _buildMediaWidget(Map<String, dynamic> message, bool isMe) {
    final fileType = (message['fileType'] ?? '').toLowerCase();
    final isSending = message['sending'] == true;


    if (fileType == 'm4a') {
      return Row(
        children: [
          if (isMe)
            ShareButton(onPressed: () => _forwardMessage(
                message['fileUrl'], fileType, message['fileName'], message['text'])),
          Expanded(child: VoiceMessageWidget(fileUrl: message['fileUrl'], isMe: isMe)),
          if (!isMe)
            ShareButton(onPressed: () => _forwardMessage(
                message['fileUrl'], fileType, message['fileName'], message['text'])),
        ],
      );
    }

    if (fileType == 'pdf') {
      return Row(
        children: [
          if (isMe)
            ShareButton(onPressed: () => _forwardMessage(
                message['fileUrl'], fileType, message['fileName'], message['text'])),
          Expanded(
            child: GestureDetector(
              onTap: () => Get.toNamed('/pdf-viewer', arguments: {'pdfUrl': message['fileUrl'] ?? ''}),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                decoration: BoxDecoration(
                  color: isMe ? Colors.blueAccent : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.picture_as_pdf, color: isMe ? Colors.white : Colors.red, size: 18),
                    SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        message['fileName'] ?? 'Unknown File',
                        style: TextStyle(
                          color: isMe ? Colors.white : Colors.black,
                          decoration: TextDecoration.underline,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (!isMe)
            ShareButton(onPressed: () => _forwardMessage(
                message['fileUrl'], fileType, message['fileName'], message['text'])),
        ],
      );
    }

    if (['jpg', 'jpeg', 'png'].contains(fileType)) {
      return Row(
        children: [
          if (isMe)
            ShareButton(onPressed: () => _forwardMessage(
                message['fileUrl'], fileType, message['fileName'], message['text'])),
          Expanded(
            child: GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.photoDownload, arguments: {
                'photoUrl': message['fileUrl'] ?? '',
              }),
              child: Column(
                crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: message['fileUrl'] == null && message['localPath'] != null
                        ? Image.file(
                      File(message['localPath']),
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 150,
                        height: 150,
                        color: Colors.grey[300],
                        child: Center(child: Text("Failed to load image")),
                      ),
                    )
                        : Image.network(
                      message['fileUrl'] ?? '',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 150,
                        height: 150,
                        color: Colors.grey[300],
                        child: Center(child: Text("Failed to load image")),
                      ),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    message['sending'] == true ? "Sending..." : "Sent",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),


          if (!isMe)
            ShareButton(onPressed: () => _forwardMessage(
                message['fileUrl'], fileType, message['fileName'], message['text'])),
        ],
      );
    }

    if (fileType == 'mp4') {
      return Row(
        children: [
          if (isMe)
            ShareButton(onPressed: () => _forwardMessage(
                message['fileUrl'], fileType, message['fileName'], message['text'])),
          Expanded(
            child: Column(
              crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                isSending
                    ? Container(
                  height: 300,
                  width: 250,
                  child: VideoMessageWidget(
                    videoFile: File(message['localPath']),
                    isLocal: true,
                  ),
                )
                    : FutureBuilder<XFile?>(
                  future: _groupService.generateThumbnail(message['fileUrl'] ?? ''),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Container(height: 300, color: Colors.grey[300]);
                    }
                    return GestureDetector(
                      onTap: () => Get.toNamed(AppRoutes.videoDownload, arguments: {
                        'videoUrl': message['fileUrl'],
                        'thumbnailGenerator': _groupService.generateThumbnail,
                        'senderName': message['senderName'],
                      }),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              File(snapshot.data!.path),
                              width: 250,
                              height: 300,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const Icon(Icons.play_circle_outline,
                              size: 50, color: Colors.white),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 4),
                Text(
                  isSending ? "Sending..." : "Sent",
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          if (!isMe)
            ShareButton(onPressed: () => _forwardMessage(
                message['fileUrl'], fileType, message['fileName'], message['text'])),
        ],
      );
    }




    // Default file type
    return Row(
      children: [
        if (isMe)
          ShareButton(onPressed: () => _forwardMessage(
              message['fileUrl'], fileType, message['fileName'], message['text'])),
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Text(
                  message['fileName'] ?? 'Unknown File',
                  style: TextStyle(color: isMe ? Colors.white : Colors.black),
                ),
              ),
              IconButton(
                icon: Icon(Icons.arrow_upward),
                onPressed: () => _forwardMessage(
                    message['fileUrl'], fileType, message['fileName'], message['text']),
              ),
              IconButton(
                icon: Icon(Icons.share),
                onPressed: () {
                  final currentUserId = FirebaseAuth.instance.currentUser?.uid;
                  if (currentUserId != null) {
                    _shareDownloadedFile(
                      message['fileUrl'], message['localPaths'], message['groupId'],
                      currentUserId, message['senderName'], message['id'],
                    );
                  }
                },
              ),
            ],
          ),
        ),
        if (!isMe)
          ShareButton(onPressed: () => _forwardMessage(
              message['fileUrl'], fileType, message['fileName'], message['text'])),
      ],
    );
  }

}



