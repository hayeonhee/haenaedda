import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:haenaedda/domain/entities/goal.dart';
import 'package:haenaedda/presentation/pages/goal_calendar/month_navigation_bar.dart';
import 'package:haenaedda/presentation/view_models/goal_view_models.dart';

class GoalCalendarHeader extends StatelessWidget {
  final Goal goal;

  const GoalCalendarHeader({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Selector<GoalViewModel, String?>(
          selector: (_, goalViewModel) =>
              goalViewModel.getGoalById(goal.id)?.title,
          builder: (context, title, _) {
            if (title == null) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 24,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.1,
                ),
                maxLines: 2,
              ),
            );
          },
        ),
        const SizedBox(height: 32),
        MonthNavigationBar(goalId: goal.id)
      ],
    );
  }
}
