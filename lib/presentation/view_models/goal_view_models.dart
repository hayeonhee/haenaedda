import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:haenaedda/constants/storage_keys.dart';
import 'package:haenaedda/model/goal.dart';
import 'package:haenaedda/extensions/iterable_extensions.dart';
import 'package:haenaedda/presentation/view_models/goal_result.dart';

class GoalViewModel extends ChangeNotifier {
  final List<Goal> _goals = [];
  List<Goal> _sortedGoals = [];
  static const String _firstGoalId = '10';
  static const int _orderStep = 10;
  bool _isLoaded = false;
  late final Future<SharedPreferences> _sharedPrefsFuture;

  GoalViewModel() {
    _sharedPrefsFuture = SharedPreferences.getInstance();
  }

  List<Goal> get goals => _goals;
  List<Goal> get sortedGoals => _sortedGoals;
  bool get isLoaded => _isLoaded;
  bool get hasNoGoal => goals.isEmpty;

  Goal? getGoalById(String id) {
    return goals.firstWhereOrNull((g) => g.id == id);
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

  Future<bool> loadData() async {
    final goalsLoaded = await _loadGoals();
    notifyListeners();
    return goalsLoaded;
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
    saveAllGoals();
    notifyListeners();
  }

  Future<void> updateGoalOrder(List<Goal> reorderedGoals) async {
    for (int i = 0; i < reorderedGoals.length; i++) {
      reorderedGoals[i].order = (i + 1) * _orderStep;
    }
    _goals
      ..clear()
      ..addAll(reorderedGoals);

    _syncSortedGoals();
    await saveAllGoals();
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
    final isSaved = await saveAllGoals();
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
    saveAllGoals();
    notifyListeners();
    return (result: RenameGoalResult.success, goal: goal);
  }

  Future<bool> saveAllGoals() async {
    try {
      final prefs = await _sharedPrefsFuture;
      final encodedGoalsJson =
          jsonEncode(goals.map((g) => g.toJson()).toList());
      final isSaved =
          await prefs.setString(StorageKeys.goals, encodedGoalsJson);
      return isSaved;
    } catch (error) {
      return false;
    }
  }

  Future<bool> _removeGoalOnly(String goalId) async {
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
    final goalCleared = await _removeGoalOnly(goalId);
    if (!goalCleared) return ResetEntireGoalResult.goalFailed;
    return ResetEntireGoalResult.success;
  }

  Future<ResetAllGoalsResult> resetAllGoals() async {
    try {
      goals.clear();
      // _recordsByGoalId.clear();
      // _firstRecordDateCache.clear();

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
      await saveAllGoals();
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
