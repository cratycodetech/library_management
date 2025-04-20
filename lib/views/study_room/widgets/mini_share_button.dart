import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ShareButton extends StatelessWidget {
  final VoidCallback onPressed;

  const ShareButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 0.8,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(Icons.share, color: Colors.black, size: 18),
          padding: EdgeInsets.zero,
          constraints: BoxConstraints.tight(Size(28, 28)),
          onPressed: onPressed,
        ),
      ),
    );
  }
}
