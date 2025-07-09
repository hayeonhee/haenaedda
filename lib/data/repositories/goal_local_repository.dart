import 'package:haenaedda/domain/entities/goal.dart';
import 'package:haenaedda/domain/repositories/goal_repository.dart';

class GoalLocalRepository implements GoalRepository {
  @override
  Future<List<Goal>> loadGoals() async {
    return [];
  }

  @override
  Future<bool> saveAllGoals(List<Goal> goals) async {
    return true;
  }

  @override
  Future<bool> clearAllGoals() {
    throw UnimplementedError();
  }

  @override
  Future<bool> removeGoal(String goalId, List<Goal> goals) {
    throw UnimplementedError();
  }
}
