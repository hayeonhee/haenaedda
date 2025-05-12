import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:haenaedda/constants/app_theme.dart';
import 'package:haenaedda/my_calendar_page.dart';
import 'package:haenaedda/record_provider.dart';

// TODO: Let the user set a goal
String kUserGoal = 'User\'s goal';

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => RecordProvider()),
    ],
    child: const Haenaedda(),
  ));
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
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      home: MyCalendarPage(title: kUserGoal),
    );
  }
}
