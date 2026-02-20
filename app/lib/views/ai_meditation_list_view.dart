import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meditimer/entities/ai_page_mode.dart';

import '../ai_logic.dart';
import '../infrastructure/l10n/generated/app_localizations.dart';
import '../infrastructure/router/hero_dialog_route.dart';
import '../service/theme_service.dart';
import 'common/ai_info_dialog.dart';
import 'common/constants.dart';
import 'common/go_back_button.dart';
import 'common/info_button.dart';
import 'common/round_icon_button.dart';

class AiMeditationListView {
  final AiLogic logic;
  final ThemeService theme;
  final Function(AiPageMode) onSetPageMode;
  final Function() onRebuild;
  int selectedIndex = -1;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _listKey = GlobalKey();

  AiMeditationListView({
    required this.logic,
    required this.theme,
    required this.onRebuild,
    required this.onSetPageMode,
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

  void _scrollToIndex(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        final position = index * 120.0; // Approximate item height
        _scrollController.animateTo(
          position,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.self_improvement,
            size: 64,
            color: theme.currentAppStyle.formTextDisabled,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.lb_no_meditations_available,
            style: _textStyle(disabled: true, bold: true),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.lb_no_meditations_subtitle,
            style: _textStyle(disabled: true),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Card(
          color: theme.currentAppStyle.inversePrimary.withOpacity(0.3),
          margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Container(
            height: 90.0,
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 16,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: theme.currentAppStyle.formTextDisabled
                              .withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 16,
                        width: 150,
                        decoration: BoxDecoration(
                          color: theme.currentAppStyle.formTextDisabled
                              .withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                CircleAvatar(
                  backgroundColor: theme.currentAppStyle.formTextDisabled
                      .withOpacity(0.3),
                  radius: 24,
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

    return Padding(
      padding: EdgeInsets.only(top: safeArea.top),
      child: Column(
        children: [
          Row(
            children: [
              GoBackButton(
                themeService: theme,
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 2,
                  ),
                  child: Text(
                    l10n.lb_miditation_from_ai,
                    style: TextStyle(
                      fontSize: kTitleFontSize,
                      color: theme.currentAppStyle.inversePrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              InfoButton(
                themeService: theme,
                onTap: () {
                  logic.cancelRequest();
                  Navigator.of(context).push(
                    HeroDialogRoute(
                      builder: (context) {
                        return AiInfoDialog();
                      },
                    ),
                  );
                },
              ),
            ],
          ),
          Expanded(
            child: !logic.isReady
                ? _buildSkeletonLoader()
                : logic.infoList.isEmpty
                    ? _buildEmptyState(l10n)
                    : RefreshIndicator(
                        color: theme.currentAppStyle.inversePrimary,
                        backgroundColor: theme.currentAppStyle.primary,
                        onRefresh: () async {
                          // Trigger refresh logic
                          await Future.delayed(const Duration(seconds: 1));
                          onRebuild();
                        },
                        child: ListView.builder(
                          key: _listKey,
                          controller: _scrollController,
                          padding: const EdgeInsets.all(8.0),
                          itemCount: logic.infoList.length,
                          itemBuilder: (BuildContext context, int index) {
                            final item = logic.infoList[index];
                            final isSelected = index == selectedIndex;

                            return GestureDetector(
                              onTap: () {
                                final newIndex = isSelected ? -1 : index;
                                selectedIndex = newIndex;
                                if (newIndex != -1) {
                                  _scrollToIndex(newIndex);
                                }
                                onRebuild();
                              },
                              child: Card(
                                color: theme.currentAppStyle.inversePrimary,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                  vertical: 4.0,
                                ),
                                child: AnimatedSize(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  child: Container(
                                    constraints: const BoxConstraints(
                                      minHeight: 90.0,
                                      maxHeight: 250.0,
                                    ),
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: _formText(
                                                      item.title,
                                                      bold: true,
                                                      expanded: isSelected,
                                                    ),
                                                  ),
                                                  Icon(
                                                    isSelected
                                                        ? Icons.expand_less
                                                        : Icons.expand_more,
                                                    color: theme
                                                        .currentAppStyle.primary,
                                                  ),
                                                ],
                                              ),
                                              if (isSelected) ...[
                                                const SizedBox(height: 12),
                                                TweenAnimationBuilder<double>(
                                                  tween: Tween<double>(
                                                    begin: 0.0,
                                                    end: 1.0,
                                                  ),
                                                  duration: const Duration(
                                                    milliseconds: 200,
                                                  ),
                                                  builder: (context, value,
                                                      child) {
                                                    return Opacity(
                                                      opacity: value,
                                                      child: Transform.scale(
                                                        scale: value,
                                                        alignment:
                                                            Alignment.centerLeft,
                                                        child: child,
                                                      ),
                                                    );
                                                  },
                                                  child: Wrap(
                                                    spacing: 8,
                                                    runSpacing: 8,
                                                    children: [
                                                      Chip(
                                                        backgroundColor: theme
                                                            .currentAppStyle
                                                            .primary,
                                                        avatar: Icon(
                                                          Icons.av_timer,
                                                          color: theme
                                                              .currentAppStyle
                                                              .inversePrimary,
                                                        ),
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                            20.0,
                                                          ),
                                                        ),
                                                        label: Text(
                                                          '${item.duration} ${l10n.lb_minute_short}',
                                                          style: TextStyle(
                                                            color: theme
                                                                .currentAppStyle
                                                                .inversePrimary,
                                                          ),
                                                        ),
                                                      ),
                                                      Chip(
                                                        backgroundColor: theme
                                                            .currentAppStyle
                                                            .primary,
                                                        avatar: Icon(
                                                          Icons.date_range,
                                                          color: theme
                                                              .currentAppStyle
                                                              .inversePrimary,
                                                        ),
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                            20.0,
                                                          ),
                                                        ),
                                                        label: Text(
                                                          DateFormat(
                                                            'dd MMM',
                                                            l10n.localeName,
                                                          ).format(
                                                            DateTime
                                                                .fromMillisecondsSinceEpoch(
                                                              item.timestamp,
                                                            ),
                                                          ),
                                                          style: TextStyle(
                                                            color: theme
                                                                .currentAppStyle
                                                                .inversePrimary,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            RoundIconButton(
                                              icon: Icons.play_arrow,
                                              themeService: theme,
                                              padding: 0.0,
                                              inverseColor: true,
                                              onTap: () {
                                                logic.loadScript(item.duration);
                                                onSetPageMode(
                                                    AiPageMode.meditation);
                                              },
                                            ),
                                            if (isSelected) ...[
                                              const SizedBox(height: 8),
                                              TweenAnimationBuilder<double>(
                                                tween: Tween<double>(
                                                  begin: 0.2,
                                                  end: 1.0,
                                                ),
                                                duration: const Duration(
                                                  milliseconds: 300,
                                                ),
                                                builder: (
                                                  BuildContext context,
                                                  double size,
                                                  Widget? child,
                                                ) {
                                                  return RoundIconButton(
                                                    icon: Icons.visibility,
                                                    themeService: theme,
                                                    padding: 0.0,
                                                    scale: size,
                                                    inverseColor: true,
                                                    onTap: () {
                                                      logic.loadViewScript(
                                                          item.duration);
                                                      onSetPageMode(
                                                          AiPageMode.view);
                                                    },
                                                  );
                                                },
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
