import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/posting_controller.dart';


class PostingScreen extends StatelessWidget {
  final PostingController controller = Get.find<PostingController>();
  final RxBool isPremium = false.obs; // Toggle premium flag

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Upload File')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Obx(() => controller.selectedFilePath.value.isNotEmpty
                ? Text("Selected: ${controller.selectedFilePath.value}")
                : Text("No file selected")),
            SizedBox(height: 16),
            Obx(() => CheckboxListTile(
              title: Text("Mark as Premium"),
              value: isPremium.value,
              onChanged: (value) => isPremium.value = value ?? false,
            )),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => controller.pickAndUploadFile(isPremium: isPremium.value),
              child: Text('Select & Upload File'),
            ),
          ],
        ),
      ),
    );
  }
}
