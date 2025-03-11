import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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
    await dotenv.load(fileName: ".env"); // ✅ Load .env file
  } catch (e) {
    print("❌ Error loading .env file: $e");
  }
  await FirebaseService.init();
  await Supabase.initialize(
    url: 'https://utomiwubfeyxyfkkmril.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InV0b21pd3ViZmV5eHlma2ttcmlsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzk5NjAyNjIsImV4cCI6MjA1NTUzNjI2Mn0.faDiJ988isqsYLJqj39N_8nLfLjGjIayh1z_JOTYos8',  // 🔹 Replace with your API Key
  );

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

  String? fcmToken = await messaging.getToken();
  if (fcmToken != null) {
    print("🔥 FCM Token: $fcmToken");
  } else {
    print("❌ Failed to retrieve FCM token.");
  }


  if (fcmToken != null) {
    String? fcmToken = await messaging.getToken();
    if (fcmToken != null) {
      try {
        await NotificationRemoteService().updateFcmToken(fcmToken: fcmToken);
        print("✅ FCM Token updated successfully.");
      } catch (e) {
        print("❌ Failed to update `FCM` token: $e");
      }
    } else {
      print("❌ Failed to retrieve FCM token.");
    }
  }


  runApp(MyApp());
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
        Locale('en', 'US'), // English
        Locale('es', 'ES'), // Spanish
        Locale('fr', 'FR'), // French
        Locale('de', 'DE'), // German
      ],
    );
  }
}
