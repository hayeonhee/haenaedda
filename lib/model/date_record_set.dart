import 'dart:convert';

import 'package:flutter/foundation.dart';

class DateRecordSet {
  final Set<DateTime> _dates;

  DateRecordSet([Set<DateTime>? initial]) : _dates = initial ?? {};

  void add(DateTime date) => _dates.add(_normalize(date));

  void remove(DateTime date) => _dates.remove(_normalize(date));

  bool contains(DateTime date) => _dates.contains(_normalize(date));

  bool get isEmpty => _dates.isEmpty;

  bool get isNotEmpty => _dates.isNotEmpty;

  List<DateTime> get sorted => _dates.toList()..sort();

  Set<DateTime> get raw => _dates;

  static DateTime _normalize(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  DateRecordSet toggle(DateTime date) {
    final normalized = _normalize(date);
    final updated = Set<DateTime>.from(_dates);
    if (updated.contains(normalized)) {
      updated.remove(normalized);
    } else {
      updated.add(normalized);
    }
    return DateRecordSet(updated);
  }

  String toJson() {
    final dateStrings = _dates.map((d) => d.toIso8601String()).toList();
    return jsonEncode(dateStrings);
  }

  static DateRecordSet fromJson(String jsonString) {
    try {
      final decoded = jsonDecode(jsonString);
      final dates = (decoded as List)
          .whereType<String>()
          .map((s) => DateTime.parse(s))
          .map(_normalize)
          .toSet();
      return DateRecordSet(dates);
    } catch (e) {
      debugPrint('DateRecordSet parsing failed: $e');
      return DateRecordSet();
    }
  }
}
