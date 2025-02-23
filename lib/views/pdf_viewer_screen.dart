// File: lib/views/pdf_viewer_screen.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../controllers/pdf_annotation_controller.dart';
import '../services/snackbar_service.dart';
import 'annotated_pdf_viewer.dart';


class PDFViewerScreen extends StatelessWidget {
  final String pdfUrl;
  const PDFViewerScreen({Key? key, required this.pdfUrl}) : super(key: key);


  Future<void> _downloadPdf(String url) async {
    // Get the directory where you want to save the PDF
    final directory = Platform.isAndroid
        ? '/storage/emulated/0/Download'
        : (await getApplicationDocumentsDirectory()).path;
    // Generate a unique filename using current datetime
    final String fileName = '${DateTime.now().millisecondsSinceEpoch}.pdf';

    await FlutterDownloader.enqueue(
      url: url,
      savedDir: directory,
      fileName: fileName,
      showNotification: true, // Show download progress in the notification bar
      openFileFromNotification: true, // Open the file when tapping the notification
    );
  }

  @override
  Widget build(BuildContext context) {
    final PdfAnnotationController controller = Get.find<PdfAnnotationController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Viewer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await controller.annotatePdf(pdfUrl, 'annotated_output.pdf');
              if (controller.annotatedFilePath.value.isNotEmpty) {
                Get.to(() => AnnotatedPdfViewer(
                  originalPdfUrl: pdfUrl,
                  annotatedPdfPath: controller.annotatedFilePath.value,
                ));
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () async {
              SnackbarService.showSuccess('Download is started');
              await _downloadPdf(pdfUrl);
            },
          ),
        ],
      ),
      body: SfPdfViewer.network(pdfUrl),
    );
  }
}
