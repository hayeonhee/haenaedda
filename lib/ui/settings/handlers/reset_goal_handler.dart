import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:haenaedda/gen_l10n/app_localizations.dart';
import 'package:haenaedda/model/goal.dart';
import 'package:haenaedda/model/reset_type.dart';
import 'package:haenaedda/provider/record_provider.dart';
import 'package:haenaedda/ui/goal_calendar/goal_calendar_page.dart';

Future<void> showResetFailureDialog(BuildContext context, ResetType type) {
  final l10n = AppLocalizations.of(context)!;
  final message = switch (type) {
    ResetType.recordsOnly => l10n.resetFailure,
    ResetType.entireGoal => l10n.resetPartialFailureGoal,
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
  final l10n = AppLocalizations.of(context)!;
  final message = switch (type) {
    ResetType.recordsOnly => l10n.resetRecordsOnlyMessage,
    ResetType.entireGoal => l10n.resetEntireGoalMessage,
  };

  return await showDialog<bool?>(
    context: context,
    builder: (context) => AlertDialog(
      contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      actionsPadding: const EdgeInsets.fromLTRB(0, 16, 16, 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Text(
        message,
        style: const TextStyle(fontSize: 16, height: 1.5),
        textAlign: TextAlign.center,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            AppLocalizations.of(context)!.cancel,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(
            AppLocalizations.of(context)!.reset,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ),
      ],
      actionsAlignment: MainAxisAlignment.center,
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
      await _handleRecordOnlyReset(context, goal);
      break;
    case ResetType.entireGoal:
      await _handleEntireGoalReset(context, goal);
      break;
  }
}

Future<void> _handleRecordOnlyReset(BuildContext context, Goal goal) async {
  final provider = context.read<RecordProvider>();
  final success = await provider.removeRecordsOnly(goal.id);

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

Future<void> _handleEntireGoalReset(BuildContext context, Goal goal) async {
  final provider = context.read<RecordProvider>();
  final result = await provider.resetEntireGoal(goal.id);
  if (!context.mounted) return;

  switch (result) {
    case ResetEntireGoalResult.success:
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const GoalCalendarPage()),
      );
      break;
    case ResetEntireGoalResult.recordFailed:
      await showResetFailureDialog(context, ResetType.recordsOnly);
      break;
    case ResetEntireGoalResult.goalFailed:
      await showResetFailureDialog(context, ResetType.entireGoal);
      break;
  }
}
