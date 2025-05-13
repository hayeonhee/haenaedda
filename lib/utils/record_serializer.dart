import 'dart:convert';

String dateTimeSetToJson(Set<DateTime> dateTimeSet) {
  final dateStrings =
      dateTimeSet.map((date) => date.toIso8601String()).toList();
  return jsonEncode(dateStrings);
}

Set<DateTime> jsonToDateTimeSet(String jsonString) {
  final List<dynamic> dateStrings = jsonDecode(jsonString);
  return dateStrings.map((dateString) => DateTime.parse(dateString)).toSet();
}
