class ChatMessage {
  final String text;
  final bool isMe;
  final String? sender; // ✅ Add this line if missing

  ChatMessage({
    required this.text,
    required this.isMe,
    this.sender, // ✅ Add this in constructor
  });
}
