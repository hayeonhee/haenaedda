import 'package:flutter/material.dart';
import 'package:haenaedda/gen_l10n/app_localizations.dart';
import 'package:haenaedda/model/goal.dart';
import 'package:haenaedda/ui/settings/settings_bottom_modal.dart';

class SettingButton extends StatelessWidget {
  final Goal goal;

  const SettingButton({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        showGeneralDialog(
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
              CurvedAnimation(parent: animation, curve: Curves.easeOut),
            );
            return SlideTransition(position: offset, child: child);
          },
        );
      },
      icon: const Icon(Icons.settings),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
    );
  }
}
