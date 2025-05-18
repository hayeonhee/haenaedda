import 'package:flutter/material.dart';

import 'package:haenaedda/model/goal.dart';
import 'package:haenaedda/ui/goal_calendar/header_section/goal_display_text.dart';
import 'package:haenaedda/ui/goal_calendar/header_section/goal_edit_field.dart';
import 'package:haenaedda/ui/goal_calendar/header_section/month_navigation_bar.dart';

class CalendarHeaderSection extends StatefulWidget {
  final Goal goal;
  final DateTime date;
  final ValueChanged<String> onGoalEditSubmitted;

  const CalendarHeaderSection({
    super.key,
    required this.goal,
    required this.date,
    required this.onGoalEditSubmitted,
  });

  @override
  State<CalendarHeaderSection> createState() => _CalendarHeaderSectionState();
}

class _CalendarHeaderSectionState extends State<CalendarHeaderSection> {
  bool _isEditing = false;
  late final TextEditingController _controller;
  final int maxLength = 20;
  final double buttonHeight = 48;
  final goalTextStyle = const TextStyle(
    fontSize: 18,
    height: 1.3,
    color: Colors.white,
    fontWeight: FontWeight.bold,
  );

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.goal.name);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _isEditing
            ? GoalEditField(
                buttonHeight: buttonHeight,
                controller: _controller,
                goalTextStyle: goalTextStyle,
                onSave: () {
                  final trimmedValue = _controller.text.trim();
                  if (trimmedValue.isNotEmpty) {
                    widget.onGoalEditSubmitted(trimmedValue);
                  }
                  setState(() => _isEditing = false);
                },
              )
            : GoalDisplayText(
                buttonHeight: buttonHeight,
                controller: _controller,
                goalTextStyle: goalTextStyle,
                onStartEditing: () {
                  setState(() => _isEditing = true);
                },
              ),
        const SizedBox(height: 24),
        MonthNavigationBar(date: widget.date),
      ],
    );
  }
}
