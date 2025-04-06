import 'package:get/get.dart';
import 'package:library_app/views/Audiobook/audio_chapter_screen.dart';
import 'package:library_app/views/Audiobook/audio_detail_screen.dart';
import 'package:library_app/views/Audiobook/audio_player_screen.dart';
import 'package:library_app/views/Authentication/forget_password_screen.dart';
import 'package:library_app/views/Authentication/update_pass_screen.dart';
import 'package:library_app/views/library_home_screen.dart';
import '../bindings/pdf_annotation_binding.dart';
import '../bindings/posting_binding.dart';
import '../bindings/posts_binding.dart';
import '../views/Authentication/login_register_screen.dart';
import '../views/Authentication/login_screen.dart';
import '../views/Authentication/otp_screen.dart';
import '../views/Authentication/registration_screen.dart';
import '../views/all_people_screen.dart';
import '../views/create_group_screen.dart';
import '../views/image_download_screen.dart';
import '../views/one_to_one_call_screen.dart';
import '../views/one_to_one_chat_screen.dart';
import '../views/posting_screen.dart';
import '../views/posts_screen.dart';
import '../views/video_download_screen.dart';
import '../views/group_call_screen.dart';
import '../views/group_chat_screen.dart';
import '../views/group_list_screen.dart';
import '../views/home_screen.dart';
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
  static const String postingScreen = '/posting';
  static const String postsScreen = '/posts';
  static const String registrationScreen = '/registration';
  static const String otpScreen = '/otp';
  static const String loginRegister = '/login-register';
  static const String forgetPassword = '/forget-password';
  static const String updatePassword = '/update-password';
  static const String libraryHomeScreen = '/library-home-screen';
  static const String audioDetailScreen = '/audio-Detail-screen';
  static const String audioChapterScreen = '/audio-Chapter-screen';
  static const String audioPlayerScreen = '/audio-player-screen';

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

    GetPage(
      name: postingScreen,
      page: () => PostingScreen(),
      binding: PostingBinding(),
    ),
    GetPage(
      name: postsScreen,
      page: () => PostsScreen(),
      binding: PostsBinding(),
    ),

    GetPage(
      name: registrationScreen, // Added select-chat page
      page: () => RegistrationScreen(),
    ),
    GetPage(
      name: otpScreen, // Added select-chat page
      page: () => OtpScreen(),
    ),
    GetPage(
      name: loginRegister,
      page: () => const LoginRegisterScreen(),
    ),

    GetPage(
      name: forgetPassword,
      page: () => const ForgetPasswordScreen(),
    ),

    GetPage(
      name: updatePassword,
      page: () => const UpdatePassScreen(),
    ),

    GetPage(
      name: libraryHomeScreen,
      page: () => const LibraryHomeScreen(),
    ),

    GetPage(
      name: audioDetailScreen,
      page: () => const AudioDetailScreen(),
    ),

    GetPage(
      name: audioChapterScreen,
      page: () => const AudioChapterScreen(),
    ),

    GetPage(
      name: audioPlayerScreen,
      page: () => const AudioPlayerScreen(),
    ),

  ];
}
