import 'package:flutter/material.dart';
import '../../entities/custom_schedule.dart';
import '../../infrastructure/l10n/generated/app_localizations.dart';
import '../../infrastructure/services/schedule_storage_service.dart';
import '../../service/theme_service.dart';
import '../common/constants.dart';

/// Dialog for displaying and selecting saved schedules.
class ScheduleListWidget extends StatefulWidget {
  final ThemeService theme;
  final ScheduleStorageService storageService;
  final int sessionDurationMs;
  final Function(CustomSchedule schedule, int filteredCount) onScheduleSelected;

  const ScheduleListWidget({
    super.key,
    required this.theme,
    required this.storageService,
    required this.sessionDurationMs,
    required this.onScheduleSelected,
  });

  @override
  State<ScheduleListWidget> createState() => _ScheduleListWidgetState();

  /// Show the schedule list dialog
  static Future<void> show({
    required BuildContext context,
    required ThemeService theme,
    required ScheduleStorageService storageService,
    required int sessionDurationMs,
    required Function(CustomSchedule schedule, int filteredCount) onScheduleSelected,
  }) async {
    await showDialog(
      context: context,
      builder: (context) => ScheduleListWidget(
        theme: theme,
        storageService: storageService,
        sessionDurationMs: sessionDurationMs,
        onScheduleSelected: onScheduleSelected,
      ),
    );
  }
}

class _ScheduleListWidgetState extends State<ScheduleListWidget> {
  List<CustomSchedule> _schedules = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    final schedules = await widget.storageService.loadSavedSchedules();
    setState(() {
      _schedules = schedules;
      _isLoading = false;
    });
  }

  Future<void> _deleteSchedule(CustomSchedule schedule) async {
    final l10n = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.lb_delete_schedule),
        content: Text(l10n.msg_confirm_delete_schedule),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: Text(l10n.lb_delete_event),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await widget.storageService.deleteSchedule(schedule.id);
      await _loadSchedules();
    }
  }

  void _selectSchedule(CustomSchedule schedule) {
    final invalidEvents = schedule.getInvalidEventsForDuration(widget.sessionDurationMs);
    widget.onScheduleSelected(schedule, invalidEvents.length);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final appStyle = widget.theme.currentAppStyle;

    return AlertDialog(
      backgroundColor: appStyle.formBackground,
      title: Text(
        l10n.lb_saved_schedules,
        style: TextStyle(color: appStyle.formText),
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _schedules.isEmpty
                ? _buildEmptyState(l10n, appStyle)
                : _buildScheduleList(l10n, appStyle),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            MaterialLocalizations.of(context).closeButtonLabel,
            style: TextStyle(color: appStyle.formText),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n, dynamic appStyle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 64,
            color: appStyle.formText.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.lb_no_saved_schedules,
            style: TextStyle(
              color: appStyle.formText.withValues(alpha: 0.7),
              fontSize: kFormFontSize,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleList(AppLocalizations l10n, dynamic appStyle) {
    return ListView.separated(
      itemCount: _schedules.length,
      separatorBuilder: (_, __) => Divider(
        height: 1,
        color: appStyle.formText.withValues(alpha: 0.1),
      ),
      itemBuilder: (context, index) {
        final schedule = _schedules[index];
        final invalidCount =
            schedule.getInvalidEventsForDuration(widget.sessionDurationMs).length;
        final hasInvalidEvents = invalidCount > 0;

        return ListTile(
          title: Text(
            schedule.name,
            style: TextStyle(
              color: appStyle.formText,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${schedule.events.length} events',
                style: TextStyle(
                  color: appStyle.formText.withValues(alpha: 0.7),
                  fontSize: kFormFontSize - 2,
                ),
              ),
              if (hasInvalidEvents)
                Text(
                  '$invalidCount events exceed duration',
                  style: TextStyle(
                    color: Colors.orangeAccent,
                    fontSize: kFormFontSize - 2,
                  ),
                ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.delete, color: Colors.redAccent.withValues(alpha: 0.7)),
                onPressed: () => _deleteSchedule(schedule),
                tooltip: l10n.lb_delete_schedule,
              ),
              IconButton(
                icon: Icon(Icons.check_circle, color: Colors.lightGreenAccent),
                onPressed: () => _selectSchedule(schedule),
                tooltip: l10n.lb_load_schedule,
              ),
            ],
          ),
          onTap: () => _selectSchedule(schedule),
        );
      },
    );
  }
}
