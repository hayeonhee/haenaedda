import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:haenaedda/model/goal.dart';
import 'package:haenaedda/theme/app_spacing.dart';
import 'package:haenaedda/presentation/pages/goal_calendar/calendar_day_cell.dart';
import 'package:haenaedda/presentation/pages/goal_calendar/goal_calendar_grid.dart';
import 'package:haenaedda/presentation/pages/goal_calendar/goal_calendar_header.dart';
import 'package:haenaedda/presentation/pages/goal_calendar/weekday_row.dart';
import 'package:haenaedda/presentation/widgets/section_divider.dart';
import 'package:haenaedda/presentation/view_models/goal_view_models.dart';
import 'package:haenaedda/presentation/view_models/record_view_model.dart';

class GoalCalendarContent extends StatefulWidget {
  final Goal goal;
  final void Function(String goalId, DateTime date) onCellTap;

  const GoalCalendarContent({
    super.key,
    required this.goal,
    required this.onCellTap,
  });

  @override
  State<GoalCalendarContent> createState() => _GoalCalendarContentState();
}

class _GoalCalendarContentState extends State<GoalCalendarContent> {
  @override
  Widget build(BuildContext context) {
    final goalViewModel = context.select<GoalViewModel, Goal?>(
      (goalViewModel) => goalViewModel.getGoalById(widget.goal.id),
    );
    if (goalViewModel == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.medium),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.doubleExtraLarge),
          GoalCalendarHeader(goal: goalViewModel),
          const SizedBox(height: AppSpacing.large),
          const SectionDivider(),
          const SizedBox(height: AppSpacing.doubleExtraLarge),
          const WeekdayRow(),
          const SizedBox(height: AppSpacing.large),
          Expanded(
            child: GoalCalendarGrid(
              cellBuilder: (cellDate) {
                return Selector<RecordViewModel, bool>(
                  selector: (_, recordViewModel) =>
                      recordViewModel
                          .getRecords(goalViewModel.id)
                          ?.contains(cellDate) ??
                      false,
                  builder: (_, hasRecord, __) => CalendarDayCell(
                    key: ValueKey(cellDate),
                    goalId: goalViewModel.id,
                    cellDate: cellDate,
                    hasRecord: hasRecord,
                    onTap: (goalId, date) => widget.onCellTap(goalId, cellDate),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
