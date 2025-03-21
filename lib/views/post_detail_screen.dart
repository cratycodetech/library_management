import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:open_filex/open_filex.dart';
import '../models/post_model.dart';

class PostDetailScreen extends StatelessWidget {
  final PostModel post;

  PostDetailScreen({Key? key, required this.post}) : super(key: key);


  final encrypt.Key encryptionKey = encrypt.Key.fromUtf8(dotenv.env['ENCRYPTION_KEY'] ?? '');
  final encrypt.IV iv = encrypt.IV.fromUtf8(dotenv.env['ENCRYPTION_IV'] ?? '');


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


      Uint8List encryptedBytes = await encryptedFile.readAsBytes();


      final encrypter = encrypt.Encrypter(
        encrypt.AES(encryptionKey, mode: encrypt.AESMode.cbc, padding: "PKCS7"),
      );


      List<int> decryptedBytes = encrypter.decryptBytes(encrypt.Encrypted(encryptedBytes), iv: iv);


      File decryptedFile = File(decryptedFilePath);
      await decryptedFile.writeAsBytes(decryptedBytes);

      Get.snackbar("Success", "File decrypted! Opening now...");


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
                OpenFilex.open(post.fileUrl);
              },
              child: Text("Open File"),
            ),
          ],
        ),
      ),
    );
  }
}
