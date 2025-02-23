// File: lib/bindings/pdf_annotation_binding.dart
import 'package:get/get.dart';
import '../controllers/pdf_annotation_controller.dart';

class PdfAnnotationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PdfAnnotationController>(() => PdfAnnotationController());
  }
}
