import 'package:flutter/material.dart';

import '../../models/admin_models.dart';
import 'admin_charts.dart';
import 'admin_theme.dart';
import 'admin_widgets.dart';

/// Target pendapatan per bulan (Rupiah). Ubah sesuai kebutuhan.
const int kMonthlyTarget = 10000000;

DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

double? _pct(num cur, num prev) =>
    prev == 0 ? null : (cur - prev) / prev * 100;

class _Stats {
  late final int totalSales;
  late final int totalOrders;
  late final int totalCustomers;
  late final double? salesDelta;
  late final double? ordersDelta;
  late final double? customersDelta;

  late final List<DateTime> chartDays;
  late final List<double> chartRevenue;
  late final List<double> chartOrders;

  late final int monthRevenue;
  late final double monthPercent;
  late final double? monthDelta;

  late final List<MapEntry<String, int>> categories;
  late final Map<String, int> statusCounts;
  late final List<MapEntry<String, int>> payments;
  late final List<MapEntry<String, int>> topProducts;
  late final int productQtyTotal;

  _Stats(List<AdminOrder> orders, int days) {
    final now = DateTime.now();
    final today = _day(now);
    final valid = orders.where((o) => o.status != 'Dibatalkan').toList();

    bool inRange(AdminOrder o, DateTime from, DateTime to) {
      final d = _day(o.createdAt);
      return !d.isBefore(from) && !d.isAfter(to);
    }

    int sumTotal(Iterable<AdminOrder> l) =>
        l.fold<int>(0, (s, o) => s + o.total);

    final w1From = DateTime(today.year, today.month, today.day - 6);
    final w0From = DateTime(today.year, today.month, today.day - 13);
    final w0To = DateTime(today.year, today.month, today.day - 7);

    // Kartu statistik
    totalSales = sumTotal(valid);
    totalOrders = orders.length;
    totalCustomers =
        orders.map((o) => o.uid).where((u) => u.isNotEmpty).toSet().length;

    salesDelta = _pct(
      sumTotal(valid.where((o) => inRange(o, w1From, today))),
      sumTotal(valid.where((o) => inRange(o, w0From, w0To))),
    );
    ordersDelta = _pct(
      orders.where((o) => inRange(o, w1From, today)).length,
      orders.where((o) => inRange(o, w0From, w0To)).length,
    );
    customersDelta = _pct(
      orders
          .where((o) => inRange(o, w1From, today))
          .map((o) => o.uid)
          .toSet()
          .length,
      orders
          .where((o) => inRange(o, w0From, w0To))
          .map((o) => o.uid)
          .toSet()
          .length,
    );

    // Grafik harian
    chartDays = [
      for (var i = 0; i < days; i++)
        DateTime(today.year, today.month, today.day - (days - 1 - i)),
    ];
    chartRevenue = [
      for (final d in chartDays)
        sumTotal(valid.where((o) => _day(o.createdAt) == d)).toDouble(),
    ];
    chartOrders = [
      for (final d in chartDays)
        valid.where((o) => _day(o.createdAt) == d).length.toDouble(),
    ];

    // Target bulanan
    final monthStart = DateTime(now.year, now.month);
    final prevMonthStart = DateTime(now.year, now.month - 1);
    monthRevenue =
        sumTotal(valid.where((o) => !o.createdAt.isBefore(monthStart)));
    final prevMonthRev = sumTotal(
      valid.where(
        (o) =>
            !o.createdAt.isBefore(prevMonthStart) &&
            o.createdAt.isBefore(monthStart),
      ),
    );
    monthPercent = monthRevenue / kMonthlyTarget * 100;
    monthDelta = _pct(monthRevenue, prevMonthRev);

    // Kategori teratas
    final cat = <String, int>{};
    for (final o in valid) {
      for (final i in o.items) {
        final k = i.category.isEmpty ? 'Lainnya' : i.category;
        cat[k] = (cat[k] ?? 0) + i.subtotal;
      }
    }
    categories =
        (cat.entries.toList()..sort((a, b) => b.value.compareTo(a.value)))
            .take(4)
            .toList();

    // Status
    final st = <String, int>{};
    for (final o in orders) {
      st[o.status] = (st[o.status] ?? 0) + 1;
    }
    statusCounts = st;

    // Metode pembayaran
    final pay = <String, int>{};
    for (final o in orders) {
      pay[o.paymentMethod] = (pay[o.paymentMethod] ?? 0) + 1;
    }
    payments =
        (pay.entries.toList()..sort((a, b) => b.value.compareTo(a.value)))
            .take(4)
            .toList();

    // Produk terlaris
    final prod = <String, int>{};
    for (final o in valid) {
      for (final i in o.items) {
        prod[i.name] = (prod[i.name] ?? 0) + i.quantity;
      }
    }
    productQtyTotal = prod.values.fold<int>(0, (a, b) => a + b);
    topProducts =
        (prod.entries.toList()..sort((a, b) => b.value.compareTo(a.value)))
            .take(5)
            .toList();
  }
}

class AdminDashboardPage extends StatefulWidget {
  final List<AdminOrder> orders;

  const AdminDashboardPage({super.key, required this.orders});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _days = 7;

  @override
  Widget build(BuildContext context) {
    final s = _Stats(widget.orders, _days);

    return LayoutBuilder(
      builder: (context, box) {
        final wide = box.maxWidth >= 1100;
        final pad = box.maxWidth >= 700 ? 28.0 : 16.0;
        final inner = box.maxWidth - pad * 2;

        return ListView(
          padding: EdgeInsets.fromLTRB(pad, 4, pad, 28),
          children: [wide ? _wide(s, inner) : _compact(s, inner)],
        );
      },
    );
  }

  // ===========================================================
  // LAYOUT
  // ===========================================================

  Widget _wide(_Stats s, double w) {
    const gap = 24.0;
    final col = (w - gap * 3) / 4;
    final stats = _statCards(s);

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: col * 3 + gap * 2,
              child: Column(
                children: [
                  SizedBox(
                    height: 124,
                    child: Row(
                      children: [
                        Expanded(child: stats[0]),
                        const SizedBox(width: gap),
                        Expanded(child: stats[1]),
                        const SizedBox(width: gap),
                        Expanded(child: stats[2]),
                      ],
                    ),
                  ),
                  const SizedBox(height: gap),
                  SizedBox(
                    height: 360,
                    child: Row(
                      children: [
                        SizedBox(
                          width: col * 2 + gap,
                          child: _revenueCard(s),
                        ),
                        const SizedBox(width: gap),
                        Expanded(child: _targetCard(s)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: gap),
            Expanded(
              child: SizedBox(
                height: 124 + gap + 360,
                child: _categoriesCard(s),
              ),
            ),
          ],
        ),
        const SizedBox(height: gap),
        SizedBox(
          height: 342,
          child: Row(
            children: [
              SizedBox(width: col, child: _paymentCard(s)),
              const SizedBox(width: gap),
              SizedBox(width: col * 2 + gap, child: _funnelCard(s)),
              const SizedBox(width: gap),
              Expanded(child: _productsCard(s)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _compact(_Stats s, double w) {
    const gap = 20.0;
    final stats = _statCards(s);
    Widget box(double h, Widget c) => SizedBox(height: h, child: c);

    return Column(
      children: [
        if (w >= 720)
          box(
            124,
            Row(
              children: [
                Expanded(child: stats[0]),
                const SizedBox(width: gap),
                Expanded(child: stats[1]),
                const SizedBox(width: gap),
                Expanded(child: stats[2]),
              ],
            ),
          )
        else ...[
          box(124, stats[0]),
          const SizedBox(height: gap),
          box(124, stats[1]),
          const SizedBox(height: gap),
          box(124, stats[2]),
        ],
        const SizedBox(height: gap),
        box(360, _revenueCard(s)),
        const SizedBox(height: gap),
        box(360, _targetCard(s)),
        const SizedBox(height: gap),
        box(500, _categoriesCard(s)),
        const SizedBox(height: gap),
        box(342, _paymentCard(s)),
        const SizedBox(height: gap),
        box(342, _funnelCard(s)),
        const SizedBox(height: gap),
        box(342, _productsCard(s)),
      ],
    );
  }

  // ===========================================================
  // KARTU STATISTIK
  // ===========================================================

  List<Widget> _statCards(_Stats s) {
    return [
      _stat(
        'Total Penjualan',
        rupiah(s.totalSales),
        Icons.attach_money_rounded,
        s.salesDelta,
        highlight: true,
      ),
      _stat(
        'Total Pesanan',
        '${s.totalOrders}',
        Icons.shopping_cart_outlined,
        s.ordersDelta,
      ),
      _stat(
        'Total Pelanggan',
        '${s.totalCustomers}',
        Icons.person_outline_rounded,
        s.customersDelta,
      ),
    ];
  }

  Widget _stat(
    String label,
    String value,
    IconData icon,
    double? delta, {
    bool highlight = false,
  }) {
    return AdminCard(
      color: highlight ? AdminColors.peach : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 14, color: AdminColors.ink),
                ),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: highlight ? AdminColors.orange : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 17,
                  color: highlight ? Colors.white : AdminColors.muted,
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AdminColors.ink,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  DeltaText(delta),
                  const Text(
                    'vs minggu lalu',
                    style: TextStyle(fontSize: 9.5, color: AdminColors.muted),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===========================================================
  // ANALISIS PENDAPATAN
  // ===========================================================

  Widget _legendLine(bool dashed, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (dashed)
          Row(
            children: [
              Container(width: 6, height: 2, color: AdminColors.orangeLight),
              const SizedBox(width: 3),
              Container(width: 6, height: 2, color: AdminColors.orangeLight),
            ],
          )
        else
          Container(width: 15, height: 2.4, color: AdminColors.orange),
        const SizedBox(width: 6),
        Text(label, style: kMutedText.copyWith(fontSize: 12)),
      ],
    );
  }

  Widget _revenueCard(_Stats s) {
    return AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Analisis Pendapatan', style: kCardTitle),
              ),
              PopupMenuButton<int>(
                tooltip: 'Rentang waktu',
                onSelected: (d) => setState(() => _days = d),
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 7, child: Text('7 Hari Terakhir')),
                  PopupMenuItem(value: 14, child: Text('14 Hari Terakhir')),
                  PopupMenuItem(value: 30, child: Text('30 Hari Terakhir')),
                ],
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AdminColors.orange,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$_days Hari Terakhir',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(
                        Icons.expand_more,
                        size: 16,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _legendLine(false, 'Pendapatan'),
              const SizedBox(width: 16),
              _legendLine(true, 'Pesanan'),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: RevenueChart(
              days: s.chartDays,
              revenue: s.chartRevenue,
              orders: s.chartOrders,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================
  // TARGET BULANAN
  // ===========================================================

  Widget _targetCard(_Stats s) {
    final pct = s.monthPercent;
    final remaining = (kMonthlyTarget - s.monthRevenue)
        .clamp(0, kMonthlyTarget)
        .toInt();
    final done = pct >= 100;

    Widget box(String label, String value) => Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: kMutedText.copyWith(fontSize: 11.5)),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: AdminColors.ink,
                ),
              ),
            ],
          ),
        );

    return AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Target Bulanan', style: kCardTitle),
          const SizedBox(height: 16),
          Center(
            child: SizedBox(
              width: 220,
              height: 126,
              child: Stack(
                children: [
                  const GaugeChart(progress: 0, width: 220),
                  GaugeChart(progress: pct / 100, width: 220),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${pct.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: AdminColors.ink,
                          ),
                        ),
                        if (s.monthDelta != null)
                          Text(
                            '${s.monthDelta! >= 0 ? '+' : ''}'
                            '${s.monthDelta!.toStringAsFixed(2)}% dari bulan lalu',
                            style: TextStyle(
                              fontSize: 10.5,
                              color: s.monthDelta! >= 0
                                  ? AdminColors.green
                                  : AdminColors.red,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: Text(
              done ? 'Target tercapai! 🎉' : 'Terus semangat! 💪',
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: AdminColors.ink,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              done
                  ? 'Pendapatan bulan ini sudah melewati target.'
                  : 'Tambah ${rupiah(remaining)} lagi untuk mencapai target bulan ini.',
              textAlign: TextAlign.center,
              style: kMutedText.copyWith(fontSize: 11.5, height: 1.4),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: AdminColors.peachSoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                box('Target', rupiah(kMonthlyTarget)),
                Container(width: 1, height: 30, color: Colors.white),
                box('Pendapatan', rupiah(s.monthRevenue)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================
  // KATEGORI TERATAS
  // ===========================================================

  static const _donutColors = [
    AdminColors.orange,
    AdminColors.orangeLight,
    Color(0xFFFFD0A0),
    Color(0xFFFFE6CC),
  ];

  Widget _categoriesCard(_Stats s) {
    final values = s.categories.map((e) => e.value.toDouble()).toList();

    return AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Kategori Teratas', style: kCardTitle),
          const SizedBox(height: 16),
          Center(
            child: DonutChart(
              size: 210,
              stroke: 22,
              values: values,
              colors: _donutColors,
              center: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Total Penjualan', style: kMutedText.copyWith(fontSize: 11)),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: 120,
                    child: FittedBox(
                      child: Text(
                        rupiah(s.totalSales),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AdminColors.ink,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          if (s.categories.isEmpty)
            const Center(
              child: Text('Belum ada penjualan', style: kMutedText),
            )
          else
            ...[
              for (var i = 0; i < s.categories.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          color: _donutColors[i],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          s.categories[i].key,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13.5,
                            color: AdminColors.ink,
                          ),
                        ),
                      ),
                      Text(
                        rupiah(s.categories[i].value),
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: AdminColors.ink,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
        ],
      ),
    );
  }

  // ===========================================================
  // METODE PEMBAYARAN
  // ===========================================================

  Widget _barRow(String name, int count, int total) {
    final frac = total == 0 ? 0.0 : count / total;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: AdminColors.ink,
                  ),
                ),
              ),
              Text(
                '${(frac * 100).toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AdminColors.ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: frac,
              minHeight: 6,
              backgroundColor: const Color(0xFFFFE6CC),
              valueColor: const AlwaysStoppedAnimation(AdminColors.orange),
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentCard(_Stats s) {
    return AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Metode Pembayaran', style: kCardTitle),
          const SizedBox(height: 12),
          Text(
            '${s.totalOrders}',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AdminColors.ink,
            ),
          ),
          const Text('Total pesanan', style: kMutedText),
          const SizedBox(height: 18),
          if (s.payments.isEmpty)
            const Text('Belum ada pesanan', style: kMutedText)
          else
            ...[
              for (final e in s.payments) _barRow(e.key, e.value, s.totalOrders),
            ],
        ],
      ),
    );
  }

  // ===========================================================
  // STATUS PESANAN (FUNNEL)
  // ===========================================================

  Widget _funnelCard(_Stats s) {
    final total = s.totalOrders;
    final labels = ['Semua Pesanan', ...kOrderStatuses];
    final counts = [
      total,
      for (final st in kOrderStatuses) s.statusCounts[st] ?? 0,
    ];
    const barColors = [
      Color(0xFFFFE3C7),
      Color(0xFFFFD0A0),
      AdminColors.orangeLight,
      Color(0xFFFF9A2E),
      AdminColors.orange,
    ];

    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < labels.length; i++)
          Expanded(
            child: _funnelCol(
              labels[i],
              counts[i],
              total,
              barColors[i],
              first: i == 0,
              bad: labels[i] == 'Dibatalkan',
            ),
          ),
      ],
    );

    return AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Status Pesanan', style: kCardTitle),
          const SizedBox(height: 14),
          Expanded(
            child: LayoutBuilder(
              builder: (context, c) {
                if (c.maxWidth >= 520) return content;
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: 520,
                    height: c.maxHeight,
                    child: content,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _funnelCol(
    String label,
    int count,
    int total,
    Color barColor, {
    required bool first,
    required bool bad,
  }) {
    final ratio = total == 0 ? 0.0 : count / total;
    final pct = total == 0 ? 0 : (count / total * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: first ? 0 : 12, right: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 32,
                child: Text(
                  label,
                  maxLines: 2,
                  style: kMutedText.copyWith(fontSize: 11.5),
                ),
              ),
              Text(
                '$count',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AdminColors.ink,
                ),
              ),
              const SizedBox(height: 6),
              Pill('$pct%', good: !bad),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: ratio.clamp(0.06, 1.0).toDouble(),
              widthFactor: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(10),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ===========================================================
  // PRODUK TERLARIS
  // ===========================================================

  static const _productColors = [
    AdminColors.orange,
    Color(0xFFFF9A2E),
    AdminColors.orangeLight,
    Color(0xFFFFD0A0),
    Color(0xFFFFE6CC),
  ];

  Widget _productsCard(_Stats s) {
    final items = s.topProducts;

    return AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Produk Terlaris', style: kCardTitle),
          const SizedBox(height: 16),
          if (items.isEmpty)
            const Text('Belum ada penjualan', style: kMutedText)
          else ...[
            SizedBox(
              height: 52,
              child: Row(
                children: [
                  for (var i = 0; i < items.length; i++)
                    Expanded(
                      flex: items[i].value,
                      child: Container(
                        margin: EdgeInsets.only(
                          right: i == items.length - 1 ? 0 : 4,
                        ),
                        decoration: BoxDecoration(
                          color: _productColors[i],
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            for (var i = 0; i < items.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: _productColors[i],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        items[i].key,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AdminColors.ink,
                        ),
                      ),
                    ),
                    Text(
                      '${(items[i].value / s.productQtyTotal * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AdminColors.ink,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}