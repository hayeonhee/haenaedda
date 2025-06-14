import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'package:haenaedda/gen_l10n/app_localizations.dart';
import 'package:haenaedda/model/goal.dart';
import 'package:haenaedda/provider/record_provider.dart';
import 'package:haenaedda/theme/app_theme.dart';
import 'package:haenaedda/ui/goal_calendar/goal_calendar_page.dart';

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
  List<Goal>? goals;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final recordProvider =
          Provider.of<RecordProvider>(context, listen: false);

      final sortedGoals = await recordProvider.initializeAndGetGoals();
      if (!mounted) return;
      setState(() {
        goals = sortedGoals;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (goals == null) {
      return const Center(child: CircularProgressIndicator());
    }
    // TODO: Handle null, empty, and valid goal states appropriately after loading.
    final List<Goal> nonNullableGoals = goals!;

    return MaterialApp(
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(textScaler: mediaQuery.textScaler),
          child: child!,
        );
      },
      title: 'HAENAEDDA — I did it',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: AppTheme.defaultMode,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('ko'),
      ],
      home: GoalCalendarPage(goals: nonNullableGoals),
    );
  }
}
