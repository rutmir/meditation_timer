import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:keep_screen_on/keep_screen_on.dart';
import '../ai_logic.dart';
import '../entities/ai_page_mode.dart';
import '../infrastructure/l10n/generated/app_localizations.dart';
import '../service/theme_service.dart';
import '../utils.dart';
import 'common/constants.dart';
import 'common/go_back_button.dart';

class AiMeditationView {
  final AiLogic logic;
  final ThemeService theme;
  final Function(AiPageMode) onSetPageMode;
  final Function() onRebuild;

  AiMeditationView({
    required this.logic,
    required this.theme,
    required this.onSetPageMode,
    required this.onRebuild,
  });

  void _onStart() {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      logic.startMeditation();
      onRebuild();
    } else {
      KeepScreenOn.turnOn().then((val) {
        logic.startMeditation();
        onRebuild();
      });
    }
  }

  Widget getView(BuildContext context, {required EdgeInsets safeArea}) {
    final appStyle = theme.currentAppStyle;
    final l10n = AppLocalizations.of(context)!;
    final kRadius = 150.0 / 392.7 * MediaQuery.of(context).size.shortestSide;
    final lbTextStyle = TextStyle(
      fontSize: kTitleFontSize,
      color: appStyle.inversePrimary,
    );
    final lbSize = textSize(l10n.action_start, lbTextStyle);

    return Dismissible(
      direction: DismissDirection.startToEnd,
      resizeDuration: Duration(milliseconds: 50),
      onDismissed: (DismissDirection direction) {
        if (direction == DismissDirection.startToEnd ||
            direction == DismissDirection.up) {
          logic.cancelRequest();
          logic.stopMeditation();
          onSetPageMode(AiPageMode.list);
        }
      },
      key: Key('ai_script_view'),
      child: Padding(
        padding: EdgeInsets.only(top: safeArea.top),
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (deepPop, _) {
            logic.cancelRequest();
            logic.stopMeditation();
            onSetPageMode(AiPageMode.list);
          },
          child:
              !logic.isReady
                  ? Center(
                    child: CircularProgressIndicator(
                      color: appStyle.inversePrimary,
                    ),
                  )
                  : Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.topCenter,
                        child: Text(
                          logic.script?.title ?? '',
                          style: TextStyle(
                            fontSize: kTitleFontSize,
                            color: theme.currentAppStyle.inversePrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            switch (logic.playStatus) {
                              PlayStatus.play ||
                              PlayStatus.pause => GestureDetector(
                                onTap: () {
                                  switch (logic.playStatus) {
                                    case PlayStatus.play:
                                      logic.pauseMeditation();
                                      break;
                                    case PlayStatus.pause:
                                      logic.continueMeditation();
                                      break;
                                    case PlayStatus.stop:
                                      break;
                                  }

                                  onRebuild();
                                },
                                child: Stack(
                                  alignment: AlignmentDirectional.center,
                                  children: [
                                    SizedBox(
                                      width: kRadius * 2,
                                      height: kRadius * 2,
                                      child: CircularProgressIndicator(
                                        backgroundColor:
                                            appStyle.inversePrimary,
                                        color: appStyle.primary,
                                        strokeWidth: kRadius / 10,
                                        value: logic.sessionRemainDelta,
                                      ),
                                    ),
                                    Text(
                                      logic.displayTime,
                                      style: TextStyle(
                                        fontSize: 50.0,
                                        color: appStyle.inversePrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              PlayStatus.stop => ElevatedButton(
                                onPressed: _onStart,
                                style: ElevatedButton.styleFrom(
                                  shape: CircleBorder(
                                    side: BorderSide(
                                      width: 0.5,
                                      color: appStyle.inversePrimary,
                                    ),
                                  ),
                                  backgroundColor: appStyle.primary,
                                ),
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(
                                    kRadius - lbSize.width / 2.0,
                                    kRadius - lbSize.height / 2.0,
                                    kRadius - lbSize.width / 2.0,
                                    kRadius - lbSize.height / 2.0,
                                  ),
                                  child: Text(
                                    l10n.action_start,
                                    style: lbTextStyle,
                                  ),
                                ),
                              ),
                            },
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: GoBackButton(
                            themeService: theme,
                            padding: 8.0,
                            onTap: () {
                              logic.cancelRequest();
                              logic.stopMeditation();
                              onSetPageMode(AiPageMode.list);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }
}
