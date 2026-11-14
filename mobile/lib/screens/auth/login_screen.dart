import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _fillAccount(String email, String password) {
    setState(() {
      _emailController.text = email;
      _passwordController.text = password;
    });
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final res = await AuthService.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (res['success'] == true) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            res['message'] ?? 'Login gagal',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          backgroundColor: AppTheme.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Card Login Neo-Brutalist
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: AppTheme.neoDecoration(
                    color: AppTheme.surface,
                    radius: 16,
                    borderWidth: 2.5,
                    shadowOffset: const Offset(5, 5),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: AppTheme.neoDecoration(
                                color: AppTheme.primaryLight,
                                radius: 10,
                                borderWidth: 1.8,
                                borderColor: AppTheme.primary,
                                shadowOffset: const Offset(2, 2),
                              ),
                              child: const Icon(
                                Icons.cloud_done_rounded,
                                color: AppTheme.primary,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'MASUK AKUN',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                Text(
                                  'ServerCloud UMKM Platform',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Input Email
                        AppTextField(
                          controller: _emailController,
                          label: 'Email Pengguna',
                          hint: 'nama@servercloud.id',
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: const Icon(Icons.email_outlined, size: 20),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Email wajib diisi';
                            }
                            if (!val.contains('@')) {
                              return 'Format email tidak valid';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Input Password
                        AppTextField(
                          controller: _passwordController,
                          label: 'Kata Sandi',
                          hint: 'Minimal 6 karakter',
                          obscureText: _obscurePassword,
                          prefixIcon: const Icon(Icons.lock_outline, size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              size: 20,
                              color: AppTheme.textMuted,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Password wajib diisi';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Tombol Login
                        AppButton(
                          text: 'MASUK SEKARANG',
                          icon: Icons.login_rounded,
                          isLoading: _isLoading,
                          onPressed: _handleLogin,
                        ),
                        const SizedBox(height: 20),

                        // Shortcut Akun Ujian (Biar gampang saat demo ke guru)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'AKUN CEPAT PENGUJIAN UJIAN:',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 6),
                                        side: const BorderSide(color: AppTheme.primary),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                      ),
                                      onPressed: () => _fillAccount('admin@servercloud.id', 'password123'),
                                      child: const Text(
                                        'Admin',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          color: AppTheme.primary,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 6),
                                        side: const BorderSide(color: AppTheme.accent),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                      ),
                                      onPressed: () => _fillAccount('client@servercloud.id', 'password123'),
                                      child: const Text(
                                        'Client',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF0284C7),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Link ke Register
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Belum memiliki akun? ',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textMuted,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/register'),
                      child: const Text(
                        'Daftar di sini',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
