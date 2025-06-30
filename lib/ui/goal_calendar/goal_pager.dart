import 'package:flutter/material.dart';

import 'package:haenaedda/model/goal.dart';
import 'package:haenaedda/ui/goal_calendar/goal_calendar_content.dart';

class GoalPager extends StatelessWidget {
  final List<Goal> goals;
  final PageController controller;
  final void Function(String goalId, DateTime date) onCellTap;
  final void Function(int index)? onPageChanged;

  const GoalPager({
    super.key,
    required this.goals,
    required this.controller,
    required this.onCellTap,
    this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      scrollDirection: Axis.vertical,
      controller: controller,
      physics: const BouncingScrollPhysics(),
      itemCount: goals.length,
      onPageChanged: (index) {
        if (onPageChanged != null && index < goals.length) {
          onPageChanged?.call(index);
        }
      },
      itemBuilder: (context, index) => GoalCalendarContent(
        key: ValueKey(goals[index].id),
        goal: goals[index],
        onCellTap: (goalId, date) => onCellTap(goalId, date),
      ),
    );
  }
}
