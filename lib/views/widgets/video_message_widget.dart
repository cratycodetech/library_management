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
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

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
      _totalDuration = _controller!.value.duration;
    });

    _controller!.addListener(() {
      setState(() {
        _currentPosition = _controller!.value.position;
      });
    });

    _controller!.play();
    setState(() {
      _isPlaying = true;
    });
  }

  void _seekForward() async {
    if (_controller != null) {
      final position = await _controller!.position;
      if (position != null) {
        _controller!.seekTo(position + Duration(seconds: 10));
      }
    }
  }

  void _seekBackward() async {
    if (_controller != null) {
      final position = await _controller!.position;
      if (position != null) {
        _controller!.seekTo(position - Duration(seconds: 10));
      }
    }
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
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
        width: 250,
        height: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.black,
        ),
        child: _isInitialized
            ? Column(
          children: [
            Expanded(child: VideoPlayer(_controller!)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Text(formatDuration(_currentPosition), style: TextStyle(color: Colors.white)),
                  Expanded(
                    child: Slider(
                      min: 0,
                      max: _totalDuration.inSeconds.toDouble(),
                      value: _currentPosition.inSeconds.toDouble().clamp(0.0, _totalDuration.inSeconds.toDouble()),
                      onChanged: (value) {
                        _controller!.seekTo(Duration(seconds: value.toInt()));
                      },
                      activeColor: Colors.red,
                      inactiveColor: Colors.grey[700],
                    ),
                  ),
                  Text(formatDuration(_totalDuration), style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.replay_10, color: Colors.white),
                  onPressed: _seekBackward,
                ),
                IconButton(
                  icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white),
                  onPressed: _onTap,
                ),
                IconButton(
                  icon: Icon(Icons.forward_10, color: Colors.white),
                  onPressed: _seekForward,
                ),
              ],
            ),
          ],
        )
            : FutureBuilder<XFile?>(
          future: _thumbnailFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
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
