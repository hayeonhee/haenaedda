import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:haenaedda/constants/storage_keys.dart';
import 'package:haenaedda/data/sources/record_data_source.dart';
import 'package:haenaedda/domain/entities/date_record_set.dart';
import 'package:haenaedda/domain/entities/record_map.dart';

class RecordLocalDataSource implements RecordDataSource {
  late final Future<SharedPreferences> _sharedPrefsFuture;

  RecordLocalDataSource() {
    _sharedPrefsFuture = SharedPreferences.getInstance();
  }

  @override
  Future<RecordMap> loadRecords() async {
    try {
      final prefs = await _sharedPrefsFuture;
      final keys = prefs.getKeys();
      final recordsByGoalId = <String, DateRecordSet>{};
      final recordKeys =
          keys.where((key) => key.startsWith(StorageKeys.record));

      for (final key in recordKeys) {
        final dates = prefs.getString(key);
        if (dates == null) {
          debugPrint('$runtimeType.loadRecords failed: $key: no dates found');
          continue;
        }
        final goalId = key.substring(StorageKeys.record.length);
        recordsByGoalId[goalId] = DateRecordSet.fromJson(dates);
      }
      return RecordMap(recordsByGoalId);
    } catch (e) {
      debugPrint('$runtimeType.loadRecords failed: $e');
      return RecordMap();
    }
  }

  @override
  Future<bool> saveRecords(
    String goalId,
    RecordMap records,
  ) async {
    try {
      final prefs = await _sharedPrefsFuture;
      final recordSet = records[goalId];
      if (recordSet == null || recordSet.dateKeys.isEmpty) {
        debugPrint('$runtimeType.saveRecords failed: $goalId: no record set');
        return false;
      }

      final json = recordSet.toJson();
      final key = '${StorageKeys.record}$goalId';
      final isSuccess = await prefs.setString(key, json);
      return isSuccess;
    } catch (e) {
      debugPrint('$runtimeType.saveRecords failed for $goalId: $e');
      return false;
    }
  }

  @override
  Future<bool> removeRecords(
    String goalId,
    RecordMap records,
  ) async {
    try {
      final prefs = await _sharedPrefsFuture;
      final key = '${StorageKeys.record}$goalId';
      final isSuccess = await prefs.remove(key);
      return isSuccess;
    } catch (e) {
      debugPrint('$runtimeType.removeRecords failed for $goalId: $e');
      return false;
    }
  }

  @override
  Future<bool> resetAllRecords() async {
    try {
      final prefs = await _sharedPrefsFuture;
      final keys = prefs.getKeys();
      final recordKeys =
          keys.where((key) => key.startsWith(StorageKeys.record));

      for (final key in recordKeys) {
        final removed = await prefs.remove(key);
        if (!removed) {
          debugPrint('$runtimeType.resetAllRecords failed to remove key: $key');
          return false;
        }
      }
      return true;
    } catch (e) {
      debugPrint('$runtimeType.resetAllRecords failed: $e');
      return false;
    }
  }
}
