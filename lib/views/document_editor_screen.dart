import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart'; // ✅ Fix for missing FlutterQuillEmbeds
import 'package:flutter_localizations/flutter_localizations.dart';

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

  @override
  void initState() {
    super.initState();
    _quillController = quill.QuillController.basic();

    if (widget.documentId != null) {
      _loadDocument();
    } else {
      setState(() => _isLoading = false);
    }
  }

  void _loadDocument() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .collection('documents')
        .doc(widget.documentId)
        .get();

    if (doc.exists) {
      setState(() {
        _titleController.text = doc['title'] ?? '';

        // Load document content from Firestore (stored as JSON)
        if (doc['content'] != null) {
          _quillController.document =
              quill.Document.fromJson(jsonDecode(doc['content']));
        }
        _isLoading = false;
      });
    }
  }

  void _saveDocument() async {
    if (_titleController.text.trim().isEmpty) return;

    var docRef = FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .collection('documents')
        .doc(widget.documentId ?? FirebaseFirestore.instance.collection('dummy').doc().id);

    await docRef.set({
      'title': _titleController.text.trim(),
      'content': jsonEncode(_quillController.document.toDelta().toJson()), // Convert rich text to JSON
      'timestamp': FieldValue.serverTimestamp(),
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.documentId == null ? "New Document" : "Edit Document"),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveDocument,
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
            ),
            SizedBox(height: 10),
            Expanded(
              child: Column(
                children: [
                  // ✅ Fixed Toolbar
                  quill.QuillSimpleToolbar(
                    controller: _quillController,
                    config: QuillSimpleToolbarConfig(
                      embedButtons: FlutterQuillEmbeds.toolbarButtons(),
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
                          scrollController: ScrollController(), // ✅ Fix for missing scrollController
                          focusNode: FocusNode(),

                          config: QuillEditorConfig(
                            placeholder: "Start writing your document...",
                            embedBuilders: FlutterQuillEmbeds.editorBuilders(), // ✅ Fix for missing FlutterQuillEmbeds
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

  @override
  void dispose() {
    _quillController.dispose();
    super.dispose();
  }
}
