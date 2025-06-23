import 'package:flutter/material.dart';

class NeumorphicSettingsTile extends StatelessWidget {
  final String title;
  final Color? titleColor;
  final bool isSelected;
  final VoidCallback onTap;

  const NeumorphicSettingsTile({
    super.key,
    required this.title,
    this.titleColor,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.outline,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.grey.withValues(alpha: 0.4)
                  : Colors.white.withValues(alpha: 0.6),
              offset: const Offset(-1, -1),
              blurRadius: isDark ? 8 : 10,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.9 : 0.01),
              offset: const Offset(2, 2),
              blurRadius: 6,
            ),
          ],
        ),
        child: DefaultTextStyle(
          style: TextStyle(
            fontSize: 18,
            color: titleColor ?? Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w500,
            letterSpacing: 1,
          ),
          child: Text(title),
        ),
      ),
    );
  }
}
