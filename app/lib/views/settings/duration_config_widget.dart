import 'package:flutter/material.dart';
import '../../entities/app_style.dart';
import '../../infrastructure/l10n/generated/app_localizations.dart';
import '../common/constants.dart';
import '../common/incremental_slider.dart';

/// A widget for configuring duration values with a slider and quick-pick dialog.
///
/// Displays the current value, min/max labels, and a slider for adjustment.
/// Tapping the label opens a quick-pick dialog with common duration values.
class DurationConfigWidget extends StatelessWidget {
  final String label;
  final int value;
  final double min;
  final double max;
  final bool disabled;
  final AppStyle appStyle;
  final ValueChanged<double>? onChanged;
  final String? description;

  const DurationConfigWidget({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    this.disabled = false,
    required this.appStyle,
    this.onChanged,
    this.description,
  });

  TextStyle _textStyle({bool? bold}) {
    return TextStyle(
      fontWeight: bold == true ? FontWeight.w800 : null,
      fontSize: kFormFontSize,
      color: disabled ? appStyle.formTextDisabled : appStyle.formText,
    );
  }

  void _showQuickPick(BuildContext context, AppLocalizations l10n) {
    final List<int> options = [1, 2, 5, 10, 15, 20, 30, 45, 60, 90, 120, 180, 240]
        .where((opt) => opt >= min && opt <= max)
        .toList();

    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(
          label,
          style: TextStyle(color: appStyle.formText),
        ),
        backgroundColor: appStyle.formBackground,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: options
                  .map(
                    (opt) => ActionChip(
                      label: Text('$opt'),
                      onPressed: () {
                        onChanged?.call(opt.toDouble());
                        Navigator.pop(context);
                      },
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label with current value (tappable for quick-pick)
        GestureDetector(
          onTap: disabled ? null : () => _showQuickPick(context, l10n),
          child: RichText(
            maxLines: 2,
            text: TextSpan(
              text: '$label (',
              style: _textStyle(),
              children: [
                TextSpan(
                  text: '$value',
                  style: _textStyle(bold: true),
                ),
                TextSpan(
                  text: ' ${l10n.lb_minute_short})',
                  style: _textStyle(),
                ),
              ],
            ),
          ),
        ),
        if (description != null) ...[
          const SizedBox(height: 4),
          Text(
            description!,
            style: TextStyle(
              fontSize: kFormFontSize - 4,
              color: (disabled ? appStyle.formTextDisabled : appStyle.formText)
                  .withOpacity(0.7),
            ),
          ),
        ],
        const SizedBox(height: 8),
        // Slider with min/max labels
        Row(
          children: [
            Text(
              '${min.round()} ${l10n.lb_minute_short}',
              style: _textStyle(),
            ),
            Expanded(
              child: IncrementalSlider(
                min: min,
                max: max,
                value: value.toDouble(),
                onChanged: disabled ? null : onChanged,
              ),
            ),
            Text(
              '${max.round()} ${l10n.lb_minute_short}',
              style: _textStyle(),
            ),
          ],
        ),
      ],
    );
  }
}
