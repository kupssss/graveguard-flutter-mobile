// ============================================================================
// PATHFINDER COMPONENT  (Dijkstra on a walkable grid, straight lines only)
// ============================================================================
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'floor.dart';
import 'group.dart';
import 'gate.dart';
import 'cluster.dart';
import 'data.dart';

class RouteResult {
  final String groupId;
  final String label;
  final List<Offset> points;
  final double length;
  const RouteResult({
    required this.groupId,
    required this.label,
    required this.points,
    required this.length,
  });
}

class SearchPrefix {
  final String display;
  final String query;
  final int count;
  const SearchPrefix(this.display, this.query, this.count);
}

class SearchHit {
  final String kind;

  final String label;

  final Map<String, dynamic>? groupCfg;

  final int? cluster;
  final int? column;
  final int? row;

  const SearchHit.group({
    required this.label,
    required Map<String, dynamic> this.groupCfg,
  })  : kind = 'group',
        cluster = null,
        column = null,
        row = null;

  const SearchHit.memorial({
    required this.label,
    required this.cluster,
    required this.column,
    required this.row,
    this.groupCfg,
  }) : kind = 'memorial';

  bool get isMemorial => kind == 'memorial';
}

class Pathfinder {
  static const double cellSize = 20;
  static const double clearance = 15;
  static const double turnPenalty = cellSize * 4;
  static const String startGateId = 'main_gate';
  static const double seeThroughOpacity = 0.3;
  static const double maxLineWidth = 160;

  static const int wallCells = 3;

  static const int gateGapHalf = 0;

  static const int laneCells = 10;

  static const Set<String> floorGroupIds = {'g14'};

  static bool isFloor(Map<String, dynamic> cfg) =>
      floorGroupIds.contains(cfg['id']);

  static final ValueNotifier<RouteResult?> current =
      ValueNotifier<RouteResult?>(null);

  static final ValueNotifier<double> viewScale = ValueNotifier<double>(1.0);

  static double lineWidth() {
    final s = viewScale.value <= 0 ? 1.0 : viewScale.value;
    return (6.0 / s).clamp(120.0, maxLineWidth).toDouble();
  }

  static void clear() {
    current.value = null;
  }

  static double _num(Map<String, dynamic> m, String k) =>
      (m[k] as num?)?.toDouble() ?? 0.0;

  static String norm(String s) => s
      .toLowerCase()
      .replaceAll(RegExp(r'\s+'), '')
      .replaceAll('o', '0');

  static String labelOf(Map<String, dynamic> cfg) {
    final l = (cfg['label'] as String?)?.trim() ?? '';
    if (l.isNotEmpty) return l;
    final n = (cfg['name'] as String?)?.trim() ?? '';
    if (n.isNotEmpty) return n;
    return (cfg['id'] as String?) ?? '?';
  }

  static Rect? _rectOf(Map<String, dynamic> cfg) {
    if (cfg['visible'] == false) return null;
    final gw = _num(cfg, 'gw');
    final gh = _num(cfg, 'gh');
    if (gw <= 0 || gh <= 0) return null;
    return Rect.fromLTWH(_num(cfg, 'gx'), _num(cfg, 'gy'), gw, gh);
  }

  static (String, int) _split(String s) {
    final m = RegExp(r'^(\D*)(\d*)').firstMatch(s)!;
    return (m.group(1)!, int.tryParse(m.group(2)!) ?? -1);
  }

  static int _natural(String a, String b) {
    final na = norm(a);
    final nb = norm(b);
    final sa = _split(na);
    final sb = _split(nb);
    final c1 = sa.$1.compareTo(sb.$1);
    if (c1 != 0) return c1;
    final c2 = sa.$2.compareTo(sb.$2);
    if (c2 != 0) return c2;
    return na.compareTo(nb);
  }

  static List<Map<String, dynamic>> allGroups() {
    final seen = <String>{};
    final out = <Map<String, dynamic>>[];
    for (final cfg in kGroupConfigs) {
      if (_rectOf(cfg) == null) continue;
      final id = (cfg['id'] as String?) ?? labelOf(cfg);
      if (!seen.add(id)) continue;
      out.add(cfg);
    }
    out.sort((a, b) => _natural(labelOf(a), labelOf(b)));
    return out;
  }

  static List<String> _keys(Map<String, dynamic> c) => [
        norm(labelOf(c)),
        norm((c['name'] as String?) ?? ''),
        norm((c['id'] as String?) ?? ''),
      ];

  static List<Map<String, dynamic>> searchGroups(String query) {
    final all = allGroups();
    final q = norm(query);
    if (q.isEmpty) return all;

    int score(Map<String, dynamic> c) {
      final keys = _keys(c);
      if (keys.any((k) => k == q)) return 0;
      if (keys.any((k) => k.startsWith(q))) return 1;
      if (q.length >= 2 && keys.any((k) => k.contains(q))) return 2;
      return 99;
    }

    final scored = <(int, Map<String, dynamic>)>[
      for (final c in all)
        if (score(c) < 99) (score(c), c),
    ];
    scored.sort((a, b) {
      final c = a.$1.compareTo(b.$1);
      if (c != 0) return c;
      return _natural(labelOf(a.$2), labelOf(b.$2));
    });
    return [for (final s in scored) s.$2];
  }

  static List<SearchPrefix> prefixes() {
    final counts = <String, int>{};
    for (final g in allGroups()) {
      final n = norm(labelOf(g));
      if (n.isEmpty) continue;
      counts[n[0]] = (counts[n[0]] ?? 0) + 1;
    }
    final keys = counts.keys.toList()
      ..sort((a, b) {
        final la = RegExp(r'[a-z]').hasMatch(a);
        final lb = RegExp(r'[a-z]').hasMatch(b);
        if (la != lb) return la ? -1 : 1;
        return a.compareTo(b);
      });
    return [
      for (final k in keys)
        SearchPrefix(
          k == '0' ? 'O' : k.toUpperCase(),
          k == '0' ? 'O' : k,
          counts[k]!,
        ),
    ];
  }

  static (int, int, int?)? parseNicheCode(String input) {
    final s = input.trim().toLowerCase().replaceAll(' ', '');
    final full = RegExp(r'^(?:cl)?(\d+)-c?(\d+)(?:-r?(\d+))?$').firstMatch(s);
    if (full == null) return null;
    final cluster = int.tryParse(full.group(1)!);
    final column = int.tryParse(full.group(2)!);
    if (cluster == null || column == null) return null;
    final row = full.group(3) != null ? int.tryParse(full.group(3)!) : null;
    return (cluster, column, row);
  }

  static ClusterColumn? _findColumnIn(
    List<ClusterColumn> all,
    int cluster,
    int column,
  ) {
    final id = cluster.toString();
    for (final c in all) {
      if (c.clusterId == id && c.columnIndex == column) return c;
    }
    return null;
  }

  static ClusterColumn? _findColumn(int cluster, int column) =>
      _findColumnIn(buildClusters(), cluster, column);

  static void _mark(Uint8List blocked, int cols, int rows, Rect r) {
    int ci(double v, int max) => v.floor().clamp(0, max).toInt();
    final c0 = ci(r.left / cellSize, cols - 1);
    final c1 = ci((r.right - 1e-6) / cellSize, cols - 1);
    final r0 = ci(r.top / cellSize, rows - 1);
    final r1 = ci((r.bottom - 1e-6) / cellSize, rows - 1);
    for (int y = r0; y <= r1; y++) {
      for (int x = c0; x <= c1; x++) {
        blocked[y * cols + x] = 1;
      }
    }
  }

  static (int, int) _gateInward(Offset gate) {
    final dLeft = gate.dx;
    final dRight = Floor.gridCols - gate.dx;
    final dTop = gate.dy;
    final dBottom = Floor.gridRows - gate.dy;
    final m = math.min(math.min(dLeft, dRight), math.min(dTop, dBottom));
    if (m == dLeft) return (1, 0);
    if (m == dRight) return (-1, 0);
    if (m == dTop) return (0, 1);
    return (0, -1);
  }

  static Uint8List _newBlocked(int cols, int rows) {
    final blocked = Uint8List(cols * rows);
    _markEdgeWall(blocked, cols, rows);
    return blocked;
  }

  static void _markEdgeWall(Uint8List blocked, int cols, int rows) {
    final gate = _gatePoint();
    final (ix, iy) = _gateInward(gate);
    final horizontal = ix != 0;

    final gc = (gate.dx / cellSize).floor().clamp(0, cols - 1).toInt();
    final gr = (gate.dy / cellSize).floor().clamp(0, rows - 1).toInt();

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final edgeLeft = c < wallCells;
        final edgeRight = c >= cols - wallCells;
        final edgeTop = r < wallCells;
        final edgeBottom = r >= rows - wallCells;
        if (!(edgeLeft || edgeRight || edgeTop || edgeBottom)) continue;

        final onGateEdge = (ix == 1 && edgeLeft) ||
            (ix == -1 && edgeRight) ||
            (iy == 1 && edgeTop) ||
            (iy == -1 && edgeBottom);
        final cross = horizontal ? (r - gr) : (c - gc);
        if (onGateEdge && cross.abs() <= gateGapHalf) continue;

        blocked[r * cols + c] = 1;
      }
    }

    final side = gateGapHalf + 1;
    for (int k = 0; k <= laneCells; k++) {
      final lc = gc + ix * k;
      final lr = gr + iy * k;
      for (final s in const [-1, 1]) {
        final c = horizontal ? lc : lc + s * side;
        final r = horizontal ? lr + s * side : lr;
        if (c < 0 || r < 0 || c >= cols || r >= rows) continue;
        blocked[r * cols + c] = 1;
      }
    }
  }

  static RouteResult? routeToGroup(Map<String, dynamic> target) {
    final rect = _rectOf(target);
    if (rect == null) return null;

    final cols = (Floor.gridCols / cellSize).ceil();
    final rows = (Floor.gridRows / cellSize).ceil();
    final blocked = _newBlocked(cols, rows);

    final targetId = target['id'];
    final otherRects = <Rect>[];
    for (final cfg in kGroupConfigs) {
      final r = _rectOf(cfg);
      if (r == null) continue;
      if (isFloor(cfg)) continue;
      if (cfg['id'] != targetId) otherRects.add(r);
      _mark(blocked, cols, rows, r.inflate(clearance));
    }

    return _solve(
      targetRect: rect,
      targetId: (target['id'] as String?) ?? '',
      targetLabel: labelOf(target),
      blocked: blocked,
      otherRects: otherRects,
      cols: cols,
      rows: rows,
    );
  }

  static RouteResult? routeToColumn(
    int cluster,
    int column, {
    String? label,
  }) {
    final all = buildClusters();
    final target = _findColumnIn(all, cluster, column);
    if (target == null) return null;

    final swept = _routeToColumnSwept(all, target, label);
    if (swept != null) return swept;

    final block = target.block;
    final rect = Rect.fromLTWH(block.gx, block.gy, block.gw, block.gh);

    final cols = (Floor.gridCols / cellSize).ceil();
    final rows = (Floor.gridRows / cellSize).ceil();
    final blocked = _newBlocked(cols, rows);

    final otherRects = <Rect>[];
    for (final cfg in kGroupConfigs) {
      final r = _rectOf(cfg);
      if (r == null) continue;
      if (isFloor(cfg)) continue;
      otherRects.add(r);
      _mark(blocked, cols, rows, r.inflate(clearance));
    }

    for (final c in all) {
      if (identical(c, target)) continue;
      final b = c.block;
      final r = Rect.fromLTWH(b.gx, b.gy, b.gw, b.gh);
      otherRects.add(r);
      _mark(blocked, cols, rows, r.inflate(clearance));
    }

    final goalDist = clearance + cellSize * 2;

    bool touchesOther(Rect strip) {
      for (final c in all) {
        if (identical(c, target)) continue;
        final b = c.block;
        if (Rect.fromLTWH(b.gx, b.gy, b.gw, b.gh).overlaps(strip)) return true;
      }
      return false;
    }

    final belowStrip = Rect.fromLTRB(
        rect.left + 1, rect.bottom, rect.right - 1, rect.bottom + 4);
    final aboveStrip =
        Rect.fromLTRB(rect.left + 1, rect.top - 4, rect.right - 1, rect.top);
    final footBelow = !touchesOther(belowStrip) || touchesOther(aboveStrip);

    final band = footBelow
        ? Rect.fromLTRB(
            rect.left, rect.bottom, rect.right, rect.bottom + goalDist)
        : Rect.fromLTRB(rect.left, rect.top - goalDist, rect.right, rect.top);

    return _solve(
      targetRect: rect,
      targetId: 'CL${target.clusterId}-C${target.columnIndex}',
      targetLabel: label ??
          'Cluster ${target.clusterId} · Column ${target.columnIndex}',
      blocked: blocked,
      otherRects: otherRects,
      cols: cols,
      rows: rows,
      goalBand: band,
    );
  }

  static Offset? _hangDelta(double heightPx) {
    final o = Floor.project(0, 0);
    final ex = Floor.project(1, 0) - o;
    final ey = Floor.project(0, 1) - o;
    final det = ex.dx * ey.dy - ey.dx * ex.dy;
    if (det.abs() < 1e-9) return null;

    final t = Floor.project(1000, 700) - o;
    final e = ex * 1000.0 + ey * 700.0;
    if ((t - e).distance > 2) return null;

    return Offset(-ey.dx * heightPx / det, ex.dx * heightPx / det);
  }

  static List<Offset> _hull(List<Offset> pts) {
    final p = List<Offset>.from(pts)
      ..sort((a, b) =>
          a.dx != b.dx ? a.dx.compareTo(b.dx) : a.dy.compareTo(b.dy));
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

  static bool _inPoly(Offset p, List<Offset> poly) {
    bool inside = false;
    for (int i = 0, j = poly.length - 1; i < poly.length; j = i++) {
      final a = poly[i];
      final b = poly[j];
      if ((a.dy > p.dy) != (b.dy > p.dy) &&
          p.dx < (b.dx - a.dx) * (p.dy - a.dy) / (b.dy - a.dy) + a.dx) {
        inside = !inside;
      }
    }
    return inside;
  }

  static void _markHull(
    Uint8List blocked,
    int cols,
    int rows,
    List<Offset> hull,
  ) {
    if (hull.length < 3) return;
    double minX = double.infinity, maxX = -double.infinity;
    double minY = double.infinity, maxY = -double.infinity;
    for (final p in hull) {
      minX = math.min(minX, p.dx);
      maxX = math.max(maxX, p.dx);
      minY = math.min(minY, p.dy);
      maxY = math.max(maxY, p.dy);
    }
    final c0 = (minX / cellSize).floor().clamp(0, cols - 1).toInt();
    final c1 = (maxX / cellSize).floor().clamp(0, cols - 1).toInt();
    final r0 = (minY / cellSize).floor().clamp(0, rows - 1).toInt();
    final r1 = (maxY / cellSize).floor().clamp(0, rows - 1).toInt();
    for (int y = r0; y <= r1; y++) {
      for (int x = c0; x <= c1; x++) {
        final c = Offset((x + 0.5) * cellSize, (y + 0.5) * cellSize);
        if (_inPoly(c, hull)) blocked[y * cols + x] = 1;
      }
    }
  }

  static (int, Int32List) _nearestSearch(
    Uint8List blocked,
    int cols,
    int rows,
    int startCell,
    Offset target,
    double maxDist,
  ) {
    const dxs = [1, -1, 0, 0];
    const dys = [0, 0, 1, -1];
    final total = cols * rows * 4;
    final dist = Float64List(total)..fillRange(0, total, double.infinity);
    final pred = Int32List(total)..fillRange(0, total, -1);
    final heap = _MinHeap();

    for (int d = 0; d < 4; d++) {
      dist[startCell * 4 + d] = 0;
      heap.push(0, startCell * 4 + d);
    }
    while (heap.isNotEmpty) {
      final st = heap.pop();
      final key = heap.topKey;
      if (key > dist[st]) continue;
      final cell = st >> 2;
      final dir = st & 3;
      final c = cell % cols;
      final r = cell ~/ cols;
      for (int nd = 0; nd < 4; nd++) {
        final nc = c + dxs[nd];
        final nr = r + dys[nd];
        if (nc < 0 || nr < 0 || nc >= cols || nr >= rows) continue;
        final ni = nr * cols + nc;
        if (blocked[ni] != 0) continue;
        final ns = ni * 4 + nd;
        final cost = key + cellSize + (nd == dir ? 0 : turnPenalty);
        if (cost < dist[ns]) {
          dist[ns] = cost;
          pred[ns] = st;
          heap.push(cost, ns);
        }
      }
    }

    int best = -1;
    double bestD = double.infinity;
    double bestCost = double.infinity;
    for (int cell = 0; cell < cols * rows; cell++) {
      double cc = double.infinity;
      int bs = -1;
      for (int d = 0; d < 4; d++) {
        if (dist[cell * 4 + d] < cc) {
          cc = dist[cell * 4 + d];
          bs = cell * 4 + d;
        }
      }
      if (bs < 0) continue;
      final p = Offset(((cell % cols) + 0.5) * cellSize,
          ((cell ~/ cols) + 0.5) * cellSize);
      final e = (p - target).distance;
      if (e > maxDist) continue;
      if (e < bestD - 1e-6 || ((e - bestD).abs() <= 1e-6 && cc < bestCost)) {
        best = bs;
        bestD = e;
        bestCost = cc;
      }
    }
    return (best, pred);
  }

  static RouteResult? _routeToColumnSwept(
    List<ClusterColumn> all,
    ClusterColumn target,
    String? label,
  ) {
    final d = _hangDelta(target.block.height);
    if (d == null) return null;
    final len = d.distance;
    if (len < 1 || len > 1500) return null;

    final cols = (Floor.gridCols / cellSize).ceil();
    final rows = (Floor.gridRows / cellSize).ceil();
    final blocked = _newBlocked(cols, rows);

    for (final cfg in kGroupConfigs) {
      final r = _rectOf(cfg);
      if (r == null) continue;
      if (isFloor(cfg)) continue;
      _mark(blocked, cols, rows, r.inflate(clearance));
    }

    final byCluster = <String, Rect>{};
    for (final c in all) {
      final b = c.block;
      final r = Rect.fromLTWH(b.gx, b.gy, b.gw, b.gh);
      final prev = byCluster[c.clusterId];
      byCluster[c.clusterId] = prev == null ? r : prev.expandToInclude(r);
    }
    for (final r0 in byCluster.values) {
      final r = r0.inflate(clearance);
      final corners = [r.topLeft, r.topRight, r.bottomRight, r.bottomLeft];
      final hull = _hull([...corners, for (final p in corners) p + d]);
      _markHull(blocked, cols, rows, hull);
      _mark(blocked, cols, rows, r);
    }

    int ci(double v, int max) => v.floor().clamp(0, max).toInt();
    final gate = _gatePoint();
    int startCell = ci(gate.dy / cellSize, rows - 1) * cols +
        ci(gate.dx / cellSize, cols - 1);
    if (blocked[startCell] != 0) {
      startCell = _nearestFree(blocked, cols, rows, startCell);
      if (startCell < 0) return null;
    }

    final b = target.block;
    final rect = Rect.fromLTWH(b.gx, b.gy, b.gw, b.gh);
    final foot = rect.center + d + (d / len) * (cellSize * 2);

    final res = _nearestSearch(
        blocked, cols, rows, startCell, foot, len + cellSize * 12);
    if (res.$1 < 0) return null;

    return _assembleRoute(
      goalState: res.$1,
      prevs: res.$2,
      cols: cols,
      gate: gate,
      targetId: 'CL${target.clusterId}-C${target.columnIndex}',
      targetLabel:
          label ?? 'Cluster ${target.clusterId} · Column ${target.columnIndex}',
    );
  }

  static List<Offset> _corners(int goalState, Int32List prevs, int cols) {
    final cells = <int>[];
    for (int at = goalState; at != -1; at = prevs[at]) {
      cells.add(at >> 2);
    }
    final centers = <Offset>[];
    for (final idx in cells.reversed) {
      final p = Offset(
        ((idx % cols) + 0.5) * cellSize,
        ((idx ~/ cols) + 0.5) * cellSize,
      );
      if (centers.isEmpty || (p - centers.last).distance > 1e-6) {
        centers.add(p);
      }
    }
    if (centers.isEmpty) return const [];

    final corners = <Offset>[centers.first];
    for (int k = 1; k < centers.length - 1; k++) {
      final a = centers[k - 1];
      final b = centers[k];
      final c = centers[k + 1];
      final sameX = a.dx == b.dx && b.dx == c.dx;
      final sameY = a.dy == b.dy && b.dy == c.dy;
      if (!sameX && !sameY) corners.add(b);
    }
    if (centers.length > 1) corners.add(centers.last);
    return corners;
  }

  static List<Offset> _withGateStart(List<Offset> corners, Offset gate) {
    final pts = <Offset>[gate];
    if (corners.isEmpty) return pts;

    final (ix, _) = _gateInward(gate);
    final horizontal = ix != 0;

    double cross(Offset p) => horizontal ? p.dy : p.dx;
    Offset snap(Offset p) =>
        horizontal ? Offset(p.dx, gate.dy) : Offset(gate.dx, p.dy);

    final first = corners.first;
    final startNearGate = (cross(first) - cross(gate)).abs() <= cellSize;
    final secondOnLane =
        corners.length < 2 || cross(corners[1]) == cross(first);

    if (startNearGate && secondOnLane) {
      pts.add(snap(first));
      if (corners.length > 1) pts.add(snap(corners[1]));
      pts.addAll(corners.skip(2));
    } else {
      if (gate.dx != first.dx && gate.dy != first.dy) {
        pts.add(horizontal
            ? Offset(first.dx, gate.dy)
            : Offset(gate.dx, first.dy));
      }
      pts.addAll(corners);
    }
    return pts;
  }

  static double _polyLength(List<Offset> pts) {
    double length = 0;
    for (int k = 1; k < pts.length; k++) {
      length += (pts[k] - pts[k - 1]).distance;
    }
    return length;
  }

  static RouteResult? _assembleRoute({
    required int goalState,
    required Int32List prevs,
    required int cols,
    required Offset gate,
    required String targetId,
    required String targetLabel,
  }) {
    final corners = _corners(goalState, prevs, cols);
    if (corners.isEmpty) return null;

    final pts = _withGateStart(corners, gate);

    final result = RouteResult(
      groupId: targetId,
      label: targetLabel,
      points: pts,
      length: _polyLength(pts),
    );
    current.value = result;
    return result;
  }

  static RouteResult? _solve({
    required Rect targetRect,
    required String targetId,
    required String targetLabel,
    required Uint8List blocked,
    required List<Rect> otherRects,
    required int cols,
    required int rows,
    Rect? goalBand,
  }) {
    int ci(double v, int max) => v.floor().clamp(0, max).toInt();

    final gate = _gatePoint();
    int startCell = ci(gate.dy / cellSize, rows - 1) * cols +
        ci(gate.dx / cellSize, cols - 1);
    if (blocked[startCell] != 0) {
      startCell = _nearestFree(blocked, cols, rows, startCell);
      if (startCell < 0) return null;
    }

    final goalDist = clearance + cellSize * 2;

    Offset clampToRect(Offset p, Rect r) => Offset(
          p.dx.clamp(r.left, r.right).toDouble(),
          p.dy.clamp(r.top, r.bottom).toDouble(),
        );

    bool segmentClear(Offset a, Offset b) {
      for (int k = 0; k <= 8; k++) {
        final p = Offset.lerp(a, b, k / 8)!;
        for (final r in otherRects) {
          if (r.contains(p)) return false;
        }
      }
      return true;
    }

    bool isGoal(int idx, bool strict, Rect? band) {
      final cx = ((idx % cols) + 0.5) * cellSize;
      final cy = ((idx ~/ cols) + 0.5) * cellSize;

      if (band != null) {
        if (cx < band.left || cx > band.right) return false;
        if (cy < band.top || cy > band.bottom) return false;
      }

      final inX = cx >= targetRect.left && cx <= targetRect.right;
      final inY = cy >= targetRect.top && cy <= targetRect.bottom;
      if (strict && !inX && !inY) return false;
      final dx = math.max(
          math.max(targetRect.left - cx, 0.0), cx - targetRect.right);
      final dy = math.max(
          math.max(targetRect.top - cy, 0.0), cy - targetRect.bottom);
      if (math.sqrt(dx * dx + dy * dy) > goalDist) return false;
      final c = Offset(cx, cy);
      return segmentClear(c, clampToRect(c, targetRect));
    }

    const dxs = [1, -1, 0, 0];
    const dys = [0, 0, 1, -1];
    final total = cols * rows * 4;

    (int, Int32List) search(bool strict, Rect? band) {
      final dist = Float64List(total)..fillRange(0, total, double.infinity);
      final pred = Int32List(total)..fillRange(0, total, -1);
      final heap = _MinHeap();

      for (int d = 0; d < 4; d++) {
        dist[startCell * 4 + d] = 0;
        heap.push(0, startCell * 4 + d);
      }

      while (heap.isNotEmpty) {
        final st = heap.pop();
        final key = heap.topKey;
        if (key > dist[st]) continue;

        final cell = st >> 2;
        final dir = st & 3;
        if (isGoal(cell, strict, band)) return (st, pred);

        final c = cell % cols;
        final r = cell ~/ cols;
        for (int nd = 0; nd < 4; nd++) {
          final nc = c + dxs[nd];
          final nr = r + dys[nd];
          if (nc < 0 || nr < 0 || nc >= cols || nr >= rows) continue;
          final ni = nr * cols + nc;
          if (blocked[ni] != 0) continue;
          final ns = ni * 4 + nd;
          final cost = key + cellSize + (nd == dir ? 0 : turnPenalty);
          if (cost < dist[ns]) {
            dist[ns] = cost;
            pred[ns] = st;
            heap.push(cost, ns);
          }
        }
      }
      return (-1, pred);
    }

    var res = search(true, goalBand);
    if (res.$1 < 0 && goalBand != null) res = search(true, null);
    if (res.$1 < 0) res = search(false, null);
    if (res.$1 < 0) return null;

    final corners = _corners(res.$1, res.$2, cols);
    if (corners.isEmpty) return null;

    final pts = _withGateStart(corners, gate);

    final last = pts.last;
    final inX = last.dx >= targetRect.left && last.dx <= targetRect.right;
    final inY = last.dy >= targetRect.top && last.dy <= targetRect.bottom;
    final Offset end;
    if (inX) {
      end = Offset(last.dx,
          last.dy < targetRect.top ? targetRect.top : targetRect.bottom);
    } else if (inY) {
      end = Offset(
          last.dx < targetRect.left ? targetRect.left : targetRect.right,
          last.dy);
    } else {
      end = clampToRect(last, targetRect);
    }
    if ((end - pts.last).distance > 1e-6) pts.add(end);

    final result = RouteResult(
      groupId: targetId,
      label: targetLabel,
      points: pts,
      length: _polyLength(pts),
    );
    current.value = result;
    return result;
  }

  static Offset _gatePoint() {
    for (final g in kGateConfigs) {
      if (g['id'] == startGateId && g['visible'] != false) {
        return Offset(_num(g, 'gx'), _num(g, 'gy'));
      }
    }
    if (kGateConfigs.isNotEmpty) {
      final g = kGateConfigs.first;
      return Offset(_num(g, 'gx'), _num(g, 'gy'));
    }
    return Offset(Floor.gridCols - 40.0, Floor.gridRows / 2);
  }

  static int _nearestFree(Uint8List blocked, int cols, int rows, int from) {
    final c0 = from % cols;
    final r0 = from ~/ cols;
    for (int rad = 1; rad < 60; rad++) {
      for (int dy = -rad; dy <= rad; dy++) {
        for (int dx = -rad; dx <= rad; dx++) {
          if (dx.abs() != rad && dy.abs() != rad) continue;
          final c = c0 + dx;
          final r = r0 + dy;
          if (c < 0 || r < 0 || c >= cols || r >= rows) continue;
          if (blocked[r * cols + c] == 0) return r * cols + c;
        }
      }
    }
    return -1;
  }

  static List<SearchHit> searchEverything(String query) {
    const maxResults = 10;
    final q = query.trim();

    if (q.isEmpty) {
      final all = searchGroups('');
      return [
        for (final g in all.take(maxResults))
          SearchHit.group(label: labelOf(g), groupCfg: g),
      ];
    }

    final code = parseNicheCode(q);
    if (code != null) {
      final (cl, co, ro) = code;
      final col = _findColumn(cl, co);
      if (col == null) return const [];
      return [
        SearchHit.memorial(
          label: 'Cluster $cl · Column $co'
              '${ro != null ? ' · Row $ro' : ''}',
          cluster: cl,
          column: co,
          row: ro,
        ),
      ];
    }

    final qNorm = norm(q);
    final groupHits = <SearchHit>[];
    for (final g in allGroups()) {
      final label = norm(labelOf(g));
      final name = norm((g['name'] as String?) ?? '');
      final id = norm((g['id'] as String?) ?? '');
      if (qNorm.isEmpty) continue;
      if (!label.startsWith(qNorm) &&
          !name.startsWith(qNorm) &&
          !id.startsWith(qNorm)) {
        continue;
      }
      groupHits.add(SearchHit.group(label: labelOf(g), groupCfg: g));
      if (groupHits.length >= maxResults) break;
    }

    final remaining = maxResults - groupHits.length;
    final memorialHits = <SearchHit>[];
    if (remaining > 0) {
      final qLower = q.toLowerCase();
      for (final rec in MemorialRepository.allRecords) {
        if (!rec.isOccupied) continue;
        final name = (rec.name ?? '').toLowerCase();
        if (name.isEmpty || !name.contains(qLower)) continue;
        final parsed = rec.key != null ? parseNicheCode(rec.key!) : null;
        if (parsed == null) continue;
        final (cl, co, ro) = parsed;
        memorialHits.add(SearchHit.memorial(
          label: rec.name!,
          cluster: cl,
          column: co,
          row: ro,
        ));
        if (memorialHits.length >= remaining) break;
      }
    }

    return [...groupHits, ...memorialHits];
  }
}

class _MinHeap {
  final List<double> _k = [];
  final List<int> _v = [];
  double topKey = 0;

  bool get isNotEmpty => _k.isNotEmpty;

  void push(double key, int val) {
    _k.add(key);
    _v.add(val);
    int i = _k.length - 1;
    while (i > 0) {
      final p = (i - 1) >> 1;
      if (_k[p] <= _k[i]) break;
      _swap(p, i);
      i = p;
    }
  }

  int pop() {
    final val = _v[0];
    topKey = _k[0];
    final lastK = _k.removeLast();
    final lastV = _v.removeLast();
    if (_k.isNotEmpty) {
      _k[0] = lastK;
      _v[0] = lastV;
      int i = 0;
      final n = _k.length;
      while (true) {
        final l = 2 * i + 1;
        final r = l + 1;
        int m = i;
        if (l < n && _k[l] < _k[m]) m = l;
        if (r < n && _k[r] < _k[m]) m = r;
        if (m == i) break;
        _swap(i, m);
        i = m;
      }
    }
    return val;
  }

  void _swap(int a, int b) {
    final tk = _k[a];
    _k[a] = _k[b];
    _k[b] = tk;
    final tv = _v[a];
    _v[a] = _v[b];
    _v[b] = tv;
  }
}

class RouteLayer extends StatelessWidget {
  final bool markers;
  const RouteLayer({super.key, this.markers = false});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Floor.repaint,
      builder: (context, child) => CustomPaint(
        size: Size(Floor.canvasWidth, Floor.canvasHeight),
        painter: _RoutePainter(markers: markers),
      ),
    );
  }
}

class _RoutePainter extends CustomPainter {
  final bool markers;

  _RoutePainter({required this.markers})
      : super(
          repaint: Listenable.merge([
            Floor.repaint,
            Pathfinder.current,
            Pathfinder.viewScale,
          ]),
        );

  @override
  void paint(Canvas canvas, Size size) {
    final route = Pathfinder.current.value;
    if (route == null || route.points.length < 2) return;

    final pts = [for (final p in route.points) Floor.project(p.dx, p.dy)];
    final w = Pathfinder.lineWidth();

    if (markers) {
      _drawMarkers(canvas, pts, w);
      return;
    }

    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (final p in pts.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    _drawLine(canvas, path, w);
  }

  Paint _stroke(Color c, double width) => Paint()
    ..color = c
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  void _drawLine(Canvas canvas, Path path, double w) {
    canvas.drawPath(path, _stroke(Colors.red.withOpacity(0.28), w * 2.4));
    canvas.drawPath(path, _stroke(const Color(0xFFE53935), w));
    canvas.drawPath(path, _stroke(Colors.white.withOpacity(0.55), w * 0.3));
  }

  void _drawMarkers(Canvas canvas, List<Offset> pts, double w) {
    final start = pts.first;
    canvas.drawCircle(start, w * 1.9, Paint()..color = Colors.white);
    canvas.drawCircle(start, w * 1.5, Paint()..color = const Color(0xFF2E7D32));

    final end = pts.last;
    final top = end - Offset(0, w * 7);
    canvas.drawLine(
      end,
      top,
      Paint()
        ..color = const Color(0xFFB71C1C)
        ..strokeWidth = w * 0.5
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(top, w * 2.6, Paint()..color = Colors.white);
    canvas.drawCircle(top, w * 2.1, Paint()..color = const Color(0xFFE53935));
    canvas.drawCircle(top, w * 0.8, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _RoutePainter oldDelegate) => true;
}