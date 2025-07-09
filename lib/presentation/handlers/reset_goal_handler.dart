import 'package:flutter/material.dart';
import 'package:haenaedda/presentation/view_models/goal_scroll_focus_manager.dart';
import 'package:provider/provider.dart';

import 'package:haenaedda/domain/entities/goal.dart';
import 'package:haenaedda/domain/enums/goal_operation_result.dart';
import 'package:haenaedda/domain/enums/reset_type.dart';
import 'package:haenaedda/gen_l10n/app_localizations.dart';
import 'package:haenaedda/presentation/pages/goal_calendar/goal_calendar_page.dart';
import 'package:haenaedda/presentation/view_models/goal_view_models.dart';
import 'package:haenaedda/presentation/view_models/record_view_model.dart';
import 'package:haenaedda/theme/buttons.dart';

Future<void> showResetFailureDialog(BuildContext context, ResetType type) {
  final l10n = AppLocalizations.of(context)!;
  final message = switch (type) {
    ResetType.recordsOnly => l10n.resetFailure,
    ResetType.entireGoal => l10n.resetPartialFailureGoal,
    ResetType.allGoals => l10n.resetFailure,
  };

  return showDialog<void>(
    context: context,
    builder: (_) => AlertDialog(
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.dismiss),
        ),
      ],
    ),
  );
}

Future<bool?> showResetConfirmDialog(
  BuildContext context,
  Goal goal,
  ResetType type,
) async {
  final colorScheme = Theme.of(context).colorScheme;
  final l10n = AppLocalizations.of(context)!;
  final (title, message) = switch (type) {
    ResetType.recordsOnly => (
        l10n.resetRecordsOnly,
        l10n.resetRecordsOnlyMessage
      ),
    ResetType.entireGoal => (l10n.resetEntireGoal, l10n.resetEntireGoalMessage),
    ResetType.allGoals => (l10n.resetAllGoals, l10n.resetAllGoalsMessage),
  };

  return await showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: l10n.dismiss,
    barrierColor: Colors.black.withValues(alpha: 0.2),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, _, __) => Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: TextButton(
                        style: getNeutralButtonStyle(context),
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          l10n.cancel,
                          style: getButtonTextStyle(),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: TextButton(
                        style: getDestructiveButtonStyle(context),
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text(
                          l10n.reset,
                          style: getButtonTextStyle(color: colorScheme.onError),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Future<void> onResetButtonTap(
  BuildContext context,
  Goal goal,
  ResetType type,
) async {
  if (!context.mounted) return;
  final confirmed = await showResetConfirmDialog(context, goal, type);

  if (!context.mounted || confirmed != true) return;
  switch (type) {
    case ResetType.recordsOnly:
      await handleResetRecordsOnly(context, goal);
      break;
    case ResetType.entireGoal:
      await handleResetEntireGoal(context, goal);
      break;
    case ResetType.allGoals:
      await handleResetAllGoals(context);
      break;
  }
}

Future<void> handleResetRecordsOnly(BuildContext context, Goal goal) async {
  final recordViewModel = context.read<RecordViewModel>();
  final success = await recordViewModel.removeRecords(goal.id);

  if (!context.mounted) return;
  if (success) {
    Navigator.of(context).pop();
  } else {
    await showResetFailureDialog(
      context,
      ResetType.recordsOnly,
    );
  }
}

Future<void> handleResetEntireGoal(BuildContext context, Goal goal) async {
  final goalViewModel = context.read<GoalViewModel>();
  final recordViewModel = context.read<RecordViewModel>();
  final scrollFocusManager = context.read<GoalScrollFocusManager>();
  final removedGoalIndex =
      goalViewModel.getNextFocusGoalIndexAfterRemoval(goal.id);
  final isGoalReset = await goalViewModel.resetEntireGoal(goal.id);

  if (!context.mounted) return;
  switch (isGoalReset) {
    case ResetEntireGoalResult.success:
      final isRecordReset = await recordViewModel.removeRecords(goal.id);
      if (isRecordReset) {
        if (removedGoalIndex != null &&
            removedGoalIndex < goalViewModel.sortedGoals.length) {
          final nextGoal = goalViewModel.sortedGoals[removedGoalIndex];
          scrollFocusManager.set(nextGoal);
        }
        if (!context.mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const GoalCalendarPage()),
        );
      } else {
        final remainingGoalIds = goalViewModel.goals.map((g) => g.id).toList();
        await recordViewModel.removeAllUnlinkedRecords(remainingGoalIds);
      }
      break;
    case ResetEntireGoalResult.recordFailed:
      await showResetFailureDialog(context, ResetType.recordsOnly);
      break;
    case ResetEntireGoalResult.goalFailed:
      await showResetFailureDialog(context, ResetType.entireGoal);
      break;
  }
}

Future<void> handleResetAllGoals(BuildContext context) async {
  final goalViewModel = context.read<GoalViewModel>();
  final recordViewModel = context.read<RecordViewModel>();
  final result = await goalViewModel.resetAllGoals();
  if (!context.mounted) return;
  switch (result) {
    case ResetAllGoalsResult.success:
      final remainingGoalIds = goalViewModel.goals.map((g) => g.id).toList();
      await recordViewModel.removeAllUnlinkedRecords(remainingGoalIds);
      if (!context.mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const GoalCalendarPage()),
      );
      break;
    case ResetAllGoalsResult.failure:
      await showResetFailureDialog(context, ResetType.allGoals);
      break;
  }
}
