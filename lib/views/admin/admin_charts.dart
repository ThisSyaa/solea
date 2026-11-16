import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

import 'admin_theme.dart';
import 'admin_widgets.dart';

TextPainter _tp(
  String text,
  double size,
  Color color, {
  FontWeight weight = FontWeight.w400,
}) {
  return TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(fontSize: size, color: color, fontWeight: weight),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
}

void _dashPath(
  Canvas canvas,
  Path path,
  Paint paint,
  double dash,
  double gap,
) {
  for (final metric in path.computeMetrics()) {
    var d = 0.0;
    while (d < metric.length) {
      final end = math.min(d + dash, metric.length);
      canvas.drawPath(metric.extractPath(d, end), paint);
      d += dash + gap;
    }
  }
}

// =============================================================
// LINE CHART: PENDAPATAN + PESANAN
// =============================================================

class RevenueChart extends StatefulWidget {
  final List<DateTime> days;
  final List<double> revenue;
  final List<double> orders;

  const RevenueChart({
    super.key,
    required this.days,
    required this.revenue,
    required this.orders,
  });

  @override
  State<RevenueChart> createState() => _RevenueChartState();
}

class _RevenueChartState extends State<RevenueChart> {
  int? _hover;

  void _setHover(Offset local, double width) {
    final n = widget.days.length;
    if (n == 0) return;
    final plotW = width - _RevenuePainter.leftPad - _RevenuePainter.rightPad;
    var idx = 0;
    if (n > 1 && plotW > 0) {
      idx = (((local.dx - _RevenuePainter.leftPad) / plotW) * (n - 1))
          .round()
          .clamp(0, n - 1)
          .toInt();
    }
    if (idx != _hover) setState(() => _hover = idx);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        return MouseRegion(
          onHover: (e) => _setHover(e.localPosition, box.maxWidth),
          onExit: (_) => setState(() => _hover = null),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (d) => _setHover(d.localPosition, box.maxWidth),
            onPanUpdate: (d) => _setHover(d.localPosition, box.maxWidth),
            child: CustomPaint(
              size: Size(box.maxWidth, box.maxHeight),
              painter: _RevenuePainter(
                days: widget.days,
                revenue: widget.revenue,
                orders: widget.orders,
                hover: _hover,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RevenuePainter extends CustomPainter {
  static const double leftPad = 46;
  static const double rightPad = 10;
  static const double topPad = 14;
  static const double bottomPad = 30;

  final List<DateTime> days;
  final List<double> revenue;
  final List<double> orders;
  final int? hover;

  _RevenuePainter({
    required this.days,
    required this.revenue,
    required this.orders,
    required this.hover,
  });

  double _niceStep(double v) {
    if (v <= 0) return 250000;
    final raw = v / 4;
    final mag = math.pow(10, (math.log(raw) / math.ln10).floor()).toDouble();
    final f = raw / mag;
    final ns = f <= 1 ? 1.0 : f <= 2 ? 2.0 : f <= 2.5 ? 2.5 : f <= 5 ? 5.0 : 10.0;
    return ns * mag;
  }

  Path _smooth(List<Offset> pts) {
    final p = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (var i = 1; i < pts.length; i++) {
      final a = pts[i - 1];
      final b = pts[i];
      final mx = (a.dx + b.dx) / 2;
      p.cubicTo(mx, a.dy, mx, b.dy, b.dx, b.dy);
    }
    return p;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final n = days.length;
    final plot = Rect.fromLTRB(
      leftPad,
      topPad,
      size.width - rightPad,
      size.height - bottomPad,
    );
    if (n == 0 || plot.width <= 0 || plot.height <= 0) return;

    final maxRev = revenue.fold<double>(0, (a, b) => a > b ? a : b);
    final step = _niceStep(maxRev);
    final axisMax = step * 4;

    // Grid + label sumbu Y
    final gridPaint = Paint()
      ..color = AdminColors.line
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    for (var i = 0; i <= 4; i++) {
      final y = plot.bottom - plot.height * i / 4;
      _dashPath(
        canvas,
        Path()
          ..moveTo(plot.left, y)
          ..lineTo(plot.right, y),
        gridPaint,
        3,
        4,
      );
      final tp = _tp(compactRp(step * i), 10.5, AdminColors.muted);
      tp.paint(canvas, Offset(plot.left - 8 - tp.width, y - tp.height / 2));
    }

    double xAt(int i) =>
        n == 1 ? plot.center.dx : plot.left + plot.width * i / (n - 1);

    // Label sumbu X
    final every = n <= 9 ? 1 : (n / 8).ceil();
    final fmt = DateFormat('d MMM', 'id_ID');
    for (var i = 0; i < n; i += every) {
      final tp = _tp(fmt.format(days[i]), 10.5, AdminColors.muted);
      tp.paint(canvas, Offset(xAt(i) - tp.width / 2, plot.bottom + 10));
    }

    // Titik data
    final maxOrd = orders.fold<double>(0, (a, b) => a > b ? a : b);
    final revPts = <Offset>[
      for (var i = 0; i < n; i++)
        Offset(xAt(i), plot.bottom - plot.height * (revenue[i] / axisMax)),
    ];
    final ordPts = <Offset>[
      for (var i = 0; i < n; i++)
        Offset(
          xAt(i),
          plot.bottom -
              plot.height * 0.55 * (maxOrd == 0 ? 0 : orders[i] / maxOrd),
        ),
    ];

    // Blok sorotan saat hover
    final h = hover;
    if (h != null && h < n) {
      final hx = xAt(h);
      final bw = n == 1 ? plot.width : plot.width / (n - 1);
      final band = Rect.fromLTRB(
        math.max(plot.left, hx - bw / 2),
        plot.top,
        math.min(plot.right, hx + bw / 2),
        plot.bottom,
      );
      canvas.drawRect(band, Paint()..color = const Color(0x14FF8A00));
    }

    // Garis
    if (n > 1) {
      _dashPath(
        canvas,
        _smooth(ordPts),
        Paint()
          ..color = AdminColors.orangeLight
          ..strokeWidth = 1.8
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
        5,
        4,
      );
      canvas.drawPath(
        _smooth(revPts),
        Paint()
          ..color = AdminColors.orange
          ..strokeWidth = 2.4
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    } else {
      canvas.drawCircle(
        revPts.first,
        4,
        Paint()..color = AdminColors.orange,
      );
    }

    // Titik + tooltip
    if (h != null && h < n) {
      final p = revPts[h];
      canvas.drawCircle(p, 5, Paint()..color = Colors.white);
      canvas.drawCircle(
        p,
        5,
        Paint()
          ..color = AdminColors.orange
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );

      final t1 = _tp(
        'Pendapatan · ${fmt.format(days[h])}',
        10,
        AdminColors.muted,
      );
      final t2 = _tp(
        rupiah(revenue[h].round()),
        13,
        AdminColors.ink,
        weight: FontWeight.w700,
      );
      final t3 = _tp('${orders[h].round()} pesanan', 10, AdminColors.muted);

      final w = math.max(t1.width, math.max(t2.width, t3.width)) + 20;
      const hh = 62.0;
      final left =
          (p.dx - w / 2).clamp(0.0, math.max(0.0, size.width - w)).toDouble();
      var top = p.dy - hh - 12;
      if (top < 0) top = p.dy + 14;

      final rr = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, w, hh),
        const Radius.circular(10),
      );
      canvas.drawShadow(
        Path()..addRRect(rr),
        const Color(0x33000000),
        6,
        false,
      );
      canvas.drawRRect(rr, Paint()..color = Colors.white);
      t1.paint(canvas, Offset(left + 10, top + 8));
      t2.paint(canvas, Offset(left + 10, top + 22));
      t3.paint(canvas, Offset(left + 10, top + 42));
    }
  }

  @override
  bool shouldRepaint(covariant _RevenuePainter old) => true;
}

// =============================================================
// DONUT
// =============================================================

class DonutChart extends StatelessWidget {
  final List<double> values;
  final List<Color> colors;
  final double size;
  final double stroke;
  final Widget? center;

  const DonutChart({
    super.key,
    required this.values,
    required this.colors,
    this.size = 200,
    this.stroke = 22,
    this.center,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _DonutPainter(values: values, colors: colors, stroke: stroke),
        child: Center(child: center),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;
  final double stroke;

  _DonutPainter({
    required this.values,
    required this.colors,
    required this.stroke,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.width - stroke) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final total = values.fold<double>(0, (a, b) => a + b);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    if (total <= 0) {
      canvas.drawCircle(center, radius, paint..color = AdminColors.peachSoft);
      return;
    }

    final nonZero = values.where((v) => v > 0).length;
    if (nonZero == 1) {
      final i = values.indexWhere((v) => v > 0);
      canvas.drawCircle(center, radius, paint..color = colors[i % colors.length]);
      return;
    }

    final gap = stroke / radius + 0.05;
    var start = -math.pi / 2;
    for (var i = 0; i < values.length; i++) {
      final sweep = values[i] / total * 2 * math.pi;
      if (sweep > gap + 0.01) {
        canvas.drawArc(
          rect,
          start + gap / 2,
          sweep - gap,
          false,
          paint..color = colors[i % colors.length],
        );
      }
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) => true;
}

// =============================================================
// GAUGE SETENGAH LINGKARAN
// =============================================================

class GaugeChart extends StatelessWidget {
  final double progress; // 0..1
  final double width;
  final double stroke;

  const GaugeChart({
    super.key,
    required this.progress,
    this.width = 220,
    this.stroke = 26,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, width / 2 + stroke / 2 + 4),
      painter: _GaugePainter(progress: progress, stroke: stroke),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double progress;
  final double stroke;

  _GaugePainter({required this.progress, required this.stroke});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      stroke / 2,
      stroke / 2,
      size.width - stroke,
      size.width - stroke,
    );

    final track = Paint()
      ..color = const Color(0xFFFFE9D2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, math.pi, math.pi, false, track);

    final p = progress.clamp(0.0, 1.0).toDouble();
    if (p > 0) {
      final prog = Paint()
        ..color = AdminColors.orange
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, math.pi, math.pi * p, false, prog);
    }
  }

  @override
  bool shouldRepaint(covariant _GaugePainter old) =>
      old.progress != progress || old.stroke != stroke;
}