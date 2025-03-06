import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:permission_handler/permission_handler.dart';

import '../services/agora_service.dart';


class CallScreen extends StatefulWidget {
  final String channelName;
  final String token;

  const CallScreen({
    Key? key,
    required this.channelName,
    required this.token,
  }) : super(key: key);

  @override
  _CallScreenState createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  late RtcEngine _engine;
  RtcEngine? _screenShareEngine;
  bool _localUserJoined = false;
  int? _remoteUid;
  bool _isMuted = false;
  bool _isVideoOn = true;
  bool _hasJoined = false;
  bool _isDisposed = false;
  bool _callEnded = false; // To prevent multiple exits
  late String _userId;
  bool isSharing = false;
  bool isSwitchingToScreenShare = false;

  @override
  void initState() {
    super.initState();
    _userId = FirebaseAuth.instance.currentUser!.uid;
    _initAgora();
    _listenForCallEnd();
    _listenForVideoToggle();
  }

  Future<void> _initAgora() async {
    try {
      if (_hasJoined) return;
      await _handlePermissions();
      print("🔹 Initializing Agora...");
      _engine = createAgoraRtcEngine();
      await _engine.initialize(const RtcEngineContext(
        appId: "68cc27d382a44628a9454809677e96e6",
      ));

      _engine.registerEventHandler(RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          if (!_isDisposed) {
            setState(() {
              _localUserJoined = true;
              _hasJoined = true;
            });
          }
          print("✅ Successfully joined channel!");
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          if (!_isDisposed) {
            setState(() {
              _remoteUid = remoteUid;
            });
          }
          print("✅ Remote user joined: $remoteUid");
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          print("🚨 Remote user left: $remoteUid");
          _endCall(); // Automatically end call when other user leaves
        },
        onError: (ErrorCodeType error, String msg) {
          print("🚨 Agora Error: $error - $msg");
        },
      ));

      _engine.registerEventHandler(RtcEngineEventHandler(
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          print("✅ Remote user joined: $remoteUid");

          if (!_isDisposed) {
            setState(() {
              _remoteUid = remoteUid;
            });
          }

          bool isScreenSharing = remoteUid == _remoteUid! + 1;
          if (isScreenSharing) {
            print("🖥️ Remote user is sharing screen");
            _engine.muteRemoteVideoStream(uid: remoteUid, mute: false);
          }

        },
      ));


      await _engine.enableVideo();
      await _engine.enableAudio();
      await _engine.startPreview();
      await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);

      print("🔹 Joining channel: ${widget.channelName}");
      await _engine.joinChannel(
        token: widget.token,
        channelId: widget.channelName,
        uid: DateTime.now().millisecondsSinceEpoch.remainder(1000000),
        options: const ChannelMediaOptions(),
      );
    } catch (e) {
      print("🚨 Exception in Agora: $e");
    }
  }
  Future<void> _handlePermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.microphone,
    ].request();

    if (statuses[Permission.camera] != PermissionStatus.granted ||
        statuses[Permission.microphone] != PermissionStatus.granted) {
      print("🚨 Camera or Microphone permission not granted!");
      Get.snackbar("Permission Denied", "Please enable camera & microphone permissions in settings.");
      return;
    }
  }

  void _listenForVideoToggle() {
    FirebaseFirestore.instance
        .collection('calls')
        .doc(widget.channelName)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        bool newVideoState = snapshot.data()?['isVideoOn'] ?? true;

        if (mounted) {
          setState(() {
            _isVideoOn = newVideoState;
          });
        }

        // **Ensure Agora updates accordingly**
        if (_isVideoOn) {
          print("📹 Remote user enabled video");
          _engine.muteLocalVideoStream(false); // Start sending video
          _engine.enableVideo();
        } else {
          print("🚫 Remote user disabled video");
          _engine.muteLocalVideoStream(true); // Stop sending video
          _engine.disableVideo();
        }
      }
    });
  }



  /// **Listen for Firestore updates and exit if the call is ended**
  void _listenForCallEnd() {
    FirebaseFirestore.instance
        .collection('calls')
        .doc(widget.channelName)
        .snapshots()
        .listen((snapshot) {
      if (!snapshot.exists || snapshot.data()?['status'] == 'ended') {
        print("🚨 Call ended remotely! Exiting...");
        _leaveCall();
      }
    });
  }


  Future<void> _leaveCall() async {
    if (_callEnded) return;
    _callEnded = true;

    try {
      await _engine.leaveChannel();
      await _engine.release();

      if (_screenShareEngine != null) {
        await _screenShareEngine!.leaveChannel();
        await _screenShareEngine!.release();
        _screenShareEngine = null;
      }

      Get.back();
    } catch (e) {
      print("🚨 Error leaving call: $e");
    }
  }


  /// **Handle Remote User Leaving (End Call for Both Users)**
  void _endCall() async {
    if (_callEnded) return;
    _callEnded = true;

    print("❌ Ending call for both users...");

    try {
      await FirebaseFirestore.instance.collection('calls')
          .doc(widget.channelName)
          .update({'status': 'ended'}).catchError((_) {
        print("⚠️ Error updating Firestore call status");
      });

      _leaveCall();
    } catch (e) {
      print("🚨 Error ending call: $e");
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _leaveCall(); // Ensure call is properly left when closing screen
    super.dispose();
  }

  void _toggleMute() {
    setState(() => _isMuted = !_isMuted);
    _engine.muteLocalAudioStream(_isMuted);
  }

  void _toggleVideo() {
    bool newVideoState = !_isVideoOn; // Toggle state

    setState(() {
      _isVideoOn = newVideoState;
    });

    if (_isVideoOn) {
      print("📹 Video Enabled");
      _engine.muteLocalVideoStream(false); // Start sending video
      _engine.enableVideo(); // Allow video streaming
    } else {
      print("🚫 Video Disabled");
      _engine.muteLocalVideoStream(true); // Stop sending video
      _engine.disableVideo(); // Disable local video
    }

    // **Update Firestore to inform the other user**
    FirebaseFirestore.instance
        .collection('calls')
        .doc(widget.channelName)
        .update({'isVideoOn': _isVideoOn}).catchError((_) {
      print("⚠️ Error updating Firestore video status");
    });
  }


  Future<void> startScreenShare() async {
    try {
      int screenShareUid = DateTime.now().millisecondsSinceEpoch.remainder(1000000);

      String screenShareToken = await AgoraService().generateToken(widget.channelName, screenShareUid);
      print("📺 Screen Sharing Token: $screenShareToken");

      _screenShareEngine = createAgoraRtcEngine();
      await _screenShareEngine!.initialize(const RtcEngineContext(
        appId: "68cc27d382a44628a9454809677e96e6",
      ));

      await _screenShareEngine!.startScreenCapture(
        ScreenCaptureParameters2(
          captureAudio: true,
          audioParams: ScreenAudioParameters(),
          videoParams: ScreenVideoParameters(frameRate: 15, bitrate: 800),
        ),
      );

      await _screenShareEngine!.joinChannel(
        token: screenShareToken,
        channelId: widget.channelName,
        uid: screenShareUid,
        options: const ChannelMediaOptions(
          publishScreenTrack: true,
          publishCameraTrack: false,
          publishMicrophoneTrack: false,
        ),
      );

      setState(() {
        isSharing = true;
      });

      print("📺 Screen Sharing Started!");
    } catch (e) {
      print("🚨 Error starting screen share: $e");
    }
  }






  Future<void> stopScreenShare() async {
    await _engine.stopScreenCapture();
    await _engine.leaveChannel();

    setState(() {
      isSharing = false;
    });

    print("📺 Screen Sharing Stopped!");
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Agora Call"),
        actions: [
          IconButton(
            icon: const Icon(Icons.call_end, color: Colors.red),
            onPressed: _leaveCall,
          ),
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: _remoteUid != null
                ? (_isVideoOn
                ? AgoraVideoView(
              controller: VideoViewController.remote(
                rtcEngine: _engine,
                connection: RtcConnection(channelId: widget.channelName),
                canvas: VideoCanvas(uid: _remoteUid!),
              ),
            )
                : _defaultVideoOffScreen()) // Show Default Screen if Video is OFF
                : _localUserJoined
                ? (_isVideoOn
                ? AgoraVideoView(
              controller: VideoViewController(
                rtcEngine: _engine,
                canvas: const VideoCanvas(uid: 0),
              ),
            )
                : _defaultVideoOffScreen()) // Show Default Screen if Video is OFF
                : const CircularProgressIndicator(),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FloatingActionButton(
                    backgroundColor: _isMuted ? Colors.grey : Colors.blue,
                    onPressed: _toggleMute,
                    heroTag: "muteButton", // ✅ Unique hero tag
                    child: Icon(_isMuted ? Icons.mic_off : Icons.mic),
                  ),
                  const SizedBox(width: 20),
                  FloatingActionButton(
                    backgroundColor: _isVideoOn ? Colors.blue : Colors.grey,
                    onPressed: _toggleVideo,
                    heroTag: "videoButton", // ✅ Unique hero tag
                    child: Icon(_isVideoOn ? Icons.videocam : Icons.videocam_off),
                  ),
                  FloatingActionButton(
                    backgroundColor: isSharing ? Colors.red : Colors.blue,
                    onPressed: () {
                      if (isSharing) {
                        stopScreenShare();
                      } else {
                        startScreenShare();
                      }
                      setState(() => isSharing = !isSharing);
                    },
                    child: Icon(isSharing ? Icons.stop_screen_share : Icons.screen_share),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// **Default Video OFF UI**
  Widget _defaultVideoOffScreen() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black, // Black screen background
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.videocam_off, color: Colors.white, size: 80), // Video Off Icon
          const SizedBox(height: 10),
          const Text(
            "Video is Off",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ],
      ),
    );
  }


}
