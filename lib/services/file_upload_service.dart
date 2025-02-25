import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';


class FileUploadService {
  final SupabaseClient supabase = Supabase.instance.client;
  final String bucketName = 'library app';

  Future<String?> uploadFile(String userId) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);
      String fileName = result.files.single.name;

      // ✅ Generate unique filename
      String uniqueId = Uuid().v4();
      String newFileName = "${uniqueId}_$fileName";


      // ✅ Store file inside user's folder
      String filePath = "$userId/uploads/$newFileName";

      try {
        await supabase.storage.from(bucketName).upload(
          filePath,
          file,
          fileOptions: const FileOptions(upsert: false),
        );

        // ✅ Get public URL
        final downloadUrl = supabase.storage.from(bucketName).getPublicUrl(filePath);
        print("✅ File uploaded successfully: $downloadUrl");
        return downloadUrl;
      } catch (e) {
        print("❌ Upload failed: $e");
        return null;
      }
    } else {
      print("🚫 No file selected.");
      return null;
    }
  }

  Future<String?> uploadAnnotatedFile(File file, String storagePath) async {
    try {
      // Ensure the storagePath is properly formatted
      if (storagePath.startsWith("https")) {
        Uri uri = Uri.parse(storagePath);
        storagePath = uri.pathSegments.sublist(2).join('/'); // Extract correct path
      }

      // Upload the file and replace existing one
      await supabase.storage.from(bucketName).upload(
        storagePath,
        file,
        fileOptions: const FileOptions(upsert: true), // Enable overwrite
      );

      // Get the public URL of the updated file
      final String fileUrl = supabase.storage.from(bucketName).getPublicUrl(storagePath);

      print("✅ Annotated file uploaded successfully: $fileUrl");
      return fileUrl;
    } catch (e) {
      print("❌ Upload failed: $e");
      return null;
    }
  }



  Future<String?> uploadDocumentMediaFile(String documentId) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'mp4', 'mov', 'avi'],
    );

    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);
      String fileName = result.files.single.name;
      String uniqueId = Uuid().v4();
      String newFileName = "${uniqueId}_$fileName";
      String filePath = "documents/$documentId/uploads/$newFileName";

      try {
        await supabase.storage.from(bucketName).upload(
          filePath,
          file,
          fileOptions: const FileOptions(upsert: false),
        );
        final downloadUrl = supabase.storage.from(bucketName).getPublicUrl(filePath);
        print("✅ Document media file uploaded successfully: $downloadUrl");
        return downloadUrl;
      } catch (e) {
        print("❌ Upload failed: $e");
        return null;
      }
    } else {
      print("🚫 No file selected.");
      return null;
    }
  }



}
