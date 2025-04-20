import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';
import 'package:library_app/views/widgets/video_message_widget.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';

class VideoPlayerPage extends StatefulWidget {
  final String videoUrl;
  final Future<XFile?> Function(String) thumbnailGenerator;
  final String senderName;

  const VideoPlayerPage({
    Key? key,
    required this.videoUrl,
    required this.thumbnailGenerator,
    required this.senderName,
  }) : super(key: key);

  @override
  _VideoPlayerPageState createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  Key _videoKey = UniqueKey();
  bool _isDownloading = false;

  void _replayVideo() {
    setState(() {
      _videoKey = UniqueKey();
    });
  }

  Future<void> _downloadVideo() async {
    setState(() => _isDownloading = true);

    try {
      final response = await http.get(Uri.parse(widget.videoUrl));
      if (response.statusCode == 200) {
        Uint8List videoData = response.bodyBytes;

        final Directory tempDir = await getTemporaryDirectory();
        final String fileName = p.basename(widget.videoUrl);
        final String filePath = '${tempDir.path}/$fileName';

        final File file = File(filePath);
        await file.writeAsBytes(videoData);

        final result = await ImageGallerySaverPlus.saveFile(file.path);

        if (result['isSuccess'] == true) {
          Get.snackbar(
            '✅ Download Complete',
            'Video saved to Gallery',
            snackPosition: SnackPosition.BOTTOM,
            duration: Duration(seconds: 4),
          );
        } else {
          Get.snackbar('Error', 'Failed to save to gallery');
        }
      } else {
        Get.snackbar('Error', 'Failed to download video file');
      }
    } catch (e) {
      Get.snackbar('Error', 'Download failed: $e');
      print('Download error: $e');
    } finally {
      setState(() => _isDownloading = false);
    }
  }

  Future<void> _shareVideo() async {
    try {
      final response = await http.get(Uri.parse(widget.videoUrl));
      if (response.statusCode == 200) {
        Uint8List videoData = response.bodyBytes;
        final Directory tempDir = await getTemporaryDirectory();
        final String fileName = p.basename(widget.videoUrl);
        final String filePath = '${tempDir.path}/$fileName';

        final File file = File(filePath);
        await file.writeAsBytes(videoData);

        Share.shareXFiles(
          [XFile(file.path)],
          text: "Check out this video!",
        );
      } else {
        Get.snackbar('Error', 'Failed to fetch video for sharing');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to share video: $e');
      print('Error sharing video: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.senderName),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert),
            onSelected: (String value) {
              if (value == 'download') {
                _downloadVideo();
              } else if (value == 'share') {
                _shareVideo();
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
                      Text('Downloading...'),
                    ],
                  )
                      : Text('Download'),
                ),
                const PopupMenuItem(
                  value: 'share',
                  child: Text('Share'),
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
