// controllers/group_call_controller.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../services/agora_service.dart';
import '../../group_call_screen.dart';


class GroupCallController extends GetxController {
  final AgoraService _agoraService = AgoraService();
  final RxBool isCallActive = false.obs;
  final RxString callToken = ''.obs;
  User? get currentUser => FirebaseAuth.instance.currentUser;
  String get currentUserId => FirebaseAuth.instance.currentUser?.uid ?? '';

  void listenToCallStatus(String groupId) {
    FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        isCallActive.value = snapshot['isCallActive'] ?? false;
        callToken.value = snapshot['callToken'] ?? '';
      }
    });
  }

  void startCall(String groupId, {bool withVideo = true}) async {
    final docRef = FirebaseFirestore.instance.collection('groups').doc(groupId);
    final snapshot = await docRef.get();

    String? token = snapshot.data()?['callToken'];

    if (token == null || token.isEmpty) {
      token = await _agoraService.generateToken(groupId, 0);
      await docRef.set({
        'isCallActive': true,
        'callToken': token,
      }, SetOptions(merge: true));
    }


    Get.to(() => GroupCallScreen(channelName: groupId, token: token!, withVideo: withVideo));

  }

  void joinCall(String groupId) {
    if (callToken.isNotEmpty) {
      Get.toNamed('/group-call', arguments: {
        'channelName': groupId,
        'token': callToken.value,
      });
    } else {
      Get.snackbar("No Call", "No active call found");
    }
  }
}
