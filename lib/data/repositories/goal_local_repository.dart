import 'package:flutter/material.dart';
import 'package:haenaedda/data/sources/goal_data_source.dart';
import 'package:haenaedda/domain/entities/goal.dart';
import 'package:haenaedda/domain/repositories/goal_repository.dart';

class GoalLocalRepository implements GoalRepository {
  final GoalDataSource _dataSource;

  GoalLocalRepository(this._dataSource);

  @override
  Future<List<Goal>> loadGoals() async {
    try {
      return await _dataSource.loadGoals();
    } catch (e) {
      debugPrint('Failed to load goals: $e');
      return [];
    }
  }

  @override
  Future<bool> saveAllGoals(List<Goal> goals) async {
    try {
      return await _dataSource.saveGoals(goals);
    } catch (e) {
      debugPrint('Failed to save goals: $e');
      return false;
    }
  }

  @override
  Future<bool> removeGoal(String goalId, List<Goal> goals) async {
    try {
      final isSaved = await _dataSource.removeGoal(goalId, goals);
      return isSaved;
    } catch (e) {
      debugPrint('Failed to remove goal $goalId: $e');
      return false;
    }
  }

  @override
  Future<bool> resetAllGoals() async {
    return await _dataSource.resetAllGoals();
  }
}
