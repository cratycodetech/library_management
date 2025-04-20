import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

class GroupCallScreen extends StatefulWidget {
  final String channelName;
  final String token;

  final bool withVideo;
  const GroupCallScreen({super.key, required this.channelName, required this.token, this.withVideo = true});


  @override
  _GroupCallScreenState createState() => _GroupCallScreenState();
}

class _GroupCallScreenState extends State<GroupCallScreen> {
  RtcEngine? _engine;
  bool isJoined = false;
  List<int> remoteUsers = [];
  String? groupName;
  String participantId = '';
  bool isMuted = false;
  bool isMutedVideo = false;
  Map<int, bool> remoteUserVideoMuted = {};
  Map<int, String> remoteUserPhotos = {};

  final user = FirebaseAuth.instance.currentUser!;
  late final int agoraUid;
  int? activeSpeakerUid;
  Timer? _activeSpeakerResetTimer;

  @override
  void initState() {
    super.initState();
    agoraUid = user.uid.hashCode;
    participantId = DateTime.now().millisecondsSinceEpoch.toString();
    if (!widget.withVideo) {
      isMutedVideo = true;
    }
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
      onJoinChannelSuccess: (RtcConnection connection, int elapsed) async {
        setState(() => isJoined = true);
        await _addSelfToParticipants();
      },
      onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) async {
        setState(() => remoteUsers.add(remoteUid));

        DocumentSnapshot mappingDoc = await FirebaseFirestore.instance
            .collection('agoraUsers')
            .doc(remoteUid.toString())
            .get();

        if (mappingDoc.exists) {
          String firebaseUid = mappingDoc['firebaseUid'];

          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(firebaseUid)
              .get();

          if (userDoc.exists && userDoc['photoURL'] != null) {
            setState(() {
              remoteUserPhotos[remoteUid] = userDoc['photoURL'];
            });
          }
        }
      },
      onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
        setState(() => remoteUsers.remove(remoteUid));
      },
      onUserMuteVideo: (RtcConnection connection, int remoteUid, bool muted) {
        setState(() {
          remoteUserVideoMuted[remoteUid] = muted;
        });
      },
      onActiveSpeaker: (RtcConnection connection, int uid) {
        _activeSpeakerResetTimer?.cancel(); // cancel previous timer

        setState(() {
          activeSpeakerUid = uid;
        });

        // Set a timeout to clear the active speaker after 2 seconds
        _activeSpeakerResetTimer = Timer(Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              activeSpeakerUid = null;
            });
          }
        });
      },

    ));

    if (widget.withVideo) {
      await _engine?.enableVideo();
      await _engine?.startPreview();
      await _engine?.setupLocalVideo(
        VideoCanvas(uid: 0, renderMode: RenderModeType.renderModeHidden),
      );
    } else {
      await _engine?.disableVideo();
    }

    await _engine?.setClientRole(role: ClientRoleType.clientRoleBroadcaster);

    String agoraToken = await _fetchTokenFromFirestore();

    if (agoraToken.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: No valid Agora token!")));
      return;
    }

    await FirebaseFirestore.instance.collection('agoraUsers').doc(agoraUid.toString()).set({
      'firebaseUid': user.uid,
    });

    await _engine?.joinChannel(
      token: agoraToken,
      channelId: widget.channelName,
      uid: agoraUid,
      options: ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      ),
    );
  }

  Future<void> _addSelfToParticipants() async {
    await FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.channelName)
        .collection('participants')
        .doc(participantId)
        .set({'joinedAt': Timestamp.now()});
  }

  Future<void> _removeSelfAndCheckParticipants() async {
    final docRef = FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.channelName)
        .collection('participants')
        .doc(participantId);

    await docRef.delete();

    final snapshot = await FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.channelName)
        .collection('participants')
        .get();

    if (snapshot.docs.isEmpty) {
      await FirebaseFirestore.instance.collection('groups').doc(widget.channelName).update({
        'isCallActive': false,
        'callToken': null,
      });
    }
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
    _activeSpeakerResetTimer?.cancel();
    _engine?.leaveChannel();
    _engine?.release();
    _removeSelfAndCheckParticipants();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_engine == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(child: _buildDynamicVideoLayout()),
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
                      icon: Icon(
                        isMutedVideo ? Icons.videocam_off : Icons.videocam,
                        color: Colors.white,
                      ),
                      onPressed: () async {
                        setState(() {
                          isMutedVideo = !isMutedVideo;
                        });

                        if (!isMutedVideo) {
                          // If video is being turned ON
                          await _engine?.enableVideo();
                          await _engine?.setupLocalVideo(
                            VideoCanvas(uid: 0, renderMode: RenderModeType.renderModeHidden),
                          );
                        } else {
                          // If video is being turned OFF
                          await _engine?.disableVideo();
                        }
                      },
                    ),
                    IconButton(
                      icon: Icon(isMuted ? Icons.mic_off : Icons.mic, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          isMuted = !isMuted;
                        });
                        _engine?.muteLocalAudioStream(isMuted);
                      },
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
    List<Widget> tiles = [];

    tiles.add(_videoTile(
      isMutedVideo
          ? _profilePlaceholder(user.photoURL)
          : AgoraVideoView(
        controller: VideoViewController(
          rtcEngine: _engine!,
          canvas: VideoCanvas(uid: 0, renderMode: RenderModeType.renderModeHidden),
        ),
      ),
      isSpeaking: activeSpeakerUid == 0 && !isMuted,
    ));


    for (int uid in remoteUsers) {
      bool isMuted = remoteUserVideoMuted[uid] ?? false;

      tiles.add(_videoTile(
        isMuted
            ? _profilePlaceholder(remoteUserPhotos[uid])
            : AgoraVideoView(
          controller: VideoViewController.remote(
            rtcEngine: _engine!,
            canvas: VideoCanvas(uid: uid, renderMode: RenderModeType.renderModeHidden),
            connection: RtcConnection(channelId: widget.channelName),
          ),
        ),
        isSpeaking: activeSpeakerUid == uid && !isMuted,
      ));
    }


    int total = tiles.length;

    if (total == 1) return tiles[0];

    if (total == 2) {
      return Column(
        children: tiles.map((tile) => Expanded(child: tile)).toList(),
      );
    }

    if (total == 3) {
      return Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(child: tiles[0]),
                Expanded(child: tiles[1]),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.6,
                child: AspectRatio(
                  aspectRatio: 9 / 16,
                  child: tiles[2],
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (total == 5) {
      return Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(child: tiles[0]),
                Expanded(child: tiles[1]),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(child: tiles[2]),
                Expanded(child: tiles[3]),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.6,
                child: AspectRatio(
                  aspectRatio: 9 / 16,
                  child: tiles[4],
                ),
              ),
            ),
          ),
        ],
      );
    }

    int crossAxisCount = total <= 4 ? 2 : 3;
    return GridView.count(
      crossAxisCount: crossAxisCount,
      childAspectRatio: 9 / 16,
      physics: NeverScrollableScrollPhysics(),
      children: tiles,
    );
  }

  Widget _videoTile(Widget child, {bool isSpeaking = false}) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            border: isSpeaking ? Border.all(color: Colors.greenAccent, width: 3) : null,
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _profilePlaceholder(String? photoUrl) {
    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      child: CircleAvatar(
        radius: 40,
        backgroundImage: photoUrl != null
            ? NetworkImage(photoUrl)
            : AssetImage('assets/avatar_placeholder.png') as ImageProvider,
      ),
    );
  }
}