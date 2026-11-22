// ============================================================================
// home.dart
// ============================================================================
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../theme/app_theme.dart';
import '../components/pathfinder.dart';
import '../components/route_search.dart';
import '../components/sync_service.dart';
import 'maps.dart';
import 'history.dart';
import 'grave_list.dart';
import 'media.dart';
import 'vacancy.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  Timer? _clockTimer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();

    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fade = CurvedAnimation(parent: _entrance, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entrance, curve: Curves.easeOutCubic));
    _entrance.forward();

    _clockTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });

    SyncService.start();
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _entrance.dispose();
    super.dispose();
  }

  static const List<_Stat> _stats = [
    _Stat(icon: Icons.grid_view_rounded, label: 'CLUSTERS', value: '24'),
    _Stat(icon: Icons.view_column_outlined, label: 'COLUMNS', value: '312'),
    _Stat(icon: Icons.person_pin_circle_outlined, label: 'GRAVES', value: '4.8k'),
    _Stat(icon: Icons.history_toggle_off, label: 'EST.', value: '1903'),
  ];

  static const List<String> _announcements = [
    '🎄 Simbang Gabi masses begin Dec 16 at the Main Chapel, 5:00 AM. Families and visitors are welcome.',
    '🕯️ Candlelight Remembrance for families — Dec 20, 5:30 PM at the North Grounds. Please bring your own candles.',
    '🧹 Volunteer grounds cleanup — Dec 6, 8:00 AM at Cluster A. Gloves and bags will be provided.',
    '🕰️ Extended visiting hours on Dec 24 and Dec 31: 6 AM – 8 PM. Gates will close promptly at closing time.',
    '🗺️ Map updated: new columns registered in Cluster G. Tap MAP on the home screen to view the latest layout.',
  ];

  static const List<_Notable> _notables = [
    _Notable(
      name: 'Elpidio Quirino',
      years: '1890 – 1956',
      role: '6th President of the Philippines',
      image: 'assets/images/notable_1.jpg',
    ),
    _Notable(
      name: 'Lope K. Santos',
      years: '1879 – 1963',
      role: 'Novelist · Father of Filipino Grammar',
      image: 'assets/images/notable_2.jpg',
    ),
    _Notable(
      name: 'Lucrecia Kasilag',
      years: '1918 – 2008',
      role: 'National Artist for Music',
      image: 'assets/images/notable_3.jpg',
    ),
    _Notable(
      name: 'Espiridiona Bonifacio',
      years: '1875 – 1956',
      role: 'Revolutionary · Sister of Andrés Bonifacio',
      image: 'assets/images/notable_4.jpg',
    ),
    _Notable(
      name: 'Ramon Bagatsing',
      years: '1916 – 2006',
      role: 'Longest-serving Mayor of Manila',
      image: 'assets/images/notable_5.jpg',
    ),
    _Notable(
      name: 'Paraluman',
      years: '1923 – 2009',
      role: 'Actress of the 1950s',
      image: 'assets/images/notable_6.jpg',
    ),
  ];

  static const List<_Event> _events = [
    _Event(
      day: '01',
      month: 'DEC',
      year: '2026',
      title: 'Advent Memorial Mass',
      time: '6:00 AM · Main Chapel',
    ),
    _Event(
      day: '06',
      month: 'DEC',
      year: '2026',
      title: 'Volunteer Grounds Cleanup',
      time: '8:00 AM · Cluster A',
    ),
    _Event(
      day: '08',
      month: 'DEC',
      year: '2026',
      title: 'Immaculate Conception Mass',
      time: '6:30 AM · Main Chapel',
    ),
    _Event(
      day: '12',
      month: 'DEC',
      year: '2026',
      title: 'Heritage Walking Tour',
      time: '9:00 AM · Gate 2',
    ),
    _Event(
      day: '16',
      month: 'DEC',
      year: '2026',
      title: 'Simbang Gabi Opening Mass',
      time: '5:00 AM · Main Chapel',
    ),
    _Event(
      day: '20',
      month: 'DEC',
      year: '2026',
      title: 'Candlelight Remembrance',
      time: '5:30 PM · North Grounds',
    ),
    _Event(
      day: '24',
      month: 'DEC',
      year: '2026',
      title: 'Christmas Eve Blessing of Graves',
      time: '4:00 PM · Main Chapel',
    ),
    _Event(
      day: '30',
      month: 'DEC',
      year: '2026',
      title: 'Rizal Day Wreath-Laying',
      time: '8:00 AM · Heroes\' Section',
    ),
    _Event(
      day: '31',
      month: 'DEC',
      year: '2026',
      title: 'Year-End Thanksgiving Prayer',
      time: '5:00 PM · Main Chapel',
    ),
    _Event(
      day: '10',
      month: 'JAN',
      year: '2027',
      title: 'Heritage Photo Exhibit',
      time: '9:00 AM · Main Chapel Hall',
    ),
  ];

  void _openMaps() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const MapsPage()),
    );
  }

  void _openVacancy() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const VacancyPage()),
    );
  }

  void _openPage(Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  void _openMapsWithHit(SearchHit hit) {
    FocusManager.instance.primaryFocus?.unfocus();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => MapsPage(initialHit: hit)),
    );
  }

  Future<void> _refresh() async {
    await Future.delayed(const Duration(milliseconds: 700));
    if (mounted) setState(() => _now = DateTime.now());
  }

  void _showAllEvents() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.navy.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const _SectionTitle('UPCOMING EVENTS'),
                          const SizedBox(height: 4),
                          Padding(
                            padding: const EdgeInsets.only(left: 12),
                            child: Text(
                              '${_events.length} events scheduled',
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      icon: const Icon(Icons.close, color: AppColors.navy),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                  itemCount: _events.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _EventTile(event: _events[i]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _greeting() {
    final h = _now.hour;
    if (h < 12) return 'Good morning';
    if (h < 18) return 'Good afternoon';
    return 'Good evening';
  }

  String _formatTime() {
    final h = _now.hour % 12 == 0 ? 12 : _now.hour % 12;
    final m = _now.minute.toString().padLeft(2, '0');
    final ampm = _now.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $ampm';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: RefreshIndicator(
        color: AppColors.navy,
        onRefresh: _refresh,
        child: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            _buildHero(),
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fade,
                child: SlideTransition(
                  position: _slide,
                  child: Column(
                    children: [
                      _buildWelcomeCard(),
                      _buildVacancyBanner(),
                      _buildSearchBar(),
                      _buildStatsRow(),
                      _buildAnnouncements(),
                      _buildQuickActions(),
                      _buildNotables(),
                      _buildVisitInfo(),
                      _buildUpcomingEvents(),
                      _buildFooterInfo(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHero() {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 260,
      backgroundColor: AppColors.navy,
      foregroundColor: AppColors.white,
      elevation: 0,
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final double top = constraints.biggest.height;
          final double collapsedHeight =
              kToolbarHeight + MediaQuery.of(context).padding.top;
          final double t =
              ((top - collapsedHeight) / (260 - collapsedHeight))
                  .clamp(0.0, 1.0);
          final bool isCollapsed = t < 0.15;

          final String titleText = isCollapsed
              ? 'MANILA SOUTH CEMETERY'
              : 'MANILA SOUTH\nCEMETERY';
          final double fontSize = isCollapsed ? 14 : 16;
          final double letterSpacing = isCollapsed ? 1.5 : 2.5;

          return FlexibleSpaceBar(
            centerTitle: true,
            titlePadding: const EdgeInsets.only(
              left: 20,
              right: 20,
              bottom: 16,
            ),
            title: Text(
              titleText,
              textAlign: TextAlign.center,
              maxLines: 2,
              softWrap: true,
              style: TextStyle(
                color: AppColors.white,
                fontSize: fontSize,
                height: 1.15,
                fontWeight: FontWeight.w800,
                letterSpacing: letterSpacing,
                shadows: const [
                  Shadow(
                    color: Colors.black54,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
            background: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.navyDark, AppColors.navyLight],
                    ),
                  ),
                ),
                Image.asset(
                  'assets/images/banner.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
                Container(color: AppColors.navyLight.withOpacity(0.45)),
                SafeArea(
                  child: Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 60),
                      child: Container(
                        width: 110,
                        height: 110,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.white,
                          border: Border.all(
                            color: AppColors.accentRed,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.35),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.location_city,
                              color: AppColors.navy,
                              size: 42,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _greeting().toUpperCase(),
                style: const TextStyle(
                  color: AppColors.accentRed,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.accentRed,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _formatTime(),
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'GraveGuard',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Lets make Manila great again.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 15,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVacancyBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: _VacancyBanner(onTap: _openVacancy),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: RouteSearchBar(onHit: _openMapsWithHit),
    );
  }

  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Row(
        children: _stats
            .map(
              (s) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _StatTile(stat: s),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildAnnouncements() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.navy,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.accentRed,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.campaign_outlined,
                color: AppColors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _AnnouncementMarquee(items: _announcements),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('QUICK ACTIONS'),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 0.95,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _HomeActionCard(
                icon: Icons.map_outlined,
                label: 'MAP',
                subtitle: 'Browse the cemetery map',
                color: AppColors.navy,
                onTap: _openMaps,
              ),
              _HomeActionCard(
                icon: Icons.history_edu_outlined,
                label: 'HISTORY',
                subtitle: 'Learn the cemetery story',
                color: AppColors.navyLight,
                onTap: () => _openPage(const HistoryPage()),
              ),
              _HomeActionCard(
                icon: Icons.list_alt_outlined,
                label: 'GRAVE LIST',
                subtitle: 'Search recorded graves',
                color: AppColors.navy,
                onTap: () => _openPage(const GraveListPage()),
              ),
              _HomeActionCard(
                icon: Icons.perm_media_outlined,
                label: 'MEDIA',
                subtitle: 'Photos & updates',
                color: AppColors.accentRed,
                onTap: () => _openPage(const MediaPage()),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotables() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: _SectionTitle('NOTABLE GRAVES'),
          ),
          const SizedBox(height: 4),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Public figures buried at Manila South Cemetery.',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 11.5,
                height: 1.35,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _notables.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, i) =>
                  _NotableCard(notable: _notables[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisitInfo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('PLAN YOUR VISIT'),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.navy.withOpacity(0.08),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: const [
                _InfoRow(
                  icon: Icons.access_time,
                  title: 'Visiting Hours',
                  value: 'Daily · 6:00 AM – 8:00 PM',
                ),
                _InfoRowDivider(),
                _InfoRow(
                  icon: Icons.location_on_outlined,
                  title: 'Location',
                  value: 'Makati City, Metro Manila',
                ),
                _InfoRowDivider(),
                _InfoRow(
                  icon: Icons.phone_outlined,
                  title: 'Contact',
                  value: '+63 (2) 8888 1234',
                ),
                _InfoRowDivider(),
                _InfoRow(
                  icon: Icons.directions_bus_outlined,
                  title: 'Getting Here',
                  value: 'LRT-1 Quirino · Jeep to South Gate',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingEvents() {
    final preview = _events.take(3).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const _SectionTitle('UPCOMING EVENTS'),
              TextButton(
                onPressed: _showAllEvents,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.navy,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'See all',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...preview.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _EventTile(event: e),
              )),
        ],
      ),
    );
  }

  Widget _buildFooterInfo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.lightBlueGray,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.navy.withOpacity(0.08)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: AppColors.navy,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.info_outline,
                color: AppColors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Text(
                'Use the search above or the Map to locate clusters, columns, '
                'and individual grave plots inside the cemetery.',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 13.5,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat {
  const _Stat({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;
}

class _Notable {
  const _Notable({
    required this.name,
    required this.years,
    required this.role,
    required this.image,
  });
  final String name;
  final String years;
  final String role;
  final String image;
}

class _Event {
  const _Event({
    required this.day,
    required this.month,
    required this.year,
    required this.title,
    required this.time,
  });
  final String day;
  final String month;
  final String year;
  final String title;
  final String time;
}

class _AnnouncementMarquee extends StatefulWidget {
  const _AnnouncementMarquee({
    required this.items,
    this.speed = 40,
    this.gap = 48,
  });

  final List<String> items;
  final double speed;
  final double gap;

  @override
  State<_AnnouncementMarquee> createState() => _AnnouncementMarqueeState();
}

class _AnnouncementMarqueeState extends State<_AnnouncementMarquee>
    with SingleTickerProviderStateMixin {
  late final ScrollController _controller;
  Ticker? _ticker;
  Duration _lastElapsed = Duration.zero;
  bool _paused = false;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void dispose() {
    _ticker?.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    if (!mounted || !_ready || _paused || !_controller.hasClients) {
      _lastElapsed = elapsed;
      return;
    }
    final dt =
        (elapsed - _lastElapsed).inMicroseconds / 1e6;
    _lastElapsed = elapsed;
    if (dt <= 0) return;

    final max = _controller.position.maxScrollExtent;
    if (max <= 0) return;

    final next = _controller.offset + widget.speed * dt;
    if (next >= max) {
      _controller.jumpTo(0);
    } else {
      _controller.jumpTo(next);
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      ...widget.items,
      ...widget.items,
    ];

    return GestureDetector(
      onTap: () => setState(() => _paused = !_paused),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 20,
        child: LayoutBuilder(
          builder: (context, constraints) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && !_ready) setState(() => _ready = true);
            });

            return ListView.builder(
              controller: _controller,
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, i) => Padding(
                padding: EdgeInsets.only(
                  right: i == items.length - 1 ? 0 : widget.gap,
                ),
                child: Center(
                  child: Text(
                    items[i],
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
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
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.8,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.stat});
  final _Stat stat;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.navy.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          Icon(stat.icon, color: AppColors.navy, size: 20),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              stat.value,
              style: const TextStyle(
                color: AppColors.navy,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              stat.label,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeActionCard extends StatefulWidget {
  const _HomeActionCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  State<_HomeActionCard> createState() => _HomeActionCardState();
}

class _HomeActionCardState extends State<_HomeActionCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 120),
      scale: _pressed ? 0.97 : 1.0,
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        elevation: _pressed ? 1 : 2,
        shadowColor: AppColors.navy.withOpacity(0.15),
        child: InkWell(
          onTap: widget.onTap,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapCancel: () => setState(() => _pressed = false),
          onTapUp: (_) => setState(() => _pressed = false),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: widget.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(widget.icon, color: widget.color, size: 24),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.label,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Flexible(
                  child: Text(
                    widget.subtitle,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11.5,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NotableCard extends StatelessWidget {
  const _NotableCard({required this.notable});
  final _Notable notable;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.navy.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(color: AppColors.lightBlueGray),
                Image.asset(
                  notable.image,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Center(
                    child: Icon(
                      Icons.person_outline,
                      color: AppColors.navy.withOpacity(0.4),
                      size: 42,
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accentRed,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'HERO',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notable.name,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  notable.years,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  notable.role,
                  style: const TextStyle(
                    color: AppColors.accentRed,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
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
      padding: const EdgeInsets.symmetric(vertical: 10),
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

class _InfoRowDivider extends StatelessWidget {
  const _InfoRowDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: AppColors.navy.withOpacity(0.06),
    );
  }
}

class _EventTile extends StatelessWidget {
  const _EventTile({required this.event});
  final _Event event;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => _showEventDetails(context, event),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.navy.withOpacity(0.08)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.navy,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Text(
                      event.day,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      event.month,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: const TextStyle(
                        color: AppColors.navy,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule,
                          size: 12,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.time,
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.textMuted,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void _showEventDetails(BuildContext context, _Event e) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.navy.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '${e.month} ${e.day}, ${e.year}',
              style: const TextStyle(
                color: AppColors.accentRed,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              e.title,
              style: const TextStyle(
                color: AppColors.navy,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.schedule,
                  size: 16,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    e.time,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Join us for this special occasion. All are welcome. '
              'Please arrive 15 minutes early for seating.',
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 13.5,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
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
                  'GOT IT',
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

// ============================================================================
// VACANCY BANNER — animated "looking for a plot?" call-to-action
// ============================================================================
class _VacancyBanner extends StatefulWidget {
  const _VacancyBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_VacancyBanner> createState() => _VacancyBannerState();
}

class _VacancyBannerState extends State<_VacancyBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _loop;

  @override
  void initState() {
    super.initState();
    _loop = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();
  }

  @override
  void dispose() {
    _loop.dispose();
    super.dispose();
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.22)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _loop,
      builder: (context, _) {
        final t = _loop.value; // 0..1, loops
        final pulse = (math.sin(t * 2 * math.pi) + 1) / 2; // 0..1, smooth

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: AppColors.navy,
            border: Border.all(
              color: AppColors.accentRed.withOpacity(0.45 + 0.55 * pulse),
              width: 1.6,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.accentRed.withOpacity(0.18 + 0.22 * pulse),
                blurRadius: 16 + 14 * pulse,
                spreadRadius: 1 + 2 * pulse,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18.5),
            child: Stack(
              children: [
                // Floating emoji decorations
                Positioned(
                  right: 18,
                  top: 14 + 6 * pulse,
                  child: const Text('🕊️', style: TextStyle(fontSize: 34)),
                ),
                Positioned(
                  right: 22,
                  top: 62 - 4 * pulse,
                  child: Opacity(
                    opacity: 0.85,
                    child: const Text('🌿', style: TextStyle(fontSize: 22)),
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // "Limited vacancies" badge with blinking dot
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accentRed,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: Colors.white
                                    .withOpacity(0.35 + 0.65 * pulse),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'LIMITED VACANCIES',
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Padding(
                        padding: EdgeInsets.only(right: 56),
                        child: Text(
                          'Looking for a plot?',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            height: 1.1,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Give your loved ones a peaceful, well kept resting '
                        'place. Vacant plots are available now. Reserve '
                        'yours before they are gone. 🌹',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.88),
                          fontSize: 13.5,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _chip('Prime locations'),
                          _chip('Quick reservation'),
                          _chip('Family plots'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Transform.scale(
                        scale: 1 + 0.025 * pulse,
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: widget.onTap,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accentRed,
                              foregroundColor: AppColors.white,
                              elevation: 6,
                              shadowColor: AppColors.accentRed,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.landscape_rounded, size: 20),
                                const SizedBox(width: 8),
                                const Text(
                                  'FIND AN AVAILABLE PLOT',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.2,
                                    fontSize: 13.5,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Transform.translate(
                                  offset: Offset(4 * pulse, 0),
                                  child: const Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.verified_outlined,
                            size: 14,
                            color: Colors.white.withOpacity(0.7),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Free to browse · No commitment',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}