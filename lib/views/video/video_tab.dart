import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:library_app/views/video/video_details_screen.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class GridItem {
  final bool isLocked;

  GridItem({required this.isLocked});
}

class VideoTab extends StatefulWidget {
  const VideoTab({super.key});

  @override
  State<VideoTab> createState() => _VideoTabState();
}

class _VideoTabState extends State<VideoTab> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 3;
  final List<GridItem> items = List.generate(12, (index) => GridItem(isLocked: index % 4 == 0));


  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) return;
      _currentPage = (_currentPage + 1) % _totalPages;
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Special Offer Section
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: Column(
              children: [
                Column(
                  children: [
                    // Video Card with play icon
                    SizedBox(
                      height: 200.h,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _totalPages,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Center(
                                child: Container(
                                  width: 60.w,
                                  height: 40.h,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(12.r), // pill shape
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

                          );
                        },
                      ),
                    ),

                    SizedBox(height: 8.h),

                    // Page indicator dots (static, or you can use SmoothPageIndicator)
                  ],
                ),

                SizedBox(height: 8.h),

                // Page Indicator
                SmoothPageIndicator(
                  controller: _pageController,
                  count: _totalPages,
                  effect: WormEffect(
                    dotHeight: 8.h,
                    dotWidth: 8.w,
                    activeDotColor: Colors.black,
                    dotColor: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          // Search bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                // Search field with border and rounded corners
                Expanded(
                  child: Container(
                    height: 35.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30.r),
                      border: Border.all(color: Colors.black12),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: Row(
                      children: [
                        Icon(Icons.search, size: 20.sp, color: Colors.black54),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 12.w),

                // Filter button styled like a field
                Container(
                  height: 35.h,
                  width: 85.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30.r),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Row(
                    children: [
                      Spacer(),
                      Icon(Icons.filter_list, color: Colors.black, size: 20.sp),
                      SizedBox(width: 8,),
                    ],
                  ),
                ),
              ],
            ),
          ),



          SizedBox(height: 16.h),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start, // Align to the left
              children: [
                Container(
                  height: 10,
                  width: 130,
                  color: Colors.grey[300],
                ),
              ],
            ),
          ),
          SizedBox(height: 8.h),
          // Add this in your widget build method

          Padding(
            padding: EdgeInsets.only(top: 16.h),
            child: SizedBox(
              height: 220.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: 10, // or dynamic list.length
                itemBuilder: (context, index) {
                  final bool isLocked = index % 3 == 0; // mock condition

                  return Container(
                    width: 140.w,
                    margin: EdgeInsets.only(right: 12.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: index == 1 // highlight selection as in screenshot
                          ? Border.all(color: Colors.blueAccent, width: 2)
                          : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top image with optional lock icon
                        Stack(
                          children: [
                            Container(
                              height: 170.h,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(12.r),
                                  topRight: Radius.circular(12.r),
                                  bottomLeft: Radius.circular(12.r),
                                  bottomRight: Radius.circular(12.r),
                                ),
                              ),
                              child: Center(
                                child: Container(
                                  width: 48.w,
                                  height: 32.h,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.play_arrow,
                                      color: Colors.white,
                                      size: 20.sp,
                                    ),
                                  ),
                                ),
                              ),

                            ),
                            if (isLocked)
                              Positioned(
                                top: 8.h,
                                right: 8.w,
                                child: Icon(Icons.lock_outline,
                                    size: 20.sp, color: Colors.grey),
                              ),
                          ],
                        ),

                        SizedBox(height: 8.h),

                        // Placeholder bars
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 8,),
                              Container(
                                height: 10.h,
                                width: 80.w,
                                decoration: BoxDecoration(
                                  color: Colors.grey[400],
                                  borderRadius: BorderRadius.circular(6.r),
                                ),
                              ),
                              SizedBox(height: 6.h),
                              Container(
                                height: 8.h,
                                width: 60.w,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(6.r),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          SizedBox(height: 16,),
          Divider(
            thickness: 1,
            color: Colors.grey[300],
            indent: 16.w,
            endIndent: 16.w,
          ),

          SizedBox(height: 16,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start, // Align to the left
              children: [
                Container(
                  height: 10,
                  width: 130,
                  color: Colors.grey[300],
                ),
              ],
            ),
          ),
          SizedBox(height: 16,),
          // Locked item grid
          // GridView Section
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: items.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 16.h,
                childAspectRatio: 0.65,
              ),
              itemBuilder: (context, index) {
                final item = items[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: 130.h,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],

                          ),
                          child: Center(
                            child: Container(
                              width: 36.w,         // smaller width
                              height: 24.h,        // smaller height
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(6.r), // tighter corners
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.play_arrow,
                                  color: Colors.white,
                                  size: 14.sp,     // smaller icon
                                ),
                              ),
                            ),
                          ),

                        ),
                        if (item.isLocked)
                          Positioned(
                            top: 8.h,
                            right: 8.w,
                            child: Icon(Icons.lock_outline, size: 18.sp, color: Colors.grey),
                          ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      height: 10.h,
                      width: 60.w,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Container(
                      height: 8.h,
                      width: 40.w,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),


          SizedBox(height: 20.h),

          // Continue Reading Button
          GestureDetector(
            onTap: () {
              Get.to(() => VideoDetailsScreen()); // <-- your detail screen widget
            },
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Container(
                width: double.infinity,
                height: 50.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(30.r),
                ),
                child: Center(
                  child: Text(
                    "Continue Reading",
                    style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
