import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  String _selectedRole = 'client';
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final res = await AuthService.register(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      phone: _phoneController.text.trim(),
      role: _selectedRole,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Registrasi berhasil! Silakan login.',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          backgroundColor: AppTheme.success,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            res['message'] ?? 'Registrasi gagal',
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
      appBar: AppBar(
        title: const Text('DAFTAR AKUN BARU'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
            child: Container(
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
                    const Text(
                      'BUAT AKUN SERVERCLOUD',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Pilih paket cloud dan kelola server UMKM Anda.',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textMuted,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Nama Lengkap
                    AppTextField(
                      controller: _nameController,
                      label: 'Nama Lengkap',
                      hint: 'Rafi Arrasyid',
                      prefixIcon: const Icon(Icons.person_outline, size: 20),
                      validator: (val) {
                        if (val == null || val.trim().length < 3) {
                          return 'Nama minimal 3 karakter';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // Email
                    AppTextField(
                      controller: _emailController,
                      label: 'Email',
                      hint: 'nama@domain.com',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(Icons.email_outlined, size: 20),
                      validator: (val) {
                        if (val == null || !val.contains('@')) {
                          return 'Format email tidak valid';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // Nomor Telepon
                    AppTextField(
                      controller: _phoneController,
                      label: 'Nomor WhatsApp / HP',
                      hint: '081234567890',
                      keyboardType: TextInputType.phone,
                      prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                    ),
                    const SizedBox(height: 14),

                    // Password
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
                        if (val == null || val.length < 6) {
                          return 'Kata sandi minimal 6 karakter';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // Pemilihan Role
                    const Text(
                      'ROLE PENGGUNA',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedRole = 'client'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: AppTheme.neoDecoration(
                                color: _selectedRole == 'client' ? AppTheme.accentSoft : Colors.white,
                                radius: 8,
                                borderWidth: 2.0,
                                borderColor: _selectedRole == 'client' ? AppTheme.accent : AppTheme.border,
                                shadowOffset: const Offset(2, 2),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Client (Pelanggan)',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: _selectedRole == 'client' ? const Color(0xFF0284C7) : AppTheme.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedRole = 'admin'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: AppTheme.neoDecoration(
                                color: _selectedRole == 'admin' ? AppTheme.primaryLight : Colors.white,
                                radius: 8,
                                borderWidth: 2.0,
                                borderColor: _selectedRole == 'admin' ? AppTheme.primary : AppTheme.border,
                                shadowOffset: const Offset(2, 2),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Admin (Pengelola)',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: _selectedRole == 'admin' ? AppTheme.primary : AppTheme.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Tombol Submit
                    AppButton(
                      text: 'DAFTAR SEKARANG',
                      icon: Icons.person_add_rounded,
                      isLoading: _isLoading,
                      onPressed: _handleRegister,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
