// ============================================================================
// grave_list.dart
// ============================================================================
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../components/data.dart';
import '../components/sync_service.dart';

const int kGravesPerPage = 20;

enum _Filter { all, occupied, reserved, vacant }

class GraveListPage extends StatefulWidget {
  const GraveListPage({super.key});

  @override
  State<GraveListPage> createState() => _GraveListPageState();
}

class _GraveListPageState extends State<GraveListPage> {
  final ScrollController _scroll = ScrollController();
  final TextEditingController _searchCtrl = TextEditingController();

  List<_Entry> _all = const [];
  List<_Entry> _filtered = const [];
  _Filter _filter = _Filter.all;
  String _query = '';
  int _page = 0;

  @override
  void initState() {
    super.initState();
    SyncService.start();
    _buildEntries();
    _applyFilter();
    MemorialRepository.version.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    MemorialRepository.version.removeListener(_onDataChanged);
    _scroll.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onDataChanged() {
    if (!mounted) return;
    setState(() {
      _buildEntries();
      _applyFilter(keepPage: true);
    });
  }

  void _buildEntries() {
    final entries = MemorialRepository.allRecords.map(_Entry.new).toList();
    entries.sort((a, b) {
      if (a.rank != b.rank) return a.rank.compareTo(b.rank);
      if (a.record.isOccupied) {
        return a.nameLower.compareTo(b.nameLower);
      }
      return _compareNums(a.nums, b.nums);
    });
    _all = entries;
  }

  void _applyFilter({bool keepPage = false}) {
    final q = _query.trim().toLowerCase();
    _filtered = _all.where((e) {
      final okFilter = switch (_filter) {
        _Filter.all => true,
        _Filter.occupied => e.record.isOccupied,
        _Filter.reserved => e.record.isReserved,
        _Filter.vacant => !e.record.isOccupied && !e.record.isReserved,
      };
      if (!okFilter) return false;
      if (q.isEmpty) return true;
      return e.nameLower.contains(q) || e.keyLower.contains(q);
    }).toList();

    if (!keepPage) _page = 0;
    final last = _pageCount - 1;
    if (_page > last) _page = last;
  }

  int get _pageCount {
    final n = (_filtered.length / kGravesPerPage).ceil();
    return n < 1 ? 1 : n;
  }

  void _goToPage(int page) {
    final target = page.clamp(0, _pageCount - 1);
    if (target == _page) return;
    setState(() => _page = target);
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  Future<void> _askPage() async {
    final ctrl = TextEditingController();
    final result = await showDialog<int>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.white,
        title: const Text(
          'Go to page',
          style: TextStyle(
            color: AppColors.navy,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: '1 to $_pageCount',
            border: const OutlineInputBorder(),
          ),
          onSubmitted: (v) =>
              Navigator.of(dialogContext).pop(int.tryParse(v.trim())),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext)
                .pop(int.tryParse(ctrl.text.trim())),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.navy,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Go'),
          ),
        ],
      ),
    );
    ctrl.dispose();
    if (result != null) _goToPage(result - 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: const Text(
          'GRAVE LIST',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 3,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.navy,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearch(),
          _buildFilters(),
          Expanded(child: _buildBody()),
          if (_filtered.isNotEmpty) _buildPager(),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        controller: _searchCtrl,
        textInputAction: TextInputAction.search,
        onChanged: (v) => setState(() {
          _query = v;
          _applyFilter();
          if (_scroll.hasClients) _scroll.jumpTo(0);
        }),
        decoration: InputDecoration(
          hintText: 'Search by name or plot code',
          hintStyle: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 14,
          ),
          prefixIcon: const Icon(Icons.search, color: AppColors.navy),
          suffixIcon: _query.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => setState(() {
                    _searchCtrl.clear();
                    _query = '';
                    _applyFilter();
                  }),
                ),
          filled: true,
          fillColor: AppColors.offWhite,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    Widget chip(String label, _Filter value) {
      final selected = _filter == value;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text(label),
          selected: selected,
          showCheckmark: false,
          selectedColor: AppColors.navy,
          backgroundColor: AppColors.offWhite,
          labelStyle: TextStyle(
            color: selected ? AppColors.white : AppColors.navy,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
          side: BorderSide(color: AppColors.navy.withOpacity(0.12)),
          onSelected: (_) => setState(() {
            _filter = value;
            _applyFilter();
            if (_scroll.hasClients) _scroll.jumpTo(0);
          }),
        ),
      );
    }

    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            chip('All', _Filter.all),
            chip('Occupied', _Filter.occupied),
            chip('Reserved', _Filter.reserved),
            chip('Vacant', _Filter.vacant),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    return AnimatedBuilder(
      animation: Listenable.merge([
        MemorialRepository.loading,
        MemorialRepository.error,
      ]),
      builder: (context, _) {
        final loading = MemorialRepository.loading.value;
        final error = MemorialRepository.error.value;

        if (!MemorialRepository.hasData) {
          if (loading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.navy),
            );
          }
          return _EmptyState(
            icon: Icons.cloud_off_outlined,
            title: 'No records yet',
            message: error ?? 'Records have not been loaded.',
            actionLabel: 'TRY AGAIN',
            onAction: () => MemorialRepository.load(),
          );
        }

        if (_filtered.isEmpty) {
          return const _EmptyState(
            icon: Icons.search_off,
            title: 'No graves found',
            message: 'Try a different name, plot code or filter.',
          );
        }

        final start = _page * kGravesPerPage;
        final end = (start + kGravesPerPage).clamp(0, _filtered.length);
        final pageItems = _filtered.sublist(start, end);

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Showing ${start + 1} to $end of ${_fmt(_filtered.length)}',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (loading)
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.navy,
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                controller: _scroll,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                itemCount: pageItems.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) => _GraveTile(
                  entry: pageItems[i],
                  onTap: () => _showDetails(pageItems[i]),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPager() {
    final canPrev = _page > 0;
    final canNext = _page < _pageCount - 1;

    Widget navButton(IconData icon, bool enabled, VoidCallback onTap) {
      return IconButton(
        onPressed: enabled ? onTap : null,
        icon: Icon(icon),
        color: AppColors.navy,
        disabledColor: AppColors.navy.withOpacity(0.2),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(color: AppColors.navy.withOpacity(0.08)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  navButton(Icons.first_page, canPrev, () => _goToPage(0)),
                  navButton(
                    Icons.chevron_left,
                    canPrev,
                    () => _goToPage(_page - 1),
                  ),
                ],
              ),
              InkWell(
                onTap: _askPage,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Text(
                    'Page ${_page + 1} of ${_fmt(_pageCount)}',
                    style: const TextStyle(
                      color: AppColors.navy,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  navButton(
                    Icons.chevron_right,
                    canNext,
                    () => _goToPage(_page + 1),
                  ),
                  navButton(
                    Icons.last_page,
                    canNext,
                    () => _goToPage(_pageCount - 1),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetails(_Entry e) {
    final r = e.record;
    final style = _statusStyle(r);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        builder: (context, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.navy.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (r.photoUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  height: 220,
                  width: double.infinity,
                  child: CachedNetworkImage(
                    imageUrl: r.photoUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        Container(color: AppColors.lightBlueGray),
                    errorWidget: (_, __, ___) => Container(
                      color: AppColors.lightBlueGray,
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: AppColors.navy.withOpacity(0.35),
                        size: 40,
                      ),
                    ),
                  ),
                ),
              ),
            if (r.photoUrl != null) const SizedBox(height: 16),
            _StatusBadge(label: style.$1, color: style.$2),
            const SizedBox(height: 10),
            Text(
              r.isOccupied ? r.name! : _placeholderTitle(r),
              style: const TextStyle(
                color: AppColors.navy,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _yearsText(r),
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _DetailRow(
              icon: Icons.place_outlined,
              title: 'Location',
              value: e.locationText,
            ),
            if (r.leaseYears != null)
              _DetailRow(
                icon: Icons.event_available_outlined,
                title: 'Lease',
                value: r.leaseStatus == null
                    ? '${r.leaseYears} years'
                    : '${r.leaseYears} years, ${r.leaseStatus}',
              ),
            if (r.quote != null) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.lightBlueGray,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '"${r.quote}"',
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    height: 1.5,
                  ),
                ),
              ),
            ],
            if (r.notes != null) ...[
              const SizedBox(height: 12),
              Text(
                r.notes!,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 13.5,
                  height: 1.5,
                ),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(sheetContext).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navy,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'CLOSE',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Entry {
  _Entry(this.record)
      : nameLower = (record.name ?? '').toLowerCase(),
        keyLower = (record.key ?? '').toLowerCase(),
        nums = _numbersIn(record.key ?? ''),
        rank = record.isOccupied ? 0 : (record.isReserved ? 1 : 2);

  final MemorialRecord record;
  final String nameLower;
  final String keyLower;
  final List<int> nums;
  final int rank;

  String get locationText {
    if (nums.length >= 3) {
      return 'Cluster ${nums[0]}, Column ${nums[1]}, Row ${nums[2]}';
    }
    return record.key ?? 'Unknown location';
  }
}

List<int> _numbersIn(String s) =>
    RegExp(r'\d+').allMatches(s).map((m) => int.parse(m.group(0)!)).toList();

int _compareNums(List<int> a, List<int> b) {
  final n = a.length < b.length ? a.length : b.length;
  for (int i = 0; i < n; i++) {
    if (a[i] != b[i]) return a[i].compareTo(b[i]);
  }
  return a.length.compareTo(b.length);
}

String _fmt(int n) {
  final s = n.toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return buf.toString();
}

String? _year(String? raw) {
  if (raw == null) return null;
  return RegExp(r'\d{4}').firstMatch(raw)?.group(0) ?? raw;
}

String _yearsText(MemorialRecord r) {
  final b = _year(r.birthDate);
  final d = _year(r.deathDate);
  if (b != null && d != null) return '$b to $d';
  if (d != null) return 'Died $d';
  if (b != null) return 'Born $b';
  return 'Dates not recorded';
}

String _placeholderTitle(MemorialRecord r) =>
    r.isReserved ? 'Reserved plot' : 'Vacant plot';

(String, Color) _statusStyle(MemorialRecord r) {
  if (r.isOccupied) return ('OCCUPIED', AppColors.navy);
  if (r.isReserved) return ('RESERVED', const Color(0xFFB7791F));
  return ('VACANT', AppColors.textMuted);
}

class _GraveTile extends StatelessWidget {
  const _GraveTile({required this.entry, required this.onTap});
  final _Entry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final r = entry.record;
    final style = _statusStyle(r);

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.navy.withOpacity(0.08)),
          ),
          child: Row(
            children: [
              _Thumb(url: r.photoUrl, occupied: r.isOccupied),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.isOccupied ? r.name! : _placeholderTitle(r),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: r.isOccupied
                            ? AppColors.navy
                            : AppColors.textMuted,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _yearsText(r),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(
                          Icons.place_outlined,
                          size: 12,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            entry.locationText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _StatusBadge(label: style.$1, color: style.$2, small: true),
            ],
          ),
        ),
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.url, required this.occupied});
  final String? url;
  final bool occupied;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      color: AppColors.lightBlueGray,
      child: Icon(
        occupied ? Icons.person_outline : Icons.crop_square,
        color: AppColors.navy.withOpacity(0.35),
        size: 28,
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 56,
        height: 56,
        child: url == null
            ? placeholder
            : CachedNetworkImage(
                imageUrl: url!,
                fit: BoxFit.cover,
                memCacheWidth: 160,
                placeholder: (_, __) => placeholder,
                errorWidget: (_, __, ___) => placeholder,
              ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    required this.color,
    this.small = false,
  });
  final String label;
  final Color color;
  final bool small;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 7 : 10,
        vertical: small ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: small ? 8.5 : 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.title,
    required this.value,
  });
  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.navy.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.navy, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 52, color: AppColors.navy.withOpacity(0.3)),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.navy,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navy,
                  foregroundColor: AppColors.white,
                ),
                child: Text(
                  actionLabel!,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}