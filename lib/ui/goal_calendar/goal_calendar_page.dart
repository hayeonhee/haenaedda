import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:haenaedda/model/goal.dart';
import 'package:haenaedda/provider/record_provider.dart';
import 'package:haenaedda/ui/goal_calendar/edit_goal_page.dart';
import 'package:haenaedda/ui/goal_calendar/goal_edit_result.dart';
import 'package:haenaedda/ui/goal_calendar/goal_pager.dart';

class GoalCalendarPage extends StatefulWidget {
  const GoalCalendarPage({super.key});

  @override
  State<GoalCalendarPage> createState() => _GoalCalendarPageState();
}

class _GoalCalendarPageState extends State<GoalCalendarPage> {
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<RecordProvider>();
      final isLoaded = provider.isLoaded;
      final goals = provider.sortedGoals;
      if (isLoaded && goals.isEmpty) {
        _showEditGoalDialog();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final goals =
        context.select<RecordProvider, List<Goal>>((p) => p.sortedGoals);
    return Scaffold(
      body: SafeArea(
        child: GoalPager(goals: goals, controller: _pageController),
      ),
    );
  }

  Future<void> _showEditGoalDialog() async {
    final provider = context.read<RecordProvider>();
    final result = await Navigator.push<GoalEditResult>(
      context,
      MaterialPageRoute(
        builder: (_) => const EditGoalPage(mode: GoalEditMode.create),
      ),
    );

    if (!context.mounted || result == null) return;
    final trimmed = result.title.trim();
    if (trimmed.isEmpty) return;
    final (result: addResult, goal: newGoal) = await provider.addGoal(trimmed);
    if (addResult == AddGoalResult.success && newGoal != null) {
      provider.setFocusedGoalForScroll(newGoal);
      setState(() {});
    }
  }
}
