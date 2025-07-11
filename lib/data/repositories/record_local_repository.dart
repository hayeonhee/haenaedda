import 'package:haenaedda/common/mixins/safe_runner_mixin.dart';
import 'package:haenaedda/data/sources/record_data_source.dart';
import 'package:haenaedda/domain/entities/record_map.dart';
import 'package:haenaedda/domain/repositories/record_repository.dart';

class RecordLocalRepository with SafeRunnerMixin implements RecordRepository {
  final RecordDataSource _source;

  RecordLocalRepository(this._source);

  @override
  Future<RecordMap> loadRecords() => runSafely(
        () => _source.loadRecords(),
        '$runtimeType.loadRecords',
        RecordMap(),
      );

  @override
  Future<bool> removeRecords(String goalId, RecordMap records) => runSafely(
        () => _source.removeRecords(goalId, records),
        '$runtimeType.removeRecords',
        false,
      );

  @override
  Future<bool> removeUnlinkedRecords(List<String> validGoalIds) => runSafely(
        () => _source.removeUnlinkedRecords(validGoalIds),
        '$runtimeType.removeUnlinkedRecords',
        false,
      );

  @override
  Future<bool> resetAllRecords() => runSafely(
        () => _source.resetAllRecords(),
        '$runtimeType.resetAllRecords',
        false,
      );

  @override
  Future<bool> saveRecords(String goalId, RecordMap records) => runSafely(
        () => _source.saveRecords(goalId, records),
        '$runtimeType.saveRecords',
        false,
      );

  @override
  Future<bool> saveAllRecords(RecordMap records) => runSafely(
        () => _source.saveAllRecords(records),
        '$runtimeType.saveAllRecords',
        false,
      );
}
