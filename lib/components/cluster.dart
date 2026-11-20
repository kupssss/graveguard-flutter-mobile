// ============================================================================
// cluster.dart
// ============================================================================

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'floor.dart';
import 'pathfinder.dart'; 
const bool kShowClusters = true;

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG 
// ─────────────────────────────────────────────────────────────────────────────
const List<Map<String, dynamic>> _clusterConfigs = [
  {
    'id': '1', 'label': 'Cluster 1', 'startX': 1050.0, 'startY': 2080.0,
    'columnCount': 26, 'columnWidth': 20.0, 'columnGap': 20.0,
    'columnDepth': 20.0, 'columnHeight': 2000.0, 'rowCount': 4,
    'isVertical': false, 'flip': false, 'labelSide': 'top',
    'labelDy': 1000.0, 'labelDx': -1000.0,
  },
  {
    'id': '2', 'label': 'Cluster 2', 'startX': 1600.0, 'startY': 2080.0,
    'columnCount': 26, 'columnWidth': 20.0, 'columnGap': 20.0,
    'columnDepth': 20.0, 'columnHeight': 2000.0, 'rowCount': 4,
    'isVertical': false, 'flip': false, 'labelSide': 'top',
    'labelDy': 1000.0, 'labelDx': -1000.0,
  },
  {
    'id': '3', 'label': 'Cluster 3', 'startX': 1050.0,
    'startY': 2067.0 + 8.0 + 4.0, 'columnCount': 26, 'columnWidth': 20.0,
    'columnGap': 20.0, 'columnDepth': 20.0, 'columnHeight': 2000.0, 'rowCount': 4,
    'isVertical': false, 'flip': true, 'labelSide': 'bottom',
    'labelDy': 1000.0, 'labelDx': 1000.0,
  },
  {
    'id': '4', 'label': 'Cluster 4', 'startX': 1600.0,
    'startY': 2067.0 + 8.0 + 4.0, 'columnCount': 26, 'columnWidth': 20.0,
    'columnGap': 20.0, 'columnDepth': 20.0, 'columnHeight': 2000.0, 'rowCount': 4,
    'isVertical': false, 'flip': true, 'labelSide': 'bottom',
    'labelDy': 1000.0, 'labelDx': 1000.0,
  },
  {
    'id': '5', 'label': 'Cluster 5', 'startX': 1050.0, 'startY': 1930.0,
    'columnCount': 26, 'columnWidth': 20.0, 'columnGap': 20.0,
    'columnDepth': 20.0, 'columnHeight': 2000.0, 'rowCount': 4,
    'isVertical': false, 'flip': false, 'labelSide': 'top',
    'labelDy': 1000.0, 'labelDx': -1000.0,
  },
  {
    'id': '6', 'label': 'Cluster 6', 'startX': 1600.0, 'startY': 1930.0,
    'columnCount': 26, 'columnWidth': 20.0, 'columnGap': 20.0,
    'columnDepth': 20.0, 'columnHeight': 2000.0, 'rowCount': 4,
    'isVertical': false, 'flip': false, 'labelSide': 'top',
    'labelDy': 1000.0, 'labelDx': -1000.0,
  },
  {
    'id': '7', 'label': 'Cluster 7', 'startX': 1050.0,
    'startY': 1917.0 + 8.0 + 4.0, 'columnCount': 26, 'columnWidth': 20.0,
    'columnGap': 20.0, 'columnDepth': 20.0, 'columnHeight': 2000.0, 'rowCount': 4,
    'isVertical': false, 'flip': true, 'labelSide': 'bottom',
    'labelDy': 1000.0, 'labelDx': 1000.0,
  },
  {
    'id': '8', 'label': 'Cluster 8', 'startX': 1600.0,
    'startY': 1917.0 + 8.0 + 4.0, 'columnCount': 26, 'columnWidth': 20.0,
    'columnGap': 20.0, 'columnDepth': 20.0, 'columnHeight': 2000.0, 'rowCount': 4,
    'isVertical': false, 'flip': true, 'labelSide': 'bottom',
    'labelDy': 1000.0, 'labelDx': 1000.0,
  },
  {
    'id': '9', 'label': 'Cluster 9', 'startX': 1050.0, 'startY': 1780.0,
    'columnCount': 26, 'columnWidth': 20.0, 'columnGap': 20.0,
    'columnDepth': 20.0, 'columnHeight': 2000.0, 'rowCount': 4,
    'isVertical': false, 'flip': false, 'labelSide': 'top',
    'labelDy': 1000.0, 'labelDx': -1000.0,
  },
  {
    'id': '10', 'label': 'Cluster 10', 'startX': 1600.0, 'startY': 1780.0,
    'columnCount': 26, 'columnWidth': 20.0, 'columnGap': 20.0,
    'columnDepth': 20.0, 'columnHeight': 2000.0, 'rowCount': 4,
    'isVertical': false, 'flip': false, 'labelSide': 'top',
    'labelDy': 1000.0, 'labelDx': -1000.0,
  },
  {
    'id': '11', 'label': 'Cluster 11', 'startX': 1050.0,
    'startY': 1767.0 + 8.0 + 4.0, 'columnCount': 23, 'columnWidth': 20.0,
    'columnGap': 20.0, 'columnDepth': 20.0, 'columnHeight': 2000.0, 'rowCount': 4,
    'isVertical': false, 'flip': true, 'labelSide': 'bottom',
    'labelDy': 1000.0, 'labelDx': 2000.0,
  },
  {
    'id': '12', 'label': 'Cluster 12', 'startX': 1660.0,
    'startY': 1767.0 + 8.0 + 4.0, 'columnCount': 23, 'columnWidth': 20.0,
    'columnGap': 20.0, 'columnDepth': 20.0, 'columnHeight': 2000.0, 'rowCount': 4,
    'isVertical': false, 'flip': true, 'labelSide': 'bottom',
    'labelDy': 1000.0, 'labelDx': 1000.0,
  },
  {
    'id': '13', 'label': 'Cluster 13', 'startX': 1050.0, 'startY': 1480.0,
    'columnCount': 23, 'columnWidth': 20.0, 'columnGap': 20.0,
    'columnDepth': 20.0, 'columnHeight': 2000.0, 'rowCount': 4,
    'isVertical': false, 'flip': false, 'labelSide': 'top',
    'labelDy': 1000.0, 'labelDx': -2000.0,
  },
  {
    'id': '14', 'label': 'Cluster 14', 'startX': 1660.0, 'startY': 1480.0,
    'columnCount': 23, 'columnWidth': 20.0, 'columnGap': 20.0,
    'columnDepth': 20.0, 'columnHeight': 2000.0, 'rowCount': 4,
    'isVertical': false, 'flip': false, 'labelSide': 'top',
    'labelDy': 1000.0, 'labelDx': -1000.0,
  },
  {
    'id': '15', 'label': 'Cluster 15', 'startX': 1050.0,
    'startY': 1467.0 + 8.0 + 4.0, 'columnCount': 26, 'columnWidth': 20.0,
    'columnGap': 20.0, 'columnDepth': 20.0, 'columnHeight': 2000.0, 'rowCount': 4,
    'isVertical': false, 'flip': true, 'labelSide': 'bottom',
    'labelDy': 1000.0, 'labelDx': 1000.0,
  },
  {
    'id': '16', 'label': 'Cluster 16', 'startX': 1600.0,
    'startY': 1467.0 + 8.0 + 4.0, 'columnCount': 26, 'columnWidth': 20.0,
    'columnGap': 20.0, 'columnDepth': 20.0, 'columnHeight': 2000.0, 'rowCount': 4,
    'isVertical': false, 'flip': true, 'labelSide': 'bottom',
    'labelDy': 1000.0, 'labelDx': 1000.0,
  },
  {
    'id': '17', 'label': 'Cluster 17', 'startX': 1050.0, 'startY': 1330.0,
    'columnCount': 26, 'columnWidth': 20.0, 'columnGap': 20.0,
    'columnDepth': 20.0, 'columnHeight': 2000.0, 'rowCount': 4,
    'isVertical': false, 'flip': false, 'labelSide': 'top',
    'labelDy': 100.0, 'labelDx': -1000.0,
  },
  {
    'id': '18', 'label': 'Cluster 18', 'startX': 1600.0, 'startY': 1330.0,
    'columnCount': 26, 'columnWidth': 20.0, 'columnGap': 20.0,
    'columnDepth': 20.0, 'columnHeight': 2000.0, 'rowCount': 4,
    'isVertical': false, 'flip': false, 'labelSide': 'top',
    'labelDy': 1000.0, 'labelDx': -1000.0,
  },
  {
    'id': '19', 'label': 'Cluster 19', 'startX': 1050.0,
    'startY': 1317.0 + 8.0 + 4.0, 'columnCount': 26, 'columnWidth': 20.0,
    'columnGap': 20.0, 'columnDepth': 20.0, 'columnHeight': 2000.0, 'rowCount': 4,
    'isVertical': false, 'flip': true, 'labelSide': 'bottom',
    'labelDy': 1000.0, 'labelDx': 1000.0,
  },
  {
    'id': '20', 'label': 'Cluster 20', 'startX': 1600.0,
    'startY': 1317.0 + 8.0 + 4.0, 'columnCount': 26, 'columnWidth': 20.0,
    'columnGap': 20.0, 'columnDepth': 20.0, 'columnHeight': 2000.0, 'rowCount': 4,
    'isVertical': false, 'flip': true, 'labelSide': 'bottom',
    'labelDy': 1000.0, 'labelDx': 1000.0,
  },
  {
    'id': '21', 'label': 'Cluster 21', 'startX': 1050.0, 'startY': 1180.0,
    'columnCount': 26, 'columnWidth': 20.0, 'columnGap': 20.0,
    'columnDepth': 20.0, 'columnHeight': 2000.0, 'rowCount': 4,
    'isVertical': false, 'flip': false, 'labelSide': 'top',
    'labelDy': 1000.0, 'labelDx': -1000.0,
  },
  {
    'id': '22', 'label': 'Cluster 22', 'startX': 1600.0, 'startY': 1180.0,
    'columnCount': 26, 'columnWidth': 20.0, 'columnGap': 20.0,
    'columnDepth': 20.0, 'columnHeight': 2000.0, 'rowCount': 4,
    'isVertical': false, 'flip': false, 'labelSide': 'top',
    'labelDy': 1000.0, 'labelDx': -1000.0,
  },
  {
    'id': '23', 'label': 'Cluster 23', 'startX': 1050.0,
    'startY': 1167.0 + 8.0 + 4.0, 'columnCount': 26, 'columnWidth': 20.0,
    'columnGap': 20.0, 'columnDepth': 20.0, 'columnHeight': 2000.0, 'rowCount': 4,
    'isVertical': false, 'flip': true, 'labelSide': 'bottom',
    'labelDy': 1000.0, 'labelDx': 1000.0,
  },
  {
    'id': '24', 'label': 'Cluster 24', 'startX': 1600.0,
    'startY': 1167.0 + 8.0 + 4.0, 'columnCount': 26, 'columnWidth': 20.0,
    'columnGap': 20.0, 'columnDepth': 20.0, 'columnHeight': 2000.0, 'rowCount': 4,
    'isVertical': false, 'flip': true, 'labelSide': 'bottom',
    'labelDy': 1000.0, 'labelDx': 1000.0,
  },
  // ── DECORATIVE ────────────────────────────────────────────────────────────
  {
    'id': 'D3', 'label': 'bone deposit', 'decorative': true,
    'color': Color(0xFFBCAAA4), 'startX': 1703.0,
    'startY': 1630.0 + 8.0 + 4.0, 'columnCount': 21, 'columnWidth': 20.0,
    'columnGap': 20.0, 'columnDepth': 20.0, 'columnHeight': 2000.0,
    'rowCount': 3, 'isVertical': false, 'flip': true,
    'labelSide': 'bottom', 'labelDy': 1000.0, 'labelDx': -2000.0,
  },
  {
    'id': 'D4', 'label': 'bone deposit', 'decorative': true,
    'color': Color(0xFFBCAAA4), 'startX': 1703.0,
    'startY': 1617.0 + 8.0 + 4.0, 'columnCount': 21, 'columnWidth': 20.0,
    'columnGap': 20.0, 'columnDepth': 20.0, 'columnHeight': 2000.0,
    'rowCount': 4, 'isVertical': false, 'flip': true,
    'labelSide': 'bottom', 'labelDy': 1000.0, 'labelDx': 1000.0,
  },

  {
    'id': 'D1', 'label': 'bone deposit', 'decorative': true,
    'color': Color(0xFFBCAAA4), 'startX': 1050.0,
    'startY': 1630.0 + 8.0 + 4.0, 'columnCount': 21, 'columnWidth': 20.0,
    'columnGap': 20.0, 'columnDepth': 20.0, 'columnHeight': 2000.0,
    'rowCount': 3, 'isVertical': false, 'flip': true,
    'labelSide': 'bottom', 'labelDy': 1000.0, 'labelDx': -2000.0,
  },
  {
    'id': 'D2', 'label': 'bone deposit', 'decorative': true,
    'color': Color(0xFFBCAAA4), 'startX': 1050.0,
    'startY': 1617.0 + 8.0 + 4.0, 'columnCount': 21, 'columnWidth': 20.0,
    'columnGap': 20.0, 'columnDepth': 20.0, 'columnHeight': 2000.0,
    'rowCount': 4, 'isVertical': false, 'flip': true,
    'labelSide': 'bottom', 'labelDy': 1000.0, 'labelDx': 1000.0,
  },
];


const List<Map<String, dynamic>> _crossConfigs = [
  {
    'id': 'X1', 'startX': 1550.0, 'startY': 1590.0,
    'width': 150.0, 'depth': 150.0, 'discThickness': 300.0,
    'crossHeight': 3500.0, 'crossWidth': 3500.0, 'crossThickness': 900.0,
    'crossBarAt': 0.25, 'dx': 0.0, 'dy': 0.0,
    'discColor': Color(0xFFBDBDBD), 'crossColor': Color(0xFFF5F5F5),
    'onTop': true,
  },
];

// ============================================================================
// PUBLIC REF
// ============================================================================
class ClusterColumnRef {
  final String clusterId;
  final int columnIndex;
  final int rowCount;

  const ClusterColumnRef({
    required this.clusterId,
    required this.columnIndex,
    this.rowCount = 4,
  });

  String dataKey(int row) => 'CL$clusterId-C$columnIndex-R$row';
  String tag(int row) => dataKey(row);
  String get columnTag => 'CL$clusterId-C$columnIndex';

  @override
  String toString() => 'ClusterColumnRef($clusterId#$columnIndex)';
}

class ClusterColumn {
  final String clusterId;
  final int columnIndex;
  final IsoBlock block;

  ClusterColumn({
    required this.clusterId,
    required this.columnIndex,
    required this.block,
  });
}

// ============================================================================
// PUBLIC API — hit targets
// ============================================================================
class ClusterHitTarget {
  final ClusterColumnRef ref;
  final double gx, gy, gw, gh, height;
  final bool flip;
  final Offset p1, p2, p3, p4;

  ClusterHitTarget({
    required this.ref,
    required this.gx,
    required this.gy,
    required this.gw,
    required this.gh,
    required this.height,
    this.flip = false,
  })  : p1 = Floor.project(gx, gy),
        p2 = Floor.project(gx + gw, gy),
        p3 = Floor.project(gx + gw, gy + gh),
        p4 = Floor.project(gx, gy + gh);

  List<Offset> get silhouette {
    final down = Offset(0, height);
    return _convexHull([
      p1, p2, p3, p4,
      p1 + down, p2 + down, p3 + down, p4 + down,
    ]);
  }

  double get depthKey => (p1.dy + p2.dy + p3.dy + p4.dy) / 4;
}

List<Offset> _convexHull(List<Offset> pts) {
  final p = List<Offset>.from(pts)
    ..sort((a, b) => a.dx != b.dx ? a.dx.compareTo(b.dx) : a.dy.compareTo(b.dy));

  double cross(Offset o, Offset a, Offset b) =>
      (a.dx - o.dx) * (b.dy - o.dy) - (a.dy - o.dy) * (b.dx - o.dx);

  final lower = <Offset>[];
  for (final pt in p) {
    while (lower.length >= 2 &&
        cross(lower[lower.length - 2], lower.last, pt) <= 0) {
      lower.removeLast();
    }
    lower.add(pt);
  }
  final upper = <Offset>[];
  for (final pt in p.reversed) {
    while (upper.length >= 2 &&
        cross(upper[upper.length - 2], upper.last, pt) <= 0) {
      upper.removeLast();
    }
    upper.add(pt);
  }
  lower.removeLast();
  upper.removeLast();
  return [...lower, ...upper];
}


List<ClusterHitTarget>? _cachedTargets;
double _cachedTargetsYaw = double.nan;
int _cachedTargetsCols = -1;
int _cachedTargetsRows = -1;

List<ClusterHitTarget> getClusterHitTargets() {
  if (!kShowClusters) return <ClusterHitTarget>[];

  if (_cachedTargets != null &&
      _cachedTargetsYaw == Floor.yaw &&
      _cachedTargetsCols == Floor.gridCols &&
      _cachedTargetsRows == Floor.gridRows) {
    return _cachedTargets!;
  }

  final targets = <ClusterHitTarget>[];

  for (final config in _clusterConfigs) {
    if (config['decorative'] == true) continue;

    final id = config['id'] as String;
    final startX = config['startX'] as double;
    final startY = config['startY'] as double;
    final columnCount = config['columnCount'] as int;
    final columnWidth = config['columnWidth'] as double;
    final columnGap = config['columnGap'] as double;
    final columnDepth = config['columnDepth'] as double;
    final columnHeight = config['columnHeight'] as double;
    final rowCount = config['rowCount'] as int? ?? 4;
    final isVertical = config['isVertical'] as bool? ?? false;
    final flip = config['flip'] as bool? ?? false;

    for (int c = 0; c < columnCount; c++) {
      final double gx, gy;
      if (isVertical) {
        gx = startX;
        gy = startY + c * columnGap;
      } else {
        gx = startX + c * columnGap;
        gy = startY;
      }
      final double effGy = flip ? gy - columnDepth : gy;

      targets.add(ClusterHitTarget(
        ref: ClusterColumnRef(
          clusterId: id, columnIndex: c + 1, rowCount: rowCount,
        ),
        gx: gx, gy: effGy, gw: columnWidth, gh: columnDepth,
        height: columnHeight, flip: flip,
      ));
    }
  }

  _cachedTargets = targets;
  _cachedTargetsYaw = Floor.yaw;
  _cachedTargetsCols = Floor.gridCols;
  _cachedTargetsRows = Floor.gridRows;
  return targets;
}

// ============================================================================
// BUILD CLUSTERS
// ============================================================================
List<ClusterColumn> buildClusters() {
  if (!kShowClusters) return <ClusterColumn>[];

  final columns = <ClusterColumn>[];

  for (final config in _clusterConfigs) {
    if (config['decorative'] == true) continue;

    final id = config['id'] as String;
    final startX = config['startX'] as double;
    final startY = config['startY'] as double;
    final columnCount = config['columnCount'] as int;
    final columnWidth = config['columnWidth'] as double;
    final columnGap = config['columnGap'] as double;
    final columnDepth = config['columnDepth'] as double;
    final columnHeight = config['columnHeight'] as double;
    final isVertical = config['isVertical'] as bool? ?? false;
    final flip = config['flip'] as bool? ?? false;

    for (int c = 0; c < columnCount; c++) {
      final double gx, gy;
      if (isVertical) {
        gx = startX;
        gy = startY + c * columnGap;
      } else {
        gx = startX + c * columnGap;
        gy = startY;
      }
      final double effGy = flip ? gy - columnDepth : gy;

      columns.add(ClusterColumn(
        clusterId: id,
        columnIndex: c + 1,
        block: IsoBlock(
          gx: gx, gy: effGy, gw: columnWidth, gh: columnDepth,
          height: columnHeight,
        ),
      ));
    }
  }
  return columns;
}

// ============================================================================
// CLUSTER LABELS
// ============================================================================
List<(double, double, String, String)> getClusterLabels() {
  if (!kShowClusters) return <(double, double, String, String)>[];

  return _clusterConfigs.where((c) => c['decorative'] != true).map((config) {
    final label = config['label'] as String;
    final startX = config['startX'] as double;
    final startY = config['startY'] as double;
    final columnCount = config['columnCount'] as int;
    final columnGap = config['columnGap'] as double;
    final columnDepth = config['columnDepth'] as double;
    final isVertical = config['isVertical'] as bool? ?? false;
    final flip = config['flip'] as bool? ?? false;
    final labelSide = config['labelSide'] as String? ?? 'top';

    double centerX, centerY;
    if (isVertical) {
      centerX = startX;
      centerY = startY + (columnCount - 1) * columnGap / 2;
    } else {
      centerX = startX + (columnCount - 1) * columnGap / 2;
      centerY = startY;
    }
    if (flip) centerY -= columnDepth;

    return (centerX, centerY, label, labelSide);
  }).toList();
}

// ============================================================================
// CLUSTER WIDGET
// ============================================================================
class Cluster extends StatelessWidget {
  const Cluster({
    super.key,
    this.selectedClusterId,
    this.selectedColumnIndex,
  });

  final String? selectedClusterId;
  final int? selectedColumnIndex;

  @override
  Widget build(BuildContext context) {
    if (!kShowClusters) return const SizedBox.shrink();

    return ListenableBuilder(
      listenable: Floor.repaint,
      builder: (_, __) {
        final w = Floor.canvasWidth;
        final h = Floor.canvasHeight;
        return SizedBox(
          width: w,
          height: h,
          child: RepaintBoundary(
            child: Stack(
              children: [
                CustomPaint(
                  size: Size(w, h),
                  painter: _ClusterPainter(),
                ),
                if (selectedClusterId != null)
                  RepaintBoundary(
                    child: CustomPaint(
                      size: Size(w, h),
                      painter: _SelectionPainter(
                        clusterId: selectedClusterId!,
                        columnIndex: selectedColumnIndex,
                      ),
                    ),
                  ),
                const IgnorePointer(
                  child: RouteLayer(markers: true),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ============================================================================
// SELECTION PAINTER — draws ONLY the highlighted column's outline
// ============================================================================
class _SelectionPainter extends CustomPainter {
  _SelectionPainter({required this.clusterId, required this.columnIndex})
      : super(repaint: Floor.repaint);

  final String clusterId;
  final int? columnIndex;

  @override
  void paint(Canvas canvas, Size size) {
    if (columnIndex == null) return;

    for (final config in _clusterConfigs) {
      if (config['decorative'] == true) continue;
      if (config['id'] != clusterId) continue;

      final startX = config['startX'] as double;
      final startY = config['startY'] as double;
      final columnCount = config['columnCount'] as int;
      final columnWidth = config['columnWidth'] as double;
      final columnGap = config['columnGap'] as double;
      final columnDepth = config['columnDepth'] as double;
      final columnHeight = config['columnHeight'] as double;
      final isVertical = config['isVertical'] as bool? ?? false;
      final flip = config['flip'] as bool? ?? false;
      final rowCount = config['rowCount'] as int? ?? 4;

      final c = columnIndex! - 1;
      if (c < 0 || c >= columnCount) return;

      final double gx, gy;
      if (isVertical) {
        gx = startX;
        gy = startY + c * columnGap;
      } else {
        gx = startX + c * columnGap;
        gy = startY;
      }
      final double effGy = flip ? gy - columnDepth : gy;

      final col = _Column(
        gx: gx, gy: effGy, gw: columnWidth, gh: columnDepth,
        height: columnHeight, index: c + 1, rowCount: rowCount, flip: flip,
      );

      final topPath = Path()
        ..moveTo(col.p1.dx, col.p1.dy)
        ..lineTo(col.p2.dx, col.p2.dy)
        ..lineTo(col.p3.dx, col.p3.dy)
        ..lineTo(col.p4.dx, col.p4.dy)
        ..close();

      canvas.drawPath(
        topPath,
        Paint()
          ..color = const Color(0xFFFFD54F).withOpacity(0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 12
          ..strokeJoin = StrokeJoin.round,
      );
      canvas.drawPath(
        topPath,
        Paint()
          ..color = const Color(0xFFFFD54F)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5
          ..strokeJoin = StrokeJoin.round,
      );
      return;
    }
  }

  @override
  bool shouldRepaint(covariant _SelectionPainter old) => true;
}

// ============================================================================
// CLUSTER PAINTER — static geometry, cached label painters
// ============================================================================
class _ClusterPainter extends CustomPainter {
  _ClusterPainter() : super(repaint: Floor.repaint);

  static const double kColumnFontSize = 150.0;
  static const double kClusterFontSize = 500.0;
  static const double kClusterLabelGap = -1500.0;

  static final Map<String, (TextPainter, TextPainter)> _labelCache = {};

  @override
  void paint(Canvas canvas, Size size) {
    final items = <_DrawItem>[];
    final labels = <_PendingLabel>[];

    for (final config in _clusterConfigs) {
      _collectCluster(config, items, labels);
    }

    for (final cfg in _crossConfigs) {
      if (cfg['onTop'] == false) _drawCircleCross(canvas, cfg);
    }

    items.sort((a, b) => a.col.depthKey.compareTo(b.col.depthKey));

    for (final it in items) {
      _drawBlock(canvas, it.col, it.color);
      if (!it.decorative) _drawColumnLabel(canvas, it.col);
    }

    for (final cfg in _crossConfigs) {
      if (cfg['onTop'] != false) _drawCircleCross(canvas, cfg);
    }

    for (final pl in labels) {
      _drawClusterLabel(canvas, pl.columns, pl.label, pl.side,
          pl.labelDy, pl.labelDx);
    }
  }

  void _collectCluster(
    Map<String, dynamic> config,
    List<_DrawItem> items,
    List<_PendingLabel> labels,
  ) {
    final id = config['id'] as String;
    final label = config['label'] as String;
    final startX = config['startX'] as double;
    final startY = config['startY'] as double;
    final columnCount = config['columnCount'] as int;
    final columnWidth = config['columnWidth'] as double;
    final columnGap = config['columnGap'] as double;
    final columnDepth = config['columnDepth'] as double;
    final columnHeight = config['columnHeight'] as double;
    final rowCount = config['rowCount'] as int? ?? 4;
    final isVertical = config['isVertical'] as bool? ?? false;
    final flip = config['flip'] as bool? ?? false;
    final labelSide = config['labelSide'] as String? ?? 'top';
    final labelDy = (config['labelDy'] as num?)?.toDouble() ?? 0.0;
    final labelDx = (config['labelDx'] as num?)?.toDouble() ?? 0.0;
    final decorative = config['decorative'] as bool? ?? false;
    final color = config['color'] as Color? ?? Colors.grey.shade200;

    final columns = <_Column>[];
    for (int c = 0; c < columnCount; c++) {
      final double gx, gy;
      if (isVertical) {
        gx = startX;
        gy = startY + c * columnGap;
      } else {
        gx = startX + c * columnGap;
        gy = startY;
      }
      final double effGy = flip ? gy - columnDepth : gy;

      final col = _Column(
        gx: gx, gy: effGy, gw: columnWidth, gh: columnDepth,
        height: columnHeight, index: c + 1, rowCount: rowCount, flip: flip,
      );
      columns.add(col);
      items.add(_DrawItem(
        clusterId: id, col: col, decorative: decorative, color: color,
      ));
    }

    if (label.isNotEmpty) {
      labels.add(_PendingLabel(
        columns: columns, label: label, side: labelSide,
        labelDy: labelDy, labelDx: labelDx,
      ));
    }
  }

  // ── CIRCLE + LATIN CROSS ─────────────────────────────────────────────────
  void _drawCircleCross(Canvas canvas, Map<String, dynamic> cfg) {
    final gx = (cfg['startX'] as num).toDouble();
    final gy = (cfg['startY'] as num).toDouble();
    final gw = (cfg['width'] as num?)?.toDouble() ?? 60.0;
    final gh = (cfg['depth'] as num?)?.toDouble() ?? 60.0;
    final discThickness =
        (cfg['discThickness'] as num?)?.toDouble() ?? (gh * 0.22);
    final crossH = (cfg['crossHeight'] as num?)?.toDouble() ??
        (cfg['height'] as num?)?.toDouble() ??
        320.0;
    final crossW = (cfg['crossWidth'] as num?)?.toDouble() ?? (gw * 2.1);
    final crossT =
        (cfg['crossThickness'] as num?)?.toDouble() ?? (gw * 0.35);
    final crossBarAt =
        ((cfg['crossBarAt'] as num?)?.toDouble() ?? 0.25).clamp(0.0, 1.0);
    final dx = (cfg['dx'] as num?)?.toDouble() ?? 0.0;
    final dy = (cfg['dy'] as num?)?.toDouble() ?? 0.0;
    final discColor = cfg['discColor'] as Color? ?? const Color(0xFFBDBDBD);
    final crossColor = cfg['crossColor'] as Color? ?? const Color(0xFFF5F5F5);

    final shift = Offset(dx, dy);

    // ── DISC ─────────────────────────────────────────────────────────────
    final cx = gx + gw / 2;
    final cy = gy + gh / 2;
    final rx = gw / 2;
    final ry = gh / 2;

    const int segments = 48;
    final ring = <Offset>[];
    for (int i = 0; i < segments; i++) {
      final a = 2 * math.pi * i / segments;
      ring.add(
          Floor.project(cx + rx * math.cos(a), cy + ry * math.sin(a)) + shift);
    }

    Path extrudeRing(List<Offset> r, double depth) {
      final p = Path()..moveTo(r.first.dx, r.first.dy);
      for (int i = 1; i < r.length; i++) {
        p.lineTo(r[i].dx, r[i].dy);
      }
      for (int i = r.length - 1; i >= 0; i--) {
        p.lineTo(r[i].dx, r[i].dy + depth);
      }
      return p..close();
    }

    Path ringTopPath() {
      final p = Path()..moveTo(ring[0].dx, ring[0].dy);
      for (int i = 1; i < ring.length; i++) {
        p.lineTo(ring[i].dx, ring[i].dy);
      }
      return p..close();
    }

    final hsl = HSLColor.fromColor(discColor);
    final sideColor =
        hsl.withLightness((hsl.lightness - 0.25).clamp(0.0, 1.0)).toColor();

    canvas.drawPath(
      extrudeRing(
          ring.map((o) => o + const Offset(6, 6)).toList(), discThickness),
      Paint()..color = Colors.black26,
    );

  
    canvas.drawPath(
      extrudeRing(ring, discThickness),
      Paint()..color = sideColor,
    );
    canvas.drawPath(
      extrudeRing(ring, discThickness),
      Paint()
        ..color = Colors.black.withOpacity(0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );

    canvas.drawPath(ringTopPath(), Paint()..color = discColor);
    canvas.drawPath(
      ringTopPath(),
      Paint()
        ..color = Colors.black.withOpacity(0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );

    // ── CROSS ────────────────────────────────────────────────────────────
    final base = Floor.project(cx, cy) + shift;
    final bx = base.dx;
    final by = base.dy;

    final top = by - crossH;
    final barTop = top + crossH * crossBarAt;
    final barBottom = barTop + crossT;

    final halfBeam = crossT / 2;
    final halfArm = crossW / 2;

    List<Offset> crossPoly(Offset o) => [
          Offset(bx - halfBeam, top) + o,
          Offset(bx + halfBeam, top) + o,
          Offset(bx + halfBeam, barTop) + o,
          Offset(bx + halfArm, barTop) + o,
          Offset(bx + halfArm, barBottom) + o,
          Offset(bx + halfBeam, barBottom) + o,
          Offset(bx + halfBeam, by) + o,
          Offset(bx - halfBeam, by) + o,
          Offset(bx - halfBeam, barBottom) + o,
          Offset(bx - halfArm, barBottom) + o,
          Offset(bx - halfArm, barTop) + o,
          Offset(bx - halfBeam, barTop) + o,
        ];

    Path polyPath(List<Offset> pts) {
      final p = Path()..moveTo(pts[0].dx, pts[0].dy);
      for (int i = 1; i < pts.length; i++) {
        p.lineTo(pts[i].dx, pts[i].dy);
      }
      return p..close();
    }

    final crossHsl = HSLColor.fromColor(crossColor);
    final crossSide = crossHsl
        .withLightness((crossHsl.lightness - 0.30).clamp(0.0, 1.0))
        .toColor();

    // Shadow
    canvas.drawPath(
      polyPath(crossPoly(const Offset(14, 8))),
      Paint()..color = Colors.black26,
    );

    // Extruded silhouette
    final depthShift = (crossT * 0.4).clamp(2.0, 24.0);
    final front = crossPoly(Offset.zero);
    final back = crossPoly(Offset(depthShift, 0));
    final extrude = Path()..moveTo(front.first.dx, front.first.dy);
    for (int i = 1; i < front.length; i++) {
      extrude.lineTo(front[i].dx, front[i].dy);
    }
    extrude.close();
    for (int i = back.length - 1; i >= 0; i--) {
      extrude.lineTo(back[i].dx, back[i].dy);
    }
    extrude.close();

    canvas.drawPath(extrude, Paint()..color = crossSide);

    // Front face
    canvas.drawPath(polyPath(front), Paint()..color = crossColor);
    canvas.drawPath(
      polyPath(front),
      Paint()
        ..color = Colors.black.withOpacity(0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..strokeJoin = StrokeJoin.round,
    );
  }

  // ── BLOCK ─────────────────────────────────────────────────────────────
  void _drawBlock(Canvas canvas, _Column block, Color topColor) {
    final hsl = HSLColor.fromColor(topColor);

    final topFaceColor = topColor;
    final nearHorizColor =
        hsl.withLightness((hsl.lightness - 0.18).clamp(0.0, 1.0)).toColor();
    final nearSideColor =
        hsl.withLightness((hsl.lightness - 0.28).clamp(0.0, 1.0)).toColor();
    final farColor =
        hsl.withLightness((hsl.lightness - 0.38).clamp(0.0, 1.0)).toColor();

    // Shadow
    canvas.drawPath(
      Path()
        ..addPolygon([
          block.p1 + const Offset(3, 4),
          block.p2 + const Offset(3, 4),
          block.p3 + const Offset(3, 4),
          block.p4 + const Offset(3, 4),
        ], true),
      Paint()..color = Colors.black12,
    );

    final double avgTopEdge = (block.p1.dy + block.p2.dy) / 2;
    final double avgBottomEdge = (block.p3.dy + block.p4.dy) / 2;
    final double avgLeftEdge = (block.p1.dy + block.p4.dy) / 2;
    final double avgRightEdge = (block.p2.dy + block.p3.dy) / 2;

    final bool showTopEdge = avgTopEdge > avgBottomEdge;
    final bool showLeftEdge = avgLeftEdge > avgRightEdge;

    final Offset nearHorizA = showTopEdge ? block.p1 : block.p4;
    final Offset nearHorizB = showTopEdge ? block.p2 : block.p3;
    final Offset nearSideA = showLeftEdge ? block.p1 : block.p2;
    final Offset nearSideB = showLeftEdge ? block.p4 : block.p3;

    final Offset farHorizA = showTopEdge ? block.p4 : block.p1;
    final Offset farHorizB = showTopEdge ? block.p3 : block.p2;
    final Offset farSideA = showLeftEdge ? block.p2 : block.p1;
    final Offset farSideB = showLeftEdge ? block.p3 : block.p4;

    _drawVerticalFace(canvas, farHorizA, farHorizB, block.height, farColor);
    _drawVerticalFace(canvas, farSideA, farSideB, block.height, farColor);
    _drawVerticalFace(
        canvas, nearHorizA, nearHorizB, block.height, nearHorizColor);
    _drawVerticalFace(
        canvas, nearSideA, nearSideB, block.height, nearSideColor);

    canvas.drawPath(
      Path()
        ..moveTo(block.p1.dx, block.p1.dy)
        ..lineTo(block.p2.dx, block.p2.dy)
        ..lineTo(block.p3.dx, block.p3.dy)
        ..lineTo(block.p4.dx, block.p4.dy)
        ..close(),
      Paint()..color = topFaceColor,
    );

    final rowH = block.height / block.rowCount;
    final nicheLine = Paint()
      ..color = Colors.black.withOpacity(0.45)
      ..strokeWidth = 1.6;

    for (int r = 1; r < block.rowCount; r++) {
      final yShift = rowH * r;
      canvas.drawLine(
        Offset(nearHorizA.dx, nearHorizA.dy + yShift),
        Offset(nearHorizB.dx, nearHorizB.dy + yShift),
        nicheLine,
      );
      canvas.drawLine(
        Offset(nearSideA.dx, nearSideA.dy + yShift),
        Offset(nearSideB.dx, nearSideB.dy + yShift),
        nicheLine,
      );
    }

    final outline = Paint()
      ..color = Colors.black.withOpacity(0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    canvas.drawPath(
      Path()
        ..moveTo(block.p1.dx, block.p1.dy)
        ..lineTo(block.p2.dx, block.p2.dy)
        ..lineTo(block.p3.dx, block.p3.dy)
        ..lineTo(block.p4.dx, block.p4.dy)
        ..close(),
      outline,
    );

    final visibleCorners = <Offset>{
      nearHorizA, nearHorizB, nearSideA, nearSideB,
    };
    for (final p in visibleCorners) {
      canvas.drawLine(
        Offset(p.dx, p.dy),
        Offset(p.dx, p.dy + block.height),
        outline,
      );
    }

    canvas.drawLine(
      Offset(nearHorizA.dx, nearHorizA.dy + block.height),
      Offset(nearHorizB.dx, nearHorizB.dy + block.height),
      outline,
    );
    canvas.drawLine(
      Offset(nearSideA.dx, nearSideA.dy + block.height),
      Offset(nearSideB.dx, nearSideB.dy + block.height),
      outline,
    );
  }

  void _drawVerticalFace(
    Canvas canvas, Offset a, Offset b, double height, Color color,
  ) {
    canvas.drawPath(
      Path()
        ..moveTo(a.dx, a.dy)
        ..lineTo(b.dx, b.dy)
        ..lineTo(b.dx, b.dy + height)
        ..lineTo(a.dx, a.dy + height)
        ..close(),
      Paint()..color = color,
    );
  }

  void _drawColumnLabel(Canvas canvas, _Column col) {
    final center = Offset(
      (col.p1.dx + col.p2.dx + col.p3.dx + col.p4.dx) / 4,
      (col.p1.dy + col.p2.dy + col.p3.dy + col.p4.dy) / 4,
    );
    _drawStyledLabel(canvas, 'C${col.index}', center, size: kColumnFontSize);
  }

  void _drawClusterLabel(
    Canvas canvas,
    List<_Column> cols,
    String label,
    String side,
    double labelDy,
    double labelDx,
  ) {
    if (cols.isEmpty) return;

    double minX = double.infinity;
    double maxX = -double.infinity;
    double minY = double.infinity;

    for (final c in cols) {
      for (final p in [c.p1, c.p2, c.p3, c.p4]) {
        if (p.dx < minX) minX = p.dx;
        if (p.dx > maxX) maxX = p.dx;
        if (p.dy < minY) minY = p.dy;
      }
    }

    final centerX = (minX + maxX) / 2;

    final strokeTp = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          fontSize: kClusterFontSize,
          fontWeight: FontWeight.bold,
          letterSpacing: 2.0,
          foreground: Paint()
            ..color = Colors.black
            ..style = PaintingStyle.stroke
            ..strokeWidth = 5
            ..strokeJoin = StrokeJoin.round,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final fillTp = TextPainter(
      text: const TextSpan(
        text: '',
      ),
      textDirection: TextDirection.ltr,
    );
    final fill = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: kClusterFontSize,
          fontWeight: FontWeight.bold,
          letterSpacing: 2.0,
          shadows: [
            Shadow(color: Colors.black87, blurRadius: 10, offset: Offset(3, 3)),
            Shadow(color: Colors.black54, blurRadius: 5, offset: Offset(1, 1)),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    fillTp.dispose();

    final double labelX = centerX - fill.width / 2 + labelDx;
    final double labelY = minY - fill.height - kClusterLabelGap + labelDy;

    strokeTp.paint(canvas, Offset(labelX, labelY));
    fill.paint(canvas, Offset(labelX, labelY));
  }

  void _drawStyledLabel(
    Canvas canvas,
    String text,
    Offset pos, {
    double size = 18,
  }) {
    final key = '$text|$size';
    final cached = _labelCache[key];
    if (cached != null) {
      final offset = pos - Offset(cached.$2.width / 2, cached.$2.height / 2);
      cached.$1.paint(canvas, offset);
      cached.$2.paint(canvas, offset);
      return;
    }

    final strokeTp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: size,
          fontWeight: FontWeight.bold,
          foreground: Paint()
            ..color = Colors.black
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4
            ..strokeJoin = StrokeJoin.round,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final fillTp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.white,
          fontSize: size,
          fontWeight: FontWeight.bold,
          shadows: const [
            Shadow(color: Colors.black87, blurRadius: 8, offset: Offset(2, 2)),
            Shadow(color: Colors.black45, blurRadius: 4, offset: Offset(1, 1)),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    _labelCache[key] = (strokeTp, fillTp);

    final offset = pos - Offset(fillTp.width / 2, fillTp.height / 2);
    strokeTp.paint(canvas, offset);
    fillTp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _ClusterPainter oldDelegate) => true;
}

// ============================================================================
// INTERNAL HELPERS
// ============================================================================
class _DrawItem {
  final String clusterId;
  final _Column col;
  final bool decorative;
  final Color color;
  const _DrawItem({
    required this.clusterId,
    required this.col,
    this.decorative = false,
    this.color = const Color(0xFFEEEEEE),
  });
}

class _PendingLabel {
  final List<_Column> columns;
  final String label;
  final String side;
  final double labelDy;
  final double labelDx;

  const _PendingLabel({
    required this.columns,
    required this.label,
    required this.side,
    required this.labelDy,
    required this.labelDx,
  });
}

class _Column {
  final double gx, gy, gw, gh, height;
  final int index;
  final int rowCount;
  final bool flip;
  final Offset p1, p2, p3, p4;

  _Column({
    required this.gx,
    required this.gy,
    required this.gw,
    required this.gh,
    required this.height,
    required this.index,
    required this.rowCount,
    this.flip = false,
  })  : p1 = Floor.project(gx, gy),
        p2 = Floor.project(gx + gw, gy),
        p3 = Floor.project(gx + gw, gy + gh),
        p4 = Floor.project(gx, gy + gh);

  double get depthKey => (p1.dy + p2.dy + p3.dy + p4.dy) / 4;
}