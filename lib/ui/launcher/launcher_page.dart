import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:haenaedda/provider/record_provider.dart';
import 'package:haenaedda/ui/goal_calendar/goal_calendar_page.dart';
import 'package:haenaedda/ui/launcher/add_first_goal_flow.dart';
import 'package:haenaedda/ui/widgets/loading_indicator.dart';

class LauncherPage extends StatelessWidget {
  const LauncherPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecordProvider>();
    if (!provider.isLoaded) {
      return const Scaffold(body: LoadingIndicator());
    }
    if (provider.hasNoGoal) {
      return const AddFirstGoalFlow();
    }
    return const GoalCalendarPage();
  }
}
