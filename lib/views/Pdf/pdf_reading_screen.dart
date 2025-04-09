import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfReadingScreen extends StatefulWidget {
  const PdfReadingScreen({super.key});

  @override
  State<PdfReadingScreen> createState() => _PdfReadingScreenState();
}

class _PdfReadingScreenState extends State<PdfReadingScreen> {
  final PdfViewerController _pdfViewerController = PdfViewerController();
  int _currentPage = 1;
  int _totalPages = 1;

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
            padding: EdgeInsets.all(1.w),
            child: IconButton(
              icon: Icon(Icons.share, color: Colors.black, size: 20.sp),
              onPressed: () {
                final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

                showMenu(
                  context: context,
                  position: RelativeRect.fromLTRB(
                    MediaQuery.of(context).size.width - 100,
                    kToolbarHeight + 10,
                    16,
                    0,
                  ),
                  items: [
                    PopupMenuItem(
                      child: Text("Create a Room", style: TextStyle(fontSize: 14.sp)),
                      onTap: () {
                        // Handle room creation here
                        debugPrint("Create Room tapped");
                      },
                    ),
                    PopupMenuItem(
                      child: Text("Share with Friends", style: TextStyle(fontSize: 14.sp)),
                    ),
                    PopupMenuItem(
                      child: Text("Copy Link", style: TextStyle(fontSize: 14.sp)),
                    ),
                  ],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  color: Colors.white,
                );
              },
            ),

          ),
          IconButton(
            icon: Icon(Icons.bookmark, color: Colors.black, size: 24.sp),
            onPressed: () async {

            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Chapter title and subtitle
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(height: 12.h, width: 180.w, color: Colors.grey[300]),
                SizedBox(height: 6.h),
                Container(height: 8.h, width: 120.w, color: Colors.grey[300]),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // PDF content
          Expanded(
            child: SfPdfViewer.asset(
              'assets/sample.pdf',
              controller: _pdfViewerController,
              onDocumentLoaded: (PdfDocumentLoadedDetails details) {
                setState(() {
                  _totalPages = details.document.pages.count;
                });
              },
              onPageChanged: (PdfPageChangedDetails details) {
                setState(() {
                  _currentPage = details.newPageNumber;
                });
              },
            ),
          ),

          // Bottom navigation bar
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            color: Colors.grey[200], // Matches background in your screenshot
            child: Row(
              children: [
                // Back Button
                Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black54),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, size: 18.sp, color: Colors.black),
                    onPressed: () => _pdfViewerController.previousPage(),
                    padding: EdgeInsets.zero,
                  ),
                ),

                // Spacer for progress + chapter
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Progress Bar
                        SizedBox(
                          width: 300, // or a fixed width like 200.w
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10.r),
                            child: LinearProgressIndicator(
                              value: _totalPages > 0 ? _currentPage / _totalPages : 0,
                              backgroundColor: Colors.white,
                              valueColor: AlwaysStoppedAnimation(Colors.black),
                              minHeight: 4.h,
                            ),
                          ),
                        ),

                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            Text("Chapter 02", style: TextStyle(fontSize: 12.sp)),
                            Spacer(),
                            Text(
                              "${_currentPage.toString().padLeft(2, '0')}/${_totalPages.toString().padLeft(3, '0')}",
                              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Page Count

                SizedBox(width: 12.w),

                // Next Button
                Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.arrow_forward, size: 18.sp, color: Colors.white),
                    onPressed: () => _pdfViewerController.nextPage(),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }
}
