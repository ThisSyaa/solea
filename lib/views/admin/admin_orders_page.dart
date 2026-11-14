import 'package:flutter/material.dart';

import '../../models/admin_models.dart';
import '../../services/admin_service.dart';
import 'admin_order_detail.dart';
import 'admin_theme.dart';
import 'admin_widgets.dart';

class AdminOrdersPage extends StatefulWidget {
  final List<AdminOrder> orders;
  final String query;

  const AdminOrdersPage({
    super.key,
    required this.orders,
    this.query = '',
  });

  @override
  State<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage> {
  String _filter = 'Semua';

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _changeStatus(AdminOrder o, String status) async {
    if (status == o.status) return;
    try {
      await AdminService.updateOrderStatus(o, status);
      if (mounted) _snack('${o.id} → $status');
    } catch (_) {
      if (mounted) _snack('Gagal mengubah status. Periksa Firestore Rules.');
    }
  }

  bool _matches(AdminOrder o) {
    final q = widget.query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return o.id.toLowerCase().contains(q) ||
        o.customerName.toLowerCase().contains(q) ||
        o.phone.contains(q) ||
        o.items.any((i) => i.name.toLowerCase().contains(q));
  }

  @override
  Widget build(BuildContext context) {
    final searched = widget.orders.where(_matches).toList();
    final shown = _filter == 'Semua'
        ? searched
        : searched.where((o) => o.status == _filter).toList();

    return LayoutBuilder(
      builder: (context, box) {
        final wide = box.maxWidth >= 760;
        final pad = box.maxWidth >= 700 ? 28.0 : 16.0;

        return ListView(
          padding: EdgeInsets.fromLTRB(pad, 4, pad, 28),
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final s in ['Semua', ...kOrderStatuses])
                  ChoiceChip(
                    showCheckmark: false,
                    shape: const StadiumBorder(),
                    selected: _filter == s,
                    selectedColor: AdminColors.orange,
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: AdminColors.line),
                    label: Text(
                      s == 'Semua'
                          ? 'Semua (${searched.length})'
                          : '$s (${searched.where((o) => o.status == s).length})',
                    ),
                    labelStyle: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _filter == s ? Colors.white : AdminColors.ink,
                    ),
                    onSelected: (_) => setState(() => _filter = s),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (shown.isEmpty)
              AdminCard(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Text(
                    widget.query.trim().isNotEmpty
                        ? 'Tidak ada pesanan yang cocok.'
                        : 'Belum ada pesanan di kategori ini.',
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
          Expanded(flex: 3, child: _h('PESANAN')),
          Expanded(flex: 2, child: _h('PELANGGAN')),
          Expanded(flex: 2, child: _h('TOTAL')),
          Expanded(flex: 2, child: _h('TANGGAL')),
          SizedBox(
            width: 130,
            child: Align(
              alignment: Alignment.centerRight,
              child: _h('STATUS'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(AdminOrder o, bool wide) {
    final first = o.items.isNotEmpty ? o.items.first : null;
    final more = o.items.length - 1;
    final qty = o.items.fold<int>(0, (s, i) => s + i.quantity);

    return InkWell(
      onTap: () => showOrderDetail(context, o),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            AdminThumb(url: first?.imageUrl ?? '', size: 46),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    o.id,
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
                    first == null
                        ? '-'
                        : '${first.name}${more > 0 ? ' +$more lainnya' : ''}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: kMutedText,
                  ),
                  if (!wide)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        '${o.customerName} · ${rupiah(o.total)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: kMutedText,
                      ),
                    ),
                ],
              ),
            ),
            if (wide) ...[
              Expanded(
                flex: 2,
                child: Text(
                  o.customerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: AdminColors.ink,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rupiah(o.total),
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AdminColors.ink,
                      ),
                    ),
                    Text('$qty pasang', style: kMutedText),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(formatDate(o.createdAt), style: kMutedText),
              ),
            ],
            SizedBox(
              width: wide ? 130 : 112,
              child: Align(
                alignment: Alignment.centerRight,
                child: PopupMenuButton<String>(
                  tooltip: 'Ubah status',
                  onSelected: (s) => _changeStatus(o, s),
                  itemBuilder: (_) => [
                    for (final s in kOrderStatuses)
                      PopupMenuItem(value: s, child: StatusChip(s)),
                  ],
                  child: StatusChip(o.status, dropdown: true),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}