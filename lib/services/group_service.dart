import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_thumbnail_video/index.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';


class GroupService {
  final CollectionReference groupsCollection =
  FirebaseFirestore.instance.collection('groups');


  Future<bool> doesGroupExist(String groupName) async {
    QuerySnapshot query = await groupsCollection
        .where('name', isEqualTo: groupName)
        .limit(1)
        .get();
    return query.docs.isNotEmpty;
  }

  Future<String> createGroup(String groupName, String adminId, List<String> memberIds) async {
    try {
      bool exists = await doesGroupExist(groupName);
      if (exists) return "";

      DocumentReference docRef = await groupsCollection.add({
        'name': groupName,
        'adminId': adminId,
        'members': memberIds,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    } catch (e) {
      print("Error creating group: $e");
      return "";
    }
  }


  Future<void> addUserToGroup(String groupId, String userId) async {
    await groupsCollection.doc(groupId).update({
      'members': FieldValue.arrayUnion([userId])
    });
  }


  Future<List<Map<String, dynamic>>> getAllUsers() async {
    QuerySnapshot querySnapshot =
    await FirebaseFirestore.instance.collection('users').get();
    return querySnapshot.docs
        .map((doc) => {"uid": doc.id, ...doc.data() as Map<String, dynamic>})
        .toList();
  }



  Future<void> sendMessage(
      String groupId,
      String userId,
      String userName,
      String text, {
        String? fileUrl,
        String? fileName,
        String? fileType,
      }) async {
    try {
      await groupsCollection.doc(groupId).collection('messages').add({
        'senderId': userId,
        'senderName': userName,
        'text': text.isNotEmpty ? text : null,
        'fileUrl': fileUrl,
        'fileName': fileName,
        'fileType': fileType,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error sending message: $e");
    }
  }


  // Fetch messages for a group (real-time updates)
  Stream<QuerySnapshot> getMessages(String groupId) {
    return groupsCollection
        .doc(groupId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> getUserGroups(String userId) {
    return groupsCollection.where('members', arrayContains: userId).snapshots();
  }

  Future<XFile?> generateThumbnail(String videoUrl) async {
    try {
      final Directory tempDir = await getTemporaryDirectory();
      return await VideoThumbnail.thumbnailFile(
        video: videoUrl,
        thumbnailPath: tempDir.path,
        imageFormat: ImageFormat.PNG,
        maxHeight: 300, // adjust as needed
        quality: 75, // adjust as needed
      );
    } catch (error) {
      print("Error generating thumbnail: $error");
      return null;
    }
  }


}
