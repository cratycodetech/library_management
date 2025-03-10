class PostModel {
  final String uploadId;  // ✅ Firestore Document ID
  final String fileName;
  final String fileUrl;
  final String fileType;
  final bool isPremium;
  final String userId;
  final String username;

  PostModel({
    required this.uploadId, // 🔹 Firestore document ID
    required this.fileName,
    required this.fileUrl,
    required this.fileType,
    required this.isPremium,
    required this.userId,
    required this.username,
  });

  factory PostModel.fromMap(Map<String, dynamic> map, String docId) {
    return PostModel(
      uploadId: docId,  // ✅ Set Firestore document ID (uploads ID)
      fileName: map['fileName'] ?? '',
      fileUrl: map['fileUrl'] ?? '',
      fileType: map['fileType'] ?? '',
      isPremium: map['isPremium'] ?? false,
      userId: map['userId'] ?? '',
      username: map['username'] ?? '',
    );
  }
}
