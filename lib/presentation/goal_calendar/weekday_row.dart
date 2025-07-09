import 'package:flutter/material.dart';

import 'package:haenaedda/gen_l10n/app_localizations.dart';

class WeekdayRow extends StatelessWidget {
  const WeekdayRow({super.key});

  @override
  Widget build(BuildContext context) {
    final daysOfWeek = AppLocalizations.of(context)!.shortWeekdays.split(',');
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(
        daysOfWeek.length,
        (index) {
          return Text(
            daysOfWeek[index],
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          );
        },
      ),
    );
  }
}
