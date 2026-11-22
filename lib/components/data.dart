// ============================================================================
// data.dart
// ============================================================================


import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://graveguard-6f71c53d057c.herokuapp.com/',
  );
  static const Duration timeout = Duration(seconds: 15);
  static const Duration pingTimeout = Duration(seconds: 4);
}

enum MemorialIcon { cross, bird }

enum NicheStatus { occupied, reserved, vacant }

const int kRowsPerColumn = 4;

String memorialKey(int cluster, int column, int row) =>
    'CL$cluster-C$column-R$row';

class MemorialRecord {
  final String? name;
  final String? birthDate;
  final String? deathDate;
  final String? quote;
  final String? photoUrl;
  final MemorialIcon icon;
  final NicheStatus status;
  final String? notes;
  final int? leaseYears;

  final String? leaseStatus;
  final String? key;

  const MemorialRecord({
    this.name,
    this.birthDate,
    this.deathDate,
    this.quote,
    this.photoUrl,
    this.icon = MemorialIcon.cross,
    this.status = NicheStatus.vacant,
    this.notes,
    this.leaseYears,
    this.leaseStatus,
    this.key,
  });

  static const MemorialRecord vacant = MemorialRecord();

  bool get isOccupied => name != null && name!.isNotEmpty;
  bool get isReserved => !isOccupied && status == NicheStatus.reserved;

  factory MemorialRecord.fromJson(String key, Map<String, dynamic> j) {
    final normalizedKey = key.trim().toUpperCase();

    final status = switch (_clean(j['status'])?.toLowerCase()) {
      'reserved' => NicheStatus.reserved,
      'vacant' => NicheStatus.vacant,
      _ => NicheStatus.occupied,
    };

    final photo = _clean(j['photo_display']) ?? _clean(j['photo_url']);

    return MemorialRecord(
      name: _clean(j['name']),
      birthDate: _clean(j['birth_date']),
      deathDate: _clean(j['death_date']),
      quote: _clean(j['quote']),
      photoUrl: _resolvePhoto(photo),
      icon: _iconFor(normalizedKey),
      status: status,
      notes: _clean(j['notes']),
      leaseYears: _asInt(j['lease_years']),
      leaseStatus: _clean(j['lease_status']),
      key: normalizedKey,
    );
  }
}

String? _clean(dynamic value) {
  final s = value?.toString().trim();
  return (s == null || s.isEmpty || s == 'null') ? null : s;
}

int? _asInt(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v?.toString() ?? '');
}

MemorialIcon _iconFor(String key) {
  var hash = 5381;
  for (final unit in key.codeUnits) {
    hash = ((hash * 33) + unit) & 0x7fffffff;
  }
  return math.Random(hash).nextBool() ? MemorialIcon.bird : MemorialIcon.cross;
}

bool _isUnreachableHost(String host) {
  final h = host.toLowerCase();
  if (h == 'localhost' || h == '0.0.0.0' || h.endsWith('.local')) return true;

  final m = RegExp(r'^(\d+)\.(\d+)\.(\d+)\.(\d+)$').firstMatch(h);
  if (m == null) return false;

  final a = int.parse(m.group(1)!);
  final b = int.parse(m.group(2)!);
  return a == 127 ||
      a == 10 ||
      (a == 192 && b == 168) ||
      (a == 172 && b >= 16 && b <= 31) ||
      (a == 169 && b == 254);
}

String? _resolvePhoto(String? raw) {
  if (raw == null) return null;

  final uri = Uri.tryParse(raw);
  if (uri == null) return null;

  final base = Uri.parse(ApiConfig.baseUrl);

  if (!uri.hasScheme) return base.resolve(raw).toString();

  String onServer() => Uri(
        scheme: base.scheme,
        host: base.host,
        port: base.hasPort ? base.port : null,
        path: uri.path,
        query: uri.hasQuery ? uri.query : null,
      ).toString();

  if (uri.host != base.host && _isUnreachableHost(uri.host)) return onServer();
  if (uri.host == base.host && uri.scheme != base.scheme) return onServer();

  return raw;
}

class _OfflineStore {
  static Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/memorials_cache.json');
  }

  static Future<void> save(String? version, List raw) async {
    final file = await _file();
    final temp = File('${file.path}.tmp');
    await temp.writeAsString(
      jsonEncode({
        'version': version,
        'saved_at': DateTime.now().toIso8601String(),
        'records': raw,
      }),
      flush: true,
    );
    await temp.rename(file.path);
  }

  static Future<Map<String, dynamic>?> read() async {
    try {
      final file = await _file();
      if (!await file.exists()) return null;
      final decoded = jsonDecode(await file.readAsString());
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (e) {
      if (kDebugMode) debugPrint('Offline cache read failed: $e');
      return null;
    }
  }
}

class MemorialRepository {
  MemorialRepository._();

  static Map<String, MemorialRecord> _records = {};

  static final ValueNotifier<int> version = ValueNotifier<int>(0);
  static final ValueNotifier<bool> loading = ValueNotifier<bool>(false);
  static final ValueNotifier<String?> error = ValueNotifier<String?>(null);
  static final ValueNotifier<DateTime?> lastSynced =
      ValueNotifier<DateTime?>(null);

  static String? localVersion;

  static bool get hasData => _records.isNotEmpty;

  static Iterable<MemorialRecord> get allRecords => _records.values;

  static MemorialRecord? byKey(String key) =>
      _records[key.trim().toUpperCase()];

  static Map<String, MemorialRecord> _parse(List raw) {
    final parsed = <String, MemorialRecord>{};

    for (final item in raw) {
      if (item is! Map) continue;
      final j = item.cast<String, dynamic>();

      var key = _clean(j['key'] ?? j['plot_key']);
      if (key == null) {
        final cluster = _asInt(j['cluster']);
        final column = _asInt(j['column'] ?? j['column_no']);
        final row = _asInt(j['row'] ?? j['row_no']);
        if (cluster == null || column == null || row == null) continue;
        key = memorialKey(cluster, column, row);
      }

      parsed[key.toUpperCase()] = MemorialRecord.fromJson(key, j);
    }
    return parsed;
  }

  static Future<({bool reachable, String? version})> checkServer() async {
    try {
      final res = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/memorials/version/'),
        headers: {'Accept': 'application/json'},
      ).timeout(ApiConfig.pingTimeout);

      String? v;
      if (res.statusCode == 200) {
        final body = jsonDecode(utf8.decode(res.bodyBytes));
        if (body is Map) v = body['version']?.toString();
      }
      return (reachable: true, version: v);
    } catch (_) {
      return (reachable: false, version: null);
    }
  }

  static Future<bool> loadFromCache() async {
    final cached = await _OfflineStore.read();
    if (cached == null) return false;

    try {
      final parsed = _parse(cached['records'] as List? ?? const []);
      if (parsed.isEmpty) return false;

      _records = parsed;
      localVersion = cached['version']?.toString();
      lastSynced.value = DateTime.tryParse(cached['saved_at']?.toString() ?? '');
      version.value++;
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('Offline cache could not be parsed: $e');
      return false;
    }
  }

  static Future<void> load({String? serverVersion}) async {
    if (loading.value) return;
    loading.value = true;
    error.value = null;

    try {
      final dataVersion = serverVersion ?? (await checkServer()).version;

      final res = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/memorials/'),
        headers: {'Accept': 'application/json'},
      ).timeout(ApiConfig.timeout);

      if (res.statusCode != 200) {
        throw HttpException('Server returned ${res.statusCode}');
      }

      final decoded = jsonDecode(utf8.decode(res.bodyBytes));
      final List raw = decoded is Map<String, dynamic>
          ? (decoded['records'] as List? ?? const [])
          : (decoded as List);

      _records = _parse(raw);
      localVersion = dataVersion;
      lastSynced.value = DateTime.now();

      try {
        await _OfflineStore.save(dataVersion, raw);
      } catch (e) {
        if (kDebugMode) debugPrint('Could not save offline copy: $e');
      }

      version.value++;
    } on TimeoutException {
      error.value = 'Connection timed out. Please try again.';
      if (!hasData) await loadFromCache();
    } on SocketException {
      error.value = 'No internet connection.';
      if (!hasData) await loadFromCache();
    } catch (e) {
      error.value = 'Could not load records: $e';
      if (kDebugMode) debugPrint('MemorialRepository error: $e');
      if (!hasData) await loadFromCache();
    } finally {
      loading.value = false;
    }
  }
}

MemorialRecord getMemorialRecord(int cluster, int column, int row) =>
    MemorialRepository.byKey(memorialKey(cluster, column, row)) ??
    MemorialRecord.vacant;