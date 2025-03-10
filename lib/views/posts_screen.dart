import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:library_app/views/post_detail_screen.dart';
import '../controllers/posts_controller.dart';
import '../models/post_model.dart';

class PostsScreen extends StatelessWidget {
  final PostsController controller = Get.put(PostsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('All Posts')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (controller.posts.isEmpty) {
          return Center(child: Text("No posts available"));
        }

        return ListView.builder(
          itemCount: controller.posts.length,
          itemBuilder: (context, index) {
            final PostModel post = controller.posts[index];
            return Card(
              margin: EdgeInsets.all(8),
              child: ListTile(
                leading: post.fileType == 'mp4'
                    ? Icon(Icons.video_library, color: Colors.red)
                    : Icon(Icons.insert_drive_file, color: Colors.blue),
                title: Text(post.fileName),
                subtitle: Text("Uploaded by ${post.username}"),
                trailing: post.isPremium
                    ? Icon(Icons.lock, color: Colors.orange) // Premium files
                    : Icon(Icons.download, color: Colors.green),
                onTap: () {
                  Get.to(() => PostDetailScreen(post: post));
                },
                onLongPress: () {
                  if (post.isPremium) {
                    controller.downloadAndEncryptFile(post);
                  } else {
                    Get.snackbar("Info", "Only premium files require download.");
                  }
                },
              ),
            );
          },
        );
      }),
    );
  }
}
