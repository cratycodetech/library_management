import 'package:get/get.dart';
import '../../../routes/routes.dart';


void handleTabNavigation(int index) {
  switch (index) {
    case 0:
      Get.toNamed(AppRoutes.audioChapterScreen);
      break;
    case 1:
      Get.toNamed(AppRoutes.audioChapterScreen);
      break;
    case 2:
      Get.toNamed(AppRoutes.audioReviewScreen);
      break;
    default:
      break;
  }
}
