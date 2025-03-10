import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:open_filex/open_filex.dart'; // ✅ Added package to open files
import '../models/post_model.dart';

class PostDetailScreen extends StatelessWidget {
  final PostModel post;

  PostDetailScreen({Key? key, required this.post}) : super(key: key);

  // ✅ Ensure Key & IV match encryption process
  final encrypt.Key encryptionKey = encrypt.Key.fromUtf8('12345678901234567890123456789012'); // 32-byte AES key
  final encrypt.IV iv = encrypt.IV.fromUtf8('1234567890123456'); // 16-byte IV

  Future<void> decryptAndOpenFile() async {
    try {
      Directory appDir = await getApplicationDocumentsDirectory();
      String encryptedFilePath = "${appDir.path}/${post.fileName}";
      String decryptedFilePath = "${appDir.path}/decrypted_${post.fileName}";

      File encryptedFile = File(encryptedFilePath);
      if (!await encryptedFile.exists()) {
        Get.snackbar("Error", "File not found. Download it first.");
        return;
      }

      // ✅ Read encrypted file bytes
      Uint8List encryptedBytes = await encryptedFile.readAsBytes();

      // ✅ Ensure same encryption settings are used
      final encrypter = encrypt.Encrypter(
        encrypt.AES(encryptionKey, mode: encrypt.AESMode.cbc, padding: "PKCS7"),
      );

      // ✅ Decrypt the file
      List<int> decryptedBytes = encrypter.decryptBytes(encrypt.Encrypted(encryptedBytes), iv: iv);

      // ✅ Write decrypted file
      File decryptedFile = File(decryptedFilePath);
      await decryptedFile.writeAsBytes(decryptedBytes);

      Get.snackbar("Success", "File decrypted! Opening now...");

      // ✅ Open the decrypted file
      OpenFilex.open(decryptedFilePath);
    } catch (e) {
      Get.snackbar("Error", "Failed to decrypt and open file. ${e.toString()}");
      print("❌ Decryption Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(post.fileName)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Uploaded by: ${post.username}"),
            Text("File Type: ${post.fileType}"),
            post.isPremium
                ? ElevatedButton(
              onPressed: decryptAndOpenFile,
              child: Text("Decrypt & Open File"),
            )
                : ElevatedButton(
              onPressed: () {
                OpenFilex.open(post.fileUrl); // ✅ Directly open non-premium file
              },
              child: Text("Open File"),
            ),
          ],
        ),
      ),
    );
  }
}
