import 'package:flutter/material.dart';

import 'package:haenaedda/model/goal.dart';
import 'package:haenaedda/ui/goal_calendar/goal_calendar_content.dart';

class GoalPager extends StatefulWidget {
  final List<Goal> goals;
  final PageController controller;
  final void Function(String goalId, DateTime date) onCellTap;
  final void Function(int index)? onPageChanged;

  const GoalPager({
    super.key,
    required this.goals,
    required this.controller,
    required this.onCellTap,
    this.onPageChanged,
  });

  @override
  State<GoalPager> createState() => _GoalPagerState();
}

class _GoalPagerState extends State<GoalPager> {
  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      scrollDirection: Axis.vertical,
      controller: widget.controller,
      physics: const BouncingScrollPhysics(),
      itemCount: widget.goals.length,
      onPageChanged: (index) {
        if (widget.onPageChanged != null && index < widget.goals.length) {
          widget.onPageChanged?.call(index);
        }
      },
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: widget.controller,
          builder: (context, child) {
            if (!widget.controller.hasClients ||
                widget.controller.page == null) {
              return child!;
            }
            final value = (widget.controller.page! - index).clamp(-1.0, 1.0);
            final scale = 1 - (value.abs() * 0.1);
            return Transform.scale(
              scale: scale,
              child: Opacity(opacity: 1 - value.abs() * 0.3, child: child),
            );
          },
          child: GoalCalendarContent(
            key: ValueKey(widget.goals[index].id),
            goal: widget.goals[index],
            onCellTap: (goalId, date) => widget.onCellTap(goalId, date),
          ),
        );
      },
    );
  }
}
