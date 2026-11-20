// ============================================================================
// sync_popups.dart
// ============================================================================
import 'dart:async';

import 'package:flutter/material.dart';

import 'data.dart';
import 'sync_service.dart';

class _P {
  static const slabTop = Color(0xFFDCD7CE);
  static const slabBottom = Color(0xFFB3ADA2);
  static const edge = Color(0xFF7A7468);
  static const inkDeep = Color(0xFF25221D);
  static const inkSoft = Color(0xFF4A463F);
  static const green = Color(0xFF2E7D32);
  static const orange = Color(0xFFB85C00);
}

class _PopupCard extends StatelessWidget {
  const _PopupCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.message,
    this.extra,
    this.actions = const [],
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;
  final Widget? extra;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_P.slabTop, _P.slabBottom],
            ),
            border: Border.all(color: _P.edge.withOpacity(0.7), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.6),
                blurRadius: 30,
                spreadRadius: 2,
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(icon, size: 40, color: iconColor),
                const SizedBox(height: 12),
                Text(
                  title.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _P.inkDeep,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.4,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _P.inkSoft,
                    fontSize: 13.5,
                    height: 1.5,
                  ),
                ),
                if (extra != null) ...[const SizedBox(height: 14), extra!],
                if (actions.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      for (int i = 0; i < actions.length; i++) ...[
                        if (i > 0) const SizedBox(width: 8),
                        actions[i],
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _primaryBtn(String label, VoidCallback onTap) => FilledButton(
      onPressed: onTap,
      style: FilledButton.styleFrom(
        backgroundColor: _P.inkDeep,
        foregroundColor: const Color(0xFFE6E2D8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      child: Text(label,
          style: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1)),
    );

Widget _secondaryBtn(String label, VoidCallback onTap) => TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(foregroundColor: _P.inkSoft),
      child: Text(label,
          style: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1)),
    );

class OfflinePopup extends StatelessWidget {
  const OfflinePopup({super.key});

  @override
  Widget build(BuildContext context) {
    final has = MemorialRepository.hasData;
    return _PopupCard(
      icon: Icons.cloud_off,
      iconColor: _P.orange,
      title: "You're offline",
      message: has
          ? "You're currently offline. The data shown may not be up to date."
              '\n\nShowing the copy saved on '
              '${formatSynced(MemorialRepository.lastSynced.value)}.'
          : "You're currently offline and there is no saved data on this "
              'phone yet. Connect to the internet once to download the records.',
      actions: [_primaryBtn('OK', () => Navigator.of(context).pop())],
    );
  }
}

class OnlinePopup extends StatefulWidget {
  const OnlinePopup({super.key});

  @override
  State<OnlinePopup> createState() => _OnlinePopupState();
}

class _OnlinePopupState extends State<OnlinePopup> {
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _t = Timer(const Duration(seconds: 2), () {
      if (mounted && (ModalRoute.of(context)?.isCurrent ?? false)) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const _PopupCard(
      icon: Icons.cloud_done_outlined,
      iconColor: _P.green,
      title: 'Back online',
      message: 'Your connection has been restored.',
    );
  }
}

class UpdatePopup extends StatelessWidget {
  const UpdatePopup({super.key});

  @override
  Widget build(BuildContext context) {
    return _PopupCard(
      icon: Icons.system_update_alt,
      iconColor: _P.inkDeep,
      title: 'New data available',
      message: 'The memorial records were updated on the server.\n\n'
          'Install the new data now? It needs the internet and takes a few '
          'seconds. If you skip, the data saved on your phone '
          '(${formatSynced(MemorialRepository.lastSynced.value)}) stays '
          'available.',
      actions: [
        _secondaryBtn('LATER', () => Navigator.of(context).pop(false)),
        _primaryBtn('INSTALL NOW', () => Navigator.of(context).pop(true)),
      ],
    );
  }
}

class UpToDatePopup extends StatelessWidget {
  const UpToDatePopup({super.key});

  @override
  Widget build(BuildContext context) {
    return _PopupCard(
      icon: Icons.check_circle_outline,
      iconColor: _P.green,
      title: "You're up to date",
      message: 'You already have the latest memorial records. '
          'There is nothing new to install.\n\n'
          'Checked: ${formatSynced(DateTime.now())}\n'
          'Records saved on: '
          '${formatSynced(MemorialRepository.lastSynced.value)}',
      actions: [_primaryBtn('OK', () => Navigator.of(context).pop())],
    );
  }
}

class InstallingPopup extends StatelessWidget {
  const InstallingPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: ValueListenableBuilder<double>(
        valueListenable: SyncService.installProgress,
        builder: (context, p, _) => _PopupCard(
          icon: Icons.downloading,
          iconColor: _P.inkDeep,
          title: 'Installing update',
          message: p > 0
              ? 'Saving photos for offline use… ${(p * 100).round()}%'
              : 'Downloading records…',
          extra: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: p > 0 ? p : null,
              minHeight: 6,
              color: _P.inkDeep,
              backgroundColor: _P.inkDeep.withOpacity(0.15),
            ),
          ),
        ),
      ),
    );
  }
}

class SyncListener extends StatefulWidget {
  const SyncListener({super.key, required this.child});
  final Widget child;

  @override
  State<SyncListener> createState() => _SyncListenerState();
}

class _SyncListenerState extends State<SyncListener> {
  bool _offlineOpen = false;
  bool _updateOpen = false;

  @override
  void initState() {
    super.initState();
    SyncService.online.addListener(_onOnline);
    SyncService.updateAvailable.addListener(_onUpdate);
    SyncService.start();
  }

  @override
  void dispose() {
    SyncService.online.removeListener(_onOnline);
    SyncService.updateAvailable.removeListener(_onUpdate);
    super.dispose();
  }

  void _onOnline() {
    if (!mounted) return;

    if (!SyncService.online.value) {
      _showOffline();
      return;
    }

    if (_offlineOpen) {
      Navigator.of(context, rootNavigator: true).pop();
    }
    showDialog<void>(
      context: context,
      barrierColor: Colors.black38,
      builder: (_) => const OnlinePopup(),
    );
  }

  Future<void> _showOffline() async {
    if (_offlineOpen) return;
    _offlineOpen = true;
    await showDialog<void>(
      context: context,
      builder: (_) => const OfflinePopup(),
    );
    _offlineOpen = false;
  }

  Future<void> _onUpdate() async {
    if (!mounted || _updateOpen) return;
    if (SyncService.updateAvailable.value == null) return;
    _updateOpen = true;

    final nav = Navigator.of(context, rootNavigator: true);
    final messenger = ScaffoldMessenger.maybeOf(context);

    final install = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const UpdatePopup(),
    );

    if (install != true) {
      SyncService.dismissUpdate();
      _updateOpen = false;
      return;
    }
    if (!mounted) {
      _updateOpen = false;
      return;
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const InstallingPopup(),
    );

    final ok = await SyncService.installUpdate();
    if (nav.canPop()) nav.pop();

    messenger?.showSnackBar(
      SnackBar(
        content: Text(ok
            ? 'Records updated. Saved for offline use.'
            : 'Update failed. Your saved data is still available.'),
      ),
    );
    _updateOpen = false;
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: SyncService.online,
      builder: (context, on, _) {
        if (on) return const SizedBox.shrink();
        return Positioned(
          bottom: 56,
          left: 8,
          right: 8,
          child: Material(
            color: Colors.orange.shade800,
            elevation: 3,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.cloud_off, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AnimatedBuilder(
                      animation: Listenable.merge([
                        MemorialRepository.lastSynced,
                        SyncService.photosSaved,
                        SyncService.photosTotal,
                      ]),
                      builder: (context, _) {
                        final saved = SyncService.photosSaved.value;
                        final total = SyncService.photosTotal.value;
                        final photos =
                            total > 0 ? ' · photos $saved/$total' : '';
                        return Text(
                          MemorialRepository.hasData
                              ? 'Offline · data saved '
                                  '${formatSynced(MemorialRepository.lastSynced.value)}'
                                  '$photos'
                              : 'Offline · no saved data yet',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 13),
                        );
                      },
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
}

class PhotoSyncBanner extends StatelessWidget {
  const PhotoSyncBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        SyncService.online,
        SyncService.photosBusy,
        SyncService.photosSaved,
        SyncService.photosTotal,
      ]),
      builder: (context, _) {
        if (!SyncService.online.value || !SyncService.photosBusy.value) {
          return const SizedBox.shrink();
        }
        final saved = SyncService.photosSaved.value;
        final total = SyncService.photosTotal.value;
        return Positioned(
          bottom: 56,
          left: 8,
          right: 8,
          child: Material(
            color: const Color(0xFF25221D),
            elevation: 3,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Saving photos for offline use… $saved/$total',
                      style:
                          const TextStyle(color: Colors.white, fontSize: 13),
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
}