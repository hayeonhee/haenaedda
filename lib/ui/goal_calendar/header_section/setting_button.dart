import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:haenaedda/ui/settings/settings_page.dart';

class SettingButton extends StatelessWidget {
  const SettingButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        Navigator.of(context).push(
          CupertinoPageRoute(
            fullscreenDialog: true,
            builder: (_) => const SettingsPage(),
          ),
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
