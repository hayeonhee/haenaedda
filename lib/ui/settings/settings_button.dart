import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:haenaedda/gen_l10n/app_localizations.dart';
import 'package:haenaedda/model/goal.dart';
import 'package:haenaedda/model/goal_setting_action.dart';
import 'package:haenaedda/provider/record_provider.dart';
import 'package:haenaedda/theme/decorations/neumorphic_theme.dart';
import 'package:haenaedda/ui/settings/handlers/edit_goal_handler.dart';
import 'package:haenaedda/ui/settings/settings_bottom_modal.dart';

class SettingButton extends StatelessWidget {
  final Goal goal;

  const SettingButton({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () async {
        final recordProvider = context.read<RecordProvider>();
        final action = await showGeneralDialog<GoalSettingAction?>(
          context: context,
          barrierDismissible: true,
          barrierLabel: AppLocalizations.of(context)!.dismiss,
          barrierColor: Colors.black54,
          transitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (context, _, __) => SettingsBottomModal(goal: goal),
          transitionBuilder: (context, animation, _, child) {
            final offset = Tween<Offset>(
              begin: const Offset(0, 1),
              end: const Offset(0, 0),
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOut),
            );
            return SlideTransition(position: offset, child: child);
          },
        );
        if (!context.mounted) return;
        switch (action) {
          case GoalSettingAction.addGoal:
            await onAddGoalPressed(context);
          case GoalSettingAction.editGoalTitle:
            await onEditGoalTitlePressed(context, goal);
          case GoalSettingAction.resetRecordsOnly:
            recordProvider.removeRecordsOnly(goal.id);
          case GoalSettingAction.resetEntireGoal:
            recordProvider.resetEntireGoal(goal.id);
          case null:
        }
      },
      child: Container(
        width: 48,
        height: 48,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          shape: BoxShape.circle,
          boxShadow: NeumorphicTheme.buttonShadow(),
        ),
        child: Icon(
          Icons.settings,
          color: colorScheme.onSurface,
        ),
      ),
    );
  }
}
