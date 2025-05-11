class CalendarGridLayout {
  final DateTime baseDate;

  late final int year;
  late final int month;
  late final int totalDaysOfMonth;
  late final int leadingBlanks;
  late final int trailingBlanks;
  late final int totalCellCount;

  CalendarGridLayout(this.baseDate) {
    year = baseDate.year;
    month = baseDate.month;
    int firstWeekday = DateTime(year, month, 1).weekday % 7;
    totalDaysOfMonth = DateTime(year, month + 1, 0).day;
    leadingBlanks = firstWeekday;
    int partialCellCount = leadingBlanks + totalDaysOfMonth;
    trailingBlanks = (7 - partialCellCount % 7) % 7;
    totalCellCount = partialCellCount + trailingBlanks;
  }

  bool isNotEmptyCell(int index) {
    return index >= leadingBlanks && index < leadingBlanks + totalDaysOfMonth;
  }

  DateTime dateFromIndex(int index) {
    assert(isNotEmptyCell(index), 'Invalid index: $index. Not a date cell.');
    final day = index - leadingBlanks + 1;
    return DateTime(year, month, day);
  }
}
