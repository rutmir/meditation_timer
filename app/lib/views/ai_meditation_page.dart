import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:keep_screen_on/keep_screen_on.dart';
import 'package:permission_handler/permission_handler.dart';

import '../ai_logic.dart';
import '../entities/ai_page_mode.dart';
import '../infrastructure/l10n/generated/app_localizations.dart';
import '../infrastructure/router/hero_dialog_route.dart';
import '../service/ai_meditation_service.dart';
import '../service/settings_service.dart';
import '../service/system_channel_service.dart';
import '../service/theme_service.dart';
import 'ai_meditation_list_view.dart';
import 'ai_meditation_script_view.dart';
import 'ai_meditation_view.dart';
import 'common/ask_permission_dialog.dart';
import 'common/constants.dart';
import 'mixin_page.dart';

class AiMeditationPage extends StatefulWidget {
  const AiMeditationPage({super.key});

  @override
  State<AiMeditationPage> createState() => _AiMeditationPageState();
}

class _AiMeditationPageState extends State<AiMeditationPage> with MixinPage {
  AiPageMode viewMode = AiPageMode.list;

  late ThemeService themeService;
  late AiLogic logic;
  late AiMeditationListView listView;
  late AiMeditationScriptView scriptView;
  late AiMeditationView meditationView;

  String errorMessage = '';

  _AiMeditationPageState() {
    themeService = GetIt.I<ThemeService>();
    logic = AiLogic(
      settings: GetIt.I<SettingsService>(),
      system: GetIt.I<SystemChannelService>(),
      aiService: GetIt.I<AiMeditationService>(),
      theme: GetIt.I<ThemeService>(),
      l10n: getLocalizedMessage,
      trigger: _stateTrigger,
    );

    listView = AiMeditationListView(
      theme: GetIt.I<ThemeService>(),
      logic: logic,
      onRebuild: _stateTrigger,
      onSetPageMode: _setMode,
    );

    scriptView = AiMeditationScriptView(
      theme: GetIt.I<ThemeService>(),
      logic: logic,
      onRebuild: _stateTrigger,
      onSetPageMode: _setMode,
    );

    meditationView = AiMeditationView(
      theme: GetIt.I<ThemeService>(),
      logic: logic,
      onRebuild: _stateTrigger,
      onSetPageMode: _setMode,
    );
  }

  bool _permissionDialogShown = false;

  String getLocalizedMessage(String key) {
    if (mounted) {
      final l10n = AppLocalizations.of(context)!;

      switch (key) {
        case checkForApplicationUpdateMsg:
          return l10n.error_app_version;
        case unknownErrorMsg:
          return l10n.error_unknown;
        case noConnectionErrorMsg:
          return l10n.error_no_internet;
        case permissionDeniedMsg:
          return l10n.permission_denied_msg;
        case permissionPermanentlyDeniedMsg:
          return l10n.permission_permanently_denied_msg;
      }
    }

    return '';
  }

  void _showPermissionDialogIfNeeded() {
    if (_permissionDialogShown || !logic.isBaseLogicInit) return;
    _permissionDialogShown = true;

    logic.needUserPermission().then((needAskUser) {
      if (needAskUser && mounted) {
        Navigator.of(context).push(
          HeroDialogRoute(
            builder: (context) {
              return AskPermissionDialog(
                onReject: () {
                  logic.appSettingsUseSilenceMode = false;
                },
                onAccept: () {
                  logic.verifyPermission();
                },
                onDismiss: () {
                  logic.dismissPermissionDialog();
                },
              );
            },
          ),
        );
      }
    });
  }

  void _stateTrigger() {
    if (logic.isError) {
      errorMessage = logic.popSnackInfoMessage();
      _setMode(AiPageMode.error);
    } else {
      _showPermissionDialogIfNeeded();
      setState(() {});
    }
  }

  void _setMode(AiPageMode mode) {
    setState(() {
      viewMode = mode;
    });
  }

  Color get _backgroundColor => switch (viewMode) {
    AiPageMode.list ||
    AiPageMode.view ||
    AiPageMode.meditation ||
    AiPageMode.error => themeService.currentAppStyle.primary,
    AiPageMode.archive =>
      themeService
          .currentAppStyle
          .primary, //themeService.currentAppStyle.formBackground,
  };

  void _onMeditationStop() {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      logic.stopMeditation();
      // setState(() {});
    } else {
      KeepScreenOn.turnOff().then((val) {
        logic.stopMeditation();
        // setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final openSettings = logic.popShouldOpenAppSettings();
      afterBuild(
        context,
        logic.popSnackInfoMessage,
        action: openSettings
            ? SnackBarAction(
                label: l10n.permission_open_settings,
                onPressed: () => openAppSettings(),
              )
            : null,
      );
    });

    if (!logic.isInitialized) {
      logic.lazyInit(AppLocalizations.of(context)!.localeName);
    }

    final safeArea = MediaQuery.of(context).padding;
    // final appStyle = themeService.currentAppStyle;
    // final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: switch (viewMode) {
        AiPageMode.error => Center(child: Text(errorMessage)),
        AiPageMode.meditation => meditationView.getView(
          context,
          safeArea: safeArea,
        ),
        AiPageMode.archive => const Center(
          child: Text('AI MEDITATION ARCHIVE PAGE'),
        ),
        AiPageMode.list => listView.getView(context, safeArea: safeArea),
        AiPageMode.view => scriptView.getView(context, safeArea: safeArea),
      },
      floatingActionButton:
          viewMode == AiPageMode.meditation
              ? switch (logic.playStatus) {
                PlayStatus.play => FloatingActionButton.extended(
                  onPressed: _onMeditationStop,
                  backgroundColor: themeService.currentAppStyle.inversePrimary,
                  tooltip: l10n.action_stop_tooltip,
                  label: Text(l10n.action_stop),
                ),
                PlayStatus.pause => FloatingActionButton.extended(
                  onPressed: () {
                    logic.continueMeditation();
                    _stateTrigger();
                  },
                  // tooltip: l10n.action_stop_tooltip,
                  label: Text(l10n.action_continue),
                ),
                PlayStatus.stop => null,
              }
              : null,
    );
  }

  @override
  void dispose() {
    logic.dispose();
    super.dispose();
  }
}
