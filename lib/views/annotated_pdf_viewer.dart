// File: lib/views/annotated_pdf_viewer.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../services/file_upload_service.dart';

class AnnotatedPdfViewer extends StatefulWidget {
  final String originalPdfUrl;
  final String annotatedPdfPath;
  const AnnotatedPdfViewer({Key? key, required this.annotatedPdfPath, required this.originalPdfUrl})
      : super(key: key);

  @override
  _AnnotatedPdfViewerState createState() => _AnnotatedPdfViewerState();
}

class _AnnotatedPdfViewerState extends State<AnnotatedPdfViewer> {
  late File pdfFile;
  // Use integer values for colors (0-255 range).
  PdfColor _selectedColor = PdfColor(255, 255, 0); // Default yellow

  @override
  void initState() {
    super.initState();
    pdfFile = File(widget.annotatedPdfPath);
  }

  Future<void> _addAnnotationAtOffset(Offset tapOffset) async {
    // Read the current PDF bytes.
    final Uint8List bytes = await pdfFile.readAsBytes();
    // Load the document.
    final PdfDocument document = PdfDocument(inputBytes: bytes);
    if (document.pages.count > 0) {
      final PdfPage page = document.pages[0];
      // Create a rectangle centered at the tap location.
      final Rect rect =
      Rect.fromCenter(center: tapOffset, width: 150, height: 20);
      // Create a highlight annotation using the selected color.
      final PdfTextMarkupAnnotation annotation = PdfTextMarkupAnnotation(
        rect,
        'Highlighted text',
        _selectedColor,
      );
      annotation.author = 'User';
      annotation.subject = 'Highlight';
      page.annotations.add(annotation);
      // Save the updated document.
      final List<int> updatedBytes = await document.save();
      document.dispose();
      await pdfFile.writeAsBytes(updatedBytes, flush: true);
      setState(() {});
    }
  }

  void _showColorPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: CircleAvatar(backgroundColor: Colors.yellow),
                title: Text('Yellow'),
                onTap: () {
                  setState(() {
                    _selectedColor = PdfColor(255, 255, 0);
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: CircleAvatar(backgroundColor: Colors.red),
                title: Text('Red'),
                onTap: () {
                  setState(() {
                    _selectedColor = PdfColor(255, 0, 0);
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: CircleAvatar(backgroundColor: Colors.green),
                title: Text('Green'),
                onTap: () {
                  setState(() {
                    _selectedColor = PdfColor(0, 255, 0);
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: CircleAvatar(backgroundColor: Colors.blue),
                title: Text('Blue'),
                onTap: () {
                  setState(() {
                    _selectedColor = PdfColor(0, 0, 255);
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveAnnotatedPdf() async {
    try {
      print("📌 Exact URL: ${widget.originalPdfUrl}");

      Uri uri = Uri.parse(widget.originalPdfUrl);

      // Ensure the correct file path inside Supabase storage
      List<String> pathSegments = uri.pathSegments;

      // Find the bucket name (e.g., "library app") and extract the file path
      int bucketIndex = pathSegments.indexOf("library app");
      if (bucketIndex == -1 || bucketIndex + 1 >= pathSegments.length) {
        throw "Invalid file path. Cannot extract storage path.";
      }

      // Extract the correct storage path inside the bucket
      String storagePath = pathSegments.sublist(bucketIndex + 1).join('/');

      print("📌 Extracted Storage Path: $storagePath");

      // Upload the annotated file
      String? downloadUrl = await FileUploadService().uploadAnnotatedFile(pdfFile, storagePath);

      if (downloadUrl != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ Annotated PDF saved and uploaded successfully.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('⚠️ Annotated PDF saved locally but upload failed.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Upload error: $e')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Annotated PDF Viewer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.color_lens),
            onPressed: _showColorPicker,
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveAnnotatedPdf,
          ),
        ],
      ),
      body: Stack(
        children: [
          SfPdfViewer.file(pdfFile),
          GestureDetector(
            onTapDown: (details) {
              final RenderBox box = context.findRenderObject() as RenderBox;
              final Offset localOffset =
              box.globalToLocal(details.globalPosition);
              _addAnnotationAtOffset(localOffset);
            },
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }
}
