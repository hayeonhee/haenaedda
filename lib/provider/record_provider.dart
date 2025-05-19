import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:haenaedda/model/goal.dart';
import 'package:haenaedda/utils/record_serializer.dart';

enum AddGoalResult { success, emptyInput, duplicate }

class RecordProvider extends ChangeNotifier {
  final List<Goal> _goals = [];
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

  bool isDuplicateGoal(String newTitle) {
    return _goals.any((goal) => goal.name == newTitle);
  }

  AddGoalResult addGoal(String input) {
    if (input.trim().isEmpty) return AddGoalResult.emptyInput;
    if (isDuplicateGoal(input)) return AddGoalResult.duplicate;
    final id = getNextGoalId();
    _goals.add(Goal(id, input));
    return AddGoalResult.success;
  }

  void renameGoal(String goalId, String newTitle) {
    final goal = _goals.firstWhere((goal) => goal.id == goalId);
    if (goal != null) {
      goal.name = newTitle;
      notifyListeners();
    }
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
}
