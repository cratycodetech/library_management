import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../routes/routes.dart';

class PdfChapterScreen extends StatefulWidget {
  const PdfChapterScreen({super.key});

  @override
  State<PdfChapterScreen> createState() => _PdfChapterScreenState();
}

class _PdfChapterScreenState extends State<PdfChapterScreen> {
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

          // Tabs
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _tab("About",0),
                _tab("Chapter",1, isSelected: true),
                _tab("Reviews",2),
              ],
            ),
          ),

          SizedBox(height: 24.h),

          // Section Heading
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 12.h, width: 140.w, color: Colors.grey[300]),
                  SizedBox(height: 6.h),
                  Container(height: 8.h, width: 100.w, color: Colors.grey[300]),
                ],
              ),
            ),
          ),


          SizedBox(height: 16.h),

          // Chapters List
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: 5,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.only(bottom: 12.h),
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32.r),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      // Avatar
                      Container(
                        height: 40.w,
                        width: 40.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[300],
                        ),
                      ),
                      SizedBox(width: 12.w),

                      // Title and subtitle
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 10.h,
                              width: 140.w,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Container(
                              height: 8.h,
                              width: 100.w,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(width: 12.w),

                      // PDF icon
                      CircleAvatar(
                        radius: 16.r,
                        backgroundColor: Colors.black,
                        child: Icon(Icons.picture_as_pdf, color: Colors.white, size: 16.sp),
                      ),
                      SizedBox(width: 8.w),

                      // Download icon
                      CircleAvatar(
                        radius: 16.r,
                        backgroundColor: Colors.black,
                        child: Icon(Icons.download, color: Colors.white, size: 16.sp),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
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
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.grey[300],
          borderRadius: BorderRadius.circular(30.r),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}
