import 'package:haenaedda/domain/entities/goal.dart';

abstract class GoalDataSource {
  Future<List<Goal>> loadGoals();
  Future<bool> saveGoals(List<Goal> goals);
  Future<bool> removeGoal(String goalId, List<Goal> goals);
  Future<bool> resetAllGoals();
}
