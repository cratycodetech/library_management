import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:library_app/views/study_room/view_banned_member_screen.dart';
import 'package:library_app/views/study_room/view_member_screen.dart';

import '../../routes/routes.dart';
import '../../services/file_upload_service.dart';
import 'add_member_screen.dart';

class GroupInfoScreen extends StatefulWidget {
  final String groupId;

  const GroupInfoScreen({Key? key, required this.groupId}) : super(key: key);

  @override
  State<GroupInfoScreen> createState() => _GroupInfoScreenState();
}

class _GroupInfoScreenState extends State<GroupInfoScreen> {
  String groupName = '';
  String? groupPhotoUrl;
  String? adminId;
  String? currentUserId;
  String? groupType;


  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser?.uid;
    _fetchGroupInfo();
  }

  Future<void> _fetchGroupInfo() async {
    final doc = await FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .get();

    if (doc.exists) {
      setState(() {
        groupName = doc['name'] ?? 'Group Info';
        groupPhotoUrl = doc.data()?['groupPhotoUrl'];
        adminId = doc['adminId'];
        groupType = doc.data()?['type'] ?? 'private';
      });
    }
  }


  Future<void> _deleteGroup() async {
    await FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .delete();

    Get.offAllNamed(AppRoutes.libraryHomeScreen);
    Get.snackbar("Group Deleted", "The group has been permanently deleted.");
  }

  Future<void> _leaveGroup() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .update({
      'members': FieldValue.arrayRemove([user.uid])
    });

    Get.toNamed(AppRoutes.libraryHomeScreen);
    Get.snackbar("Left Group", "You have successfully left the group");
  }

  Future<void> _handleGroupPhotoChange() async {
    FileUploadService uploadService = FileUploadService();

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null && result.files.single.path != null) {
      File selectedFile = File(result.files.single.path!);

      String? photoUrl = await uploadService.uploadFile(widget.groupId, selectedFile);

      if (photoUrl != null) {
        await FirebaseFirestore.instance
            .collection('groups')
            .doc(widget.groupId)
            .update({'groupPhotoUrl': photoUrl});

        setState(() {
          groupPhotoUrl = photoUrl;
        });

        Get.snackbar("Photo Updated", "Group photo updated successfully.");
      } else {
        Get.snackbar("Error", "Failed to upload group photo.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = currentUserId == adminId;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 24.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 14.r,
              backgroundColor: Colors.white,
              backgroundImage: (groupPhotoUrl != null && groupPhotoUrl!.isNotEmpty)
                  ? NetworkImage(groupPhotoUrl!)
                  : null,
              child: (groupPhotoUrl == null || groupPhotoUrl!.isEmpty)
                  ? Icon(Icons.image, color: Colors.black, size: 16.sp)
                  : null,
            ),
            SizedBox(width: 8.w),
            Text('Group Info', style: TextStyle(color: Colors.white, fontSize: 16.sp)),
          ],
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 24.h),
          GestureDetector(
            onTap: _handleGroupPhotoChange,
            child: CircleAvatar(
              radius: 50.r,
              backgroundColor: Colors.grey.shade300,
              backgroundImage:
              (groupPhotoUrl != null && groupPhotoUrl!.isNotEmpty)
                  ? NetworkImage(groupPhotoUrl!)
                  : null,
              child: (groupPhotoUrl == null || groupPhotoUrl!.isEmpty)
                  ? Icon(Icons.image, size: 40.sp, color: Colors.black)
                  : null,
            ),
          ),
          SizedBox(height: 16.h),
          Text(groupName, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 8.h),

          SizedBox(height: 24.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: (isAdmin || groupType == 'public')
                      ? () => Get.to(() => AddMemberScreen(groupId: widget.groupId))
                      : null,
                  child: Opacity(
                    opacity: (isAdmin || groupType == 'public') ? 1.0 : 0.4,
                    child: _buildMemberOption(Icons.person_add, 'Add Members'),
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.to(() => ViewMemberScreen(groupId: widget.groupId)),
                  child: _buildMemberOption(Icons.group, 'View Members'),
                ),
                GestureDetector(
                  onTap: isAdmin ? () => Get.to(() => ViewBannedMemberScreen(groupId: widget.groupId)) : null,
                  child: Opacity(
                    opacity: isAdmin ? 1.0 : 0.4,
                    child: _buildMemberOption(Icons.block, 'Ban Members'),
                  ),
                ),

              ],
            ),
          ),
          SizedBox(height: 24.h),
          Divider(height: 1.h, thickness: 1, color: Colors.grey.shade300),

          ListTile(
            leading: Icon(Icons.remove_circle, color: Colors.red, size: 24.sp),
            title: Text('Leave', style: TextStyle(color: Colors.red, fontSize: 14.sp)),
            onTap: _leaveGroup,
          ),

          if (isAdmin)
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red, size: 24.sp),
              title: Text('Delete and Exit', style: TextStyle(color: Colors.red, fontSize: 14.sp)),
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Confirm Delete"),
                    content: const Text("Are you sure you want to delete this group permanently?"),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
                      TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete")),
                    ],
                  ),
                );
                if (confirm == true) _deleteGroup();
              },
            ),
        ],
      ),
    );
  }

  Widget _buildMemberOption(IconData icon, String label) {
    return Container(
      width: 110.w,
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 2.h),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 20.r,
            backgroundColor: Colors.grey.shade300,
            child: Icon(icon, color: Colors.grey.shade600, size: 20.sp),
          ),
          SizedBox(height: 8.h),
          Text(label, style: TextStyle(fontSize: 12.sp)),
        ],
      ),
    );
  }
}
