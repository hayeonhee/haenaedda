import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:haenaedda/gen_l10n/app_localizations.dart';
import 'package:haenaedda/model/calendar_grid_layout.dart';
import 'package:haenaedda/model/goal.dart';
import 'package:haenaedda/provider/record_provider.dart';
import 'package:haenaedda/ui/goal_calendar/calendar_screen.dart';
import 'package:haenaedda/ui/goal_calendar/header_section/calendar_header_section.dart';
import 'package:haenaedda/ui/widgets/section_divider.dart';

class MyCalendarPage extends StatefulWidget {
  final Goal goal;

  const MyCalendarPage({super.key, required this.goal});

  @override
  State<MyCalendarPage> createState() => _MyCalendarPageState();
}

class _MyCalendarPageState extends State<MyCalendarPage> {
  final DateTime _focusedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final recordProvider = context.watch<RecordProvider>();
    final selectedDates = recordProvider.getRecords(widget.goal.id);
    final dateLayout = CalendarGridLayout(_focusedDate);
    final daysOfWeek = AppLocalizations.of(context)!.shortWeekdays.split(',');

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                const SizedBox(height: 30),
                CalendarHeaderSection(
                  goal: widget.goal,
                  date: _focusedDate,
                  onGoalEditSubmitted: (String newGoal) {
                    recordProvider.renameGoal(widget.goal.id, newGoal);
                  },
                ),
                const SizedBox(height: 24),
                const SectionDivider(),
                const SizedBox(height: 40),
                Row(
                  children: List.generate(daysOfWeek.length, (index) {
                    return Expanded(
                      child: Text(
                        daysOfWeek[index],
                        style: TextStyle(
                          fontSize: 15,
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),
                CalendarScreen(
                  dateLayout: dateLayout,
                  selectedDates: selectedDates,
                  onCellTap: (selectedDate) =>
                      recordProvider.toggleRecord(widget.goal.id, selectedDate),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
