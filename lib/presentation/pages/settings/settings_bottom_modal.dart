import 'package:flutter/material.dart';

import 'package:haenaedda/constants/dimensions.dart';
import 'package:haenaedda/gen_l10n/app_localizations.dart';
import 'package:haenaedda/model/goal.dart';
import 'package:haenaedda/model/goal_setting_action.dart';
import 'package:haenaedda/model/reset_type.dart';
import 'package:haenaedda/presentation/handlers/reset_goal_handler.dart';
import 'package:haenaedda/presentation/pages/settings/neumorphic_settings_tile.dart';
import 'package:haenaedda/presentation/widgets/bottom_right_button.dart';

class SettingsBottomModal extends StatelessWidget {
  final Goal goal;

  const SettingsBottomModal({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom:
                bottomRightButtonOffset.dy + bottomRightButtonSize.height + 16,
            right: bottomRightButtonOffset.dx,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NeumorphicSettingsTile(
                  title: l10n.reorderGoals,
                  onTap: () =>
                      Navigator.of(context).pop(GoalSettingAction.reorderGoal),
                ),
                NeumorphicSettingsTile(
                  title: l10n.editCurrentGoal,
                  onTap: () => Navigator.of(context)
                      .pop(GoalSettingAction.editGoalTitle),
                ),
                NeumorphicSettingsTile(
                  title: l10n.addGoal,
                  onTap: () =>
                      Navigator.of(context).pop(GoalSettingAction.addGoal),
                ),
                NeumorphicSettingsTile(
                  title: l10n.menuResetRecordsOnly,
                  titleColor: Theme.of(context).colorScheme.onErrorContainer,
                  onTap: () =>
                      onResetButtonTap(context, goal, ResetType.recordsOnly),
                ),
                NeumorphicSettingsTile(
                  title: l10n.menuResetEntireGoal,
                  titleColor: Theme.of(context).colorScheme.error,
                  onTap: () =>
                      onResetButtonTap(context, goal, ResetType.entireGoal),
                ),
                NeumorphicSettingsTile(
                  title: l10n.menuResetAllGoals,
                  titleColor: Theme.of(context).colorScheme.error,
                  onTap: () =>
                      onResetButtonTap(context, goal, ResetType.allGoals),
                ),
              ],
            ),
          ),
          BottomRightButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Icon(Icons.close, color: colorScheme.onSurface),
          ),
        ],
      ),
    );
  }
}
