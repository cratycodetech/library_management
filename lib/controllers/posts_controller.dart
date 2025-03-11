import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import '../models/post_model.dart';

class PostsController extends GetxController {
  RxList<PostModel> posts = <PostModel>[].obs;
  var filteredPosts = <PostModel>[].obs;
  RxBool isLoading = true.obs;
  RxString selectedFileType = "all".obs;
  RxString searchQuery = "".obs;
  Dio dio = Dio();

  // ✅ Fix: Ensure Key & IV are consistent
  final encrypt.Key encryptionKey = encrypt.Key.fromUtf8('12345678901234567890123456789012'); // 32-byte AES key
  final encrypt.IV iv = encrypt.IV.fromUtf8('1234567890123456'); // 16-byte IV

  @override
  void onInit() {
    super.onInit();
    fetchPosts();
  }

  void fetchPosts() async {
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection("uploads")
          .orderBy("uploadedAt", descending: true)
          .get();

      posts.value = snapshot.docs.map((doc) {
        var data = doc.data();
        return PostModel.fromMap(data, doc.id);
      }).toList();

      // ✅ Fix: Ensure filteredPosts is updated
      filteredPosts.value = posts;
    } catch (e) {
      Get.snackbar("Error", "Failed to load posts");
    } finally {
      isLoading.value = false;
    }
  }


  void filterPosts(String query) {
    if (query.isEmpty) {
      filteredPosts.value = List.from(posts); // ✅ Ensure UI updates properly
    } else {
      filteredPosts.value = posts
          .where((post) =>
          post.fileName.toLowerCase().contains(query.toLowerCase()))
          .toList(); // ✅ Convert to List
    }
  }

  void filterByFileType(String fileType) {
    selectedFileType.value = fileType;
    applyFilters(); // ✅ Apply both filters
  }

  void applyFilters() {
    filteredPosts.value = posts.where((post) {
      bool matchesQuery = searchQuery.value.isEmpty ||
          post.fileName.toLowerCase().contains(searchQuery.value.toLowerCase());

      bool matchesFileType = selectedFileType.value == "all" ||
          post.fileType == selectedFileType.value;

      return matchesQuery && matchesFileType;
    }).toList();
  }

  Future<void> downloadAndEncryptFile(PostModel post) async {
    try {
      Get.snackbar("Downloading", "Starting download for ${post.fileName}...");

      Directory appDir = await getApplicationDocumentsDirectory();
      String filePath = "${appDir.path}/${post.fileName}";

      // ✅ Step 1: Download file
      await dio.download(post.fileUrl, filePath);

      // ✅ Step 2: Encrypt file with PKCS7 Padding
      File downloadedFile = File(filePath);
      List<int> fileBytes = await downloadedFile.readAsBytes();

      final encrypter = encrypt.Encrypter(
        encrypt.AES(encryptionKey, mode: encrypt.AESMode.cbc, padding: "PKCS7"),
      );

      final encrypted = encrypter.encryptBytes(fileBytes, iv: iv);
      await downloadedFile.writeAsBytes(encrypted.bytes);

      // ✅ Step 3: Update Firestore with local path using `post.uploadId`
      await FirebaseFirestore.instance.collection('uploads').doc(post.uploadId).update({
        'localPath': filePath,
      });

      Get.snackbar("Success", "File encrypted and saved in app storage!");
    } catch (e) {
      Get.snackbar("Error", "Failed to download or encrypt file. ${e.toString()}");
      print("❌ Encryption Error: $e");
    }
  }


}
