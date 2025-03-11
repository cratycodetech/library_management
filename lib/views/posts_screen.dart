import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:library_app/views/post_detail_screen.dart';
import '../controllers/posts_controller.dart';
import '../models/post_model.dart';

class PostsScreen extends StatelessWidget {
  final PostsController controller = Get.put(PostsController());
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('All Posts')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: "Search",
                hintText: "Search posts by name...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                controller.filterPosts(value);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Obx(() {
              return DropdownButton<String>(
                value: controller.selectedFileType.value,
                onChanged: (value) {
                  controller.filterByFileType(value!);
                },
                items: [
                  DropdownMenuItem(value: "all", child: Text("All")),
                  DropdownMenuItem(value: "pdf", child: Text("Books (PDF)")),
                  DropdownMenuItem(value: "mp4", child: Text("Videos (MP4)")),
                  DropdownMenuItem(value: "mp3", child: Text("Audios (MP3)")),
                ],
              );
            }),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              }

              if (controller.filteredPosts.isEmpty) {
                return Center(child: Text("No posts available"));
              }

              return ListView.builder(
                itemCount: controller.filteredPosts.length,
                itemBuilder: (context, index) {
                  final PostModel post = controller.filteredPosts[index];
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
          ),
        ],
      ),
    );
  }
  Widget _getFileIcon(String fileType) {
    switch (fileType) {
      case 'mp4':
        return Icon(Icons.video_library, color: Colors.red);
      case 'pdf':
        return Icon(Icons.book, color: Colors.blue);
      case 'mp3':
        return Icon(Icons.audiotrack, color: Colors.green);
      default:
        return Icon(Icons.insert_drive_file, color: Colors.grey);
    }
  }
}
