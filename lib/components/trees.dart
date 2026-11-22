// ============================================================================
// TREES COMPONENT
// ============================================================================
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'floor.dart';
import 'group.dart' show kGroupConfigs;

// Each entry is a straight line of trees from (x1, y1) to (x2, y2) in grid
// coordinates, placed every `spacing` units along the line.
//   scale    : overall tree size multiplier
//   jitter   : random sideways wobble (grid units) so the row looks natural
//   conifers : fraction (0..1) of trees drawn as tall pine/cypress shapes
//
// The gate is at x = 4060, y = 3150 (about 2970..3330 wide), and the floor
// ends at x = 4100, y = 5400. The rows leave a clear opening at the gate.
const List<Map<String, dynamic>> kTreeLineConfigs = [
  // South of the gate, down to the end of the floor
  {
    'id': 'gate_trees_south',
    'visible': true,
    'x1': 4010.0,
    'y1': 3450.0,
    'x2': 4010.0,
    'y2': 5330.0,
    'spacing': 140.0,
    'scale': 1.0,
    'jitter': 30.0,
    'conifers': 0.2,
  },
  // North of the gate, up to the end of the floor
  {
    'id': 'gate_trees_north',
    'visible': true,
    'x1': 4010.0,
    'y1': 2850.0,
    'x2': 4010.0,
    'y2': 70.0,
    'spacing': 140.0,
    'scale': 1.0,
    'jitter': 30.0,
    'conifers': 0.2,
  },
];

// Bush rows along the outer left and right edges of the floor (not the gate).
//   spacing : distance between bushes along the line (grid units)
//   scale   : overall bush size multiplier
//   jitter  : random sideways wobble (grid units)
//   gaps    : [fromY, toY] ranges that stay free of bushes (gate opening)
//
// Left-edge groups start at x = 50 and right-edge groups end at x = 3950, so
// the rows sit just inside the floor edges (x = 0 and x = 4100).
const List<Map<String, dynamic>> kBushLineConfigs = [
  {
    'id': 'bushes_left_edge',
    'visible': true,
    'x1': 15.0,
    'y1': 40.0,
    'x2': 15.0,
    'y2': 5360.0,
    'spacing': 55.0,
    'scale': 1.0,
    'jitter': 6.0,
    'gaps': <List<double>>[],
  },
  {
    'id': 'bushes_right_edge',
    'visible': true,
    'x1': 4075.0,
    'y1': 40.0,
    'x2': 4075.0,
    'y2': 5360.0,
    'spacing': 55.0,
    'scale': 1.0,
    'jitter': 6.0,
    'gaps': <List<double>>[
      [2900.0, 3400.0], // gate opening (gate is ~2970..3330)
    ],
  },
  // Bottom edge: more free space here (bottom groups end at y = 5290, floor
  // ends at y = 5400), so the bushes are bigger. The row stops before the
  // last gate tree (x = 4010).
  {
    'id': 'bushes_bottom_edge',
    'visible': true,
    'x1': 40.0,
    'y1': 5350.0,
    'x2': 3960.0,
    'y2': 5350.0,
    'spacing': 90.0,
    'scale': 1.8,
    'jitter': 6.0,
    'gaps': <List<double>>[],
  },
];

double _n(Map<String, dynamic> m, String k, double fallback) =>
    (m[k] as num?)?.toDouble() ?? fallback;

class TreeLine extends StatelessWidget {
  const TreeLine({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Floor.repaint,
      builder: (_, __) => CustomPaint(
        size: Size(Floor.canvasWidth, Floor.canvasHeight),
        painter: _TreePainter(),
      ),
    );
  }
}

class _TreeItem {
  final Offset base; // projected position on the floor
  final double scale;
  final int seed;
  final bool conifer;
  final bool bush;
  const _TreeItem(this.base, this.scale, this.seed, this.conifer,
      {this.bush = false});
}

class _TreePainter extends CustomPainter {
  _TreePainter() : super(repaint: Floor.repaint);

  static const barkLight = Color(0xFF7A5A3A);
  static const barkDark = Color(0xFF3A2816);

  // A few green families so the row does not look copy-pasted.
  static const List<List<Color>> _greens = [
    [Color(0xFF173F1E), Color(0xFF2E7D32), Color(0xFF7CC86A)], // classic
    [Color(0xFF1B4A2A), Color(0xFF3A8A3E), Color(0xFF8BD47A)], // fresh
    [Color(0xFF2A4A1A), Color(0xFF4F8A2C), Color(0xFFA6D45F)], // olive-lime
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final items = <_TreeItem>[];

    // ---- Tree rows ---------------------------------------------------------
    for (int c = 0; c < kTreeLineConfigs.length; c++) {
      final cfg = kTreeLineConfigs[c];
      if (cfg['visible'] == false) continue;

      final x1 = _n(cfg, 'x1', 0);
      final y1 = _n(cfg, 'y1', 0);
      final x2 = _n(cfg, 'x2', 0);
      final y2 = _n(cfg, 'y2', 0);
      final spacing = math.max(_n(cfg, 'spacing', 140), 1.0);
      final scale = _n(cfg, 'scale', 1.0);
      final jitter = _n(cfg, 'jitter', 0);
      final conifers = _n(cfg, 'conifers', 0).clamp(0.0, 1.0);

      final len = math.sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1));
      final count = math.max(1, (len / spacing).floor() + 1);

      for (int i = 0; i < count; i++) {
        final seed = c * 1000 + i;
        final rng = math.Random(seed * 31 + 7);
        final t = count == 1 ? 0.0 : i / (count - 1);
        final gx = x1 + (x2 - x1) * t + (rng.nextDouble() - 0.5) * 2 * jitter;
        final gy = y1 + (y2 - y1) * t + (rng.nextDouble() - 0.5) * spacing * 0.2;
        final isConifer = rng.nextDouble() < conifers;
        items.add(
          _TreeItem(Floor.project(gx, gy), scale, seed, isConifer),
        );
      }
    }

    // ---- Bush rows (left and right edges of the map, gate left open) -------
    for (int c = 0; c < kBushLineConfigs.length; c++) {
      final cfg = kBushLineConfigs[c];
      if (cfg['visible'] == false) continue;

      final x1 = _n(cfg, 'x1', 0);
      final y1 = _n(cfg, 'y1', 0);
      final x2 = _n(cfg, 'x2', 0);
      final y2 = _n(cfg, 'y2', 0);
      final spacing = math.max(_n(cfg, 'spacing', 60), 1.0);
      final scale = _n(cfg, 'scale', 1.0);
      final jitter = _n(cfg, 'jitter', 0);
      final gaps = (cfg['gaps'] as List?) ?? const [];

      final len = math.sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1));
      final count = math.max(1, (len / spacing).floor() + 1);

      for (int i = 0; i < count; i++) {
        final seed = 100000 + c * 10000 + i;
        final rng = math.Random(seed * 31 + 7);
        final t = count == 1 ? 0.0 : i / (count - 1);
        final lineX = x1 + (x2 - x1) * t;
        final lineY = y1 + (y2 - y1) * t;

        // Keep the gate (or any other gap) clear.
        if (_inGap(gaps, lineY)) continue;

        final gx = lineX + (rng.nextDouble() - 0.5) * 2 * jitter;
        final gy = lineY + (rng.nextDouble() - 0.5) * spacing * 0.25;

        // Never place a bush on top of a side group.
        if (_hitsGroup(gx, gy, 12)) continue;

        items.add(
          _TreeItem(Floor.project(gx, gy), scale, seed, false, bush: true),
        );
      }
    }

    // Far items first, near items on top.
    items.sort((a, b) => a.base.dy.compareTo(b.base.dy));

    for (final t in items) {
      if (t.bush) {
        _drawBush(canvas, t);
      } else if (t.conifer) {
        _drawConifer(canvas, t);
      } else {
        _drawBroadleaf(canvas, t);
      }
    }
  }

  bool _inGap(List gaps, double y) {
    for (final g in gaps) {
      final from = (g[0] as num).toDouble();
      final to = (g[1] as num).toDouble();
      if (y >= from && y <= to) return true;
    }
    return false;
  }

  bool _hitsGroup(double gx, double gy, double margin) {
    for (final g in kGroupConfigs) {
      if (g['visible'] == false) continue;
      final x = _n(g, 'gx', 0);
      final y = _n(g, 'gy', 0);
      final w = _n(g, 'gw', 0);
      final h = _n(g, 'gh', 0);
      if (gx >= x - margin &&
          gx <= x + w + margin &&
          gy >= y - margin &&
          gy <= y + h + margin) {
        return true;
      }
    }
    return false;
  }

  Color _shade(Color c, double delta) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness + delta).clamp(0.0, 1.0)).toColor();
  }

  void _groundShadow(Canvas canvas, Offset base, double width, double s) {
    canvas.drawOval(
      Rect.fromCenter(
        center: base + Offset(width * 0.18, 140 * s),
        width: width,
        height: width * 0.28,
      ),
      Paint()
        ..color = Colors.black.withOpacity(0.28)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 110 * s),
    );
  }

  // --------------------------------------------------------------------------
  // Bush: dense rounded mound of leaf clumps, with flowers on most of them
  // --------------------------------------------------------------------------
  static const List<Color> _flowerColors = [
    Color(0xFFFF6FA5), // pink
    Color(0xFFFFFFFF), // white
    Color(0xFFFF5A4F), // red
    Color(0xFFFFD84D), // yellow
    Color(0xFFB57BFF), // purple
  ];

  void _drawBush(Canvas canvas, _TreeItem t) {
    final rng = math.Random(t.seed * 6113 + 5);
    final s = t.scale * (0.85 + 0.3 * rng.nextDouble());
    final palette = _greens[rng.nextInt(_greens.length)];
    final base = t.base;
    final r = 400.0 * s;
    final rx = r * 1.35; // half width of the mound
    final ry = r * 1.0; // height of the mound

    _groundShadow(canvas, base, rx * 2.6, s * 0.35);

    // Dark underlay so the gaps between clumps read as depth, not holes.
    canvas.drawOval(
      Rect.fromCenter(
        center: base + Offset(0, -ry * 0.32),
        width: rx * 2.0,
        height: ry * 1.0,
      ),
      Paint()..color = _shade(palette[0], -0.04),
    );

    // Leaf clumps: a bottom row for fullness, then a dome on top.
    final clumps = <(Offset, double)>[];
    for (int i = 0; i < 5; i++) {
      final fx = -0.8 + 1.6 * (i / 4) + (rng.nextDouble() - 0.5) * 0.15;
      clumps.add((
        Offset(rx * fx, -r * (0.18 + 0.1 * rng.nextDouble())),
        r * (0.42 + 0.12 * rng.nextDouble()),
      ));
    }
    for (int i = 0; i < 11; i++) {
      final a = math.pi + rng.nextDouble() * math.pi; // upper half only
      final rad = 0.25 + 0.6 * math.sqrt(rng.nextDouble());
      clumps.add((
        Offset(math.cos(a) * rx * rad * 0.85, math.sin(a) * ry * rad * 0.95),
        r * (0.3 + 0.18 * rng.nextDouble()),
      ));
    }
    // Lower clumps first, upper clumps on top.
    clumps.sort((a, b) => b.$1.dy.compareTo(a.$1.dy));

    for (final (off, cr) in clumps) {
      final h = (-off.dy / ry).clamp(0.0, 1.0); // 0 bottom .. 1 top
      Color col = Color.lerp(palette[0], palette[1], 0.35 + h * 0.65)!;
      col = Color.lerp(col, palette[2], h * h * 0.35)!;
      final c = base + off;
      canvas.drawCircle(
        c,
        cr,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-0.4, -0.5),
            radius: 1.0,
            colors: [_shade(col, 0.12), col, _shade(col, -0.16)],
            stops: const [0.0, 0.55, 1.0],
          ).createShader(Rect.fromCircle(center: c, radius: cr)),
      );
      // Thin dark rim so each clump is readable
      canvas.drawCircle(
        c,
        cr,
        Paint()
          ..color = Colors.black.withOpacity(0.10)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8 * s,
      );
    }

    // Small leaf dots for texture (dark and light)
    final dotDark = Paint()..color = palette[0].withOpacity(0.55);
    final dotLight = Paint()..color = palette[2].withOpacity(0.55);
    for (int i = 0; i < 16; i++) {
      final a = math.pi + rng.nextDouble() * math.pi;
      final rad = 0.2 + 0.7 * math.sqrt(rng.nextDouble());
      final p = base +
          Offset(math.cos(a) * rx * rad * 0.9, math.sin(a) * ry * rad * 0.95);
      canvas.drawCircle(p, r * 0.06, i.isEven ? dotDark : dotLight);
    }

    // Flowers (about 4 in 5 bushes), one or two colours per bush.
    if (rng.nextDouble() < 0.8) {
      final c1 = _flowerColors[rng.nextInt(_flowerColors.length)];
      final c2 = _flowerColors[rng.nextInt(_flowerColors.length)];
      final count = 8 + rng.nextInt(6);
      final fr = r * 0.17;
      final flowers = <Offset>[];
      for (int i = 0; i < count; i++) {
        final a = math.pi + (0.08 + 0.84 * rng.nextDouble()) * math.pi;
        final rad = 0.2 + 0.7 * math.sqrt(rng.nextDouble());
        flowers.add(base +
            Offset(math.cos(a) * rx * rad * 0.8, math.sin(a) * ry * rad * 0.9));
      }
      flowers.sort((a, b) => a.dy.compareTo(b.dy));
      for (int i = 0; i < flowers.length; i++) {
        final f = flowers[i];
        final petal = i.isEven ? c1 : c2;
        // Soft shadow under the flower
        canvas.drawCircle(
          f + Offset(fr * 0.15, fr * 0.2),
          fr * 1.05,
          Paint()..color = Colors.black.withOpacity(0.18),
        );
        // Five petals
        for (int k = 0; k < 5; k++) {
          final pa = k * math.pi * 2 / 5 - math.pi / 2;
          canvas.drawCircle(
            f + Offset(math.cos(pa), math.sin(pa)) * fr * 0.62,
            fr * 0.5,
            Paint()..color = petal,
          );
        }
        // Centre
        canvas.drawCircle(
            f, fr * 0.36, Paint()..color = const Color(0xFFF2B01E));
        canvas.drawCircle(
          f + Offset(-fr * 0.08, -fr * 0.1),
          fr * 0.14,
          Paint()..color = Colors.white.withOpacity(0.5),
        );
      }
    }
  }

  // --------------------------------------------------------------------------
  // Broadleaf tree: tapered trunk, branches, layered shaded canopy
  // --------------------------------------------------------------------------
  void _drawBroadleaf(Canvas canvas, _TreeItem t) {
    final rng = math.Random(t.seed * 7919 + 13);
    final s = t.scale * (0.85 + 0.35 * rng.nextDouble());
    final palette = _greens[rng.nextInt(_greens.length)];
    final leafDeep = palette[0];
    final leafMid = palette[1];
    final leafLight = palette[2];

    final base = t.base;
    final trunkH = 3400.0 * s;
    final wBase = 480.0 * s;
    final wTop = 280.0 * s;
    final ry = 1500.0 * s * (0.9 + 0.2 * rng.nextDouble());
    final rx = ry * (1.25 + 0.15 * rng.nextDouble());
    final center = base - Offset(0, trunkH + ry * 0.45);

    _groundShadow(canvas, base, rx * 2.4, s);

    // Trunk (tapered with root flare)
    final trunk = Path()
      ..moveTo(base.dx - wBase * 0.75, base.dy + 40 * s)
      ..quadraticBezierTo(
        base.dx - wBase * 0.5, base.dy - trunkH * 0.12,
        base.dx - wTop / 2, base.dy - trunkH * 0.35,
      )
      ..lineTo(base.dx - wTop / 2, base.dy - trunkH)
      ..lineTo(base.dx + wTop / 2, base.dy - trunkH)
      ..lineTo(base.dx + wTop / 2, base.dy - trunkH * 0.35)
      ..quadraticBezierTo(
        base.dx + wBase * 0.5, base.dy - trunkH * 0.12,
        base.dx + wBase * 0.75, base.dy + 40 * s,
      )
      ..close();
    canvas.drawPath(
      trunk,
      Paint()
        ..shader = LinearGradient(
          colors: [barkLight, _shade(barkDark, 0.04), barkDark],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(Rect.fromLTWH(
          base.dx - wBase, base.dy - trunkH, wBase * 2, trunkH,
        )),
    );
    // Bark lines
    final barkLine = Paint()
      ..color = barkDark.withOpacity(0.45)
      ..strokeWidth = 18 * s
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 4; i++) {
      final x = base.dx + (i - 1.5) * wTop * 0.22;
      final y0 = base.dy - trunkH * (0.1 + 0.18 * i);
      canvas.drawLine(
          Offset(x, y0), Offset(x + 20 * s, y0 - trunkH * 0.2), barkLine);
    }

    // Branches reaching into the canopy
    final branch = Paint()
      ..color = barkDark
      ..strokeWidth = 150 * s
      ..strokeCap = StrokeCap.round;
    final fork = base - Offset(0, trunkH * 0.92);
    canvas.drawLine(fork, center + Offset(-rx * 0.45, -ry * 0.1), branch);
    canvas.drawLine(fork, center + Offset(rx * 0.45, -ry * 0.05), branch);
    canvas.drawLine(fork, center + Offset(0, -ry * 0.45), branch);

    // Dark underside so the canopy has depth
    canvas.drawOval(
      Rect.fromCenter(
        center: center + Offset(0, ry * 0.15),
        width: rx * 2.0,
        height: ry * 1.7,
      ),
      Paint()..color = leafDeep,
    );

    // Layered leaf clusters, lit from the top-left
    final blobs = <(Offset, double)>[];
    for (int i = 0; i < 18; i++) {
      final a = rng.nextDouble() * math.pi * 2;
      final rad = math.sqrt(rng.nextDouble()) * 0.72;
      final off = Offset(
        math.cos(a) * rx * rad,
        math.sin(a) * ry * rad * 0.9,
      );
      final r = ry * (0.5 + 0.28 * rng.nextDouble());
      blobs.add((off, r));
    }
    // Lower clusters first, upper clusters on top
    blobs.sort((a, b) => b.$1.dy.compareTo(a.$1.dy));

    for (final (off, r) in blobs) {
      final h = ((-off.dy / ry) + 1) / 2; // 0 bottom .. 1 top
      Color col = Color.lerp(leafDeep, leafMid, h.clamp(0.0, 1.0))!;
      col = Color.lerp(col, leafLight, (h * h * 0.45).clamp(0.0, 1.0))!;
      final c = center + off;
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-0.35, -0.45),
            radius: 0.95,
            colors: [_shade(col, 0.10), col, _shade(col, -0.14)],
            stops: const [0.0, 0.55, 1.0],
          ).createShader(Rect.fromCircle(center: c, radius: r)),
      );
    }

    // Small bright leaf clumps on the sunny side
    final spark = Paint()..color = leafLight.withOpacity(0.55);
    for (int i = 0; i < 10; i++) {
      final a = math.pi + rng.nextDouble() * (math.pi * 0.9);
      final rad = 0.35 + rng.nextDouble() * 0.5;
      canvas.drawCircle(
        center + Offset(math.cos(a) * rx * rad, math.sin(a) * ry * rad * 0.9),
        ry * (0.10 + 0.10 * rng.nextDouble()),
        spark,
      );
    }

    // Soft rim to separate the canopy from the background
    canvas.drawOval(
      Rect.fromCenter(center: center, width: rx * 2.05, height: ry * 1.85),
      Paint()
        ..color = Colors.black.withOpacity(0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14 * s,
    );
  }

  // --------------------------------------------------------------------------
  // Conifer (pine / cypress): short trunk, stacked two-tone tiers
  // --------------------------------------------------------------------------
  void _drawConifer(Canvas canvas, _TreeItem t) {
    final rng = math.Random(t.seed * 4421 + 13);
    final s = t.scale * (0.9 + 0.3 * rng.nextDouble());
    final palette = _greens[rng.nextInt(_greens.length)];
    final dark = _shade(palette[0], 0.01);
    final mid = palette[1];

    final base = t.base;
    final trunkH = 1400.0 * s;
    final trunkW = 300.0 * s;

    _groundShadow(canvas, base, 3000 * s, s);

    // Trunk
    canvas.drawRect(
      Rect.fromLTWH(base.dx - trunkW / 2, base.dy - trunkH, trunkW, trunkH),
      Paint()..color = barkDark,
    );

    const tiers = 6;
    final tierH = 2700.0 * s;
    final step = 1250.0 * s;

    for (int i = 0; i < tiers; i++) {
      final w = 1500.0 * s * (1 - i * 0.15);
      final yBottom = base.dy - trunkH * 0.7 - i * step;
      final apex = Offset(base.dx, yBottom - tierH);
      final left = Offset(base.dx - w, yBottom);
      final right = Offset(base.dx + w, yBottom);
      final mc = Offset(base.dx, yBottom + 120 * s);

      // Lit left half
      canvas.drawPath(
        Path()
          ..moveTo(apex.dx, apex.dy)
          ..lineTo(left.dx, left.dy)
          ..quadraticBezierTo(
              base.dx - w * 0.45, yBottom + 220 * s, mc.dx, mc.dy)
          ..close(),
        Paint()..color = _shade(mid, 0.06 - i * 0.01),
      );
      // Shaded right half
      canvas.drawPath(
        Path()
          ..moveTo(apex.dx, apex.dy)
          ..lineTo(right.dx, right.dy)
          ..quadraticBezierTo(
              base.dx + w * 0.45, yBottom + 220 * s, mc.dx, mc.dy)
          ..close(),
        Paint()..color = _shade(dark, 0.02 + i * 0.005),
      );
      // Thin edge between tiers
      canvas.drawPath(
        Path()
          ..moveTo(left.dx, left.dy)
          ..quadraticBezierTo(
              base.dx - w * 0.45, yBottom + 220 * s, mc.dx, mc.dy)
          ..quadraticBezierTo(
              base.dx + w * 0.45, yBottom + 220 * s, right.dx, right.dy),
        Paint()
          ..color = Colors.black.withOpacity(0.18)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10 * s,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TreePainter oldDelegate) => true;
}