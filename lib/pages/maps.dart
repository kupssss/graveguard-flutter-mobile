// ============================================================================
// maps.dart
// ============================================================================
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../components/floor.dart';
import '../components/group.dart';
import '../components/gate.dart';
import '../components/trees.dart';
import '../components/pathfinder.dart';
import '../components/route_search.dart';
import '../components/cluster.dart';
import '../components/column_modal.dart';
import '../theme/app_theme.dart';
import '../components/data.dart';
import '../components/sync_service.dart';
import '../components/sync_popups.dart';

class MapsPage extends StatefulWidget {
  const MapsPage({super.key, this.initialHit});

  final SearchHit? initialHit;

  @override
  State<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  final TransformationController _controller = TransformationController();
  final GlobalKey _viewportKey = GlobalKey();
  bool _didFit = false;
  bool _didInitialRoute = false;

  static const double _yawStep = math.pi / 12;
  static const double _minScale = 0.01;
  static const double _maxScale = 4.0;

  ClusterColumnRef? _selectedColumn;
  Offset? _pointerDownPos;
  Offset _pin = Offset.zero;

  @override
  void initState() {
    super.initState();
    Floor.yawNotifier.addListener(_onYawChanged);
    Floor.gridVersion.addListener(_onGridChanged);
    _controller.addListener(_onTransformChanged);

    MemorialRepository.version.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    Floor.yawNotifier.removeListener(_onYawChanged);
    Floor.gridVersion.removeListener(_onGridChanged);
    _controller.removeListener(_onTransformChanged);
    MemorialRepository.version.removeListener(_onDataChanged);
    _controller.dispose();
    Pathfinder.clear();
    super.dispose();
  }

  void _onDataChanged() {
    if (mounted) setState(() {});
  }

  void _onTransformChanged() {
    final s = _controller.value.getMaxScaleOnAxis();
    final old = Pathfinder.viewScale.value;
    if (old <= 0 || (s - old).abs() / old > 0.01) {
      Pathfinder.viewScale.value = s;
    }
  }

  void _onYawChanged() {
    if (mounted) setState(() {});
  }

  void _setTransform(double scale, double tx, double ty) {
    _controller.value = Matrix4.identity()
      ..translate(tx, ty)
      ..scale(scale);
  }

  void _onGridChanged() {
    if (!mounted) return;

    if (_didFit) {
      final m = _controller.value;
      final s = m.getMaxScaleOnAxis();
      final oldViewportPos = MatrixUtils.transformPoint(m, _pin);
      final newPin = Floor.pinPoint;

      _setTransform(
        s,
        oldViewportPos.dx - newPin.dx * s,
        oldViewportPos.dy - newPin.dy * s,
      );
      _pin = newPin;
    }
    setState(() {});
  }

  void _fitToGroup() {
    final box = _viewportKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;

    final vw = box.size.width;
    final vh = box.size.height;
    if (vw <= 0 || vh <= 0) return;

    final bounds = getFocusGroupBounds();
    if (bounds == null) return;

    final c1 = Floor.project(bounds.left, bounds.top);
    final c2 = Floor.project(bounds.right, bounds.top);
    final c3 = Floor.project(bounds.right, bounds.bottom);
    final c4 = Floor.project(bounds.left, bounds.bottom);

    final left = [c1.dx, c2.dx, c3.dx, c4.dx].reduce(math.min);
    final right = [c1.dx, c2.dx, c3.dx, c4.dx].reduce(math.max);
    final top = [c1.dy, c2.dy, c3.dy, c4.dy].reduce(math.min);
    final bottom = [c1.dy, c2.dy, c3.dy, c4.dy].reduce(math.max);

    final groupW = math.max(right - left, 1.0);
    final groupH = math.max(bottom - top, 1.0);

    final scaleX = vw / groupW;
    final scaleY = vh / groupH;
    final scale = ((scaleX < scaleY ? scaleX : scaleY) * 0.85)
        .clamp(_minScale, _maxScale)
        .toDouble();

    final groupCenterX = (left + right) / 2;
    final groupCenterY = (top + bottom) / 2;

    final dx = vw / 2 - groupCenterX * scale;
    final dy = vh / 2 - groupCenterY * scale;

    _setTransform(scale, dx, dy);
    _pin = Floor.pinPoint;
  }

  void _fitToRoute(List<Offset> worldPoints) {
    final box = _viewportKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize || worldPoints.isEmpty) return;

    final vw = box.size.width;
    final vh = box.size.height;
    if (vw <= 0 || vh <= 0) return;

    double minX = double.infinity;
    double maxX = -double.infinity;
    double minY = double.infinity;
    double maxY = -double.infinity;

    for (final p in worldPoints) {
      final s = Floor.project(p.dx, p.dy);
      minX = math.min(minX, s.dx);
      maxX = math.max(maxX, s.dx);
      minY = math.min(minY, s.dy);
      maxY = math.max(maxY, s.dy);
    }

    const pad = 2500.0;
    minX -= pad;
    maxX += pad;
    minY -= pad * 3;
    maxY += pad;

    final w = math.max(maxX - minX, 1.0);
    final h = math.max(maxY - minY, 1.0);
    final scale = (math.min(vw / w, vh / h) * 0.9)
        .clamp(_minScale, _maxScale)
        .toDouble();

    final cx = (minX + maxX) / 2;
    final cy = (minY + maxY) / 2;
    _setTransform(scale, vw / 2 - cx * scale, vh / 2 - cy * scale);
    _pin = Floor.pinPoint;
  }

  void _routeToInitialHit() {
    final hit = widget.initialHit;
    if (hit == null || _didInitialRoute) return;
    _didInitialRoute = true;

    RouteResult? route;
    if (hit.isMemorial) {
      final cl = hit.cluster;
      final co = hit.column;
      if (cl != null && co != null) {
        route = Pathfinder.routeToColumn(cl, co, label: hit.label);
      }
    } else {
      final cfg = hit.groupCfg;
      if (cfg != null) route = Pathfinder.routeToGroup(cfg);
    }

    if (route == null) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(content: Text('No walkable path found to ${hit.label}.')),
      );
      return;
    }
    _fitToRoute(route.points);
  }

  void _rotateBy(double delta) {
    final box = _viewportKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;

    final newYaw =
        (Floor.yaw + delta).clamp(-math.pi / 2, math.pi / 2).toDouble();
    if ((newYaw - Floor.yaw).abs() < 1e-9) return;

    final center = Offset(box.size.width / 2, box.size.height / 2);

    final inv = Matrix4.tryInvert(_controller.value);
    if (inv == null) return;

    final canvasPt = MatrixUtils.transformPoint(inv, center);
    final world = Floor.unproject(canvasPt);

    Floor.yaw = newYaw;

    final np = Floor.project(world.dx, world.dy);
    final s = _controller.value.getMaxScaleOnAxis();
    _setTransform(s, center.dx - np.dx * s, center.dy - np.dy * s);
    _pin = Floor.pinPoint;
  }

  void _resetView() {
    Floor.yaw = 0;
    _fitToGroup();
  }

  void _zoomBy(double factor) {
    final box = _viewportKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;

    final vw = box.size.width;
    final vh = box.size.height;

    final current = _controller.value;
    final currentScale = current.getMaxScaleOnAxis();
    final targetScale =
        (currentScale * factor).clamp(_minScale, _maxScale).toDouble();
    if ((targetScale - currentScale).abs() < 1e-6) return;

    final focal = Offset(vw / 2, vh / 2);
    final inv = Matrix4.inverted(current);
    final scenePoint = MatrixUtils.transformPoint(inv, focal);

    final tx = focal.dx - scenePoint.dx * targetScale;
    final ty = focal.dy - scenePoint.dy * targetScale;

    _setTransform(targetScale, tx, ty);
  }

  void _handlePointerDown(PointerDownEvent event) {
    _pointerDownPos = event.localPosition;
  }

  void _handlePointerUp(PointerUpEvent event) {
    final downPos = _pointerDownPos;
    _pointerDownPos = null;
    if (downPos == null) return;

    if ((event.localPosition - downPos).distance > 10) return;

    FocusManager.instance.primaryFocus?.unfocus();

    final inverse = Matrix4.tryInvert(_controller.value);
    if (inverse == null) return;
    final scenePoint = MatrixUtils.transformPoint(inverse, event.localPosition);
    _processTapAt(scenePoint);
  }

  void _processTapAt(Offset scenePoint) {
    final targets = getClusterHitTargets()
      ..sort((a, b) => b.depthKey.compareTo(a.depthKey));

    for (final t in targets) {
      if (_pointInPolygon(scenePoint, t.silhouette, expand: 4)) {
        _onColumnTap(t.ref);
        return;
      }
    }
  }

  Future<void> _onColumnTap(ClusterColumnRef ref) async {
    setState(() => _selectedColumn = ref);
    await showColumnModal(context, ref: ref);
    if (!mounted) return;
    setState(() => _selectedColumn = null);
  }

  bool _pointInPolygon(Offset p, List<Offset> poly, {double expand = 0}) {
    if (_evenOdd(p, poly)) return true;
    if (expand <= 0) return false;

    double cx = 0;
    double cy = 0;
    for (final v in poly) {
      cx += v.dx;
      cy += v.dy;
    }
    cx /= poly.length;
    cy /= poly.length;

    double avgDist = 0;
    for (final v in poly) {
      avgDist += (v - Offset(cx, cy)).distance;
    }
    avgDist /= poly.length;
    if (avgDist < 1e-6) return false;

    final scale = (avgDist + expand) / avgDist;
    final expanded = poly
        .map((v) => Offset(cx + (v.dx - cx) * scale, cy + (v.dy - cy) * scale))
        .toList();

    return _evenOdd(p, expanded);
  }

  bool _evenOdd(Offset p, List<Offset> poly) {
    int count = 0;
    for (int i = 0, j = poly.length - 1; i < poly.length; j = i++) {
      final pi = poly[i];
      final pj = poly[j];
      final intersect = ((pi.dy > p.dy) != (pj.dy > p.dy)) &&
          (p.dx <
              (pj.dx - pi.dx) * (p.dy - pi.dy) / (pj.dy - pi.dy + 1e-9) +
                  pi.dx);
      if (intersect) count++;
    }
    return count.isOdd;
  }

  Future<void> _onRefreshPressed() async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    await SyncService.checkNow(userInitiated: true);
    if (!mounted) return;
    if (!SyncService.online.value) return;
    if (SyncService.updateAvailable.value == null) {
      messenger?.showSnackBar(
        const SnackBar(
          content: Text('Records are up to date.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildErrorBanner() {
    return ValueListenableBuilder<String?>(
      valueListenable: MemorialRepository.error,
      builder: (context, err, child) {
        if (err == null) return const SizedBox.shrink();
        return Positioned(
          bottom: 8,
          left: 8,
          right: 8,
          child: Material(
            color: Colors.red.shade700,
            elevation: 3,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.cloud_off, color: AppColors.white, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      err,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: MemorialRepository.load,
                    child: const Text(
                      'Retry',
                      style: TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchOverlay() {
    return Positioned(
      top: 8,
      left: 8,
      right: 8,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RouteSearchBar(
            onRoute: (route) => _fitToRoute(route.points),
          ),
          ValueListenableBuilder<RouteResult?>(
            valueListenable: Pathfinder.current,
            builder: (context, route, child) {
              if (route == null) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Material(
                  color: AppColors.navy,
                  elevation: 3,
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 14,
                      right: 4,
                      top: 2,
                      bottom: 2,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.directions_walk,
                          color: AppColors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Route to ${route.label}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: AppColors.white,
                            size: 18,
                          ),
                          tooltip: 'Clear route',
                          onPressed: Pathfinder.clear,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMapLayers() {
    return Stack(
      children: [
        Positioned.fill(
          child: RepaintBoundary(child: const Floor()),
        ),
        Positioned.fill(
          child: RepaintBoundary(child: const RouteLayer()),
        ),
        Positioned.fill(
          child: RepaintBoundary(child: const Group()),
        ),
        Positioned.fill(
          child: RepaintBoundary(child: const Gate()),
        ),
        Positioned.fill(
          child: RepaintBoundary(child: const TreeLine()),
        ),
        Positioned.fill(
          child: RepaintBoundary(child: const RouteLayer(markers: true)),
        ),
        Positioned.fill(
          child: RepaintBoundary(
            child: Cluster(
              selectedClusterId: _selectedColumn?.clusterId,
              selectedColumnIndex: _selectedColumn?.columnIndex,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildControlBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightBlueGray,
        border: Border(
          top: BorderSide(
            color: AppColors.navy.withOpacity(0.08),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ControlButton(
                icon: Icons.rotate_left,
                tooltip: 'Rotate left',
                onPressed: () => _rotateBy(-_yawStep),
              ),
              _ControlButton(
                icon: Icons.restart_alt,
                tooltip: 'Reset view',
                onPressed: _resetView,
              ),
              _ControlButton(
                icon: Icons.rotate_right,
                tooltip: 'Rotate right',
                onPressed: () => _rotateBy(_yawStep),
              ),
              const _BarDivider(),
              _ControlButton(
                icon: Icons.zoom_out_map,
                tooltip: 'Zoom all the way out',
                onPressed: () {
                  _setTransform(
                    _minScale,
                    _controller.value.getTranslation().x,
                    _controller.value.getTranslation().y,
                  );
                  _fitToGroup();
                },
              ),
              _ControlButton(
                icon: Icons.remove,
                tooltip: 'Zoom out',
                onPressed: () => _zoomBy(1 / 1.2),
              ),
              _ControlButton(
                icon: Icons.add,
                tooltip: 'Zoom in',
                onPressed: () => _zoomBy(1.2),
              ),
              const _BarDivider(),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.navy,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${(Floor.yaw * 180 / math.pi).toStringAsFixed(0)}°',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: const Text('GraveGuard - Maps'),
        backgroundColor: AppColors.navy,
        foregroundColor: AppColors.white,
        elevation: 0,
        actions: [
          ValueListenableBuilder<bool>(
            valueListenable: MemorialRepository.loading,
            builder: (context, loading, child) {
              if (loading) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.white,
                    ),
                  ),
                );
              }
              return IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh records',
                onPressed: _onRefreshPressed,
              );
            },
          ),
        ],
      ),
      body: SyncListener(
        child: Column(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (!_didFit &&
                      constraints.maxWidth > 0 &&
                      constraints.maxHeight > 0) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!mounted) return;
                      _fitToGroup();
                      _didFit = true;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) _routeToInitialHit();
                      });
                    });
                  }
                  return Container(
                    key: _viewportKey,
                    color: AppColors.white,
                    child: Stack(
                      children: [
                        Listener(
                          onPointerDown: _handlePointerDown,
                          onPointerUp: _handlePointerUp,
                          child: InteractiveViewer(
                            transformationController: _controller,
                            minScale: _minScale,
                            maxScale: _maxScale,
                            boundaryMargin:
                                const EdgeInsets.all(double.infinity),
                            child: SizedBox(
                              width: Floor.canvasWidth,
                              height: Floor.canvasHeight,
                              child: _buildMapLayers(),
                            ),
                          ),
                        ),
                        _buildSearchOverlay(),
                        _buildErrorBanner(),
                        const OfflineBanner(),
                        const PhotoSyncBanner(),
                      ],
                    ),
                  );
                },
              ),
            ),
            _buildControlBar(),
          ],
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon),
      tooltip: tooltip,
      onPressed: onPressed,
      iconSize: 22,
      color: AppColors.navy,
      splashColor: AppColors.navy.withOpacity(0.12),
      highlightColor: AppColors.navy.withOpacity(0.06),
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.all(6),
      constraints: const BoxConstraints(
        minWidth: 40,
        minHeight: 40,
      ),
    );
  }
}

class _BarDivider extends StatelessWidget {
  const _BarDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 22,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      color: AppColors.navy.withOpacity(0.15),
    );
  }
}