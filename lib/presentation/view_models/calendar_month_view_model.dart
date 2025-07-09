import 'package:flutter/material.dart';
import 'package:haenaedda/extensions/date_compare_extension.dart';

class CalendarDateViewModel with ChangeNotifier {
  late final DateTime _initialVisibleDate;
  late DateTime _visibleDate;

  CalendarDateViewModel() {
    final now = DateTime.now();
    _initialVisibleDate = DateTime(now.year, now.month);
    _visibleDate = _initialVisibleDate;
  }

  DateTime get visibleDate => _visibleDate;
  DateTime get initialVisibleDate => _initialVisibleDate;

  void updateDate(DateTime newDate) {
    _visibleDate = newDate;
    notifyListeners();
  }

  bool canGoToPrevious(DateTime firstRecordedDate) {
    return visibleDate.isAfterYearMonthOf(firstRecordedDate);
  }

  bool canGoToNext(DateTime firstRecordedDate) {
    return visibleDate.isBeforeYearMonthOf(initialVisibleDate);
  }
}
