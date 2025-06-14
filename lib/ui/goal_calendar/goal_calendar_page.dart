import 'package:flutter/material.dart';
import 'package:haenaedda/model/goal.dart';
import 'package:haenaedda/ui/goal_calendar/goal_pager.dart';

class GoalCalendarPage extends StatelessWidget {
  final List<Goal> goals;

  const GoalCalendarPage({super.key, required this.goals});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: GoalPager(goals: goals)),
    );
  }
}
