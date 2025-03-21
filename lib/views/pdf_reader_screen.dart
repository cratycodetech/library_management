import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfReaderScreen extends StatefulWidget {
  @override
  _PdfReaderScreenState createState() => _PdfReaderScreenState();
}

class _PdfReaderScreenState extends State<PdfReaderScreen> {
  final PdfViewerController _pdfViewerController = PdfViewerController();
  int _currentPage = 1;
  int _totalPages = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("(Page $_currentPage / $_totalPages)"),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              _pdfViewerController.previousPage();
            },
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () {
              _pdfViewerController.nextPage();
            },
          ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () async {
              try {
                final user = FirebaseAuth.instance.currentUser;
                if (user == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("User not logged in")),
                  );
                  return;
                }

                String uid = user.uid;
                String pdfName = 'sample.pdf'; // You can make this dynamic if needed

                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .collection('readingProgress') // Subcollection
                    .doc(pdfName) // Use PDF name as doc ID
                    .set({
                  'currentPage': _currentPage,
                  'pdfName': pdfName,
                  'updatedAt': FieldValue.serverTimestamp(),
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Progress saved: Page $_currentPage")),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error saving progress")),
                );
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          SfPdfViewer.asset(
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
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    TextEditingController _textController = TextEditingController();

                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('Enter Number of Days'),
                          content: TextField(
                            controller: _textController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(hintText: "Enter days"),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                String inputText = _textController.text;
                                int? days = int.tryParse(inputText);

                                if (days != null && days > 0) {
                                  int pagesPerDay = (_totalPages / days).ceil();

                                  Navigator.of(context).pop();

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("You need to read $pagesPerDay pages per day.")),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Please enter a valid number of days.")),
                                  );
                                }
                              },
                              child: Text('Submit'),
                            ),

                          ],
                        );
                      },
                    );
                  },
                  child: Text('Estimate'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("User not logged in")),
                        );
                        return;
                      }

                      String uid = user.uid;
                      String pdfName = 'sample.pdf'; // Same PDF name used when saving

                      DocumentSnapshot doc = await FirebaseFirestore.instance
                          .collection('users')
                          .doc(uid)
                          .collection('readingProgress')
                          .doc(pdfName)
                          .get();

                      if (doc.exists) {
                        int savedPage = doc['currentPage'];
                        double progress = savedPage / _totalPages;

                        // Show Dialog with Progress Bar
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text('Reading Progress'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  LinearProgressIndicator(
                                    value: progress,
                                    minHeight: 10,
                                    backgroundColor: Colors.grey[300],
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    "Page $savedPage of $_totalPages\n(${(progress * 100).toStringAsFixed(1)}% completed)",
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text("OK"),
                                ),
                              ],
                            );
                          },
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("No progress found")),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error fetching progress")),
                      );
                    }
                  },
                  child: Text('Show Progress'),
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }
}
