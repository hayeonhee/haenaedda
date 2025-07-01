import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:haenaedda/model/goal.dart';
import 'package:haenaedda/provider/record_provider.dart';
import 'package:haenaedda/ui/goal_calendar/month_navigation_bar.dart';

class GoalCalendarHeader extends StatefulWidget {
  final Goal goal;

  const GoalCalendarHeader({super.key, required this.goal});

  @override
  State<GoalCalendarHeader> createState() => _GoalCalendarHeaderState();
}

class _GoalCalendarHeaderState extends State<GoalCalendarHeader> {
  @override
  Widget build(BuildContext context) {
    final firstRecordMonth =
        context.read<RecordProvider>().findFirstRecordedMonth(widget.goal.id);
    if (firstRecordMonth == null) return const SizedBox.shrink();

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
        MonthNavigationBar(firstRecordMonth: firstRecordMonth)
      ],
    );
  }
}
