import 'package:flutter/material.dart';

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
    return GestureDetector(
      onTap: () => onTap(cellDate),
      child: AspectRatio(
        aspectRatio: 1,
        child: Stack(
          alignment: Alignment.center,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text('${cellDate.day}'),
            ),
            if (hasRecord)
              Positioned(child: Image.asset('assets/did_it_stamp_kor.png')),
          ],
        ),
      ),
    );
  }
}
