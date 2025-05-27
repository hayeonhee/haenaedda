import 'package:flutter/material.dart';
import 'package:haenaedda/theme/decorations/neumorphic_theme.dart';

class GoalEditField extends StatefulWidget {
  final double buttonHeight;
  final TextStyle goalTextStyle;
  final VoidCallback onSave;
  final TextEditingController controller;

  const GoalEditField({
    super.key,
    required this.buttonHeight,
    required this.goalTextStyle,
    required this.onSave,
    required this.controller,
  });

  @override
  State<GoalEditField> createState() => _GoalEditFieldState();
}

class _GoalEditFieldState extends State<GoalEditField> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: widget.buttonHeight,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: NeumorphicTheme.pressedBoxDecoration(context),
            alignment: Alignment.centerLeft,
            child: TextField(
              controller: widget.controller,
              style: widget.goalTextStyle,
              autofocus: true,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              cursorColor: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: widget.onSave,
          child: Container(
            height: widget.buttonHeight,
            width: widget.buttonHeight,
            decoration: NeumorphicTheme.raisedBoxDecoration(context),
            child: const Icon(Icons.check, size: 20),
          ),
        ),
      ],
    );
  }
}
