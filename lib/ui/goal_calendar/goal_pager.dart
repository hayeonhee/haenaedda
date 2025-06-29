import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:haenaedda/model/goal.dart';
import 'package:haenaedda/provider/record_provider.dart';
import 'package:haenaedda/ui/goal_calendar/single_goal_calendar_view.dart';

class GoalPager extends StatefulWidget {
  final List<Goal> goals;
  final PageController controller;
  final void Function(String goalId, DateTime date) onCellTap;
  final void Function(Goal goal)? onGoalChanged;

  const GoalPager({
    super.key,
    required this.goals,
    required this.onCellTap,
    required this.controller,
    this.onGoalChanged,
  });

  @override
  State<GoalPager> createState() => _GoalPagerState();
}

class _GoalPagerState extends State<GoalPager> {
  bool _hasScrolledToFocusedGoal = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hasScrolledToFocusedGoal) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<RecordProvider>();
      final focusedGoal = provider.focusedGoalForScroll;
      final shouldScroll = provider.shouldScrollToFocusedPage;
      if (focusedGoal != null && shouldScroll) {
        final index = widget.goals.indexWhere((g) => g.id == focusedGoal.id);
        if (index != -1 && widget.controller.hasClients) {
          widget.controller.jumpToPage(index);
          widget.onGoalChanged?.call(widget.goals[index]);
        }
        provider.clearFocusedGoalForScroll();
        _hasScrolledToFocusedGoal = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      scrollDirection: Axis.vertical,
      controller: widget.controller,
      physics: const BouncingScrollPhysics(),
      itemCount: widget.goals.length,
      onPageChanged: (index) {
        if (widget.onGoalChanged != null && index < widget.goals.length) {
          widget.onGoalChanged!(widget.goals[index]);
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
          child: SingleGoalCalendarView(
            key: ValueKey(widget.goals[index].id),
            goal: widget.goals[index],
            onCellTap: (goalId, date) => widget.onCellTap(goalId, date),
          ),
        );
      },
    );
  }
}
