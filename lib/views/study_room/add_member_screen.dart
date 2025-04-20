import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddMemberScreen extends StatefulWidget {
  final String groupId;

  const AddMemberScreen({Key? key, required this.groupId}) : super(key: key);

  @override
  State<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen> {
  List<Map<String, dynamic>> allUsers = [];
  List<Map<String, dynamic>> filteredUsers = [];
  Set<String> selectedUserIds = {};
  final TextEditingController _searchController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNonMemberUsers();
  }

  Future<void> _loadNonMemberUsers() async {
    try {
      final groupDoc = await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .get();

      final List<dynamic> memberIds = groupDoc['members'] ?? [];

      final usersSnapshot =
      await FirebaseFirestore.instance.collection('users').get();

      allUsers = usersSnapshot.docs
          .where((doc) => !memberIds.contains(doc.id))
          .map((doc) {
        final data = doc.data();
        return {
          'uid': doc.id,
          'name': data['name'] ?? '',
          'photoURL': data['photoURL'] ?? '',
        };
      }).toList();

      setState(() {
        filteredUsers = allUsers;
        isLoading = false;
      });
    } catch (e) {
      print("Error loading users: $e");
    }
  }

  void _filter(String text) {
    final query = text.toLowerCase();
    setState(() {
      filteredUsers = allUsers
          .where((user) => user['name'].toLowerCase().contains(query))
          .toList();
    });
  }

  void _toggleSelection(String uid) {
    setState(() {
      if (selectedUserIds.contains(uid)) {
        selectedUserIds.remove(uid);
      } else {
        selectedUserIds.add(uid);
      }
    });
  }

  Future<void> _addSelectedMembers() async {
    if (selectedUserIds.isEmpty) return;
    await FirebaseFirestore.instance.collection('groups').doc(widget.groupId).update({
      'members': FieldValue.arrayUnion(selectedUserIds.toList()),
    });
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${selectedUserIds.length} member(s) added')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.4,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Add people', style: TextStyle(color: Colors.black, fontSize: 16.sp)),
        actions: [
          TextButton(
            onPressed: _addSelectedMembers,
            child: Text("Add", style: TextStyle(fontSize: 14.sp, color: Colors.blue)),
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12.w),
            child: TextField(
              controller: _searchController,
              onChanged: _filter,
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.r),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Suggested', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500)),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredUsers.length,
              itemBuilder: (_, index) {
                final user = filteredUsers[index];
                final isSelected = selectedUserIds.contains(user['uid']);

                return ListTile(
                  leading: CircleAvatar(
                    radius: 20.r,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: user['photoURL'].isNotEmpty ? NetworkImage(user['photoURL']) : null,
                    child: user['photoURL'].isEmpty
                        ? Icon(Icons.person, size: 20.sp, color: Colors.black)
                        : null,
                  ),
                  title: Text(user['name'], style: TextStyle(fontSize: 14.sp)),
                  trailing: Icon(
                    isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: isSelected ? Colors.blue : Colors.grey,
                  ),
                  onTap: () => _toggleSelection(user['uid']),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
