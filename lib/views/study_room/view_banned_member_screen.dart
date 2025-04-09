import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ViewBannedMemberScreen extends StatefulWidget {
  const ViewBannedMemberScreen({super.key});

  @override
  State<ViewBannedMemberScreen> createState() => _ViewBannedMemberScreenState();
}

class _ViewBannedMemberScreenState extends State<ViewBannedMemberScreen> {
  final List<String> bannedUsers = List.generate(6, (index) => 'User $index');

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
        title: Text('Banned Members', style: TextStyle(color: Colors.black, fontSize: 16.sp)),
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
        itemCount: bannedUsers.length,
        separatorBuilder: (_, __) => Divider(height: 1.h, color: Colors.grey.shade300),
        itemBuilder: (context, index) {
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
                  width: 200.w,
                  height: 10.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.black, size: 20.sp),
                  onPressed: () {
                    // handle unban
                    setState(() {
                      bannedUsers.removeAt(index);
                    });
                  },
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
