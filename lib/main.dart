import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:haenaedda/constants/app_theme.dart';
import 'package:haenaedda/my_calendar_page.dart';
import 'package:haenaedda/record_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RecordProvider()),
      ],
      child: const Haenaedda(),
    ),
  );
}

class Haenaedda extends StatefulWidget {
  const Haenaedda({super.key});

  @override
  State<Haenaedda> createState() => _HaenaeddaState();
}

class _HaenaeddaState extends State<Haenaedda> {
  String? goalId;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final recordProvider =
          Provider.of<RecordProvider>(context, listen: false);
      final goal = await recordProvider.initializeAndGetFirstGoal();
      setState(() {
        goalId = goal.id;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (goalId == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final String nonNullableGoalId = goalId!;

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
      home: MyCalendarPage(goalId: nonNullableGoalId),
    );
  }
}
