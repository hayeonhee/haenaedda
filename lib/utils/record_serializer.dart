import 'dart:convert';

import 'package:flutter/foundation.dart';

String dateTimeSetToJson(Set<DateTime> dateTimeSet) {
  final dateStrings =
      dateTimeSet.map((date) => date.toIso8601String()).toList();
  return jsonEncode(dateStrings);
}

Set<DateTime> jsonToDateTimeSet(String? jsonString) {
  if (jsonString == null || jsonString.trim().isEmpty) {
    return {};
  }
  try {
    final List<dynamic> dateStrings = jsonDecode(jsonString);
    return dateStrings
        .whereType<String>()
        .map((dateString) => DateTime.parse(dateString))
        .toSet();
  } catch (e) {
    debugPrint('Error parsing DateTime set: $e');
    return {};
  }
}
