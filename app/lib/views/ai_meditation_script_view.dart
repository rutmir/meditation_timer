import 'package:flutter/material.dart';
import '../ai_logic.dart';
import '../entities/ai_page_mode.dart';
import '../infrastructure/l10n/generated/app_localizations.dart';
import '../service/theme_service.dart';
import 'common/constants.dart';
import 'common/go_back_button.dart';
import 'common/round_icon_button.dart';

class PhaseItem {
  final int? time;
  final String text;

  PhaseItem(this.time, this.text);

  @override
  String toString() {
    String timeStr = '';
    if (time != null) {
      int minutes = time! ~/ 60;
      int remainingSeconds = time! % 60;

      String minutesString = minutes.toString().padLeft(2, '0');
      String secondsString = remainingSeconds.toString().padLeft(2, '0');

      timeStr = '$minutesString:$secondsString';
    }

    return timeStr.isEmpty ? text : '$timeStr -> $text';
  }
}

class ListItem {
  final String title;
  final List<PhaseItem> items;

  ListItem(this.title, this.items);
}

class AiMeditationScriptView {
  final AiLogic logic;
  final ThemeService theme;
  final Function(AiPageMode) onSetPageMode;
  final Function() onRebuild;
  int selectedIndex = -1;

  AiMeditationScriptView({
    required this.logic,
    required this.theme,
    required this.onSetPageMode,
    required this.onRebuild,
  });

  TextStyle _textStyle({bool? disabled, bool? bold}) {
    final appStyle = theme.currentAppStyle;

    return TextStyle(
      fontWeight: bold != null ? FontWeight.w800 : null,
      fontSize: kFormFontSize,
      color: disabled ?? false ? appStyle.formTextDisabled : appStyle.formText,
    );
  }

  Text _formText(String text, {bool? disabled, bool? bold, bool? expanded}) {
    final maxLines =
        expanded != null
            ? expanded
                ? null
                : 2
            : null;

    return Text(
      text,
      maxLines: maxLines,
      overflow: maxLines != null && maxLines > 0 ? TextOverflow.ellipsis : null,
      style: _textStyle(disabled: disabled, bold: bold),
    );
  }

  String _formatTime(int? seconds) {
    if (seconds == null) return '';
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Widget _buildPhaseItems(List<PhaseItem> items, bool isSelected) {
    if (!isSelected) {
      // Collapsed: show first item only
      return _formText(
        items.isNotEmpty ? items.first.text : '',
        expanded: false,
      );
    }

    // Expanded: show all items with formatting in a scrollable container
    return Flexible(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: items.map((phaseItem) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (phaseItem.time != null) ...[
                    Icon(
                      Icons.schedule,
                      size: 16,
                      color: theme.currentAppStyle.primary,
                    ),
                    const SizedBox(width: 4),
                    SizedBox(
                      width: 50,
                      child: Text(
                        _formatTime(phaseItem.time),
                        style: _textStyle(bold: true),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text(
                      phaseItem.text,
                      style: _textStyle(),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Card(
          color: theme.currentAppStyle.inversePrimary.withOpacity(0.3),
          margin: const EdgeInsets.all(4.0),
          child: Container(
            height: 90.0,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 16,
                  width: 120,
                  decoration: BoxDecoration(
                    color: theme.currentAppStyle.formTextDisabled
                        .withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 14,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.currentAppStyle.formTextDisabled
                        .withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  height: 14,
                  width: 200,
                  decoration: BoxDecoration(
                    color: theme.currentAppStyle.formTextDisabled
                        .withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget getView(BuildContext context, {required EdgeInsets safeArea}) {
    final l10n = AppLocalizations.of(context)!;

    return Dismissible(
      direction: DismissDirection.startToEnd,
      resizeDuration: const Duration(milliseconds: 50),
      onDismissed: (DismissDirection direction) {
        if (direction == DismissDirection.startToEnd) {
          logic.cancelRequest();
          onSetPageMode(AiPageMode.list);
        }
      },
      key: const Key('ai_script_view'),
      child: Padding(
        padding: EdgeInsets.only(top: safeArea.top),
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (deepPop, _) {
            logic.cancelRequest();
            onSetPageMode(AiPageMode.list);
          },
          child: !logic.isReady
              ? Padding(
                  padding: EdgeInsets.only(top: safeArea.top + 60),
                  child: _buildSkeletonLoader(),
                )
              : Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GoBackButton(
                          themeService: theme,
                          padding: 8.0,
                          onTap: () {
                            logic.cancelRequest();
                            onSetPageMode(AiPageMode.list);
                          },
                        ),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 2,
                            ),
                            child: Text(
                              logic.script?.title ?? '',
                              style: TextStyle(
                                fontSize: kTitleFontSize,
                                color: theme.currentAppStyle.inversePrimary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        RoundIconButton(
                          icon: Icons.play_arrow,
                          themeService: theme,
                          padding: 8.0,
                          onTap: () {
                            logic.loadScript(null);
                            onSetPageMode(AiPageMode.meditation);
                          },
                        ),
                      ],
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8.0),
                        itemCount: (logic.script?.body.length ?? -2) + 2,
                        itemBuilder: (BuildContext context, int index) {
                          late ListItem item;
                          bool isIntroOrConclusion = false;

                          if (index == 0) {
                            isIntroOrConclusion = true;
                            item = ListItem(l10n.lb_introduction, [
                              PhaseItem(
                                null,
                                logic.script?.introduction ?? '',
                              ),
                            ]);
                          } else if (index ==
                              (logic.script?.body.length ?? -2) + 1) {
                            isIntroOrConclusion = true;
                            item = ListItem(l10n.lb_conclusion, [
                              PhaseItem(null, logic.script?.conclusion ?? ''),
                            ]);
                          } else {
                            item = ListItem(
                              logic.script?.body[index - 1].phase.name ?? '',
                              logic.script?.body[index - 1].phase.items
                                      .map(
                                        (x) => PhaseItem(
                                          x.startTime,
                                          x.instructions,
                                        ),
                                      )
                                      .toList() ??
                                  [],
                            );
                          }

                          final isSelected = index == selectedIndex;

                          return GestureDetector(
                            onTap: () {
                              selectedIndex = isSelected ? -1 : index;
                              onRebuild();
                            },
                            child: Card(
                              color: isIntroOrConclusion
                                  ? theme.currentAppStyle.inversePrimary
                                      .withOpacity(0.95)
                                  : theme.currentAppStyle.inversePrimary,
                              margin: const EdgeInsets.all(4.0),
                              child: AnimatedSize(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                child: Container(
                                  constraints: const BoxConstraints(
                                    minHeight: 90.0,
                                    maxHeight: 400.0,
                                  ),
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        children: [
                                          if (isIntroOrConclusion)
                                            Icon(
                                              index == 0
                                                  ? Icons.play_circle_outline
                                                  : Icons.check_circle_outline,
                                              size: 20,
                                              color:
                                                  theme.currentAppStyle.primary,
                                            ),
                                          if (isIntroOrConclusion)
                                            const SizedBox(width: 8),
                                          Expanded(
                                            child: _formText(
                                              item.title,
                                              bold: true,
                                            ),
                                          ),
                                          Icon(
                                            isSelected
                                                ? Icons.expand_less
                                                : Icons.expand_more,
                                            color: theme.currentAppStyle.primary,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      _buildPhaseItems(item.items, isSelected),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
