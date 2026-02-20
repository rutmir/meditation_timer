import 'dart:convert';

import '../../entities/custom_schedule.dart';
import '../../service/storage_service.dart';

/// Service for saving, loading, and deleting custom meditation schedules.
class ScheduleStorageService {
  static const _savedSchedulesKey = 'saved_schedules';

  final StorageService _storage;

  ScheduleStorageService({required StorageService storage}) : _storage = storage;

  /// Load all saved schedules
  Future<List<CustomSchedule>> loadSavedSchedules() async {
    final rawData = await _storage.read(key: _savedSchedulesKey);
    if (rawData == null || rawData.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> jsonList = jsonDecode(rawData) as List<dynamic>;
      return jsonList
          .map((e) => CustomSchedule.fromJson(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.modifiedAt.compareTo(a.modifiedAt)); // Most recent first
    } catch (e) {
      return [];
    }
  }

  /// Save a new schedule or update an existing one
  Future<void> saveSchedule(CustomSchedule schedule) async {
    final schedules = await loadSavedSchedules();

    // Find existing schedule with same ID
    final existingIndex = schedules.indexWhere((s) => s.id == schedule.id);
    if (existingIndex >= 0) {
      schedules[existingIndex] = schedule;
    } else {
      schedules.add(schedule);
    }

    await _writeSchedules(schedules);
  }

  /// Delete a schedule by ID
  Future<void> deleteSchedule(String id) async {
    final schedules = await loadSavedSchedules();
    schedules.removeWhere((s) => s.id == id);
    await _writeSchedules(schedules);
  }

  /// Get a schedule by ID
  Future<CustomSchedule?> getScheduleById(String id) async {
    final schedules = await loadSavedSchedules();
    try {
      return schedules.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Check if a schedule name already exists
  Future<bool> scheduleNameExists(String name, {String? excludeId}) async {
    final schedules = await loadSavedSchedules();
    return schedules.any((s) =>
        s.name.toLowerCase() == name.toLowerCase() &&
        (excludeId == null || s.id != excludeId));
  }

  /// Write schedules list to storage
  Future<void> _writeSchedules(List<CustomSchedule> schedules) async {
    final jsonString = jsonEncode(schedules.map((s) => s.toJson()).toList());
    await _storage.write(key: _savedSchedulesKey, value: jsonString);
  }
}
