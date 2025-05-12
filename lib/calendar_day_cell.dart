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

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(cellDate),
      child: AspectRatio(
        aspectRatio: 1,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: hasRecord
              ? AnimatedContainer(
                  alignment: Alignment.center,
                  duration: const Duration(milliseconds: 100),
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.background,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: NeumorphicTheme.shadowColor,
                        offset: isDarkMode
                            ? NeumorphicTheme.darkShadowOffset
                            : NeumorphicTheme.lightShadowOffset,
                        blurRadius: NeumorphicTheme.borderRadius,
                      ),
                      BoxShadow(
                        color: Theme.of(context).colorScheme.onPrimary,
                        offset: isDarkMode
                            ? NeumorphicTheme.lightShadowOffset
                            : NeumorphicTheme.darkShadowOffset,
                        blurRadius: NeumorphicTheme.borderRadius,
                      ),
                    ],
                  ),
                  child: Text(
                    '${cellDate.day}',
                    style: TextStyle(
                      fontSize: 30,
                      color: Theme.of(context).colorScheme.surface,
                      fontWeight: FontWeight.bold,
                    ),
                  ))
              : Text(
                  '${cellDate.day}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }
}
