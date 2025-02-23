import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:library_app/views/widgets/video_message_widget.dart';


class VideoPlayerPage extends StatefulWidget {
  final String videoUrl;
  final Future<XFile?> Function(String) thumbnailGenerator;

  const VideoPlayerPage({
    Key? key,
    required this.videoUrl,
    required this.thumbnailGenerator,
  }) : super(key: key);

  @override
  _VideoPlayerPageState createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  // A key to force rebuild the InlineVideoPlayer.
  Key _videoKey = UniqueKey();
  bool _isDownloading = false;

  void _replayVideo() {
    setState(() {
      _videoKey = UniqueKey();
    });
  }

  Future<void> _downloadVideo() async {
    PermissionStatus permissionStatus;

    // On Android 11+ (API level 30+), request manageExternalStorage.
    if (Platform.isAndroid) {
      permissionStatus = await Permission.manageExternalStorage.status;
      if (!permissionStatus.isGranted) {
        permissionStatus = await Permission.manageExternalStorage.request();
      }
    } else {
      permissionStatus = await Permission.storage.request();
    }

    // if (!permissionStatus.isGranted) {
    //   if (permissionStatus.isPermanentlyDenied) {
    //     Get.snackbar(
    //       'Permission Denied',
    //       'Storage permission is permanently denied. Please enable it in settings.',
    //       snackPosition: SnackPosition.BOTTOM,
    //     );
    //     await openAppSettings();
    //   } else {
    //     Get.snackbar(
    //       'Permission Denied',
    //       'Storage permission is required to download the video.',
    //       snackPosition: SnackPosition.BOTTOM,
    //     );
    //   }
    //   return;
    // }

    setState(() {
      _isDownloading = true;
    });

    try {
      // Define the public Downloads directory on Android.
      final downloadsDir = "/storage/emulated/0/Download";
      final fileName = widget.videoUrl.split('/').last;

      // Enqueue the download task.
      await FlutterDownloader.enqueue(
        url: widget.videoUrl,
        savedDir: downloadsDir,
        fileName: fileName,
        showNotification: true, // optional: show download progress in notification
        openFileFromNotification: true, // optional: allow opening file on tap from notification
      );

      Get.snackbar(
        'Download Started',
        'Video is downloading to:\n$downloadsDir',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to download video: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      print( 'Failed to download video: $e');
    } finally {
      setState(() {
        _isDownloading = false;
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Player'),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert),
            onSelected: (String value) {
              if (value == 'download') {
                _downloadVideo();
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  value: 'download',
                  child: _isDownloading
                      ? Row(
                    children: [
                      SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text('Downloading'),
                    ],
                  )
                      : Text('Download'),
                ),
              ];
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _replayVideo,
            tooltip: 'Replay Video',
          ),
        ],
      ),
      body: Center(
        child: InlineVideoPlayer(
          key: _videoKey,
          videoUrl: widget.videoUrl,
          thumbnailGenerator: widget.thumbnailGenerator,
        ),
      ),
    );
  }
}
