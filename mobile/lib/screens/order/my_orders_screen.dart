import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../config/app_theme.dart';
import '../../models/order_model.dart';
import '../../services/order_service.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  List<OrderModel> _orders = [];
  bool _isLoading = true;
  String _filter = 'all'; // 'all', 'active', 'pending'

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() => _isLoading = true);
    final list = await OrderService.getMyOrders();
    if (mounted) {
      setState(() {
        _orders = list;
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

  List<OrderModel> get _filteredOrders {
    if (_filter == 'active') {
      return _orders.where((o) => o.isActive).toList();
    } else if (_filter == 'pending') {
      return _orders.where((o) => o.isPending).toList();
    }
    return _orders;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          'Server & Riwayat Sewa',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
      body: RefreshIndicator(
        color: AppTheme.primary,
        onRefresh: _fetchOrders,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // Filter Pills
            Row(
              children: [
                _buildFilterChip('Semua (${_orders.length})', 'all'),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Aktif (${_orders.where((o) => o.isActive).length})',
                  'active',
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Menunggu Bayar (${_orders.where((o) => o.isPending).length})',
                  'pending',
                ),
              ],
            ),

            const SizedBox(height: 16),

            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: AppTheme.primary,
                  ),
                ),
              )
            else if (_filteredOrders.isEmpty)
              _buildEmptyState()
            else
              ..._filteredOrders.map((order) => _buildOrderCard(order)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filter == value;
    return GestureDetector(
      onTap: () => setState(() => _filter = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: AppTheme.neoDecoration(
          color: isSelected ? AppTheme.primary : AppTheme.surface,
          radius: 8,
          borderWidth: 1.8,
          shadowOffset: isSelected ? const Offset(2.5, 2.5) : const Offset(1.5, 1.5),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: isSelected ? Colors.white : AppTheme.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    final isPending = order.isPending;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: AppTheme.neoDecoration(
        color: AppTheme.surface,
        radius: 12,
        borderWidth: 2.0,
        shadowOffset: const Offset(3.5, 3.5),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.pushNamed(
              context,
              '/order/detail',
              arguments: order,
            ).then((_) => _fetchOrders());
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      order.orderNumber,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textMuted,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isPending ? const Color(0xFFFEF3C7) : const Color(0xFFD1FAE5),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: isPending ? const Color(0xFFF59E0B) : AppTheme.success,
                          width: 1.2,
                        ),
                      ),
                      child: Text(
                        isPending ? 'MENUNGGU BAYAR' : 'AKTIF',
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: isPending ? const Color(0xFFB45309) : const Color(0xFF047857),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Nama Paket
                Text(
                  order.packageName ?? 'Paket Cloud Server',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),

                if (order.categoryName != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    order.categoryName!,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                    ),
                  ),
                ],

                // IP Address Box jika aktif
                if (order.isActive && order.serverIp != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFF86EFAC), width: 1.0),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.circle, size: 8, color: AppTheme.success),
                        const SizedBox(width: 6),
                        Text(
                          'IP: ${order.serverIp}',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF166534),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 10),
                const Divider(color: Color(0xFFE2E8F0), height: 1),
                const SizedBox(height: 8),

                // Footer Card
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Durasi: ${order.durationMonths} Bulan',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppTheme.textMuted,
                      ),
                    ),
                    Text(
                      _formatPrice(order.totalPrice),
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.primary,
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

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: AppTheme.neoDecoration(
        color: AppTheme.surface,
        radius: 12,
        borderWidth: 2.0,
        shadowOffset: const Offset(3, 3),
      ),
      child: Column(
        children: [
          const Icon(Icons.receipt_long_outlined, size: 48, color: AppTheme.textMuted),
          const SizedBox(height: 12),
          Text(
            'Belum Ada Server Disewa',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Pilih paket cloud hosting atau VPS di katalog untuk mulai menyewa server UMKM Anda.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppTheme.textMuted,
            ),
          ),
          const SizedBox(height: 16),
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
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Lihat Katalog Layanan',
              style: GoogleFonts.inter(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}
