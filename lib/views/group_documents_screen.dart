import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import 'document_editor_screen.dart';

class GroupDocumentsScreen extends StatelessWidget {
  final String groupId;

  GroupDocumentsScreen({required this.groupId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Group Documents")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                // Navigate to document editor to create a new document
                Get.to(() => DocumentEditorScreen(groupId: groupId));
              },
              child: Text("Create Document"),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('groups')
                  .doc(groupId)
                  .collection('documents')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No documents found."));
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var doc = snapshot.data!.docs[index];
                    return ListTile(
                      title: Text(doc['title'] ?? 'Untitled Document'),
                      subtitle: Text(
                          doc['timestamp'] != null
                              ? doc['timestamp'].toDate().toString()
                              : "No timestamp available"
                      ),
                      onTap: () {
                        // Open the document for editing
                        Get.to(() => DocumentEditorScreen(
                          groupId: groupId,
                          documentId: doc.id,
                        ));
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
