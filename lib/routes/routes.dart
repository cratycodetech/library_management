import 'package:get/get.dart';
import '../views/create_group_screen.dart';
import '../views/group_chat_screen.dart';
import '../views/group_list_screen.dart';
import '../views/home_screen.dart';
import '../views/login_screen.dart';
import '../bindings/auth_binding.dart';




class AppRoutes {
  static const String login = '/login';
  static const String home = '/home';
  static const String createGroup = '/create-group';
  static const String groupChat = '/group-chat';
  static const String groupList = '/group-list';

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
  ];
}
