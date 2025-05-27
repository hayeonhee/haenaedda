import 'package:flutter/material.dart';
import 'package:haenaedda/ui/settings/settings_bottom_modal.dart';

class SettingButton extends StatelessWidget {
  const SettingButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        showGeneralDialog(
          context: context,
          barrierDismissible: true,
          // TODO: Extract this string for localization
          barrierLabel: 'Dismiss',
          barrierColor: Colors.black54,
          transitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (context, _, __) {
            return const SettingsBottomModal();
          },
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
