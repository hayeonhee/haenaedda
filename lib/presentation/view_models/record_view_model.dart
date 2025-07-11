import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';

import 'package:haenaedda/domain/entities/date_record_set.dart';
import 'package:haenaedda/domain/entities/record_map.dart';
import 'package:haenaedda/domain/repositories/record_repository.dart';

class RecordViewModel extends ChangeNotifier {
  final RecordRepository _repository;

  RecordViewModel(this._repository);

  final RecordMap _records = RecordMap();
  final Map<String, Timer> _saveDebounceTimers = {};
  final Map<String, DateTime> _firstRecordDateCache = {};
  bool _isLoaded = false;

  UnmodifiableMapView<String, DateRecordSet> get records =>
      _records.asReadOnlyMap;
  bool get isLoaded => _isLoaded;

  DateRecordSet? getRecords(String goalId) {
    return _records[goalId];
  }

  Future<bool> loadData() async {
    final recordsLoaded = await _loadRecords();
    notifyListeners();
    return recordsLoaded;
  }

  DateTime? findFirstRecordedDate(String goalId) {
    if (_firstRecordDateCache.containsKey(goalId)) {
      return _firstRecordDateCache[goalId];
    }
    final recordSet = _records[goalId];
    if (recordSet == null || recordSet.dateKeys.isEmpty) return null;
    final sorted = recordSet.dateKeys.map((key) => DateTime.parse(key)).toList()
      ..sort();
    final first = sorted.first;
    final firstDate = DateTime(first.year, first.month, 1);
    _firstRecordDateCache[goalId] = firstDate;
    return firstDate;
  }

  void toggleRecord(String goalId, DateTime date) {
    final currentSet = _records.putIfAbsent(goalId, () => DateRecordSet());
    final updatedSet = currentSet.toggle(date);
    _records[goalId] = updatedSet;
    _removeFirstRecordedDateCache(goalId);
    notifyListeners();
  }

  void scheduleDebouncedSave(
    String goalId, {
    Duration duration = const Duration(milliseconds: 500),
  }) {
    _saveDebounceTimers[goalId]?.cancel();
    _saveDebounceTimers[goalId] = Timer(duration, () => saveRecords(goalId));
  }

  Future<void> saveRecords(String goalId) async {
    final isSuccess = await _repository.saveRecords(goalId, _records);
    if (!isSuccess) {
      debugPrint('$runtimeType.saveRecords failed for $goalId');
    }
  }

  Future<void> saveAllRecords() async {
    final isSuccess = await _repository.saveAllRecords(_records);
    if (!isSuccess) {
      debugPrint('$runtimeType.saveAllRecords failed');
    }
  }

  Future<bool> removeRecords(String goalId) async {
    final isSuccess = await _repository.removeRecords(goalId, _records);
    if (isSuccess) {
      _removeRecordFromMemory(goalId);
      notifyListeners();
    }
    return isSuccess;
  }

  Future<void> removeUnlinkedRecords(List<String> validGoalIds) async {
    _removeUnlinkedRecordsFromMemory(validGoalIds);
    final isSuccess = await _repository.removeUnlinkedRecords(validGoalIds);
    if (!isSuccess) {
      debugPrint('$runtimeType.removeUnlinkedRecords failed');
    }
  }

  void resetAllRecords() {
    _records.clear();
    notifyListeners();
  }

  Future<bool> _loadRecords() async {
    try {
      final records = await _repository.loadRecords();
      resetAllRecords();
      _records.addAll(records);
      _isLoaded = true;
      return true;
    } catch (e) {
      debugPrint('$runtimeType.loadRecords failed: $e');
      return false;
    }
  }

  void _removeFirstRecordedDateCache(String goalId) {
    _firstRecordDateCache.remove(goalId);
  }

  void _removeRecordFromMemory(String goalId) {
    _records.remove(goalId);
    _removeFirstRecordedDateCache(goalId);
  }

  void _removeUnlinkedRecordsFromMemory(List<String> validGoalIds) {
    final unlinkedIds =
        _records.keys.where((id) => !validGoalIds.contains(id)).toList();

    for (final id in unlinkedIds) {
      _removeRecordFromMemory(id);
    }
    if (unlinkedIds.isNotEmpty) {
      debugPrint('$runtimeType.removeUnlinkedRecords removed: $unlinkedIds');
      notifyListeners();
    }
  }
}
