import 'package:flutter/material.dart';

import '../../models/admin_models.dart';
import '../../services/admin_service.dart';
import 'admin_product_form.dart';
import 'admin_theme.dart';
import 'admin_widgets.dart';

class AdminProductsPage extends StatefulWidget {
  final String query;

  const AdminProductsPage({super.key, this.query = ''});

  @override
  State<AdminProductsPage> createState() => _AdminProductsPageState();
}

class _AdminProductsPageState extends State<AdminProductsPage> {
  final Stream<List<AdminProduct>> _stream = AdminService.productsStream();
  bool _importing = false;

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _openForm([AdminProduct? product]) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => ProductFormDialog(product: product),
    );
    if (saved == true && mounted) {
      _snack(product == null ? 'Produk ditambahkan' : 'Perubahan disimpan');
    }
  }

  Future<void> _delete(AdminProduct p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Text('Hapus produk?', style: TextStyle(fontSize: 17)),
        content: Text('"${p.name}" akan dihapus permanen dari katalog.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            style: TextButton.styleFrom(foregroundColor: AdminColors.muted),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AdminColors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    try {
      await AdminService.deleteProduct(p.id);
      if (mounted) _snack('Produk dihapus');
    } catch (_) {
      if (mounted) _snack('Gagal menghapus. Periksa Firestore Rules.');
    }
  }

  Future<void> _import() async {
    setState(() => _importing = true);
    try {
      final n = await AdminService.importFromDummyJson();
      if (mounted) _snack('$n produk diimpor dari DummyJSON');
    } catch (_) {
      if (mounted) {
        _snack('Gagal impor. Periksa koneksi dan Firestore Rules.');
      }
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<AdminProduct>>(
      stream: _stream,
      builder: (context, snap) {
        if (snap.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Gagal memuat produk.\n${snap.error}',
                textAlign: TextAlign.center,
                style: kMutedText,
              ),
            ),
          );
        }
        if (!snap.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: AdminColors.orange),
          );
        }

        final all = snap.data!;
        final q = widget.query.trim().toLowerCase();
        final shown = all
            .where(
              (p) =>
                  q.isEmpty ||
                  p.name.toLowerCase().contains(q) ||
                  p.category.toLowerCase().contains(q),
            )
            .toList();

        return LayoutBuilder(
          builder: (context, box) {
            final wide = box.maxWidth >= 760;
            final pad = box.maxWidth >= 700 ? 28.0 : 16.0;

            return ListView(
              padding: EdgeInsets.fromLTRB(pad, 4, pad, 28),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        q.isEmpty
                            ? '${all.length} produk di katalog'
                            : '${shown.length} dari ${all.length} produk',
                        style: kMutedText.copyWith(fontSize: 13.5),
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: () => _openForm(),
                      style: adminPrimaryStyle(),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Tambah produk'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (all.isEmpty)
                  _emptyState()
                else if (shown.isEmpty)
                  const AdminCard(
                    padding: EdgeInsets.all(32),
                    child: Center(
                      child: Text(
                        'Tidak ada produk yang cocok.',
                        style: kMutedText,
                      ),
                    ),
                  )
                else
                  AdminCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        if (wide) _headerRow(),
                        for (var i = 0; i < shown.length; i++) ...[
                          if (i > 0 || wide)
                            const Divider(height: 1, color: AdminColors.line),
                          _row(shown[i], wide),
                        ],
                      ],
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _emptyState() {
    return AdminCard(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const Icon(
            Icons.inventory_2_outlined,
            size: 38,
            color: AdminColors.muted,
          ),
          const SizedBox(height: 12),
          const Text(
            'Katalog masih kosong',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AdminColors.ink,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Impor produk awal dari DummyJSON, atau tambah manual.',
            textAlign: TextAlign.center,
            style: kMutedText,
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              FilledButton(
                onPressed: _importing ? null : _import,
                style: adminPrimaryStyle(),
                child: _importing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Impor dari DummyJSON'),
              ),
              OutlinedButton(
                onPressed: () => _openForm(),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 44),
                  foregroundColor: AdminColors.ink,
                  side: const BorderSide(color: AdminColors.line),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Tambah manual'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _h(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          letterSpacing: 0.8,
          fontWeight: FontWeight.w700,
          color: AdminColors.muted,
        ),
      );

  Widget _headerRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const SizedBox(width: 58),
          Expanded(flex: 4, child: _h('PRODUK')),
          SizedBox(width: 130, child: _h('HARGA')),
          SizedBox(width: 90, child: _h('STOK')),
          const SizedBox(width: 92),
        ],
      ),
    );
  }

  Widget _row(AdminProduct p, bool wide) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          AdminThumb(url: p.imageUrl, size: 46),
          const SizedBox(width: 12),
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AdminColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  wide ? p.category : '${p.category} · ${rupiah(p.price)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: kMutedText,
                ),
              ],
            ),
          ),
          if (wide)
            SizedBox(
              width: 130,
              child: Text(
                rupiah(p.price),
                style: const TextStyle(
                  fontSize: 13.5,
                  color: AdminColors.ink,
                ),
              ),
            ),
          SizedBox(
            width: wide ? 90 : 70,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _StockChip(p.stock),
            ),
          ),
          SizedBox(
            width: 92,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  tooltip: 'Edit',
                  visualDensity: VisualDensity.compact,
                  onPressed: () => _openForm(p),
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 19,
                    color: AdminColors.ink,
                  ),
                ),
                IconButton(
                  tooltip: 'Hapus',
                  visualDensity: VisualDensity.compact,
                  onPressed: () => _delete(p),
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 19,
                    color: AdminColors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StockChip extends StatelessWidget {
  final int stock;
  const _StockChip(this.stock);

  @override
  Widget build(BuildContext context) {
    final String text;
    final Color bg;
    final Color fg;

    if (stock <= 0) {
      text = 'Habis';
      bg = AdminColors.redBg;
      fg = AdminColors.red;
    } else if (stock <= 5) {
      text = 'Sisa $stock';
      bg = AdminColors.peach;
      fg = const Color(0xFFB85E00);
    } else {
      text = '$stock';
      bg = Colors.white;
      fg = AdminColors.ink;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}