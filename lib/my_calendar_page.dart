import 'package:flutter/material.dart';

import 'package:haenaedda/calendar_screen.dart';
import 'package:haenaedda/main.dart';
import 'package:haenaedda/model/calendar_grid_layout.dart';

class MyCalendarPage extends StatefulWidget {
  final String title;

  const MyCalendarPage({super.key, required this.title});

  @override
  State<MyCalendarPage> createState() => _MyCalendarPageState();
}

class _MyCalendarPageState extends State<MyCalendarPage> {
  final daysOfWeek = ['일', '월', '화', '수', '목', '금', '토'];

  Map<String, Set<DateTime>> recordsByGoal = {};

  void toggleDate(String goal, DateTime date) {
    final records = recordsByGoal[goal] ?? <DateTime>{};

    setState(() {
      if (records.contains(date)) {
        records.remove(date);
      } else {
        records.add(date);
      }
      recordsByGoal[goal] = records;
    });
  }

  // TODO: Always display the current month in this version
  DateTime focusedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final selectedDates = recordsByGoal[kUserGoal] ?? {};
    final dateLayout = CalendarGridLayout(focusedDate);

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
              '${focusedDate.year}년 ${focusedDate.month}월',
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
            CalendarScreen(
              dateLayout: dateLayout,
              selectedDates: selectedDates,
              onCellTap: (selectedDate) => toggleDate(kUserGoal, selectedDate),
            )
          ],
        ),
      ),
    );
  }
}
