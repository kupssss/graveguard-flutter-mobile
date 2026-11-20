// ============================================================================
// FLOOR COMPONENT
// ============================================================================
import 'dart:math' as math;

import 'package:flutter/material.dart';

class Floor extends StatelessWidget {
  const Floor({super.key});

  static final ValueNotifier<double> yawNotifier = ValueNotifier<double>(0.0);
  static double get yaw => yawNotifier.value;
  static set yaw(double v) => yawNotifier.value = v;

  static int gridCols = 4100;
  static int gridRows = 5400;

  static final ValueNotifier<int> gridVersion = ValueNotifier<int>(0);
  static void notifyGridChanged() => gridVersion.value++;

  static final Listenable repaint =
      Listenable.merge([yawNotifier, gridVersion]);

  static const double tileW = 48;
  static const double tileH = 24;
  static const double margin = 600;

  static double _cachedYaw = double.nan;
  static int _cachedCols = -1;
  static int _cachedRows = -1;
  static double _minX = 0, _maxX = 0, _minY = 0, _maxY = 0;

  static void _ensureBounds() {
    final y = yawNotifier.value;
    if (y == _cachedYaw && gridCols == _cachedCols && gridRows == _cachedRows) {
      return;
    }

    final cosY = math.cos(y);
    final sinY = math.sin(y);

    final xs = <double>[0, gridCols.toDouble(), gridCols.toDouble(), 0];
    final ys = <double>[0, 0, gridRows.toDouble(), gridRows.toDouble()];

    double minX = double.infinity, maxX = -double.infinity;
    double minY = double.infinity, maxY = -double.infinity;

    for (int i = 0; i < 4; i++) {
      final rx = xs[i] * cosY - ys[i] * sinY;
      final ry = xs[i] * sinY + ys[i] * cosY;
      final px = (rx - ry) * (tileW / 2);
      final py = (rx + ry) * (tileH / 2);
      if (px < minX) minX = px;
      if (px > maxX) maxX = px;
      if (py < minY) minY = py;
      if (py > maxY) maxY = py;
    }

    _minX = minX;
    _maxX = maxX;
    _minY = minY;
    _maxY = maxY;
    _cachedYaw = y;
    _cachedCols = gridCols;
    _cachedRows = gridRows;
  }

  static double get canvasWidth {
    _ensureBounds();
    return (_maxX - _minX) + margin * 2;
  }

  static double get canvasHeight {
    _ensureBounds();
    return (_maxY - _minY) + margin * 2;
  }

  static Offset get isoOrigin {
    _ensureBounds();
    return Offset(margin - _minX, margin - _minY);
  }

  static Offset get pinPoint => Offset(margin, canvasHeight - margin);

  static Offset project(double gx, double gy) {
    final y = yawNotifier.value;
    return projectWith(gx, gy, math.cos(y), math.sin(y));
  }

  static Offset projectWith(double gx, double gy, double cosY, double sinY) {
    final rx = gx * cosY - gy * sinY;
    final ry = gx * sinY + gy * cosY;
    final origin = isoOrigin;

    return Offset(
      origin.dx + (rx - ry) * (tileW / 2),
      origin.dy + (rx + ry) * (tileH / 2),
    );
  }

  static Offset unproject(Offset p) {
    final y = yawNotifier.value;
    final cosY = math.cos(y);
    final sinY = math.sin(y);
    final origin = isoOrigin;

    final a = (p.dx - origin.dx) * 2 / tileW;
    final b = (p.dy - origin.dy) * 2 / tileH;
    final rx = (a + b) / 2;
    final ry = (b - a) / 2;

    return Offset(
      rx * cosY + ry * sinY,
      -rx * sinY + ry * cosY,
    );
  }

  static double depth(double gx, double gy) {
    final y = yawNotifier.value;
    final cosY = math.cos(y);
    final sinY = math.sin(y);

    return (gx * cosY - gy * sinY) + (gx * sinY + gy * cosY);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: repaint,
      builder: (context, _) {
        final size = Size(canvasWidth, canvasHeight);
        return SizedBox.fromSize(
          size: size,
          child: RepaintBoundary(
            child: CustomPaint(
              size: size,
              painter: _FloorPainter(),
            ),
          ),
        );
      },
    );
  }
}

class _FloorPainter extends CustomPainter {
  _FloorPainter() : super(repaint: Floor.repaint);

  @override
  void paint(Canvas canvas, Size size) {
    final cols = Floor.gridCols.toDouble();
    final rows = Floor.gridRows.toDouble();

    final c1 = Floor.project(0, 0);
    final c2 = Floor.project(cols, 0);
    final c3 = Floor.project(cols, rows);
    final c4 = Floor.project(0, rows);

    final floorPath = Path()
      ..moveTo(c1.dx, c1.dy)
      ..lineTo(c2.dx, c2.dy)
      ..lineTo(c3.dx, c3.dy)
      ..lineTo(c4.dx, c4.dy)
      ..close();

    canvas.drawPath(floorPath, Paint()..color = const Color(0xFF3A7A3A));
    canvas.drawPath(
      floorPath,
      Paint()
        ..color = const Color(0xFF2A5A2A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(covariant _FloorPainter oldDelegate) => true;
}

class IsoBlock {
  final double gx, gy, gw, gh, height;

  const IsoBlock({
    required this.gx,
    required this.gy,
    required this.gw,
    required this.gh,
    required this.height,
  });
}