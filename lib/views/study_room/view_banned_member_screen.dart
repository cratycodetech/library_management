import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ViewBannedMemberScreen extends StatefulWidget {
  final String groupId;

  const ViewBannedMemberScreen({super.key, required this.groupId});

  @override
  State<ViewBannedMemberScreen> createState() => _ViewBannedMemberScreenState();
}

class _ViewBannedMemberScreenState extends State<ViewBannedMemberScreen> {
  List<Map<String, dynamic>> members = [];
  List<Map<String, dynamic>> filteredMembers = [];
  final TextEditingController _searchController = TextEditingController();
  bool isSearching = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMembers();
  }

  Future<void> fetchMembers() async {
    try {
      final groupDoc = await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .get();

      final memberIds = List<String>.from(groupDoc['members'] ?? []);

      final usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where(FieldPath.documentId, whereIn: memberIds)
          .get();

      final loaded = usersSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'uid': doc.id,
          'name': data['name'] ?? '',
          'photoURL': data['photoURL'] ?? '',
        };
      }).toList();

      setState(() {
        members = loaded;
        filteredMembers = loaded;
        isLoading = false;
      });
    } catch (e) {
      print('❌ Error fetching members: $e');
    }
  }

  Future<void> removeMember(String uid) async {
    await FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .update({
      'members': FieldValue.arrayRemove([uid])
    });

    setState(() {
      members.removeWhere((member) => member['uid'] == uid);
      filteredMembers.removeWhere((member) => member['uid'] == uid);
    });
  }

  void _toggleSearch() {
    setState(() {
      isSearching = !isSearching;
      _searchController.clear();
      filteredMembers = members;
    });
  }

  void _filterMembers(String query) {
    final lower = query.toLowerCase();
    final filtered = members.where((m) => m['name'].toLowerCase().contains(lower)).toList();
    setState(() {
      filteredMembers = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black, size: 24.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: !isSearching
            ? Text('Ban Members',
            style: TextStyle(color: Colors.black, fontSize: 16.sp))
            : TextField(
          controller: _searchController,
          onChanged: _filterMembers,
          autofocus: true,
          style: TextStyle(fontSize: 14.sp),
          decoration: InputDecoration(
            hintText: "Search members...",
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              isSearching ? Icons.close : Icons.search,
              color: Colors.black,
              size: 24.sp,
            ),
            onPressed: _toggleSearch,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
        itemCount: filteredMembers.length,
        separatorBuilder: (_, __) =>
            Divider(height: 1.h, color: Colors.grey.shade300),
        itemBuilder: (context, index) {
          final member = filteredMembers[index];
          return Padding(
            padding:
            EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20.r,
                  backgroundImage: member['photoURL'] != ''
                      ? NetworkImage(member['photoURL'])
                      : null,
                  backgroundColor: Colors.black,
                  child: member['photoURL'] == ''
                      ? Icon(Icons.person,
                      color: Colors.white, size: 20.sp)
                      : null,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    member['name'],
                    style: TextStyle(fontSize: 14.sp),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close,
                      color: Colors.black, size: 20.sp),
                  onPressed: () => removeMember(member['uid']),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
