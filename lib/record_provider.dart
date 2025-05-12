import 'package:flutter/material.dart';

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
    notifyListeners();
  }
}
