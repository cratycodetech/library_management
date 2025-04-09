import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../routes/routes.dart';

class AudioTab extends StatelessWidget {
  const AudioTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          const SizedBox(height: 16),

          // Search and Filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      suffixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),

                      // 🟡 Default border (also a fallback)
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE7E8E8)),
                      ),

                      // ✅ When enabled (not focused)
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE7E8E8)),
                      ),

                      // ✅ When focused
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(color: Color(0xFFE7E8E8)),
                      ),

                      // ✅ When disabled
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE7E8E8)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  height: 48,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.white, // Transparent background like your design
                    border: Border.all(
                      color: const Color(0xFFE7E8E8), // Light border
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(30), // Rounded pill-like shape
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.end, // 👈 Push icon to the right
                      children: [
                        Icon(Icons.filter_list, size: 20, color: Colors.black),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start, // Align to the left
              children: [
                Container(
                  height: 10,
                  width: 100,
                  color: Colors.grey[300],
                ),
              ],
            ),
          ),

          // Horizontal featured audio cards
          SizedBox(
            height: 114,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 4,
              itemBuilder: (context, index) => Container(
                margin: const EdgeInsets.only(right: 24),
                width: 176,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(child: Icon(Icons.music_note, size: 40)),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start, // Align to the left
              children: [
                Container(
                  height: 10,
                  width: 100,
                  color: Colors.grey[300],
                ),
              ],
            ),
          ),

          // Audio List
          ListView.builder(
            itemCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    // Thumbnail
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.music_note),
                    ),
                    const SizedBox(width: 12),

                    // Title & subtitle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              height: 10, width: 100, color: Colors.grey[300]),
                          const SizedBox(height: 6),
                          Container(
                              height: 10, width: 140, color: Colors.grey[300]),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Action icon
                    _buildActionIcon(index),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // Continue Listening button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[200],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () {
                Get.toNamed(AppRoutes.audioDetailScreen);
              },
              child: const Center(
                child: Text(
                  "Continue Listening",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionIcon(int index) {
    if (index == 0) {
      return const Icon(Icons.pause_circle_filled,
          size: 36, color: Colors.black);
    } else if (index == 2) {
      return const Icon(Icons.lock, size: 24, color: Colors.grey);
    } else {
      return const Icon(Icons.play_circle_fill, size: 30, color: Colors.grey);
    }
  }
}
