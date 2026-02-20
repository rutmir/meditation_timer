import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'entities/app_settings.dart';
import 'service/settings_service.dart';
import 'service/system_channel_service.dart';
import 'views/common/constants.dart';

class BaseLogic {
  String snackInfoMessage = '';

  final String Function(String) l10n;
  final AppSettings _appSettings;
  final SettingsService _settings;
  final SystemChannelService _system;
  final Function() trigger;

  bool _dontDisturbEnabled = false;

  BaseLogic({
    required this.l10n,
    required SystemChannelService system,
    required AppSettings appSettings,
    required SettingsService settings,
    required this.trigger,
  }) : _system = system,
       _appSettings = appSettings,
       _settings = settings;

  static Future<BaseLogic> buildBaseLogic(
    String Function(String) l10n,
    SystemChannelService system,
    SettingsService settings,
    Function() trigger,
  ) async {
    final appSettings = await settings.getAppSettings();

    return BaseLogic(
      l10n: l10n,
      system: system,
      appSettings: appSettings,
      settings: settings,
      trigger: trigger,
    );
  }

  void setInterruptionFilter(bool muteAll) async {
    if (kIsWeb || !_appSettings.useSilenceMode) return;

    if (muteAll) {
      final isGranted = await Permission.accessNotificationPolicy.isGranted;
      if (!isGranted) return;

      _dontDisturbEnabled = true;
      await _system.setSilentMode();
    } else {
      if (!_dontDisturbEnabled) return;
      _dontDisturbEnabled = false;
      await _system.resumeSilentMode();
    }
  }

  bool _shouldOpenAppSettings = false;

  bool get shouldOpenAppSettings => _shouldOpenAppSettings;

  bool popShouldOpenAppSettings() {
    if (!_shouldOpenAppSettings) return false;
    _shouldOpenAppSettings = false;
    return true;
  }

  Future<bool> needUserPermission() async {
    if (kIsWeb || !_appSettings.useSilenceMode) return false;
    if (_appSettings.silenceModePermissionDismissed) return false;

    return !await Permission.accessNotificationPolicy.isGranted;
  }

  void dismissPermissionDialog() {
    _appSettings.silenceModePermissionDismissed = true;
    _settings.writeAppSettingsPermissionDismissed(true);
    appSettingsUseSilenceMode = false;
  }

  void verifyPermission() async {
    if (kIsWeb || !_appSettings.useSilenceMode) return;

    final isGranted = await Permission.accessNotificationPolicy.isGranted;
    if (isGranted) return;

    final permission = Permission.accessNotificationPolicy
        .onDeniedCallback(() {
          appSettingsUseSilenceMode = false;
          snackInfoMessage = l10n(permissionDeniedMsg);
          trigger();
        })
        .onPermanentlyDeniedCallback(() {
          appSettingsUseSilenceMode = false;
          _shouldOpenAppSettings = true;
          snackInfoMessage = l10n(permissionPermanentlyDeniedMsg);
          trigger();
        });

    await permission.request();
  }

  AppSettings get appSettings => _appSettings;
  SettingsService get settings => _settings;

  Future<void> reloadAppSettings() async {
    final newSettings = await _settings.getAppSettings();
    _appSettings.useSilenceMode = newSettings.useSilenceMode;
    _appSettings.silenceModePermissionDismissed =
        newSettings.silenceModePermissionDismissed;
  }

  set appSettingsUseSilenceMode(bool val) {
    _appSettings.useSilenceMode = val;
    _settings.writeAppSettingsUseSilenceMode(_appSettings.useSilenceMode);

    trigger();
  }

  void enableSilenceModeWithPermission() async {
    _appSettings.useSilenceMode = true;
    _settings.writeAppSettingsUseSilenceMode(true);

    // Reset dismissed flag since user is explicitly opting in
    _appSettings.silenceModePermissionDismissed = false;
    _settings.writeAppSettingsPermissionDismissed(false);

    trigger();

    if (kIsWeb) return;

    final isGranted = await Permission.accessNotificationPolicy.isGranted;
    if (isGranted) return;

    final permission = Permission.accessNotificationPolicy
        .onDeniedCallback(() {
          appSettingsUseSilenceMode = false;
          snackInfoMessage = l10n(permissionDeniedMsg);
          trigger();
        })
        .onPermanentlyDeniedCallback(() {
          appSettingsUseSilenceMode = false;
          _shouldOpenAppSettings = true;
          snackInfoMessage = l10n(permissionPermanentlyDeniedMsg);
          trigger();
        });

    await permission.request();
  }

  String popSnackInfoMessage() {
    if (snackInfoMessage.isEmpty) {
      return '';
    }

    final out = snackInfoMessage;
    snackInfoMessage = '';

    return out;
  }

  void dispose() {
    if (_dontDisturbEnabled) {
      _dontDisturbEnabled = false;
      _system.resumeSilentMode();
    }
  }
}
