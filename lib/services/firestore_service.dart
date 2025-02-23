import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveFileMetadata(String groupId, String fileName, String fileType, String downloadUrl, String uploadedBy) async {
    await _firestore.collection('groups').doc(groupId).collection('files').add({
      'fileName': fileName,
      'fileType': fileType,
      'url': downloadUrl,
      'uploadedBy': uploadedBy,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
