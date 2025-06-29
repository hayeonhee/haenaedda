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
  bool _isAddGoalFlowActive = false;
  RecordProvider? _recordProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _recordProvider = context.read<RecordProvider>();
      _recordProvider?.addListener(_checkGoalState);
      _checkGoalState();
    });
  }

  void _checkGoalState() {
    if (!_isAddGoalFlowActive &&
        _recordProvider != null &&
        _recordProvider!.isLoaded &&
        _recordProvider!.sortedGoals.isEmpty) {
      _isAddGoalFlowActive = true;
      Future.microtask(() async {
        if (mounted) {
          await showAddGoalFlow(context);
          _isAddGoalFlowActive = false;
        }
      });
    }
  }

  @override
  void dispose() {
    _recordProvider?.removeListener(_checkGoalState);
    _currentGoal.dispose();
    super.dispose();
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
              onCellTap: (goalId, date) {
                final provider = context.read<RecordProvider>();
                provider.toggleRecord(goalId, date);
                provider.saveRecordsDebounced(goalId);
              },
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
        break;
      case GoalSettingAction.editGoalTitle:
        await onEditGoalTitlePressed(context, goal);
        break;
      case GoalSettingAction.resetRecordsOnly:
        recordProvider.removeRecordsOnly(goal.id);
        break;
      case GoalSettingAction.resetEntireGoal:
        recordProvider.resetEntireGoal(goal.id);
        break;
      case null:
        break;
    }
  }
}
