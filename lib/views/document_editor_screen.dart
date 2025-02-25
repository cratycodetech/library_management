import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:image_picker/image_picker.dart';

import '../services/file_upload_service.dart';

class DocumentEditorScreen extends StatefulWidget {
  final String groupId;
  final String? documentId; // If null, create a new document

  DocumentEditorScreen({required this.groupId, this.documentId});

  @override
  _DocumentEditorScreenState createState() => _DocumentEditorScreenState();
}

class _DocumentEditorScreenState extends State<DocumentEditorScreen> {
  final TextEditingController _titleController = TextEditingController();
  late quill.QuillController _quillController;
  bool _isLoading = true;
  Timer? _debounceTimer;
  StreamSubscription<DocumentSnapshot>? _docSubscription;
  final FileUploadService fileUploadService = FileUploadService();

  @override
  void initState() {
    super.initState();
    _quillController = quill.QuillController.basic();
    _quillController.addListener(_onDocumentChanged);

    if (widget.documentId != null) {
      _subscribeDocument();
    } else {
      _isLoading = false;
    }
  }

  void _onDocumentChanged() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(Duration(milliseconds: 500), () {
      _saveDocumentRealtime();
    });
  }

  void _saveDocumentRealtime() async {
    if (_titleController.text.trim().isEmpty) return;

    var docRef = FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .collection('documents')
        .doc(widget.documentId ?? FirebaseFirestore.instance.collection('dummy').doc().id);

    await docRef.set({
      'title': _titleController.text.trim(),
      'content': jsonEncode(_quillController.document.toDelta().toJson()),
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  void _subscribeDocument() {
    _docSubscription = FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .collection('documents')
        .doc(widget.documentId)
        .snapshots()
        .listen((docSnapshot) {
      if (docSnapshot.exists) {
        var data = docSnapshot.data() as Map<String, dynamic>;
        if (data['content'] != null) {
          final remoteDoc = quill.Document.fromJson(jsonDecode(data['content']));
          final localJson = jsonEncode(_quillController.document.toDelta().toJson());
          final remoteJson = jsonEncode(remoteDoc.toDelta().toJson());
          if (localJson != remoteJson) {
            _quillController.removeListener(_onDocumentChanged);
            setState(() {
              _quillController.document = remoteDoc;
            });
            _quillController.addListener(_onDocumentChanged);
          }
        }
        if (data['title'] != null && data['title'] != _titleController.text.trim()) {
          _titleController.text = data['title'];
        }
        if (_isLoading) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    });
  }

  Future<String?> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return null;

    // Upload the image and get the URL
    String? imageUrl = await fileUploadService.uploadDocumentMediaFile(image.path);
    return imageUrl;
  }

  void _insertImage() async {
    String? imageUrl = await _pickAndUploadImage();
    if (imageUrl != null) {
      int index = _quillController.selection.baseOffset;

      // Ensure index is within the valid range
      if (index < 0 || index > _quillController.document.length) {
        index = _quillController.document.length; // Append at the end
      }

      _quillController.document.insert(index, quill.BlockEmbed.image(imageUrl));
      _quillController.moveCursorToPosition(index + 1); // Move cursor after insertion
    }
  }


  @override
  void dispose() {
    _debounceTimer?.cancel();
    _docSubscription?.cancel();
    _quillController.removeListener(_onDocumentChanged);
    _quillController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.documentId == null ? "New Document" : "Edit Document"),
        actions: [
          IconButton(
            icon: Icon(Icons.image),
            onPressed: _insertImage, // Custom image upload button
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: "Title"),
              onChanged: (_) {
                _onDocumentChanged();
              },
            ),
            SizedBox(height: 10),
            Expanded(
              child: Column(
                children: [
                  quill.QuillSimpleToolbar(
                    controller: _quillController,
                    config: quill.QuillSimpleToolbarConfig(
                      showClipboardPaste: true,
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: quill.QuillEditor(
                          controller: _quillController,
                          scrollController: ScrollController(),
                          focusNode: FocusNode(),
                          config: quill.QuillEditorConfig(
                            placeholder: "Start writing your document...",
                            embedBuilders: FlutterQuillEmbeds.editorBuilders(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
