import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:haenaedda/provider/record_provider.dart';
import 'package:haenaedda/theme/decorations/neumorphic_theme.dart';

class MonthNavigationBar extends StatefulWidget {
  final DateTime referenceDate;
  final void Function(DateTime)? onMonthChanged;

  const MonthNavigationBar({
    super.key,
    required this.referenceDate,
    this.onMonthChanged,
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
      widget.onMonthChanged?.call(_focusedDate);
    }
  }

  void _goToNextMonth() {
    if (!isAtReferenceMonth) {
      setState(() {
        _focusedDate = DateTime(_focusedDate.year, _focusedDate.month + 1);
      });
      widget.onMonthChanged?.call(_focusedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: 48,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          if (!isAtFirstRecordedMonth)
            _buildChevronButton(isLeft: true, onTap: _goToPreviousMonth),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.3,
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '${_focusedDate.year}.${_focusedDate.month.toString().padLeft(2, '0')}',
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          if (!isAtReferenceMonth)
            _buildChevronButton(isLeft: false, onTap: _goToNextMonth),
        ],
      ),
    );
  }

  Widget _buildChevronButton({
    required bool isLeft,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            boxShadow: NeumorphicTheme.buttonShadow(context),
          ),
          child: Icon(
            isLeft ? Icons.chevron_left : Icons.chevron_right,
            color: Theme.of(context).colorScheme.onSurface,
          )),
    );
  }
}
