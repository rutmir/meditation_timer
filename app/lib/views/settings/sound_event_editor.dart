import 'package:flutter/material.dart';
import '../../entities/sound_event.dart';
import '../../infrastructure/l10n/generated/app_localizations.dart';
import '../../service/theme_service.dart';
import '../common/constants.dart';
import '../common/incremental_slider.dart';

/// Dialog for adding or editing a single sound event.
/// Provides time picker, sound type selector, and volume slider.
class SoundEventEditor extends StatefulWidget {
  final ThemeService theme;
  final SoundEvent? initialEvent;
  final int sessionDurationMs;
  final Function(SoundEvent) onSave;
  final void Function(String soundType, double volume)? onPreviewSound;
  final List<SoundEvent> existingEvents;

  const SoundEventEditor({
    super.key,
    required this.theme,
    required this.sessionDurationMs,
    required this.onSave,
    this.initialEvent,
    this.onPreviewSound,
    this.existingEvents = const [],
  });

  @override
  State<SoundEventEditor> createState() => _SoundEventEditorState();

  /// Show the editor as a dialog and return the created/edited event
  static Future<SoundEvent?> show({
    required BuildContext context,
    required ThemeService theme,
    required int sessionDurationMs,
    required void Function(String soundType, double volume) onPreviewSound,
    SoundEvent? initialEvent,
    List<SoundEvent> existingEvents = const [],
  }) async {
    SoundEvent? result;

    await showDialog(
      context: context,
      builder: (context) => SoundEventEditor(
        theme: theme,
        sessionDurationMs: sessionDurationMs,
        initialEvent: initialEvent,
        existingEvents: existingEvents,
        onSave: (event) {
          result = event;
          Navigator.of(context).pop();
        },
        onPreviewSound: onPreviewSound,
      ),
    );

    return result;
  }
}

class _SoundEventEditorState extends State<SoundEventEditor> {
  late int _timeMs;
  late SoundType _soundType;
  late double _volume;
  late int _repeatCount;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _timeMs = widget.initialEvent?.timeMs ?? 0;
    _soundType = widget.initialEvent?.soundType ?? SoundType.minor;
    _volume = widget.initialEvent?.volume ?? 0.8;
    _repeatCount = widget.initialEvent?.repeatCount ?? 1;
  }

  int get _minutes => (_timeMs / 60000).floor();

  void _setMinutes(int minutes) {
    setState(() {
      _timeMs = minutes * 60000;
      _validateTime();
    });
  }

  void _validateTime() {
    final l10n = AppLocalizations.of(context)!;

    if (_timeMs > widget.sessionDurationMs) {
      _errorMessage = l10n.msg_time_exceeds_duration;
      return;
    }

    // Check if another event exists at the same minute
    final currentMinute = _minutes;
    for (final event in widget.existingEvents) {
      // Skip the event being edited
      if (widget.initialEvent != null && event.timeMs == widget.initialEvent!.timeMs) {
        continue;
      }

      final eventMinute = (event.timeMs / 60000).floor();
      if (eventMinute == currentMinute) {
        _errorMessage = l10n.msg_minute_already_used;
        return;
      }
    }

    _errorMessage = null;
  }

  void _save() {
    final l10n = AppLocalizations.of(context)!;

    if (_timeMs > widget.sessionDurationMs) {
      setState(() {
        _errorMessage = l10n.msg_time_exceeds_duration;
      });
      return;
    }

    // Check if another event exists at the same minute
    final currentMinute = _minutes;
    for (final event in widget.existingEvents) {
      if (widget.initialEvent != null && event.timeMs == widget.initialEvent!.timeMs) {
        continue;
      }

      final eventMinute = (event.timeMs / 60000).floor();
      if (eventMinute == currentMinute) {
        setState(() {
          _errorMessage = l10n.msg_minute_already_used;
        });
        return;
      }
    }

    final event = SoundEvent(
      timeMs: _timeMs,
      soundType: _soundType,
      volume: _volume,
      repeatCount: _repeatCount,
    );
    widget.onSave(event);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final appStyle = widget.theme.currentAppStyle;
    final isEditing = widget.initialEvent != null;
    final maxMinutes = (widget.sessionDurationMs / 60000).floor();

    return AlertDialog(
      backgroundColor: appStyle.formBackground,
      title: Text(
        isEditing ? l10n.lb_edit_event : l10n.lb_add_sound_event,
        style: TextStyle(color: appStyle.formText),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time picker
            Text(
              l10n.lb_event_time,
              style: TextStyle(
                color: appStyle.formText,
                fontSize: kFormFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            // Minutes picker
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: appStyle.formText.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.remove, color: appStyle.formText),
                    onPressed: _minutes > 0
                        ? () => _setMinutes(_minutes - 1)
                        : null,
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '$_minutes ${l10n.lb_minute_short}',
                      style: TextStyle(
                        color: appStyle.formText,
                        fontSize: kFormFontSize + 4,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add, color: appStyle.formText),
                    onPressed: _minutes < maxMinutes
                        ? () => _setMinutes(_minutes + 1)
                        : null,
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: kFormFontSize - 2,
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Sound type selector
            Text(
              l10n.lb_event_sound_type,
              style: TextStyle(
                color: appStyle.formText,
                fontSize: kFormFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: SoundType.values.map((type) {
                final isSelected = type == _soundType;
                return ChoiceChip(
                  label: Text(_getSoundTypeLabel(type, l10n)),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _soundType = type);
                    }
                  },
                  selectedColor: Colors.lightGreenAccent,
                  backgroundColor: appStyle.formBackground,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.black : appStyle.formText,
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Repeat count selector
            Text(
              l10n.lb_event_repeat_count,
              style: TextStyle(
                color: appStyle.formText,
                fontSize: kFormFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [1, 2, 3, 4].map((count) {
                final isSelected = count == _repeatCount;
                return ChoiceChip(
                  label: Text('${count}x'),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _repeatCount = count);
                    }
                  },
                  selectedColor: Colors.lightGreenAccent,
                  backgroundColor: appStyle.formBackground,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.black : appStyle.formText,
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Volume slider
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${l10n.lb_event_volume} (${(_volume * 100).round()}%)',
                    style: TextStyle(
                      color: appStyle.formText,
                      fontSize: kFormFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.play_arrow, color: appStyle.formText),
                  onPressed: widget.onPreviewSound != null
                      ? () => widget.onPreviewSound!(_soundType.name, _volume)
                      : null,
                  tooltip: 'Preview sound',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '0%',
                  style: TextStyle(
                    color: appStyle.formText.withOpacity(0.7),
                    fontSize: kFormFontSize - 2,
                  ),
                ),
                Expanded(
                  child: IncrementalSlider(
                    min: 0.0,
                    max: 1.0,
                    step: 0.05,
                    value: _volume,
                    onChanged: (val) => setState(() => _volume = val),
                  ),
                ),
                Text(
                  '100%',
                  style: TextStyle(
                    color: appStyle.formText.withOpacity(0.7),
                    fontSize: kFormFontSize - 2,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            MaterialLocalizations.of(context).cancelButtonLabel,
            style: TextStyle(color: appStyle.formText),
          ),
        ),
        ElevatedButton(
          onPressed: _errorMessage == null ? _save : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.lightGreenAccent,
          ),
          child: Text(
            MaterialLocalizations.of(context).okButtonLabel,
            style: const TextStyle(color: Colors.black),
          ),
        ),
      ],
    );
  }

  String _getSoundTypeLabel(SoundType type, AppLocalizations l10n) {
    switch (type) {
      case SoundType.session:
        return l10n.lb_sound_session;
      case SoundType.round:
        return l10n.lb_sound_round;
      case SoundType.minor:
        return l10n.lb_sound_minor;
    }
  }
}
