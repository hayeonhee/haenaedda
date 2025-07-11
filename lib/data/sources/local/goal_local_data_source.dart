import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:haenaedda/constants/storage_keys.dart';
import 'package:haenaedda/data/sources/goal_data_source.dart';
import 'package:haenaedda/domain/entities/goal.dart';

class GoalLocalDataSource implements GoalDataSource {
  late final Future<SharedPreferences> _sharedPrefsFuture;

  GoalLocalDataSource() {
    _sharedPrefsFuture = SharedPreferences.getInstance();
  }

  @override
  Future<List<Goal>> loadGoals() async {
    try {
      final prefs = await _sharedPrefsFuture;
      final loadedGoalsJson = prefs.getString(StorageKeys.goals);
      if (loadedGoalsJson == null) {
        debugPrint('$runtimeType.loadGoals: no goals found');
        return [];
      }

      final decoded = jsonDecode(loadedGoalsJson);
      return (decoded as List)
          .map((e) => Goal.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('$runtimeType.loadGoals failed: $e');
      return [];
    }
  }

  @override
  Future<bool> removeGoal(String goalId, List<Goal> goals) async {
    try {
      final prefs = await _sharedPrefsFuture;
      final updatedGoalsJson =
          jsonEncode(goals.map((g) => g.toJson()).toList());
      final isSaved =
          await prefs.setString(StorageKeys.goals, updatedGoalsJson);
      return isSaved;
    } catch (e) {
      debugPrint('$runtimeType.removeGoal failed for $goalId: $e');
      return false;
    }
  }

  @override
  Future<bool> saveGoals(List<Goal> goals) async {
    try {
      final prefs = await _sharedPrefsFuture;
      final encodedGoalsJson =
          jsonEncode(goals.map((g) => g.toJson()).toList());
      final isSaved =
          await prefs.setString(StorageKeys.goals, encodedGoalsJson);
      return isSaved;
    } catch (error) {
      debugPrint('$runtimeType.saveGoals failed: $error');
      return false;
    }
  }

  @override
  Future<bool> resetAllGoals() async {
    try {
      final prefs = await _sharedPrefsFuture;
      final keysToRemove =
          prefs.getKeys().where((k) => k.startsWith(StorageKeys.record));
      for (final key in keysToRemove) {
        await prefs.remove(key);
      }
      await prefs.remove(StorageKeys.goals);
      return true;
    } catch (e) {
      debugPrint('$runtimeType.resetAllGoals failed: $e');
      return false;
    }
  }
}
