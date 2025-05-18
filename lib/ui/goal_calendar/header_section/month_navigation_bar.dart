import 'package:flutter/material.dart';

class MonthNavigationBar extends StatefulWidget {
  final DateTime date;

  const MonthNavigationBar({
    super.key,
    required this.date,
  });

  @override
  State<MonthNavigationBar> createState() => _MonthNavigationBarState();
}

class _MonthNavigationBarState extends State<MonthNavigationBar> {
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
