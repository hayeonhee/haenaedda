class CalendarGridLayout {
  final DateTime baseDate;

  late final int year;
  late final int month;
  late final int totalDaysOfMonth;
  late final int leadingBlanks;
  late final int trailingBlanks;
  late final int totalCellCount;

  CalendarGridLayout(this.baseDate) {
    int firstWeekday = DateTime(year, month, 1).weekday % 7;
    totalDaysOfMonth = DateTime(year, month + 1, 0).day;
    leadingBlanks = firstWeekday;
    int partialCellCount = leadingBlanks + totalDaysOfMonth;
    trailingBlanks = (7 - partialCellCount % 7) % 7;
    totalCellCount = partialCellCount + trailingBlanks;
  }
}
