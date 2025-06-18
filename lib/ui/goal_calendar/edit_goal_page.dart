import 'package:flutter/material.dart';
import 'package:haenaedda/gen_l10n/app_localizations.dart';
import 'package:haenaedda/provider/record_provider.dart';
import 'package:haenaedda/ui/settings/handlers/edit_goal_handler.dart';
import 'package:provider/provider.dart';

class EditGoalPage extends StatefulWidget {
  final String? initialText;

  const EditGoalPage({super.key, this.initialText});

  @override
  State<EditGoalPage> createState() => _EditGoalPageState();
}

class _EditGoalPageState extends State<EditGoalPage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isDiscardCheckInProgress = false;

  @override
  void initState() {
    super.initState();
    _controller.text = widget.initialText ?? '';
    _controller.addListener(() => setState(() {}));
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop || _isDiscardCheckInProgress) return;
        _isDiscardCheckInProgress = true;
        await _handlePop(context);
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
                final hasNoGoal = context.select<RecordProvider, bool>(
                  (provider) => provider.hasNoGoal,
                );
                if (hasNoGoal) return const SizedBox.shrink();
                return IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => _handlePop(context),
                );
              },
            ),
            actions: [
              TextButton(
                onPressed: _controller.text.isEmpty
                    ? null
                    : () {
                        final trimmed = _controller.text.trim();
                        if (trimmed.isNotEmpty) {
                          Navigator.of(context).pop(trimmed);
                        }
                      },
                style: ButtonStyle(
                  splashFactory: NoSplash.splashFactory,
                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                  foregroundColor:
                      WidgetStateProperty.all(colorScheme.onSurface),
                ),
                child: Text(
                  AppLocalizations.of(context)!.add,
                  style: TextStyle(
                    fontSize: 18,
                    color: _controller.text.isEmpty
                        ? colorScheme.outline
                        : colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
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
                        AppLocalizations.of(context)!.editGoalPrompt,
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
                          autofocus: true,
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

  Future<void> _handlePop(BuildContext context) async {
    final original = widget.initialText?.trim() ?? '';
    final current = _controller.text.trim();
    final isDirty = current.isNotEmpty && current != original;

    if (!isDirty) {
      if (context.mounted) Navigator.of(context).pop();
      return;
    }

    final confirmed = await confirmDiscardChanges(context);
    if (context.mounted && confirmed == true) {
      Navigator.of(context).pop();
    }
  }
}
