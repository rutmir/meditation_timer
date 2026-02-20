import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart' show Logger;
import '../../entities/interruption_filter_enum.dart';
import '../../entities/platform_method_channel.dart';
import '../../entities/ringer_mode_enum.dart';
import '../../service/system_channel_service.dart';

class AppSystemChannelService extends SystemChannelService
    implements Disposable {
  final logger = Logger();
  final PlatformMethodChannel _notificationServiceChannel =
      PlatformMethodChannel(
        channel: 'pro.optima.meditimer/notification_service',
      );
  final PlatformMethodChannel _audioServiceChannel = PlatformMethodChannel(
    channel: 'pro.optima.meditimer/audio_service',
  );

  InterruptionFilterEnum? _originalInterruptionFilter;
  RingerModeEnum? _originalRingerMode;

  Future<void> _fetchOriginalInterruptionFilter() async {
    if (!_notificationServiceChannel.isSupported) return;

    final result = await _notificationServiceChannel.invokeMethod<int>(
      'INTERRUPTION_FILTER_STATUS',
    );
    if (result == null) return;

    _originalInterruptionFilter = InterruptionFilterEnum.values[result];
  }

  Future<void> _setNotificationSilentMode() async {
    if (!_notificationServiceChannel.isSupported) return;

    final result = await _notificationServiceChannel.invokeMethod<int>(
      'INTERRUPTION_FILTER_STATUS',
    );
    if (result == null) return;

    final currentFilter = InterruptionFilterEnum.values[result];

    if (currentFilter == InterruptionFilterEnum.filterAlarms) {
      return;
    }

    try {
      await _notificationServiceChannel.invokeMethod<bool>(
        'INTERRUPTION_FILTER_ALARMS',
      );
    } catch (e) {
      logger.d('---> $e');
    }
  }

  // Future<bool> _isPoplicyAccessGranted() async {
  //   if (!_notificationServiceChannel.isSupported) return false;
  //
  //   final result = await _notificationServiceChannel.invokeMethod<bool>(
  //     'IS_POLICY_ACCESS_GRANTED',
  //   );
  //   if (result == null) return false;
  //
  //   return result;
  // }

  // Future<void> _askPoplicyAccessGranted() async {
  //   if (!_notificationServiceChannel.isSupported) return;
  //
  //   await _notificationServiceChannel.invokeMethod<bool>(
  //     'ASK_POLICY_ACCESS_GRANTED',
  //   );
  // }

  Future<void> _fetchAudioSilentMode() async {
    if (!_audioServiceChannel.isSupported) return;

    final result = await _audioServiceChannel.invokeMethod<int>('RINGER_MODE');
    if (result == null) return;

    _originalRingerMode = RingerModeEnum.values[result];
  }

  Future<void> _setAudioSilentMode() async {
    if (!_audioServiceChannel.isSupported) return;

    final result = await _audioServiceChannel.invokeMethod<int>('RINGER_MODE');
    if (result == null) return;

    final currentMode = RingerModeEnum.values[result];

    if (currentMode == RingerModeEnum.modeSilent) {
      return;
    }

    try {
      await _audioServiceChannel.invokeMethod<bool>('RINGER_MODE_SILENT');
    } catch (e) {
      logger.d('---> $e');
    }
  }

  Future<void> _resumeNotificationSilentMode() async {
    if (!_notificationServiceChannel.isSupported ||
        _originalInterruptionFilter == null ||
        _originalInterruptionFilter == InterruptionFilterEnum.filterUnknown) {
      return;
    }

    try {
      await _notificationServiceChannel.invokeMethod<bool>(
        InterruptionFilterEnum.stringValue(_originalInterruptionFilter!),
      );
    } catch (e) {
      logger.d('---> $e');
    }
  }

  Future<void> _resumeAudioSilentMode() async {
    if (!_audioServiceChannel.isSupported || _originalRingerMode == null) {
      return;
    }

    try {
      await _audioServiceChannel.invokeMethod<bool>(
        RingerModeEnum.stringValue(_originalRingerMode!),
      );
    } catch (e) {
      logger.d('---> $e');
    }
  }

  @override
  Future<void> setSilentMode() async {
    await _fetchOriginalInterruptionFilter();
    await _fetchAudioSilentMode();
    await _setNotificationSilentMode();
    await _setAudioSilentMode();
  }

  @override
  Future<void> resumeSilentMode() async {
    await _resumeNotificationSilentMode();
    await _resumeAudioSilentMode();
  }

  // @override
  // Future<bool> isPoplicyAccessGranted() async {
  //   return await _isPoplicyAccessGranted();
  // }

  // @override
  // Future<void> askPoplicyAccessGranted() async {
  //   await _askPoplicyAccessGranted();
  // }

  @override
  FutureOr onDispose() async {
    await resumeSilentMode();
  }
}
