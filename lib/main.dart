import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:flutter/material.dart';
import 'package:lensshop/screens/google_login_screen.dart';
import 'package:lensshop/screens/home_screens.dart';
import 'package:lensshop/screens/login_screen.dart';
import 'package:lensshop/themes/light_mode.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    // Web initialization with FirebaseOptions
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyAmaWsyZv1pNV9dkX5Y60pp43BhtvPZ0Ag",
        authDomain: "lensshop-1.firebaseapp.com",
        projectId: "lensshop-1",
        storageBucket: "lensshop-1.firebasestorage.app",
        messagingSenderId: "604478051287",
        appId: "1:604478051287:web:90800b2fba8e957e3bb192",
        measurementId: "G-497VEL8NKW",
      ),
    );
  } else {
    // Mobile initialization (uses google-services.json / GoogleService-Info.plist)
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightMode,
      home:
       //HomeScreen(),
        LoginScreen(),
    );
  }
}
