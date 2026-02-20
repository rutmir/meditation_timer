import 'package:flutter/material.dart';

mixin MixinPage {
  void showSnackBar(
    BuildContext context, {
    required Widget content,
    SnackBarAction? action,
  }) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: content, action: action, actionOverflowThreshold: 1),
  );

  void afterBuild(
    BuildContext context,
    String Function() text, {
    SnackBarAction? action,
  }) {
    final snackStr = text();
    if (snackStr.isNotEmpty) {
      showSnackBar(context, content: Text(snackStr), action: action);
    }
  }
}
