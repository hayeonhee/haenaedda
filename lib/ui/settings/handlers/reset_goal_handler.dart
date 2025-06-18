import 'package:flutter/material.dart';
import 'package:haenaedda/theme/buttons.dart';
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
  final colorScheme = Theme.of(context).colorScheme;
  final l10n = AppLocalizations.of(context)!;
  final (title, message) = switch (type) {
    ResetType.recordsOnly => (
        l10n.resetRecordsOnly,
        l10n.resetRecordsOnlyMessage
      ),
    ResetType.entireGoal => (l10n.resetEntireGoal, l10n.resetEntireGoalMessage),
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
                        style: getButtonStyle(
                          background: colorScheme.outline,
                          foreground: colorScheme.onSurfaceVariant,
                        ),
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
                        style: getButtonStyle(
                          background: colorScheme.onError,
                          foreground: colorScheme.error,
                        ),
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text(
                          l10n.reset,
                          style: getButtonTextStyle(color: colorScheme.error),
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
  final removedGoalIndex = provider.getNextFocusGoalIndexAfterRemoval(goal.id);
  final result = await provider.resetEntireGoal(goal.id);

  if (!context.mounted) return;

  switch (result) {
    case ResetEntireGoalResult.success:
      if (removedGoalIndex != null &&
          removedGoalIndex < provider.sortedGoals.length) {
        final nextGoal = provider.sortedGoals[removedGoalIndex];
        provider.setFocusedGoalForScroll(nextGoal);
      }
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
