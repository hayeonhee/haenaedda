import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:haenaedda/model/goal.dart';
import 'package:haenaedda/provider/record_provider.dart';
import 'package:haenaedda/ui/goal_calendar/header_section/month_navigation_bar.dart';
import 'package:haenaedda/theme/decorations/neumorphic_theme.dart';
import 'package:haenaedda/ui/settings/settings_button.dart';

class CalendarHeaderSection extends StatefulWidget {
  final Goal goal;
  final DateTime date;
  final ValueChanged<String> onGoalEditSubmitted;
  final void Function(DateTime)? onMonthChanged;

  const CalendarHeaderSection({
    super.key,
    required this.goal,
    required this.date,
    required this.onGoalEditSubmitted,
    this.onMonthChanged,
  });

  @override
  State<CalendarHeaderSection> createState() => _CalendarHeaderSectionState();
}

class _CalendarHeaderSectionState extends State<CalendarHeaderSection> {
  late final TextEditingController _controller;
  late DateTime _currentMonth;
  bool _isPressed = false;

  final int maxLength = 20;
  final double buttonHeight = 48;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.goal.title);
    _currentMonth = widget.date;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Selector<RecordProvider, Goal?>(
        selector: (_, provider) => provider.getGoalById(widget.goal.id),
        builder: (context, goal, child) {
          if (goal == null) return const SizedBox.shrink();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _isPressed = !_isPressed;
                      }),
                      child: Container(
                        height: buttonHeight,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: _isPressed
                            ? NeumorphicTheme.pressedBoxDecoration(context)
                            : NeumorphicTheme.raisedBoxDecoration(context),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          goal.title,
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight:
                                _isPressed ? FontWeight.w500 : FontWeight.w700,
                          ),
                          maxLines: 2,
                        ),
                      ),
                    ),
                  ),
                  SettingButton(goal: goal),
                ],
              ),
              const SizedBox(height: 24),
              MonthNavigationBar(
                referenceDate: _currentMonth,
                onMonthChanged: (newMonth) {
                  setState(() {
                    _currentMonth = newMonth;
                  });
                  widget.onMonthChanged?.call(newMonth);
                },
              ),
            ],
          );
        });
  }
}
