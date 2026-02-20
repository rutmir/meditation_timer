import 'package:flutter/material.dart';
import '../../entities/app_style.dart';
import '../../infrastructure/l10n/generated/app_localizations.dart';

/// Shows a confirmation dialog before resetting settings to defaults.
///
/// Returns true if user confirms, false otherwise.
Future<bool> showResetConfirmDialog(
  BuildContext context, {
  required AppStyle appStyle,
}) async {
  final l10n = AppLocalizations.of(context)!;

  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        l10n.lb_reset_confirm_title,
        style: TextStyle(color: appStyle.formText),
      ),
      backgroundColor: appStyle.formBackground,
      content: Text(
        l10n.lb_reset_confirm_message,
        style: TextStyle(color: appStyle.formText),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(
            l10n.lb_reset_defaults,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ],
    ),
  );

  return result ?? false;
}
