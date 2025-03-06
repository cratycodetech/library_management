import 'package:get/get.dart';
import '../bindings/pdf_annotation_binding.dart';
import '../views/all_people_screen.dart';
import '../views/create_group_screen.dart';
import '../views/image_download_screen.dart';
import '../views/one_to_one_call_screen.dart';
import '../views/one_to_one_chat_screen.dart';
import '../views/video_download_screen.dart';
import '../views/group_call_screen.dart';
import '../views/group_chat_screen.dart';
import '../views/group_list_screen.dart';

import '../views/home_screen.dart';
import '../views/login_screen.dart';
import '../bindings/auth_binding.dart';
import '../views/pdf_viewer_screen.dart';
import '../views/widgets/select_chat_widget.dart';




class AppRoutes {
  static const String login = '/login';
  static const String home = '/home';
  static const String createGroup = '/create-group';
  static const String groupChat = '/group-chat';
  static const String groupList = '/group-list';
  static const String groupCall = '/group-call';
  static const String pdfViewer = '/pdf-viewer';
  static const String videoDownload = '/video-download-page';
  static const String photoDownload = '/photo-download';
  static const String selectChat = '/select-chat';
  static const String allPeople = '/all-people';
  static const String chat = '/chat';
  static const String callScreen = '/call';

  static List<GetPage> pages = [
    GetPage(
      name: login,
      page: () => LoginScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: home,
      page: () => HomeScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: createGroup,
      page: () => CreateGroupScreen(),
    ),
    GetPage(
      name: groupChat,
      page: () {
        final args = Get.arguments as Map<String, dynamic>? ?? {};
        return GroupChatScreen(
          groupId: args["groupId"] ?? "",
          groupName: args["groupName"] ?? "Unknown Group",
        );
      },
    ),
    GetPage(
      name: groupList,
      page: () => GroupListScreen(),
    ),

    GetPage(
      name: groupCall,
      page: () {
        final args = Get.arguments as Map<String, dynamic>? ?? {};
        return GroupCallScreen(
          channelName: args["channelName"] ?? "Unknown",
          token: args["token"] ?? "",
        );
      },
    ),

    GetPage(
      name: pdfViewer,
      page: () {
        final args = Get.arguments as Map<String, dynamic>? ?? {};
        // Dynamically get the PDF URL from arguments
        return PDFViewerScreen(
          pdfUrl: args["pdfUrl"] ?? 'https://example.com/default.pdf',
        );
      },
      binding: PdfAnnotationBinding(),
    ),

    GetPage(
      name: AppRoutes.videoDownload,
      page: () {
        final args = Get.arguments as Map<String, dynamic>? ?? {};
        return VideoPlayerPage(
          videoUrl: args['videoUrl'] ?? 'https://example.com/default_video.mp4',
          thumbnailGenerator: args['thumbnailGenerator'] ??
                  (String url) async {

                return null;
              },
        );
      },
    ),

    GetPage(
      name: photoDownload,
      page: () => PhotoDownloadScreen(),
    ),

    GetPage(
      name: selectChat, // Added select-chat page
      page: () => SelectChatScreen(),
    ),
    GetPage(
      name: allPeople, // Added All People route
      page: () => const AllPeopleScreen(),
    ),

    GetPage(
      name: chat,
      page: () {
        final args = Get.arguments as Map<String, dynamic>;
        return ChatScreen(
          receiverId: args['receiverId'],
          receiverName: args['receiverName'],
          receiverPhotoURL: args['receiverPhotoURL'],
        );
      },
    ),
    GetPage(
      name: callScreen, // Added call screen route
      page: () {
        final args = Get.arguments as Map<String, dynamic>;
        return CallScreen(
          channelName: args['channelName'],
          token: args['token'],
        );
      },
    ),
  ];
}
