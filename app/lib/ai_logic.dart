import 'dart:async';

import 'package:async/async.dart';
import 'base_logic.dart';
import 'entities/ai_meditation_session.dart';
import 'entities/meditation_info.dart';
import 'entities/meditation_script.dart';
import 'infrastructure/common/transport_error.dart';
import 'player.dart';
import 'service/ai_meditation_service.dart';
import 'service/settings_service.dart';
import 'service/system_channel_service.dart';
import 'service/theme_service.dart';
import 'views/common/constants.dart';

enum PlayStatus { play, pause, stop }

class AiLogic {
  final AiMeditationService aiService;
  final ThemeService theme;
  final _watch = Stopwatch();
  final _player = AudioController();
  AiMeditationSession? _session;
  late BaseLogic _baseLogic;

  bool _isError = false;
  bool _initializationInProgress = false;
  bool _baseLogicInit = false;
  bool _isReady = false;
  PlayStatus _playStatus = PlayStatus.stop;
  String snackInfoMessage = '';
  List<MeditationInfo> _infoList = [];
  MeditationScript? _script;
  // CancelableCompleter<void> _completer = CancelableCompleter(onCancel: () {});
  CancelableOperation<void>? _operation;
  String _displayTime = '';

  AiLogic({
    required SettingsService settings,
    required SystemChannelService system,
    required this.aiService,
    required this.theme,
    required String Function(String) l10n,
    required Function() trigger,
  }) {
    () async {
      _baseLogic = await BaseLogic.buildBaseLogic(
        l10n,
        system,
        settings,
        trigger,
      );
      _baseLogicInit = true;
      _baseLogic.trigger();
    }();
  }

  void lazyInit(String locate) async {
    if (_initializationInProgress || !_baseLogicInit) return;

    _initializationInProgress = true;

    if (aiService.isMeditationInfoListLoaded && aiService.locale.isNotEmpty) {
      _infoList = aiService.meditationInfoList;

      _isReady = true;
      _baseLogic.trigger();

      return;
    }

    await cancelRequest();
    _operation = CancelableOperation.fromFuture(() async {
      aiService.locale = locate;
      final data = await fetchData(aiService.getMeditationInfoList());
      if (data != null) _infoList = data;
    }(), onCancel: () {});
    await _operation!.valueOrCancellation(null);

    _isReady = true;
    if (snackInfoMessage.isNotEmpty) _isError = true;
    if (_operation!.isCompleted) _baseLogic.trigger();
  }

  String get locale => aiService.locale;
  set locale(String val) {
    aiService.locale = locale;

    _baseLogic.trigger();
  }

  bool get isInitialized => _infoList.isNotEmpty || _script != null;
  bool get isError => _isError;
  PlayStatus get playStatus => _playStatus;
  bool get isReady => _isReady;
  MeditationScript? get script => _script;
  List<MeditationInfo> get infoList => _infoList;
  double get sessionRemainDelta => _session?.remainDelta ?? 1.0;
  String get displayTime => _displayTime;
  bool get isBaseLogicInit => _baseLogicInit;

  Future<bool> needUserPermission() => _baseLogic.needUserPermission();
  void verifyPermission() => _baseLogic.verifyPermission();
  void dismissPermissionDialog() => _baseLogic.dismissPermissionDialog();

  set appSettingsUseSilenceMode(bool val) =>
      _baseLogic.appSettingsUseSilenceMode = val;
  bool popShouldOpenAppSettings() => _baseLogic.popShouldOpenAppSettings();

  String popSnackInfoMessage() {
    if (snackInfoMessage.isEmpty) {
      return '';
    }

    final out = snackInfoMessage;
    snackInfoMessage = '';

    return out;
  }

  Future<T?> fetchData<T>(Future<T?> dataFuture) async {
    try {
      return await dataFuture;
    } on NoConnectionError {
      snackInfoMessage = _baseLogic.l10n(noConnectionErrorMsg);
    } catch (e) {
      if (e is BadRequestError ||
          e is ForbiddenError ||
          e is UnauthorizedRequestError ||
          e is NotFoundError ||
          e is UnsupportedMediaTypeError ||
          e is InternalServerError ||
          e is BadDataFormatError) {
        snackInfoMessage = _baseLogic.l10n(checkForApplicationUpdateMsg);
      } else {
        snackInfoMessage = _baseLogic.l10n(unknownErrorMsg);
      }
    }

    return null;
  }

  Future<void> _loadViewScript(int duration) async {
    _script = null;
    _isReady = false;
    _script = await fetchData(
      aiService.viewMeditationScript(duration: duration),
    );
  }

  void loadViewScript(int duration) async {
    // await _completer.operation.cancel();
    // _completer = CancelableCompleter(onCancel: () {});
    // _completer.complete(Future.value(_loadViewScript(duration)));
    // _completer.operation.value.whenComplete(() {
    //   _isReady = true;
    //   cb();
    // });
    // return _completer.operation.value;

    await cancelRequest();
    _operation = CancelableOperation.fromFuture(
      _loadViewScript(duration),
      onCancel: () {},
    );
    await _operation!.valueOrCancellation(null);
    _isReady = true;

    if (_operation!.isCompleted) _baseLogic.trigger();
  }

  Future<void> _loadScript(int? duration) async {
    _script = null;
    _isReady = false;
    _script = await fetchData(
      aiService.getMeditationScript(duration: duration),
    );
  }

  void loadScript(int? duration) async {
    // await _completer.operation.cancel();
    // _completer = CancelableCompleter(onCancel: () {});
    // _completer.complete(Future.value(_loadScript(duration)));
    // // _completer.operation.value.then((value) => {print('then: $value')});
    // _completer.operation.value.whenComplete(() {
    //   _isReady = true;
    //   cb();
    // });
    // return _completer.operation.value;

    await cancelRequest();

    _operation = CancelableOperation.fromFuture(
      _loadScript(duration),
      onCancel: () {},
    );
    await _operation!.valueOrCancellation(null);
    _isReady = true;
    if (_operation!.isCompleted) _baseLogic.trigger();
  }

  Future<void> cancelRequest() async {
    // await _completer.operation.cancel();
    if (_operation != null) await _operation!.cancel();

    _isReady = true;
  }

  void _updateTime(Timer timer) {
    if (!_watch.isRunning) {
      return;
    }

    int millsec = _watch.elapsedMilliseconds;

    if (_session == null) return;

    if (!_session!.isCompleted) {
      _session!.processTick(_player, millsec, (val) => _displayTime = val);
      _baseLogic.trigger();

      return;
    }

    stopMeditation();
  }

  void pauseMeditation() async {
    _session?.saveFinalizer();
    _playStatus = PlayStatus.pause;
    _watch.stop();
    _player.pause();
  }

  void continueMeditation() async {
    _session?.restoreFinalizer();
    _playStatus = PlayStatus.play;

    _player.play(() {
      if (_session?.playFinalizer != null) _session!.playFinalizer!();
    });

    _watch.start();
  }

  void startMeditation() async {
    if (_script == null) {
      //TODO error info
      return;
    }

    _displayTime = '';
    _session = AiMeditationSession(
      script: _script!,
      scriptDuration: aiService.currentScriptDuration,
    );
    _baseLogic.setInterruptionFilter(true);
    _playStatus = PlayStatus.play;
    _watch.start();
    Timer.periodic(Duration(milliseconds: 50), _updateTime);

    // Switch to meditation-friendly color scheme
    theme.setMeditationMode(true);
    _baseLogic.trigger(); // Trigger UI update
  }

  void stopMeditation() {
    if (_playStatus == PlayStatus.stop) {
      return;
    }
    _baseLogic.setInterruptionFilter(false);
    _playStatus = PlayStatus.stop;
    _watch.stop();
    _watch.reset();
    _player.stop();
    _session = null;

    // Switch back to normal color scheme
    theme.setMeditationMode(false);
    _baseLogic.trigger();
  }

  void dispose() {
    _baseLogic.dispose();
    _player.dispose();
  }
}
