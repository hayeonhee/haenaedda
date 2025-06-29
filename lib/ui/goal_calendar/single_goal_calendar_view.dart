import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:haenaedda/gen_l10n/app_localizations.dart';
import 'package:haenaedda/model/calendar_grid_layout.dart';
import 'package:haenaedda/model/goal.dart';
import 'package:haenaedda/provider/record_provider.dart';
import 'package:haenaedda/ui/goal_calendar/calendar_day_cell.dart';
import 'package:haenaedda/ui/goal_calendar/calendar_grid.dart';
import 'package:haenaedda/ui/goal_calendar/header_section/calendar_header_section.dart';
import 'package:haenaedda/ui/widgets/section_divider.dart';

class SingleGoalCalendarView extends StatefulWidget {
  final Goal goal;
  final void Function(String goalId, DateTime date) onCellTap;

  const SingleGoalCalendarView({
    super.key,
    required this.goal,
    required this.onCellTap,
  });

  @override
  State<SingleGoalCalendarView> createState() => _SingleGoalCalendarViewState();
}

class _SingleGoalCalendarViewState extends State<SingleGoalCalendarView> {
  DateTime _focusedDate = DateTime.now();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final dateLayout = CalendarGridLayout(_focusedDate);
    final daysOfWeek = AppLocalizations.of(context)!.shortWeekdays.split(',');
    final goal = context.select<RecordProvider, Goal?>(
      (provider) => provider.getGoalById(widget.goal.id),
    );
    if (goal == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 56),
          CalendarHeaderSection(
            goal: goal,
            date: _focusedDate,
            onMonthChanged: (DateTime newMonth) {
              setState(() => _focusedDate = newMonth);
            },
          ),
          const SizedBox(height: 24),
          const SectionDivider(),
          const SizedBox(height: 48),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              daysOfWeek.length,
              (index) {
                return Text(
                  daysOfWeek[index],
                  style: TextStyle(
                    fontSize: 15,
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          CalendarGrid(
            dateLayout: dateLayout,
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
        ],
      ),
    );
  }
}
