import 'package:flutter/material.dart';

import 'package:haenaedda/model/calendar_grid_layout.dart';
import 'package:haenaedda/model/date_record_set.dart';
import 'package:haenaedda/ui/goal_calendar/calendar_day_cell.dart';
import 'package:haenaedda/ui/goal_calendar/empty_cell.dart';

class CalendarGrid extends StatefulWidget {
  final CalendarGridLayout dateLayout;
  final DateRecordSet selectedDates;
  final void Function(DateTime) onCellTap;

  const CalendarGrid({
    super.key,
    required this.dateLayout,
    required this.selectedDates,
    required this.onCellTap,
  });

  @override
  State<CalendarGrid> createState() => _CalendarGridState();
}

class _CalendarGridState extends State<CalendarGrid> {
  @override
  Widget build(BuildContext context) {
    final dateLayout = widget.dateLayout;

    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      crossAxisCount: 7,
      childAspectRatio: 1,
      mainAxisSpacing: 10,
      crossAxisSpacing: 8,
      children: List.generate(dateLayout.totalCellCount, (index) {
        if (index < dateLayout.leadingBlanks) {
          return const EmptyCell();
        } else if (index <
            dateLayout.leadingBlanks + dateLayout.totalDaysOfMonth) {
          return CalendarDayCell(
            cellDate: dateLayout.dateFromIndex(index),
            hasRecord: widget.selectedDates.contains(
              dateLayout.dateFromIndex(index),
            ),
            onTap: (selectedDate) {
              widget.onCellTap(selectedDate);
            },
          );
        } else {
          return const EmptyCell();
        }
      }),
    );
  }
}
