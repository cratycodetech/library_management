import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:library_app/views/study_room/widgets/main_scaffold.dart';

class AllRoomsScreen extends StatelessWidget {
  const AllRoomsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MainScaffold(
          currentIndex: 3, // Active: All Rooms
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: Center(
              child: Text(
                'Community',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            actions: const [
              Padding(
                padding: EdgeInsets.only(right: 16),
                child: Icon(Icons.search, color: Colors.black),
              )
            ],
            elevation: 0,
          ),
          body: ListView.builder(
            padding: EdgeInsets.only(bottom: 100.h),
            itemCount: 10,
            itemBuilder: (context, index) {
              final bool isActive = index % 2 == 0;

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  padding: EdgeInsets.all(12.r),
                  child: Stack(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 24.r,
                            backgroundColor: Colors.black12,
                            child: Icon(Icons.person, size: 26.sp, color: Colors.black),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 12.h,
                                  width: 180.w,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade400,
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Container(
                                  height: 10.h,
                                  width: 120.w,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade400,
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        top: 4.h,
                        right: 4.w,
                        child: Container(
                          width: 10.w,
                          height: 10.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isActive ? Colors.black : Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Floating button (shown only here)
        Positioned(
          bottom: 80.h,
          right: 20.w,
          child: FloatingActionButton(
            onPressed: () {
              // Add new room
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
