import 'dart:io';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';

import '../services/file_upload_service.dart';


class PostingController extends GetxController {
  var selectedFilePath = ''.obs;
  final FileUploadService fileUploadService = FileUploadService();

  void pickAndUploadFile({bool isPremium = false}) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);
      selectedFilePath.value = file.path;

      // Upload file to Supabase and Firestore with Premium flag
      String? fileUrl = await fileUploadService.uploadPostedFile(file, isPremium: isPremium);

      if (fileUrl != null) {
        Get.snackbar("Success", "File uploaded successfully: $fileUrl");
      } else {
        Get.snackbar("Error", "File upload failed.");
      }
    } else {
      Get.snackbar("Error", "No file selected.");
    }
  }
}
