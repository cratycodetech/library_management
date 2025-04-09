import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:library_app/views/video/video_player_screen.dart';

import '../../routes/routes.dart';

class GridItem {
  final bool isLocked;
  GridItem({required this.isLocked});
}

class VideoChapterScreen extends StatefulWidget {
  const VideoChapterScreen({super.key});

  @override
  State<VideoChapterScreen> createState() => _VideoChapterScreenState();
}

class _VideoChapterScreenState extends State<VideoChapterScreen> {
  final List<GridItem> items = List.generate(
    12,
        (index) => GridItem(isLocked: index >= 2),
  );

  int selectedTabIndex = 1; // Chapter tab selected by default

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 80.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Video Banner
                Container(
                  height: 260.h,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: Center(
                    child: Container(
                      width: 60.w,
                      height: 40.h,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(Icons.play_arrow, color: Colors.white, size: 28.sp),
                    ),
                  ),
                ),

                SizedBox(height: 24.h),

                // Tabs
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _tab("About", 0),
                      _tab("Chapter", 1),
                      _tab("Reviews", 2),
                    ],
                  ),
                ),

                SizedBox(height: 24.h),

                // Chapter List
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return GestureDetector(
                        onTap: () {
                          if (item.isLocked) {
                            _showBuyBottomSheet(context);
                          } else {
                            Get.to(() => VideoPlayerScreen());
                          }
                        },

                        child: Padding(
                          padding: EdgeInsets.only(bottom: 16.h),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 60.w,
                                height: 60.w,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  //borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Center(
                                  child: Container(
                                    width: 24.w,
                                    height: 16.h,
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(4.r),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.play_arrow,
                                        color: Colors.white,
                                        size: 14.sp,
                                      ),
                                    ),
                                  ),
                                ),

                              ),
                              SizedBox(width: 50.w ),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 18.h),
                                    Container(height: 12.h, width: 150.w, color: Colors.grey[300]),
                                    SizedBox(height: 6.h),
                                    Container(height: 10.h, width: 100.w, color: Colors.grey[300]),
                                  ],
                                ),
                              ),

                              SizedBox(width: 20.w),
                              Container(
                                width: 32.w,
                                height: 32.w,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  item.isLocked ? Icons.lock_outline : Icons.play_arrow,
                                  size: 18.sp,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // App Bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 8.h,
            left: 16.w,
            right: 16.w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.arrow_back, color: Colors.black, size: 24.sp),
                Row(
                  children: [
                    Icon(Icons.share, color: Colors.black, size: 20.sp),
                    SizedBox(width: 16.w),
                    Icon(Icons.bookmark_border, color: Colors.black, size: 24.sp),
                  ],
                ),
              ],
            ),
          ),

          // Floating Buy Button (optional if you want permanent button too)

        ],
      ),
    );
  }

  Widget _tab(String title, int index) {
    final isSelected = selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTabIndex = index;
        });
        switch (index) {
          case 0:
            Get.toNamed(AppRoutes.videoDetailScreen);
            break;
          case 1:
            break;
          case 2:
          // Get.toNamed(AppRoutes.pdfReviewScreen);
            break;
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8.w),
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.grey[300],
          borderRadius: BorderRadius.circular(32.r),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _showBuyBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Color(0xFFD9D9D9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              "Client will provide the \ntext later",
              style: TextStyle(fontSize: 14.sp, color: Colors.black),
            ),
            Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 12.h),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Buy Now", style: TextStyle(fontSize: 14.sp, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
