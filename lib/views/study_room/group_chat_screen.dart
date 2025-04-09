import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import 'group_info_screen.dart';
import 'model/message_model.dart';

class GroupChatScreen extends StatelessWidget {
  GroupChatScreen({super.key});

  final List<ChatMessage> messages = [
    ChatMessage(text: "Hey! Did you check the updates?", isMe: false, sender: "Noyon"),
    ChatMessage(text: "Yes, everything looks great!", isMe: true, sender: "You"),
    ChatMessage(text: "Let's finalize by tomorrow.", isMe: true, sender: "You"),
    ChatMessage(text: "Cool, I'll add a few more ideas.", isMe: false, sender: "Nafiz"),
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          color: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: SafeArea(
            child: Row(
              children: [
                const Icon(Icons.arrow_back, color: Colors.white),
                const SizedBox(width: 8),
                const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.person)),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Sample Name',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    Text('14 members', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
                const Spacer(),
                const Icon(Icons.videocam, color: Colors.white),
                const SizedBox(width: 12),
                const Icon(Icons.call, color: Colors.white),
                const SizedBox(width: 12),
                const Icon(Icons.description, color: Colors.white),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.info_outline, color: Colors.white),
                  onPressed: () {
                    Get.to(() => const GroupInfoScreen());
                  },
                ),

              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Photo/Preview Area
          Stack(
            children: [
              Container(
                height: 200,
                width: double.infinity,
                color: Colors.grey[300],
                alignment: Alignment.center,
                child: const Icon(Icons.image, size: 50),
              ),
              Positioned(
                bottom: 8,
                right: 8,
                child: Icon(Icons.fullscreen, size: 20),
              ),
            ],
          ),


          const SizedBox(height: 24),

          // Chat Area
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];

                // 🧍 Show both your name and others' name
                final String displayName = message.isMe ? "You" : (message.sender ?? "Unknown");



                if (message.isMe) {
                  // ✅ Outgoing message (user)
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 4, bottom: 4),
                        child: Text(
                          displayName,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          constraints: const BoxConstraints(maxWidth: 280),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(0),
                              bottomLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                          ),
                          child: Text(
                            message.text,
                            style: const TextStyle(color: Colors.white),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  // ✅ Incoming message (other user)
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.black12,
                          child: Icon(Icons.person, size: 16, color: Colors.black),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (displayName.isNotEmpty)

                                Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Text(
                                    displayName,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              Container(
                                padding: const EdgeInsets.all(12),
                                constraints: const BoxConstraints(maxWidth: 280),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(0),
                                    topRight: Radius.circular(12),
                                    bottomLeft: Radius.circular(12),
                                    bottomRight: Radius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  message.text,
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    height: 1.4,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ),




          // Message input
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 🔹 TextField
                const TextField(
                  decoration: InputDecoration(
                    hintText: 'Type your message...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                  ),
                  style: TextStyle(fontSize: 14),
                ),

                // 🔸 Divider
                const Divider(height: 1, thickness: 1),

                const SizedBox(height: 8),

                // 🔻 Icon Row + Send Button
                Row(
                  children: [
                    Icon(Icons.add_circle_outline, color: Colors.grey.shade600),
                    const SizedBox(width: 16),
                    Icon(Icons.mic_none, color: Colors.grey.shade600),
                    const SizedBox(width: 16),
                    Icon(Icons.emoji_emotions_outlined, color: Colors.grey.shade600),
                    const SizedBox(width: 16),
                    Icon(Icons.attach_file, color: Colors.grey.shade600),
                    const SizedBox(width: 16),
                    Icon(Icons.auto_awesome, color: Colors.grey.shade600),
                    const Spacer(),
                    CircleAvatar(
                      backgroundColor: Colors.black,
                      radius: 20,
                      child: Icon(Icons.send, color: Colors.white, size: 20),
                    ),
                  ],
                ),
              ],
            ),
          )


        ],
      ),
    );
  }
}
