import 'package:flutter/material.dart';

import 'package:haenaedda/model/calendar_grid_layout.dart';
import 'package:haenaedda/ui/goal_calendar/empty_cell.dart';

class CalendarGrid extends StatelessWidget {
  final CalendarGridLayout dateLayout;
  final Widget Function(DateTime) cellBuilder;

  const CalendarGrid({
    super.key,
    required this.dateLayout,
    required this.cellBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: dateLayout.totalCellCount,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
        ),
        itemBuilder: (context, index) {
          if (index < dateLayout.leadingBlanks ||
              index >= dateLayout.leadingBlanks + dateLayout.totalDaysOfMonth) {
            return const EmptyCell();
          } else {
            final cellDate = dateLayout.dateFromIndex(index);
            return cellBuilder(cellDate);
          }
        });
  }
}
