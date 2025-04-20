import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import '../services/snackbar_service.dart';

class PhotoDownloadScreen extends StatelessWidget {
  const PhotoDownloadScreen({Key? key}) : super(key: key);

  Future<void> _downloadImage(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        Uint8List fileData = response.bodyBytes;

        final tempDir = await getTemporaryDirectory();
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        final filePath = '${tempDir.path}/$fileName';

        final file = File(filePath);
        await file.writeAsBytes(fileData);

        final result = await ImageGallerySaverPlus.saveFile(file.path);

        if (result['isSuccess'] == true) {
          SnackbarService.showSuccess('✅ Image saved to Gallery');
        } else {
          SnackbarService.showError('❌ Failed to save image');
        }
      } else {
        SnackbarService.showError('❌ Failed to fetch image');
      }
    } catch (e) {
      SnackbarService.showError('❌ Download error: $e');
    }
  }


  Future<void> _shareImage(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        Uint8List fileData = response.bodyBytes;
        final Directory tempDir = await getTemporaryDirectory();
        final String fileName = p.basename(Uri.parse(url).path);
        final String filePath = '${tempDir.path}/$fileName';

        final File file = File(filePath);
        await file.writeAsBytes(fileData);

        Share.shareXFiles(
          [XFile(file.path)],
          text: "Check out this image!",
        );
      } else {
        SnackbarService.showError('❌ Failed to fetch image');
      }
    } catch (e) {
      SnackbarService.showError('❌ Share error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final String photoUrl = args['photoUrl'] ?? '';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Photo Viewer'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'download') {
                _downloadImage(photoUrl);
                SnackbarService.showSuccess('Download started');
              } else if (value == 'share') {
                _shareImage(photoUrl);
              } else if (value == 'details') {
                // You can handle details action here
              }
            },
            itemBuilder: (BuildContext context) {
              return const [
                PopupMenuItem<String>(
                  value: 'download',
                  child: Text('Download'),
                ),
                PopupMenuItem<String>(
                  value: 'share',
                  child: Text('Share'),
                ),
                PopupMenuItem<String>(
                  value: 'details',
                  child: Text('Details'),
                ),
              ];
            },
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: photoUrl.isNotEmpty
            ? InteractiveViewer(
          child: Image.network(
            photoUrl,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Center(
              child: Text(
                'Failed to load image',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        )
            : const Center(
          child: Text(
            'No image available',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
