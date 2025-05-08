import 'package:flutter/material.dart';

class CalendarDayCell extends StatelessWidget {
  final String dayText;
  final bool hasRecord;
  final VoidCallback onTap;

  const CalendarDayCell({
    super.key,
    required this.dayText,
    required this.hasRecord,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
            color: hasRecord ? Colors.deepPurple : Colors.white,
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.topLeft,
          child: Text(dayText),
        ),
      ),
    );
  }
}
