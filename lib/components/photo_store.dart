// ============================================================================
// photo_store.dart
// ============================================================================
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import 'sync_service.dart';

class PhotoStore {
  PhotoStore._();

  static Directory? _dir;

  static Future<Directory> _folder() async {
    final cached = _dir;
    if (cached != null) return cached;
    final base = await getApplicationDocumentsDirectory();
    final d = Directory('${base.path}/memorial_photos_local');
    if (!await d.exists()) await d.create(recursive: true);
    return _dir = d;
  }

  static String _name(String url) {
    final u = Uri.tryParse(url);
    final key = (u != null && u.path.isNotEmpty)
        ? '${u.path}${u.hasQuery ? '?${u.query}' : ''}'
        : url;
    int a = 5381;
    int b = 0;
    for (final c in key.codeUnits) {
      a = ((a * 33) + c) & 0x7fffffff;
      b = (c + (b << 6) + (b << 16) - b) & 0x7fffffff;
    }
    return '${a.toRadixString(16)}${b.toRadixString(16)}.img';
  }

  static Future<File?> find(String url) async {
    try {
      final f = File('${(await _folder()).path}/${_name(url)}');
      if (await f.exists() && await f.length() > 0) return f;
    } catch (_) {}
    return null;
  }

  static Future<void> delete(String url) async {
    try {
      final f = File('${(await _folder()).path}/${_name(url)}');
      if (await f.exists()) await f.delete();
    } catch (_) {}
  }

  static Future<int> prune(Iterable<String> keepUrls) async {
    try {
      final keep = <String>{for (final u in keepUrls) _name(u)};
      final dir = await _folder();
      var removed = 0;
      await for (final e in dir.list()) {
        if (e is! File) continue;
        final name = e.uri.pathSegments.last;
        if (keep.contains(name)) continue;
        try {
          await e.delete();
          removed++;
        } catch (_) {}
      }
      if (kDebugMode) debugPrint('PHOTOS: pruned $removed old file(s)');
      return removed;
    } catch (e) {
      if (kDebugMode) debugPrint('PHOTOS: prune failed ($e)');
      return 0;
    }
  }

  static bool _looksLikeImage(Uint8List b) {
    if (b.length < 12) return false;
    if (b[0] == 0xFF && b[1] == 0xD8) return true;
    if (b[0] == 0x89 && b[1] == 0x50 && b[2] == 0x4E && b[3] == 0x47) {
      return true;
    }
    if (b[0] == 0x47 && b[1] == 0x49 && b[2] == 0x46) return true;
    if (b[0] == 0x52 &&
        b[1] == 0x49 &&
        b[2] == 0x46 &&
        b[3] == 0x46 &&
        b[8] == 0x57 &&
        b[9] == 0x45 &&
        b[10] == 0x42 &&
        b[11] == 0x50) {
      return true;
    }
    return false;
  }

  static Future<bool> save(String url) async {
    if (await find(url) != null) return true;
    try {
      final res = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 20));
      if (res.statusCode != 200 || res.bodyBytes.isEmpty) {
        if (kDebugMode) {
          debugPrint('PHOTO HTTP ${res.statusCode}: $url');
        }
        return false;
      }
      final type = res.headers['content-type'] ?? '';
      if (type.contains('text/html')) {
        if (kDebugMode) debugPrint('PHOTO is a web page, not an image: $url');
        return false;
      }
      if (!_looksLikeImage(res.bodyBytes)) {
        if (kDebugMode) debugPrint('PHOTO bytes are not an image: $url');
        return false;
      }

      final f = File('${(await _folder()).path}/${_name(url)}');
      final tmp = File('${f.path}.tmp');
      await tmp.writeAsBytes(res.bodyBytes, flush: true);
      await tmp.rename(f.path);
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('PHOTO save failed: $url  ($e)');
      return false;
    }
  }
}

class StoredPhoto extends StatefulWidget {
  const StoredPhoto({
    super.key,
    required this.url,
    required this.placeholder,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
  });

  final String url;
  final Widget placeholder;
  final BoxFit fit;
  final Alignment alignment;

  @override
  State<StoredPhoto> createState() => _StoredPhotoState();
}

class _StoredPhotoState extends State<StoredPhoto> {
  File? _file;
  bool _repaired = false;

  @override
  void initState() {
    super.initState();
    _loadLocal();
  }

  @override
  void didUpdateWidget(covariant StoredPhoto old) {
    super.didUpdateWidget(old);
    if (old.url != widget.url) {
      _file = null;
      _repaired = false;
      _loadLocal();
    }
  }

  Future<void> _loadLocal() async {
    final url = widget.url;

    final saved = await PhotoStore.find(url);
    if (!mounted || url != widget.url) return;
    if (saved != null) {
      setState(() => _file = saved);
      return;
    }

    if (!SyncService.online.value) return;

    final ok = await PhotoStore.save(url);
    if (!mounted || url != widget.url || !ok) return;
    final f = await PhotoStore.find(url);
    if (mounted && f != null && url == widget.url) {
      setState(() => _file = f);
    }
  }

  void _discardBadFile() {
    if (_repaired) return;
    _repaired = true;
    final url = widget.url;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await PhotoStore.delete(url);
      if (!mounted || url != widget.url) return;
      setState(() => _file = null);
      _loadLocal();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: SyncService.online,
      builder: (context, online, _) {
        final f = _file;
        if (f != null) {
          return Image.file(
            f,
            fit: widget.fit,
            alignment: widget.alignment,
            gaplessPlayback: true,
            errorBuilder: (_, __, ___) {
              _discardBadFile();
              return widget.placeholder;
            },
          );
        }

        if (!online) return widget.placeholder;

        return Image.network(
          widget.url,
          fit: widget.fit,
          alignment: widget.alignment,
          gaplessPlayback: true,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return widget.placeholder;
          },
          errorBuilder: (_, __, ___) => widget.placeholder,
        );
      },
    );
  }
}