import 'package:flutter/material.dart';
import 'round_icon_button.dart';

class GoBackButton extends RoundIconButton {
  const GoBackButton({
    super.key,
    required super.themeService,
    required super.onTap,
    super.padding,
  }) : super(icon: Icons.reply);
}
