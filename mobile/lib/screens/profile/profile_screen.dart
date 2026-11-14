import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/app_theme.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/order_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _user;
  int _activeServersCount = 0;
  int _totalOrdersCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    setState(() => _isLoading = true);
    final user = await AuthService.getSavedUser();
    final orders = await OrderService.getMyOrders();

    if (mounted) {
      setState(() {
        _user = user;
        _totalOrdersCount = orders.length;
        _activeServersCount = orders.where((o) => o.isActive).length;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppTheme.border, width: 2.2),
        ),
        title: Text(
          'Konfirmasi Keluar',
          style: GoogleFonts.inter(fontWeight: FontWeight.w800),
        ),
        content: Text(
          'Apakah Anda yakin ingin keluar dari akun ini?',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Batal',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                color: AppTheme.textMuted,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.danger,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: AppTheme.border, width: 1.5),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Keluar',
              style: GoogleFonts.inter(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AuthService.logout();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    }
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppTheme.border, width: 2.2),
        ),
        title: Row(
          children: [
            const Icon(Icons.cloud_circle, color: AppTheme.primary, size: 28),
            const SizedBox(width: 8),
            Text(
              'Tentang ServerCloud',
              style: GoogleFonts.inter(fontWeight: FontWeight.w800),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ServerCloud v1.0.0',
              style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 14),
            ),
            const SizedBox(height: 6),
            Text(
              'Platform Penyedia Layanan Cloud Hosting, VPS, dan Dedicated Server Mandiri untuk UMKM.',
              style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted),
            ),
            const Divider(height: 20),
            Text(
              'Pengembang:\nRafi Arrasyid (NISN: 0095484729)\nKelas XI RPL 3 — SMK Taruna Bhakti',
              style: GoogleFonts.inter(fontSize: 12, height: 1.4),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: AppTheme.border, width: 1.5),
              ),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Tutup',
              style: GoogleFonts.inter(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(
          child: CircularProgressIndicator(strokeWidth: 3, color: AppTheme.primary),
        ),
      );
    }

    final isAdmin = _user?.isAdmin ?? false;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          'Profil Saya',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Tentang Aplikasi',
            icon: const Icon(Icons.info_outline, color: AppTheme.primary),
            onPressed: _showAboutDialog,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        children: [
          // Header Card Profil User
          _buildUserProfileCard(isAdmin),

          const SizedBox(height: 16),

          // Ringkasan Statistik Akun
          _buildStatsRow(),

          const SizedBox(height: 20),

          // Menu Pilihan Profil
          Text(
            'PENGATURAN & LAYANAN',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppTheme.textMuted,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),

          _buildMenuItem(
            icon: Icons.person_outline,
            title: 'Informasi Akun',
            subtitle: _user?.email ?? 'Tidak ada email',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Data profil terverifikasi di server.'),
                  backgroundColor: AppTheme.success,
                ),
              );
            },
          ),
          _buildMenuItem(
            icon: Icons.receipt_long_outlined,
            title: 'Riwayat Transaksi & Invoice',
            subtitle: '$_totalOrdersCount total pesanan sewa',
            onTap: () {
              Navigator.pushNamed(context, '/my-orders');
            },
          ),
          _buildMenuItem(
            icon: Icons.support_agent,
            title: 'Bantuan & Dukungan Teknis UMKM',
            subtitle: 'Layanan konsultasi server 24/7',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tim dukungan ServerCloud siap membantu via WhatsApp.'),
                  backgroundColor: AppTheme.primary,
                ),
              );
            },
          ),
          _buildMenuItem(
            icon: Icons.lock_outline,
            title: 'Keamanan Akun',
            subtitle: 'Enkripsi sandi Bcrypt & Token JWT',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Akun Anda terlindungi dengan standar keamanan JWT.'),
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // Tombol Keluar (Logout)
          Container(
            decoration: AppTheme.neoDecoration(
              color: const Color(0xFFFEE2E2),
              radius: 10,
              borderWidth: 2.0,
              borderColor: AppTheme.danger,
              shadowOffset: const Offset(3, 3),
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: _handleLogout,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.logout, color: AppTheme.danger, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Keluar dari Akun',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.danger,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildUserProfileCard(bool isAdmin) {
    final initials = (_user?.fullName.isNotEmpty ?? false)
        ? _user!.fullName.trim().split(' ').map((w) => w[0]).take(2).join().toUpperCase()
        : 'SC';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.neoDecoration(
        color: AppTheme.surface,
        radius: 14,
        borderWidth: 2.0,
        shadowOffset: const Offset(3.5, 3.5),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 58,
            height: 58,
            decoration: AppTheme.neoDecoration(
              color: isAdmin ? AppTheme.primary : AppTheme.accent,
              radius: 12,
              borderWidth: 2.0,
              shadowOffset: const Offset(2, 2),
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Info Teks
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        _user?.fullName ?? 'Pelanggan ServerCloud',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isAdmin ? const Color(0xFFFEF3C7) : const Color(0xFFE0F2FE),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isAdmin ? const Color(0xFFD97706) : const Color(0xFF0284C7),
                          width: 1.2,
                        ),
                      ),
                      child: Text(
                        (_user?.role ?? 'CLIENT').toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: isAdmin ? const Color(0xFFB45309) : const Color(0xFF0369A1),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _user?.email ?? '',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppTheme.textMuted,
                  ),
                ),
                if (_user?.phone != null && _user!.phone!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    'No. HP: ${_user!.phone}',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            decoration: AppTheme.neoDecoration(
              color: AppTheme.surface,
              radius: 10,
              borderWidth: 1.8,
              shadowOffset: const Offset(2.5, 2.5),
            ),
            child: Column(
              children: [
                Text(
                  '$_activeServersCount',
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.success,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Server Aktif',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            decoration: AppTheme.neoDecoration(
              color: AppTheme.surface,
              radius: 10,
              borderWidth: 1.8,
              shadowOffset: const Offset(2.5, 2.5),
            ),
            child: Column(
              children: [
                Text(
                  '$_totalOrdersCount',
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Total Riwayat Sewa',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: AppTheme.neoDecoration(
        color: AppTheme.surface,
        radius: 10,
        borderWidth: 1.8,
        shadowOffset: const Offset(2.5, 2.5),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.border, width: 1.2),
                  ),
                  child: Icon(icon, size: 18, color: AppTheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, size: 18, color: AppTheme.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
