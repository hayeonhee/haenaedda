import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'package:haenaedda/gen_l10n/app_localizations.dart';
import 'package:haenaedda/provider/calendar_month_provider.dart';
import 'package:haenaedda/provider/record_provider.dart';
import 'package:haenaedda/theme/app_theme.dart';
import 'package:haenaedda/ui/launcher/launcher_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final recordProvider = RecordProvider();
  final calendarMonthProvider = CalendarDateProvider();
  await recordProvider.loadData();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<RecordProvider>.value(
          value: recordProvider,
        ),
        ChangeNotifierProvider<CalendarDateProvider>.value(
          value: calendarMonthProvider,
        )
      ],
      child: const Haenaedda(),
    ),
  );
  WidgetsBinding.instance.addObserver(
    _AppLifecycleObserver(onPause: () => recordProvider.saveAll()),
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
