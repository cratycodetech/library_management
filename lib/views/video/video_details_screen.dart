import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../routes/routes.dart';
import '../Pdf/pdf_tab.dart';

class VideoDetailsScreen extends StatefulWidget {
  const VideoDetailsScreen({super.key});

  @override
  State<VideoDetailsScreen> createState() => _VideoDetailsScreenState();
}

class _VideoDetailsScreenState extends State<VideoDetailsScreen> {
  final List<GridItem> items = List.generate(
    12,
        (index) => GridItem(isLocked: index % 4 == 0),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Video Container with Play Button
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
                      child: Center(
                        child: Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 28.sp,
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 24.h),

                // Tabs
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _tab("About", 0, isSelected: true),
                      _tab("Chapter", 1),
                      _tab("Reviews", 2),
                    ],
                  ),
                ),

                SizedBox(height: 16.h),

                // Description
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Text(
                    "Creative thinking opens new possibilities. Simple ideas can have profound impacts. Each project teaches valuable lessons. Understanding users leads to better solutions. The best solutions often come from collaboration.",
                    style: TextStyle(height: 1.5, fontSize: 14.sp),
                  ),
                ),

                SizedBox(height: 24.h),

                // Author Info
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24.r,
                        backgroundColor: Colors.grey[400],
                        child: Icon(Icons.person, color: Colors.white, size: 24.sp),
                      ),
                      SizedBox(width: 12.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(height: 10.h, width: 100.w, color: Colors.grey[300]),
                          SizedBox(height: 6.h),
                          Container(height: 8.h, width: 80.w, color: Colors.grey[300]),
                        ],
                      )
                    ],
                  ),
                ),

                SizedBox(height: 24.h),
                Divider(
                  thickness: 1,
                  color: Colors.grey[300],
                  indent: 16.w,
                  endIndent: 16.w,
                ),

                SizedBox(height: 16.h),

                // Section title placeholder
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Container(
                    height: 12.h,
                    width: 140.w,
                    color: Colors.grey[300],
                  ),
                ),

                SizedBox(height: 16.h),

                // Grid
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12.w,
                      mainAxisSpacing: 16.h,
                      childAspectRatio: 0.7,
                    ),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return GestureDetector(
                        onTap: () {
                          if (item.isLocked) {
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
                                      "Clint will provide the \ntext later",
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
                          } else {
                            // Handle unlocked video tap (e.g. play video)
                          }
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                Container(
                                  height: 123.h,
                                  width: double.infinity,
                                  color: Colors.grey[300],
                                  child: Center(
                                    child: Container(
                                      width: 32.w,
                                      height: 20.h,
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.circular(6.r),
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
                                if (item.isLocked)
                                  Positioned(
                                    top: 6.h,
                                    right: 6.w,
                                    child: Icon(
                                      Icons.lock_outline,
                                      size: 16.sp,
                                      color: Colors.grey,
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(height: 8.h),
                            Container(height: 10.h, width: 60.w, color: Colors.grey[400]),
                            SizedBox(height: 6.h),
                            Container(height: 8.h, width: 40.w, color: Colors.grey[300]),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                SizedBox(height: 40.h),
              ],
            ),
          ),

          // Custom AppBar floating above video
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
        ],
      ),
    );
  }

  Widget _tab(String title, int index, {bool isSelected = false}) {
    return GestureDetector(
      onTap: () {
        switch (index) {
          case 0:
            Get.toNamed(AppRoutes.videoDetailScreen);
            break;
          case 1:
            Get.toNamed(AppRoutes.videoChapterScreen);
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
}

