import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:haenaedda/domain/entities/goal.dart';
import 'package:haenaedda/domain/enums/goal_operation_result.dart';
import 'package:haenaedda/presentation/pages/edit_goal/edit_goal_page.dart';
import 'package:haenaedda/presentation/pages/edit_goal/goal_edit_result.dart';
import 'package:haenaedda/presentation/pages/goal_calendar/goal_calendar_page.dart';
import 'package:haenaedda/presentation/pages/reorder_goals/reorder_goals_page.dart';
import 'package:haenaedda/presentation/view_models/goal_view_models.dart';

Future<(AddGoalResult, Goal?)> showAddGoalFlow(
  BuildContext context, {
  bool replaceToGoalCalendar = false,
}) async {
  final goalViewModel = context.read<GoalViewModel>();
  final result = await Navigator.push<GoalEditResult>(
    context,
    MaterialPageRoute(
      builder: (_) => const EditGoalPage(mode: GoalEditMode.create),
    ),
  );

  if (!context.mounted) return (AddGoalResult.saveFailed, null);
  if (result == null) return (AddGoalResult.emptyInput, null);

  final trimmedTitle = result.title.trim();
  final (result: addResult, goal: newGoal) =
      await goalViewModel.addGoal(trimmedTitle);

  if (addResult == AddGoalResult.success && newGoal != null) {
    goalViewModel.setFocusedGoalForScroll(newGoal);
    if (replaceToGoalCalendar) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const GoalCalendarPage()),
      );
    }
  }
  return (addResult, newGoal);
}

Future<String?> onEditGoalTitlePressed(BuildContext context, Goal goal) async {
  final goalViewModel = context.read<GoalViewModel>();
  final result = await Navigator.of(context).push<GoalEditResult>(
    MaterialPageRoute(
      builder: (_) => EditGoalPage(
        initialText: goal.title,
        mode: GoalEditMode.update,
      ),
    ),
  );

  if (!context.mounted || result == null) return null;
  final trimmedTitle = result.title.trim();
  if (trimmedTitle.isEmpty && trimmedTitle == goal.title) return null;

  final (result: editResult, goal: renamedGoal) =
      await goalViewModel.renameGoal(goal, trimmedTitle);
  switch (editResult) {
    case RenameGoalResult.emptyInput:
      break;
    case RenameGoalResult.duplicate:
      break;
    case RenameGoalResult.saveFailed:
      break;
    case RenameGoalResult.notFound:
      break;
    case RenameGoalResult.success:
      if (renamedGoal != null) {
        goalViewModel.setFocusedGoalForScroll(renamedGoal);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const GoalCalendarPage()),
        );
        return renamedGoal.title;
      } else {
        debugPrint('️Failed to rename Goal');
      }
      break;
  }

  return null;
}

Future<void> reorderGoals(
  BuildContext context, {
  bool replaceToGoalCalendar = false,
}) async {
  final goalViewModel = context.read<GoalViewModel>();
  final result = await Navigator.push<List<Goal>>(
    context,
    MaterialPageRoute(builder: (_) => const ReorderGoalsPage()),
  );
  if (!context.mounted || result == null) return;

  await goalViewModel.updateGoalOrder(result);
  if (!context.mounted) return;
  if (replaceToGoalCalendar) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const GoalCalendarPage()),
    );
  }
}
