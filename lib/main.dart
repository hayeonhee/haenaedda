import 'package:flutter/material.dart';
import 'my_calendar_page.dart';

// TODO: Let the user set a goal
String kUserGoal = 'User\'s goal';

void main() {
  runApp(const Haenaedda());
}

class Haenaedda extends StatelessWidget {
  const Haenaedda({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaleFactor: mediaQuery.textScaleFactor,
          ),
          child: child!,
        );
      },
      title: 'HAENAEDDA — I did it',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyCalendarPage(title: kUserGoal),
    );
  }
}
