import 'package:flutter/material.dart';

import 'package:haenaedda/presentation/settings/handlers/edit_goal_handler.dart';
import 'package:haenaedda/presentation/widgets/loading_indicator.dart';

class AddFirstGoalFlow extends StatefulWidget {
  const AddFirstGoalFlow({super.key});

  @override
  State<AddFirstGoalFlow> createState() => _AddFirstGoalFlowState();
}

class _AddFirstGoalFlowState extends State<AddFirstGoalFlow> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      showAddGoalFlow(context, replaceToGoalCalendar: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: LoadingIndicator());
  }
}
