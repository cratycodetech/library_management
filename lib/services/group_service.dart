import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get_thumbnail_video/index.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';


class GroupService extends GetxController{
  final CollectionReference groupsCollection =
  FirebaseFirestore.instance.collection('groups');
  List<DocumentSnapshot> messages = [];
  DocumentSnapshot? lastMessageDoc;
  bool hasMore = true;
  bool isLoadingMore = false;


  Future<bool> doesGroupExist(String groupName) async {
    QuerySnapshot query = await groupsCollection
        .where('name', isEqualTo: groupName)
        .limit(1)
        .get();
    return query.docs.isNotEmpty;
  }

  Future<String> createGroup(String groupName, String adminId, List<String> memberIds, {String type = 'private'}) async {
    try {
      bool exists = await doesGroupExist(groupName);
      if (exists) return "";

      DocumentReference docRef = await groupsCollection.add({
        'name': groupName,
        'adminId': adminId,
        'members': memberIds,
        'type': type, // ✅ added group type
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
        String? localPath,
      }) async {
    try {
      final String? photoURL = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get()
          .then((doc) => doc['photoURL']);

      DocumentSnapshot groupDoc = await groupsCollection.doc(groupId).get();
      List<dynamic> members = groupDoc['members'];

      Map<String, bool> unreadMap = {
        for (var member in members)
          if (member != userId) member: true
      };

      await groupsCollection.doc(groupId).collection('messages').add({
        'senderId': userId,
        'senderName': userName,
        'photoURL': await photoURL ?? '',
        'text': text.isNotEmpty ? text : null,
        'fileUrl': fileUrl,
        'fileName': fileName,
        'fileType': fileType,
        'localPaths': {userId: localPath},
        'groupId': groupId,
        'unread': unreadMap,
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



  Future<void> sendVoiceSMS(
      String groupId,
      String userId,
      String userName,
      String fileUrl,
      String fileName,
      ) async {
    try {
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      final String photoURL = userDoc.data() != null &&
          (userDoc.data() as Map<String, dynamic>).containsKey('photoURL')
          ? userDoc['photoURL']
          : '';

      DocumentSnapshot groupDoc = await groupsCollection.doc(groupId).get();
      List<dynamic> members = groupDoc['members'];

      Map<String, bool> unreadMap = {
        for (var member in members)
          if (member != userId) member: true
      };

      await groupsCollection.doc(groupId).collection('messages').add({
        'senderId': userId,
        'senderName': userName,
        'photoURL': photoURL,
        'fileUrl': fileUrl,
        'fileName': fileName,
        'fileType': 'm4a',
        'text': '',
        'groupId': groupId,
        'unread': unreadMap, // ✅ NEW
        'timestamp': FieldValue.serverTimestamp(),
      });


      print("✅ Voice SMS sent successfully");
    } catch (e) {
      print("❌ Error sending Voice SMS: $e");
    }
  }

  Future<void> loadMoreMessages(String groupId) async {
    if (!hasMore || isLoadingMore) return;
    isLoadingMore = true;

    Query query = FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(20);

    if (lastMessageDoc != null) {
      query = query.startAfterDocument(lastMessageDoc!);
    }

    final snapshot = await query.get();
    if (snapshot.docs.isNotEmpty) {
      messages.addAll(snapshot.docs);
      lastMessageDoc = snapshot.docs.last;
      update(); // GetBuilder will rebuild
    }

    if (snapshot.docs.length < 20) {
      hasMore = false;
    }

    isLoadingMore = false;
  }

  Stream<List<DocumentSnapshot>> streamMessages(String groupId) {
    return FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }



}
