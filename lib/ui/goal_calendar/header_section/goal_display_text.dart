import 'package:flutter/material.dart';

import 'package:haenaedda/constants/neumorphic_theme.dart';
import 'package:haenaedda/gen_l10n/app_localizations.dart';
import 'package:haenaedda/ui/settings/settings_button.dart';

class GoalDisplayText extends StatelessWidget {
  final double buttonHeight;
  final TextStyle goalTextStyle;
  final VoidCallback onStartEditing;
  final TextEditingController controller;

  const GoalDisplayText({
    super.key,
    required this.buttonHeight,
    required this.goalTextStyle,
    required this.onStartEditing,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
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
              controller.text.isEmpty
                  ? AppLocalizations.of(context)!.goalSetupHint
                  : controller.text,
              style: goalTextStyle.copyWith(
                color: controller.text.isEmpty
                    ? Theme.of(context).colorScheme.outline
                    : null,
              ),
            ),
          ),
        ),
        const SettingButton(),
      ],
    );
  }
}
