import 'package:flutter/material.dart';
import 'package:haenaedda/gen_l10n/app_localizations.dart';
import 'package:haenaedda/ui/settings/neumorphic_settings_tile.dart';
import 'package:haenaedda/ui/widgets/modal_action_icon_buttons.dart';
import 'package:haenaedda/ui/widgets/section_divider.dart';

class SettingsBottomModal extends StatelessWidget {
  const SettingsBottomModal({super.key});

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Theme.of(context).colorScheme.surface;

    return Stack(
      children: [
        // SafeArea로 인해 화면 아래에 생기는 빈 공간을 채우는 위젯입니다.
        // 이 영역은 기본적으로 투명하게 남기 때문에, 배경색이 설정되지 않으면 UI가 잘린 것처럼 보일 수 있습니다.
        // 아래 위젯은 그 빈 공간을 모달과 동일한 배경색으로 덮어, 시각적 일관성을 유지합니다.
        //
        // This widget fills the empty space at the bottom caused by SafeArea.
        // Without a background color, this area remains transparent and may look like a visual cut-off.
        // It ensures a consistent look by matching the modal’s background color.
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: MediaQuery.of(context).padding.bottom,
          child: Container(color: backgroundColor),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: SafeArea(
            child: Container(
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ModalCancelIconButton(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        ModalDoneIconButton(
                          onTap: () {
                            // TODO: Implement save action - For now, just close the modal
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  ),
                  const SectionDivider(),
                  const SizedBox(height: 8.0),
                  // TODO: Implement actual action
                  NeumorphicSettingsTile(
                    title: AppLocalizations.of(context)!.resetSavedGoals,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
