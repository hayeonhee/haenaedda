import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:haenaedda/calendar_header_section.dart';
import 'package:haenaedda/calendar_screen.dart';
import 'package:haenaedda/model/calendar_grid_layout.dart';
import 'package:haenaedda/record_provider.dart';

class MyCalendarPage extends StatefulWidget {
  final String goalId;

  const MyCalendarPage({super.key, required this.goalId});

  @override
  State<MyCalendarPage> createState() => _MyCalendarPageState();
}

class _MyCalendarPageState extends State<MyCalendarPage> {
  // TODO: Change app language based on user's device settings
  final daysOfWeek = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  // TODO: Always display the current month in this version
  DateTime focusedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final recordProvider = context.watch<RecordProvider>();
    final selectedDates = recordProvider.getRecords(widget.goalId);
    final dateLayout = CalendarGridLayout(focusedDate);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              const SizedBox(height: 30),
              CalendarHeaderSection(
                goal: widget.goal,
                date: focusedDate,
                // TODO: Implement the save functionality
                onGoalEditSubmitted: (String value) {},
              ),
              const SizedBox(height: 24),
              const Divider(thickness: 1),
              const SizedBox(height: 32),
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
                    recordProvider.toggleRecord(widget.goalId, selectedDate),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
