import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:library_app/views/study_room/widgets/main_scaffold.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MainScaffold(
          currentIndex: 2,
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
              final String subtitle = switch (index % 5) {
                0 => "📹 Video",
                1 => "🖼️ Photo Lorem ipsum dolor sit am...",
                2 => "🎧 Audio",
                3 => "💬 Sticker",
                _ => "🖼️ Photo Lorem ipsum dolor sit am..."
              };

              final String? badge = [0, 3, 5, 8].contains(index) ? "18" : (index == 4 ? "2" : null);
              final bool showSeen = index % 2 == 1;

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 22.r,
                          backgroundColor: Colors.black12,
                          child: Icon(Icons.person, size: 24.sp, color: Colors.black),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Sample Name",
                                    style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    "4:30 PM",
                                    style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4.h),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  if (showSeen)
                                    Padding(
                                      padding: EdgeInsets.only(right: 4.w),
                                      child: Icon(
                                        Icons.check,
                                        size: 14.sp,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  Expanded(
                                    child: Text(
                                      subtitle,
                                      style: TextStyle(fontSize: 13.sp),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
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
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    Divider(height: 24.h, thickness: 0.6, color: Colors.grey[300]),
                  ],
                ),
              );
            },
          ),
        ),

        // ✅ FAB only for this screen
        Positioned(
          bottom: 80.h,
          right: 20.w,
          child: FloatingActionButton(
            onPressed: () {
              // action
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
