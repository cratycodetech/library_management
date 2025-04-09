import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:library_app/services/notification_remote_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'routes/routes.dart';
import 'services/firebase_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

const MethodChannel _channel = MethodChannel('screen_protection');

Future<void> enableScreenProtection() async {
  try {
    await _channel.invokeMethod('enableProtection');
  } catch (e) {
    print("Error enabling screen protection: $e");
  }
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> requestNotificationPermission() async {
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print("❌ Error loading .env file: $e");
  }
  await FirebaseService.init();
  // await Supabase.initialize(
  //   url: dotenv.env['SUPABASE_URL'] ?? '',
  //   anonKey: dotenv.env['SUPABASE_ANONKEY'] ?? '',
  // );

  await FlutterDownloader.initialize(
    debug: true,
    ignoreSsl: true,
  );
  await requestNotificationPermission();
  // Android settings
  const AndroidInitializationSettings androidInitSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  // iOS settings
  final DarwinInitializationSettings iosInitSettings =
      DarwinInitializationSettings();

  final InitializationSettings initSettings = InitializationSettings(
    android: androidInitSettings,
    iOS: iosInitSettings,
  );
  //await enableScreenProtection();
  await flutterLocalNotificationsPlugin.initialize(initSettings);
  await Firebase.initializeApp();
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // String? fcmToken = await messaging.getToken();
  // if (fcmToken != null) {
  //   print("🔥 FCM Token: $fcmToken");
  // } else {
  //   print("❌ Failed to retrieve FCM token.");
  // }
  //
  // if (fcmToken != null) {
  //   String? fcmToken = await messaging.getToken();
  //   if (fcmToken != null) {
  //     try {
  //       await NotificationRemoteService().updateFcmToken(fcmToken: fcmToken);
  //       print("✅ FCM Token updated successfully.");
  //     } catch (e) {
  //       print("❌ Failed to update `FCM` token: $e");
  //     }
  //   } else {
  //     print("❌ Failed to retrieve FCM token.");
  //   }
  // }

  runApp(
    ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.login,
      getPages: AppRoutes.pages,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en', 'US'),
        Locale('es', 'ES'),
        Locale('fr', 'FR'), // French
        Locale('de', 'DE'), // German
      ],
    );
  }
}
