import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    await Future.delayed(const Duration(milliseconds: 1200));
    final loggedIn = await AuthService.isLoggedIn();
    if (!mounted) return;

    if (loggedIn) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
                decoration: AppTheme.neoDecoration(
                  color: AppTheme.surface,
                  radius: 16,
                  borderWidth: 2.5,
                  shadowOffset: const Offset(5, 5),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: AppTheme.neoDecoration(
                        color: AppTheme.primaryLight,
                        radius: 16,
                        borderWidth: 2.2,
                        shadowOffset: const Offset(3, 3),
                        borderColor: AppTheme.primary,
                      ),
                      child: const Icon(
                        Icons.cloud_queue_rounded,
                        size: 42,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'SERVERCLOUD',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Cloud & VPS Hosting UMKM',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textMuted,
                      ),
                    ),
                    const SizedBox(height: 28),
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.8,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
