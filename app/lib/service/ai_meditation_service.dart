import '../entities/meditation_info.dart';
import '../entities/meditation_script.dart';

abstract class AiMeditationService {
  Future<bool> isAiServiceOnline();
  bool get isMeditationInfoListLoaded;
  String get locale;
  set locale(String val);
  List<MeditationInfo> get meditationInfoList;
  MeditationScript? get meditationScript;
  int get currentScriptDuration;

  Future<List<MeditationInfo>> getMeditationInfoList({bool reload = false});
  Future<MeditationScript?> viewMeditationScript({required int duration});
  Future<MeditationScript?> getMeditationScript({required int? duration});
}
