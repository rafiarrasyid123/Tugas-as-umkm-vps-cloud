import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/app_theme.dart';
import '../../models/category_model.dart';
import '../../models/package_model.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/category_service.dart';
import '../../services/package_service.dart';
import '../../widgets/package_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserModel? _currentUser;
  List<CategoryModel> _categories = [];
  List<PackageModel> _packages = [];

  bool _isLoading = true;
  int? _selectedCategoryId; // null = Semua
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);

    // Ambil data user yang sedang login
    final user = await AuthService.getSavedUser();
    
    // Ambil kategori & paket dari backend live
    final categories = await CategoryService.getCategories();
    final packages = await PackageService.getPackages();

    if (mounted) {
      setState(() {
        _currentUser = user;
        _categories = categories;
        _packages = packages;
        _isLoading = false;
      });
    }
  }

  Future<void> _filterPackages() async {
    setState(() => _isLoading = true);
    final packages = await PackageService.getPackages(
      categoryId: _selectedCategoryId,
      search: _searchQuery,
    );
    if (mounted) {
      setState(() {
        _packages = packages;
        _isLoading = false;
      });
    }
  }

  void _onCategorySelected(int? categoryId) {
    if (_selectedCategoryId == categoryId) return;
    setState(() {
      _selectedCategoryId = categoryId;
    });
    _filterPackages();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _filterPackages();
  }

  Future<void> _handleDeletePackage(PackageModel package) async {
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
          'Apakah Anda yakin ingin menghapus paket "${package.name}"?',
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
      final result = await PackageService.deletePackage(package.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'],
              style: GoogleFonts.inter(fontWeight: FontWeight.w700),
            ),
            backgroundColor:
                result['success'] ? AppTheme.success : AppTheme.danger,
          ),
        );
        _filterPackages();
      }
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
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = _currentUser?.isAdmin ?? false;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: _buildAppBar(isAdmin),
      floatingActionButton: isAdmin
          ? _buildAddPackageFab()
          : null,
      body: RefreshIndicator(
        color: AppTheme.primary,
        onRefresh: _filterPackages,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          children: [
            // Search Input Field
            _buildSearchBar(),

            const SizedBox(height: 16),

            // Kategori Chips Horizontal
            _buildCategoryChips(),

            const SizedBox(height: 16),

            // Header Hasil & Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Daftar Layanan Tersedia',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppTheme.border, width: 1.2),
                  ),
                  child: Text(
                    '${_packages.length} Paket',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // List Paket
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
            else if (_packages.isEmpty)
              _buildEmptyState()
            else
              ..._packages.map(
                (pkg) => PackageCard(
                  package: pkg,
                  isAdmin: isAdmin,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/package/detail',
                      arguments: pkg,
                    ).then((_) => _filterPackages());
                  },
                  onEdit: () {
                    Navigator.pushNamed(
                      context,
                      '/package/form',
                      arguments: pkg,
                    ).then((_) => _filterPackages());
                  },
                  onDelete: () => _handleDeletePackage(pkg),
                ),
              ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isAdmin) {
    return AppBar(
      titleSpacing: 16,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: AppTheme.neoDecoration(
              color: AppTheme.primary,
              radius: 8,
              borderWidth: 1.8,
              shadowOffset: const Offset(2, 2),
            ),
            child: const Icon(Icons.cloud_queue, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SERVERCLOUD',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                _currentUser != null
                    ? 'Halo, ${_currentUser!.fullName}'
                    : 'Katalog Layanan Cloud',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        // Role Badge
        if (_currentUser != null)
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: AppTheme.neoDecoration(
              color: isAdmin ? const Color(0xFFFEF3C7) : const Color(0xFFE0F2FE),
              radius: 6,
              borderWidth: 1.5,
              shadowOffset: const Offset(1.5, 1.5),
            ),
            child: Text(
              _currentUser!.role.toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: isAdmin ? const Color(0xFFD97706) : const Color(0xFF0284C7),
              ),
            ),
          ),

        // Logout Button
        IconButton(
          tooltip: 'Keluar',
          icon: const Icon(Icons.logout, size: 20, color: AppTheme.danger),
          onPressed: _handleLogout,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: AppTheme.neoDecoration(
        color: AppTheme.surface,
        radius: 10,
        borderWidth: 2.0,
        shadowOffset: const Offset(3, 3),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'Cari paket hosting, vps, nvme...',
          hintStyle: GoogleFonts.inter(
            fontSize: 13,
            color: AppTheme.textMuted,
          ),
          prefixIcon: const Icon(Icons.search, color: AppTheme.textPrimary, size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildChipItem(
            label: 'Semua Layanan',
            isSelected: _selectedCategoryId == null,
            onTap: () => _onCategorySelected(null),
          ),
          ..._categories.map(
            (cat) => _buildChipItem(
              label: cat.name,
              isSelected: _selectedCategoryId == cat.id,
              onTap: () => _onCategorySelected(cat.id),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChipItem({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: AppTheme.neoDecoration(
            color: isSelected ? AppTheme.primary : AppTheme.surface,
            radius: 8,
            borderWidth: 1.8,
            shadowOffset: isSelected ? const Offset(2.5, 2.5) : const Offset(1.5, 1.5),
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: isSelected ? Colors.white : AppTheme.textPrimary,
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
          const Icon(Icons.cloud_off, size: 48, color: AppTheme.textMuted),
          const SizedBox(height: 12),
          Text(
            'Tidak Ada Paket Ditemukan',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Coba ubah kata kunci pencarian atau pilih kategori layanan lain.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddPackageFab() {
    return Container(
      decoration: AppTheme.neoDecoration(
        color: AppTheme.primary,
        radius: 14,
        borderWidth: 2.2,
        shadowOffset: const Offset(3.5, 3.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            Navigator.pushNamed(context, '/package/form').then((_) => _filterPackages());
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add, color: Colors.white, size: 20),
                const SizedBox(width: 6),
                Text(
                  'Tambah Paket',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
