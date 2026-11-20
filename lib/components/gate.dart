// ============================================================================
// GATE COMPONENT
// ============================================================================
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'floor.dart';

const List<Map<String, dynamic>> kGateConfigs = [
  {
    'id': 'main_gate',
    'visible': true,
    'gx': 4060.0,
    'gy': 3150.0,
    'axis': 'y',
    'scale': 90.0,
    'line1': 'MANILA SOUTH',
    'line2': 'CEMETERY',
  },
];

double _n(Map<String, dynamic> m, String k, double fallback) =>
    (m[k] as num?)?.toDouble() ?? fallback;

Offset _centroid(List<Offset> pts) {
  var x = 0.0, y = 0.0;
  for (final p in pts) {
    x += p.dx;
    y += p.dy;
  }
  return Offset(x / pts.length, y / pts.length);
}

class Gate extends StatelessWidget {
  const Gate({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Floor.repaint,
      builder: (_, __) => CustomPaint(
        size: Size(Floor.canvasWidth, Floor.canvasHeight),
        painter: _GatePainter(),
      ),
    );
  }
}

class _Edge {
  final Offset a, b;
  final Color color;
  final double depth;

  const _Edge(this.a, this.b, this.color, this.depth);
}

class _GatePainter extends CustomPainter {
  _GatePainter() : super(repaint: Floor.repaint);

  static const stoneBase = Color(0xFF5B5048);
  static const stoneCap = Color(0xFF716657);
  static const stoneCapEdge = Color(0xFF453D37);
  static const ironDark = Color(0xFF17140F);
  static const gold = Color(0xFFC9A227);
  static const goldHighlight = Color(0xFFF1DC8F);

  @override
  void paint(Canvas canvas, Size size) {
    final gates = [
      for (final c in kGateConfigs)
        if (c['visible'] != false) c,
    ]..sort((a, b) => Floor.depth(_n(a, 'gx', 0), _n(a, 'gy', 0))
        .compareTo(Floor.depth(_n(b, 'gx', 0), _n(b, 'gy', 0))));

    for (final gate in gates) {
      _drawGate(canvas, gate);
    }
  }

  void _drawGate(Canvas canvas, Map<String, dynamic> cfg) {
    final cx = _n(cfg, 'gx', 0);
    final cy = _n(cfg, 'gy', 0);
    final k = _n(cfg, 'scale', 40);
    final alongY = cfg['axis'] != 'x';

    final halfSpan = 2.0 * k;
    final pillarWidth = 0.5 * k;
    final pillarDepth = 0.9 * k;
    final h = 85.0 * k;

    Offset proj(double s, double d) {
      final world = alongY ? Offset(cx + d, cy + s) : Offset(cx + s, cy + d);
      return Floor.project(world.dx, world.dy);
    }

    List<Offset> rect(double s0, double s1, double d0, double d1) =>
        [proj(s0, d0), proj(s1, d0), proj(s1, d1), proj(s0, d1)];

    final leftBase =
        rect(-halfSpan, -halfSpan + pillarWidth, -pillarDepth / 2, pillarDepth / 2);
    final rightBase =
        rect(halfSpan - pillarWidth, halfSpan, -pillarDepth / 2, pillarDepth / 2);

    final leftTop = _centroid(leftBase) - Offset(0, h);
    final rightTop = _centroid(rightBase) - Offset(0, h);

    canvas.drawOval(
      Rect.fromCenter(
        center: proj(0, 0) + Offset(0, 8 * k),
        width: 170 * k,
        height: 34 * k,
      ),
      Paint()..color = Colors.black.withOpacity(0.2),
    );

    _drawDoors(canvas, proj(-halfSpan, 0), proj(halfSpan, 0), h, k);

    final pillars = [leftBase, rightBase]
      ..sort((a, b) => _centroid(a).dy.compareTo(_centroid(b).dy));
    for (final base in pillars) {
      _drawPillar(canvas, base, h, k);
    }

    _drawArchAndSign(
      canvas,
      leftTop - Offset(0, 12 * k),
      rightTop - Offset(0, 12 * k),
      k,
      (cfg['line1'] as String?) ?? 'GRAVEGUARD',
      (cfg['line2'] as String?) ?? 'MEMORIAL PARK',
    );
  }

  void _prism(Canvas canvas, List<Offset> base, double height, Color top,
      Color sideA, Color sideB) {
    final edges = <_Edge>[];
    for (int i = 0; i < base.length; i++) {
      final a = base[i];
      final b = base[(i + 1) % base.length];
      edges.add(_Edge(a, b, i.isEven ? sideA : sideB, (a.dy + b.dy) / 2));
    }
    edges.sort((a, b) => a.depth.compareTo(b.depth));

    final outline = Paint()
      ..color = Colors.black.withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (final e in edges) {
      final path = Path()
        ..moveTo(e.a.dx, e.a.dy)
        ..lineTo(e.b.dx, e.b.dy)
        ..lineTo(e.b.dx, e.b.dy - height)
        ..lineTo(e.a.dx, e.a.dy - height)
        ..close();
      canvas.drawPath(path, Paint()..color = e.color);
      canvas.drawPath(path, outline);
    }

    final topPath = Path()
      ..addPolygon(base.map((p) => p - Offset(0, height)).toList(), true);
    canvas.drawPath(topPath, Paint()..color = top);
    canvas.drawPath(topPath, outline);
  }

  Color _shade(Color c, double delta) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness + delta).clamp(0.0, 1.0)).toColor();
  }

  void _drawPillar(Canvas canvas, List<Offset> base, double h, double k) {
    _prism(canvas, base, h, stoneBase, _shade(stoneBase, -0.10),
        _shade(stoneBase, -0.20));

    final topPts = base.map((p) => p - Offset(0, h)).toList();
    final center = _centroid(topPts);
    final capTop = topPts.map((p) => center + (p - center) * 1.4).toList();
    final capBase = capTop.map((p) => p + Offset(0, 5 * k)).toList();
    _prism(canvas, capBase, 5 * k, stoneCap, stoneCapEdge,
        _shade(stoneCapEdge, -0.05));

    final finialBase = center - Offset(0, 1 * k);
    final finialTip = finialBase - Offset(0, 17 * k);
    canvas.drawLine(
      finialBase,
      finialTip + Offset(0, 4 * k),
      Paint()
        ..color = const Color(0xFF3E2E12)
        ..strokeWidth = 2 * k,
    );
    canvas.drawCircle(finialTip, 5.2 * k, Paint()..color = gold);
    canvas.drawCircle(finialTip - Offset(1.3 * k, 1.3 * k), 1.7 * k,
        Paint()..color = goldHighlight);
  }

  void _drawDoors(Canvas canvas, Offset bl, Offset br, double h, double k) {
    final tl = bl - Offset(0, h);
    final tr = br - Offset(0, h);

    canvas.drawPath(
      Path()
        ..moveTo(tl.dx, tl.dy)
        ..lineTo(tr.dx, tr.dy)
        ..lineTo(br.dx, br.dy)
        ..lineTo(bl.dx, bl.dy)
        ..close(),
      Paint()..color = const Color(0xFF20201F).withOpacity(0.35),
    );

    const barCount = 19;
    final barPaint = Paint()
      ..color = ironDark
      ..strokeWidth = 2.4 * k
      ..strokeCap = StrokeCap.round;
    final studPaint = Paint()..color = const Color(0xFF3E2E12);

    for (int i = 0; i <= barCount; i++) {
      final t = i / barCount;
      final top = Offset.lerp(tl, tr, t)!;
      canvas.drawLine(top, Offset.lerp(bl, br, t)!, barPaint);
      if (i.isOdd) canvas.drawCircle(top, 2.2 * k, studPaint);
    }

    final railPaint = Paint()
      ..color = ironDark
      ..strokeWidth = 3 * k;
    for (final f in [0.28, 0.82]) {
      canvas.drawLine(Offset.lerp(tl, bl, f)!, Offset.lerp(tr, br, f)!, railPaint);
    }

    final seamTop = Offset.lerp(tl, tr, 0.5)!;
    final seamBottom = Offset.lerp(bl, br, 0.5)!;
    canvas.drawLine(
      seamTop,
      seamBottom,
      Paint()
        ..color = const Color(0xFF0F0D0A)
        ..strokeWidth = 3 * k,
    );
    canvas.drawCircle(
      Offset.lerp(seamTop, seamBottom, 0.45)!,
      7 * k,
      Paint()
        ..color = gold
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2 * k,
    );
  }

  Offset _quad(Offset p0, Offset p1, Offset p2, double t) {
    final a = Offset.lerp(p0, p1, t)!;
    final b = Offset.lerp(p1, p2, t)!;
    return Offset.lerp(a, b, t)!;
  }

  void _drawArchAndSign(Canvas canvas, Offset archLeft, Offset archRight,
      double k, String line1, String line2) {
    final archPeak = Offset(
      (archLeft.dx + archRight.dx) / 2,
      math.min(archLeft.dy, archRight.dy) - 40 * k,
    );

    final archPath = Path()
      ..moveTo(archLeft.dx, archLeft.dy)
      ..quadraticBezierTo(archPeak.dx, archPeak.dy, archRight.dx, archRight.dy);

    canvas.drawPath(
      archPath,
      Paint()
        ..color = Colors.black.withOpacity(0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7 * k
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3 * k),
    );
    canvas.drawPath(
      archPath,
      Paint()
        ..color = ironDark
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4 * k
        ..strokeCap = StrokeCap.round,
    );

    _drawScroll(canvas, archLeft, k, flip: false);
    _drawScroll(canvas, archRight, k, flip: true);

    final spikePaint = Paint()
      ..color = ironDark
      ..strokeWidth = 2 * k;
    for (int i = 1; i <= 6; i++) {
      final base = _quad(archLeft, archPeak, archRight, 0.15 * i);
      final tip = base - Offset(0, 10 * k);
      canvas.drawLine(base, tip, spikePaint);
      canvas.drawCircle(tip, 1.6 * k, Paint()..color = gold);
    }

    _drawPlaque(canvas, archPeak + Offset(0, 24 * k), k, line1, line2);

    for (final t in [0.26, 0.74]) {
      _drawLantern(
          canvas, _quad(archLeft, archPeak, archRight, t) + Offset(0, 4 * k), k);
    }
  }

  void _drawScroll(Canvas canvas, Offset origin, double k,
      {required bool flip}) {
    final dir = flip ? -1.0 : 1.0;
    final path = Path()
      ..moveTo(origin.dx, origin.dy)
      ..relativeCubicTo(
          6 * dir * k, -4 * k, 10 * dir * k, 4 * k, 4 * dir * k, 8 * k);

    canvas.drawPath(
      path,
      Paint()
        ..color = ironDark
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4 * k
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(origin + Offset(4 * dir * k, 6 * k), 1.6 * k,
        Paint()..color = gold);
  }

  void _drawPlaque(
      Canvas canvas, Offset center, double k, String line1, String line2) {
    final w = 118.0 * k;
    final h = 28.0 * k;
    final rect = Rect.fromCenter(center: center, width: w, height: h);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(4 * k));

    canvas.drawRRect(rrect.shift(Offset(2 * k, 3 * k)),
        Paint()..color = Colors.black.withOpacity(0.25));
    canvas.drawRRect(rrect, Paint()..color = const Color(0xFF1B1B1B));
    canvas.drawRRect(
      rrect.deflate(2 * k),
      Paint()
        ..color = gold
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4 * k,
    );

    final text = TextPainter(
      text: TextSpan(
        text: '$line1\n$line2',
        style: TextStyle(
          color: const Color(0xFFE8D9A0),
          fontSize: 9 * k,
          height: 1.15,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.6 * k,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: w);
    text.paint(canvas, center - Offset(text.width / 2, text.height / 2));

    final chain = Paint()
      ..color = ironDark
      ..strokeWidth = 1.4 * k;
    canvas.drawLine(rect.topLeft + Offset(6 * k, 0),
        rect.topLeft + Offset(6 * k, -10 * k), chain);
    canvas.drawLine(rect.topRight - Offset(6 * k, 0),
        rect.topRight - Offset(6 * k, 10 * k), chain);
  }

  void _drawLantern(Canvas canvas, Offset topAnchor, double k) {
    final body = topAnchor + Offset(0, 14 * k);

    canvas.drawLine(
      topAnchor,
      body - Offset(0, 6 * k),
      Paint()
        ..color = ironDark
        ..strokeWidth = 1.4 * k,
    );
    canvas.drawCircle(
      body,
      9 * k,
      Paint()
        ..color = const Color(0xFFFFC966).withOpacity(0.35)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 6 * k),
    );

    final rect = Rect.fromCenter(center: body, width: 10 * k, height: 13 * k);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(2 * k));
    canvas.drawRRect(rrect, Paint()..color = const Color(0xFFFFD98A));
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = ironDark
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2 * k,
    );
  }

  @override
  bool shouldRepaint(covariant _GatePainter oldDelegate) => true;
}