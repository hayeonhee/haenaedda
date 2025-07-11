import 'package:flutter/material.dart';

import 'package:haenaedda/common/utils/goal_list_helper.dart';
import 'package:haenaedda/domain/entities/goal.dart';
import 'package:haenaedda/domain/enums/goal_operation_result.dart';
import 'package:haenaedda/domain/repositories/goal_repository.dart';
import 'package:haenaedda/extensions/iterable_extensions.dart';

class GoalViewModel extends ChangeNotifier {
  final GoalRepository _goalRepository;

  final List<Goal> _goals = [];
  List<Goal> _sortedGoals = [];

  bool _isLoaded = false;

  GoalViewModel(this._goalRepository);

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

  Future<bool> loadData() async {
    final goalsLoaded = await _loadGoals();
    notifyListeners();
    return goalsLoaded;
  }

  /// Reassigns order values with equal spacing (e.g. 10, 20, 30...).
  /// Call this when there isn't enough space between items
  void rebalanceOrders() {
    goals.sort((a, b) => a.order.compareTo(b.order));
    for (int i = 0; i < goals.length; i++) {
      goals[i].order = (i + 1) * GoalListHelper.orderStep;
    }
    _syncSortedGoals();
    saveAllGoals();
    notifyListeners();
  }

  Future<void> updateGoalOrder(List<Goal> reorderedGoals) async {
    for (int i = 0; i < reorderedGoals.length; i++) {
      reorderedGoals[i].order = (i + 1) * GoalListHelper.orderStep;
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
      final isSaved = await _goalRepository.saveAllGoals(goals);
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
        final saved = await _goalRepository.removeGoal(goalId, goals);
        if (saved) {
          _syncSortedGoals();
          notifyListeners();
        }
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
      final isReset = await _goalRepository.resetAllGoals();
      notifyListeners();
      return isReset
          ? ResetAllGoalsResult.success
          : ResetAllGoalsResult.failure;
    } catch (e) {
      debugPrint('resetAllGoals failed: $e');
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
      notifyListeners();
    }
  }

  Future<bool> _loadGoals() async {
    try {
      final loadedGoals = await _goalRepository.loadGoals();
      if (loadedGoals.isEmpty) {
        _resetState();
        debugPrint('No goals found. Resetting state.');
        return true;
      }
      _goals
        ..clear()
        ..addAll(loadedGoals);
      _syncSortedGoals();
      _isLoaded = true;
      return true;
    } catch (e) {
      debugPrint('Failed to load goals: $e');
      return false;
    }
  }

  void _syncSortedGoals() {
    _sortedGoals = GoalListHelper.sorted(goals);
  }

  Goal _createGoal(String title) {
    final String id = GoalListHelper.getNextId(goals);
    final int order = GoalListHelper.getNextOrder(goals);
    return Goal(id, order, title);
  }

  bool _isDuplicateGoal(String newGoalTitle) {
    return goals.any((goal) => goal.title == newGoalTitle);
  }

  void _resetState() {
    _goals.clear();
    _sortedGoals.clear();
    notifyListeners();
  }
}
