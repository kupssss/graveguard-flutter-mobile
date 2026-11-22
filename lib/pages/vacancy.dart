// ============================================================================
// vacancy.dart
// ============================================================================
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../components/data.dart';
import '../components/niche_detail_modal.dart';

const Color _kAvailable = Color(0xFF2E7D32);

class _Plot {
  const _Plot(this.cluster, this.column, this.row);
  final int cluster;
  final int column;
  final int row;
}

final RegExp _keyPattern = RegExp(r'^CL(\d+)-C(\d+)-R(\d+)$');

/// Every vacant niche the server knows about, sorted by cluster, column, row.
List<_Plot> _vacantPlots() {
  final out = <_Plot>[];
  for (final r in MemorialRepository.allRecords) {
    if (r.isOccupied || r.status != NicheStatus.vacant) continue;
    final m = _keyPattern.firstMatch(r.key ?? '');
    if (m == null) continue;
    out.add(_Plot(
      int.parse(m.group(1)!),
      int.parse(m.group(2)!),
      int.parse(m.group(3)!),
    ));
  }
  out.sort((a, b) {
    final c = a.cluster.compareTo(b.cluster);
    if (c != 0) return c;
    final col = a.column.compareTo(b.column);
    if (col != 0) return col;
    return a.row.compareTo(b.row);
  });
  return out;
}

class VacancyPage extends StatefulWidget {
  const VacancyPage({super.key});

  @override
  State<VacancyPage> createState() => _VacancyPageState();
}

class _VacancyPageState extends State<VacancyPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  int? _cluster; // null = show every cluster

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    // Make sure we have data even if the user came straight here.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !MemorialRepository.hasData) MemorialRepository.load();
    });
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  void _openPlot(_Plot p) {
    showNicheDetailModal(
      context,
      cluster: p.cluster,
      column: p.column,
      row: p.row,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: const Text('Vacant Plots'),
        backgroundColor: AppColors.navy,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      body: ValueListenableBuilder<int>(
        valueListenable: MemorialRepository.version,
        builder: (context, _, __) {
          return ValueListenableBuilder<bool>(
            valueListenable: MemorialRepository.loading,
            builder: (context, loading, __) {
              final all = _vacantPlots();
              if (all.isEmpty) return _buildEmpty(loading);
              return _buildContent(all);
            },
          );
        },
      ),
    );
  }

  // --------------------------------------------------------------------------
  // Content
  // --------------------------------------------------------------------------
  Widget _buildContent(List<_Plot> all) {
    final counts = <int, int>{};
    for (final p in all) {
      counts[p.cluster] = (counts[p.cluster] ?? 0) + 1;
    }
    final clusters = counts.keys.toList()..sort();

    final int? selected =
        (_cluster != null && counts.containsKey(_cluster)) ? _cluster : null;
    final shown = selected == null
        ? all
        : all.where((p) => p.cluster == selected).toList();

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: _buildHeader(all.length)),
        SliverToBoxAdapter(child: _buildSectionTitle(shown.length)),
        SliverToBoxAdapter(
          child: _buildFilters(clusters, counts, all.length, selected),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                final p = shown[i];
                return _PlotCard(
                  key: ValueKey('${p.cluster}_${p.column}_${p.row}'),
                  plot: p,
                  index: i,
                  pulse: _pulse,
                  onTap: () => _openPlot(p),
                );
              },
              childCount: shown.length,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.95,
            ),
          ),
        ),
        SliverToBoxAdapter(child: _buildFooterNote()),
      ],
    );
  }

  Widget _buildHeader(int total) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.navy,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.navy.withOpacity(0.18),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AnimatedBuilder(
                  animation: _pulse,
                  builder: (context, _) => Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.accentRed
                          .withOpacity(0.4 + 0.6 * _pulse.value),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'AVAILABLE NOW',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.75),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.4,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: total.toDouble()),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutCubic,
                  builder: (context, v, _) => Text(
                    '${v.round()}',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Text(
                      'vacant plots ready to reserve',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Find a place that feels right for your family. Choose a plot, '
              'leave your details, and our team will take care of the rest.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.78),
                fontSize: 13,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.verified_outlined,
                  size: 14,
                  color: Colors.white.withOpacity(0.7),
                ),
                const SizedBox(width: 6),
                Text(
                  'Free to inquire · No commitment',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(int shownCount) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 10),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              color: AppColors.accentRed,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'CHOOSE YOUR PLOT',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.8,
            ),
          ),
          const Spacer(),
          Text(
            '$shownCount shown',
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(
    List<int> clusters,
    Map<int, int> counts,
    int total,
    int? selected,
  ) {
    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _filterChip('All  $total', selected == null,
              () => setState(() => _cluster = null)),
          for (final c in clusters) ...[
            const SizedBox(width: 8),
            _filterChip('Cluster $c  ${counts[c]}', selected == c,
                () => setState(() => _cluster = c)),
          ],
        ],
      ),
    );
  }

  Widget _filterChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.navy : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppColors.navy
                : AppColors.navy.withOpacity(0.15),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.white : AppColors.navy,
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildFooterNote() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.lightBlueGray,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.navy.withOpacity(0.08)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppColors.navy,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chat_bubble_outline,
                color: AppColors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Not sure yet? Tap any plot to ask a question. There is no '
                'payment needed to inquire.',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // Empty / loading
  // --------------------------------------------------------------------------
  Widget _buildEmpty(bool loading) {
    if (loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.navy),
      );
    }

    final noData = !MemorialRepository.hasData;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.landscape_outlined,
              size: 56,
              color: AppColors.navy.withOpacity(0.4),
            ),
            const SizedBox(height: 14),
            Text(
              noData
                  ? 'We could not load the plots'
                  : 'Every plot is taken right now',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.navy,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              noData
                  ? 'Check your connection and try again.'
                  : 'Please check back soon for newly available plots.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            if (noData) ...[
              const SizedBox(height: 18),
              FilledButton(
                onPressed: MemorialRepository.load,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.navy,
                  foregroundColor: AppColors.white,
                ),
                child: const Text('Try again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// Plot card
// ============================================================================
class _PlotCard extends StatefulWidget {
  const _PlotCard({
    super.key,
    required this.plot,
    required this.index,
    required this.pulse,
    required this.onTap,
  });

  final _Plot plot;
  final int index;
  final Animation<double> pulse;
  final VoidCallback onTap;

  @override
  State<_PlotCard> createState() => _PlotCardState();
}

class _PlotCardState extends State<_PlotCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.plot;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 350 + (widget.index % 8) * 60),
      curve: Curves.easeOutCubic,
      builder: (context, v, child) => Opacity(
        opacity: v.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, 18 * (1 - v)),
          child: child,
        ),
      ),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        scale: _pressed ? 0.97 : 1.0,
        child: Material(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          elevation: _pressed ? 1 : 2,
          shadowColor: AppColors.navy.withOpacity(0.15),
          child: InkWell(
            onTap: widget.onTap,
            onTapDown: (_) => setState(() => _pressed = true),
            onTapCancel: () => setState(() => _pressed = false),
            onTapUp: (_) => setState(() => _pressed = false),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.navy.withOpacity(0.08)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _kAvailable.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.local_florist_outlined,
                          color: _kAvailable,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: AnimatedBuilder(
                        animation: widget.pulse,
                        builder: (context, _) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _kAvailable.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: _kAvailable.withOpacity(
                                      0.4 + 0.6 * widget.pulse.value),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              const Text(
                                'AVAILABLE',
                                style: TextStyle(
                                  color: _kAvailable,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CLUSTER ${p.cluster}',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.6,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Column ${p.column}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.navy,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          height: 1.15,
                        ),
                      ),
                      Text(
                        'Row ${p.row}',
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Reserve this plot',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.accentRed,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.accentRed.withOpacity(0.10),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          color: AppColors.accentRed,
                          size: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}