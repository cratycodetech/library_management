import 'package:flutter/material.dart';
import 'package:get/get.dart'; // <- Make sure this is added
import 'package:library_app/views/study_room/room_list.dart';
import 'package:library_app/views/study_room/widgets/main_scaffold.dart';
import 'package:library_app/views/video/video_tab.dart';
import 'Audiobook/audio_tab.dart';
import 'Pdf/pdf_tab.dart';

class LibraryHomeScreen extends StatefulWidget {
  const LibraryHomeScreen({Key? key}) : super(key: key);

  @override
  State<LibraryHomeScreen> createState() => _LibraryHomeScreenState();
}

class _LibraryHomeScreenState extends State<LibraryHomeScreen> {
  String selectedTab = "AUDIO";
  int _currentIndex = 0; // ✅ Added this line

  Widget _buildTab(String label) {
    final bool isSelected = label == selectedTab;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedTab = label;
          });
        },
        child: Container(
          height: 30,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? Colors.black : Colors.grey[300],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _getSelectedTabWidget() {
    switch (selectedTab) {
      case "AUDIO":
        return const AudioTab();
      case "PDF":
        return PdfTab();
      case "VIDEO":
        return VideoTab();
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      currentIndex: 0,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Library App", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 60,
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  _buildTab("AUDIO"),
                  _buildTab("PDF"),
                  _buildTab("VIDEO"),
                ],
              ),
            ),
          ),
          const SizedBox(height: 2),
          Expanded(child: _getSelectedTabWidget()),
        ],
      ),
    );
  }

}
