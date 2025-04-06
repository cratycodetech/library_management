import 'package:flutter/material.dart';

class AudioPlayerScreen extends StatelessWidget {
  const AudioPlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Icon(Icons.arrow_back, color: Colors.black),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Spacer(),
            Container(height: 10, width: 120, color: Colors.grey[300]),
            const SizedBox(width: 24),
            Spacer(),
            const CircleAvatar(radius: 8, backgroundColor: Colors.grey),
            const SizedBox(width: 6),
            CircleAvatar(radius: 8, backgroundColor: Colors.grey[300]),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 100),

          // Big disc
          Center(
            child: Container(
              height: 220,
              width: 220,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  height: 80,
                  width: 80,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.music_note, size: 36),
                ),
              ),
            ),
          ),

          const SizedBox(height: 40),

          // Title and subtitle placeholder
          Column(
            children: [
              Container(height: 10, width: 160, color: Colors.grey[400]),
              const SizedBox(height: 10),
              Container(height: 8, width: 100, color: Colors.grey[200]),
            ],
          ),

          const Spacer(),

          // Waveform + time
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const AudioWavePlaceholder(),
                const SizedBox(height: 8),
                Row(
                  children: const [
                    SizedBox(width: 16),
                    Text("10:00", style: TextStyle(fontSize: 12)),
                    Spacer(),
                    Text("-03:42", style: TextStyle(fontSize: 12)),
                    SizedBox(width: 16),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),

          // Playback controls
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                Icon(Icons.shuffle),
                Icon(Icons.skip_previous),
                Icon(Icons.pause_circle_filled, size: 40),
                Icon(Icons.skip_next),
                Icon(Icons.repeat),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Wider waveform placeholder
class AudioWavePlaceholder extends StatelessWidget {
  const AudioWavePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 32,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 100, // More bars to stretch across wider width
        itemBuilder: (context, index) {
          final height = index.isEven ? 20.0 : 12.0;
          return Container(
            width: 3,
            height: height,
            margin: const EdgeInsets.symmetric(horizontal: 1.0),
            decoration: BoxDecoration(
              color: index < 50 ? Colors.black : Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          );
        },
      ),
    );
  }
}
