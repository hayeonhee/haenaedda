import 'package:flutter/material.dart';
import 'package:haenaedda/constants/dimensions.dart';

import 'package:haenaedda/theme/decorations/neumorphic_theme.dart';

class BottomRightButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;

  const BottomRightButton({
    super.key,
    required this.onPressed,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: bottomRightButtonOffset.dy,
      right: bottomRightButtonOffset.dx,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: bottomRightButtonSize.width,
          height: bottomRightButtonSize.height,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            shape: BoxShape.circle,
            boxShadow: NeumorphicTheme.buttonShadow(),
          ),
          child: child,
        ),
      ),
    );
  }
}
