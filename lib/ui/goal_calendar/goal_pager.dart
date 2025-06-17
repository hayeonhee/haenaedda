import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:haenaedda/model/goal.dart';
import 'package:haenaedda/provider/record_provider.dart';
import 'package:haenaedda/ui/goal_calendar/single_goal_calendar_view.dart';

class GoalPager extends StatefulWidget {
  final List<Goal> goals;

  const GoalPager({super.key, required this.goals});

  @override
  State<GoalPager> createState() => _GoalPagerState();
}

class _GoalPagerState extends State<GoalPager> {
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<RecordProvider>();
      final focusedGoal = provider.focusedGoalForScroll;
      if (focusedGoal != null) {
        final index = widget.goals.indexWhere((g) => g.id == focusedGoal.id);
        if (index != -1) {
          _controller.jumpToPage(index);
        }
        provider.clearFocusedGoalForScroll();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
            if (!_controller.hasClients || _controller.page == null) {
              return child!;
            }
            final value = (_controller.page! - index).clamp(-1.0, 1.0);
            final scale = 1 - (value.abs() * 0.1);
            return Transform.scale(
              scale: scale,
              child: Opacity(opacity: 1 - value.abs() * 0.3, child: child),
            );
          },
          child: SingleGoalCalendarView(
            key: ValueKey(widget.goals[index].id),
            goal: widget.goals[index],
          ),
        );
      },
    );
  }
}
