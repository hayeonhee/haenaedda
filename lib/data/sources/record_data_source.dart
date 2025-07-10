import 'package:haenaedda/domain/entities/record_map.dart';

abstract class RecordDataSource {
  Future<RecordMap> loadRecords();
  Future<bool> saveRecords(String goalId, RecordMap records);
  Future<bool> removeRecords(String goalId, RecordMap records);
  Future<void> resetAllRecords();
}
