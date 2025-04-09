import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../routes/routes.dart';

class AudioChapterScreen extends StatefulWidget {
  const AudioChapterScreen({super.key});

  @override
  State<AudioChapterScreen> createState() => _AudioChapterScreenState();
}

class _AudioChapterScreenState extends State<AudioChapterScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Icon(Icons.arrow_back, color: Colors.black),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.bookmark_border, color: Colors.black),
          ),
        ],
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  height: 155,
                  width: 124,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.music_note, size: 48),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 14, width: 120, color: Colors.grey[300]),
                      const SizedBox(height: 8),
                      Container(height: 12, width: 100, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Row(
                        children: List.generate(
                          4,
                              (index) => Container(
                            margin: const EdgeInsets.only(right: 8),
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: index == 0 ? Colors.black : Colors.grey[300],
                            ),
                            child: index == 0
                                ? const Icon(Icons.play_arrow, size: 14, color: Colors.white)
                                : null,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _tab("About",0),
                _tab("Chapter",1, isSelected: true),
                _tab("Reviews",2),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 10, width: 180, color: Colors.grey[300]),
                const SizedBox(height: 6),
                Container(height: 8, width: 100, color: Colors.grey[300]),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // List of Chapters
          Expanded(
            child: ListView.builder(
              itemCount: 5,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Get.toNamed(AppRoutes.audioPlayerScreen);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Colors.grey,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(height: 10, width: 140, color: Colors.grey[300]),
                              const SizedBox(height: 6),
                              Container(height: 8, width: 100, color: Colors.grey[300]),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          index == 2 || index > 2 ? Icons.lock : Icons.play_circle,
                          color: index == 2 || index > 2 ? Colors.grey : Colors.black,
                          size: 28,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom CTA
          Container(
            color: Colors.grey[100],
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 10, width: 140, color: Colors.grey[300]),
                      const SizedBox(height: 6),
                      Container(height: 8, width: 100, color: Colors.grey[300]),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  onPressed: () {},
                  child: const Text("Buy Now", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tab(String title, int index,{bool isSelected = false}) {
    return GestureDetector(
      onTap: () {
        switch (index) {
          case 0:
            Get.toNamed(AppRoutes.audioDetailScreen);
            break;
          case 1:
            Get.toNamed(AppRoutes.audioChapterScreen);
            break;
          case 2:
            Get.toNamed(AppRoutes.audioReviewScreen);
            break;
          default:
            break;
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8), // ⬅️ Space between tabs
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12), // ⬅️ Wider & taller
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.grey[300],
          borderRadius: BorderRadius.circular(32), // Optional: More rounded
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
