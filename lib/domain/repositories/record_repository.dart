import 'package:haenaedda/domain/entities/record_map.dart';

abstract class RecordRepository {
  Future<RecordMap> loadRecords();
  Future<bool> saveRecords(String goalId, RecordMap records);
  Future<bool> saveAllRecords(RecordMap records);
  Future<bool> removeRecords(String goalId, RecordMap records);
  Future<bool> removeUnlinkedRecords(List<String> validGoalIds);
  Future<bool> resetAllRecords();
}
