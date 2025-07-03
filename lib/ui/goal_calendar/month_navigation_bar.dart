import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:haenaedda/theme/decorations/neumorphic_theme.dart';
import 'package:haenaedda/view_models/calendar_month_view_model.dart';
import 'package:haenaedda/view_models/record_view_model.dart';

class MonthNavigationBar extends StatelessWidget {
  final String goalId;

  const MonthNavigationBar({super.key, required this.goalId});

  String _formatYearMonth(DateTime date) =>
      '${date.year}.${date.month.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final recordViewModel = context.watch<CalendarDateViewModel>();
    final firstRecordDate =
        context.read<RecordViewModel>().findFirstRecordedDate(goalId) ??
            recordViewModel.initialVisibleDate;
    final visibleDate = recordViewModel.visibleDate;
    final canGoToPrevious = recordViewModel.canGoToPrevious(firstRecordDate);
    final canGoToNext = recordViewModel.canGoToNext(firstRecordDate);
    final colorScheme = Theme.of(context).colorScheme;

    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: 48,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildChevronButton(
            context,
            canGoToPrevious,
            isLeft: true,
            onTap: () {
              final newMonth =
                  DateTime(visibleDate.year, visibleDate.month - 1, 1);
              recordViewModel.updateDate(newMonth);
            },
          ),
          const SizedBox(width: 12),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.4,
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                _formatYearMonth(visibleDate),
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                  fontSize: 17,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          _buildChevronButton(
            context,
            canGoToNext,
            isLeft: false,
            onTap: () {
              final newMonth =
                  DateTime(visibleDate.year, visibleDate.month + 1, 1);
              recordViewModel.updateDate(newMonth);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChevronButton(
    BuildContext context,
    bool showChevron, {
    double width = 24.0,
    required bool isLeft,
    VoidCallback? onTap,
  }) {
    return showChevron
        ? GestureDetector(
            onTap: onTap,
            child: Container(
                width: width,
                height: width,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: NeumorphicTheme.buttonShadow(context),
                ),
                child: Icon(
                  isLeft ? Icons.chevron_left : Icons.chevron_right,
                  color: Theme.of(context).colorScheme.onSurface,
                )),
          )
        : SizedBox(width: width, height: width);
  }
}
