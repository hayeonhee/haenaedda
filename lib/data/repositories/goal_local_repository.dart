import 'package:haenaedda/common/mixins/safe_runner_mixin.dart';
import 'package:haenaedda/data/sources/goal_data_source.dart';
import 'package:haenaedda/domain/entities/goal.dart';
import 'package:haenaedda/domain/repositories/goal_repository.dart';

class GoalLocalRepository with SafeRunnerMixin implements GoalRepository {
  final GoalDataSource _source;

  GoalLocalRepository(this._source);

  @override
  Future<List<Goal>> loadGoals() => runSafely(
        () => _source.loadGoals(),
        '$runtimeType.loadGoals',
        [],
      );

  @override
  Future<bool> saveAllGoals(List<Goal> goals) => runSafely(
        () => _source.saveGoals(goals),
        '$runtimeType.saveAllGoals',
        false,
      );

  @override
  Future<bool> removeGoal(String goalId, List<Goal> goals) => runSafely(
        () => _source.removeGoal(goalId, goals),
        '$runtimeType.removeGoal',
        false,
      );

  @override
  Future<bool> resetAllGoals() => runSafely(
        () => _source.resetAllGoals(),
        '$runtimeType.resetAllGoals',
        false,
      );
}
