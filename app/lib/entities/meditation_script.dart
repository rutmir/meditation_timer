import './script_phase_item.dart';

class MeditationScript {
  final int timestamp;
  final String title;
  final String conclusion;
  final String? conclusionAudio;
  final String introduction;
  final String? introductionAudio;
  final List<ScriptPhaseItem> body;

  MeditationScript({
    required this.timestamp,
    required this.title,
    required this.conclusion,
    this.conclusionAudio,
    required this.introduction,
    this.introductionAudio,
    required this.body,
  });

  bool isValid() {
    if (title.isEmpty) return false;
    if (conclusion.isEmpty && (conclusionAudio?.isNotEmpty ?? false)) {
      return false;
    }
    if (introduction.isEmpty && (introductionAudio?.isNotEmpty ?? false)) {
      return false;
    }

    return !body.any((x) => !x.phase.isValid());
  }
}
