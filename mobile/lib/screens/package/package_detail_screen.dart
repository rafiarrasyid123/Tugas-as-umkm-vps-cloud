import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../config/app_theme.dart';
import '../../models/package_model.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/package_service.dart';
import '../../widgets/app_button.dart';

class PackageDetailScreen extends StatefulWidget {
  const PackageDetailScreen({super.key});

  @override
  State<PackageDetailScreen> createState() => _PackageDetailScreenState();
}

class _PackageDetailScreenState extends State<PackageDetailScreen> {
  PackageModel? _package;
  UserModel? _currentUser;
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_package == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is PackageModel) {
        _package = args;
        _loadFreshData();
      }
    }
  }

  Future<void> _loadFreshData() async {
    final user = await AuthService.getSavedUser();
    if (_package != null) {
      final fresh = await PackageService.getPackageById(_package!.id);
      if (mounted) {
        setState(() {
          _currentUser = user;
          if (fresh != null) _package = fresh;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _currentUser = user;
        });
      }
    }
  }

  String _formatPrice(double price) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return currencyFormatter.format(price);
  }

  Future<void> _handleDelete() async {
    if (_package == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppTheme.border, width: 2.2),
        ),
        title: Text(
          'Hapus Paket Server',
          style: GoogleFonts.inter(fontWeight: FontWeight.w800),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus paket "${_package!.name}"?',
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
              'Hapus',
              style: GoogleFonts.inter(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      final res = await PackageService.deletePackage(_package!.id);
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              res['message'],
              style: GoogleFonts.inter(fontWeight: FontWeight.w700),
            ),
            backgroundColor:
                res['success'] ? AppTheme.success : AppTheme.danger,
          ),
        );
        if (res['success'] == true) {
          Navigator.pop(context, true);
        }
      }
    }
  }

  void _showOrderBottomSheet() {
    if (_package == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          border: Border(
            top: BorderSide(color: AppTheme.border, width: 2.5),
            left: BorderSide(color: AppTheme.border, width: 2.5),
            right: BorderSide(color: AppTheme.border, width: 2.5),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Konfirmasi Pemesanan Layanan',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Detail pesanan paket server UMKM Anda:',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppTheme.textMuted,
              ),
            ),
            const SizedBox(height: 16),

            // Ringkasan Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: AppTheme.neoDecoration(
                color: AppTheme.background,
                radius: 10,
                borderWidth: 1.8,
                shadowOffset: const Offset(2, 2),
              ),
              child: Column(
                children: [
                  _buildSummaryRow('Paket Layanan', _package!.name),
                  const Divider(color: Color(0xFFCBD5E1), height: 16),
                  _buildSummaryRow('Kategori', _package!.categoryName),
                  const Divider(color: Color(0xFFCBD5E1), height: 16),
                  _buildSummaryRow(
                    'Spesifikasi',
                    '${_package!.cpuCores} vCPU / ${_package!.ramGb} GB / ${_package!.storageGb} GB NVMe',
                  ),
                  const Divider(color: Color(0xFFCBD5E1), height: 16),
                  _buildSummaryRow('Durasi Sewa', '1 Bulan (Bulanan)'),
                  const Divider(color: Color(0xFFCBD5E1), height: 16),
                  _buildSummaryRow(
                    'Total Biaya',
                    _formatPrice(_package!.pricePerMonth),
                    isBold: true,
                    highlightColor: AppTheme.primary,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            AppButton(
              text: 'Konfirmasi & Aktivasi Server',
              icon: Icons.check_circle_outline,
              onPressed: () {
                Navigator.pop(ctx);
                _showSuccessOrderDialog();
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _showSuccessOrderDialog() {
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
            const Icon(Icons.check_circle, color: AppTheme.success, size: 26),
            const SizedBox(width: 8),
            Text(
              'Pesanan Diproses!',
              style: GoogleFonts.inter(fontWeight: FontWeight.w800),
            ),
          ],
        ),
        content: Text(
          'Permintaan sewa untuk "${_package!.name}" berhasil dicatat. Tim ServerCloud akan menyiapkan konfigurasi server Anda.',
          style: GoogleFonts.inter(height: 1.4),
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
              'Kembali',
              style: GoogleFonts.inter(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isBold = false,
    Color? highlightColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppTheme.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: GoogleFonts.inter(
              fontSize: isBold ? 14 : 12,
              fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
              color: highlightColor ?? AppTheme.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_package == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Paket')),
        body: const Center(child: Text('Data paket tidak ditemukan')),
      );
    }

    final isAdmin = _currentUser?.isAdmin ?? false;
    final isOutOfStock = _package!.stockAvailable <= 0;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          _package!.name,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
        actions: [
          if (isAdmin)
            IconButton(
              tooltip: 'Edit Paket',
              icon: const Icon(Icons.edit, size: 20, color: AppTheme.primary),
              onPressed: () async {
                final updated = await Navigator.pushNamed(
                  context,
                  '/package/form',
                  arguments: _package,
                );
                if (updated == true) {
                  _loadFreshData();
                }
              },
            ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(isAdmin, isOutOfStock),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: AppTheme.primary,
              ),
            )
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                // Banner / Foto Server
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: AppTheme.neoDecoration(
                    color: const Color(0xFF1E293B),
                    radius: 12,
                    borderWidth: 2.0,
                    shadowOffset: const Offset(3.5, 3.5),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: _package!.imageUrl != null &&
                            _package!.imageUrl!.isNotEmpty
                        ? Image.network(
                            _package!.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildDefaultBanner(),
                          )
                        : _buildDefaultBanner(),
                  ),
                ),

                const SizedBox(height: 16),

                // Kategori & Stock Status Badges
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: AppTheme.neoDecoration(
                        color: AppTheme.surface,
                        radius: 8,
                        borderWidth: 1.8,
                        shadowOffset: const Offset(2, 2),
                      ),
                      child: Text(
                        _package!.categoryName.toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: AppTheme.neoDecoration(
                        color: isOutOfStock ? AppTheme.danger : AppTheme.success,
                        radius: 8,
                        borderWidth: 1.8,
                        shadowOffset: const Offset(2, 2),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isOutOfStock ? Icons.cancel : Icons.check_circle,
                            size: 13,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            isOutOfStock
                                ? 'STOK HABIS'
                                : 'TERSEDIA (${_package!.stockAvailable} UNIT)',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Title & Price Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: AppTheme.neoDecoration(
                    color: AppTheme.surface,
                    radius: 12,
                    borderWidth: 2.0,
                    shadowOffset: const Offset(3, 3),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _package!.name,
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textPrimary,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            _formatPrice(_package!.pricePerMonth),
                            style: GoogleFonts.inter(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.primary,
                            ),
                          ),
                          Text(
                            ' / bulan',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Grid Spesifikasi Teknis
                Text(
                  'Spesifikasi Performa',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),

                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 2.1,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  children: [
                    _buildSpecTile(
                      icon: Icons.memory,
                      label: 'Processor vCPU',
                      value: '${_package!.cpuCores} Core High-Freq',
                    ),
                    _buildSpecTile(
                      icon: Icons.speed,
                      label: 'RAM Memory',
                      value: '${_package!.ramGb} GB DDR4 ECC',
                    ),
                    _buildSpecTile(
                      icon: Icons.storage,
                      label: 'Storage Drive',
                      value: '${_package!.storageGb} GB NVMe SSD',
                    ),
                    _buildSpecTile(
                      icon: Icons.wifi,
                      label: 'Bandwidth Jaringan',
                      value: '${_package!.bandwidthTb} TB / Bulan',
                    ),
                    _buildSpecTile(
                      icon: Icons.shield,
                      label: 'Keamanan DDoS',
                      value: 'DDoS Guard Pro',
                    ),
                    _buildSpecTile(
                      icon: Icons.network_check,
                      label: 'SLA Uptime',
                      value: '99.98% Guarantee',
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Deskripsi Lengkap
                if (_package!.description != null &&
                    _package!.description!.isNotEmpty) ...[
                  Text(
                    'Deskripsi & Peruntukan Layanan',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: AppTheme.neoDecoration(
                      color: AppTheme.surface,
                      radius: 10,
                      borderWidth: 1.8,
                      shadowOffset: const Offset(2.5, 2.5),
                    ),
                    child: Text(
                      _package!.description!,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppTheme.textPrimary,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ],
            ),
    );
  }

  Widget _buildSpecTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: AppTheme.neoDecoration(
        color: AppTheme.surface,
        radius: 10,
        borderWidth: 1.8,
        shadowOffset: const Offset(2, 2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppTheme.border, width: 1.2),
            ),
            child: Icon(icon, size: 18, color: AppTheme.primary),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textMuted,
                  ),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(bool isAdmin, bool isOutOfStock) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(top: BorderSide(color: AppTheme.border, width: 2.0)),
      ),
      child: SafeArea(
        child: isAdmin
            ? Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: 'Hapus Paket',
                      backgroundColor: AppTheme.danger,
                      icon: Icons.delete_outline,
                      onPressed: _handleDelete,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      text: 'Edit Spesifikasi',
                      icon: Icons.edit,
                      onPressed: () async {
                        final res = await Navigator.pushNamed(
                          context,
                          '/package/form',
                          arguments: _package,
                        );
                        if (res == true) {
                          _loadFreshData();
                        }
                      },
                    ),
                  ),
                ],
              )
            : AppButton(
                text: isOutOfStock ? 'Stok Tidak Tersedia' : 'Sewa Paket Sekarang',
                icon: Icons.shopping_bag_outlined,
                backgroundColor:
                    isOutOfStock ? const Color(0xFF94A3B8) : AppTheme.primary,
                onPressed: isOutOfStock ? null : _showOrderBottomSheet,
              ),
      ),
    );
  }

  Widget _buildDefaultBanner() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.dns, size: 48, color: Color(0xFF94A3B8)),
          const SizedBox(height: 8),
          Text(
            'SERVERCLOUD CLUSTER NODE',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF64748B),
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
