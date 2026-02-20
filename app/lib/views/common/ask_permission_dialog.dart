import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../infrastructure/l10n/generated/app_localizations.dart';
import '../../service/theme_service.dart';
import 'constants.dart';
import 'custom_rect_tween.dart';

const String heroShowAskPermission = 'show-ask-permission-hero';

class AskPermissionDialog extends StatefulWidget {
  final Function() onReject;
  final Function() onAccept;
  final Function() onDismiss;

  const AskPermissionDialog({
    super.key,
    required this.onReject,
    required this.onAccept,
    required this.onDismiss,
  });

  @override
  State<AskPermissionDialog> createState() => _AskPermissionDialogState();
}

class _AskPermissionDialogState extends State<AskPermissionDialog> {
  bool _dontAskAgain = false;

  @override
  Widget build(BuildContext context) {
    final appStyle = GetIt.I<ThemeService>().currentAppStyle;
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Hero(
          tag: heroShowAskPermission,
          transitionOnUserGestures: false,
          createRectTween: (begin, end) {
            return CustomRectTween(begin: begin!, end: end!);
          },
          child: Material(
            color: appStyle.inversePrimary,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.do_not_disturb_on_outlined,
                      size: 48,
                      color: appStyle.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.permission_msg_title,
                      style: TextStyle(
                        fontSize: kTitleFontSize,
                        color: appStyle.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Divider(color: appStyle.primary, thickness: 0.2),
                    const SizedBox(height: 8),
                    Text(
                      l10n.permission_msg_1,
                      style: TextStyle(
                        fontSize: kFormFontSize,
                        color: appStyle.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.permission_msg_2,
                      style: TextStyle(
                        fontSize: kFormFontSize - 2,
                        color: appStyle.primary.withAlpha(180),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.permission_msg_3,
                      style: TextStyle(
                        fontSize: kFormFontSize - 2,
                        color: appStyle.primary.withAlpha(180),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Divider(color: appStyle.primary, thickness: 0.2),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _dontAskAgain = !_dontAskAgain;
                        });
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: _dontAskAgain,
                              onChanged: (val) {
                                setState(() {
                                  _dontAskAgain = val ?? false;
                                });
                              },
                              activeColor: appStyle.primary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.permission_msg_dont_ask,
                            style: TextStyle(
                              fontSize: kFormFontSize - 2,
                              color: appStyle.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        TextButton(
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all<Color>(
                              appStyle.formBackground,
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            if (_dontAskAgain) {
                              widget.onDismiss();
                            } else {
                              widget.onReject();
                            }
                          },
                          child: Text(
                            l10n.permission_msg_reject,
                            style: TextStyle(
                              fontSize: kFormFontSize,
                              color: appStyle.primary,
                            ),
                          ),
                        ),
                        Expanded(child: Container()),
                        TextButton(
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all<Color>(
                              Colors.lightGreenAccent,
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            widget.onAccept();
                          },
                          child: Text(
                            l10n.permission_msg_accept,
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
