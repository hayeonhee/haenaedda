import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:haenaedda/gen_l10n/app_localizations.dart';
import 'package:haenaedda/model/goal.dart';
import 'package:haenaedda/theme/buttons.dart';
import 'package:haenaedda/presentation/handlers/discard_changes_handler.dart';
import 'package:haenaedda/presentation/widgets/discard_aware_close_button.dart';
import 'package:haenaedda/presentation/view_models/goal_view_models.dart';

class ReorderGoalsPage extends StatefulWidget {
  const ReorderGoalsPage({super.key});

  @override
  State<ReorderGoalsPage> createState() => _ReorderGoalsPageState();
}

class _ReorderGoalsPageState extends State<ReorderGoalsPage> {
  late List<Goal> _goals;
  late List<String> _initialOrder;

  @override
  void initState() {
    super.initState();
    final goalViewModel = context.read<GoalViewModel>();
    _goals = List.of(goalViewModel.sortedGoals);
    _initialOrder = _goals.map((g) => g.id).toList();
  }

  bool get _isOrderChanged {
    final currentOrder = _goals.map((g) => g.id).toList();
    return !listEquals(currentOrder, _initialOrder);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await DiscardChangesHandler.maybePopWithDiscardCheck(
          context,
          _isOrderChanged,
        );
      },
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          backgroundColor: colorScheme.surface,
          leading: DiscardAwareCloseButton(hasUnsavedChanges: _isOrderChanged),
          actions: [
            TextButton(
              onPressed: _isOrderChanged ? _onSave : null,
              style: getAppbarButtonStyle(context),
              child: Text(
                AppLocalizations.of(context)!.save,
                style: getAppbarButtonTextStyle(context, _isOrderChanged),
              ),
            ),
          ],
        ),
        body: ReorderableListView(
          proxyDecorator: (child, _, __) =>
              Material(type: MaterialType.transparency, child: child),
          physics: const NeverScrollableScrollPhysics(),
          onReorder: _onReorder,
          children: [
            for (final goal in _goals)
              ListTile(
                key: ValueKey(goal.id),
                title: Text(
                  goal.title,
                  style: TextStyle(
                    fontSize: 16,
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.1,
                    height: 1.2,
                  ),
                  maxLines: 1,
                ),
                leading: ReorderableDragStartListener(
                  index: _goals.indexOf(goal),
                  child: GestureDetector(
                    onTapDown: (_) => HapticFeedback.selectionClick(),
                    child: Icon(Icons.reorder, color: colorScheme.onSurface),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) newIndex -= 1;
      final goal = _goals.removeAt(oldIndex);
      _goals.insert(newIndex, goal);
    });
  }

  void _onSave() => Navigator.pop(context, _goals);
}
