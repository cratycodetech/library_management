import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';

class PdfAnnotationService {
  Future<File> annotateAndSavePdf({
    required String pdfUrl,
    required String outputFileName,
  }) async {
    final http.Response response = await http.get(Uri.parse(pdfUrl));
    if (response.statusCode != 200) {
      throw Exception('Failed to download PDF. Status code: ${response.statusCode}');
    }
    final Uint8List pdfBytes = response.bodyBytes;
    final PdfDocument document = PdfDocument(inputBytes: pdfBytes);
    if (document.pages.count == 0) {
      throw Exception('Downloaded PDF has no pages.');
    }
    final PdfPage page = document.pages[0];
    final Rect highlightRect = Rect.fromLTWH(100, 500, 150, 20);
    final PdfTextMarkupAnnotation highlightAnnotation = PdfTextMarkupAnnotation(
      highlightRect,
      'This text has been highlighted',
      PdfColor(1, 1, 0),
    );
    highlightAnnotation.author = 'Your App';
    highlightAnnotation.subject = 'Highlighted Section';
    page.annotations.add(highlightAnnotation);
    final List<int> annotatedPdfBytes = await document.save();
    document.dispose();
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String filePath = '${appDocDir.path}/$outputFileName';
    final File outputFile = File(filePath);
    await outputFile.writeAsBytes(annotatedPdfBytes, flush: true);
    return outputFile;
  }
}
