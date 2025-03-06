import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class VoiceMessageWidget extends StatefulWidget {
  final String fileUrl;
  final bool isMe;

  const VoiceMessageWidget({required this.fileUrl, required this.isMe, Key? key}) : super(key: key);

  @override
  _VoiceMessageWidgetState createState() => _VoiceMessageWidgetState();
}

class _VoiceMessageWidgetState extends State<VoiceMessageWidget> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  double progress = 0.0;
  Duration totalDuration = Duration.zero;
  Duration currentPosition = Duration.zero;

  @override
  void initState() {
    super.initState();
    _audioPlayer.onDurationChanged.listen((Duration d) {
      setState(() {
        totalDuration = d;
      });
    });

    _audioPlayer.onPositionChanged.listen((Duration p) {
      setState(() {
        currentPosition = p;
        progress = totalDuration.inMilliseconds > 0
            ? p.inMilliseconds / totalDuration.inMilliseconds
            : 0.0;
      });
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      setState(() {
        isPlaying = false;
        progress = 0.0;
      });
    });
  }

  void _togglePlay() async {
    if (isPlaying) {
      await _audioPlayer.pause();
      setState(() => isPlaying = false);
    } else {
      await _audioPlayer.play(UrlSource(widget.fileUrl));
      setState(() => isPlaying = true);
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(duration.inMinutes)}:${twoDigits(duration.inSeconds.remainder(60))}";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: widget.isMe ? Colors.blueAccent : Colors.grey[300],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white),
            onPressed: _togglePlay,
          ),
          Expanded(
            child: LinearProgressIndicator(
              value: progress,
              color: Colors.white,
              backgroundColor: Colors.white30,
            ),
          ),
          SizedBox(width: 8),
          Text(
            _formatDuration(currentPosition),
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
