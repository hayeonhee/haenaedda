import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'package:haenaedda/gen_l10n/app_localizations.dart';
import 'package:haenaedda/provider/record_provider.dart';
import 'package:haenaedda/theme/app_theme.dart';
import 'package:haenaedda/ui/launcher/launcher_page.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) {
          final recordProvider = RecordProvider();
          recordProvider.loadData();
          return recordProvider;
        }),
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
