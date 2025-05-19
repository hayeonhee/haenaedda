import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:haenaedda/provider/record_provider.dart';

class MonthNavigationBar extends StatefulWidget {
  final DateTime referenceDate;

  const MonthNavigationBar({
    super.key,
    required this.referenceDate,
  });

  @override
  State<MonthNavigationBar> createState() => _MonthNavigationBarState();
}

class _MonthNavigationBarState extends State<MonthNavigationBar> {
  late DateTime _focusedDate;
  DateTime? _firstRecordedDate;

  @override
  void initState() {
    super.initState();
    _focusedDate = widget.referenceDate;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initFirstRecordedDateIfNeeded();
  }

  void _initFirstRecordedDateIfNeeded() {
    _firstRecordedDate ??=
        context.read<RecordProvider>().getFirstRecordedDate();
  }

  bool get isAtFirstRecordedMonth {
    _initFirstRecordedDateIfNeeded();
    return _focusedDate.year == _firstRecordedDate!.year &&
        _focusedDate.month == _firstRecordedDate!.month;
  }

  bool get isAtReferenceMonth =>
      _focusedDate.year == widget.referenceDate.year &&
      _focusedDate.month == widget.referenceDate.month;

  void _goToPreviousMonth() {
    if (!isAtFirstRecordedMonth) {
      setState(() {
        _focusedDate = DateTime(_focusedDate.year, _focusedDate.month - 1);
      });
    }
  }

  void _goToNextMonth() {
    if (!isAtReferenceMonth) {
      setState(() {
        _focusedDate = DateTime(_focusedDate.year, _focusedDate.month + 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          // TODO: implement navigation to previous and next months
          onPressed: () {},
          icon: const Icon(Icons.chevron_left),
          color: Theme.of(context).colorScheme.onBackground,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          focusColor: Colors.transparent,
        ),
        Text(
          '${widget.date.year}.${widget.date.month}',
          style: TextStyle(
              color: Theme.of(context).colorScheme.onBackground,
              fontWeight: FontWeight.bold),
        ),
        IconButton(
          // TODO: implement navigation to previous and next months
          onPressed: () {},
          icon: const Icon(Icons.chevron_right),
          color: Theme.of(context).colorScheme.onBackground,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          focusColor: Colors.transparent,
        ),
      ],
    );
  }
}
