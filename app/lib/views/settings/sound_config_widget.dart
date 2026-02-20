import 'package:flutter/material.dart';
import '../../entities/app_style.dart';
import '../../infrastructure/l10n/generated/app_localizations.dart';
import '../common/constants.dart';
import '../common/incremental_slider.dart';

/// A widget for configuring sound settings with toggle, volume, and optional interval.
///
/// Groups related sound controls visually with description text explaining
/// when the sound plays.
class SoundConfigWidget extends StatelessWidget {
  final String title;
  final String description;
  final bool enabled;
  final double volume;
  final int? intervalMinutes;
  final double? intervalMin;
  final double? intervalMax;
  final String? intervalExample;
  final AppStyle appStyle;
  final VoidCallback? onPreview;
  final ValueChanged<bool> onEnabledChanged;
  final ValueChanged<double> onVolumeChanged;
  final ValueChanged<double>? onIntervalChanged;
  final bool isLocked;

  const SoundConfigWidget({
    super.key,
    required this.title,
    required this.description,
    required this.enabled,
    required this.volume,
    this.intervalMinutes,
    this.intervalMin,
    this.intervalMax,
    this.intervalExample,
    required this.appStyle,
    this.onPreview,
    required this.onEnabledChanged,
    required this.onVolumeChanged,
    this.onIntervalChanged,
    this.isLocked = false,
  });

  TextStyle _textStyle({bool? disabled, bool? bold}) {
    return TextStyle(
      fontWeight: bold == true ? FontWeight.w800 : null,
      fontSize: kFormFontSize,
      color: (disabled ?? false) ? appStyle.formTextDisabled : appStyle.formText,
    );
  }

  void _showIntervalQuickPick(BuildContext context, AppLocalizations l10n) {
    if (intervalMin == null || intervalMax == null) return;

    final List<int> options = [1, 2, 3, 5, 10, 15, 20, 30, 45, 60]
        .where((opt) => opt >= intervalMin! && opt <= intervalMax!)
        .toList();

    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(
          title,
          style: TextStyle(color: appStyle.formText),
        ),
        backgroundColor: appStyle.formBackground,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: options
                  .map(
                    (opt) => ActionChip(
                      label: Text('$opt'),
                      onPressed: () {
                        onIntervalChanged?.call(opt.toDouble());
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bool controlsDisabled = !enabled;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title row with toggle
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: _textStyle(),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: kFormFontSize - 4,
                      color: appStyle.formText.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: enabled,
              onChanged: onEnabledChanged,
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Interval setting (if applicable)
        if (intervalMinutes != null && intervalMin != null && intervalMax != null) ...[
          Opacity(
            opacity: controlsDisabled || isLocked ? 0.5 : 1.0,
            child: IgnorePointer(
              ignoring: controlsDisabled || isLocked,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => _showIntervalQuickPick(context, l10n),
                    child: RichText(
                      text: TextSpan(
                        text: '${l10n.lb_med_round_duration} (',
                        style: _textStyle(disabled: controlsDisabled || isLocked),
                        children: [
                          TextSpan(
                            text: '$intervalMinutes',
                            style: _textStyle(disabled: controlsDisabled || isLocked, bold: true),
                          ),
                          TextSpan(
                            text: ' ${l10n.lb_minute_short})',
                            style: _textStyle(disabled: controlsDisabled || isLocked),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (intervalExample != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      intervalExample!,
                      style: TextStyle(
                        fontSize: kFormFontSize - 4,
                        color: (controlsDisabled || isLocked
                                ? appStyle.formTextDisabled
                                : appStyle.formText)
                            .withOpacity(0.7),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '${intervalMin!.round()} ${l10n.lb_minute_short}',
                        style: _textStyle(disabled: controlsDisabled || isLocked),
                      ),
                      Expanded(
                        child: IncrementalSlider(
                          min: intervalMin!,
                          max: intervalMax!,
                          value: intervalMinutes!.toDouble(),
                          onChanged: controlsDisabled || isLocked ? null : onIntervalChanged,
                        ),
                      ),
                      Text(
                        '${intervalMax!.round()} ${l10n.lb_minute_short}',
                        style: _textStyle(disabled: controlsDisabled || isLocked),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Volume control with preview button
        Opacity(
          opacity: controlsDisabled ? 0.5 : 1.0,
          child: IgnorePointer(
            ignoring: controlsDisabled,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          text: '${l10n.lb_med_session_gong_volume.split(' ').first} (',
                          style: _textStyle(disabled: controlsDisabled),
                          children: [
                            TextSpan(
                              text: '${(volume * 100).round()}%',
                              style: _textStyle(disabled: controlsDisabled, bold: true),
                            ),
                            TextSpan(
                              text: ')',
                              style: _textStyle(disabled: controlsDisabled),
                            ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.play_arrow,
                        color: controlsDisabled
                            ? appStyle.formTextDisabled
                            : appStyle.formText,
                      ),
                      onPressed: controlsDisabled ? null : onPreview,
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      '0 %',
                      style: _textStyle(disabled: controlsDisabled),
                    ),
                    Expanded(
                      child: IncrementalSlider(
                        min: 0.0,
                        max: 1.0,
                        step: 0.05,
                        value: volume,
                        onChanged: controlsDisabled ? null : onVolumeChanged,
                      ),
                    ),
                    Text(
                      '100 %',
                      style: _textStyle(disabled: controlsDisabled),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Generates interval example text like "For 60 min session: at 10, 20, 30 min"
String generateIntervalExample(
  AppLocalizations l10n,
  int sessionDuration,
  int intervalMinutes,
) {
  if (intervalMinutes <= 0 || sessionDuration <= 0) return '';

  final List<int> intervals = [];
  for (int i = intervalMinutes; i < sessionDuration; i += intervalMinutes) {
    intervals.add(i);
    if (intervals.length >= 5) {
      intervals.add(-1); // marker for "..."
      break;
    }
  }

  if (intervals.isEmpty) return '';

  final intervalsStr = intervals
      .map((i) => i == -1 ? '...' : '$i')
      .join(', ');

  return l10n.lb_interval_example(sessionDuration, intervalsStr);
}
