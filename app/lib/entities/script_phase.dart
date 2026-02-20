import './script_item.dart';

class ScriptPhase {
  final String name;
  final List<ScriptItem> items;

  ScriptPhase({required this.name, required this.items});

  bool isValid() {
    if (items.isEmpty) return false;

    return !items.any((x) => !x.isValid());
  }
}
