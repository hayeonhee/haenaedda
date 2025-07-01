extension DateCompare on DateTime {
  bool isBeforeYearMonthOf(DateTime target) {
    return year < target.year || (year == target.year && month < target.month);
  }

  bool isAfterYearMonthOf(DateTime target) {
    return year > target.year || (year == target.year && month > target.month);
  }

  bool isSameYearMonthAs(DateTime target) {
    return year == target.year && month == target.month;
  }
}
