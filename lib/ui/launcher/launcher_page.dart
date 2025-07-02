import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:haenaedda/ui/goal_calendar/goal_calendar_page.dart';
import 'package:haenaedda/ui/launcher/add_first_goal_flow.dart';
import 'package:haenaedda/ui/widgets/loading_indicator.dart';
import 'package:haenaedda/view_models/record_view_model.dart';

class LauncherPage extends StatelessWidget {
  const LauncherPage({super.key});

  @override
  Widget build(BuildContext context) {
    final recordViewModel = context.watch<RecordViewModel>();
    if (!recordViewModel.isLoaded) {
      return const Scaffold(body: LoadingIndicator());
    }
    if (recordViewModel.hasNoGoal) {
      return const AddFirstGoalFlow();
    }
    return const GoalCalendarPage();
  }
}
