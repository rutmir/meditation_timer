import 'package:flutter/material.dart';

class IncrementalSlider extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final double step;
  final ValueChanged<double>? onChanged;
  final bool enabled;
  final Color? activeColor;
  final Color? inactiveColor;

  const IncrementalSlider({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    this.step = 1.0,
    this.onChanged,
    this.enabled = true,
    this.activeColor,
    this.inactiveColor,
  });

  void _updateValue(double newValue) {
    if (onChanged != null && enabled) {
      final clampedValue = newValue.clamp(min, max);
      onChanged!(clampedValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: enabled && value > min ? () => _updateValue(value - step) : null,
        ),
        Expanded(
          child: Slider(
            value: value,
            min: min,
            max: max,
            onChanged: enabled ? onChanged : null,
            activeColor: activeColor,
            inactiveColor: inactiveColor,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: enabled && value < max ? () => _updateValue(value + step) : null,
        ),
      ],
    );
  }
}
