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

  @override
  void initState() {
    super.initState();
    _initializeAgora();
  }

  Future<void> _initializeAgora() async {
    print("🔹 Requesting camera & microphone permissions...");
    await [Permission.microphone, Permission.camera].request();

    if (!(await Permission.microphone.isGranted) || !(await Permission.camera.isGranted)) {
      print("🚨 Error: Permissions not granted!");
      return;
    }

    print("🔹 Creating Agora RTC Engine...");
    _engine = createAgoraRtcEngine();
    await _engine?.initialize(RtcEngineContext(appId: "68cc27d382a44628a9454809677e96e6")); // Replace with your valid Agora App ID
    print("✅ Agora Engine Initialized!");

    print("🔹 Registering Event Handlers...");
    _engine?.registerEventHandler(RtcEngineEventHandler(
      onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
        print("✅ Successfully joined channel as a broadcaster: ${connection.channelId}");
        setState(() => isJoined = true);
      },
      onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
        print("✅ Remote user joined: $remoteUid");
        setState(() => remoteUsers.add(remoteUid));
        _engine?.setupRemoteVideo(VideoCanvas(uid: remoteUid, renderMode: RenderModeType.renderModeHidden));
      },
      onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
        print("🚨 User left: $remoteUid");
        setState(() => remoteUsers.remove(remoteUid));
      },
      onError: (ErrorCodeType error, String msg) {
        print("🚨 Agora Error: Code $error - $msg");
      },
    ));

    print("🔹 Setting Client Role to Broadcaster...");
    await _engine?.setClientRole(role: ClientRoleType.clientRoleBroadcaster);

    print("🔹 Enabling Video...");
    await _engine?.enableVideo();
    await _engine?.startPreview();
    await _engine?.setupLocalVideo(VideoCanvas(uid: 0, renderMode: RenderModeType.renderModeHidden));
    print("✅ Video Enabled!");

    print("🔹 Fetching Agora Token from Firestore...");
    String agoraToken = await _fetchTokenFromFirestore();

    if (agoraToken.isEmpty) {
      print("🚨 Error: No valid Agora token found in Firestore!");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: No valid Agora token!")));
      return;
    }

    print("✅ Agora Token Retrieved: $agoraToken");

    print("🔹 Joining Agora Channel as Broadcaster...");
    await _engine?.joinChannel(
      token: agoraToken,
      channelId: widget.channelName,
      uid: DateTime.now().millisecondsSinceEpoch.remainder(100000), // Generate a unique UID
      options: ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster, // 🎥 Broadcast mode
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting, // Live Broadcast Mode
      ),
    );

    print("✅ Successfully joined as a Broadcaster!");
  }


  Future<String> _fetchTokenFromFirestore() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('groups').doc(widget.channelName).get();
    return snapshot.exists ? snapshot['callToken'] ?? '' : '';
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
      appBar: AppBar(title: Text("Group Call")),
      body: Stack(
        children: [
          _renderLocalVideo(),
          _renderRemoteVideos(),
          _callControls(),
        ],
      ),
    );
  }

  Widget _renderLocalVideo() {
    return Positioned(
      top: 10,
      right: 10,
      width: 120,
      height: 160,
      child: _engine == null
          ? Center(child: Text("Initializing video..."))
          : AgoraVideoView(
        controller: VideoViewController(
          rtcEngine: _engine!,
          canvas: VideoCanvas(uid: 0, renderMode: RenderModeType.renderModeHidden),
        ),
      ),
    );
  }

  Widget _renderRemoteVideos() {
    if (_engine == null || remoteUsers.isEmpty) {
      return Center(child: Text("Waiting for remote users..."));
    }

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.0,
      ),
      itemCount: remoteUsers.length,
      itemBuilder: (context, index) {
        return AgoraVideoView(
          controller: VideoViewController.remote(
            rtcEngine: _engine!,
            canvas: VideoCanvas(uid: remoteUsers[index], renderMode: RenderModeType.renderModeHidden),
            connection: RtcConnection(channelId: widget.channelName),
          ),
        );
      },
    );
  }

  Widget _callControls() {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton(
            heroTag: "switchCamera",
            onPressed: () => _engine?.switchCamera(),
            child: Icon(Icons.switch_camera),
          ),
          SizedBox(width: 20),
          FloatingActionButton(
            heroTag: "endCall",
            onPressed: () {
              _engine?.leaveChannel();
              Navigator.pop(context);
            },
            backgroundColor: Colors.red,
            child: Icon(Icons.call_end),
          ),
        ],
      ),
    );
  }
}
