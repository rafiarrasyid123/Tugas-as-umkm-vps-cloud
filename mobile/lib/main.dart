import 'package:flutter/material.dart';
import 'config/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ServerCloudApp());
}

class ServerCloudApp extends StatelessWidget {
  const ServerCloudApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ServerCloud Mobile',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const Scaffold(
          body: Center(child: Text("Halaman Home (Tahap Selanjutnya)")),
        ),
      },
    );
  }
}
