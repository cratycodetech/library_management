import 'package:flutter/material.dart';

class AudioDetailScreen extends StatelessWidget {
  const AudioDetailScreen({super.key});

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
        children: [
          // Upper section with image, title, play indicator
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

          // Tabs (About, Chapter, Reviews)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _tab("About", isSelected: true),
                _tab("Chapter"),
                _tab("Reviews"),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Description text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: const Text(
              "Creative thinking opens new possibilities. Simple ideas can have profound impacts. Each project teaches valuable lessons. Understanding users leads to better solutions. The best solutions often come from collaboration. Small changes can lead to remarkable results.",
              style: TextStyle(height: 1.4),
            ),
          ),

          const SizedBox(height: 24),

          // Author section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.grey,
                  radius: 24,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 10, width: 100, color: Colors.grey[300]),
                    const SizedBox(height: 6),
                    Container(height: 8, width: 80, color: Colors.grey[300]),
                  ],
                )
              ],
            ),
          ),

          const Spacer(),

          // Playback progress
          Container(
            color: Colors.grey[200],
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Row(
                  children: [
                    Text("10:00", style: TextStyle(fontSize: 12)),
                    Expanded(
                      child: Slider(
                        value: 0.4,
                        onChanged: (v) {},
                        activeColor: Colors.black,
                        inactiveColor: Colors.grey[400],
                      ),
                    ),
                    Text("-03:42", style: TextStyle(fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 8),
                // Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: const [
                    Icon(Icons.shuffle),
                    Icon(Icons.skip_previous),
                    Icon(Icons.pause_circle_filled, size: 40),
                    Icon(Icons.skip_next),
                    Icon(Icons.repeat),
                  ],
                ),
              ],
            ),
          ),

          // Bottom CTA
          Container(
            color: Colors.grey[100],
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 24,
                    color: Colors.grey[300],
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

  Widget _tab(String title, {bool isSelected = false}) {
    return Container(
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
    );
  }

}
