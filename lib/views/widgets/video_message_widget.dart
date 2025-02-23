import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:get_thumbnail_video/video_thumbnail.dart';
import 'package:video_player/video_player.dart';

import '../../routes/routes.dart';


class InlineVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final Future<XFile?> Function(String) thumbnailGenerator; // Pass your generator here

  const InlineVideoPlayer({
    Key? key,
    required this.videoUrl,
    required this.thumbnailGenerator,
  }) : super(key: key);

  @override
  _InlineVideoPlayerState createState() => _InlineVideoPlayerState();
}

class _InlineVideoPlayerState extends State<InlineVideoPlayer> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  late Future<XFile?> _thumbnailFuture;

  @override
  void initState() {
    super.initState();
    _thumbnailFuture = widget.thumbnailGenerator(widget.videoUrl);
  }

  Future<void> _initializeAndPlay() async {
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    await _controller!.initialize();
    setState(() {
      _isInitialized = true;
      _isPlaying = true;
    });
    _controller!.play();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _onTap() async {
    if (!_isInitialized) {
      await _initializeAndPlay();
    } else {
      if (_isPlaying) {
        _controller!.pause();
        setState(() {
          _isPlaying = false;
        });
        Get.toNamed(AppRoutes.videoDownload, arguments: {
          'videoUrl': widget.videoUrl,
          'thumbnailGenerator': widget.thumbnailGenerator,
        });
      } else {
        _controller!.play();
        setState(() {
          _isPlaying = true;
        });
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.black,
        ),
        child: _isInitialized
            ? VideoPlayer(_controller!)
            : FutureBuilder<XFile?>(
          future: _thumbnailFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
              // If thumbnail can't be generated, show a fallback placeholder
              return Stack(
                children: [
                  Container(color: Colors.grey[300]),
                  Center(
                    child: Icon(
                      Icons.play_circle_outline,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                ],
              );
            } else {
              // If thumbnail is available, display it with a play overlay.
              return Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(
                    File(snapshot.data!.path),
                    fit: BoxFit.cover,
                  ),
                  Center(
                    child: Icon(
                      Icons.play_circle_outline,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
