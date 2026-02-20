import 'package:flutter/material.dart';
import 'package:meditimer/service/theme_service.dart';

import '../../infrastructure/l10n/generated/app_localizations.dart';
import 'constants.dart';

class RoundBackButton extends StatelessWidget {
  final ThemeService theme;
  final Function() onPress;

  const RoundBackButton({
    super.key,
    required this.onPress,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ElevatedButton(
      onPressed: onPress,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return theme.currentAppStyle.primary;
          }
          return theme.currentAppStyle.inversePrimary;
        }),
        shape: WidgetStateProperty.all(
          CircleBorder(side: BorderSide(width: 0.0)),
        ),
        padding: WidgetStateProperty.all(EdgeInsets.all(kTitleFontSize)),
      ),
      child: Text(
        l10n.action_back,
        style: TextStyle(
          fontSize: kFormFontSize,
          color: theme.currentAppStyle.formText,
        ),
      ),
    );
  }
}
