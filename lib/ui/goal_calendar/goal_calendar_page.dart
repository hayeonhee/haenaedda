import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:haenaedda/gen_l10n/app_localizations.dart';
import 'package:haenaedda/model/goal.dart';
import 'package:haenaedda/model/goal_setting_action.dart';
import 'package:haenaedda/ui/goal_calendar/goal_pager.dart';
import 'package:haenaedda/ui/settings/handlers/edit_goal_handler.dart';
import 'package:haenaedda/ui/settings/settings_bottom_modal.dart';
import 'package:haenaedda/ui/widgets/bottom_right_button.dart';
import 'package:haenaedda/view_models/record_view_model.dart';

class GoalCalendarPage extends StatefulWidget {
  const GoalCalendarPage({super.key});

  @override
  State<GoalCalendarPage> createState() => _GoalCalendarPageState();
}

class _GoalCalendarPageState extends State<GoalCalendarPage> {
  final PageController _pageController = PageController();
  bool _isAddGoalFlowActive = false;
  int _currentPageIndex = 0;
  RecordViewModel? _recordViewModel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _recordViewModel = context.read<RecordViewModel>();
      _recordViewModel?.addListener(_checkGoalState);
      _checkGoalState();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToFocusedGoalIfNeeded();
    });
  }

  void _checkGoalState() {
    if (!_isAddGoalFlowActive &&
        _recordViewModel != null &&
        _recordViewModel!.isLoaded &&
        _recordViewModel!.sortedGoals.isEmpty) {
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
    _recordViewModel?.removeListener(_checkGoalState);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final goals = context.select<RecordViewModel, List<Goal>>(
      (recordViewModel) => recordViewModel.sortedGoals,
    );
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            GoalPager(
              goals: goals,
              controller: _pageController,
              onCellTap: (goalId, date) {
                final recordViewModel = context.read<RecordViewModel>();
                recordViewModel.toggleRecord(goalId, date);
                recordViewModel.saveRecordsDebounced(goalId);
              },
              onPageChanged: (index) {
                _currentPageIndex = index;
              },
            ),
            BottomRightButton(
              onPressed: () {
                final goal = goals[_currentPageIndex];
                _onSettingButtonTap(context, goal);
              },
              child: Icon(
                Icons.settings,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onSettingButtonTap(BuildContext context, Goal goal) async {
    final recordViewModel = context.read<RecordViewModel>();
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
        recordViewModel.removeRecordsOnly(goal.id);
        break;
      case GoalSettingAction.resetEntireGoal:
        recordViewModel.resetEntireGoal(goal.id);
        break;
      case null:
        break;
    }
  }

  void _scrollToFocusedGoalIfNeeded() {
    final recordViewModel = context.read<RecordViewModel>();
    final focusedGoal = recordViewModel.focusedGoalForScroll;
    final shouldScroll = recordViewModel.shouldScrollToFocusedPage;

    if (focusedGoal != null && shouldScroll) {
      final index =
          recordViewModel.sortedGoals.indexWhere((g) => g.id == focusedGoal.id);
      if (index == -1) return;
      if (!_pageController.hasClients) return;

      _pageController.jumpToPage(index);
      _currentPageIndex = index;
      recordViewModel.clearFocusedGoalForScroll();
    }
  }
}
