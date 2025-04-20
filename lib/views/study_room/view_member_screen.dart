import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ViewMemberScreen extends StatefulWidget {
  final String groupId;

  const ViewMemberScreen({Key? key, required this.groupId}) : super(key: key);

  @override
  State<ViewMemberScreen> createState() => _ViewMemberScreenState();
}

class _ViewMemberScreenState extends State<ViewMemberScreen> {
  List<Map<String, dynamic>> memberDetails = [];
  List<Map<String, dynamic>> filteredMembers = [];
  bool isLoading = true;
  bool isSearching = false;
  String? adminId;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    try {
      final groupDoc = await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .get();

      final List<dynamic> uidsRaw = groupDoc['members'] ?? [];
      adminId = groupDoc['adminId']?.toString();
      final Set<String> uids = {...uidsRaw.map((e) => e.toString())};

      List<Map<String, dynamic>> loadedMembers = [];

      for (final uid in uids) {
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
        if (userDoc.exists) {
          loadedMembers.add({
            'uid': uid,
            'name': userDoc['name'] ?? 'Unknown',
            'photoURL': userDoc['photoURL'] ?? '',
            'isAdmin': uid == adminId,
          });
        }
      }

      // Admin always at the top
      loadedMembers.sort((a, b) => b['isAdmin'].toString().compareTo(a['isAdmin'].toString()));

      setState(() {
        memberDetails = loadedMembers;
        filteredMembers = loadedMembers;
        isLoading = false;
      });
    } catch (e) {
      print("❌ Error loading members: $e");
    }
  }

  void _toggleSearch() {
    setState(() {
      isSearching = !isSearching;
      _searchController.clear();
      filteredMembers = memberDetails;
    });
  }

  void _filterMembers(String text) {
    final lower = text.toLowerCase();
    final filtered = memberDetails
        .where((m) => m['name'].toLowerCase().contains(lower))
        .toList();

    filtered.sort((a, b) => b['isAdmin'].toString().compareTo(a['isAdmin'].toString()));

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
            ? Text('Members', style: TextStyle(color: Colors.black, fontSize: 16.sp))
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
        separatorBuilder: (_, __) => Divider(height: 1.h, color: Colors.grey.shade300),
        itemBuilder: (context, index) {
          final member = filteredMembers[index];
          final String name = member['name'];
          final String photoURL = member['photoURL'];
          final bool isAdmin = member['isAdmin'];

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20.r,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage: (photoURL.isNotEmpty) ? NetworkImage(photoURL) : null,
                  child: (photoURL.isEmpty)
                      ? Icon(Icons.person, color: Colors.black, size: 20.sp)
                      : null,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    name,
                    style: TextStyle(fontSize: 14.sp),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: isAdmin ? Colors.black : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    isAdmin ? 'Owner' : 'Member',
                    style: TextStyle(
                      color: isAdmin ? Colors.white : Colors.black,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
