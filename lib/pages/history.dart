// ============================================================================
// history.dart
// ============================================================================
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  static const List<_Milestone> _timeline = [
    _Milestone(
      year: '1903',
      title: 'Founding of the Cemetery',
      body:
          'Manila South Cemetery is established as a public burial ground '
          'to serve the growing city and its surrounding communities.',
      image: 'assets/images/history/history_founding.jpg',
    ),
    _Milestone(
      year: '1920',
      title: 'Expansion of the Grounds',
      body:
          'New clusters and columns are opened as more families lay their '
          'loved ones to rest, shaping the layout that visitors know today.',
    ),
    _Milestone(
      year: '1945',
      title: 'Wartime and Recovery',
      body:
          'The cemetery endures a difficult period and is carefully '
          'restored by the community in the years that follow.',
      image: 'assets/images/history/history_war_era.jpg',
    ),
    _Milestone(
      year: '1960',
      title: 'Resting Place of Public Figures',
      body:
          'Presidents, writers, artists and revolutionaries are laid to '
          'rest here, making the grounds a living part of national memory.',
    ),
    _Milestone(
      year: '2000',
      title: 'Restoration of Heritage Graves',
      body:
          'Older graves and mausoleums receive restoration work so that '
          'future generations can continue to visit and learn from them.',
      image: 'assets/images/history/history_heritage_graves.jpg',
    ),
    _Milestone(
      year: '2026',
      title: 'GraveGuard Goes Digital',
      body:
          'Records, maps and search tools are brought together in one app '
          'to help families find their loved ones with ease.',
      image: 'assets/images/history/history_today.jpg',
    ),
  ];

  static const List<_Landmark> _landmarks = [
    _Landmark(
      name: 'The Main Chapel',
      description:
          'The heart of the grounds, where memorial masses and '
          'remembrance services are held throughout the year.',
      image: 'assets/images/history/history_chapel.jpg',
    ),
    _Landmark(
      name: 'The Main Gate',
      description:
          'The principal entrance and the starting point for most visits '
          'and heritage walking tours.',
      image: 'assets/images/history/history_gate.jpg',
    ),
    _Landmark(
      name: 'Heritage Graves',
      description:
          'Restored graves and older mausoleums that carry the stories '
          'of earlier generations.',
      image: 'assets/images/history/history_heritage_graves.jpg',
    ),
  ];

  static const List<_Figure> _figures = [
    _Figure(
      name: 'Elpidio Quirino',
      note: '6th President',
      image: 'assets/images/notable_1.jpg',
    ),
    _Figure(
      name: 'Lope K. Santos',
      note: 'Novelist',
      image: 'assets/images/notable_2.jpg',
    ),
    _Figure(
      name: 'Lucrecia Kasilag',
      note: 'National Artist',
      image: 'assets/images/notable_3.jpg',
    ),
    _Figure(
      name: 'Espiridiona Bonifacio',
      note: 'Revolutionary',
      image: 'assets/images/notable_4.jpg',
    ),
    _Figure(
      name: 'Ramon Bagatsing',
      note: 'Mayor of Manila',
      image: 'assets/images/notable_5.jpg',
    ),
    _Figure(
      name: 'Paraluman',
      note: 'Actress',
      image: 'assets/images/notable_6.jpg',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildHero(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildIntro(),
                _buildTimeline(),
                _buildLandmarks(),
                _buildFigures(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 240,
      backgroundColor: AppColors.navy,
      foregroundColor: AppColors.white,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        titlePadding: const EdgeInsets.only(bottom: 16),
        title: const Text(
          'HISTORY',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 3,
            shadows: [
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
              'assets/images/history/history_banner.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
            Container(color: AppColors.navyDark.withOpacity(0.45)),
          ],
        ),
      ),
    );
  }

  Widget _buildIntro() {
    return Container(
      width: double.infinity,
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
      child: const Column(
        children: [
          Text(
            'OUR STORY',
            style: TextStyle(
              color: AppColors.accentRed,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 4,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'A Resting Place for Generations',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              height: 1.2,
            ),
          ),
          SizedBox(height: 14),
          Text(
            'For more than a century, Manila South Cemetery has been the '
            'final home of families, heroes and everyday Filipinos. Its '
            'clusters, columns and quiet pathways hold the stories of the '
            'people who built the city and the nation.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('TIMELINE'),
          const SizedBox(height: 16),
          for (int i = 0; i < _timeline.length; i++)
            _TimelineTile(
              milestone: _timeline[i],
              isLast: i == _timeline.length - 1,
            ),
        ],
      ),
    );
  }

  Widget _buildLandmarks() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('HERITAGE LANDMARKS'),
          const SizedBox(height: 16),
          for (final l in _landmarks)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _LandmarkCard(landmark: l),
            ),
        ],
      ),
    );
  }

  Widget _buildFigures() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: _SectionTitle('FIGURES OF HISTORY'),
          ),
          const SizedBox(height: 4),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Public figures who rest at Manila South Cemetery.',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 11.5,
                height: 1.35,
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 150,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _figures.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (_, i) => _FigureAvatar(figure: _figures[i]),
            ),
          ),
        ],
      ),
    );
  }
}

class _Milestone {
  const _Milestone({
    required this.year,
    required this.title,
    required this.body,
    this.image,
  });
  final String year;
  final String title;
  final String body;
  final String? image;
}

class _Landmark {
  const _Landmark({
    required this.name,
    required this.description,
    required this.image,
  });
  final String name;
  final String description;
  final String image;
}

class _Figure {
  const _Figure({
    required this.name,
    required this.note,
    required this.image,
  });
  final String name;
  final String note;
  final String image;
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

class _HistoryImage extends StatelessWidget {
  const _HistoryImage({required this.path, required this.height});
  final String path;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(color: AppColors.lightBlueGray),
          Image.asset(
            path,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Center(
              child: Icon(
                Icons.photo_outlined,
                color: AppColors.navy.withOpacity(0.35),
                size: 40,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineTile extends StatelessWidget {
  const _TimelineTile({required this.milestone, required this.isLast});
  final _Milestone milestone;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                const SizedBox(height: 4),
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: AppColors.accentRed,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentRed.withOpacity(0.35),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: AppColors.navy.withOpacity(0.15),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.navy.withOpacity(0.08),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (milestone.image != null)
                      _HistoryImage(path: milestone.image!, height: 140),
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            milestone.year,
                            style: const TextStyle(
                              color: AppColors.accentRed,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            milestone.title,
                            style: const TextStyle(
                              color: AppColors.navy,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            milestone.body,
                            style: const TextStyle(
                              color: AppColors.textDark,
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LandmarkCard extends StatelessWidget {
  const _LandmarkCard({required this.landmark});
  final _Landmark landmark;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HistoryImage(path: landmark.image, height: 160),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  landmark.name,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  landmark.description,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                    height: 1.5,
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

class _FigureAvatar extends StatelessWidget {
  const _FigureAvatar({required this.figure});
  final _Figure figure;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 92,
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.lightBlueGray,
              border: Border.all(color: AppColors.accentRed, width: 2),
            ),
            child: ClipOval(
              child: Image.asset(
                figure.image,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.person_outline,
                  color: AppColors.navy.withOpacity(0.4),
                  size: 34,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            figure.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            figure.note,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}