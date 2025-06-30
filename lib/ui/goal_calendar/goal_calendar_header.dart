import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:haenaedda/model/goal.dart';
import 'package:haenaedda/provider/record_provider.dart';
import 'package:haenaedda/ui/goal_calendar/month_navigation_bar.dart';

class GoalCalendarHeader extends StatefulWidget {
  final Goal goal;
  final DateTime date;
  final void Function(DateTime)? onMonthChanged;

  const GoalCalendarHeader({
    super.key,
    required this.goal,
    required this.date,
    this.onMonthChanged,
  });

  @override
  State<GoalCalendarHeader> createState() => _GoalCalendarHeaderState();
}

class _GoalCalendarHeaderState extends State<GoalCalendarHeader> {
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _currentMonth = widget.date;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Selector<RecordProvider, String?>(
          selector: (_, provider) =>
              provider.getGoalById(widget.goal.id)?.title,
          builder: (context, title, _) {
            if (title == null) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 32,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
              ),
            );
          },
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
  }
}
