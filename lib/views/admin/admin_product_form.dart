import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_theme.dart';
import '../../models/admin_models.dart';
import '../../services/admin_service.dart';
import 'admin_theme.dart';
import 'admin_widgets.dart';

const _categories = [
  'Running',
  'Basketball',
  'Outdoor',
  'Training',
  'Casual',
  'Lifestyle',
];

/// Dialog tambah / edit produk.
/// Mengembalikan `true` lewat Navigator.pop kalau berhasil disimpan.
class ProductFormDialog extends StatefulWidget {
  final AdminProduct? product;

  const ProductFormDialog({super.key, this.product});

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _name;
  late final TextEditingController _price;
  late final TextEditingController _stock;
  late final TextEditingController _sizes;
  late final TextEditingController _image;
  late final TextEditingController _desc;
  late String _category;

  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _name = TextEditingController(text: p?.name ?? '');
    _price = TextEditingController(text: p == null ? '' : '${p.price}');
    _stock = TextEditingController(text: p == null ? '' : '${p.stock}');
    _sizes = TextEditingController(
      text: (p?.sizes.isNotEmpty ?? false)
          ? p!.sizes.join(', ')
          : '39, 40, 41, 42, 43',
    );
    _image = TextEditingController(text: p?.imageUrl ?? '');
    _desc = TextEditingController(text: p?.description ?? '');
    _category = (p?.category.isNotEmpty ?? false)
        ? p!.category
        : _categories.first;
  }

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _stock.dispose();
    _sizes.dispose();
    _image.dispose();
    _desc.dispose();
    super.dispose();
  }

  List<int> _parseSizes() {
    final list = _sizes.text
        .split(RegExp(r'[,\s]+'))
        .map(int.tryParse)
        .whereType<int>()
        .toList();
    return list.isEmpty ? [39, 40, 41, 42, 43] : list;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _saving = true;
      _error = null;
    });

    final base = widget.product;
    final p = AdminProduct(
      id: base?.id ?? '',
      name: _name.text.trim(),
      category: _category,
      price: int.parse(_price.text),
      stock: int.parse(_stock.text),
      imageUrl: _image.text.trim(),
      description: _desc.text.trim(),
      sizes: _parseSizes(),
      rating: base?.rating ?? 0,
    );

    try {
      await AdminService.saveProduct(p);
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = 'Gagal menyimpan. Periksa Firestore Rules.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cats = <String>{..._categories, _category}.toList();
    final width = math.min(500.0, MediaQuery.of(context).size.width - 80);

    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      title: Text(
        widget.product == null ? 'Tambah produk' : 'Edit produk',
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
      ),
      content: SizedBox(
        width: width,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FieldLabel('Nama produk'),
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(hintText: 'Nama sepatu'),
                  validator: (v) => (v == null || v.trim().length < 2)
                      ? 'Nama minimal 2 karakter'
                      : null,
                ),
                const SizedBox(height: 14),
                const FieldLabel('Kategori'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final c in cats)
                      ChoiceChip(
                        showCheckmark: false,
                        shape: const StadiumBorder(),
                        label: Text(c),
                        selected: _category == c,
                        selectedColor: AdminColors.orange,
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: AdminColors.line),
                        labelStyle: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: _category == c
                              ? Colors.white
                              : AdminColors.ink,
                        ),
                        onSelected: (_) => setState(() => _category = c),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const FieldLabel('Harga (Rp)'),
                          TextFormField(
                            controller: _price,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration:
                                const InputDecoration(hintText: '750000'),
                            validator: (v) =>
                                (int.tryParse(v ?? '') ?? 0) > 0
                                    ? null
                                    : 'Isi harga',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const FieldLabel('Stok'),
                          TextFormField(
                            controller: _stock,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration:
                                const InputDecoration(hintText: '20'),
                            validator: (v) => int.tryParse(v ?? '') == null
                                ? 'Isi stok'
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const FieldLabel('Ukuran (pisahkan dengan koma)'),
                TextFormField(
                  controller: _sizes,
                  decoration: const InputDecoration(
                    hintText: '39, 40, 41, 42, 43',
                  ),
                ),
                const SizedBox(height: 14),
                const FieldLabel('URL gambar'),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _image,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          hintText: 'https://...',
                        ),
                        validator: (v) {
                          final t = v?.trim() ?? '';
                          if (t.isEmpty) return null;
                          return t.startsWith('http')
                              ? null
                              : 'URL harus diawali http';
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    AdminThumb(url: _image.text.trim(), size: 52),
                  ],
                ),
                const SizedBox(height: 14),
                const FieldLabel('Deskripsi'),
                TextFormField(
                  controller: _desc,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Deskripsi singkat produk',
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: const TextStyle(
                      color: AdminColors.red,
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context, false),
          style: TextButton.styleFrom(foregroundColor: AdminColors.muted),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          style: adminPrimaryStyle(height: 42),
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Simpan'),
        ),
      ],
    );
  }
}