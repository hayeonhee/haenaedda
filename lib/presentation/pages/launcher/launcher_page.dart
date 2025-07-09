import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:haenaedda/presentation/pages/goal_calendar/goal_calendar_page.dart';
import 'package:haenaedda/presentation/pages/launcher/add_first_goal_flow.dart';
import 'package:haenaedda/presentation/widgets/loading_indicator.dart';
import 'package:haenaedda/presentation/view_models/goal_view_models.dart';

class LauncherPage extends StatelessWidget {
  const LauncherPage({super.key});

  @override
  Widget build(BuildContext context) {
    final goalViewModel = context.watch<GoalViewModel>();
    if (!goalViewModel.isLoaded) {
      return const Scaffold(body: LoadingIndicator());
    }
    if (goalViewModel.hasNoGoal) {
      return const AddFirstGoalFlow();
    }
    return const GoalCalendarPage();
  }
}
