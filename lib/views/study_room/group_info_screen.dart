import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:library_app/views/study_room/view_banned_member_screen.dart';
import 'package:library_app/views/study_room/view_member_screen.dart';

class GroupInfoScreen extends StatefulWidget {
  const GroupInfoScreen({super.key});

  @override
  State<GroupInfoScreen> createState() => _GroupInfoScreenState();
}

class _GroupInfoScreenState extends State<GroupInfoScreen> {
  @override
  Widget build(BuildContext context) {
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
              child: Icon(Icons.image, color: Colors.black, size: 16.sp),
            ),
            SizedBox(width: 8.w),
            Text(
              'Group Info',
              style: TextStyle(color: Colors.white, fontSize: 16.sp),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 24.h),
          CircleAvatar(
            radius: 50.r,
            backgroundColor: Colors.grey.shade300,
            child: Icon(Icons.image, size: 40.sp, color: Colors.black),
          ),
          SizedBox(height: 16.h),
          Container(
            height: 10.h,
            width: 180.w,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(5.r),
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            height: 8.h,
            width: 100.w,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(5.r),
            ),
          ),
          SizedBox(height: 24.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMemberOption(Icons.person_add, 'Add Members'),
                GestureDetector(
                  onTap: () {
                    Get.to(() => const ViewMemberScreen());
                  },
                  child: _buildMemberOption(Icons.group, 'View Members'),
                ),
                GestureDetector(
                    onTap: () {
                      Get.to(() => const ViewBannedMemberScreen());
                    },
                    child: _buildMemberOption(Icons.block, 'Banned Members')),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          Divider(height: 1.h, thickness: 1, color: Colors.grey.shade300),
          ListTile(
            leading: Icon(Icons.remove_circle, color: Colors.red, size: 24.sp),
            title: Text('Leave',
                style: TextStyle(color: Colors.red, fontSize: 14.sp)),
            onTap: () {
              // handle leave
            },
          ),
          ListTile(
            leading: Icon(Icons.delete, color: Colors.red, size: 24.sp),
            title: Text('Delete and Exit',
                style: TextStyle(color: Colors.red, fontSize: 14.sp)),
            onTap: () {
              // handle delete and exit
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
