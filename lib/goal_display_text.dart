import 'package:flutter/material.dart';

import 'package:haenaedda/constants/neumorphic_theme.dart';
import 'package:haenaedda/setting_button.dart';

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
                  // TODO: replace magic strings with constants
                  // TODO: add “Tap here to set your goal” with localization support
                  ? '눌러서 목표를 설정해보세요'
                  : controller.text,
              style: goalTextStyle.copyWith(
                color: controller.text.isEmpty ? Colors.grey : Colors.black,
              ),
            ),
          ),
        ),
        const SettingButton(),
      ],
    );
  }
}
