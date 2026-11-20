// ============================================================================
// sync_service.dart
// ============================================================================
import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'data.dart';
import 'photo_store.dart';

class PhotoCache {
  static final CacheManager manager = CacheManager(
    Config(
      'memorial_photos',
      stalePeriod: const Duration(days: 365),
      maxNrOfCacheObjects: 10000,
    ),
  );
}

class SyncService with WidgetsBindingObserver {
  SyncService._();
  static final SyncService _instance = SyncService._();

  static final ValueNotifier<bool> online = ValueNotifier<bool>(true);

  static final ValueNotifier<String?> updateAvailable =
      ValueNotifier<String?>(null);

  static final ValueNotifier<bool> installing = ValueNotifier<bool>(false);
  static final ValueNotifier<double> installProgress =
      ValueNotifier<double>(0);

  static const bool cachePhotos = true;

  static const Duration checkEvery = Duration(seconds: 15);

  static Timer? _timer;
  static StreamSubscription<List<ConnectivityResult>>? _sub;
  static bool _started = false;
  static bool _checking = false;
  static String? _dismissedVersion;

  static String? _photosDoneFor;
  static Future<void>? _photoRun;

  static final ValueNotifier<int> photosSaved = ValueNotifier<int>(0);
  static final ValueNotifier<int> photosTotal = ValueNotifier<int>(0);
  static final ValueNotifier<bool> photosBusy = ValueNotifier<bool>(false);

  static Future<void> start() async {
    if (_started) return;
    _started = true;

    WidgetsBinding.instance.addObserver(_instance);

    await MemorialRepository.loadFromCache();
    await refreshPhotoCount();

    try {
      _sub = Connectivity().onConnectivityChanged.listen(
        (results) {
          if (results.contains(ConnectivityResult.none)) {
            _setOnline(false);
          } else {
            checkNow();
          }
        },
        onError: (_) {},
      );
    } catch (_) {}

    _timer = Timer.periodic(checkEvery, (_) => checkNow());
    await checkNow();
  }

  static void stop() {
    _timer?.cancel();
    _sub?.cancel();
    WidgetsBinding.instance.removeObserver(_instance);
    _started = false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) checkNow();
  }

  static void _setOnline(bool v) {
    if (online.value != v) online.value = v;
  }

  static Future<void> checkNow({bool userInitiated = false}) async {
    if (_checking || installing.value) return;
    _checking = true;
    try {
      final r = await MemorialRepository.checkServer();
      _setOnline(r.reachable);
      if (!r.reachable) return;

      if (!MemorialRepository.hasData) {
        await MemorialRepository.load(serverVersion: r.version);
        if (cachePhotos && MemorialRepository.hasData) {
          unawaited(prefetchPhotos());
        }
        return;
      }

      if (cachePhotos &&
          !installing.value &&
          _photosDoneFor != (MemorialRepository.localVersion ?? '')) {
        unawaited(prefetchPhotos());
      }

      final serverV = r.version;
      if (serverV == null) return;

      if (serverV != MemorialRepository.localVersion) {
        if (userInitiated || serverV != _dismissedVersion) {
          updateAvailable.value = serverV;
        }
      } else {
        updateAvailable.value = null;
      }
    } finally {
      _checking = false;
    }
  }

  static void dismissUpdate() {
    _dismissedVersion = updateAvailable.value;
    updateAvailable.value = null;
  }

  static Future<bool> installUpdate() async {
    final target = updateAvailable.value;
    installing.value = true;
    installProgress.value = 0;
    try {
      await MemorialRepository.load(serverVersion: target);
      if (MemorialRepository.error.value != null) return false;

      if (cachePhotos) {
        await prefetchPhotos();
      } else {
        await PhotoStore.prune(_photoUrls());
        await refreshPhotoCount();
      }

      updateAvailable.value = null;
      return true;
    } finally {
      installing.value = false;
    }
  }

  static Future<void> prefetchPhotos() {
    return _photoRun ??= _prefetchPhotos().whenComplete(() => _photoRun = null);
  }

  static List<String> _photoUrls() => <String>{
        for (final r in MemorialRepository.allRecords)
          if (r.photoUrl != null) r.photoUrl!,
      }.toList();

  static Future<void> refreshPhotoCount() async {
    final urls = _photoUrls();
    var n = 0;
    for (final u in urls) {
      if (await PhotoStore.find(u) != null) n++;
    }
    photosTotal.value = urls.length;
    photosSaved.value = n;
  }

  static Future<void> _prefetchPhotos() async {
    final urls = _photoUrls();
    if (urls.isEmpty) {
      if (MemorialRepository.hasData) await PhotoStore.prune(const []);
      photosTotal.value = 0;
      photosSaved.value = 0;
      return;
    }

    photosBusy.value = true;
    try {
      await refreshPhotoCount();
      final base = photosSaved.value;
      final versionAtStart = MemorialRepository.localVersion;

      const batch = 6;
      var done = 0;
      var alreadySaved = 0;
      var downloaded = 0;
      var failed = 0;
      var paused = false;

      for (var i = 0; i < urls.length; i += batch) {
        if (!online.value) {
          paused = true;
          if (kDebugMode) debugPrint('PHOTOS: paused, the phone went offline');
          break;
        }
        final slice = urls.skip(i).take(batch).toList();
        await Future.wait(slice.map((u) async {
          try {
            if (await PhotoStore.find(u) != null) {
              alreadySaved++;
              return;
            }
            if (await PhotoStore.save(u)) {
              downloaded++;
            } else {
              failed++;
              if (kDebugMode) debugPrint('PHOTO FAILED: $u');
            }
          } catch (e) {
            failed++;
            if (kDebugMode) debugPrint('PHOTO FAILED: $u  ($e)');
          }
        }));
        done += slice.length;
        installProgress.value = done / urls.length;
        photosSaved.value = base + downloaded;
      }

      if (kDebugMode) {
        debugPrint('PHOTOS: ${urls.length} total · $alreadySaved already '
            'saved · $downloaded downloaded · $failed failed');
      }

      if (!paused) {
        final removed = await PhotoStore.prune(urls);
        if (removed > 0) await refreshPhotoCount();
      }

      if (failed == 0 && !paused) _photosDoneFor = versionAtStart ?? '';
    } finally {
      photosBusy.value = false;
    }
  }
}

String formatSynced(DateTime? d) {
  if (d == null) return 'unknown';
  const m = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  final h12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final mm = d.minute.toString().padLeft(2, '0');
  final ap = d.hour >= 12 ? 'PM' : 'AM';
  return '${m[d.month - 1]} ${d.day}, ${d.year} $h12:$mm $ap';
}