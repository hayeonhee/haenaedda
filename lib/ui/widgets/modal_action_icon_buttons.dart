import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:haenaedda/constants/dimensions.dart';

class ModalCancelIconButton extends StatelessWidget {
  final VoidCallback onTap;

  const ModalCancelIconButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.translucent,
      child: Container(
        width: kIconButtonSize,
        height: kIconButtonSize,
        padding: const EdgeInsets.all(4),
        child: Icon(
          CupertinoIcons.xmark,
          size: kIconSize,
          color: Theme.of(context).hintColor,
        ),
      ),
    );
  }
}

class ModalDoneIconButton extends StatelessWidget {
  final VoidCallback onTap;

  const ModalDoneIconButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.translucent,
      child: Container(
        width: kIconButtonSize,
        height: kIconButtonSize,
        padding: const EdgeInsets.all(4),
        child: Icon(
          CupertinoIcons.check_mark,
          size: kIconSize,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}
