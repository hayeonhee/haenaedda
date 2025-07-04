import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:haenaedda/gen_l10n/app_localizations.dart';
import 'package:haenaedda/model/goal.dart';
import 'package:haenaedda/theme/buttons.dart';
import 'package:haenaedda/ui/goal_calendar/edit_goal_page.dart';
import 'package:haenaedda/ui/goal_calendar/goal_calendar_page.dart';
import 'package:haenaedda/ui/goal_calendar/goal_edit_result.dart';
import 'package:haenaedda/view_models/goal_result.dart';
import 'package:haenaedda/view_models/goal_view_models.dart';

Future<void> onDiscardDuringInput(
    BuildContext context, TextEditingController controller) async {
  final trimmedText = controller.text.trim();
  if (trimmedText.isEmpty) {
    Navigator.of(context).pop();
    return;
  }
  final discardConfirmed = await confirmDiscardChanges(context);
  if (!context.mounted) return;
  if (discardConfirmed == true) {
    controller.clear();
    Navigator.of(context).pop();
  }
}

Future<bool?> confirmDiscardChanges(BuildContext context) {
  final colorScheme = Theme.of(context).colorScheme;
  final l10n = AppLocalizations.of(context)!;

  return showGeneralDialog(
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
                l10n.unsavedChanges,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.unsavedChangesMessage,
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
                        onPressed: () => Navigator.of(context).pop(false),
                        child:
                            Text(l10n.keepEditing, style: getButtonTextStyle()),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: TextButton(
                        style: getDestructiveButtonStyle(context),
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text(l10n.leave, style: getButtonTextStyle()),
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
