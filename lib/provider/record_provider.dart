import 'dart:async';
import 'dart:collection';
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

enum ResetAllGoalsResult {
  success,
  failure,
}

class RecordProvider extends ChangeNotifier {
  final List<Goal> _goals = [];
  List<Goal> _sortedGoals = [];
  final Map<String, DateRecordSet> _recordsByGoalId = {};
  static const String _firstGoalId = '10';
  static const int _orderStep = 10;
  bool _isLoaded = false;
  final Map<String, Timer> _saveDebounceTimers = {};
  late final Future<SharedPreferences> _sharedPrefsFuture;

  RecordProvider() {
    _sharedPrefsFuture = SharedPreferences.getInstance();
  }

  List<Goal> get goals => _goals;
  List<Goal> get sortedGoals => _sortedGoals;
  UnmodifiableMapView<String, DateRecordSet> get recordsByGoalId =>
      UnmodifiableMapView(_recordsByGoalId);
  bool get isLoaded => _isLoaded;
  bool get hasNoGoal => goals.isEmpty;

  DateRecordSet? getRecords(String goalId) {
    return _recordsByGoalId[goalId];
  }

  DateRecordSet getOrCreateRecords(String goalId) {
    return _recordsByGoalId.putIfAbsent(goalId, () => DateRecordSet());
  }

  Goal? getGoalById(String id) {
    return goals.firstWhereOrNull((g) => g.id == id);
  }

  Future<bool> loadData() async {
    final goalsLoaded = await _loadGoals();
    final recordsLoaded = await _loadRecords();
    _isLoaded = goalsLoaded && recordsLoaded;
    notifyListeners();
    return isLoaded;
  }

  DateTime findFirstRecordedDate() {
    if (recordsByGoalId.isEmpty) return DateTime.now();
    final allDateTimes = recordsByGoalId.values
        .expand((recordSet) => recordSet.dateKeys)
        .map((key) => DateTime.tryParse(key))
        .whereType<DateTime>()
        .toList();
    if (allDateTimes.isEmpty) return DateTime.now();
    allDateTimes.sort();
    return allDateTimes.first;
  }

  int? getNextFocusGoalIndexAfterRemoval(String removedId) {
    final index = sortedGoals.indexWhere((g) => g.id == removedId);
    if (index == -1) return null;
    final nextIndex = (index - 1).clamp(0, sortedGoals.length - 1);
    return nextIndex;
  }

  String getNextGoalId() {
    if (goals.isEmpty) return _firstGoalId;
    final lastGoal = goals.last;
    final nextId = int.parse(lastGoal.id) + 1;
    return nextId.toString();
  }

  /// Returns the next order value with a fixed step (default: 10).
  /// This keeps enough space between items for future insertions.
  int getNextOrder() {
    if (goals.isEmpty) return _orderStep;
    final maxOrder = goals.map((g) => g.order).reduce(max);
    return maxOrder + _orderStep;
  }

  /// Reassigns order values with equal spacing (e.g. 10, 20, 30...).
  /// Call this when there isn't enough space between items
  void rebalanceOrders() {
    goals.sort((a, b) => a.order.compareTo(b.order));
    for (int i = 0; i < goals.length; i++) {
      goals[i].order = (i + 1) * _orderStep;
    }
    _syncSortedGoals();
    saveGoals();
    notifyListeners();
  }

  Future<({AddGoalResult result, Goal? goal})> addGoal(String title) async {
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) {
      return (result: AddGoalResult.emptyInput, goal: null);
    }
    if (_isDuplicateGoal(trimmedTitle)) {
      return (result: AddGoalResult.duplicate, goal: null);
    }
    final goal = _createGoal(trimmedTitle);
    goals.add(goal);
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
    if (_isDuplicateGoal(newTitle)) {
      return (result: RenameGoalResult.duplicate, goal: null);
    }
    final goal =
        goals.firstWhereOrNull((oldGoal) => oldGoal.id == selectedGoal.id);
    if (goal == null) {
      return (result: RenameGoalResult.notFound, goal: null);
    }
    goal.title = newTitle;
    _syncSortedGoals();
    saveGoals();
    notifyListeners();
    return (result: RenameGoalResult.success, goal: goal);
  }

  void toggleRecord(String goalId, DateTime date) {
    final currentSet = getOrCreateRecords(goalId);
    final updated = currentSet.toggle(date);
    recordsByGoalId[goalId] = updated;
    notifyListeners();
  }

  void saveRecordsDebounced(
    String goalId, {
    Duration duration = const Duration(milliseconds: 500),
  }) {
    _saveDebounceTimers[goalId]?.cancel();
    _saveDebounceTimers[goalId] = Timer(duration, () => saveRecords(goalId));
  }

  Future<bool> saveGoals() async {
    try {
      final prefs = await _sharedPrefsFuture;
      final encodedGoalsJson =
          jsonEncode(goals.map((g) => g.toJson()).toList());
      final isSaved =
          await prefs.setString(StorageKeys.goals, encodedGoalsJson);
      if (isSaved) notifyListeners();
      return isSaved;
    } catch (error) {
      return false;
    }
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

  Future<void> saveAll() async {
    final prefs = await _sharedPrefsFuture;
    for (final entry in recordsByGoalId.entries) {
      await prefs.setString(entry.key, entry.value.toJson());
    }
    debugPrint('💾 All records saved on app pause.');
  }

  Future<bool> removeRecordsOnly(String goalId) async {
    try {
      final prefs = await _sharedPrefsFuture;
      final success = await prefs.remove(goalId);
      if (success) {
        recordsByGoalId.remove(goalId);
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
      final goalCountBefore = goals.length;
      goals.removeWhere((goal) => goal.id == goalId);
      final goalRemoved = goals.length < goalCountBefore;
      if (goalRemoved) {
        final prefs = await _sharedPrefsFuture;
        final updatedGoalsJson =
            jsonEncode(goals.map((g) => g.toJson()).toList());
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

  Future<ResetAllGoalsResult> resetAllGoals() async {
    try {
      goals.clear();
      recordsByGoalId.clear();

      final prefs = await _sharedPrefsFuture;
      final keysToRemove = prefs.getKeys().where(
            (k) => k.startsWith(StorageKeys.record),
          );
      for (final key in keysToRemove) {
        await prefs.remove(key);
      }
      await prefs.remove(StorageKeys.goals);
      notifyListeners();
      return ResetAllGoalsResult.success;
    } catch (e) {
      debugPrint('❌ resetAllGoals failed: $e');
      return ResetAllGoalsResult.failure;
    }
  }

  /// Creates a fallback goal if the goal list is empty.
  /// This prevents the app from crashing after full reset.
  Future<void> ensureAtLeastOneGoalExists() async {
    if (goals.isEmpty) {
      final fallbackGoal = _createGoal("");
      goals.add(fallbackGoal);
      await saveGoals();
    }
  }

  Future<bool> _loadGoals() async {
    try {
      final prefs = await _sharedPrefsFuture;
      final loadedGoalsJson = prefs.getString(StorageKeys.goals);
      if (loadedGoalsJson == null) {
        _clearGoals();
        debugPrint('No saved goals found. Clearing internal goal state.');
        return true;
      }

      final decodedGoalsJson = jsonDecode(loadedGoalsJson);
      final List<Goal> restoredGoals = (decodedGoalsJson as List)
          .map((e) => Goal.fromJson((e as Map<String, dynamic>)))
          .toList();
      goals
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
      final prefs = await _sharedPrefsFuture;
      final keys = prefs.getKeys();
      recordsByGoalId.clear();

      final recordKeys =
          keys.where((key) => key.startsWith(StorageKeys.record));
      for (String key in recordKeys) {
        final dates = prefs.getString(key);
        debugPrint('key: $key → $dates');

        if (dates == null) continue;
        debugPrint('key: $key → $dates');
        try {
          final goalId = key.substring(StorageKeys.record.length);
          recordsByGoalId[goalId] = DateRecordSet.fromJson(dates);
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

  void _syncSortedGoals() {
    _sortedGoals = [...goals]..sort((a, b) => a.order.compareTo(b.order));
  }

  Goal _createGoal(String title) {
    final String id = getNextGoalId();
    final int order = getNextOrder();
    return Goal(id, order, title);
  }

  bool _isDuplicateGoal(String newGoalTitle) {
    return goals.any((goal) => goal.title == newGoalTitle);
  }

  void _clearGoals() {
    _goals.clear();
    _sortedGoals.clear();
    notifyListeners();
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
