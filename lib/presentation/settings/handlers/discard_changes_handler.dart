import 'package:flutter/material.dart';
import 'package:haenaedda/gen_l10n/app_localizations.dart';
import 'package:haenaedda/theme/buttons.dart';

class DiscardChangesHandler {
  static Future<bool> maybePopWithDiscardCheck(
    BuildContext context,
    bool isDirty,
  ) async {
    if (!isDirty) {
      if (context.mounted) Navigator.of(context).pop();
      return true;
    }

    final confirmed = await confirmDiscardChanges(context);
    if (context.mounted && confirmed == true) {
      Navigator.of(context).pop();
      return true;
    }

    return false;
  }

  static Future<bool?> confirmDiscardChanges(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: l10n.dismiss,
      barrierColor: Colors.black.withValues(alpha: 0.2),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, _, __) => Material(
        color: Colors.transparent,
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.unsavedChanges,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.unsavedChangesMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: TextButton(
                          style: getNeutralButtonStyle(context),
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text(l10n.keepEditing,
                              style: getButtonTextStyle()),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: TextButton(
                          style: getDestructiveButtonStyle(context),
                          onPressed: () => Navigator.of(context).pop(true),
                          child: Text(l10n.leave, style: getButtonTextStyle()),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Future<void> onDiscardDuringInput(
      BuildContext context, TextEditingController controller) async {
    final trimmedText = controller.text.trim();
    if (trimmedText.isEmpty) {
      Navigator.of(context).pop();
      return;
    }
    final discardConfirmed = await confirmDiscardChanges(context);
    if (!context.mounted) return;
    if (discardConfirmed == true) {
      controller.clear();
      Navigator.of(context).pop();
    }
  }
}
