import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as p;



class FileUploadService {
  final SupabaseClient supabase = Supabase.instance.client;
  final String bucketName = 'library app';

  Future<String?> uploadFile(String userId, File file) async {
    if (file == null) {
      print("🚫 No file provided.");
      return null;
    }

    String fileName = p.basename(file.path); // Extract file name
    String uniqueId = Uuid().v4();
    String newFileName = "${uniqueId}_$fileName";
    String filePath = "$userId/uploads/$newFileName";

    try {
      await supabase.storage.from(bucketName).upload(
        filePath,
        file,
        fileOptions: const FileOptions(upsert: false),
      );

      final downloadUrl = supabase.storage.from(bucketName).getPublicUrl(filePath);
      print("✅ File uploaded successfully: $downloadUrl");
      return downloadUrl;
    } catch (e) {
      print("❌ Upload failed: $e");
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

  Future<String?> uploadRecordingToSupabase(File recordingFile) async {
    try {
      if (!await recordingFile.exists()) {
        print("🚫 Recording file does not exist.");
        return null;
      }


      String uniqueId = Uuid().v4();
      String fileName = "recording_${uniqueId}.m4a";
      String filePath = "recordings/$fileName";


      await supabase.storage.from(bucketName).upload(
        filePath,
        recordingFile,
        fileOptions: const FileOptions(upsert: false),
      );

      final String downloadUrl = supabase.storage.from(bucketName).getPublicUrl(filePath);
      print("✅ Recording uploaded successfully: $downloadUrl");

      return downloadUrl;
    } catch (e) {
      print("❌ Recording upload failed: $e");
      return null;
    }
  }



}
