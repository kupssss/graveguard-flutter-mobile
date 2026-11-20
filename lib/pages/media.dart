// ============================================================================
// media.dart
// ============================================================================
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MediaPage extends StatefulWidget {
  const MediaPage({super.key});

  @override
  State<MediaPage> createState() => _MediaPageState();
}

class _MediaPageState extends State<MediaPage> {
  bool _showGrid = false;

  static const String _pageName = 'Manila South Cemetery';

  static const List<_Post> _posts = [
    _Post(
      image: 'assets/images/history/history_banner.jpg',
      label: 'Grounds',
      location: 'Main Grounds',
      caption:
          'Quiet mornings at the cemetery. Visitors are welcome every day '
          'from 6:00 AM to 8:00 PM.',
      time: '2 days ago',
    ),
    _Post(
      image: 'assets/images/history/history_chapel.jpg',
      label: 'Chapel',
      location: 'Main Chapel',
      caption:
          'The Main Chapel is ready for the season of memorial masses and '
          'remembrance services.',
      time: '4 days ago',
    ),
    _Post(
      image: 'assets/images/history/history_gate.jpg',
      label: 'Gate',
      location: 'Main Gate',
      caption:
          'The Main Gate, the starting point for visits and heritage '
          'walking tours.',
      time: '1 week ago',
    ),
    _Post(
      image: 'assets/images/history/history_heritage_graves.jpg',
      label: 'Heritage',
      location: 'Heritage Section',
      caption:
          'Restored heritage graves that carry the stories of earlier '
          'generations.',
      time: '2 weeks ago',
    ),
    _Post(
      image: 'assets/images/history/history_founding.jpg',
      label: 'Archive',
      location: 'From the Archives',
      caption:
          'A look back at the early days of the cemetery from our '
          'archive collection.',
      time: '3 weeks ago',
    ),
    _Post(
      image: 'assets/images/history/history_war_era.jpg',
      label: 'Then',
      location: 'From the Archives',
      caption:
          'A photo from a difficult chapter in our history, and the '
          'recovery that followed.',
      time: '1 month ago',
    ),
    _Post(
      image: 'assets/images/history/history_today.jpg',
      label: 'Today',
      location: 'Main Grounds',
      caption:
          'The cemetery today, cared for by staff, families and '
          'volunteers.',
      time: '1 month ago',
    ),
  ];

  void _openViewer(int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _PhotoViewer(posts: _posts, initialIndex: index),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text(
          'MEDIA',
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
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _buildProfile()),
          SliverToBoxAdapter(child: _buildHighlights()),
          SliverToBoxAdapter(child: _buildToggle()),
          if (_showGrid)
            SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, i) => GestureDetector(
                  onTap: () => _openViewer(i),
                  child: _PostImage(path: _posts[i].image),
                ),
                childCount: _posts.length,
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) => _PostCard(
                  post: _posts[i],
                  pageName: _pageName,
                  onImageTap: () => _openViewer(i),
                ),
                childCount: _posts.length,
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildProfile() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _Avatar(size: 78, ring: true),
              const SizedBox(width: 20),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _ProfileStat(value: '${_posts.length}', label: 'Posts'),
                    const _ProfileStat(value: '24', label: 'Clusters'),
                    const _ProfileStat(value: '4.8k', label: 'Graves'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            _pageName,
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Photos and updates from the grounds. Remembering those who '
            'came before us.',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlights() {
    return SizedBox(
      height: 98,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _posts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (_, i) {
          final p = _posts[i];
          return GestureDetector(
            onTap: () => _openViewer(i),
            child: SizedBox(
              width: 68,
              child: Column(
                children: [
                  Container(
                    width: 66,
                    height: 66,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.accentRed,
                        width: 2,
                      ),
                    ),
                    child: ClipOval(child: _PostImage(path: p.image)),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    p.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildToggle() {
    Widget tab(IconData icon, bool selected, VoidCallback onTap) {
      return Expanded(
        child: InkWell(
          onTap: onTap,
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: selected ? AppColors.navy : Colors.transparent,
                  width: 2,
                ),
              ),
            ),
            child: Icon(
              icon,
              size: 24,
              color: selected
                  ? AppColors.navy
                  : AppColors.textMuted.withOpacity(0.7),
            ),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(top: 6),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.navy.withOpacity(0.08)),
        ),
      ),
      child: Row(
        children: [
          tab(Icons.view_agenda_outlined, !_showGrid,
              () => setState(() => _showGrid = false)),
          tab(Icons.grid_on_rounded, _showGrid,
              () => setState(() => _showGrid = true)),
        ],
      ),
    );
  }
}

class _Post {
  const _Post({
    required this.image,
    required this.label,
    required this.location,
    required this.caption,
    required this.time,
  });
  final String image;
  final String label;
  final String location;
  final String caption;
  final String time;
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.size, this.ring = false});
  final double size;
  final bool ring;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.white,
        border: Border.all(
          color: ring ? AppColors.accentRed : AppColors.navy.withOpacity(0.1),
          width: ring ? 2.5 : 1,
        ),
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/logo.png',
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Icon(
            Icons.location_city,
            color: AppColors.navy,
            size: size * 0.45,
          ),
        ),
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.navy,
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _PostImage extends StatelessWidget {
  const _PostImage({required this.path, this.fit = BoxFit.cover});
  final String path;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: AppColors.lightBlueGray),
        Image.asset(
          path,
          fit: fit,
          errorBuilder: (_, __, ___) => Center(
            child: Icon(
              Icons.photo_outlined,
              color: AppColors.navy.withOpacity(0.35),
              size: 36,
            ),
          ),
        ),
      ],
    );
  }
}

class _PostCard extends StatelessWidget {
  const _PostCard({
    required this.post,
    required this.pageName,
    required this.onImageTap,
  });
  final _Post post;
  final String pageName;
  final VoidCallback onImageTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(color: AppColors.navy.withOpacity(0.06)),
          bottom: BorderSide(color: AppColors.navy.withOpacity(0.06)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Row(
              children: [
                const _Avatar(size: 38),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pageName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.navy,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        post.location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onImageTap,
            child: AspectRatio(
              aspectRatio: 4 / 5,
              child: _PostImage(path: post.image),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 13.5,
                  height: 1.45,
                ),
                children: [
                  TextSpan(
                    text: '$pageName  ',
                    style: const TextStyle(
                      color: AppColors.navy,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  TextSpan(text: post.caption),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 6, 14, 14),
            child: Text(
              post.time.toUpperCase(),
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoViewer extends StatefulWidget {
  const _PhotoViewer({required this.posts, required this.initialIndex});
  final List<_Post> posts;
  final int initialIndex;

  @override
  State<_PhotoViewer> createState() => _PhotoViewerState();
}

class _PhotoViewerState extends State<_PhotoViewer> {
  late final PageController _controller;
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.posts[_index];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          '${_index + 1} of ${widget.posts.length}',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: widget.posts.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (_, i) => InteractiveViewer(
                minScale: 1,
                maxScale: 4,
                child: Center(
                  child: Image.asset(
                    widget.posts[i].image,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.photo_outlined,
                      color: Colors.white54,
                      size: 64,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.location,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    post.caption,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}