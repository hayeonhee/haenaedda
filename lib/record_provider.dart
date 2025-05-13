import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:haenaedda/utils/record_serializer.dart';

class RecordProvider extends ChangeNotifier {
  final Map<String, Set<DateTime>> _recordsByTopic = {};

  Map<String, Set<DateTime>> get recordsByTopic => _recordsByTopic;

  Set<DateTime> getRecords(String topic) => _recordsByTopic[topic] ?? {};

  void toggleRecord(String topic, DateTime date) {
    final topicRecords = _recordsByTopic[topic] ?? <DateTime>{};
    if (topicRecords.contains(date)) {
      topicRecords.remove(date);
    } else {
      topicRecords.add(date);
    }
    _recordsByTopic[topic] = topicRecords;
    saveRecords();
    notifyListeners();
  }

  Future<void> loadRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    for (String key in keys) {
      final dates = prefs.getString(key);
      if (dates != null) {
        _recordsByTopic[key] = jsonToDateTimeSet(dates);
      }
    }
    notifyListeners();
  }

  Future<void> saveRecords() async {
    final prefs = await SharedPreferences.getInstance();
    for (final entry in _recordsByTopic.entries) {
      final dates = dateTimeSetToJson(entry.value);
      await prefs.setString(entry.key, dates);
    }
  }
}
