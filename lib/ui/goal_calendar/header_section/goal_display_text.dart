import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:haenaedda/gen_l10n/app_localizations.dart';
import 'package:haenaedda/model/goal.dart';
import 'package:haenaedda/provider/record_provider.dart';
import 'package:haenaedda/theme/decorations/neumorphic_theme.dart';
import 'package:haenaedda/ui/settings/settings_button.dart';

class GoalDisplayText extends StatelessWidget {
  final Goal goal;
  final double buttonHeight;
  final TextStyle goalTextStyle;
  final VoidCallback onStartEditing;
  final TextEditingController controller;

  const GoalDisplayText({
    super.key,
    required this.goal,
    required this.buttonHeight,
    required this.goalTextStyle,
    required this.onStartEditing,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final updatedGoal = context.select<RecordProvider, Goal>(
      (provider) => provider.getGoalById(goal.id) ?? goal,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: onStartEditing,
          child: Container(
            height: buttonHeight,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: NeumorphicTheme.pressedBoxDecoration(context),
            alignment: Alignment.centerLeft,
            child: Text(
              updatedGoal.title.isEmpty
                  ? AppLocalizations.of(context)!.goalSetupHint
                  : updatedGoal.title,
              style: goalTextStyle.copyWith(
                color: updatedGoal.title.isEmpty
                    ? Theme.of(context).colorScheme.outline
                    : null,
              ),
            ),
          ),
        ),
        SettingButton(goal: goal),
      ],
    );
  }
}
