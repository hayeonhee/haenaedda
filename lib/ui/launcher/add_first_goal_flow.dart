import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:haenaedda/provider/record_provider.dart';
import 'package:haenaedda/ui/goal_calendar/edit_goal_page.dart';
import 'package:haenaedda/ui/goal_calendar/goal_calendar_page.dart';
import 'package:haenaedda/ui/goal_calendar/goal_edit_result.dart';
import 'package:haenaedda/ui/widgets/loading_indicator.dart';

class AddFirstGoalFlow extends StatefulWidget {
  const AddFirstGoalFlow({super.key});

  @override
  State<AddFirstGoalFlow> createState() => _AddFirstGoalFlowState();
}

class _AddFirstGoalFlowState extends State<AddFirstGoalFlow> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final result = await Navigator.push<GoalEditResult>(
        context,
        MaterialPageRoute(
          builder: (_) => const EditGoalPage(mode: GoalEditMode.create),
        ),
      );
      if (!mounted || result == null) return;
      final trimmed = result.title.trim();
      if (trimmed.isEmpty) return;

      final provider = context.read<RecordProvider>();
      final (result: addResult, goal: newGoal) =
          await provider.addGoal(trimmed);

      if (addResult == AddGoalResult.success && newGoal != null) {
        provider.setFocusedGoalForScroll(newGoal);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const GoalCalendarPage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: LoadingIndicator());
  }
}
