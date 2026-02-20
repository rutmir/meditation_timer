import '../../../entities/script_item.dart';
import '../../../entities/script_phase.dart';
import '../../../entities/script_phase_item.dart';
import '../../../service/common/json_response.dart';

class ScriptItemResponse extends JsonResponse<ScriptItem> {
  @override
  ScriptItem fromJson(dynamic json) {
    final data = json as Map<String, dynamic>;

    return ScriptItem(
      startTime: data['startTime'] as int,
      instructions: data['instructions'] as String,
      audio: data['audio'] as String?,
    );
  }
}

class ScriptPhaseResponse extends JsonResponse<ScriptPhase> {
  @override
  ScriptPhase fromJson(dynamic json) {
    final data = json as Map<String, dynamic>;

    return ScriptPhase(
      name: data['name'] as String,
      items:
          data['items']
              .map<ScriptItem>((x) => ScriptItemResponse().fromJson(x))
              .toList(),
    );
  }
}

class ScriptPhaseItemResponse extends JsonResponse<ScriptPhaseItem> {
  @override
  ScriptPhaseItem fromJson(dynamic json) {
    final data = json as Map<String, dynamic>;

    return ScriptPhaseItem(
      phase: ScriptPhaseResponse().fromJson(data['phase']),
    );
  }
}
