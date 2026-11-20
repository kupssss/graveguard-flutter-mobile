// ============================================================================
// niche_detail_modal.dart
// ============================================================================
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'data.dart';
import 'photo_store.dart';

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

  static const leaseActive = Color(0xFF5F7B4F);
  static const leaseExpiring = Color(0xFFB89A4E);
  static const leaseCritical = Color(0xFF9C3A32);
}

Future<void> showNicheDetailModal(
  BuildContext context, {
  required int cluster,
  required int column,
  required int row,
}) {
  final record = getMemorialRecord(cluster, column, row);

  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Niche',
    barrierColor: Colors.black.withOpacity(0.86),
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (_, __, ___) => _NicheDetailModal(
      cluster: cluster,
      column: column,
      row: row,
      record: record,
    ),
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
            begin: const Offset(0, 0.05),
            end: Offset.zero,
          ).animate(curved),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.94, end: 1.0).animate(curved),
            child: child,
          ),
        ),
      );
    },
  );
}

class _NicheDetailModal extends StatefulWidget {
  const _NicheDetailModal({
    required this.cluster,
    required this.column,
    required this.row,
    required this.record,
  });

  final int cluster;
  final int column;
  final int row;
  final MemorialRecord record;

  @override
  State<_NicheDetailModal> createState() => _NicheDetailModalState();
}

class _NicheDetailModalState extends State<_NicheDetailModal> {
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _msgCtrl = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _msgCtrl.dispose();
    super.dispose();
  }

  String get _code => 'CL${widget.cluster}-C${widget.column}-R${widget.row}';

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    const hPad = 12.0;
    const vPad = 24.0;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: math.min(screen.width - hPad * 2, 460),
            maxHeight: screen.height - vPad * 2,
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
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
              borderRadius: BorderRadius.circular(10),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _header(),
                    _rule(),
                    if (widget.record.isOccupied)
                      _occupiedBody()
                    else
                      _vacantBody(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _header() {
    final occupied = widget.record.isOccupied;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 12, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                center: Alignment(-0.3, -0.4),
                colors: [_Stone.slabTop, _Stone.slabMid, _Stone.slabBottom],
              ),
              border: Border.all(color: _Stone.slabEdge, width: 1),
            ),
            alignment: Alignment.center,
            child: Icon(
              occupied ? Icons.local_florist : Icons.add,
              color: _Stone.inkDeep,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  occupied ? 'IN MEMORIAM' : 'AVAILABLE NICHE',
                  style: const TextStyle(
                    color: _Stone.inkFaint,
                    fontSize: 10.5,
                    letterSpacing: 4.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Cluster ${widget.cluster}  ·  Column ${widget.column}'
                  '  ·  Row ${widget.row}',
                  style: const TextStyle(
                    color: _Stone.parchment,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                    height: 1.25,
                  ),
                  softWrap: true,
                ),
                const SizedBox(height: 2),
                Text(
                  _code,
                  style: TextStyle(
                    color: _Stone.parchment.withOpacity(0.4),
                    fontSize: 11.5,
                    letterSpacing: 1.2,
                  ),
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

  Widget _rule() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(height: 1, color: _Stone.divider),
      );

  Widget _occupiedBody() {
    final r = widget.record;
    final dates = (r.birthDate != null && r.deathDate != null)
        ? '${r.birthDate}  —  ${r.deathDate}'
        : (r.birthDate ?? r.deathDate ?? '');

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _PhotoPane(url: r.photoUrl),
          const SizedBox(height: 16),
          Text(
            (r.name ?? '').toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _Stone.parchment,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: 2.0,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          if (dates.isNotEmpty)
            Text(
              dates,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _Stone.inkSoft,
                fontSize: 13,
                fontStyle: FontStyle.italic,
                letterSpacing: 0.4,
                height: 1.4,
              ),
            ),
          if (r.leaseYears != null || r.leaseStatus != null) ...[
            const SizedBox(height: 14),
            Center(child: _leaseBadge(r)),
          ],
          if (r.quote != null && r.quote!.trim().isNotEmpty) ...[
            const SizedBox(height: 18),
            Container(height: 1, color: _Stone.divider),
            const SizedBox(height: 12),
            Text(
              '\u201C${r.quote!.trim()}\u201D',
              textAlign: TextAlign.justify,
              textWidthBasis: TextWidthBasis.parent,
              style: const TextStyle(
                color: _Stone.inkSoft,
                fontSize: 12.5,
                height: 1.55,
                letterSpacing: 0.1,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          if (r.notes != null && r.notes!.trim().isNotEmpty) ...[
            const SizedBox(height: 18),
            Container(height: 1, color: _Stone.divider),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.notes,
                    size: 13, color: _Stone.inkFaint.withOpacity(0.8)),
                const SizedBox(width: 6),
                Text(
                  'RECORDS',
                  style: TextStyle(
                    color: _Stone.inkFaint.withOpacity(0.9),
                    fontSize: 9.5,
                    letterSpacing: 2.4,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.35),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: _Stone.divider, width: 0.8),
              ),
              child: Text(
                r.notes!,
                style: const TextStyle(
                  color: _Stone.inkSoft,
                  fontSize: 12.5,
                  height: 1.5,
                  letterSpacing: 0.15,
                ),
              ),
            ),
          ],
          const SizedBox(height: 22),
          Center(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: _Stone.parchment,
                side: const BorderSide(color: _Stone.divider, width: 1),
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text(
                'Close',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _leaseBadge(MemorialRecord r) {
    final status = r.leaseStatus ?? _deriveLeaseStatus(r.leaseYears);
    final label = switch (status) {
      'active' => 'Lease active',
      'expiring' => 'Lease expiring',
      'critical' => 'Lease critical',
      _ => 'Vacant',
    };
    final color = switch (status) {
      'active' => _Stone.leaseActive,
      'expiring' => _Stone.leaseExpiring,
      'critical' => _Stone.leaseCritical,
      _ => _Stone.inkFaint,
    };
    final years = r.leaseYears;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.55), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            years != null
                ? '$label · $years yr${years == 1 ? "" : "s"} left'
                : label,
            style: const TextStyle(
              color: _Stone.parchment,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  String _deriveLeaseStatus(int? years) {
    if (years == null) return 'vacant';
    if (years >= 4) return 'active';
    if (years >= 2) return 'expiring';
    return 'critical';
  }

  Widget _vacantBody() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _Stone.available.withOpacity(0.1),
                border: Border.all(
                  color: _Stone.available.withOpacity(0.5),
                  width: 1.4,
                ),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.local_florist_outlined,
                color: _Stone.available,
                size: 30,
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'This niche is available',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _Stone.parchment,
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Inquire about reserving Cluster ${widget.cluster}, '
            'Column ${widget.column}, Row ${widget.row}.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _Stone.parchment.withOpacity(0.55),
              fontSize: 12.5,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 22),
          Container(height: 1, color: _Stone.divider),
          const SizedBox(height: 20),

          _fieldLabel('YOUR NAME'),
          const SizedBox(height: 6),
          _field(
            controller: _nameCtrl,
            hint: 'Juan Dela Cruz',
          ),
          const SizedBox(height: 14),

          _fieldLabel('EMAIL ADDRESS'),
          const SizedBox(height: 6),
          _field(
            controller: _emailCtrl,
            hint: 'you@example.com',
            keyboard: TextInputType.emailAddress,
          ),
          const SizedBox(height: 14),

          _fieldLabel('PHONE (OPTIONAL)'),
          const SizedBox(height: 6),
          _field(
            controller: _phoneCtrl,
            hint: '+63 900 000 0000',
            keyboard: TextInputType.phone,
          ),
          const SizedBox(height: 14),

          _fieldLabel('MESSAGE (OPTIONAL)'),
          const SizedBox(height: 6),
          _field(
            controller: _msgCtrl,
            hint: 'I would like to know more about this niche…',
            maxLines: 3,
          ),
          const SizedBox(height: 20),

          if (_submitted)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _Stone.available.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: _Stone.available.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: _Stone.available, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Inquiry received. We'll contact you shortly.",
                      style: TextStyle(
                        color: _Stone.parchment,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            FilledButton.icon(
              onPressed: _onSubmitInquiry,
              style: FilledButton.styleFrom(
                backgroundColor: _Stone.parchment,
                foregroundColor: _Stone.inkDeep,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              icon: const Icon(Icons.send_outlined, size: 18),
              label: const Text(
                'SEND INQUIRY',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                ),
              ),
            ),

          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: _Stone.parchment.withOpacity(0.7),
              ),
              child: const Text('Cancel'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fieldLabel(String t) => Text(
        t,
        style: TextStyle(
          color: _Stone.inkFaint.withOpacity(0.9),
          fontSize: 9.5,
          letterSpacing: 2.4,
          fontWeight: FontWeight.w700,
        ),
      );

  Widget _field({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboard,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      maxLines: maxLines,
      style: const TextStyle(color: _Stone.parchment, fontSize: 13.5),
      cursorColor: _Stone.parchment,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: _Stone.inkFaint.withOpacity(0.6),
          fontSize: 13,
        ),
        filled: true,
        fillColor: Colors.black.withOpacity(0.3),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: _Stone.divider, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: _Stone.divider, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: _Stone.available, width: 1.4),
        ),
      ),
    );
  }

  Future<void> _onSubmitInquiry() async {
    HapticFeedback.mediumImpact();

    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final message = _msgCtrl.text.trim();

    if (name.isEmpty) {
      _snack('Please enter your name.');
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      _snack('Please enter a valid email address.');
      return;
    }

    debugPrint(
      'Inquiry (preview only) → CL${widget.cluster}-C${widget.column}-R${widget.row} '
      '· $name · $email · $phone · $message',
    );

    setState(() => _submitted = true);
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }
}

class _PhotoPane extends StatelessWidget {
  const _PhotoPane({required this.url});
  final String? url;

  @override
  Widget build(BuildContext context) {
    final hasUrl = url != null && url!.trim().isNotEmpty;
    return Center(
      child: Container(
        width: 150,
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: _Stone.slabEdge.withOpacity(0.7), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.6),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_Stone.slabTop, _Stone.slabMid, _Stone.slabBottom],
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: hasUrl
              ? StoredPhoto(
                  url: url!,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  placeholder: _fallback(label: false),
                )
              : _fallback(label: true),
        ),
      ),
    );
  }

  Widget _fallback({required bool label}) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_outline,
              size: 46, color: _Stone.inkFaint.withOpacity(0.6)),
          if (label) ...[
            const SizedBox(height: 6),
            Text(
              'NO PORTRAIT',
              style: TextStyle(
                color: _Stone.inkFaint.withOpacity(0.7),
                fontSize: 9.5,
                letterSpacing: 2.4,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}