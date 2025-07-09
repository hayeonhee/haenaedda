import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'package:haenaedda/gen_l10n/app_localizations.dart';
import 'package:haenaedda/theme/app_theme.dart';
import 'package:haenaedda/presentation/launcher/launcher_page.dart';
import 'package:haenaedda/presentation/view_models/calendar_month_view_model.dart';
import 'package:haenaedda/presentation/view_models/goal_view_models.dart';
import 'package:haenaedda/presentation/view_models/record_view_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) async {
    FlutterError.dumpErrorToConsole(details);
    // TODO: Integrate with Crashlytics to report uncaught Flutter errors
    final log = 'Error: ${details.exception}\nStack: ${details.stack}';
    final file = File('error_log.txt');
    await file.writeAsString(log, mode: FileMode.append);
  };

  final recordViewModel = RecordViewModel();
  final goalViewModel = GoalViewModel();
  final calendarMonthViewModel = CalendarDateViewModel();
  await recordViewModel.loadData();
  await goalViewModel.loadData();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<RecordViewModel>.value(
          value: recordViewModel,
        ),
        ChangeNotifierProvider<GoalViewModel>.value(
          value: goalViewModel,
        ),
        ChangeNotifierProvider<CalendarDateViewModel>.value(
          value: calendarMonthViewModel,
        )
      ],
      child: const Haenaedda(),
    ),
  );
  WidgetsBinding.instance.addObserver(
    _AppLifecycleObserver(onPause: () async {
      await recordViewModel.saveAllRecords();
      await goalViewModel.saveAllGoals();
    }),
  );
}

class _AppLifecycleObserver extends WidgetsBindingObserver {
  final Future<void> Function() onPause;

  _AppLifecycleObserver({required this.onPause});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      onPause();
    }
  }
}

class Haenaedda extends StatefulWidget {
  const Haenaedda({super.key});

  @override
  State<Haenaedda> createState() => _HaenaeddaState();
}

class _HaenaeddaState extends State<Haenaedda> {
  @override
  Widget build(BuildContext context) {
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
      home: const LauncherPage(),
    );
  }
}
