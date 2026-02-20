import 'package:flutter/material.dart';
import '../../service/theme_service.dart';

class RoundIconButton extends StatelessWidget {
  final ThemeService themeService;
  final IconData icon;
  final Function() onTap;
  final double? padding;
  final double? scale;
  final bool inverseColor;

  const RoundIconButton({
    super.key,
    required this.icon,
    required this.themeService,
    required this.onTap,
    this.padding,
    this.scale,
    this.inverseColor = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all((scale ?? 1.0) * (padding ?? 12.0)),
      child: GestureDetector(
        onTap: onTap,
        child: Material(
          color:
              inverseColor
                  ? themeService.currentAppStyle.primary
                  : themeService
                      .currentAppStyle
                      .inversePrimary, // AppColors.accentColor,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
          child: Padding(
            padding: EdgeInsets.all((scale ?? 1.0) * 8.0),
            child: Icon(
              icon,
              size: (scale ?? 1.0) * 28,
              color:
                  inverseColor
                      ? themeService.currentAppStyle.inversePrimary
                      : themeService.currentAppStyle.primary,
            ),
          ),
        ),
      ),
    );
  }
}
