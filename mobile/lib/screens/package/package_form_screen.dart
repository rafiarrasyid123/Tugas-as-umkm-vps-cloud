import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/app_theme.dart';
import '../../models/category_model.dart';
import '../../models/package_model.dart';
import '../../services/category_service.dart';
import '../../services/package_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

class PackageFormScreen extends StatefulWidget {
  const PackageFormScreen({super.key});

  @override
  State<PackageFormScreen> createState() => _PackageFormScreenState();
}

class _PackageFormScreenState extends State<PackageFormScreen> {
  final _formKey = GlobalKey<FormState>();

  PackageModel? _editingPackage;
  bool _isInit = false;
  bool _isLoading = false;
  bool _isSaving = false;

  List<CategoryModel> _categories = [];
  int? _selectedCategoryId;

  final _nameController = TextEditingController();
  final _cpuController = TextEditingController();
  final _ramController = TextEditingController();
  final _storageController = TextEditingController();
  final _bandwidthController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _descriptionController = TextEditingController();

  final _picker = ImagePicker();
  File? _imageFile;
  String? _existingImageUrl;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      _isInit = true;
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is PackageModel) {
        _editingPackage = args;
        _populateFields(args);
      }
      _loadCategories();
    }
  }

  void _populateFields(PackageModel pkg) {
    _selectedCategoryId = pkg.categoryId;
    _nameController.text = pkg.name;
    _cpuController.text = pkg.cpuCores.toString();
    _ramController.text = pkg.ramGb.toString();
    _storageController.text = pkg.storageGb.toString();
    _bandwidthController.text = pkg.bandwidthTb.toString();
    _priceController.text = pkg.pricePerMonth.toStringAsFixed(0);
    _stockController.text = pkg.stockAvailable.toString();
    _descriptionController.text = pkg.description ?? '';
    _existingImageUrl = pkg.imageUrl;
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    final list = await CategoryService.getCategories();
    if (mounted) {
      setState(() {
        _categories = list;
        if (_selectedCategoryId == null && list.isNotEmpty) {
          _selectedCategoryId = list.first.id;
        }
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cpuController.dispose();
    _ramController.dispose();
    _storageController.dispose();
    _bandwidthController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (picked != null) {
        setState(() {
          _imageFile = File(picked.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memilih gambar: $e'),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    }
  }

  void _showImagePickerModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
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
              'Pilih Sumber Foto Server',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: 'Kamera',
                    icon: Icons.camera_alt,
                    isOutlined: true,
                    onPressed: () {
                      Navigator.pop(ctx);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    text: 'Galeri HP',
                    icon: Icons.photo_library,
                    onPressed: () {
                      Navigator.pop(ctx);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih kategori layanan'),
          backgroundColor: AppTheme.danger,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final name = _nameController.text.trim();
    final cpu = int.tryParse(_cpuController.text.trim()) ?? 1;
    final ram = int.tryParse(_ramController.text.trim()) ?? 1;
    final storage = int.tryParse(_storageController.text.trim()) ?? 10;
    final bandwidth = int.tryParse(_bandwidthController.text.trim()) ?? 1;
    final price = double.tryParse(_priceController.text.trim()) ?? 0.0;
    final stock = int.tryParse(_stockController.text.trim()) ?? 0;
    final desc = _descriptionController.text.trim();

    Map<String, dynamic> result;

    if (_editingPackage != null) {
      // Mode Edit
      result = await PackageService.updatePackage(
        id: _editingPackage!.id,
        categoryId: _selectedCategoryId,
        name: name,
        cpuCores: cpu,
        ramGb: ram,
        storageGb: storage,
        bandwidthTb: bandwidth,
        pricePerMonth: price,
        stockAvailable: stock,
        description: desc,
        imageFile: _imageFile,
      );
    } else {
      // Mode Tambah Baru
      result = await PackageService.createPackage(
        categoryId: _selectedCategoryId!,
        name: name,
        cpuCores: cpu,
        ramGb: ram,
        storageGb: storage,
        bandwidthTb: bandwidth,
        pricePerMonth: price,
        stockAvailable: stock,
        description: desc,
        imageFile: _imageFile,
      );
    }

    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['message'] ?? 'Proses selesai',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700),
          ),
          backgroundColor:
              result['success'] ? AppTheme.success : AppTheme.danger,
        ),
      );

      if (result['success'] == true) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = _editingPackage != null;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Paket Layanan' : 'Tambah Paket Server Baru',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: AppTheme.primary,
              ),
            )
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                children: [
                  // Section: Upload Gambar Paket (Image Picker)
                  Text(
                    'Foto / Banner Paket Server',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildImagePreviewArea(),

                  const SizedBox(height: 20),

                  // Section: Kategori Layanan
                  Text(
                    'Kategori Layanan',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildCategoryDropdown(),

                  const SizedBox(height: 16),

                  // Section: Nama Paket
                  AppTextField(
                    label: 'Nama Paket Server',
                    hintText: 'Contoh: Cloud VPS NVMe Starter 2G',
                    controller: _nameController,
                    prefixIcon: Icons.dns_outlined,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Nama paket tidak boleh kosong';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Section: Spesifikasi Teknis (CPU & RAM)
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          label: 'vCPU (Cores)',
                          hintText: '1',
                          controller: _cpuController,
                          keyboardType: TextInputType.number,
                          prefixIcon: Icons.memory,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return 'Wajib isi';
                            final n = int.tryParse(val);
                            if (n == null || n < 1) return 'Min 1 Core';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppTextField(
                          label: 'RAM (GB)',
                          hintText: '2',
                          controller: _ramController,
                          keyboardType: TextInputType.number,
                          prefixIcon: Icons.speed,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return 'Wajib isi';
                            final n = int.tryParse(val);
                            if (n == null || n < 1) return 'Min 1 GB';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Section: Storage & Bandwidth
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          label: 'NVMe SSD (GB)',
                          hintText: '30',
                          controller: _storageController,
                          keyboardType: TextInputType.number,
                          prefixIcon: Icons.storage,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return 'Wajib isi';
                            final n = int.tryParse(val);
                            if (n == null || n < 1) return 'Min 1 GB';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppTextField(
                          label: 'Bandwidth (TB)',
                          hintText: '2',
                          controller: _bandwidthController,
                          keyboardType: TextInputType.number,
                          prefixIcon: Icons.wifi,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return 'Wajib isi';
                            final n = int.tryParse(val);
                            if (n == null || n < 1) return 'Min 1 TB';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Section: Harga Sewa & Stok Unit
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: AppTextField(
                          label: 'Harga / Bulan (Rp)',
                          hintText: '125000',
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                          prefixIcon: Icons.payments_outlined,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return 'Wajib isi';
                            final n = double.tryParse(val);
                            if (n == null || n < 1000) return 'Min Rp 1.000';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: AppTextField(
                          label: 'Stok Unit',
                          hintText: '10',
                          controller: _stockController,
                          keyboardType: TextInputType.number,
                          prefixIcon: Icons.inventory_2_outlined,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return 'Wajib isi';
                            final n = int.tryParse(val);
                            if (n == null || n < 0) return 'Min 0';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Section: Deskripsi
                  AppTextField(
                    label: 'Deskripsi & Target Penggunaan',
                    hintText: 'Jelaskan keunggulan paket ini untuk UMKM...',
                    controller: _descriptionController,
                    maxLines: 3,
                    prefixIcon: Icons.description_outlined,
                  ),

                  const SizedBox(height: 24),

                  // Tombol Simpan
                  AppButton(
                    text: isEditing ? 'Simpan Perubahan' : 'Buat Paket Sekarang',
                    icon: Icons.save,
                    isLoading: _isSaving,
                    onPressed: _handleSubmit,
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildImagePreviewArea() {
    return Container(
      width: double.infinity,
      height: 170,
      decoration: AppTheme.neoDecoration(
        color: AppTheme.surface,
        radius: 12,
        borderWidth: 2.0,
        shadowOffset: const Offset(3, 3),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (_imageFile != null)
              Image.file(
                _imageFile!,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              )
            else if (_existingImageUrl != null && _existingImageUrl!.isNotEmpty)
              Image.network(
                _existingImageUrl!,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildUploadPlaceholder(),
              )
            else
              _buildUploadPlaceholder(),

            // Tombol overlay ganti gambar
            Positioned(
              bottom: 10,
              right: 10,
              child: GestureDetector(
                onTap: _showImagePickerModal,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: AppTheme.neoDecoration(
                    color: AppTheme.surface,
                    radius: 8,
                    borderWidth: 1.8,
                    shadowOffset: const Offset(2, 2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add_a_photo, size: 16, color: AppTheme.primary),
                      const SizedBox(width: 6),
                      Text(
                        _imageFile != null || _existingImageUrl != null
                            ? 'Ubah Gambar'
                            : 'Upload Gambar',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            if (_imageFile != null)
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _imageFile = null;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: AppTheme.neoDecoration(
                      color: AppTheme.danger,
                      radius: 6,
                      borderWidth: 1.5,
                      shadowOffset: const Offset(1.5, 1.5),
                    ),
                    child: const Icon(Icons.close, size: 14, color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadPlaceholder() {
    return GestureDetector(
      onTap: _showImagePickerModal,
      child: Container(
        color: const Color(0xFFF1F5F9),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_upload_outlined,
                  size: 44, color: AppTheme.primary),
              const SizedBox(height: 8),
              Text(
                'Ketuk untuk Memilih Gambar Paket',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Kamera HP atau Galeri Foto (PNG/JPG)',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: AppTheme.neoDecoration(
        color: AppTheme.surface,
        radius: 10,
        borderWidth: 2.0,
        shadowOffset: const Offset(3, 3),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _selectedCategoryId,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: AppTheme.textPrimary),
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
          hint: const Text('Pilih Kategori Layanan'),
          items: _categories.map((cat) {
            return DropdownMenuItem<int>(
              value: cat.id,
              child: Text(cat.name),
            );
          }).toList(),
          onChanged: (val) {
            setState(() {
              _selectedCategoryId = val;
            });
          },
        ),
      ),
    );
  }
}
