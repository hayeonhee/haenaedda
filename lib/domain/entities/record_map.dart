import 'dart:collection';

import 'package:haenaedda/domain/entities/date_record_set.dart';

class RecordMap {
  final Map<String, DateRecordSet> _map;

  RecordMap([Map<String, DateRecordSet>? initial]) : _map = initial ?? {};

  DateRecordSet? operator [](String goalId) => _map[goalId];

  void operator []=(String goalId, DateRecordSet record) {
    _map[goalId] = record;
  }

  void addAll(RecordMap other) => _map.addAll(other._map);

  bool contains(String goalId) => _map.containsKey(goalId);

  void remove(String goalId) => _map.remove(goalId);

  DateRecordSet putIfAbsent(String goalId, DateRecordSet Function() ifAbsent) {
    return _map.putIfAbsent(goalId, ifAbsent);
  }

  void clear() => _map.clear();

  UnmodifiableMapView<String, DateRecordSet> get asReadOnlyMap =>
      UnmodifiableMapView(_map);

  Iterable<String> get keys => _map.keys;
}
