import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:haenaedda/model/date_record_set.dart';
import 'package:haenaedda/model/goal.dart';
import 'package:haenaedda/utils/extensions/iterable_extensions.dart';

class StorageKeys {
  static const String goals = 'goals';
  static const String record = 'record:';
}

enum AddGoalResult {
  success,
  emptyInput,
  duplicate,
  saveFailed,
}

enum RenameGoalResult {
  success,
  emptyInput,
  notFound,
  duplicate,
  saveFailed,
}

enum ResetEntireGoalResult {
  success,
  recordFailed,
  goalFailed,
}

class RecordProvider extends ChangeNotifier {
  List<Goal> _goals = [];
  List<Goal> _sortedGoals = [];
  final Map<String, DateRecordSet> _recordsByGoalId = {};
  static const String _firstGoalId = '10';
  static const int _orderStep = 10;
  bool _isLoaded = false;

  Map<String, DateRecordSet> get recordsByGoal => _recordsByGoalId;

  DateRecordSet getRecords(String goal) =>
      _recordsByGoalId[goal] ?? DateRecordSet();

  List<Goal> get sortedGoals => _sortedGoals;

  Goal? get currentGoal {
    if (_goals.isEmpty) return null;
    return _goals.firstWhereOrNull((g) => g.id == _firstGoalId);
  }

  bool get isLoaded => _isLoaded;

  bool get hasNoGoal => _goals.isEmpty;

  void _syncSortedGoals() {
    _sortedGoals = [..._goals]..sort((a, b) => a.order.compareTo(b.order));
  }

  Goal? getGoalById(String id) {
    return _goals.firstWhereOrNull((g) => g.id == id);
  }

  Future<bool> loadData() async {
    final goalsLoaded = await _loadGoals();
    final recordsLoaded = await _loadRecords();
    final isSuccess = goalsLoaded && recordsLoaded;
    if (isSuccess) notifyListeners();
    return isSuccess;
  }

  Future<bool> _loadGoals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final loadedGoalsJson = prefs.getString(StorageKeys.goals);

      if (loadedGoalsJson == null) {
        _clearGoals();
        debugPrint('No saved goals found. Clearing internal goal state.');
        _isLoaded = true;
        return true;
      }

      final decodedGoalsJson = jsonDecode(loadedGoalsJson);
      final List<Goal> restoredGoals = (decodedGoalsJson as List)
          .map((e) => Goal.fromJson((e as Map<String, dynamic>)))
          .toList();
      _goals
        ..clear()
        ..addAll(restoredGoals);
      _syncSortedGoals();
      _isLoaded = true;
      return true;
    } catch (e) {
      debugPrint('Failed to load goals: $e');
      return false;
    }
  }

  Future<bool> _loadRecords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      _recordsByGoalId.clear();

      final recordKeys =
          keys.where((key) => key.startsWith(StorageKeys.record));
      for (String key in recordKeys) {
        final dates = prefs.getString(key);
        if (dates == null) continue;

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

  Goal _createGoal(String title) {
    final String id = getNextGoalId();
    final int order = getNextOrder();
    return Goal(id, order, title);
  }

  String getNextGoalId() {
    if (_goals.isEmpty) return _firstGoalId;
    final lastGoal = _goals.last;
    final nextId = int.parse(lastGoal.id) + 1;
    return nextId.toString();
  }

  /// Returns the next order value with a fixed step (default: 10).
  /// This keeps enough space between items for future insertions.
  int getNextOrder() {
    if (_goals.isEmpty) return _orderStep;
    final maxOrder = _goals.map((g) => g.order).reduce(max);
    return maxOrder + _orderStep;
  }

  /// Reassigns order values with equal spacing (e.g. 10, 20, 30...).
  /// Call this when there isn't enough space between items
  void rebalanceOrders() {
    _goals.sort((a, b) => a.order.compareTo(b.order));
    for (int i = 0; i < _goals.length; i++) {
      _goals[i].order = (i + 1) * _orderStep;
    }
    _syncSortedGoals();
    saveGoals();
    notifyListeners();
  }

  bool isDuplicateGoal(String newGoalTitle) {
    return _goals.any((goal) => goal.title == newGoalTitle);
  }

  Future<({AddGoalResult result, Goal? goal})> addGoal(String title) async {
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) {
      return (result: AddGoalResult.emptyInput, goal: null);
    }
    if (isDuplicateGoal(trimmedTitle)) {
      return (result: AddGoalResult.duplicate, goal: null);
    }
    final goal = _createGoal(trimmedTitle);
    _goals.add(goal);
    _syncSortedGoals();
    final isSaved = await saveGoals();
    if (!isSaved) {
      return (result: AddGoalResult.saveFailed, goal: null);
    }
    notifyListeners();
    return (result: AddGoalResult.success, goal: goal);
  }

  Future<({RenameGoalResult result, Goal? goal})> renameGoal(
    Goal selectedGoal,
    String newTitle,
  ) async {
    if (newTitle.trim().isEmpty) {
      return (result: RenameGoalResult.emptyInput, goal: null);
    }
    if (isDuplicateGoal(newTitle)) {
      return (result: RenameGoalResult.duplicate, goal: null);
    }
    final goal =
        _goals.firstWhereOrNull((oldGoal) => oldGoal.id == selectedGoal.id);
    if (goal == null) {
      return (result: RenameGoalResult.notFound, goal: null);
    }
    goal.title = newTitle;
    _syncSortedGoals();
    saveGoals();
    notifyListeners();
    return (result: RenameGoalResult.success, goal: goal);
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

  void _clearGoals() {
    _goals = [];
    _sortedGoals = [];
    notifyListeners();
  }

  DateTime getFirstRecordedDate() {
    if (_recordsByGoalId.isEmpty) return DateTime.now();
    final allDates =
        _recordsByGoalId.values.expand((recordSet) => recordSet.raw).toList();
    if (allDates.isEmpty) return DateTime.now();
    allDates.sort();
    return allDates.first;
  }

  void toggleRecord(String goalId, DateTime date) {
    final currentSet = _recordsByGoalId[goalId] ?? DateRecordSet();
    final updated = currentSet.toggle(date);
    _recordsByGoalId[goalId] = updated;
    saveRecords();
    notifyListeners();
  }

  Future<void> saveRecords() async {
    final prefs = await SharedPreferences.getInstance();
    for (final entry in _recordsByGoalId.entries) {
      final dates = entry.value.toJson();
      await prefs.setString(entry.key, dates);
    }
  }

  Future<bool> removeRecordsOnly(String goalId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final success = await prefs.remove(goalId);
      if (success) {
        _recordsByGoalId.remove(goalId);
        notifyListeners();
      }
      return success;
    } catch (e) {
      debugPrint('Failed to remove records for goal $goalId: $e');
      return false;
    }
  }

  Future<bool> removeGoal(String goalId) async {
    try {
      final goalCountBefore = _goals.length;
      _goals.removeWhere((goal) => goal.id == goalId);
      final goalRemoved = _goals.length < goalCountBefore;
      if (goalRemoved) {
        final prefs = await SharedPreferences.getInstance();
        final updatedGoalsJson =
            jsonEncode(_goals.map((g) => g.toJson()).toList());
        final saved = await prefs.setString('goals', updatedGoalsJson);
        _syncSortedGoals();
        notifyListeners();
        return saved;
      }
      return false;
    } catch (e) {
      debugPrint('Failed to remove goal $goalId: $e');
      return false;
    }
  }

  Future<ResetEntireGoalResult> resetEntireGoal(String goalId) async {
    final recordsCleared = await removeRecordsOnly(goalId);
    if (!recordsCleared) return ResetEntireGoalResult.recordFailed;

    final goalCleared = await removeGoal(goalId);
    if (!goalCleared) return ResetEntireGoalResult.goalFailed;

    return ResetEntireGoalResult.success;
  }

  /// Creates a fallback goal if the goal list is empty.
  /// This prevents the app from crashing after full reset.
  Future<void> ensureAtLeastOneGoalExists() async {
    if (_goals.isEmpty) {
      final fallbackGoal = _createGoal("");
      _goals.add(fallbackGoal);
      await saveGoals();
    }
  }

  int? getNextFocusGoalIndexAfterRemoval(String removedId) {
    final index = _sortedGoals.indexWhere((g) => g.id == removedId);
    if (index == -1) return null;
    final nextIndex = (index - 1).clamp(0, _sortedGoals.length - 1);
    return nextIndex;
  }

// 📌 Scroll Focus Management for Newly Added Goal
// Used to scroll to the newly added goal once, immediately after creation.
// Cleared in GoalPager after being consumed.

  Goal? _focusedGoalForScroll;
  bool _shouldScrollToFocusedPage = false;

  Goal? get focusedGoalForScroll => _focusedGoalForScroll;
  bool get shouldScrollToFocusedPage => _shouldScrollToFocusedPage;

  void setFocusedGoalForScroll(Goal goal) {
    _focusedGoalForScroll = goal;
    _shouldScrollToFocusedPage = true;
    notifyListeners();
  }

  void clearFocusedGoalForScroll() {
    _focusedGoalForScroll = null;
    _shouldScrollToFocusedPage = false;
  }
}
