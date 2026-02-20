import 'package:flutter/material.dart';
import 'round_icon_button.dart';

class AiButton extends RoundIconButton {
  const AiButton({super.key, required super.themeService, required super.onTap})
    : super(icon: Icons.webhook);
}
