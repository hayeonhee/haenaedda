import 'package:flutter/material.dart';

import 'calendar_day_cell.dart';
import 'empty_cell.dart';

class MyCalendarPage extends StatefulWidget {
  final String title;

  const MyCalendarPage({super.key, required this.title});

  @override
  State<MyCalendarPage> createState() => _MyCalendarPageState();
}

class _MyCalendarPageState extends State<MyCalendarPage> {
  final daysOfWeek = ['일', '월', '화', '수', '목', '금', '토'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text(
              '$year년 $month월',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            Row(
              children: List.generate(daysOfWeek.length, (index) {
                return Expanded(
                  child: Text(
                    daysOfWeek[index],
                    style: const TextStyle(fontSize: 15),
                    textAlign: TextAlign.center,
                  ),
                );
              }),
            ),
            const SizedBox(height: 10),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 7,
              childAspectRatio: 1,
              mainAxisSpacing: 10,
              crossAxisSpacing: 8,
              children: List.generate(totalCellsCount, (index) {
                if (index < leadingBlanks) {
                  return const EmptyCell();
                } else if (index < leadingBlanks + totalDaysOfMonth) {
                  int day = index - leadingBlanks + 1;
                  return CalendarDayCell(
                    dayText: '$day',
                    hasRecord: true,
                    onTap: () {},
                  );
                } else {
                  return const EmptyCell();
                }
              }),
            ),
          ],
        ),
      ),
    );
  }
}
