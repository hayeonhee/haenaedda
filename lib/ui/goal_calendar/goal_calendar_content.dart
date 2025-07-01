import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:haenaedda/model/goal.dart';
import 'package:haenaedda/provider/record_provider.dart';
import 'package:haenaedda/theme/app_spacing.dart';
import 'package:haenaedda/ui/goal_calendar/calendar_day_cell.dart';
import 'package:haenaedda/ui/goal_calendar/goal_calendar_grid.dart';
import 'package:haenaedda/ui/goal_calendar/goal_calendar_header.dart';
import 'package:haenaedda/ui/goal_calendar/weekday_row.dart';
import 'package:haenaedda/ui/widgets/section_divider.dart';

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
    final goal = context.select<RecordProvider, Goal?>(
      (provider) => provider.getGoalById(widget.goal.id),
    );
    if (goal == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.medium),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.doubleExtraLarge),
          GoalCalendarHeader(goal: goal),
          const SizedBox(height: AppSpacing.large),
          const SectionDivider(),
          const SizedBox(height: AppSpacing.doubleExtraLarge),
          const WeekdayRow(),
          const SizedBox(height: AppSpacing.large),
          Expanded(
            child: GoalCalendarGrid(
              cellBuilder: (cellDate) {
                return Selector<RecordProvider, bool>(
                  selector: (_, provider) =>
                      provider.getRecords(goal.id)?.contains(cellDate) ?? false,
                  builder: (_, hasRecord, __) => CalendarDayCell(
                    key: ValueKey(cellDate),
                    goalId: goal.id,
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
