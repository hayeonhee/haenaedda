import 'package:flutter/material.dart';
import 'package:haenaedda/model/goal.dart';
import 'package:haenaedda/ui/goal_calendar/single_goal_calendar_view.dart';

class GoalPager extends StatefulWidget {
  final List<Goal> goals;

  const GoalPager({super.key, required this.goals});

  @override
  State<GoalPager> createState() => _GoalPagerState();
}

class _GoalPagerState extends State<GoalPager> {
  final PageController _controller = PageController();

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
        scrollDirection: Axis.vertical,
        controller: _controller,
        physics: const BouncingScrollPhysics(),
        itemCount: widget.goals.length,
        itemBuilder: (context, index) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              double value = _controller.hasClients && _controller.page != null
                  ? (_controller.page! - index).clamp(-1, 1)
                  : 0;
              final scale = 1 - (value.abs() * 0.1);
              return Transform.scale(
                scale: scale,
                child: Opacity(opacity: 1 - value.abs() * 0.3, child: child),
              );
            },
            child: SingleGoalCalendarView(goal: widget.goals[index]),
          );
        });
  }
}
