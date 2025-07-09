import 'package:flutter/material.dart';
import 'package:haenaedda/presentation/settings/handlers/discard_changes_handler.dart';

class DiscardAwareCloseButton extends StatelessWidget {
  final bool hasUnsavedChanges;

  const DiscardAwareCloseButton({super.key, required this.hasUnsavedChanges});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.close),
      onPressed: () {
        DiscardChangesHandler.maybePopWithDiscardCheck(
          context,
          hasUnsavedChanges,
        );
      },
    );
  }
}
