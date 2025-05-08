import 'package:flutter/material.dart';

class CalendarDayCell extends StatelessWidget {
  final double width;
  final double height;
  final String dayText;
  final bool hasRecord;
  final VoidCallback onTap;

  const CalendarDayCell({
    super.key,
    required this.width,
    required this.height,
    required this.dayText,
    required this.hasRecord,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: hasRecord ? Colors.blue : Colors.white,
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.topLeft,
        child: Text(dayText),
      ),
    );
  }
}
