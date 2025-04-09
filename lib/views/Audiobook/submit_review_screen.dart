import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SubmitReviewScreen extends StatefulWidget {
  const SubmitReviewScreen({super.key});

  @override
  State<SubmitReviewScreen> createState() => _SubmitReviewScreenState();
}

class _SubmitReviewScreenState extends State<SubmitReviewScreen> {
  int selectedRating = 4;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Icon(Icons.arrow_back, color: Colors.black, size: 24.sp),
      ),

      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Audio Info
            Row(
              children: [
                Container(
                  height: 140.h,
                  width: 100.w,
                  color: Colors.grey[300],
                  child: Icon(Icons.music_note, size: 40.sp),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 12.h, width: 120.w, color: Colors.grey[300]),
                      SizedBox(height: 8.h),
                      Container(height: 10.h, width: 100.w, color: Colors.grey[300]),
                      SizedBox(height: 16.h),
                      Row(
                        children: List.generate(4, (index) {
                          if (index == 0) {
                            return Container(
                              margin: EdgeInsets.only(right: 8.w),
                              width: 20.w,
                              height: 20.w,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black,
                              ),
                              child: Icon(Icons.play_arrow, size: 12.sp, color: Colors.white),
                            );
                          } else {
                            return Container(
                              margin: EdgeInsets.only(right: 8.w),
                              width: 20.w,
                              height: 20.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey[300],
                              ),
                            );
                          }
                        }),
                      ),

                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 100.h),

            // Name placeholder
            Center(
              child: Container(
                height: 12.h,
                width: 160.w,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),

            SizedBox(height: 20.h),

            // Star Rating
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  onPressed: () {
                    setState(() {
                      selectedRating = index + 1;
                    });
                  },
                  icon: Icon(
                    Icons.star,
                    color: index < selectedRating ? Colors.black : Colors.grey[300],
                    size: 32.sp,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                );
              }),
            ),

            SizedBox(height: 50.h),

            // Comment Placeholder
            Container(
              height: 12.h,
              width: 140.w,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),

            SizedBox(height: 16.h),

            // Review Text Box
            Container(
              height: 160.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),

            const Spacer(),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32.r),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                ),
                child: Text(
                  "Submit",
                  style: TextStyle(color: Colors.white, fontSize: 16.sp),
                ),
              ),
            ),

            SizedBox(height: 80.h),
          ],
        ),
      ),
    );
  }
}
