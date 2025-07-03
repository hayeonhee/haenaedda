import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:haenaedda/model/calendar_grid_layout.dart';
import 'package:haenaedda/ui/goal_calendar/empty_cell.dart';
import 'package:haenaedda/view_models/calendar_month_view_model.dart';

class GoalCalendarGrid extends StatelessWidget {
  final Widget Function(DateTime) cellBuilder;

  const GoalCalendarGrid({super.key, required this.cellBuilder});

  @override
  Widget build(BuildContext context) {
    return Selector<CalendarDateViewModel, DateTime>(
      selector: (_, dateViewModel) => dateViewModel.visibleDate,
      builder: (_, focusedMonth, __) {
        final layout = CalendarGridLayout(focusedMonth);
        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: layout.totalCellCount,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.05,
          ),
          itemBuilder: (context, index) {
            if (index < layout.leadingBlanks ||
                index >= layout.leadingBlanks + layout.totalDaysOfMonth) {
              return const EmptyCell();
            } else {
              final cellDate = layout.dateFromIndex(index);
              return cellBuilder(cellDate);
            }
          },
        );
      },
    );
  }
}
