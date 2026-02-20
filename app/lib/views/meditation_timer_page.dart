import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:keep_screen_on/keep_screen_on.dart';
import 'package:permission_handler/permission_handler.dart';
import '../entities/timer_page_mode.dart';
import '../infrastructure/l10n/generated/app_localizations.dart';
import '../infrastructure/router/hero_dialog_route.dart';
import '../timer_logic.dart';
import '../service/ai_meditation_service.dart';
import '../service/locale_service.dart';
import '../service/settings_service.dart';
import '../service/system_channel_service.dart';
import '../service/theme_service.dart';
import '../views/ai_meditation_page.dart';
import '../utils.dart';
import 'common/ai_button.dart';
import 'common/ask_permission_dialog.dart';
import 'common/constants.dart';
import 'common/gear_button.dart';
import 'common/round_back_button.dart';
import 'mixin_page.dart';
import 'timer_settings_view.dart';

class MeditationTimerPage extends StatefulWidget {
  const MeditationTimerPage({super.key});

  @override
  State<MeditationTimerPage> createState() => _MeditationTimerPageState();
}

class _MeditationTimerPageState extends State<MeditationTimerPage>
    with MixinPage {
  TimerPageMode viewMode = TimerPageMode.beforeInit;

  late ThemeService themeService;
  late TimerLogic logic;
  late TimerSettingsView settingsView;
  late RoundBackButton rbb;

  _MeditationTimerPageState() {
    themeService = GetIt.I<ThemeService>();
    logic = TimerLogic(
      settings: GetIt.I<SettingsService>(),
      theme: GetIt.I<ThemeService>(),
      system: GetIt.I<SystemChannelService>(),
      aiService: GetIt.I<AiMeditationService>(),
      l10n: getLocalizedMessage,
      trigger: _stateTrigger,
      afterInitCb: _onLogicInitialized,
    );

    settingsView = TimerSettingsView(
      theme: GetIt.I<ThemeService>(),
      locale: GetIt.I<LocaleService>(),
      logic: logic,
      onClose:
          () => _setMode(
            logic.isRunning ? TimerPageMode.inProgress : TimerPageMode.main,
          ),
    );
  }

  double get _kRadius =>
      150.0 / 392.7 * MediaQuery.of(context).size.shortestSide;

  void _onLogicInitialized() {
    if (logic.isInitialized) {
      _setMode(TimerPageMode.main);
      _showPermissionDialogIfNeeded();
    }
  }

  void _showPermissionDialogIfNeeded() {
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

  void _setMode(TimerPageMode mode) {
    setState(() {
      viewMode = mode;
    });
  }

  void _stateTrigger() {
    setState(() {});
  }

  void _onStart() {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      logic.startTimer();
    } else {
      KeepScreenOn.turnOn().then((val) => logic.startTimer());
    }

    _setMode(TimerPageMode.inProgress);
  }

  void _onStop() {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      logic.stopTimer();
    } else {
      KeepScreenOn.turnOff().then((val) => logic.stopTimer());
    }

    _setMode(TimerPageMode.main);
  }

  String getLocalizedMessage(String key) {
    if (mounted) {
      final l10n = AppLocalizations.of(context)!;

      switch (key) {
        case permissionDeniedMsg:
          return l10n.permission_denied_msg;
        case permissionPermanentlyDeniedMsg:
          return l10n.permission_permanently_denied_msg;
      }
    }

    return '';
  }

  Widget runningDisplay() {
    // final colorScheme = Theme.of(context).colorScheme;
    final appStyle = themeService.currentAppStyle;

    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        SizedBox(
          width: _kRadius * 2,
          height: _kRadius * 2,
          child: CircularProgressIndicator(
            backgroundColor: appStyle.inversePrimary,
            color: appStyle.primary,
            strokeWidth: _kRadius / 10,
            value: logic.currentSessionRemainDelta,
          ),
        ),
        if (logic.pranayamaSession.enabled)
          SizedBox(
            width: _kRadius * 2 - (_kRadius / 10) * 3,
            height: _kRadius * 2 - (_kRadius / 10) * 3,
            child: CircularProgressIndicator(
              backgroundColor: appStyle.inverseSecondary,
              color: appStyle.primary,
              strokeWidth: _kRadius / 10,
              value: logic.pranayamaSession.remainDelta,
            ),
          ),
        Text(
          logic.displayTime,
          style: TextStyle(
            fontSize: 50.0,
            color:
                !logic.pranayamaSession.isCompleted
                    ? appStyle.inverseSecondary
                    : appStyle.inversePrimary,
          ),
        ),
      ],
    );
  }

  Color get _backgroundColor => switch (viewMode) {
    TimerPageMode.beforeInit ||
    TimerPageMode.main ||
    TimerPageMode.inProgress => themeService.currentAppStyle.primary,
    TimerPageMode.pranayama ||
    TimerPageMode.meditation ||
    TimerPageMode.settings =>
      themeService
          .currentAppStyle
          .primary, //themeService.currentAppStyle.formBackground,
  };

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

    const secondShift = 65.0;
    final appStyle = themeService.currentAppStyle;
    final safeArea = MediaQuery.of(context).padding;
    // print('dimention ${MediaQuery.of(context).size}');

    final lbTextStyle = TextStyle(
      fontSize: kTitleFontSize,
      color: appStyle.inversePrimary,
    );

    final lbSize =
        viewMode == TimerPageMode.main
            ? textSize(l10n.action_start, lbTextStyle)
            : null;

    // print('lbSize $lbSize');

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: switch (viewMode) {
        TimerPageMode.beforeInit => Center(
          child: CircularProgressIndicator(color: appStyle.inversePrimary),
        ),
        TimerPageMode.main || TimerPageMode.inProgress => PopScope(
          canPop: false,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Container(
              //   decoration: BoxDecoration(
              //     gradient: LinearGradient(
              //       begin: Alignment.topCenter,
              //       end: Alignment.bottomCenter,
              //       colors: [Colors.deepPurpleAccent, Colors.deepPurple],
              //       stops: [0.0, 1],
              //     ),
              //   ),
              // ),
              Positioned(
                left: 0,
                top: safeArea.top + kTopShift / 2,
                child: GestureDetector(
                  onTap: () => _setMode(TimerPageMode.pranayama),
                  child: Chip(
                    backgroundColor: appStyle.inverseSecondary,
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(kTitleFontSize),
                        bottomRight: Radius.circular(kTitleFontSize),
                      ),
                    ),
                    avatar: Icon(
                      Icons.air,
                      size: 30.0,
                      color: appStyle.secondary,
                    ),
                    label: Row(
                      spacing: 10,
                      children: [
                        Text(
                          l10n.lb_pranayama /* Prāṇāyāma Pranayama */,
                          style: TextStyle(
                            fontSize: kTitleFontSize,
                            color: appStyle.secondary,
                          ),
                        ),
                        logic.pranayamaSession.enabled
                            ? Text(
                              '${logic.pranayamaSession.duration} ${l10n.lb_minute_short}',
                              style: TextStyle(
                                fontSize: kTitleFontSize,
                                color: appStyle.secondary,
                              ),
                            )
                            : Icon(
                              Icons.block,
                              color: appStyle.iconDisabled,
                              size: kTitleFontSize * 1.5,
                            ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: safeArea.top + kTopShift / 2 + secondShift,
                child: GestureDetector(
                  onTap: () => _setMode(TimerPageMode.meditation),
                  child: Chip(
                    backgroundColor: appStyle.inversePrimary,
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(kTitleFontSize),
                        bottomRight: Radius.circular(kTitleFontSize),
                      ),
                    ),
                    avatar: Icon(
                      Icons.access_time_outlined,
                      size: 30.0,
                      color: appStyle.primary,
                    ),
                    label: Text(
                      '${l10n.lb_meditation} ${logic.unguidedMeditationSession.sessionDuration} ${l10n.lb_minute_short}',
                      style: TextStyle(
                        fontSize: kTitleFontSize,
                        color: appStyle.primary,
                      ),
                    ),
                  ),
                ),
              ),
              if (viewMode == TimerPageMode.main ||
                  viewMode == TimerPageMode.inProgress)
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: safeArea.top + kTopShift / 2,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          if (viewMode == TimerPageMode.inProgress)
                            runningDisplay(),
                          if (viewMode == TimerPageMode.main)
                            ElevatedButton(
                              onPressed: _onStart,
                              style: ElevatedButton.styleFrom(
                                shape: CircleBorder(
                                  side: BorderSide(
                                    width: 0.5,
                                    color: appStyle.inversePrimary,
                                  ),
                                ),
                                backgroundColor: appStyle.primary,
                              ),
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(
                                  _kRadius - lbSize!.width / 2.0,
                                  _kRadius - lbSize.height / 2.0,
                                  _kRadius - lbSize.width / 2.0,
                                  _kRadius - lbSize.height / 2.0,
                                ),
                                child: Text(
                                  l10n.action_start,
                                  style: lbTextStyle,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (viewMode == TimerPageMode.main)
                Align(
                  alignment: Alignment.bottomLeft,
                  // child: ShowTipButton(themeService: themeService),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.end, // Aligns content to the bottom
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start, // Aligns content to the left
                      children: [
                        if (logic.isAiServiceOnline)
                          AiButton(
                            themeService: themeService,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => const AiMeditationPage(),
                                ),
                              );
                            },
                          ),
                        GearButton(
                          themeService: themeService,
                          onTap: () {
                            _setMode(TimerPageMode.settings);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              // if (viewMode == TimerPageMode.main && logic.isAiServiceOnline)
              //   Align(
              //     alignment: Alignment.bottomLeft,
              //     // child: ShowTipButton(themeService: themeService),
              //     child: GearButton(
              //       themeService: themeService,
              //       onTap: () {
              //         print('I am here');
              //       },
              //     ),
              //   ),
            ],
          ),
        ),
        TimerPageMode.pranayama ||
        TimerPageMode.meditation ||
        TimerPageMode.settings => settingsView.getView(
          context,
          isRunning: logic.isRunning,
          safeArea: safeArea,
          expandedSection: switch (viewMode) {
            TimerPageMode.pranayama => SettingsSection.pranayama,
            TimerPageMode.meditation => SettingsSection.meditation,
            TimerPageMode.settings => SettingsSection.appSettings,
            _ => SettingsSection.meditation,
          },
        ), // settingsDisplay(logic.isRunning),
      },
      floatingActionButton:
          viewMode == TimerPageMode.inProgress
              ? FloatingActionButton.extended(
                onPressed: _onStop,
                backgroundColor: appStyle.inversePrimary,
                tooltip: l10n.action_stop_tooltip,
                label: Text(l10n.action_stop),
              )
              : null,
    );
  }

  @override
  void dispose() {
    logic.dispose();
    super.dispose();
  }
}
