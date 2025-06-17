import 'package:flutter/material.dart';

import 'package:haenaedda/constants/dimensions.dart';
import 'package:haenaedda/gen_l10n/app_localizations.dart';
import 'package:haenaedda/model/goal.dart';
import 'package:haenaedda/model/goal_setting_action.dart';
import 'package:haenaedda/model/reset_type.dart';
import 'package:haenaedda/ui/settings/handlers/reset_goal_handler.dart';
import 'package:haenaedda/ui/settings/neumorphic_settings_tile.dart';
import 'package:haenaedda/ui/widgets/section_divider.dart';

class SettingsBottomModal extends StatefulWidget {
  final Goal goal;

  const SettingsBottomModal({super.key, required this.goal});

  @override
  State<SettingsBottomModal> createState() => _SettingsBottomModalState();
}

class _SettingsBottomModalState extends State<SettingsBottomModal> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // This widget fills the empty space at the bottom caused by SafeArea.
        // Without a background color, this area remains transparent and may look like a visual cut-off.
        // It ensures a consistent look by matching the modal’s background color.
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: MediaQuery.of(context).padding.bottom,
          child: Container(color: Theme.of(context).colorScheme.surface),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: SafeArea(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 4.0),
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Row(
                      children: [
                        SizedBox(
                          width: iconButtonSize,
                          height: iconButtonSize,
                          child: IconButton(
                            icon: const Icon(Icons.close),
                            padding: EdgeInsets.zero,
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  const SectionDivider(),
                  const SizedBox(height: 12.0),
                  NeumorphicSettingsTile(
                    title: AppLocalizations.of(context)!.addGoal,
                    onTap: () =>
                        Navigator.of(context).pop(GoalSettingAction.addGoal),
                  ),
                  const SizedBox(height: 16.0),
                  NeumorphicSettingsTile(
                    title: AppLocalizations.of(context)!.resetRecordsOnly,
                    onTap: () => onResetButtonTap(
                        context, widget.goal, ResetType.recordsOnly),
                  ),
                  NeumorphicSettingsTile(
                    title: AppLocalizations.of(context)!.resetEntireGoal,
                    onTap: () => onResetButtonTap(
                        context, widget.goal, ResetType.entireGoal),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
