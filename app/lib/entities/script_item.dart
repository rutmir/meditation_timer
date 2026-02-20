class ScriptItem {
  final String instructions;
  final String? audio;
  final int startTime;

  ScriptItem({required this.instructions, required this.startTime, this.audio});

  bool isValid() {
    return instructions.isNotEmpty && (audio?.isNotEmpty ?? false);
  }
}
