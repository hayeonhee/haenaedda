import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:haenaedda/model/goal.dart';
import 'package:haenaedda/provider/record_provider.dart';
import 'package:haenaedda/ui/goal_calendar/header_section/month_navigation_bar.dart';

class CalendarHeaderSection extends StatefulWidget {
  final Goal goal;
  final DateTime date;
  final void Function(DateTime)? onMonthChanged;

  const CalendarHeaderSection({
    super.key,
    required this.goal,
    required this.date,
    this.onMonthChanged,
  });

  @override
  State<CalendarHeaderSection> createState() => _CalendarHeaderSectionState();
}

class _CalendarHeaderSectionState extends State<CalendarHeaderSection> {
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _currentMonth = widget.date;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Selector<RecordProvider, Goal?>(
        selector: (_, provider) => provider.getGoalById(widget.goal.id),
        builder: (context, goal, child) {
          if (goal == null) return const SizedBox.shrink();
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  goal.title,
                  style: TextStyle(
                    fontSize: 32,
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                ),
              ),
              const SizedBox(height: 32),
              MonthNavigationBar(
                referenceDate: _currentMonth,
                onMonthChanged: (newMonth) {
                  setState(() {
                    _currentMonth = newMonth;
                  });
                  widget.onMonthChanged?.call(newMonth);
                },
              ),
            ],
          );
        });
  }
}
