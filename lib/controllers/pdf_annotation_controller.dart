// File: lib/controllers/pdf_annotation_controller.dart

import 'package:get/get.dart';

import '../services/pdf_annotation_service.dart';


class PdfAnnotationController extends GetxController {
  final PdfAnnotationService _pdfAnnotationService = PdfAnnotationService();

  var isLoading = false.obs;
  var annotatedFilePath = ''.obs;

  Future<void> annotatePdf(String pdfUrl, String outputFileName) async {
    try {
      isLoading.value = true;
      final file = await _pdfAnnotationService.annotateAndSavePdf(
        pdfUrl: pdfUrl,
        outputFileName: outputFileName,
      );
      annotatedFilePath.value = file.path;
    } catch (error) {
      annotatedFilePath.value = 'Error: $error';
    } finally {
      isLoading.value = false;
    }
  }
}
