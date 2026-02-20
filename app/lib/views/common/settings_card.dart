import 'package:flutter/material.dart';
import '../../entities/app_style.dart';
import 'constants.dart';

class SettingsCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final bool enabled;
  final AppStyle appStyle;
  final VoidCallback? onHelpTap;

  const SettingsCard({
    super.key,
    required this.title,
    required this.children,
    required this.appStyle,
    this.enabled = true,
    this.onHelpTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: Card(
        color: appStyle.inversePrimary,
        margin: EdgeInsets.zero,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: kTitleFontSize,
                      fontWeight: FontWeight.bold,
                      color: appStyle.formText,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (onHelpTap != null)
                    Positioned(
                      right: 0,
                      child: GestureDetector(
                        onTap: onHelpTap,
                        child: Icon(
                          Icons.help_outline,
                          color: appStyle.formText.withOpacity(0.7),
                          size: 20,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: kFormSpacer),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}