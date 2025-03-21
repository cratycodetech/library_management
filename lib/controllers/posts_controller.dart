import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import '../models/post_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PostsController extends GetxController {
  RxList<PostModel> posts = <PostModel>[].obs;
  var filteredPosts = <PostModel>[].obs;
  RxBool isLoading = true.obs;
  RxString selectedFileType = "all".obs;
  RxString searchQuery = "".obs;
  Dio dio = Dio();


  final encryptionKey = encrypt.Key.fromUtf8(dotenv.env['ENCRYPTION_KEY'] ?? '');
  final iv = encrypt.IV.fromUtf8(dotenv.env['ENCRYPTION_IV'] ?? '');


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
      filteredPosts.value = List.from(posts);
    } else {
      filteredPosts.value = posts
          .where((post) =>
          post.fileName.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  void filterByFileType(String fileType) {
    selectedFileType.value = fileType;
    applyFilters();
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


      await dio.download(post.fileUrl, filePath);


      File downloadedFile = File(filePath);
      List<int> fileBytes = await downloadedFile.readAsBytes();

      final encrypter = encrypt.Encrypter(
        encrypt.AES(encryptionKey, mode: encrypt.AESMode.cbc, padding: "PKCS7"),
      );

      final encrypted = encrypter.encryptBytes(fileBytes, iv: iv);
      await downloadedFile.writeAsBytes(encrypted.bytes);


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
