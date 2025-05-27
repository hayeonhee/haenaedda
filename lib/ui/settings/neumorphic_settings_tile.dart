import 'package:flutter/material.dart';
import 'package:haenaedda/constants/neumorphic_theme.dart';

class NeumorphicSettingsTile extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const NeumorphicSettingsTile({
    super.key,
    required this.title,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: NeumorphicTheme.raisedTileBoxDecoration(context),
        alignment: Alignment.centerLeft,
        child: DefaultTextStyle(
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).colorScheme.onBackground,
            fontWeight: FontWeight.bold,
          ),
          child: Text(title),
        ),
      ),
    );
  }
}
