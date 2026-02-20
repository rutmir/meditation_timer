import 'package:flutter/material.dart';
import 'round_icon_button.dart';

class InfoButton extends RoundIconButton {
  const InfoButton({
    super.key,
    required super.themeService,
    required super.onTap,
  }) : super(icon: Icons.priority_high);
}
