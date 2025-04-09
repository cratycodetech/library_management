import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

class GroupCallScreen extends StatefulWidget {
  final String channelName;
  final String token;

  GroupCallScreen({required this.channelName, required this.token});

  @override
  _GroupCallScreenState createState() => _GroupCallScreenState();
}

class _GroupCallScreenState extends State<GroupCallScreen> {
  RtcEngine? _engine;
  bool isJoined = false;
  List<int> remoteUsers = [];
  String? groupName;

  @override
  void initState() {
    super.initState();
    _initializeAgora();
  }

  Future<void> _initializeAgora() async {
    await [Permission.microphone, Permission.camera].request();

    if (!(await Permission.microphone.isGranted) || !(await Permission.camera.isGranted)) {
      print("🚨 Permissions not granted!");
      return;
    }

    _engine = createAgoraRtcEngine();
    await _engine?.initialize(RtcEngineContext(appId: "68cc27d382a44628a9454809677e96e6"));

    _engine?.registerEventHandler(RtcEngineEventHandler(
      onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
        setState(() => isJoined = true);
      },
      onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
        setState(() => remoteUsers.add(remoteUid));
        _engine?.setupRemoteVideo(VideoCanvas(uid: remoteUid, renderMode: RenderModeType.renderModeHidden));
      },
      onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
        setState(() => remoteUsers.remove(remoteUid));
      },
    ));

    await _engine?.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await _engine?.enableVideo();
    await _engine?.startPreview();
    await _engine?.setupLocalVideo(VideoCanvas(uid: 0, renderMode: RenderModeType.renderModeHidden));

    String agoraToken = await _fetchTokenFromFirestore();

    if (agoraToken.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: No valid Agora token!")));
      return;
    }

    await _engine?.joinChannel(
      token: agoraToken,
      channelId: widget.channelName,
      uid: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      options: ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      ),
    );
  }

  Future<String> _fetchTokenFromFirestore() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.channelName)
        .get();

    if (snapshot.exists) {
      setState(() {
        groupName = snapshot['name'] ?? widget.channelName;
      });
      return snapshot['callToken'] ?? '';
    }
    return '';
  }

  @override
  void dispose() {
    _engine?.leaveChannel();
    _engine?.release();
    FirebaseFirestore.instance.collection('groups').doc(widget.channelName).update({
      'isCallActive': false,
      'callToken': null,
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Dynamic video layout
            Positioned.fill(child: _buildDynamicVideoLayout()),

            // Top bar with group name
            Positioned(
              top: 16,
              left: 12,
              right: 12,
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    groupName ?? '',
                    style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            // Center info (only when no one has joined)
            if (remoteUsers.isEmpty)
              Positioned(
                top: MediaQuery.of(context).size.height * 0.15,
                left: 0,
                right: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage('assets/avatar_placeholder.png'),
                    ),
                    SizedBox(height: 12),
                    Text(
                      groupName ?? '',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    SizedBox(height: 4),
                    Text("Calling...", style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ),

            // Bottom controls
            Positioned(
              bottom: 24,
              left: 24,
              right: 24,
              child: Container(
                height: 70,
                padding: EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(Icons.videocam, color: Colors.white),
                      onPressed: () => _engine?.disableVideo(),
                    ),
                    IconButton(
                      icon: Icon(Icons.mic, color: Colors.white),
                      onPressed: () => _engine?.enableAudio(),
                    ),
                    IconButton(
                      icon: Icon(Icons.screen_share, color: Colors.white),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: Icon(Icons.cameraswitch, color: Colors.white),
                      onPressed: () => _engine?.switchCamera(),
                    ),
                    IconButton(
                      icon: Icon(Icons.call_end, color: Colors.redAccent),
                      onPressed: () {
                        _engine?.leaveChannel();
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicVideoLayout() {
    const int maxTiles = 6;
    List<Widget> tiles = [];

    // Local video
    tiles.add(
      AgoraVideoView(
        controller: VideoViewController(
          rtcEngine: _engine!,
          canvas: VideoCanvas(uid: 0, renderMode: RenderModeType.renderModeHidden),
        ),
      ),
    );

    // Remote users (limit to 5 others)
    int remoteToShow = remoteUsers.length > (maxTiles - 1) ? (maxTiles - 1) : remoteUsers.length;

    for (int i = 0; i < remoteToShow; i++) {
      tiles.add(
        AgoraVideoView(
          controller: VideoViewController.remote(
            rtcEngine: _engine!,
            canvas: VideoCanvas(uid: remoteUsers[i], renderMode: RenderModeType.renderModeHidden),
            connection: RtcConnection(channelId: widget.channelName),
          ),
        ),
      );
    }

    // More than 6 users: show "+" icon
    if ((remoteUsers.length + 1) > maxTiles) {
      tiles.add(
        Container(
          color: Colors.black87,
          child: Center(
            child: Icon(Icons.add, color: Colors.white, size: 36),
          ),
        ),
      );
    }

    int total = tiles.length;
    int crossAxisCount;
    if (total == 1) {
      return tiles.first;
    } else if (total <= 2) {
      crossAxisCount = 1;
    } else if (total <= 4) {
      crossAxisCount = 2;
    } else {
      crossAxisCount = 3;
    }

    return GridView.count(
      crossAxisCount: crossAxisCount,
      childAspectRatio: 9 / 16,
      physics: NeverScrollableScrollPhysics(),
      children: tiles,
    );
  }
}
