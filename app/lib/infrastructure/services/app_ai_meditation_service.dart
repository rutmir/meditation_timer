import '../../entities/meditation_info.dart';
import '../../entities/meditation_script.dart';
import '../../service/ai_meditation_service.dart';
import '../../service/common/api_methods.dart';
import '../../service/transport_service.dart';
import 'common/meditation_info_list_response.dart';
import 'common/meditation_script_response.dart';

class AppAiMeditationService extends AiMeditationService {
  final TransportService _transportService;
  List<MeditationInfo> _todayMeditationList = [];
  final Map<int, MeditationScript> _meditations = {};
  String _locale = '';
  int _lastRequestedDuration = 0;

  AppAiMeditationService({required TransportService transportService})
    : _transportService = transportService;

  MeditationInfo? _meditationInfoFirstWhereOrNull(
    bool Function(MeditationInfo element) test,
  ) {
    for (var element in _todayMeditationList) {
      if (test(element)) return element;
    }
    return null;
  }

  Future<MeditationScript?> _getScript(int duration, bool full) async {
    _lastRequestedDuration = duration;

    var info = _meditationInfoFirstWhereOrNull((x) => x.duration == duration);
    if (info == null) await _fetchMeditationList();

    info = _meditationInfoFirstWhereOrNull((x) => x.duration == duration);
    if (info == null) return null;

    final script = _meditations[duration];
    if (script == null || script.timestamp != info.timestamp) return null;

    return full && script.isValid() ? script : null;
  }

  Future<List<MeditationInfo>> _fetchMeditationList() async {
    final list = await _transportService.get(
      '${ApiMethods.meditationInfoList}/$_locale',
      MeditationInfoListResponse(),
    );
    _todayMeditationList = list ?? [];
    return _todayMeditationList;
  }

  Future<MeditationScript?> _fetchMeditation({
    required int duration,
    required String endpoint,
  }) async {
    final script = await _transportService.get(
      '$endpoint?duration=$duration&lang=$_locale',
      MeditationScriptResponse(),
    );

    if (script == null) return null;

    _meditations[duration] = script;
    return script;
  }

  @override
  List<MeditationInfo> get meditationInfoList => _todayMeditationList;

  @override
  bool get isMeditationInfoListLoaded {
    if (_todayMeditationList.isEmpty) {
      return false;
    }

    final unixTimestampMillis = _todayMeditationList
        .map((item) => item.timestamp)
        .reduce((a, b) => a < b ? a : b);

    final dateTimeFromMillis = DateTime.fromMillisecondsSinceEpoch(
      unixTimestampMillis,
    );

    final difference = DateTime.now().difference(dateTimeFromMillis).inHours;

    return difference <= 24;
  }

  @override
  MeditationScript? get meditationScript =>
      _meditations[_lastRequestedDuration];

  @override
  String get locale => _locale;

  @override
  set locale(String val) => _locale = val;

  @override
  Future<List<MeditationInfo>> getMeditationInfoList({
    bool reload = false,
  }) async {
    if (!isMeditationInfoListLoaded || reload) {
      return await _fetchMeditationList();
    }

    return _todayMeditationList;
  }

  @override
  Future<MeditationScript?> getMeditationScript({
    required int? duration,
  }) async {
    final script = await _getScript(duration ?? _lastRequestedDuration, true);

    return script ??
        await _fetchMeditation(
          duration: duration ?? _lastRequestedDuration,
          endpoint: ApiMethods.meditation,
        );
  }

  @override
  Future<bool> isAiServiceOnline() async {
    try {
      await _transportService.get(ApiMethods.health);

      return true;
    } catch (_) {}

    return false;
  }

  @override
  Future<MeditationScript?> viewMeditationScript({
    required int duration,
  }) async {
    final script = await _getScript(duration, false);

    return script ??
        await _fetchMeditation(
          duration: duration,
          endpoint: ApiMethods.meditationScript,
        );
  }

  @override
  int get currentScriptDuration => _lastRequestedDuration;
}
