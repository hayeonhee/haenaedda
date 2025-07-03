import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:haenaedda/constants/storage_keys.dart';
import 'package:haenaedda/model/date_record_set.dart';

class RecordViewModel extends ChangeNotifier {
  final Map<String, DateRecordSet> _recordsByGoalId = {};
  final bool _isLoaded = false;
  final Map<String, Timer> _saveDebounceTimers = {};
  final Map<String, DateTime> _firstRecordDateCache = {};
  late final Future<SharedPreferences> _sharedPrefsFuture;

  RecordViewModel() {
    _sharedPrefsFuture = SharedPreferences.getInstance();
  }

  UnmodifiableMapView<String, DateRecordSet> get recordsByGoalId =>
      UnmodifiableMapView(_recordsByGoalId);
  bool get isLoaded => _isLoaded;

  void setRecord(String goalId, DateRecordSet recordSet) {
    _recordsByGoalId[goalId] = recordSet;
    clearFirstRecordDateCache(goalId);
    notifyListeners();
  }

  DateRecordSet? getRecords(String goalId) {
    return _recordsByGoalId[goalId];
  }

  DateRecordSet getOrCreateRecords(String goalId) {
    return _recordsByGoalId.putIfAbsent(goalId, () => DateRecordSet());
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
    final recordSet = _recordsByGoalId[goalId];
    if (recordSet == null || recordSet.dateKeys.isEmpty) return null;
    final sorted = recordSet.dateKeys.map((key) => DateTime.parse(key)).toList()
      ..sort();
    final first = sorted.first;
    final result = DateTime(first.year, first.month, 1);
    _firstRecordDateCache[goalId] = result;
    return result;
  }

  void toggleRecord(String goalId, DateTime date) {
    final currentSet = getOrCreateRecords(goalId);
    final updated = currentSet.toggle(date);
    setRecord(goalId, updated);
  }

  void saveRecordsDebounced(
    String goalId, {
    Duration duration = const Duration(milliseconds: 500),
  }) {
    _saveDebounceTimers[goalId]?.cancel();
    _saveDebounceTimers[goalId] = Timer(duration, () => saveRecords(goalId));
  }

  Future<void> saveRecords(String goalId) async {
    final prefs = await _sharedPrefsFuture;
    final recordSet = recordsByGoalId[goalId];
    if (recordSet == null || recordSet.dateKeys.isEmpty) {
      debugPrint('⚠️ No records to save for goalId: $goalId');
      return;
    }

    final json = recordSet.toJson();
    final key = '${StorageKeys.record}$goalId';
    final success = await prefs.setString(key, json);
    if (success) {
      debugPrint('📦 key: $key → $json');
    } else {
      debugPrint('❌ Failed to save record for $goalId');
    }
  }

  Future<void> saveAllRecords() async {
    final prefs = await _sharedPrefsFuture;
    for (final entry in recordsByGoalId.entries) {
      await prefs.setString(entry.key, entry.value.toJson());
    }
    debugPrint('💾 All records saved on app pause.');
  }

  void clearFirstRecordDateCache(String goalId) {
    _firstRecordDateCache.remove(goalId);
  }

  Future<bool> removeRecords(String goalId) async {
    try {
      final prefs = await _sharedPrefsFuture;
      final success = await prefs.remove(goalId);
      if (success) {
        _recordsByGoalId.remove(goalId);
        clearFirstRecordDateCache(goalId);
        notifyListeners();
      }
      return success;
    } catch (e) {
      debugPrint('Failed to remove records for goal $goalId: $e');
      return false;
    }
  }

  Future<void> removeAllUnlinkedRecords(List<String> validGoalIds) async {
    _removeUnlinkedRecords(validGoalIds);
    await removeUnlinkedRecordsFromStorage(validGoalIds);
  }

  /// Removes in-memory records that do not have a matching goal ID.
  void _removeUnlinkedRecords(List<String> validGoalIds) {
    final unlinkedIds = _recordsByGoalId.keys
        .where((id) => !validGoalIds.contains(id))
        .toList();

    for (final id in unlinkedIds) {
      _recordsByGoalId.remove(id);
      clearFirstRecordDateCache(id);
    }

    if (unlinkedIds.isNotEmpty) {
      debugPrint('🧹 Removed unlinked records: $unlinkedIds');
      notifyListeners();
    }
  }

  /// Removes record entries from SharedPreferences that do not match any known goal ID.
  Future<void> removeUnlinkedRecordsFromStorage(
    List<String> validGoalIds,
  ) async {
    final prefs = await _sharedPrefsFuture;
    final allKeys = prefs.getKeys();
    final recordKeys = allKeys.where((k) => k.startsWith(StorageKeys.record));

    final unlinkedKeys = recordKeys.where((key) {
      final goalId = key.substring(StorageKeys.record.length);
      return !validGoalIds.contains(goalId);
    }).toList();

    for (final key in unlinkedKeys) {
      await prefs.remove(key);
    }

    if (unlinkedKeys.isNotEmpty) {
      debugPrint(
          '🧹 Removed unlinked records from SharedPreferences: $unlinkedKeys');
    }
  }

  Future<bool> _loadRecords() async {
    try {
      final prefs = await _sharedPrefsFuture;
      final keys = prefs.getKeys();
      _recordsByGoalId.clear();

      final recordKeys =
          keys.where((key) => key.startsWith(StorageKeys.record));
      for (String key in recordKeys) {
        final dates = prefs.getString(key);
        debugPrint('key: $key → $dates');

        if (dates == null) continue;
        debugPrint('key: $key → $dates');
        try {
          final goalId = key.substring(StorageKeys.record.length);
          _recordsByGoalId[goalId] = DateRecordSet.fromJson(dates);
        } catch (e) {
          debugPrint('Record parsing failed for $key: $e');
          return false;
        }
      }
      return true;
    } catch (e) {
      debugPrint('Failed to load records: $e');
      return false;
    }
  }
}
