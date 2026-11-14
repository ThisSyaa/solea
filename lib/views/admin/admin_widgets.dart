import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'admin_theme.dart';

const kOrderStatuses = ['Diproses', 'Dikirim', 'Selesai', 'Dibatalkan'];

String rupiah(int value) => NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(value);

/// 2500000 -> "2,5jt", 750000 -> "750rb"
String compactRp(num v) {
  String fmt(double x) {
    var s = x.toStringAsFixed(1);
    if (s.endsWith('.0')) s = s.substring(0, s.length - 2);
    return s.replaceAll('.', ',');
  }

  final a = v.abs();
  if (a >= 1000000000) return '${fmt(v / 1000000000)}M';
  if (a >= 1000000) return '${fmt(v / 1000000)}jt';
  if (a >= 1000) return '${fmt(v / 1000)}rb';
  return v.toStringAsFixed(0);
}

String formatDate(DateTime d) =>
    DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(d);

(Color, Color) statusColors(String status) {
  switch (status) {
    case 'Dikirim':
      return (AdminColors.blueBg, AdminColors.blue);
    case 'Selesai':
      return (AdminColors.greenBg, AdminColors.green);
    case 'Dibatalkan':
      return (AdminColors.redBg, AdminColors.red);
    default: // Diproses
      return (AdminColors.peach, const Color(0xFFB85E00));
  }
}

class StatusChip extends StatelessWidget {
  final String status;
  final bool dropdown;

  const StatusChip(this.status, {super.key, this.dropdown = false});

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = statusColors(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            status,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
          if (dropdown) ...[
            const SizedBox(width: 2),
            Icon(Icons.expand_more, size: 16, color: fg),
          ],
        ],
      ),
    );
  }
}

/// Badge persen kecil (hijau / merah).
class Pill extends StatelessWidget {
  final String text;
  final bool good;

  const Pill(this.text, {super.key, this.good = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: good ? AdminColors.greenBg : AdminColors.redBg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: good ? AdminColors.green : AdminColors.red,
        ),
      ),
    );
  }
}

/// Teks perubahan persen: hijau kalau naik, merah kalau turun.
class DeltaText extends StatelessWidget {
  final double? value;

  const DeltaText(this.value, {super.key});

  @override
  Widget build(BuildContext context) {
    final v = value;
    if (v == null) {
      return const Text(
        '—',
        style: TextStyle(fontSize: 11, color: AdminColors.muted),
      );
    }
    final up = v >= 0;
    return Text(
      '${up ? '+' : ''}${v.toStringAsFixed(2)}%',
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: up ? AdminColors.green : AdminColors.red,
      ),
    );
  }
}

/// Kartu lembut tanpa border.
class AdminCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;

  const AdminCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color ?? AdminColors.card,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: Padding(padding: padding, child: child),
    );
  }
}

class AdminThumb extends StatelessWidget {
  final String url;
  final double size;

  const AdminThumb({super.key, required this.url, this.size = 46});

  @override
  Widget build(BuildContext context) {
    final fallback = Icon(
      Icons.image_outlined,
      color: AdminColors.muted,
      size: size * 0.45,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: size,
        height: size,
        color: Colors.white,
        alignment: Alignment.center,
        child: url.isEmpty
            ? fallback
            : CachedNetworkImage(
                imageUrl: url,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => fallback,
              ),
      ),
    );
  }
}

ButtonStyle adminPrimaryStyle({double height = 44}) {
  return FilledButton.styleFrom(
    backgroundColor: AdminColors.orange,
    foregroundColor: Colors.white,
    minimumSize: Size(0, height),
    padding: const EdgeInsets.symmetric(horizontal: 18),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    textStyle: const TextStyle(fontWeight: FontWeight.w600),
  );
}