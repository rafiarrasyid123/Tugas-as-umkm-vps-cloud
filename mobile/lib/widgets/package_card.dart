import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../config/app_theme.dart';
import '../models/package_model.dart';

class PackageCard extends StatelessWidget {
  final PackageModel package;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isAdmin;

  const PackageCard({
    super.key,
    required this.package,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.isAdmin = false,
  });

  String _formatPrice(double price) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return currencyFormatter.format(price);
  }

  @override
  Widget build(BuildContext context) {
    final isOutOfStock = package.stockAvailable <= 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: AppTheme.neoDecoration(
        color: AppTheme.surface,
        radius: 14,
        borderWidth: 2.0,
        shadowOffset: const Offset(4, 4),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Image / Banner
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Container(
                      height: 140,
                      width: double.infinity,
                      color: const Color(0xFF1E293B),
                      child: package.imageUrl != null && package.imageUrl!.isNotEmpty
                          ? Image.network(
                              package.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  _buildDefaultBanner(),
                            )
                          : _buildDefaultBanner(),
                    ),
                  ),

                  // Kategori Badge di Kiri Atas
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: AppTheme.neoDecoration(
                        color: AppTheme.surface,
                        radius: 6,
                        borderWidth: 1.5,
                        shadowOffset: const Offset(2, 2),
                      ),
                      child: Text(
                        package.categoryName.toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),

                  // Stock Badge di Kanan Atas
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: AppTheme.neoDecoration(
                        color: isOutOfStock ? AppTheme.danger : AppTheme.success,
                        radius: 6,
                        borderWidth: 1.5,
                        shadowOffset: const Offset(2, 2),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isOutOfStock ? Icons.cancel : Icons.check_circle,
                            size: 11,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isOutOfStock ? 'HABIS' : 'STOK ${package.stockAvailable}',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Detail Konten
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nama Paket & Menu Aksi Admin
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            package.name,
                            style: GoogleFonts.inter(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                              letterSpacing: -0.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isAdmin) ...[
                          const SizedBox(width: 8),
                          _buildAdminActionButton(
                            icon: Icons.edit_outlined,
                            color: AppTheme.primary,
                            onTap: onEdit,
                          ),
                          const SizedBox(width: 6),
                          _buildAdminActionButton(
                            icon: Icons.delete_outline,
                            color: AppTheme.danger,
                            onTap: onDelete,
                          ),
                        ],
                      ],
                    ),

                    if (package.description != null && package.description!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        package.description!,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppTheme.textMuted,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    const SizedBox(height: 12),

                    // Grid / Baris Spesifikasi Server
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _buildSpecChip(
                          icon: Icons.memory,
                          label: '${package.cpuCores} vCPU',
                        ),
                        _buildSpecChip(
                          icon: Icons.speed,
                          label: '${package.ramGb} GB RAM',
                        ),
                        _buildSpecChip(
                          icon: Icons.storage,
                          label: '${package.storageGb} GB NVMe',
                        ),
                        _buildSpecChip(
                          icon: Icons.wifi,
                          label: '${package.bandwidthTb} TB Bandwidth',
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),
                    const Divider(color: AppTheme.border, thickness: 1.2, height: 1),
                    const SizedBox(height: 10),

                    // Harga & Tombol Aksi
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Harga Sewa',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textMuted,
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                text: _formatPrice(package.pricePerMonth),
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.primary,
                                ),
                                children: [
                                  TextSpan(
                                    text: ' /bln',
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        // Tombol Lihat Detail / Pesan
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: AppTheme.neoDecoration(
                            color: isOutOfStock ? const Color(0xFFCBD5E1) : AppTheme.primary,
                            radius: 8,
                            borderWidth: 1.8,
                            shadowOffset: const Offset(2, 2),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                isOutOfStock ? 'Lihat Spesifikasi' : 'Pilih Paket',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: isOutOfStock ? AppTheme.textMuted : Colors.white,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward,
                                size: 14,
                                color: isOutOfStock ? AppTheme.textMuted : Colors.white,
                              ),
                            ],
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
    );
  }

  Widget _buildDefaultBanner() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.dns, size: 40, color: Color(0xFF94A3B8)),
          const SizedBox(height: 6),
          Text(
            'SERVERCLOUD CLUSTER',
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

  Widget _buildSpecChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppTheme.textPrimary),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminActionButton({
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: AppTheme.neoDecoration(
          color: AppTheme.surface,
          radius: 6,
          borderWidth: 1.5,
          shadowOffset: const Offset(1.5, 1.5),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}
