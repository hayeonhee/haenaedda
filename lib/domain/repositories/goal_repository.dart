import 'package:haenaedda/domain/entities/goal.dart';

abstract class GoalRepository {
  Future<List<Goal>> loadGoals();
  Future<bool> saveAllGoals(List<Goal> goals);
  Future<bool> removeGoal(String goalId, List<Goal> goals);
  Future<bool> resetAllGoals();
}
