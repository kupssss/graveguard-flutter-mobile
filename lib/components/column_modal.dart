// ============================================================================
// column_modal.dart
// ============================================================================

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'cluster.dart';
import 'data.dart';
import 'niche_detail_modal.dart'; 

class _Stone {
  static const slabTop = Color(0xFFDCD7CE);
  static const slabMid = Color(0xFFC9C4BA);
  static const slabBottom = Color(0xFFB3ADA2);
  static const slabEdge = Color(0xFF7A7468);
  static const inkDeep = Color(0xFF25221D);
  static const inkSoft = Color(0xFF4A463F);
  static const inkFaint = Color(0xFF736E64);
  static const parchment = Color(0xFFE6E2D8);
  static const background = Color(0xFF15140F);
  static const backgroundLow = Color(0xFF0C0B08);
  static const divider = Color(0xFF3A372F);
  static const available = Color(0xFF5F7B4F);
  static const flame = Color(0xFFFFB347);
  static const flower = Color(0xFF8E3B4A);
}

Future<void> showColumnModal(
  BuildContext context, {
  required ClusterColumnRef ref,
}) {
  if (!MemorialRepository.hasData) MemorialRepository.load();

  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Column',
    barrierColor: Colors.black.withOpacity(0.86),
    transitionDuration: const Duration(milliseconds: 420),
    pageBuilder: (_, __, ___) => _ColumnModal(ref: ref),
    transitionBuilder: (context, anim, _, child) {
      final curved = CurvedAnimation(
        parent: anim,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.04),
            end: Offset.zero,
          ).animate(curved),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(curved),
            child: child,
          ),
        ),
      );
    },
  );
}

class _ColumnModal extends StatefulWidget {
  const _ColumnModal({required this.ref});
  final ClusterColumnRef ref;

  @override
  State<_ColumnModal> createState() => _ColumnModalState();
}

class _ColumnModalState extends State<_ColumnModal>
    with SingleTickerProviderStateMixin {
  int? _openRow;
  late final AnimationController _ambient;

  int get _clusterNumber {
    final raw = widget.ref.clusterId;
    final match = RegExp(r'\d+').firstMatch(raw);
    return match != null ? int.parse(match.group(0)!) : 1;
  }

  @override
  void initState() {
    super.initState();
    _ambient = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 22),
    )..repeat();
    MemorialRepository.version.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    MemorialRepository.version.removeListener(_onDataChanged);
    _ambient.dispose();
    super.dispose();
  }

  void _onDataChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _openDetail(int row) async {
    setState(() => _openRow = row);
    await showNicheDetailModal(
      context,
      cluster: _clusterNumber,
      column: widget.ref.columnIndex,
      row: row,
    );
    if (!mounted) return;
    setState(() => _openRow = null);
  }

  @override
  Widget build(BuildContext context) {
    final ref = widget.ref;
    final rows = List.generate(ref.rowCount, (i) => i + 1);
    final records = [
      for (final r in rows)
        getMemorialRecord(_clusterNumber, ref.columnIndex, r),
    ];

    final screen = MediaQuery.of(context).size;
    const hPad = 10.0;
    const vPad = 20.0;
    final maxCardW = screen.width - hPad * 2;
    final maxCardH = screen.height - vPad * 2;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: 0,
            maxWidth: maxCardW,
            maxHeight: maxCardH,
          ),
          child: Container(
            margin: const EdgeInsets.symmetric(
              horizontal: hPad,
              vertical: vPad,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_Stone.background, _Stone.backgroundLow],
              ),
              border: Border.all(color: _Stone.divider, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.9),
                  blurRadius: 44,
                  spreadRadius: 6,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(painter: _MistPainter(_ambient)),
                    ),
                  ),
                  SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _header(ref, records),
                        _rule(),
                        _rowsList(rows, records),
                      ],
                    ),
                  ),
                  Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            radius: 1.15,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.45),
                            ],
                            stops: const [0.6, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  Widget _header(ClusterColumnRef ref, List<MemorialRecord> records) {
    final occupied = records.where((r) => r.isOccupied).length;
    final vacant = records.length - occupied;
    final subtitle = MemorialRepository.hasData
        ? '${ref.rowCount} niches  ·  $occupied resting  ·  $vacant vacant'
        : '${ref.rowCount} niches  ·  memorial record';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 12, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedBuilder(
            animation: _ambient,
            builder: (context, child) {
              final breath =
                  0.5 + 0.5 * math.sin(_ambient.value * 2 * math.pi * 4);
              return Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    center: Alignment(-0.3, -0.4),
                    colors: [_Stone.slabTop, _Stone.slabMid, _Stone.slabBottom],
                  ),
                  border: Border.all(color: _Stone.slabEdge, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.04 + 0.07 * breath),
                      blurRadius: 14 + 10 * breath,
                      spreadRadius: 1 + 2 * breath,
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: child,
              );
            },
            child: SizedBox(
              width: 26,
              height: 26,
              child: CustomPaint(
                painter: _CrossPainter(color: _Stone.inkDeep),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'IN MEMORIAM',
                  style: TextStyle(
                    color: _Stone.inkFaint,
                    fontSize: 11,
                    letterSpacing: 4.0,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                  softWrap: true,
                ),
                const SizedBox(height: 6),
                Text(
                  'Cluster $_clusterNumber  ·  Column ${ref.columnIndex}',
                  style: const TextStyle(
                    color: _Stone.parchment,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                    height: 1.25,
                  ),
                  softWrap: true,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: _Stone.parchment.withOpacity(0.45),
                    fontSize: 12.5,
                    letterSpacing: 1.0,
                    height: 1.3,
                  ),
                  softWrap: true,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: Colors.white54),
            tooltip: 'Close',
          ),
        ],
      ),
    );
  }

  Widget _rule() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(height: 1, color: _Stone.divider),
    );
  }

  Widget _rowsList(List<int> rows, List<MemorialRecord> records) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            if (i > 0) const SizedBox(height: 14),
            _Rise(
              key: ValueKey('rise_${rows[i]}'),
              index: i,
              child: _LapidaPlaque(
                row: rows[i],
                record: records[i],
                selected: _openRow == rows[i],
                onTap: () => _openDetail(rows[i]),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Rise extends StatefulWidget {
  const _Rise({super.key, required this.index, required this.child});
  final int index;
  final Widget child;

  @override
  State<_Rise> createState() => _RiseState();
}

class _RiseState extends State<_Rise> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _curve;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _curve = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
    Future.delayed(Duration(milliseconds: 150 + widget.index * 120), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _curve,
      child: widget.child,
      builder: (context, child) {
        final v = _curve.value;
        return Opacity(
          opacity: v.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, (1 - v) * 30),
            child: child,
          ),
        );
      },
    );
  }
}

class _LapidaPlaque extends StatefulWidget {
  const _LapidaPlaque({
    required this.row,
    required this.record,
    required this.selected,
    required this.onTap,
  });

  final int row;
  final MemorialRecord record;

  final bool selected;
  final VoidCallback onTap;

  @override
  State<_LapidaPlaque> createState() => _LapidaPlaqueState();
}

class _LapidaPlaqueState extends State<_LapidaPlaque> {
  static const _dateStyle = TextStyle(
    color: _Stone.inkSoft,
    fontSize: 12.5,
    height: 1.4,
    letterSpacing: 0.2,
    fontWeight: FontWeight.w500,
    fontStyle: FontStyle.italic,
  );

  static const double _chrome = 124;

  bool _candle = false;
  bool _flower = false;
  bool _overflow = false;

  String? get _birth => widget.record.birthDate;
  String? get _death => widget.record.deathDate;

  String get _datesText {
    final b = _birth;
    final d = _death;
    return (b != null && d != null) ? '$b  —  $d' : (b ?? d ?? '');
  }

  bool get _hasQuote =>
      widget.record.quote != null && widget.record.quote!.trim().isNotEmpty;

  bool _datesOverflow(BuildContext context, double maxWidth) {
    final text = _datesText;
    if (text.isEmpty) return false;
    final tp = TextPainter(
      text: TextSpan(text: text, style: _dateStyle),
      maxLines: 1,
      textDirection: TextDirection.ltr,
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();
    return tp.width > maxWidth - _chrome;
  }

  void _handleTap() {
    HapticFeedback.selectionClick();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final occupied = widget.record.isOccupied;

    return LayoutBuilder(
      builder: (context, c) {
        _overflow = occupied && _datesOverflow(context, c.maxWidth);
        final lit = occupied && _candle;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _handleTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOut,
            transform: Matrix4.translationValues(
              0,
              widget.selected ? -3 : 0,
              0,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.6),
                  blurRadius: widget.selected ? 18 : 10,
                  offset: Offset(0, widget.selected ? 9 : 5),
                ),
                if (widget.selected && !occupied)
                  BoxShadow(
                    color: _Stone.available.withOpacity(0.35),
                    blurRadius: 22,
                    spreadRadius: 1,
                  ),
                if (lit)
                  BoxShadow(
                    color: _Stone.flame.withOpacity(0.22),
                    blurRadius: 26,
                    spreadRadius: 1,
                  ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Stack(
                children: [
                  _face(occupied ? _front(_overflow) : _vacant(), 0),
                  Positioned.fill(
                    child: IgnorePointer(
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 700),
                        opacity: lit ? 1 : 0,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              center: const Alignment(0.9, 1.1),
                              radius: 1.2,
                              colors: [
                                _Stone.flame.withOpacity(0.28),
                                _Stone.flame.withOpacity(0.0),
                              ],
                            ),
                          ),
                        ),
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

  Widget _face(Widget content, int seedOffset) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_Stone.slabTop, _Stone.slabMid, _Stone.slabBottom],
              stops: [0.0, 0.55, 1.0],
            ),
            border: Border.all(
              color: widget.selected
                  ? _Stone.inkDeep
                  : _Stone.slabEdge.withOpacity(0.55),
              width: widget.selected ? 1.6 : 1.0,
            ),
          ),
          child: Container(
            margin: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white.withOpacity(0.30),
                width: 0.6,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: content,
            ),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _MarblePainter(seed: widget.row * 11 + seedOffset),
            ),
          ),
        ),
      ],
    );
  }

  Widget _front(bool overflow) {
    final r = widget.record;
    final b = _birth;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 40,
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: SizedBox(
              width: 32,
              height: 32,
              child: CustomPaint(
                painter: _CrossPainter(color: _Stone.inkDeep),
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _Engraved(
                text: (r.name ?? '').toUpperCase(),
                selected: widget.selected,
                fontSize: 18,
              ),
              const SizedBox(height: 8),
              if (overflow && b != null && _death != null) ...[
                Text('$b  —', style: _dateStyle, softWrap: true),
                const SizedBox(height: 2),
                Text(_death!, style: _dateStyle, softWrap: true),
              ] else if (_datesText.isNotEmpty)
                Text(_datesText, style: _dateStyle, softWrap: true),
              if (_hasQuote) ...[
                const SizedBox(height: 10),
                _hair(),
                const SizedBox(height: 8),
                _quote(),
              ],
              const SizedBox(height: 10),
              _offerings(),
            ],
          ),
        ),
        _marker(),
      ],
    );
  }

  Widget _vacant() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 40,
          child: Icon(
            Icons.remove,
            size: 20,
            color: _Stone.inkFaint.withOpacity(0.55),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const _Engraved(text: 'VACANT', selected: false, fontSize: 16),
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 240),
                      width: widget.selected ? 8 : 6,
                      height: widget.selected ? 8 : 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _Stone.available,
                        boxShadow: widget.selected
                            ? [
                                BoxShadow(
                                  color: _Stone.available.withOpacity(0.7),
                                  blurRadius: 8,
                                ),
                              ]
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Flexible(
                    child: Text(
                      'Available · tap to inquire',
                      style: TextStyle(
                        color: _Stone.inkSoft,
                        fontSize: 12,
                        height: 1.35,
                        letterSpacing: 0.2,
                        fontWeight: FontWeight.w500,
                      ),
                      softWrap: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                height: 1,
                width: 110,
                color: _Stone.inkFaint.withOpacity(0.22),
              ),
              const SizedBox(height: 6),
              Container(
                height: 1,
                width: 70,
                color: _Stone.inkFaint.withOpacity(0.16),
              ),
            ],
          ),
        ),
        _marker(),
      ],
    );
  }

  Widget _marker({String? page}) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, left: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'R${widget.row}',
            style: TextStyle(
              color: _Stone.inkFaint.withOpacity(0.9),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
          if (page != null) ...[
            const SizedBox(height: 2),
            Text(
              page,
              style: TextStyle(
                color: _Stone.inkFaint.withOpacity(0.8),
                fontSize: 9.5,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _hair() {
    return Container(
      height: 1,
      width: 40,
      color: _Stone.inkDeep.withOpacity(0.25),
    );
  }

  Widget _quote() {
    return SizedBox(
      width: double.infinity,
      child: Text(
        '\u201C${widget.record.quote!.trim()}\u201D',
        textAlign: TextAlign.justify,
        textWidthBasis: TextWidthBasis.parent,
        style: const TextStyle(
          color: _Stone.inkSoft,
          fontSize: 12.5,
          height: 1.55,
          letterSpacing: 0.1,
          fontStyle: FontStyle.italic,
        ),
        softWrap: true,
      ),
    );
  }

  Widget _offerings({Widget? chip}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (chip != null) chip,
        const Spacer(),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            HapticFeedback.lightImpact();
            setState(() => _flower = !_flower);
          },
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: AnimatedScale(
              scale: _flower ? 1.18 : 1.0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.elasticOut,
              child: Icon(
                _flower ? Icons.local_florist : Icons.local_florist_outlined,
                size: 22,
                color: _flower ? _Stone.flower : _Stone.inkFaint,
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            HapticFeedback.lightImpact();
            setState(() => _candle = !_candle);
          },
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: _Flame(lit: _candle),
          ),
        ),
      ],
    );
  }
}

class _Flame extends StatefulWidget {
  const _Flame({required this.lit});
  final bool lit;

  @override
  State<_Flame> createState() => _FlameState();
}

class _FlameState extends State<_Flame> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    if (widget.lit) _c.repeat();
  }

  @override
  void didUpdateWidget(covariant _Flame old) {
    super.didUpdateWidget(old);
    if (widget.lit && !_c.isAnimating) {
      _c.repeat();
    } else if (!widget.lit && _c.isAnimating) {
      _c.stop();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(22, 30),
      painter: _FlamePainter(t: _c, lit: widget.lit),
    );
  }
}

class _FlamePainter extends CustomPainter {
  _FlamePainter({required this.t, required this.lit}) : super(repaint: t);
  final Animation<double> t;
  final bool lit;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final bodyTop = size.height * 0.62;

    final body = RRect.fromLTRBR(
      cx - size.width * 0.17,
      bodyTop,
      cx + size.width * 0.17,
      size.height,
      const Radius.circular(1.5),
    );
    canvas.drawRRect(body, Paint()..color = const Color(0xFFE9E2D0));
    canvas.drawRRect(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.7
        ..color = _Stone.inkFaint.withOpacity(0.6),
    );

    final wickTop = bodyTop - 3;
    canvas.drawLine(
      Offset(cx, bodyTop),
      Offset(cx, wickTop),
      Paint()
        ..color = _Stone.inkDeep
        ..strokeWidth = 1,
    );

    if (!lit) return;

    final f = math.sin(t.value * 2 * math.pi * 3) * 0.5 +
        math.sin(t.value * 2 * math.pi * 7 + 1) * 0.3;
    final fh = size.height * 0.40 * (1 + 0.10 * f);
    final fw = size.width * 0.20;
    final tipX = cx + f * 1.4;
    final tipY = wickTop - fh;
    final glowC = Offset(cx, wickTop - fh * 0.45);

    canvas.drawCircle(
      glowC,
      size.width * 1.0,
      Paint()
        ..shader = RadialGradient(
          colors: [
            _Stone.flame.withOpacity(0.45),
            _Stone.flame.withOpacity(0.0),
          ],
        ).createShader(Rect.fromCircle(center: glowC, radius: size.width)),
    );

    final outer = Path()
      ..moveTo(cx, wickTop)
      ..quadraticBezierTo(cx - fw * 1.7, wickTop - fh * 0.45, tipX, tipY)
      ..quadraticBezierTo(cx + fw * 1.7, wickTop - fh * 0.45, cx, wickTop)
      ..close();
    canvas.drawPath(outer, Paint()..color = const Color(0xFFFF9A2E));

    final inner = Path()
      ..moveTo(cx, wickTop)
      ..quadraticBezierTo(
          cx - fw, wickTop - fh * 0.35, cx + f * 0.8, wickTop - fh * 0.7)
      ..quadraticBezierTo(cx + fw, wickTop - fh * 0.35, cx, wickTop)
      ..close();
    canvas.drawPath(inner, Paint()..color = const Color(0xFFFFE9A8));
  }

  @override
  bool shouldRepaint(covariant _FlamePainter old) => old.lit != lit;
}

class _CrossPainter extends CustomPainter {
  _CrossPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = color.withOpacity(0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(c.dx, c.dy - size.height * 0.34),
      Offset(c.dx, c.dy + size.height * 0.34),
      paint,
    );
    canvas.drawLine(
      Offset(c.dx - size.width * 0.22, c.dy - size.height * 0.12),
      Offset(c.dx + size.width * 0.22, c.dy - size.height * 0.12),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _CrossPainter old) => old.color != color;
}

class _Engraved extends StatelessWidget {
  const _Engraved({
    required this.text,
    required this.selected,
    this.fontSize = 18,
  });

  final String text;
  final bool selected;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1100),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) {
        final base = TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
          letterSpacing: 2.0 + (1 - v) * 5.0,
          height: 1.15,
        );

        return Opacity(
          opacity: v.clamp(0.0, 1.0),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Stack(
              children: [
                Transform.translate(
                  offset: const Offset(1.0, 1.0),
                  child: Text(
                    text,
                    style: base.copyWith(color: Colors.black.withOpacity(0.55)),
                    softWrap: false,
                    maxLines: 1,
                  ),
                ),
                Transform.translate(
                  offset: const Offset(-0.6, -0.6),
                  child: Text(
                    text,
                    style: base.copyWith(color: Colors.white.withOpacity(0.5)),
                    softWrap: false,
                    maxLines: 1,
                  ),
                ),
                Text(
                  text,
                  style: base.copyWith(color: _Stone.inkDeep),
                  softWrap: false,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MarblePainter extends CustomPainter {
  _MarblePainter({required this.seed});
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = math.Random(seed);
    final w = size.width;
    final h = size.height;


    for (int i = 0; i < 3; i++) {
      final p = Path()
        ..moveTo(rnd.nextDouble() * w, -2)
        ..cubicTo(
          rnd.nextDouble() * w,
          h * 0.3,
          rnd.nextDouble() * w,
          h * 0.65,
          rnd.nextDouble() * w,
          h + 2,
        );
      canvas.drawPath(
        p,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.6 + rnd.nextDouble() * 0.9
          ..color = Colors.black.withOpacity(0.055 + rnd.nextDouble() * 0.04)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.9),
      );
    }

    final dark = Paint()..color = Colors.black.withOpacity(0.035);
    final light = Paint()..color = Colors.white.withOpacity(0.05);
    for (int i = 0; i < 180; i++) {
      canvas.drawCircle(
        Offset(rnd.nextDouble() * w, rnd.nextDouble() * h),
        0.5 + rnd.nextDouble() * 0.6,
        rnd.nextBool() ? dark : light,
      );
    }

    canvas.drawLine(
      const Offset(0, 0.5),
      Offset(w, 0.5),
      Paint()
        ..color = Colors.white.withOpacity(0.35)
        ..strokeWidth = 1,
    );
    canvas.drawLine(
      Offset(0, h - 0.5),
      Offset(w, h - 0.5),
      Paint()
        ..color = Colors.black.withOpacity(0.25)
        ..strokeWidth = 1,
    );

    const inset = 9.0;
    for (final o in [
      const Offset(inset, inset),
      Offset(w - inset, inset),
      Offset(inset, h - inset),
      Offset(w - inset, h - inset),
    ]) {
      canvas.drawCircle(o + const Offset(0.5, 0.8), 2.8,
          Paint()..color = Colors.black.withOpacity(0.25));
      canvas.drawCircle(
          o, 2.6, Paint()..color = _Stone.slabEdge.withOpacity(0.75));
      canvas.drawCircle(o + const Offset(-0.6, -0.6), 1.0,
          Paint()..color = Colors.white.withOpacity(0.45));
    }
  }

  @override
  bool shouldRepaint(covariant _MarblePainter old) => old.seed != seed;
}

class _MistPainter extends CustomPainter {
  _MistPainter(this.t) : super(repaint: t);
  final Animation<double> t;

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < 5; i++) {
      final phase = (t.value + i / 5) % 1.0;
      final center = Offset(
        size.width * (phase * 1.5 - 0.25),
        size.height * (0.12 + 0.19 * i),
      );
      final radius = size.width * (0.5 + 0.08 * (i % 3));
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..shader = RadialGradient(
            colors: [
              Colors.white.withOpacity(0.065),
              Colors.white.withOpacity(0.0),
            ],
          ).createShader(Rect.fromCircle(center: center, radius: radius)),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MistPainter old) => false;
}