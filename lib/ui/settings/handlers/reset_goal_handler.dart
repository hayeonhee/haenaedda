import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:haenaedda/gen_l10n/app_localizations.dart';
import 'package:haenaedda/model/goal.dart';
import 'package:haenaedda/provider/record_provider.dart';

Future<void> showResetFailureDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(AppLocalizations.of(context)!.cancel),
      content: Text(AppLocalizations.of(context)!.resetFailure),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context)!.confirm),
        ),
      ],
    ),
  );
}

Future<bool?> showResetConfirmDialog(BuildContext context, Goal goal) async {
  return await showDialog<bool?>(
    context: context,
    builder: (context) => AlertDialog(
      contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      actionsPadding: const EdgeInsets.fromLTRB(0, 16, 16, 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Text(
        AppLocalizations.of(context)!.resetRecordsMessage,
        style: const TextStyle(fontSize: 16, height: 1.5),
        textAlign: TextAlign.center,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            AppLocalizations.of(context)!.cancel,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        TextButton(
          onPressed: () async {
            final provider = context.read<RecordProvider>();
            final succeeded = await provider.clearGoalRecords(goal.id);
            if (!context.mounted) return;
            if (succeeded) {
              Navigator.of(context).pop(true);
            }
          },
          child: Text(
            AppLocalizations.of(context)!.reset,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ),
      ],
      actionsAlignment: MainAxisAlignment.center,
    ),
  );
}

Future<void> onResetButtonTap(BuildContext context, Goal goal) async {
  // Step 1: Ask user to confirm reset
  if (!context.mounted) return;
  final confirmed = await showResetConfirmDialog(context, goal);
  if (!context.mounted || confirmed != true) return;

  // Step 2: Try to clear goal records
  final succeeded =
      await context.read<RecordProvider>().clearGoalRecords(goal.id);
  if (!context.mounted) return;

  // Step 3: Handle result
  if (succeeded) {
    Navigator.of(context).pop();
  } else {
    await showResetFailureDialog(context);
  }
}
