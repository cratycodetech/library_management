import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:audio_waveforms/audio_waveforms.dart';

class VoiceMessageWidget extends StatefulWidget {
  final String fileUrl;
  final bool isMe;

  const VoiceMessageWidget({
    required this.fileUrl,
    required this.isMe,
    Key? key,
  }) : super(key: key);

  @override
  _VoiceMessageWidgetState createState() => _VoiceMessageWidgetState();
}

class _VoiceMessageWidgetState extends State<VoiceMessageWidget> {
  final PlayerController _playerController = PlayerController();
  bool isPlaying = false;
  String? localPath;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;


  @override
  void initState() {
    super.initState();
    _setupPlayer();
  }

  Future<void> _setupPlayer() async {
    localPath = await _downloadFile(widget.fileUrl);
    await _playerController.preparePlayer(path: localPath!);
    _totalDuration = Duration(milliseconds: _playerController.maxDuration ?? 0);
    _playerController.onCurrentDurationChanged.listen((ms) {
      setState(() => _currentPosition = Duration(milliseconds: ms));
    });

    _playerController.onCompletion.listen((_) async {
      await _playerController.stopPlayer();
      await _playerController.preparePlayer(path: localPath!);
      setState(() {
        isPlaying = false;
        _currentPosition = Duration.zero;
      });
    });

    setState(() {});
  }

  Future<String> _downloadFile(String url) async {
    final response = await http.get(Uri.parse(url));
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/${DateTime.now().millisecondsSinceEpoch}.aac');
    await file.writeAsBytes(response.bodyBytes);
    return file.path;
  }

  void _togglePlay() async {
    if (isPlaying) {
      await _playerController.pausePlayer();
      setState(() => isPlaying = false);
    } else {
      await _playerController.startPlayer();
      setState(() => isPlaying = true);
    }
  }

  String _formatTime(Duration duration) {
    return "${duration.inMinutes.remainder(60).toString().padLeft(2, '0')}:${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final bubbleColor = widget.isMe ? const Color(0xFF25D366) : Colors.blue;
    final textColor = widget.isMe ? Colors.white : Colors.black;

    return Align(
      alignment: widget.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        width: double.infinity,
        height: 70.h,
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: const Radius.circular(16),
            bottomRight: const Radius.circular(16),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: localPath != null ? _togglePlay : null,
              child: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                color: textColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            if (localPath != null)
              Expanded(
                child: AudioFileWaveforms(
                  size: const Size(130, 30),
                  playerController: _playerController,
                  enableSeekGesture: true,
                  waveformType: WaveformType.fitWidth,
                  playerWaveStyle: PlayerWaveStyle(
                    scaleFactor: 90,
                    fixedWaveColor: textColor.withOpacity(0.4),
                    liveWaveColor: textColor,
                    spacing: 4,
                    showSeekLine: false,
                    waveThickness: 3.0,
                  ),
                ),
              ),
            const SizedBox(width: 6),
            Text(
              _formatTime(isPlaying ? _currentPosition : _totalDuration),
              style: TextStyle(
                color: textColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),

          ],
        ),
      ),
    );
  }


  @override
  void dispose() {
    _playerController.dispose();
    super.dispose();
  }
}
