import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../routes/routes.dart';

class PdfDetailScreen extends StatefulWidget {
  const PdfDetailScreen({super.key});

  @override
  State<PdfDetailScreen> createState() => _PdfDetailScreenState();
}

class _PdfDetailScreenState extends State<PdfDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Icon(Icons.arrow_back, color: Colors.black, size: 24.sp),
        actions: [
          Padding(
            padding: EdgeInsets.all(5.w),
            child: Icon(Icons.share, color: Colors.black, size: 20.sp),
          ),
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: Icon(Icons.bookmark_border, color: Colors.black, size: 24.sp),
          ),
        ],
      ),
      body: Column(
        children: [
          // Top Section
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                Container(
                  height: 155.h,
                  width: 124.w,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(Icons.image, size: 48.sp),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 14.h, width: 120.w, color: Colors.grey[300]),
                      SizedBox(height: 8.h),
                      Container(height: 12.h, width: 100.w, color: Colors.grey[300]),
                      SizedBox(height: 16.h),
                      Row(
                        children: List.generate(
                          4,
                              (index) => Container(
                            margin: EdgeInsets.only(right: 8.w),
                            width: 20.w,
                            height: 20.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: index == 0 ? Colors.black : Colors.grey[300],
                            ),
                            child: index == 0
                                ? Icon(Icons.play_arrow, size: 14.sp, color: Colors.white)
                                : null,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 24.h),

          // Tabs (About, Chapter, Reviews)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _tab("About", 0,isSelected: true),
                _tab("Chapter",1),
                _tab("Reviews",2),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // Description
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Text(
              "Creative thinking opens new possibilities. Simple ideas can have profound impacts. Each project teaches valuable lessons. Understanding users leads to better solutions. The best solutions often come from collaboration. Small changes can lead to remarkable results.",
              style: TextStyle(height: 1.4, fontSize: 14.sp),
            ),
          ),

          SizedBox(height: 40.h),

          // Author Info
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey,
                  radius: 24.r,
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

          const Spacer(),

          // Read Now Button
          GestureDetector(
            onTap: () {
              Get.toNamed(AppRoutes.pdfReadingScreen);
            },
            child: Container(
              height: 60.h,
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(30.r),
              ),
              child: Center(
                child: Text(
                  'Read Now',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: 32.h),
        ],
      ),
    );
  }

  Widget _tab(String title,int index, {bool isSelected = false}) {
    return GestureDetector(
      onTap: () {
        switch (index) {
          case 0:
            Get.toNamed(AppRoutes.pdfDetailScreen);
            break;
          case 1:
            Get.toNamed(AppRoutes.pdfChapterScreen);
            break;
          case 2:
            //Get.toNamed(AppRoutes.pdfReadingScreen);
            break;
          default:
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
