import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:haenaedda/gen_l10n/app_localizations.dart';
import 'package:haenaedda/theme/buttons.dart';
import 'package:haenaedda/presentation/goal_calendar/goal_edit_result.dart';
import 'package:haenaedda/presentation/settings/handlers/discard_changes_handler.dart';
import 'package:haenaedda/presentation/widgets/discard_aware_close_button.dart';
import 'package:haenaedda/presentation/view_models/goal_view_models.dart';

class EditGoalPage extends StatefulWidget {
  final String? initialText;
  final GoalEditMode mode;

  const EditGoalPage({
    super.key,
    this.initialText,
    this.mode = GoalEditMode.create,
  });

  @override
  State<EditGoalPage> createState() => _EditGoalPageState();
}

class _EditGoalPageState extends State<EditGoalPage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isDiscardCheckInProgress = false;
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _controller.text = widget.initialText ?? '';
    _updateButtonEnabled();
    _controller.addListener(_updateButtonEnabled);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final original = widget.initialText?.trim() ?? '';
    final current = _controller.text.trim();
    final isDirty = current.isNotEmpty && current != original;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop || _isDiscardCheckInProgress) return;
        _isDiscardCheckInProgress = true;
        await DiscardChangesHandler.maybePopWithDiscardCheck(context, isDirty);
        _isDiscardCheckInProgress = false;
      },
      child: GestureDetector(
        onTap: () {
          _focusNode.hasFocus
              ? FocusScope.of(context).unfocus()
              : FocusScope.of(context).requestFocus(_focusNode);
        },
        behavior: HitTestBehavior.translucent,
        child: Scaffold(
          backgroundColor: colorScheme.surface,
          appBar: AppBar(
            backgroundColor: colorScheme.surface,
            leading: Builder(
              builder: (context) {
                final hasNoGoal = context.select<GoalViewModel, bool>(
                  (goalViewModel) => goalViewModel.hasNoGoal,
                );
                if (hasNoGoal) return const SizedBox.shrink();
                return DiscardAwareCloseButton(hasUnsavedChanges: isDirty);
              },
            ),
            actions: [
              TextButton(
                onPressed: _isButtonEnabled
                    ? () {
                        Navigator.of(context).pop(GoalEditResult(
                          title: _controller.text.trim(),
                          mode: widget.mode,
                        ));
                      }
                    : null,
                style: getAppbarButtonStyle(context),
                child: Text(
                  widget.mode == GoalEditMode.create ? l10n.add : l10n.save,
                  style: getAppbarButtonTextStyle(context, _isButtonEnabled),
                ),
              ),
            ],
            elevation: 0,
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.only(
                  top: constraints.maxHeight * 0.25,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                ),
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        widget.mode == GoalEditMode.create
                            ? l10n.addGoalPrompt
                            : l10n.editGoalPrompt,
                        style: TextStyle(
                          fontSize: 16,
                          color: colorScheme.onSurface.withValues(alpha: 0.4),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: TextField(
                          controller: _controller,
                          maxLines: 2,
                          maxLength: 40,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            counterText: '',
                          ),
                          cursorColor: colorScheme.onSurface,
                          textAlign: TextAlign.center,
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.text,
                          onSubmitted: (_) => FocusScope.of(context).unfocus(),
                          focusNode: _focusNode,
                          onChanged: (_) => _updateButtonEnabled(),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _updateButtonEnabled() {
    final trimmed = _controller.text.trim();
    final original = (widget.initialText ?? '').trim();
    setState(() {
      _isButtonEnabled = trimmed.isNotEmpty && trimmed != original;
    });
  }
}
