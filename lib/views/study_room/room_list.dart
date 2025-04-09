import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:library_app/views/study_room/widgets/main_scaffold.dart';

import 'group_chat_screen.dart';

class RoomListView extends StatelessWidget {
  const RoomListView({super.key});

  @override
  Widget build(BuildContext context) {


    return Stack(
      children: [
        MainScaffold(
          currentIndex: 1,
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Center(
              child: Text(
                'Study Room',
                style: TextStyle(
                  fontSize: 16, // 👈 Reduce this as needed
                  color: Colors.black,
                ),
              ),
            ),

            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              Padding(
                padding: EdgeInsets.only(right: 16.w),
                child: const Icon(Icons.search),
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
                    isSelected: const [true, false],
                    borderRadius: BorderRadius.circular(10.r),
                    selectedColor: Colors.white,
                    fillColor: Colors.black,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        child: Text('Private Room', style: TextStyle(fontSize: 14.sp)),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        child: Text('Public Room', style: TextStyle(fontSize: 14.sp)),
                      ),
                    ],
                    onPressed: (index) {
                      // TODO: handle toggle
                    },
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Expanded(
                child: ListView(
                  children: List.generate(5, (index) {
                    final String subtitle = switch (index) {
                      0 => "Lorem ipsum dolor sit amet...",
                      1 => "📹 Video",
                      2 => "🖼️ Photo Lorem ipsum dolor sit am...",
                      3 => "🎧 Audio",
                      4 => "💬 Sticker",
                      _ => ""
                    };

                    final String? badge = switch (index) {
                      1 => "18",
                      3 => "2",
                      _ => null
                    };

                    final bool showSeenIcon = index != 0; // ✅ define it here however you want

                    return GestureDetector(
                      onTap: () {
                        Get.to(() => GroupChatScreen());
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
                              // Profile Avatar
                              CircleAvatar(
                                radius: 20.r,
                                child: const Icon(Icons.person),
                              ),
                              SizedBox(width: 12.w),

                              // Name + Message Column
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Row 1: Name and Time
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Sample Name",
                                          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
                                        ),
                                        Text(
                                          "4:30 PM",
                                          style: TextStyle(fontSize: 12.sp, color: Colors.grey[700]),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4.h),

                                    // Row 2: Seen Icon + Message + Badge (if any)
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        if (showSeenIcon)
                                          Padding(
                                            padding: EdgeInsets.only(right: 4.w),
                                            child: Icon(
                                              Icons.check,
                                              size: 14.sp,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        // Message subtitle
                                        Expanded(
                                          child: Text(
                                            subtitle,
                                            style: TextStyle(fontSize: 13.sp, color: Colors.black87),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),

                                        // Message Count Badge (Right side, 2nd row)
                                        if (badge != null)
                                          Container(
                                            margin: EdgeInsets.only(left: 8.w),
                                            padding: EdgeInsets.all(6.r),
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.black,
                                            ),
                                            child: Text(
                                              badge,
                                              style: TextStyle(color: Colors.white, fontSize: 12.sp),
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

                  })

                ),
              ),
            ],
          ),
        ),

        // Floating Action Button (elevated and circular)
        Positioned(
          bottom: 80.h,
          right: 20.w,
          child: FloatingActionButton(
            onPressed: () {
              // Create new room
            },
            backgroundColor: Colors.black,
            shape: const CircleBorder(),
            child: Icon(
              Icons.add,
              color: Colors.white,
              size: 24.sp,
            ),
          ),
        ),
      ],
    );
  }
}
