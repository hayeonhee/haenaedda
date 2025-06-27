import 'package:flutter/material.dart';

import 'package:haenaedda/theme/decorations/neumorphic_theme.dart';

class CalendarDayCell extends StatelessWidget {
  final String goalId;
  final DateTime cellDate;
  final bool hasRecord;
  final void Function(String goalId, DateTime date) onTap;

  const CalendarDayCell({
    super.key,
    required this.goalId,
    required this.cellDate,
    required this.hasRecord,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(goalId, cellDate),
      child: Container(
        decoration: hasRecord
            ? NeumorphicTheme.recordedCellDecoration(context)
            : NeumorphicTheme.unrecordedCellDecoration(context),
        alignment: Alignment.center,
        child: Text(
          '${cellDate.day}',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: hasRecord ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
