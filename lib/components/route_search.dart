// ============================================================================
// ROUTE SEARCH BAR  (live suggestions + quick-pick chips)
// ============================================================================
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'data.dart';
import 'pathfinder.dart';

class RouteSearchBar extends StatefulWidget {
  final ValueChanged<RouteResult>? onRoute;

  final ValueChanged<SearchHit>? onHit;

  const RouteSearchBar({super.key, this.onRoute, this.onHit})
      : assert(onRoute != null || onHit != null,
            'Provide onRoute or onHit');

  @override
  State<RouteSearchBar> createState() => _RouteSearchBarState();
}

class _RouteSearchBarState extends State<RouteSearchBar> {
  static const int _maxResults = 10;

  final TextEditingController _ctrl = TextEditingController();
  final FocusNode _focus = FocusNode();
  late final List<SearchPrefix> _prefixes = Pathfinder.prefixes();

  List<SearchHit> _results =
      Pathfinder.searchEverything('').take(_maxResults).toList();
  String? _error;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      if (mounted) setState(() {});
    });
    MemorialRepository.version.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    MemorialRepository.version.removeListener(_onDataChanged);
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onDataChanged() {
    if (mounted) _onChanged(_ctrl.text);
  }

  void _setQuery(String v) {
    _ctrl.value = TextEditingValue(
      text: v,
      selection: TextSelection.collapsed(offset: v.length),
    );
    _onChanged(v);
    _focus.requestFocus();
  }

  void _onChanged(String v) {
    setState(() {
      _results = Pathfinder.searchEverything(v).take(_maxResults).toList();
      _error = null;
    });
  }

  void _select(SearchHit hit) {
    final onHit = widget.onHit;
    if (onHit != null) {
      if (hit.isMemorial) {
        if (hit.cluster == null || hit.column == null) {
          setState(() => _error = 'This memorial has no location.');
          return;
        }
      } else if (hit.groupCfg == null) {
        setState(() => _error = 'This group cannot be located.');
        return;
      }
      _ctrl.text = hit.label;
      _focus.unfocus();
      setState(() => _error = null);
      onHit(hit);
      return;
    }

    RouteResult? route;

    if (hit.isMemorial) {
      final cl = hit.cluster;
      final co = hit.column;
      if (cl == null || co == null) {
        setState(() => _error = 'This memorial has no location.');
        return;
      }
      route = Pathfinder.routeToColumn(
        cl,
        co,
        label: hit.label,
      );
    } else {
      final cfg = hit.groupCfg;
      if (cfg == null) {
        setState(() => _error = 'This group cannot be located.');
        return;
      }
      route = Pathfinder.routeToGroup(cfg);
    }

    if (route == null) {
      setState(() => _error = 'No walkable path found to ${hit.label}.');
      return;
    }

    _ctrl.text = hit.label;
    _focus.unfocus();
    setState(() => _error = null);
    widget.onRoute?.call(route);
  }

  Widget _highlighted(String label, String query) {
    const base = TextStyle(fontSize: 15, color: Colors.black87);
    final q = Pathfinder.norm(query);
    if (q.isEmpty) return Text(label, style: base);

    final n = Pathfinder.norm(label);
    final idx = n.indexOf(q);
    if (idx < 0 || n.length != label.replaceAll(' ', '').length) {
      return Text(label, style: base);
    }
    int count = 0, start = 0;
    for (int i = 0; i < label.length; i++) {
      if (label[i] == ' ') continue;
      if (count == idx) {
        start = i;
        break;
      }
      count++;
    }
    int end = start, matched = 0;
    while (end < label.length && matched < q.length) {
      if (label[end] != ' ') matched++;
      end++;
    }
    return Text.rich(TextSpan(style: base, children: [
      TextSpan(text: label.substring(0, start)),
      TextSpan(
        text: label.substring(start, end),
        style: const TextStyle(
            fontWeight: FontWeight.w900, color: AppColors.navy),
      ),
      TextSpan(text: label.substring(end)),
    ]));
  }

  @override
  Widget build(BuildContext context) {
    final query = _ctrl.text;
    final open = _focus.hasFocus;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(28),
          color: Colors.white,
          child: TextField(
            controller: _ctrl,
            focusNode: _focus,
            textInputAction: TextInputAction.search,
            onChanged: _onChanged,
            onSubmitted: (_) {
              if (_results.isNotEmpty) _select(_results.first);
            },
            decoration: InputDecoration(
              hintText: 'Search a group, name, or code (CL1-C1-R1)…',
              prefixIcon: const Icon(Icons.search, color: AppColors.navy),
              suffixIcon: query.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _ctrl.clear();
                        _onChanged('');
                      },
                    ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),

        if (open)
          Container(
            margin: const EdgeInsets.only(top: 6),
            constraints: const BoxConstraints(maxHeight: 360),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 3)),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 52,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      itemCount: _prefixes.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 6),
                      itemBuilder: (_, i) {
                        final p = _prefixes[i];
                        final selected = Pathfinder.norm(query) ==
                                Pathfinder.norm(p.query) &&
                            query.isNotEmpty;
                        return ChoiceChip(
                          label: Text('${p.display}  ${p.count}'),
                          selected: selected,
                          selectedColor: AppColors.navy,
                          labelStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: selected
                                ? Colors.white
                                : AppColors.navy,
                          ),
                          visualDensity: VisualDensity.compact,
                          onSelected: (_) => _setQuery(p.query),
                        );
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 2),
                    child: Text(
                      query.isEmpty
                          ? '${_results.length} groups'
                          : '${_results.length} match'
                              '${_results.length == 1 ? '' : 'es'} for "$query"',
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey[600]),
                    ),
                  ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 2, 16, 4),
                      child: Text(_error!,
                          style: const TextStyle(color: Colors.red)),
                    ),
                  Flexible(
                    child: _results.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(20),
                            child: Center(child: Text('No matches')),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: _results.length,
                            itemBuilder: (_, i) {
                              final hit = _results[i];
                              if (hit.isMemorial) {
                                return _memorialTile(hit, query);
                              }
                              return _groupTile(hit, query);
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _groupTile(SearchHit hit, String query) {
    return ListTile(
      dense: true,
      leading: const CircleAvatar(
        radius: 14,
        backgroundColor: AppColors.navy,
        child: Icon(Icons.place, size: 16, color: Colors.white),
      ),
      title: _highlighted(hit.label, query),
      trailing: const Icon(Icons.directions_walk,
          size: 20, color: AppColors.navy),
      onTap: () => _select(hit),
    );
  }

  Widget _memorialTile(SearchHit hit, String query) {
    final code = 'CL${hit.cluster}-C${hit.column}'
        '${hit.row != null ? '-R${hit.row}' : ''}';
    return ListTile(
      dense: true,
      leading: const CircleAvatar(
        radius: 14,
        backgroundColor: Color(0xFF5F7B4F),
        child: Icon(Icons.person, size: 16, color: Colors.white),
      ),
      title: _highlighted(hit.label, query),
      subtitle: Text(
        code,
        style: const TextStyle(
          fontSize: 11,
          color: Color(0xFF5F7B4F),
          fontWeight: FontWeight.w600,
          letterSpacing: 0.4,
        ),
      ),
      trailing: const Icon(Icons.directions_walk,
          size: 20, color: Color(0xFF5F7B4F)),
      onTap: () => _select(hit),
    );
  }
}