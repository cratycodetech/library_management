import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:library_app/controllers/auth_controller.dart';
import 'package:library_app/routes/routes.dart';
import 'package:library_app/views/study_room/widgets/main_scaffold.dart';

class RoomListView extends StatefulWidget {
  const RoomListView({super.key});

  @override
  State<RoomListView> createState() => _RoomListViewState();
}

class _RoomListViewState extends State<RoomListView> {
  final AuthController authController = Get.find();
  final TextEditingController _searchController = TextEditingController();

  String get userId => authController.userModel.value?.uid ?? "";
  bool isSearching = false;
  List<DocumentSnapshot> allGroups = [];
  List<DocumentSnapshot> filteredGroups = [];
  int selectedToggleIndex = 0; // 0 = Private, 1 = Public


  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterGroups);
  }

  void _toggleSearch() {
    setState(() {
      isSearching = !isSearching;
      _searchController.clear();
      filteredGroups = allGroups;
    });
  }

  void _filterGroups() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredGroups = allGroups.where((group) {
        final groupData = group.data() as Map<String, dynamic>;
        final name = groupData['name']?.toString().toLowerCase() ?? '';
        final type = groupData['type']?.toString().toLowerCase() ?? 'private';

        final matchesSearch = name.contains(query);
        final matchesType = selectedToggleIndex == 0
            ? type == 'private'
            : type == 'public';

        return matchesSearch && matchesType;
      }).toList();
    });
  }


  String _formatTimestamp(dynamic timestamp) {
    try {
      if (timestamp is Timestamp) {
        return DateFormat.jm().format(timestamp.toDate());
      }
    } catch (_) {}
    return '';
  }

  Future<Map<String, dynamic>> _getLastMessage(String groupId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final msg = snapshot.docs.first;
      final fileType = msg['fileType'];
      final text = msg['text'];

      if (fileType == 'm4a') return {'text': '\u{1F399} Audio', 'time': _formatTimestamp(msg['timestamp'])};
      if (fileType == 'pdf') return {'text': '\u{1F4D1} PDF', 'time': _formatTimestamp(msg['timestamp'])};
      if (['jpg', 'jpeg', 'png'].contains(fileType)) return {'text': '\u{1F5BC} Photo ${text ?? ''}', 'time': _formatTimestamp(msg['timestamp'])};
      if (fileType == 'mp4') return {'text': '\u{1F4FD} Video', 'time': _formatTimestamp(msg['timestamp'])};

      return {
        'text': text ?? '',
        'time': _formatTimestamp(msg['timestamp'])
      };
    }
    return {'text': 'No messages yet', 'time': ''};
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MainScaffold(
          currentIndex: 1,
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: isSearching
                ? TextField(
              controller: _searchController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Search Rooms...',
                border: InputBorder.none,
              ),
              style: const TextStyle(color: Colors.black),
            )
                : const Center(
              child: Text('Study Room',
                  style: TextStyle(fontSize: 16, color: Colors.black)),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                if (isSearching) {
                  _toggleSearch();
                } else {
                  Navigator.pop(context);
                }
              },
            ),
            actions: [
              IconButton(
                icon: Icon(isSearching ? Icons.close : Icons.search),
                onPressed: _toggleSearch,
              ),
            ],
          ),
          body: Column(
            children: [
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ToggleButtons(
                    isSelected: [selectedToggleIndex == 0, selectedToggleIndex == 1],
                    borderRadius: BorderRadius.circular(10.r),
                    selectedColor: Colors.white,
                    color: Colors.black,
                    fillColor: Colors.black,
                    borderColor: Colors.black,
                    selectedBorderColor: Colors.black,
                    constraints: BoxConstraints(minHeight: 40.h, minWidth: 140.w),
                    children: [
                      Container(
                        alignment: Alignment.center,
                        child: Text(
                          'Private Room',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: selectedToggleIndex == 0 ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.center,
                        child: Text(
                          'Public Room',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: selectedToggleIndex == 1 ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ],
                    onPressed: (index) {
                      setState(() {
                        selectedToggleIndex = index;
                        _filterGroups();
                      });
                    },
                  )

                ],
              ),
              SizedBox(height: 16.h),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('groups')
                      .where('members', arrayContains: userId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text("No rooms found"));
                    }

                    allGroups = snapshot.data!.docs; // ✅ Fix: Populate allGroups from stream

                    filteredGroups = allGroups.where((doc) {
                      final groupData = doc.data() as Map<String, dynamic>;
                      final name = groupData['name']?.toString().toLowerCase() ?? '';
                      final type = groupData['type']?.toString().toLowerCase() ?? 'private';

                      final matchesSearch = isSearching
                          ? name.contains(_searchController.text.toLowerCase())
                          : true;

                      final matchesType = selectedToggleIndex == 0
                          ? type == 'private'
                          : type == 'public';

                      return matchesSearch && matchesType;
                    }).toList();

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text("No rooms found"));
                    }



                    return ListView.builder(
                      itemCount: filteredGroups.length,
                      itemBuilder: (context, index) {
                        final group = filteredGroups[index];
                        final groupData = group.data() as Map<String, dynamic>;
                        final String groupId = group.id;
                        final String groupName = groupData['name'] ?? 'Unnamed Group';
                        final String? badge = groupData.containsKey('unreadCount') ? groupData['unreadCount'].toString() : null;

                        return FutureBuilder<int>(
                          future: FirebaseFirestore.instance
                              .collection('groups')
                              .doc(groupId)
                              .collection('messages')
                              .where('unread.$userId', isEqualTo: true)
                              .count()
                              .get()
                              .then((res) => res.count ?? 0),
                          builder: (context, unreadSnap) {
                            final unreadCount = unreadSnap.data ?? 0;

                            return FutureBuilder<Map<String, dynamic>>(
                              future: _getLastMessage(groupId),
                              builder: (context, messageSnap) {
                                final subtitle = messageSnap.data?['text'] ?? 'Loading...';
                                final time = messageSnap.data?['time'] ?? '';
                                final bool hasPhoto = groupData.containsKey('groupPhotoUrl') &&
                                    groupData['groupPhotoUrl'] != null &&
                                    groupData['groupPhotoUrl'].toString().isNotEmpty;

                                return GestureDetector(
                                  onTap: () {
                                    Get.toNamed(AppRoutes.groupChat, arguments: {
                                      'groupId': groupId,
                                      'groupName': groupName,
                                    })?.then((_) {
                                      setState(() {});
                                    });
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(12.r),
                                      ),
                                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          CircleAvatar(
                                            radius: 20.r,
                                            backgroundColor: Colors.grey.shade300,
                                            backgroundImage: hasPhoto
                                                ? NetworkImage(groupData['groupPhotoUrl'])
                                                : null,
                                            child: !hasPhoto
                                                ? const Icon(Icons.group, color: Colors.black)
                                                : null,
                                          ),
                                          SizedBox(width: 12.w),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(groupName,
                                                        style: TextStyle(
                                                            fontSize: 15.sp,
                                                            fontWeight: FontWeight.w600)),
                                                    Text(time,
                                                        style: TextStyle(
                                                            fontSize: 12.sp, color: Colors.grey[700])),
                                                  ],
                                                ),
                                                SizedBox(height: 4.h),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        subtitle,
                                                        style: TextStyle(
                                                            fontSize: 13.sp, color: Colors.black87),
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                    if (unreadCount > 0)
                                                      Container(
                                                        margin: EdgeInsets.only(left: 8.w),
                                                        padding: EdgeInsets.all(6.r),
                                                        decoration: const BoxDecoration(
                                                          shape: BoxShape.circle,
                                                          color: Colors.black,
                                                        ),
                                                        child: Text(
                                                          unreadCount.toString(),
                                                          style: TextStyle(
                                                              color: Colors.white, fontSize: 12.sp),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );

                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 80.h,
          right: 20.w,
          child: FloatingActionButton(
            onPressed: () {
              Get.toNamed(AppRoutes.createGroup);
            },
            backgroundColor: Colors.black,
            shape: const CircleBorder(),
            child: Icon(Icons.add, color: Colors.white, size: 24.sp),
          ),
        ),
      ],
    );
  }
}