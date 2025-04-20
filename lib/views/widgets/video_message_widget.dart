import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';
import 'package:video_player/video_player.dart';

import '../../routes/routes.dart';

class InlineVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final Future<XFile?> Function(String) thumbnailGenerator;
  final bool autoPlay;

  const InlineVideoPlayer({
    Key? key,
    required this.videoUrl,
    required this.thumbnailGenerator,
    this.autoPlay = true,
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

    if (widget.autoPlay) {
      _initializeAndPlay();
    }
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

    if (widget.autoPlay) {
      _controller!.play();
      setState(() {
        _isPlaying = true;
      });
    }
  }

  void _seekForward() async {
    final position = await _controller?.position;
    if (position != null) {
      _controller?.seekTo(position + const Duration(seconds: 10));
    }
  }

  void _seekBackward() async {
    final position = await _controller?.position;
    if (position != null) {
      _controller?.seekTo(position - const Duration(seconds: 10));
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

  void _navigateToFullPlayer() {
    Get.toNamed(AppRoutes.videoDownload, arguments: {
      'videoUrl': widget.videoUrl,
      'thumbnailGenerator': widget.thumbnailGenerator,
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isInitialized
        ? Container(
      color: Colors.black,
      width: double.infinity,
      height: MediaQuery.of(context).size.height, // Full screen height
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              child: GestureDetector(
                onTap: _navigateToFullPlayer,
                child: VideoPlayer(_controller!),
              ),
            ),
          ),
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Text(formatDuration(_currentPosition),
                      style: const TextStyle(color: Colors.white)),
                  Expanded(
                    child: Slider(
                      min: 0,
                      max: _totalDuration.inSeconds.toDouble(),
                      value: _currentPosition.inSeconds
                          .toDouble()
                          .clamp(0.0, _totalDuration.inSeconds.toDouble()),
                      onChanged: (value) {
                        _controller!
                            .seekTo(Duration(seconds: value.toInt()));
                      },
                      activeColor: Colors.red,
                      inactiveColor: Colors.grey[700],
                    ),
                  ),
                  Text(formatDuration(_totalDuration),
                      style: const TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.replay_10, color: Colors.white),
                  onPressed: _seekBackward,
                ),
                IconButton(
                  icon: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPlaying = !_isPlaying;
                      _isPlaying
                          ? _controller!.play()
                          : _controller!.pause();
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.forward_10, color: Colors.white),
                  onPressed: _seekForward,
                ),
              ],
            ),
          )
        ],
      ),
    )
        : FutureBuilder<XFile?>(
      future: _thumbnailFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError ||
            !snapshot.hasData ||
            snapshot.data == null) {
          return GestureDetector(
            onTap: _navigateToFullPlayer,
            child: Container(
              color: Colors.black,
              height: 200,
              child: const Center(
                child: Icon(Icons.play_circle_outline,
                    size: 50, color: Colors.white),
              ),
            ),
          );
        } else {
          return GestureDetector(
            onTap: _navigateToFullPlayer,
            child: Container(
              color: Colors.black,
              width: double.infinity,
              height: MediaQuery.of(context).size.height,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.file(
                    File(snapshot.data!.path),
                    fit: BoxFit.contain,
                  ),
                  const Icon(Icons.play_circle_outline,
                      size: 50, color: Colors.white),
                ],
              ),
            ),
          );
        }
      },
    );
  }

}



class VideoMessageWidget extends StatefulWidget {
  final File videoFile;
  final bool isLocal;

  const VideoMessageWidget({required this.videoFile, this.isLocal = false});

  @override
  State<VideoMessageWidget> createState() => _VideoMessageWidgetState();
}

class _VideoMessageWidgetState extends State<VideoMessageWidget> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.videoFile)
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _playPause() {
    setState(() {
      _controller.value.isPlaying
          ? _controller.pause()
          : _controller.play();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _playPause,
      child: _isInitialized
          ? Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          ),
          if (!_controller.value.isPlaying)
            const Icon(Icons.play_circle_outline,
                size: 50, color: Colors.white),
        ],
      )
          : Container(
        height: 300,
        width: 250,
        color: Colors.grey[300],
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
