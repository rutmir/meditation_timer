import 'package:flutter/material.dart';
import '../../entities/app_style.dart';
import '../common/constants.dart';

/// A widget for displaying a single setting with label, optional description,
/// and a control widget (switch, slider, etc.).
///
/// When disabled, the entire item is grayed out and non-interactive.
class SettingItem extends StatelessWidget {
  final String label;
  final String? description;
  final Widget child;
  final bool disabled;
  final AppStyle appStyle;

  const SettingItem({
    super.key,
    required this.label,
    this.description,
    required this.child,
    this.disabled = false,
    required this.appStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: disabled ? 0.5 : 1.0,
      child: IgnorePointer(
        ignoring: disabled,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: kFormFontSize,
                      color: disabled
                          ? appStyle.formTextDisabled
                          : appStyle.formText,
                    ),
                  ),
                  if (description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      description!,
                      style: TextStyle(
                        fontSize: kFormFontSize - 4,
                        color: (disabled
                                ? appStyle.formTextDisabled
                                : appStyle.formText)
                            .withOpacity(0.7),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            child,
          ],
        ),
      ),
    );
  }
}
