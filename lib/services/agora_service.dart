import 'dart:convert';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:http/http.dart' as http;

class AgoraService {
  RtcEngine? _engine;
  final String serverUrl = "https://librarymanagementbackend-production-3f5b.up.railway.app/agora/generateToken";



  Future<String> generateToken(String channelName, int uid) async {
    try {
      final response = await http.get(
        Uri.parse("$serverUrl?channelName=$channelName&uid=$uid"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["token"];
      } else {
        throw Exception("Failed to fetch token: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error generating token: $e");
    }
  }

  /// Initializes Agora Engine
  Future<void> initializeAgora(String appId) async {
    _engine = createAgoraRtcEngine();
    await _engine!.initialize(RtcEngineContext(appId: appId));
    await _engine!.enableVideo();
  }

  /// Returns Agora RTC Engine instance
  RtcEngine? getEngine() => _engine;
}