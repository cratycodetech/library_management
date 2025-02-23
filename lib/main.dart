import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'routes/routes.dart';
import 'services/firebase_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.init();
  await Supabase.initialize(
    url: 'https://utomiwubfeyxyfkkmril.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InV0b21pd3ViZmV5eHlma2ttcmlsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzk5NjAyNjIsImV4cCI6MjA1NTUzNjI2Mn0.faDiJ988isqsYLJqj39N_8nLfLjGjIayh1z_JOTYos8',  // 🔹 Replace with your API Key
  );
  await FlutterDownloader.initialize(
    debug: true,
    ignoreSsl: true,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(

      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.login, // Start with login
      getPages: AppRoutes.pages, // Use predefined routes with bindings

      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FlutterQuillLocalizations.delegate, // ✅ Fixes Missing Localization Error
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
