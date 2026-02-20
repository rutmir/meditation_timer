import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import '../entities/pranayama_session.dart';
import '../entities/scheduling_mode.dart';
import '../infrastructure/l10n/generated/app_localizations.dart';
import '../infrastructure/services/schedule_storage_service.dart';
import '../main.dart';
import '../timer_logic.dart';
import '../service/locale_service.dart';
import '../service/theme_service.dart';
import '../utils.dart';
import 'common/constants.dart';
import 'common/incremental_slider.dart';
import 'settings/advanced_schedule_widget.dart';
import 'settings/collapsible_section.dart';
import 'settings/reset_confirm_dialog.dart';

enum SettingsSection { pranayama, meditation, appSettings }

class TimerSettingsView {
  final TimerLogic logic;
  final ThemeService theme;
  final LocaleService locale;
  final Function() onClose;

  TimerSettingsView({
    required this.theme,
    required this.locale,
    required this.onClose,
    required this.logic,
  });

  TextStyle _editTextStyle({bool? disabled, bool? bold}) {
    final appStyle = theme.currentAppStyle;

    return TextStyle(
      fontWeight: bold != null ? FontWeight.w800 : null,
      fontSize: kFormFontSize,
      color:
          (disabled ?? false) ? appStyle.formTextDisabled : appStyle.formText,
    );
  }

  Text _formText(String text, {bool? disabled}) =>
      Text(text, style: _editTextStyle(disabled: disabled));

  RichText _formRichText({
    required String starttext,
    String? boldtext,
    String? endtext,
    bool? disabled,
  }) => RichText(
    maxLines: 2,
    text: TextSpan(
      text: starttext,
      style: _editTextStyle(disabled: disabled),
      children: [
        if (boldtext != null)
          TextSpan(
            text: boldtext,
            style: _editTextStyle(disabled: disabled, bold: true),
          ),
        if (endtext != null)
          TextSpan(text: endtext, style: _editTextStyle(disabled: disabled)),
      ],
    ),
  );

  Widget _disabledWrapper({required bool disabled, required Widget child}) {
    return Opacity(
      opacity: disabled ? 0.5 : 1.0,
      child: IgnorePointer(ignoring: disabled, child: child),
    );
  }

  void _showHelpDialog(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              title,
              style: TextStyle(color: theme.currentAppStyle.formText),
            ),
            backgroundColor: theme.currentAppStyle.formBackground,
            content: Text(
              content,
              style: TextStyle(color: theme.currentAppStyle.formText),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(MaterialLocalizations.of(context).okButtonLabel),
              ),
            ],
          ),
    );
  }

  void _showDurationQuickPick(
    BuildContext context, {
    required String title,
    required double min,
    required double max,
    required Function(double) onSelected,
  }) {
    final List<int> options =
        [
          1,
          2,
          5,
          10,
          15,
          20,
          30,
          45,
          60,
          90,
          120,
          180,
          240,
        ].where((opt) => opt >= min && opt <= max).toList();

    showDialog(
      context: context,
      builder:
          (context) => SimpleDialog(
            title: Text(
              title,
              style: TextStyle(color: theme.currentAppStyle.formText),
            ),
            backgroundColor: theme.currentAppStyle.formBackground,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children:
                      options
                          .map(
                            (opt) => ActionChip(
                              label: Text('$opt'),
                              onPressed: () {
                                onSelected(opt.toDouble());
                                Navigator.pop(context);
                              },
                            ),
                          )
                          .toList(),
                ),
              ),
            ],
          ),
    );
  }

  Widget getView(
    BuildContext context, {
    required bool isRunning,
    required EdgeInsets safeArea,
    SettingsSection expandedSection = SettingsSection.meditation,
  }) {
    const horizontalPadding = 10.0;
    final mq = MediaQuery.of(context);
    final preferredWidth = mq.size.width - horizontalPadding * 2;
    final l10n = AppLocalizations.of(context)!;
    final appStyle = theme.currentAppStyle;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          onClose();
        }
      },
      child: Scaffold(
        backgroundColor: theme.currentAppStyle.primary,
        appBar: AppBar(
          backgroundColor: theme.currentAppStyle.primary,
          title: Text(
            l10n.lb_app_settings,
            style: TextStyle(color: theme.currentAppStyle.inversePrimary),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: theme.currentAppStyle.inversePrimary,
            ),
            onPressed: onClose,
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(horizontalPadding),
            child: Column(
              spacing: kFormSpacer,
              children: [
                if (isRunning)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orangeAccent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orangeAccent),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orangeAccent),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            l10n.msg_session_active_locked,
                            style: TextStyle(
                              color: appStyle.formText,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                CollapsibleSection(
                  title: l10n.lb_pra_settings,
                  subtitle: l10n.lb_pranayama_desc,
                  icon: Icons.air,
                  initiallyExpanded:
                      expandedSection == SettingsSection.pranayama,
                  appStyle: appStyle,
                  onHelpTap:
                      () => _showHelpDialog(
                        context,
                        title: l10n.help_pra_title,
                        content: l10n.help_pra_content,
                      ),
                  child: Column(
                    spacing: horizontalPadding * 3,
                    children: [
                      _disabledWrapper(
                        disabled: isRunning,
                        child: Row(
                          children: [
                            SizedBox(
                              width: preferredWidth / 3 * 2,
                              child: _formText(l10n.lb_pra_start_round),
                            ),
                            Expanded(
                              child: Switch(
                                value: logic.pranayamaSession.enabled,
                                onChanged:
                                    (val) => logic.pranayamaEnabled = val,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap:
                                            isRunning ||
                                                    !logic
                                                        .pranayamaSession
                                                        .enabled
                                                ? null
                                                : () => _showDurationQuickPick(
                                                  context,
                                                  title:
                                                      l10n.lb_pra_set_duration,
                                                  min:
                                                      PranayamaSession
                                                          .durationMin
                                                          .toDouble(),
                                                  max:
                                                      PranayamaSession
                                                          .durationMax
                                                          .toDouble(),
                                                  onSelected:
                                                      (val) =>
                                                          logic.pranayamaDuration =
                                                              val,
                                                ),
                                        child: _formRichText(
                                          starttext:
                                              '${l10n.lb_pra_set_duration} (',
                                          boldtext:
                                              '${logic.pranayamaSession.duration}',
                                          endtext: ' ${l10n.lb_minute_short})',
                                          disabled:
                                              isRunning ||
                                              !logic.pranayamaSession.enabled,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    _formText(
                                      '${PranayamaSession.durationMin} ${l10n.lb_minute_short}',
                                      disabled:
                                          isRunning ||
                                          !logic.pranayamaSession.enabled,
                                    ),
                                    Expanded(
                                      child: IncrementalSlider(
                                        min:
                                            PranayamaSession.durationMin
                                                .toDouble(),
                                        max:
                                            PranayamaSession.durationMax
                                                .toDouble(),
                                        value:
                                            logic
                                                .pranayamaSession
                                                .durationValue,
                                        onChanged:
                                            isRunning ||
                                                    !logic
                                                        .pranayamaSession
                                                        .enabled
                                                ? null
                                                : (val) =>
                                                    logic.pranayamaDuration =
                                                        val,
                                      ),
                                    ),
                                    _formText(
                                      '${PranayamaSession.durationMax} ${l10n.lb_minute_short}',
                                      disabled:
                                          isRunning ||
                                          !logic.pranayamaSession.enabled,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _formText(
                                  l10n.lb_pra_use_metronome,
                                  disabled: !logic.pranayamaSession.enabled,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  l10n.lb_metronome_desc,
                                  style: TextStyle(
                                    fontSize: kFormFontSize - 4,
                                    color: (!logic.pranayamaSession.enabled
                                            ? appStyle.formTextDisabled
                                            : appStyle.formText)
                                        .withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: logic.pranayamaSession.useMetronome,
                            onChanged:
                                !logic.pranayamaSession.enabled
                                    ? null
                                    : (val) =>
                                        logic.pranayamaUseMetronome = val,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: _formRichText(
                                        starttext:
                                            '${l10n.lb_pra_metronome_volume} (',
                                        boldtext:
                                            '${(logic.pranayamaSession.volume * 100).round()}%',
                                        endtext: ')',
                                        disabled:
                                            !logic
                                                .pranayamaSession
                                                .useMetronome ||
                                            !logic.pranayamaSession.enabled,
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.play_arrow,
                                        color:
                                            !logic
                                                        .pranayamaSession
                                                        .useMetronome ||
                                                    !logic
                                                        .pranayamaSession
                                                        .enabled
                                                ? appStyle.formTextDisabled
                                                : appStyle.formText,
                                      ),
                                      onPressed:
                                          !logic
                                                      .pranayamaSession
                                                      .useMetronome ||
                                                  !logic
                                                      .pranayamaSession
                                                      .enabled
                                              ? null
                                              : () => logic.previewSound(
                                                'metronome',
                                                logic.pranayamaSession.volume,
                                              ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    _formText(
                                      '0 %',
                                      disabled:
                                          !logic
                                              .pranayamaSession
                                              .useMetronome ||
                                          !logic.pranayamaSession.enabled,
                                    ),
                                    Expanded(
                                      child: IncrementalSlider(
                                        min: 0.0,
                                        max: 1.0,
                                        step: 0.05,
                                        value: logic.pranayamaSession.volume,
                                        onChanged:
                                            !logic
                                                        .pranayamaSession
                                                        .useMetronome ||
                                                    !logic
                                                        .pranayamaSession
                                                        .enabled
                                                ? null
                                                : (val) =>
                                                    logic.pranayamaMetronomeVolume =
                                                        val,
                                      ),
                                    ),
                                    _formText(
                                      '100 %',
                                      disabled:
                                          !logic
                                              .pranayamaSession
                                              .useMetronome ||
                                          !logic.pranayamaSession.enabled,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                CollapsibleSection(
                  title: l10n.lb_med_settings,
                  icon: Icons.self_improvement,
                  initiallyExpanded:
                      expandedSection == SettingsSection.meditation,
                  appStyle: appStyle,
                  child: Column(
                    spacing: horizontalPadding * 3,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap:
                                            isRunning
                                                ? null
                                                : () => _showDurationQuickPick(
                                                  context,
                                                  title:
                                                      l10n.lb_med_session_duration,
                                                  min:
                                                      logic
                                                          .unguidedMeditationSession
                                                          .durationMin,
                                                  max:
                                                      logic
                                                          .unguidedMeditationSession
                                                          .durationMax,
                                                  onSelected:
                                                      (val) =>
                                                          logic.meditationSessionDuration =
                                                              val,
                                                ),
                                        child: _formRichText(
                                          starttext:
                                              '${l10n.lb_med_session_duration} (',
                                          boldtext:
                                              '${logic.unguidedMeditationSession.sessionDuration}',
                                          endtext: ' ${l10n.lb_minute_short})',
                                          disabled: isRunning,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    _formText(
                                      '${logic.unguidedMeditationSession.durationMin.round()} ${l10n.lb_minute_short}',
                                      disabled: isRunning,
                                    ),
                                    Expanded(
                                      child: IncrementalSlider(
                                        min:
                                            logic
                                                .unguidedMeditationSession
                                                .durationMin,
                                        max:
                                            logic
                                                .unguidedMeditationSession
                                                .durationMax,
                                        value:
                                            logic
                                                .unguidedMeditationSession
                                                .sessionDurationValue,
                                        onChanged:
                                            isRunning
                                                ? null
                                                : (val) =>
                                                    logic.meditationSessionDuration =
                                                        val,
                                      ),
                                    ),
                                    _formText(
                                      '${logic.unguidedMeditationSession.durationMax.round()} ${l10n.lb_minute_short}',
                                      disabled: isRunning,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // Scheduling mode toggle
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _formText(l10n.lb_scheduling_mode),
                                const SizedBox(height: 8),
                                SegmentedButton<SchedulingMode>(
                                  segments: [
                                    ButtonSegment(
                                      value: SchedulingMode.interval,
                                      label: Text(l10n.lb_mode_interval),
                                      icon: Icon(Icons.timer),
                                    ),
                                    ButtonSegment(
                                      value: SchedulingMode.advanced,
                                      label: Text(
                                        l10n.lb_mode_advanced,
                                        textScaler:
                                            locale.isRu
                                                ? TextScaler.linear(0.9)
                                                : null,
                                      ),
                                      icon: Icon(Icons.playlist_add),
                                    ),
                                  ],
                                  selected: {logic.schedulingMode},
                                  onSelectionChanged:
                                      isRunning
                                          ? null
                                          : (Set<SchedulingMode> selected) {
                                            logic.schedulingMode =
                                                selected.first;
                                          },
                                  style: ButtonStyle(
                                    backgroundColor:
                                        WidgetStateProperty.resolveWith((
                                          states,
                                        ) {
                                          if (states.contains(
                                            WidgetState.selected,
                                          )) {
                                            return Colors.lightGreenAccent;
                                          }
                                          return appStyle.formBackground;
                                        }),
                                    foregroundColor:
                                        WidgetStateProperty.resolveWith((
                                          states,
                                        ) {
                                          if (states.contains(
                                            WidgetState.selected,
                                          )) {
                                            return Colors.black;
                                          }
                                          return appStyle.formText;
                                        }),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // Show interval settings or advanced schedule widget based on mode
                      if (logic.schedulingMode == SchedulingMode.interval) ...[
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _formText(l10n.lb_med_use_session_gong),
                                  const SizedBox(height: 4),
                                  Text(
                                    l10n.lb_session_gong_desc,
                                    style: TextStyle(
                                      fontSize: kFormFontSize - 4,
                                      color: appStyle.formText.withValues(
                                        alpha: 0.7,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value:
                                  logic
                                      .unguidedMeditationSession
                                      .useSessionSound,
                              onChanged:
                                  (val) => logic.meditationUseSession = val,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _formRichText(
                                          starttext:
                                              '${l10n.lb_med_session_gong_volume} (',
                                          boldtext:
                                              '${(logic.unguidedMeditationSession.sessionVolume * 100).round()}%',
                                          endtext: ')',
                                          disabled:
                                              !logic
                                                  .unguidedMeditationSession
                                                  .useSessionSound,
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.play_arrow,
                                          color:
                                              !logic
                                                      .unguidedMeditationSession
                                                      .useSessionSound
                                                  ? appStyle.formTextDisabled
                                                  : appStyle.formText,
                                        ),
                                        onPressed:
                                            !logic
                                                    .unguidedMeditationSession
                                                    .useSessionSound
                                                ? null
                                                : () => logic.previewSound(
                                                  'session',
                                                  logic
                                                      .unguidedMeditationSession
                                                      .sessionVolume,
                                                ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      _formText(
                                        '0 %',
                                        disabled:
                                            !logic
                                                .unguidedMeditationSession
                                                .useSessionSound,
                                      ),
                                      Expanded(
                                        child: IncrementalSlider(
                                          min: 0.0,
                                          max: 1.0,
                                          step: 0.05,
                                          value:
                                              logic
                                                  .unguidedMeditationSession
                                                  .sessionVolume,
                                          onChanged:
                                              !logic
                                                      .unguidedMeditationSession
                                                      .useSessionSound
                                                  ? null
                                                  : (val) =>
                                                      logic.meditationSessionVolume =
                                                          val,
                                        ),
                                      ),
                                      _formText(
                                        '100 %',
                                        disabled:
                                            !logic
                                                .unguidedMeditationSession
                                                .useSessionSound,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Divider(),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _formText(l10n.lb_med_use_round_gong),
                                  const SizedBox(height: 4),
                                  Text(
                                    l10n.lb_round_gong_desc,
                                    style: TextStyle(
                                      fontSize: kFormFontSize - 4,
                                      color: appStyle.formText.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value:
                                  logic.unguidedMeditationSession.useRoundSound,
                              onChanged:
                                  (val) => logic.meditationUseRound = val,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap:
                                              isRunning ||
                                                      !logic
                                                          .unguidedMeditationSession
                                                          .useRoundSound
                                                  ? null
                                                  : () => _showDurationQuickPick(
                                                    context,
                                                    title:
                                                        l10n.lb_med_round_duration,
                                                    min:
                                                        logic
                                                            .unguidedMeditationSession
                                                            .roundDurationMin,
                                                    max:
                                                        logic
                                                            .unguidedMeditationSession
                                                            .roundDurationMax,
                                                    onSelected:
                                                        (val) =>
                                                            logic.meditationRoundDuration =
                                                                val,
                                                  ),
                                          child: _formRichText(
                                            starttext:
                                                '${l10n.lb_med_round_duration} (',
                                            boldtext:
                                                '${logic.unguidedMeditationSession.roundDuration}',
                                            endtext:
                                                ' ${l10n.lb_minute_short})',
                                            disabled:
                                                isRunning ||
                                                !logic
                                                    .unguidedMeditationSession
                                                    .useRoundSound,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      _formText(
                                        '${logic.unguidedMeditationSession.roundDurationMin.round()} ${l10n.lb_minute_short}',
                                        disabled:
                                            isRunning ||
                                            !logic
                                                .unguidedMeditationSession
                                                .useRoundSound,
                                      ),
                                      Expanded(
                                        child: IncrementalSlider(
                                          min:
                                              logic
                                                  .unguidedMeditationSession
                                                  .roundDurationMin,
                                          max:
                                              logic
                                                  .unguidedMeditationSession
                                                  .roundDurationMax,
                                          value: trimDouble(
                                            logic
                                                .unguidedMeditationSession
                                                .roundDurationValue,
                                            logic
                                                .unguidedMeditationSession
                                                .roundDurationMin,
                                            logic
                                                .unguidedMeditationSession
                                                .roundDurationMax,
                                          ),
                                          onChanged:
                                              isRunning ||
                                                      !logic
                                                          .unguidedMeditationSession
                                                          .useRoundSound
                                                  ? null
                                                  : (val) =>
                                                      logic.meditationRoundDuration =
                                                          val,
                                        ),
                                      ),
                                      _formText(
                                        '${logic.unguidedMeditationSession.roundDurationMax.round()} ${l10n.lb_minute_short}',
                                        disabled:
                                            isRunning ||
                                            !logic
                                                .unguidedMeditationSession
                                                .useRoundSound,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _formRichText(
                                          starttext:
                                              '${l10n.lb_med_round_gong_volume} (',
                                          boldtext:
                                              '${(logic.unguidedMeditationSession.roundVolume * 100).round()}%',
                                          endtext: ')',
                                          disabled:
                                              !logic
                                                  .unguidedMeditationSession
                                                  .useRoundSound,
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.play_arrow,
                                          color:
                                              !logic
                                                      .unguidedMeditationSession
                                                      .useRoundSound
                                                  ? appStyle.formTextDisabled
                                                  : appStyle.formText,
                                        ),
                                        onPressed:
                                            !logic
                                                    .unguidedMeditationSession
                                                    .useRoundSound
                                                ? null
                                                : () => logic.previewSound(
                                                  'round',
                                                  logic
                                                      .unguidedMeditationSession
                                                      .roundVolume,
                                                ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      _formText(
                                        '0 %',
                                        disabled:
                                            !logic
                                                .unguidedMeditationSession
                                                .useRoundSound,
                                      ),
                                      Expanded(
                                        child: IncrementalSlider(
                                          min: 0.0,
                                          max: 1.0,
                                          step: 0.05,
                                          value:
                                              logic
                                                  .unguidedMeditationSession
                                                  .roundVolume,
                                          onChanged:
                                              !logic
                                                      .unguidedMeditationSession
                                                      .useRoundSound
                                                  ? null
                                                  : (val) =>
                                                      logic.meditationRoundVolume =
                                                          val,
                                        ),
                                      ),
                                      _formText(
                                        '100 %',
                                        disabled:
                                            !logic
                                                .unguidedMeditationSession
                                                .useRoundSound,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Divider(),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _formText(l10n.lb_med_use_minor_gong),
                                  const SizedBox(height: 4),
                                  Text(
                                    l10n.lb_minor_gong_desc,
                                    style: TextStyle(
                                      fontSize: kFormFontSize - 4,
                                      color: appStyle.formText.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value:
                                  logic.unguidedMeditationSession.useMinorSound,
                              onChanged:
                                  (val) => logic.meditationUseMinor = val,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap:
                                              isRunning ||
                                                      !logic
                                                          .unguidedMeditationSession
                                                          .useMinorSound
                                                  ? null
                                                  : () => _showDurationQuickPick(
                                                    context,
                                                    title:
                                                        l10n.lb_med_minor_duration,
                                                    min:
                                                        logic
                                                            .unguidedMeditationSession
                                                            .minorDurationMin,
                                                    max:
                                                        logic
                                                            .unguidedMeditationSession
                                                            .minorDurationMax,
                                                    onSelected:
                                                        (val) =>
                                                            logic.meditationMinorDuration =
                                                                val,
                                                  ),
                                          child: _formRichText(
                                            starttext:
                                                '${l10n.lb_med_minor_duration} (',
                                            boldtext:
                                                '${logic.unguidedMeditationSession.minorDuration}',
                                            endtext:
                                                ' ${l10n.lb_minute_short})',
                                            disabled:
                                                isRunning ||
                                                !logic
                                                    .unguidedMeditationSession
                                                    .useMinorSound,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      _formText(
                                        '${logic.unguidedMeditationSession.minorDurationMin.round()} ${l10n.lb_minute_short}',
                                        disabled:
                                            isRunning ||
                                            !logic
                                                .unguidedMeditationSession
                                                .useMinorSound,
                                      ),
                                      Expanded(
                                        child: IncrementalSlider(
                                          min:
                                              logic
                                                  .unguidedMeditationSession
                                                  .minorDurationMin,
                                          max:
                                              logic
                                                  .unguidedMeditationSession
                                                  .minorDurationMax,
                                          value: trimDouble(
                                            logic
                                                .unguidedMeditationSession
                                                .minorDurationValue,
                                            logic
                                                .unguidedMeditationSession
                                                .minorDurationMin,
                                            logic
                                                .unguidedMeditationSession
                                                .minorDurationMax,
                                          ),
                                          onChanged:
                                              isRunning ||
                                                      !logic
                                                          .unguidedMeditationSession
                                                          .useMinorSound
                                                  ? null
                                                  : (val) =>
                                                      logic.meditationMinorDuration =
                                                          val,
                                        ),
                                      ),
                                      _formText(
                                        '${logic.unguidedMeditationSession.minorDurationMax.round()} ${l10n.lb_minute_short}',
                                        disabled:
                                            isRunning ||
                                            !logic
                                                .unguidedMeditationSession
                                                .useMinorSound,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _formRichText(
                                          starttext:
                                              '${l10n.lb_med_minor_gong_volume} (',
                                          boldtext:
                                              '${(logic.unguidedMeditationSession.minorVolume * 100).round()}%',
                                          endtext: ')',
                                          disabled:
                                              !logic
                                                  .unguidedMeditationSession
                                                  .useMinorSound,
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.play_arrow,
                                          color:
                                              !logic
                                                      .unguidedMeditationSession
                                                      .useMinorSound
                                                  ? appStyle.formTextDisabled
                                                  : appStyle.formText,
                                        ),
                                        onPressed:
                                            !logic
                                                    .unguidedMeditationSession
                                                    .useMinorSound
                                                ? null
                                                : () => logic.previewSound(
                                                  'minor',
                                                  logic
                                                      .unguidedMeditationSession
                                                      .minorVolume,
                                                ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      _formText(
                                        '0 %',
                                        disabled:
                                            !logic
                                                .unguidedMeditationSession
                                                .useMinorSound,
                                      ),
                                      Expanded(
                                        child: IncrementalSlider(
                                          min: 0.0,
                                          max: 1.0,
                                          step: 0.05,
                                          value:
                                              logic
                                                  .unguidedMeditationSession
                                                  .minorVolume,
                                          onChanged:
                                              !logic
                                                      .unguidedMeditationSession
                                                      .useMinorSound
                                                  ? null
                                                  : (val) =>
                                                      logic.meditationMinorVolume =
                                                          val,
                                        ),
                                      ),
                                      _formText(
                                        '100 %',
                                        disabled:
                                            !logic
                                                .unguidedMeditationSession
                                                .useMinorSound,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        // Advanced scheduling mode
                        AdvancedScheduleWidget(
                          theme: theme,
                          sessionDurationMinutes:
                              logic.unguidedMeditationSession.sessionDuration,
                          events: logic.advancedEvents,
                          onEventsChanged: (events) {
                            logic.advancedEvents = events;
                          },
                          onPreviewSound: (soundType, volume) {
                            logic.previewSound(soundType, volume);
                          },
                          locale: locale,
                          storageService:
                              GetIt.instance<ScheduleStorageService>(),
                        ),
                      ],
                    ],
                  ),
                ),
                CollapsibleSection(
                  title: l10n.lb_app_settings,
                  icon: Icons.settings,
                  initiallyExpanded:
                      expandedSection == SettingsSection.appSettings,
                  appStyle: appStyle,
                  child: Column(
                    spacing: horizontalPadding * 3,
                    children: [
                      if (!kIsWeb)
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _formText(
                                          l10n.lb_app_use_silent_mode,
                                          disabled: isRunning,
                                        ),
                                      ),
                                      Tooltip(
                                        message: l10n.help_silence_title,
                                        child: GestureDetector(
                                          onTap:
                                              () => _showHelpDialog(
                                                context,
                                                title: l10n.help_silence_title,
                                                content:
                                                    l10n.help_silence_content,
                                              ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0,
                                            ),
                                            child: Icon(
                                              Icons.help_outline,
                                              color: appStyle.formText
                                                  .withOpacity(0.7),
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    l10n.lb_silent_mode_desc,
                                    style: TextStyle(
                                      fontSize: kFormFontSize - 4,
                                      color: (isRunning
                                              ? appStyle.formTextDisabled
                                              : appStyle.formText)
                                          .withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: logic.appSettings.useSilenceMode,
                              onChanged:
                                  isRunning
                                      ? null
                                      : (val) {
                                          if (val) {
                                            logic.enableSilenceModeWithPermission();
                                          } else {
                                            logic.appSettingsUseSilenceMode = false;
                                          }
                                        },
                            ),
                          ],
                        ),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      width: preferredWidth / 3 * 2,
                                      child: _formText(
                                        l10n.lb_app_color_scheme,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: SegmentedButton(
                                        segments:
                                            theme.availableSchemasLabel.entries
                                                .map(
                                                  (entry) => ButtonSegment(
                                                    value: entry.key,
                                                    label: _formText(
                                                      entry.value,
                                                    ),
                                                  ),
                                                )
                                                .toList(),
                                        selected: {theme.currentThemeName},
                                        showSelectedIcon: false,
                                        multiSelectionEnabled: false,
                                        onSelectionChanged: (selected) async {
                                          if (selected.isEmpty) return;

                                          final newThemeName = selected.first;

                                          if (newThemeName !=
                                              theme.currentThemeName) {
                                            await theme.setAppStyle(
                                              themeName: newThemeName,
                                            );

                                            logic.trigger();
                                          }
                                        },
                                        style: ButtonStyle(
                                          backgroundColor:
                                              WidgetStateProperty.resolveWith<
                                                Color
                                              >((Set<WidgetState> states) {
                                                if (states.contains(
                                                  WidgetState.selected,
                                                )) {
                                                  return Colors
                                                      .lightGreenAccent;
                                                }
                                                return theme
                                                    .currentAppStyle
                                                    .formBackground;
                                              }),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      width: preferredWidth / 3 * 2,
                                      child: _formText(l10n.lb_app_language),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: [
                                          ChoiceChip(
                                            label: _formText(
                                              l10n.lb_language_system_default,
                                            ),
                                            selected:
                                                locale.currentLocale == null,
                                            onSelected: (selected) async {
                                              if (selected) {
                                                await Provider.of<
                                                  LocaleProvider
                                                >(
                                                  context,
                                                  listen: false,
                                                ).clearLocale();
                                                logic.trigger();
                                              }
                                            },
                                            selectedColor:
                                                Colors.lightGreenAccent,
                                            backgroundColor:
                                                theme
                                                    .currentAppStyle
                                                    .formBackground,
                                          ),
                                          ...locale.supportedLocales.map(
                                            (loc) => ChoiceChip(
                                              label: _formText(
                                                locale.localeLabels[loc
                                                        .languageCode] ??
                                                    loc.languageCode,
                                              ),
                                              selected:
                                                  locale
                                                      .currentLocale
                                                      ?.languageCode ==
                                                  loc.languageCode,
                                              onSelected: (selected) async {
                                                if (selected) {
                                                  await Provider.of<
                                                    LocaleProvider
                                                  >(
                                                    context,
                                                    listen: false,
                                                  ).setLocale(loc);
                                                  logic.trigger();
                                                }
                                              },
                                              selectedColor:
                                                  Colors.lightGreenAccent,
                                              backgroundColor:
                                                  theme
                                                      .currentAppStyle
                                                      .formBackground,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      Center(
                        child: TextButton.icon(
                          icon: Icon(Icons.restore, color: appStyle.formText),
                          label: Text(
                            l10n.lb_reset_defaults,
                            style: TextStyle(
                              color: appStyle.formText,
                              fontSize: kFormFontSize,
                            ),
                          ),
                          onPressed: () async {
                            final localeProvider = Provider.of<LocaleProvider>(
                              context,
                              listen: false,
                            );
                            final confirmed = await showResetConfirmDialog(
                              context,
                              appStyle: appStyle,
                            );
                            if (confirmed) {
                              await logic.resetToDefaults();
                              await localeProvider.clearLocale();
                              await theme.setAppStyle(themeName: 'deepPurple');
                              logic.trigger();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
