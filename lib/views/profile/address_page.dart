
import 'package:flutter/material.dart';

import '../../controllers/auth_controller.dart';
import '../../core/app_theme.dart';
import '../../core/home_button.dart';

class AddressPage extends StatefulWidget {
  const AddressPage({super.key});

  @override
  State<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  bool _hasAddress = false;
  bool _isEditing = false;

  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadAddress();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // =========================================================
  // LOAD ADDRESS
  // =========================================================

  Future<void> _loadAddress() async {
    try {
      final data = await AuthController.loadFirebaseAddress();

      if (!mounted) return;

      if (data != null) {
        _nameController.text = data['name'] ?? '';
        _phoneController.text = data['phone'] ?? '';
        _addressController.text = data['address'] ?? '';
      }

      setState(() {
        _hasAddress = data != null;
        _isEditing = data == null;
        _isLoading = false;
        _loadError = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _loadError = e.toString();
      });
    }
  }

  // =========================================================
  // EDIT ADDRESS
  // =========================================================

  void _startEditing() {
    setState(() {
      _isEditing = true;
    });
  }

  void _cancelEditing() {
    if (!_hasAddress) return;

    setState(() {
      _isEditing = false;
    });

    // Mengembalikan field ke data terakhir yang tersimpan.
    _loadAddress();
  }

  // =========================================================
  // SAVE ADDRESS
  // =========================================================

  Future<void> _saveAddress() async {
    if (_isSaving) return;

    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    String? error;

    try {
      error = await AuthController.saveFirebaseAddress(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
      );
    } catch (_) {
      error = 'Terjadi kesalahan saat menyimpan alamat.';
    }

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    if (error != null) {
      _showMessage(error);
      return;
    }

    setState(() {
      _hasAddress = true;
      _isEditing = false;
    });

    _showMessage('Alamat berhasil disimpan.');
  }

  // =========================================================
  // SNACKBAR
  // =========================================================

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  // =========================================================
  // UI
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.sand,
      appBar: AppBar(
        backgroundColor: AppColors.sand,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Alamat Saya',
          style: TextStyle(
            color: AppColors.ink,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        actions: const [
          HomeButton(),
          SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.forest,
        ),
      );
    }

    if (_loadError != null) {
      return _buildErrorState();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            20,
            12,
            20,
            32,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 650,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPageHeader(),
                  const SizedBox(height: 26),

                  if (_isEditing)
                    _buildAddressForm()
                  else ...[
                    _buildSavedAddress(),
                    const SizedBox(height: 18),
                    _buildAddressNote(),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // =========================================================
  // PAGE HEADER
  // =========================================================

  Widget _buildPageHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 11,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFE8E4DA),
            borderRadius: BorderRadius.circular(999),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.local_shipping_outlined,
                size: 14,
                color: AppColors.forestDeep,
              ),
              SizedBox(width: 6),
              Text(
                'PENGIRIMAN',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                  color: AppColors.forestDeep,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          _isEditing
              ? (_hasAddress
                  ? 'Edit alamat'
                  : 'Tambah alamat')
                  : 'Alamat Saya',
          style: const TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          _isEditing
              ? 'Pastikan detail alamat dan kontak kamu benar.'
              : 'Alamat yang kamu gunakan untuk menerima pesanan SOLEA.',
          style: const TextStyle(
            fontSize: 13,
            height: 1.6,
            color: AppColors.muted,
          ),
        ),
      ],
    );
  }

  // =========================================================
  // EMPTY / SAVED ADDRESS CARD
  // =========================================================

  Widget _buildSavedAddress() {
    if (!_hasAddress) {
      return _buildEmptyAddress();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.line,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0EEE8),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.location_on_outlined,
                  color: AppColors.forest,
                  size: 23,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alamat pengiriman',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Alamat utama akun kamu',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5EFE9),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'UTAMA',
                  style: TextStyle(
                    color: AppColors.forestDeep,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(
              color: AppColors.line,
              height: 1,
            ),
          ),
          Text(
            _nameController.text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 7),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.phone_outlined,
                size: 17,
                color: AppColors.muted,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _phoneController.text,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.muted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.home_outlined,
                size: 18,
                color: AppColors.muted,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _addressController.text,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.7,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: _startEditing,
              icon: const Icon(
                Icons.edit_outlined,
                size: 17,
              ),
              label: const Text('Edit alamat'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.forestDeep,
                side: const BorderSide(
                  color: AppColors.line,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyAddress() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 38,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.line,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: const BoxDecoration(
              color: Color(0xFFF0EEE8),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_on_outlined,
              size: 35,
              color: AppColors.forest,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Belum ada alamat tersimpan',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tambahkan alamat pengiriman agar pesanan sepatu kamu bisa sampai ke tujuan.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.6,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 23),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _startEditing,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Tambah alamat'),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // ADDRESS FORM
  // =========================================================

  Widget _buildAddressForm() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.line,
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.contact_page_outlined,
                  size: 21,
                  color: AppColors.forest,
                ),
                SizedBox(width: 9),
                Text(
                  'Informasi penerima',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),

            const FieldLabel('Nama penerima'),
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                hintText: 'Masukkan nama lengkap',
                prefixIcon: Icon(
                  Icons.person_outline_rounded,
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nama penerima wajib diisi.';
                }

                if (value.trim().length < 3) {
                  return 'Nama minimal 3 karakter.';
                }

                return null;
              },
            ),

            const SizedBox(height: 19),

            const FieldLabel('Nomor HP'),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                hintText: 'Contoh: 081234567890',
                prefixIcon: Icon(
                  Icons.phone_outlined,
                ),
              ),
              validator: (value) {
                final phone = value?.trim() ?? '';
                final digits =
                    phone.replaceAll(RegExp(r'\D'), '');

                if (phone.isEmpty) {
                  return 'Nomor HP wajib diisi.';
                }

                if (digits.length < 8) {
                  return 'Masukkan nomor HP yang valid.';
                }

                return null;
              },
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Divider(
                color: AppColors.line,
                height: 1,
              ),
            ),

            const Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 21,
                  color: AppColors.forest,
                ),
                SizedBox(width: 9),
                Text(
                  'Detail alamat',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 9),
            const Text(
              'Cantumkan jalan, nomor rumah, RT/RW, kelurahan, kecamatan, kota, provinsi, dan kode pos jika tersedia.',
              style: TextStyle(
                fontSize: 12,
                height: 1.6,
                color: AppColors.muted,
              ),
            ),
            const SizedBox(height: 18),

            const FieldLabel('Alamat lengkap'),
            TextFormField(
              controller: _addressController,
              minLines: 4,
              maxLines: 6,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText:
                    'Jalan, nomor rumah, kelurahan, kecamatan, kota, provinsi...',
                alignLabelWithHint: true,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Alamat lengkap wajib diisi.';
                }

                if (value.trim().length < 10) {
                  return 'Alamat minimal 10 karakter.';
                }

                return null;
              },
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveAddress,
                child: _isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Simpan alamat'),
              ),
            ),

            if (_hasAddress) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: TextButton(
                  onPressed: _isSaving
                      ? null
                      : _cancelEditing,
                  child: const Text('Batal'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // =========================================================
  // NOTE
  // =========================================================

  Widget _buildAddressNote() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFEDEAE2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: AppColors.forestDeep,
            size: 19,
          ),
          SizedBox(width: 11),
          Expanded(
            child: Text(
              'Pastikan alamat dan nomor HP sudah benar agar kurir dapat menghubungi kamu saat pengiriman.',
              style: TextStyle(
                fontSize: 12,
                height: 1.6,
                color: AppColors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // ERROR STATE
  // =========================================================

  Widget _buildErrorState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 420,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: Color(0xFFEDEAE2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cloud_off_outlined,
                  size: 32,
                  color: AppColors.forest,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Alamat belum bisa dimuat',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 9),
              const Text(
                'Periksa koneksi internet dan sesi akun kamu, lalu coba lagi.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.6,
                  color: AppColors.muted,
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isLoading = true;
                      _loadError = null;
                    });

                    _loadAddress();
                  },
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Coba lagi'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
