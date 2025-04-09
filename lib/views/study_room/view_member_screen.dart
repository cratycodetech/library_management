import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ViewMemberScreen extends StatefulWidget {
  const ViewMemberScreen({super.key});

  @override
  State<ViewMemberScreen> createState() => _ViewMemberScreenState();
}

class _ViewMemberScreenState extends State<ViewMemberScreen> {
  final List<Map<String, String>> members = [
    {"role": "Owner"},
    {"role": "Admin"},
    {"role": "Moderator"},
    {"role": ""},
    {"role": ""},
    {"role": ""},
    {"role": ""},
    {"role": ""},
  ];

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
        title: Text('Members', style: TextStyle(color: Colors.black, fontSize: 16.sp)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.black, size: 24.sp),
            onPressed: () {
              // handle search
            },
          ),
        ],
      ),
      body: ListView.separated(
        itemCount: members.length,
        separatorBuilder: (_, __) => Divider(height: 1.h, color: Colors.grey.shade300),
        itemBuilder: (context, index) {
          final member = members[index];
          final role = member["role"] ?? "";
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20.r,
                  backgroundColor: Colors.black,
                  child: Icon(Icons.person, color: Colors.white, size: 20.sp),
                ),
                SizedBox(width: 12.w),
                Container(
                  width: 180.w,
                  height: 10.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                const Spacer(),
                if (role.isNotEmpty) _buildRoleChip(role),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRoleChip(String role) {
    bool isOwner = role == "Owner";
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: isOwner ? Colors.black : Colors.white,
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        role,
        style: TextStyle(
          color: isOwner ? Colors.white : Colors.black,
          fontSize: 12.sp,
        ),
      ),
    );
  }
}
