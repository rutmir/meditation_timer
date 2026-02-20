import 'package:flutter/material.dart';
import '../../entities/custom_schedule.dart';
import '../../entities/sound_event.dart';
import '../../infrastructure/l10n/generated/app_localizations.dart';
import '../../infrastructure/services/schedule_storage_service.dart';
import '../../service/locale_service.dart';
import '../../service/theme_service.dart';
import '../common/constants.dart';
import 'schedule_list_widget.dart';
import 'sound_event_editor.dart';

/// Widget for displaying and managing a custom sound schedule.
/// Shows list of events with add/edit/delete functionality.
class AdvancedScheduleWidget extends StatefulWidget {
  final ThemeService theme;
  final int sessionDurationMinutes;
  final List<SoundEvent> events;
  final Function(List<SoundEvent>) onEventsChanged;
  final void Function(String soundType, double volume) onPreviewSound;
  final ScheduleStorageService? storageService;
  final LocaleService locale;

  const AdvancedScheduleWidget({
    super.key,
    required this.theme,
    required this.sessionDurationMinutes,
    required this.events,
    required this.onEventsChanged,
    required this.onPreviewSound,
    required this.locale,
    this.storageService,
  });

  @override
  State<AdvancedScheduleWidget> createState() => _AdvancedScheduleWidgetState();
}

class _AdvancedScheduleWidgetState extends State<AdvancedScheduleWidget> {
  late List<SoundEvent> _events;

  @override
  void initState() {
    super.initState();
    _events = List<SoundEvent>.from(widget.events);
  }

  @override
  void didUpdateWidget(AdvancedScheduleWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.events != widget.events) {
      _events = List<SoundEvent>.from(widget.events);
    }
  }

  int get _sessionDurationMs => widget.sessionDurationMinutes * 60 * 1000;

  void _addEvent() async {
    final event = await _showEventEditor(null);
    if (event != null) {
      setState(() {
        _events.add(event);
        _events.sort((a, b) => a.timeMs.compareTo(b.timeMs));
      });
      widget.onEventsChanged(_events);
    }
  }

  void _editEvent(int index) async {
    final event = await _showEventEditor(_events[index]);
    if (event != null) {
      setState(() {
        _events[index] = event;
        _events.sort((a, b) => a.timeMs.compareTo(b.timeMs));
      });
      widget.onEventsChanged(_events);
    }
  }

  void _deleteEvent(int index) {
    setState(() {
      _events.removeAt(index);
    });
    widget.onEventsChanged(_events);
  }

  Future<SoundEvent?> _showEventEditor(SoundEvent? initialEvent) async {
    SoundEvent? result;

    await showDialog(
      context: context,
      builder:
          (context) => SoundEventEditor(
            theme: widget.theme,
            sessionDurationMs: _sessionDurationMs,
            initialEvent: initialEvent,
            existingEvents: _events,
            onSave: (event) {
              result = event;
              Navigator.of(context).pop();
            },
            onPreviewSound: (soundType, volume) {
              widget.onPreviewSound(soundType, volume);
            },
          ),
    );

    return result;
  }

  Future<void> _saveSchedule() async {
    if (widget.storageService == null) return;

    final l10n = AppLocalizations.of(context)!;
    final appStyle = widget.theme.currentAppStyle;
    final controller = TextEditingController();

    final name = await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: appStyle.formBackground,
            title: Text(
              l10n.lb_save_schedule,
              style: TextStyle(color: appStyle.formText),
            ),
            content: TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                labelText: l10n.lb_schedule_name,
                labelStyle: TextStyle(
                  color: appStyle.formText.withOpacity(0.7),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: appStyle.formText.withOpacity(0.3),
                  ),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.lightGreenAccent),
                ),
              ),
              style: TextStyle(color: appStyle.formText),
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
                onPressed: () {
                  final name = controller.text.trim();
                  if (name.isNotEmpty) {
                    Navigator.of(context).pop(name);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightGreenAccent,
                ),
                child: Text(
                  MaterialLocalizations.of(context).okButtonLabel,
                  style: const TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
    );

    if (name != null && name.isNotEmpty) {
      final schedule = CustomSchedule(name: name, events: _events);
      await widget.storageService!.saveSchedule(schedule);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.msg_schedule_saved)));
      }
    }
  }

  Future<void> _loadSchedule() async {
    if (widget.storageService == null) return;

    final l10n = AppLocalizations.of(context)!;

    await ScheduleListWidget.show(
      context: context,
      theme: widget.theme,
      storageService: widget.storageService!,
      sessionDurationMs: _sessionDurationMs,
      onScheduleSelected: (schedule, filteredCount) {
        final validEvents = schedule.getValidEventsForDuration(
          _sessionDurationMs,
        );
        setState(() {
          _events = validEvents;
        });
        widget.onEventsChanged(_events);

        if (filteredCount > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.msg_events_filtered(filteredCount))),
          );
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.msg_schedule_loaded)));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final appStyle = widget.theme.currentAppStyle;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with title and add button
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.lb_advanced_schedule,
                    style: TextStyle(
                      color: appStyle.formText,
                      fontSize: kFormFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.lb_advanced_schedule_desc,
                    style: TextStyle(
                      color: appStyle.formText.withOpacity(0.7),
                      fontSize: kFormFontSize - 4,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.add_circle,
                color: Colors.lightGreenAccent,
                size: 32,
              ),
              onPressed: _addEvent,
              tooltip: l10n.lb_add_sound_event,
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Events list or empty state
        if (_events.isEmpty)
          _buildEmptyState(l10n, appStyle)
        else
          _buildEventsList(l10n, appStyle),

        // Save/Load buttons
        if (widget.storageService != null) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _loadSchedule,
                  icon: const Icon(Icons.folder_open),
                  label: Text(
                    l10n.lb_load_schedule,
                    textScaler:
                        widget.locale.isEn ? null : TextScaler.linear(0.8),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: appStyle.formText,
                    side: BorderSide(color: appStyle.formText.withOpacity(0.3)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _events.isEmpty ? null : _saveSchedule,
                  icon: const Icon(Icons.save),
                  label: Text(
                    l10n.lb_save_schedule,
                    textScaler:
                        widget.locale.isEn ? null : TextScaler.linear(0.8),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightGreenAccent,
                    foregroundColor: Colors.black,
                    disabledBackgroundColor: Colors.grey.withOpacity(0.3),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n, dynamic appStyle) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: appStyle.formBackground.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: appStyle.formText.withOpacity(0.2),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.music_note_outlined,
            size: 48,
            color: appStyle.formText.withOpacity(0.4),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.lb_no_events_scheduled,
            style: TextStyle(
              color: appStyle.formText,
              fontSize: kFormFontSize,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.lb_no_events_scheduled_desc,
            style: TextStyle(
              color: appStyle.formText.withOpacity(0.6),
              fontSize: kFormFontSize - 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsList(AppLocalizations l10n, dynamic appStyle) {
    return Column(
      children: [
        // Schedule preview header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: appStyle.formBackground.withOpacity(0.3),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
          child: Text(
            l10n.lb_schedule_preview,
            style: TextStyle(
              color: appStyle.formText.withOpacity(0.7),
              fontSize: kFormFontSize - 2,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        // Events list
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: appStyle.formText.withOpacity(0.2)),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(8),
            ),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _events.length,
            separatorBuilder:
                (_, __) => Divider(
                  height: 1,
                  color: appStyle.formText.withOpacity(0.1),
                ),
            itemBuilder:
                (context, index) => _buildEventTile(index, l10n, appStyle),
          ),
        ),
      ],
    );
  }

  Widget _buildEventTile(int index, AppLocalizations l10n, dynamic appStyle) {
    final event = _events[index];
    final iconData = _getSoundTypeIcon(event.soundType);
    final typeName = _getSoundTypeName(event.soundType, l10n);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      leading: Container(
        width: 60,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.lightGreenAccent.withOpacity(0.2),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          '${event.minutes} ${l10n.lb_minute_short}',
          style: TextStyle(
            color: appStyle.formText,
            fontSize: kFormFontSize,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      title: Row(
        children: [
          Icon(iconData, size: 20, color: appStyle.formText),
          const SizedBox(width: 8),
          Text(
            typeName,
            style: TextStyle(color: appStyle.formText, fontSize: kFormFontSize),
          ),
        ],
      ),
      subtitle: Text(
        event.repeatCount > 1
            ? '${(event.volume * 100).round()}% • ${event.repeatCount}x'
            : '${(event.volume * 100).round()}%',
        style: TextStyle(
          color: appStyle.formText.withOpacity(0.6),
          fontSize: kFormFontSize - 2,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.edit, color: appStyle.formText.withOpacity(0.7)),
            onPressed: () => _editEvent(index),
            tooltip: l10n.lb_edit_event,
            iconSize: 20,
          ),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.redAccent.withOpacity(0.7)),
            onPressed: () => _deleteEvent(index),
            tooltip: l10n.lb_delete_event,
            iconSize: 20,
          ),
        ],
      ),
    );
  }

  IconData _getSoundTypeIcon(SoundType type) {
    switch (type) {
      case SoundType.session:
        return Icons.notifications_active;
      case SoundType.round:
        return Icons.notifications;
      case SoundType.minor:
        return Icons.notifications_none;
    }
  }

  String _getSoundTypeName(SoundType type, AppLocalizations l10n) {
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
