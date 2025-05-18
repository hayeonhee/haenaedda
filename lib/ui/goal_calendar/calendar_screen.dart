import 'package:flutter/material.dart';

import 'package:haenaedda/model/calendar_grid_layout.dart';
import 'package:haenaedda/ui/goal_calendar/calendar_day_cell.dart';
import 'package:haenaedda/ui/goal_calendar/empty_cell.dart';

class CalendarScreen extends StatefulWidget {
  final CalendarGridLayout dateLayout;
  final Set<DateTime> selectedDates;
  final void Function(DateTime) onCellTap;

  const CalendarScreen({
    super.key,
    required this.dateLayout,
    required this.selectedDates,
    required this.onCellTap,
  });

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  @override
  Widget build(BuildContext context) {
    final dateLayout = widget.dateLayout;

    return GridView.count(
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
