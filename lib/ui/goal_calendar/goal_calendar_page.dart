import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:haenaedda/model/goal.dart';
import 'package:haenaedda/provider/record_provider.dart';
import 'package:haenaedda/ui/goal_calendar/edit_goal_page.dart';
import 'package:haenaedda/ui/goal_calendar/goal_pager.dart';

class GoalCalendarPage extends StatefulWidget {
  const GoalCalendarPage({super.key});

  @override
  State<GoalCalendarPage> createState() => _GoalCalendarPageState();
}

class _GoalCalendarPageState extends State<GoalCalendarPage> {
  final PageController _pageController = PageController();
  bool _hasRedirected = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<RecordProvider>();
      if (provider.isLoaded && provider.hasNoGoal) {
        _navigateToAddGoalPage();
      }
    });
  }

  Future<void> _navigateToAddGoalPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EditGoalPage()),
    );
    if (mounted && result is String && result.trim().isNotEmpty) {
      final provider = context.read<RecordProvider>();
      final (result: addResult, goal: newGoal) = await provider.addGoal(result);
      if (newGoal != null) provider.setFocusedGoalForScroll(newGoal);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoaded =
        context.select<RecordProvider, bool>((provider) => provider.isLoaded);
    final goals = context
        .select<RecordProvider, List<Goal>>((provider) => provider.sortedGoals);

    if (!isLoaded) return _buildLoadingIndicator();
    if (goals.isEmpty && !_hasRedirected) {
      _hasRedirected = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted && goals.isEmpty) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const EditGoalPage()),
          );
        }
      });
    }
    if (goals.isEmpty) return _buildLoadingIndicator();
    return Scaffold(
      body: SafeArea(
        child: GoalPager(goals: goals, controller: _pageController),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
