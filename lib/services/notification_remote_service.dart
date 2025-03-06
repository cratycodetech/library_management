import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationRemoteService {
  static const String _baseUrl = "http://192.168.0.102:3000";

  static Future<void> sendPushNotification({
    required String receiverId,
    required String message,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/send-notification"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "receiverId": receiverId,
          "message": message,
        }),
      );

      if (response.statusCode == 200) {
        print("✅ Push notification sent successfully.");
      } else {
        print("❌ Failed to send push notification: \${response.body}");
      }
    } catch (e) {
      print("❌ Error sending push notification: $e");
    }
  }

  Future<void> updateFcmToken({required String fcmToken}) async {
    try {

      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception("No authenticated user found.");
      }

      String userId = user.uid;

      final url = Uri.parse('$_baseUrl/fcm-update/$userId');
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'fcmToken': fcmToken,
        }),
      );

      if (response.statusCode != 200) {
        final errorResponse = jsonDecode(response.body);
        throw Exception(errorResponse['message'] ?? 'Update failed');
      }
    } catch (e) {

      throw Exception('Failed to update fcmToken: ${e.toString()}');
    }
  }

  static void listenForNotifications() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("🔔 Foreground Notification Received!");
      if (message.notification != null) {
        print("Title: \${message.notification!.title}");
        print("Body: \${message.notification!.body}");
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("🚀 User tapped on the notification");
      if (message.data.isNotEmpty) {
        print("Data Payload: \${message.data}");
      }
    });
  }



  Future<void> sendNotificationRequest({
    required String userId,
    required String title,
    required String body,
  }) async {
    const String baseUrl = "http://192.168.0.102:3000"; // Replace with your server IP
    final Uri url = Uri.parse("$baseUrl/notifications/send");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "userId": userId,
          "title": title,
          "body": body,
        }),
      );

      if (response.statusCode == 201) {
        print("✅ Notification sent successfully: ${response.body}");
      } else {
        print("❌ Failed to send notification: ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      print("❌ Error sending notification: $e");
    }
  }
}
