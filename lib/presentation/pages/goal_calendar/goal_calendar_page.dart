import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:haenaedda/domain/entities/goal.dart';
import 'package:haenaedda/domain/enums/goal_setting_action.dart';
import 'package:haenaedda/gen_l10n/app_localizations.dart';
import 'package:haenaedda/presentation/handlers/edit_goal_handler.dart';
import 'package:haenaedda/presentation/handlers/reset_goal_handler.dart';
import 'package:haenaedda/presentation/pages/goal_calendar/goal_pager.dart';
import 'package:haenaedda/presentation/pages/settings/settings_bottom_modal.dart';
import 'package:haenaedda/presentation/view_models/goal_scroll_focus_manager.dart';
import 'package:haenaedda/presentation/view_models/goal_view_models.dart';
import 'package:haenaedda/presentation/view_models/record_view_model.dart';
import 'package:haenaedda/presentation/widgets/bottom_right_button.dart';

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
  GoalViewModel? _goalViewModel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _recordViewModel = context.read<RecordViewModel>();
      _goalViewModel = context.read<GoalViewModel>();
      _recordViewModel?.addListener(_checkGoalState);
      _goalViewModel?.addListener(_checkGoalState);
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
        _goalViewModel!.sortedGoals.isEmpty) {
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
    final goalViewModel = context.select<GoalViewModel, List<Goal>>(
      (goalViewModel) => goalViewModel.sortedGoals,
    );
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            GoalPager(
              goals: goalViewModel,
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
                final goal = goalViewModel[_currentPageIndex];
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
      case GoalSettingAction.reorderGoal:
        await reorderGoals(context, replaceToGoalCalendar: true);
        break;
      case GoalSettingAction.resetRecordsOnly:
        await handleResetRecordsOnly(context, goal);
        break;
      case GoalSettingAction.resetEntireGoal:
        await handleResetEntireGoal(context, goal);
        break;
      case GoalSettingAction.resetAllGoals:
        await handleResetAllGoals(context);
        break;
      case null:
        break;
    }
  }

  void _scrollToFocusedGoalIfNeeded() {
    final goalViewModel = context.read<GoalViewModel>();
    final scrollFocusManager = context.read<GoalScrollFocusManager>();
    final focusedGoal = scrollFocusManager.focusedGoal;
    final shouldScroll = scrollFocusManager.shouldScroll;

    if (focusedGoal != null && shouldScroll) {
      final index =
          goalViewModel.sortedGoals.indexWhere((g) => g.id == focusedGoal.id);
      if (index == -1) return;
      if (!_pageController.hasClients) return;

      _pageController.jumpToPage(index);
      _currentPageIndex = index;
      scrollFocusManager.clear();
    }
  }
}
