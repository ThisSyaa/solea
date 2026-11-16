import 'package:flutter/material.dart';

import '../../models/admin_models.dart';
import 'admin_theme.dart';
import 'admin_widgets.dart';

void showOrderDetail(BuildContext context, AdminOrder o) {
  Widget kv(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 92, child: Text(k, style: kMutedText)),
            Expanded(
              child: Text(
                v,
                style: const TextStyle(
                  fontSize: 13.5,
                  color: AdminColors.ink,
                ),
              ),
            ),
          ],
        ),
      );

  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      title: Row(
        children: [
          Expanded(
            child: Text(o.id, style: const TextStyle(fontSize: 17)),
          ),
          StatusChip(o.status),
        ],
      ),
      content: SizedBox(
        width: 460,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final i in o.items)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      AdminThumb(url: i.imageUrl, size: 44),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              i.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Ukuran ${i.size} · ${i.quantity}x',
                              style: kMutedText,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        rupiah(i.price * i.quantity),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
              const Divider(color: AdminColors.line),
              kv('Penerima', o.customerName),
              kv('No. HP', o.phone),
              kv('Alamat', o.address),
              kv('Pembayaran', o.paymentMethod),
              kv('Tanggal', formatDate(o.createdAt)),
              kv('Ongkir', rupiah(o.shippingCost)),
              kv('Total', rupiah(o.total)),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          style: TextButton.styleFrom(foregroundColor: AdminColors.orange),
          child: const Text('Tutup'),
        ),
      ],
    ),
  );
}