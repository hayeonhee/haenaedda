import 'package:flutter/material.dart';

import 'package:haenaedda/model/calendar_grid_layout.dart';

class CalendarGrid extends StatelessWidget {
  final CalendarGridLayout dateLayout;
  final Widget Function(DateTime) cellBuilder;

  const CalendarGrid({
    super.key,
    required this.dateLayout,
    required this.cellBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        itemCount: dateLayout.totalCellCount,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
        ),
        itemBuilder: (context, index) {
          final cellDate = dateLayout.dateFromIndex(index);
          return cellBuilder(cellDate);
        });
  }
}
