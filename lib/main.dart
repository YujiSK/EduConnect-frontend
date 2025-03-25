import 'package:firebase_auth/firebase_auth.dart';
import 'package:frontend/screens/login_screen.dart';

import 'firebase_options.dart';
import 'screens/home_screen.dart';
// import 'screens/login_screen.dart'; // 一時的に未使用
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth/firebase_auth.dart'; // 一時的に未使用

import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  NotificationService().initializeFCM();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EduConnect',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // 🔽 ログインをスキップ
      home: const HomeScreen(),
    );
  }
}

// AuthGate クラスは残しておきますが、現在は使用されていません
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(), // ログイン状態を監視
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator()); // ローディング表示
        }
        if (snapshot.hasData) {
          return const HomeScreen(); // ログイン済みなら HomeScreen を表示
        }
        return const LoginScreen(); // 未ログインなら LoginScreen を表示
      },
    );
  }
}
