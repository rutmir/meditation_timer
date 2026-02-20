import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../infrastructure/l10n/generated/app_localizations.dart';
import '../../service/theme_service.dart';
import 'constants.dart';
import 'custom_rect_tween.dart';

const String heroAiInfo = 'show-ai-info-hero';

class AiInfoDialog extends StatelessWidget {
  const AiInfoDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final appStyle = GetIt.I<ThemeService>().currentAppStyle;
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Hero(
          tag: heroAiInfo,
          transitionOnUserGestures: false,
          createRectTween: (begin, end) {
            return CustomRectTween(begin: begin!, end: end!);
          },
          child: Material(
            color: appStyle.inversePrimary, // AppColors.accentColor,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.lb_created_by_ai,
                      style: TextStyle(
                        fontSize: kTitleFontSize,
                        color: appStyle.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Divider(color: appStyle.primary, thickness: 0.2),
                    Text(
                      l10n.created_by_ai_msg,
                      style: TextStyle(
                        fontSize: kFormFontSize,
                        color: appStyle.primary,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                    Divider(color: appStyle.primary, thickness: 0.2),
                    Row(
                      children: [
                        Expanded(child: Container()),
                        TextButton(
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all<Color>(
                              appStyle.formBackground,
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Ok', // TODO l10n.permission_msg_reject,
                            style: TextStyle(
                              fontSize: kFormFontSize,
                              color: appStyle.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
