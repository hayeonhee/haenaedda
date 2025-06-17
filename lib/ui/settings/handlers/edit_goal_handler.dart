import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:haenaedda/provider/record_provider.dart';
import 'package:haenaedda/ui/goal_calendar/edit_goal_page.dart';
import 'package:haenaedda/ui/goal_calendar/goal_calendar_page.dart';

Future<void> onAddGoalPressed(BuildContext context) async {
  final recordProvider = context.read<RecordProvider>();
  final inputText = await Navigator.push<String>(
    context,
    MaterialPageRoute(builder: (_) => const EditGoalPage()),
  );

  if (!context.mounted || inputText == null) return;
  final (result: addResult, goal: newGoal) =
      await recordProvider.addGoal(inputText);
  switch (addResult) {
    case AddGoalResult.emptyInput:
      break;
    case AddGoalResult.duplicate:
      break;
    case AddGoalResult.saveFailed:
      break;
    case AddGoalResult.success:
      if (newGoal != null) {
        recordProvider.setFocusedGoalForScroll(newGoal);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const GoalCalendarPage()),
        );
      } else {
        debugPrint('⚠️ Failed to add newGoal: newGoal is null');
      }
      break;
  }
}
