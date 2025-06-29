import 'dart:convert';

import 'package:flutter/foundation.dart';

class DateRecordSet {
  static const String _jsonKeyDates = 'dates';
  final Set<String> _dateKeys;

  DateRecordSet([Set<String>? initial]) : _dateKeys = initial ?? {};

  Set<String> get dateKeys => _dateKeys;
  static DateRecordSet fromJson(String? jsonString) {
    if (jsonString == null || jsonString.trim().isEmpty) {
      return DateRecordSet();
    }
    try {
      final decoded = jsonDecode(jsonString);
      Set<String> extractDateKeys(dynamic input) {
        if (input is Map && input.containsKey(_jsonKeyDates)) {
          final list = input[_jsonKeyDates];
          return Set<String>.from(
            (list as List)
                .map((e) => e.toString().split('T').first)
                .where((s) => DateKey.isValid(s)),
          );
        } else if (input is List) {
          return Set<String>.from(
            input
                .map((e) => e.toString().split('T').first)
                .where((s) => DateKey.isValid(s)),
          );
        } else {
          debugPrint('⚠️ Unknown format for DateRecordSet: $input');
          return {};
        }
      }

      return DateRecordSet(extractDateKeys(decoded));
    } catch (e) {
      debugPrint('⚠️ DateRecordSet parsing failed: $e');
      return DateRecordSet();
    }
  }

  String toJson() => jsonEncode({'dates': dateKeys.toList()});

  Map<String, dynamic> toJsonMap() => {'dates': toList()};

  List<String> toList() => dateKeys.toList();

  void add(DateTime date) => _dateKeys.add(DateKey.fromDate(date));

  void remove(DateTime date) => _dateKeys.remove(DateKey.fromDate(date));

  bool contains(DateTime date) => _dateKeys.contains(DateKey.fromDate(date));

  DateRecordSet toggle(DateTime date) {
    final key = DateKey.fromDate(date);
    final updated = Set<String>.from(dateKeys);
    if (updated.contains(key)) {
      updated.remove(key);
    } else {
      updated.add(key);
    }
    return DateRecordSet(updated);
  }
}

class DateKey {
  static final regex = RegExp(r'^\d{4}-\d{2}-\d{2}$');

  static String fromDate(DateTime date) {
    return DateTime(date.year, date.month, date.day)
        .toIso8601String()
        .split('T')
        .first;
  }

  static bool isValid(String key) => regex.hasMatch(key);
}
