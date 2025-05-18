import 'package:flutter/material.dart';

import 'package:haenaedda/constants/neumorphic_theme.dart';

class CalendarDayCell extends StatelessWidget {
  final DateTime cellDate;
  final bool hasRecord;
  final void Function(DateTime) onTap;

  const CalendarDayCell({
    super.key,
    required this.cellDate,
    required this.hasRecord,
    required this.onTap,
  });

  Widget _buildRecordedCell(BuildContext context, DateTime date) {
    return Container(
      decoration: NeumorphicTheme.recordedCellDecoration(context),
      alignment: Alignment.center,
      child: Text(
        '${date.day}',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildUnrecordedCell(BuildContext context, DateTime date) {
    return Container(
      decoration: NeumorphicTheme.unrecordedCellDecoration(context),
      alignment: Alignment.center,
      child: Text(
        '${date.day}',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(cellDate),
      child: hasRecord
          ? _buildRecordedCell(context, cellDate)
          : _buildUnrecordedCell(context, cellDate),
    );
  }
}
