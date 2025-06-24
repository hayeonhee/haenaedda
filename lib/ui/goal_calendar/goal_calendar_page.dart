import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:haenaedda/gen_l10n/app_localizations.dart';
import 'package:haenaedda/model/goal.dart';
import 'package:haenaedda/model/goal_setting_action.dart';
import 'package:haenaedda/provider/record_provider.dart';
import 'package:haenaedda/ui/goal_calendar/goal_pager.dart';
import 'package:haenaedda/ui/settings/handlers/edit_goal_handler.dart';
import 'package:haenaedda/ui/settings/settings_bottom_modal.dart';
import 'package:haenaedda/ui/widgets/bottom_right_button.dart';

class GoalCalendarPage extends StatefulWidget {
  const GoalCalendarPage({super.key});

  @override
  State<GoalCalendarPage> createState() => _GoalCalendarPageState();
}

class _GoalCalendarPageState extends State<GoalCalendarPage> {
  final PageController _pageController = PageController();
  final ValueNotifier<Goal?> _currentGoal = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<RecordProvider>();
      final isLoaded = provider.isLoaded;
      final goals = provider.sortedGoals;
      if (isLoaded && goals.isEmpty) {
        showAddGoalFlow(context);
        setState(() {});
      }
      _initializeCurrentGoal(goals);
    });
  }

  @override
  Widget build(BuildContext context) {
    final goals =
        context.select<RecordProvider, List<Goal>>((p) => p.sortedGoals);
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            GoalPager(
              goals: goals,
              controller: _pageController,
              onGoalChanged: (goal) => _currentGoal.value = goal,
            ),
            ValueListenableBuilder<Goal?>(
                valueListenable: _currentGoal,
                builder: (context, goal, _) {
                  if (goal == null) return const SizedBox.shrink();
                  return BottomRightButton(
                    onPressed: () => _onSettingButtonTap(context, goal),
                    child: Icon(
                      Icons.settings,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  );
                }),
          ],
        ),
      ),
    );
  }

  void _initializeCurrentGoal(List<Goal> goals) {
    if (goals.isNotEmpty) {
      _currentGoal.value = goals[0];
    }
  }

  Future<void> _onSettingButtonTap(BuildContext context, Goal goal) async {
    final recordProvider = context.read<RecordProvider>();
    final action = await showGeneralDialog<GoalSettingAction?>(
      context: context,
      barrierDismissible: true,
      barrierLabel: AppLocalizations.of(context)!.dismiss,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, _, __) => SettingsBottomModal(goal: goal),
      transitionBuilder: (context, animation, _, child) {
        final offset = Tween<Offset>(
          begin: const Offset(0, 1),
          end: const Offset(0, 0),
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          ),
        );
        return SlideTransition(position: offset, child: child);
      },
    );
    if (!context.mounted) return;
    switch (action) {
      case GoalSettingAction.addGoal:
        await showAddGoalFlow(context);
      case GoalSettingAction.editGoalTitle:
        await onEditGoalTitlePressed(context, goal);
      case GoalSettingAction.resetRecordsOnly:
        recordProvider.removeRecordsOnly(goal.id);
      case GoalSettingAction.resetEntireGoal:
        recordProvider.resetEntireGoal(goal.id);
      case null:
    }
  }
}
