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
        child: Stack(
          alignment: Alignment.center,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(dayText),
            ),
            if (hasRecord)
              Positioned(child: Image.asset('assets/did_it_stamp_kor.png')),
          ],
        ),
      ),
    );
  }
}
