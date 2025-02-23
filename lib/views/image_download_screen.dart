import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../services/snackbar_service.dart';

class PhotoDownloadScreen extends StatelessWidget {
  const PhotoDownloadScreen({Key? key}) : super(key: key);


  Future<void> _downloadImage(String url) async {

    final directory = Platform.isAndroid
        ? '/storage/emulated/0/Download'
        : (await getApplicationDocumentsDirectory()).path;
    final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    await FlutterDownloader.enqueue(
      url: url,
      savedDir: directory,
      fileName: fileName,
      showNotification: true,
      openFileFromNotification: true,
    );
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
                SnackbarService.showSuccess('Download is started');

              } else if (value == 'details') {
                // Implement details functionality if needed
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'download',
                  child: Text('Download'),
                ),
                const PopupMenuItem<String>(
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
