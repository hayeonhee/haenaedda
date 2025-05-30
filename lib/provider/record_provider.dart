import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:haenaedda/model/goal.dart';
import 'package:haenaedda/utils/extensions/iterable_extensions.dart';
import 'package:haenaedda/utils/record_serializer.dart';

class StorageKeys {
  static const String goals = 'goals';
}

enum AddGoalResult {
  success,
  emptyInput,
  duplicate,
}

enum RenameGoalResult {
  success,
  emptyInput,
  notFound,
  duplicate,
  saveFailed,
}

class RecordProvider extends ChangeNotifier {
  List<Goal> _goals = [];
  final Map<String, Set<DateTime>> _recordsByGoalId = {};
  final String _firstDisplayedGoalId = '1';

  Map<String, Set<DateTime>> get recordsByGoal => _recordsByGoalId;

  Set<DateTime> getRecords(String goal) => _recordsByGoalId[goal] ?? {};

  bool isGoalsEmpty() => _goals.isEmpty;

// TODO: Currently displayed in ID order, but will switch to order field later.
  Future<Goal> initializeAndGetFirstGoal() async {
    await loadRecords();

    final existingGoal = _goals.firstWhere(
      (goal) => goal.id == _firstDisplayedGoalId,
      orElse: () {
        final newGoal = _createDefaultGoal();
        _goals.add(newGoal);
        return newGoal;
      },
    );
    return existingGoal;
  }

  Goal _createDefaultGoal() {
    return Goal(_firstDisplayedGoalId, "");
  }

  String getNextGoalId() {
    if (_goals.isEmpty) return _firstDisplayedGoalId;
    final lastGoal = _goals.last;
    final nextId = int.parse(lastGoal.id) + 1;
    return nextId.toString();
  }

  bool isDuplicateGoal(String newGoalTitle) {
    return _goals.any((goal) => goal.title == newGoalTitle);
  }

  AddGoalResult addGoal(String input) {
    if (input.trim().isEmpty) return AddGoalResult.emptyInput;
    if (isDuplicateGoal(input)) return AddGoalResult.duplicate;
    final id = getNextGoalId();
    _goals.add(Goal(id, input));
    return AddGoalResult.success;
  }

  Future<RenameGoalResult> renameGoal(
      String goalId, String newGoalTitle) async {
    if (newGoalTitle.trim().isEmpty) {
      return RenameGoalResult.emptyInput;
    }
    if (isDuplicateGoal(newGoalTitle)) {
      return RenameGoalResult.duplicate;
    }
    final goal = _goals.firstWhereOrNull((goal) => goal.id == goalId);
    if (goal == null) {
      return RenameGoalResult.notFound;
    }
    goal.title = newGoalTitle;
    notifyListeners();
    return RenameGoalResult.success;
  }

  Future<bool> saveGoals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encodedGoalsJson =
          jsonEncode(_goals.map((g) => g.toJson()).toList());
      final isSaved =
          await prefs.setString(StorageKeys.goals, encodedGoalsJson);
      if (isSaved) notifyListeners();
      return isSaved;
    } catch (error) {
      return false;
    }
  }

  Future<bool> loadGoal() async {
    final prefs = await SharedPreferences.getInstance();
    final loadedGoalsJson = prefs.getString(StorageKeys.goals);

    if (loadedGoalsJson == null) return false;

    final decodedGoalsJson = jsonDecode(loadedGoalsJson);
    final restoredGoals =
        decodedGoalsJson.map((e) => Goal.fromJson(e)).toList();
    _goals = restoredGoals;
    notifyListeners();
    return true;
  }

  DateTime getFirstRecordedDate() {
    if (_recordsByGoalId.isEmpty) {
      return DateTime.now();
    }
    final allDates = _recordsByGoalId.values.expand((dates) => dates).toList();
    allDates.sort((a, b) => a.compareTo(b));
    return allDates.first;
  }

  void toggleRecord(String goalId, DateTime date) {
    final goalRecords = _recordsByGoalId[goalId] ?? <DateTime>{};
    if (goalRecords.contains(date)) {
      goalRecords.remove(date);
    } else {
      goalRecords.add(date);
    }
    _recordsByGoalId[goalId] = goalRecords;
    saveRecords();
    notifyListeners();
  }

  Future<void> loadRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    for (String key in keys) {
      final dates = prefs.getString(key);
      if (dates != null) {
        _recordsByGoalId[key] = jsonToDateTimeSet(dates);
      }
    }
    notifyListeners();
  }

  Future<void> saveRecords() async {
    final prefs = await SharedPreferences.getInstance();
    for (final entry in _recordsByGoalId.entries) {
      final dates = dateTimeSetToJson(entry.value);
      await prefs.setString(entry.key, dates);
    }
  }

  Future<bool> clearGoalRecords(String goalId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final success = await prefs.remove(goalId);
      if (!success) return false;
      _recordsByGoalId.remove(goalId);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Failed to delete records. id: $goalId');
      return false;
    }
  }
}
