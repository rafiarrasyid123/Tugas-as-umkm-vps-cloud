import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../config/app_theme.dart';
import '../../models/order_model.dart';
import '../../services/order_service.dart';
import '../../widgets/app_button.dart';

class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({super.key});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  OrderModel? _order;
  bool _isLoading = false;
  bool _isPaying = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_order == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is OrderModel) {
        _order = args;
        _loadFreshDetail();
      }
    }
  }

  Future<void> _loadFreshDetail() async {
    if (_order == null) return;
    setState(() => _isLoading = true);
    final fresh = await OrderService.getOrderById(_order!.id);
    if (mounted) {
      setState(() {
        if (fresh != null) _order = fresh;
        _isLoading = false;
      });
    }
  }

  String _formatPrice(double price) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(price);
  }

  Future<void> _handlePaySimulation() async {
    if (_order == null) return;

    setState(() => _isPaying = true);
    final res = await OrderService.payOrder(_order!.id);
    setState(() => _isPaying = false);

    if (!mounted) return;

    if (res['success'] == true) {
      setState(() {
        _order = res['data'];
      });

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
              const Icon(Icons.check_circle, color: AppTheme.success, size: 28),
              const SizedBox(width: 8),
              Text(
                'Pembayaran Lunas!',
                style: GoogleFonts.inter(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          content: Text(
            'Server Cloud Anda berhasil diaktifkan dengan alokasi IP Address:\n${_order!.serverIp ?? "103.187.45.12"}\n\nLayanan kini siap digunakan untuk deployment UMKM Anda.',
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
                'Lihat Server Saya',
                style: GoogleFonts.inter(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message']),
          backgroundColor: AppTheme.danger,
        ),
      );
    }
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label berhasil disalin ke clipboard!'),
        backgroundColor: AppTheme.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Invoice')),
        body: const Center(child: Text('Data pesanan tidak ditemukan')),
      );
    }

    final isPending = _order!.isPending;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          isPending ? 'Tagihan Sewa (Invoice)' : 'Detail Server Aktif',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(isPending),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: AppTheme.primary,
              ),
            )
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              children: [
                // Header Status Badge & Nomor Invoice
                _buildInvoiceHeader(isPending),

                const SizedBox(height: 16),

                // Jika server sudah aktif, tampilkan Banner Kredensial Server
                if (!isPending) ...[
                  _buildServerCredentialsCard(),
                  const SizedBox(height: 16),
                ],

                // Rincian Paket yang Disewa
                _buildPackageDetailsCard(),

                const SizedBox(height: 16),

                // Rincian Metode Pembayaran
                if (isPending) ...[
                  _buildPaymentMethodCard(),
                  const SizedBox(height: 16),
                ],

                // Petunjuk Pembayaran Singkat
                if (isPending) _buildPaymentInstructions(),

                const SizedBox(height: 30),
              ],
            ),
    );
  }

  Widget _buildInvoiceHeader(bool isPending) {
    return Container(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'NOMOR INVOICE',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textMuted,
                  letterSpacing: 0.8,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: AppTheme.neoDecoration(
                  color: isPending ? const Color(0xFFFEF3C7) : const Color(0xFFD1FAE5),
                  radius: 6,
                  borderWidth: 1.5,
                  shadowOffset: const Offset(1.5, 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPending ? Icons.pending_actions : Icons.verified,
                      size: 13,
                      color: isPending ? const Color(0xFFD97706) : AppTheme.success,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isPending ? 'MENUNGGU PEMBAYARAN' : 'SERVER AKTIF / LUNAS',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: isPending ? const Color(0xFFD97706) : AppTheme.success,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _order!.orderNumber,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppTheme.textPrimary,
              letterSpacing: -0.2,
            ),
          ),
          if (_order!.createdAt != null) ...[
            const SizedBox(height: 4),
            Text(
              'Tanggal Pemesanan: ${DateFormat('dd MMMM yyyy, HH:mm').format(_order!.createdAt!)} WIB',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AppTheme.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildServerCredentialsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.neoDecoration(
        color: const Color(0xFFECFDF5),
        radius: 12,
        borderWidth: 2.0,
        borderColor: AppTheme.success,
        shadowOffset: const Offset(3.5, 3.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.dns, color: AppTheme.success, size: 20),
              const SizedBox(width: 8),
              Text(
                'Alokasi Node Server Aktif',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF065F46),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildCopyableRow('IP Address Publik', _order!.serverIp ?? '103.187.22.45'),
          const Divider(color: Color(0xFFA7F3D0), height: 16),
          _buildCopyableRow('Port SSH / Akses', '22'),
          const Divider(color: Color(0xFFA7F3D0), height: 16),
          _buildCopyableRow('Username Default', 'root'),
          const Divider(color: Color(0xFFA7F3D0), height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Status Node',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: const Color(0xFF047857),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.success,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'ONLINE (99.98% SLA)',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCopyableRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: const Color(0xFF047857),
            fontWeight: FontWeight.w600,
          ),
        ),
        Row(
          children: [
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF065F46),
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () => _copyToClipboard(value, label),
              child: const Icon(Icons.copy, size: 14, color: Color(0xFF047857)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPackageDetailsCard() {
    return Container(
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
            'RINCIAN SEWA LAYANAN',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppTheme.textMuted,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),
          _buildItemRow('Paket Layanan', _order!.packageName ?? 'Paket Cloud VPS'),
          const Divider(color: Color(0xFFE2E8F0), height: 16),
          if (_order!.categoryName != null) ...[
            _buildItemRow('Kategori', _order!.categoryName!),
            const Divider(color: Color(0xFFE2E8F0), height: 16),
          ],
          if (_order!.cpuCores != null && _order!.ramGb != null) ...[
            _buildItemRow(
              'Spesifikasi',
              '${_order!.cpuCores} vCPU / ${_order!.ramGb} GB RAM / ${_order!.storageGb} GB NVMe',
            ),
            const Divider(color: Color(0xFFE2E8F0), height: 16),
          ],
          _buildItemRow('Durasi Sewa', '${_order!.durationMonths} Bulan'),
          const Divider(color: Color(0xFFE2E8F0), height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Pembayaran',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                _formatPrice(_order!.totalPrice),
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard() {
    final method = _order!.paymentMethod.toUpperCase().replaceAll('_', ' ');
    final paymentCode = _order!.paymentCode ?? '88012948271048';

    return Container(
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
            'METODE PEMBAYARAN',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppTheme.textMuted,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppTheme.border, width: 1.2),
                ),
                child: const Icon(Icons.account_balance, size: 20, color: AppTheme.primary),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    'Virtual Account Otomatis 24 Jam',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nomor Virtual Account',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textMuted,
                      ),
                    ),
                    Text(
                      paymentCode,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.surface,
                    foregroundColor: AppTheme.textPrimary,
                    elevation: 0,
                    side: const BorderSide(color: AppTheme.border, width: 1.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  ),
                  onPressed: () => _copyToClipboard(paymentCode, 'Nomor VA'),
                  icon: const Icon(Icons.copy, size: 14),
                  label: Text(
                    'Salin',
                    style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInstructions() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppTheme.neoDecoration(
        color: AppTheme.surface,
        radius: 10,
        borderWidth: 1.8,
        shadowOffset: const Offset(2.5, 2.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, size: 16, color: AppTheme.primary),
              const SizedBox(width: 6),
              Text(
                'Petunjuk Pembayaran:',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '1. Buka aplikasi m-Banking atau ATM bank Anda.\n'
            '2. Pilih menu Transfer > Virtual Account.\n'
            '3. Masukkan Nomor Virtual Account di atas.\n'
            '4. Periksa kecocokan nama dan total tagihan.\n'
            '5. Selesaikan transaksi. Server Cloud Anda akan otomatis aktif.',
            style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(String label, String value) {
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
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(bool isPending) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(top: BorderSide(color: AppTheme.border, width: 2.0)),
      ),
      child: SafeArea(
        child: isPending
            ? AppButton(
                text: 'Simulasi Bayar Sekarang',
                icon: Icons.payments,
                backgroundColor: AppTheme.success,
                isLoading: _isPaying,
                onPressed: _handlePaySimulation,
              )
            : AppButton(
                text: 'Kelola Server / Konsol SSH',
                icon: Icons.terminal,
                backgroundColor: AppTheme.primary,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: AppTheme.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: AppTheme.border, width: 2.2),
                      ),
                      title: Text(
                        'Konsol SSH Server',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w800),
                      ),
                      content: Text(
                        'Gunakan terminal Anda untuk terhubung ke VPS:\n\nssh root@${_order!.serverIp ?? "103.187.22.45"} -p 22',
                        style: GoogleFonts.inter(fontFamily: 'monospace', fontSize: 12),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Tutup'),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
