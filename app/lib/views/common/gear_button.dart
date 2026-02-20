import 'package:flutter/material.dart';
import 'round_icon_button.dart';

class GearButton extends RoundIconButton {
  const GearButton({
    super.key,
    required super.themeService,
    required super.onTap,
  }) : super(icon: Icons.settings);
}
