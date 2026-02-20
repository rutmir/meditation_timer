import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../infrastructure/router/hero_dialog_route.dart';
import '../../service/theme_service.dart';
import 'custom_rect_tween.dart';
// import 'styles.dart';

/// {@template show_tip_button}
/// Button to show a tip.
///
/// Opens a [HeroDialogRoute] of [_ShowTipPopupCard].
///
/// Uses a [Hero] with tag [_heroShowTip].
/// {@endtemplate}
class ShowTipButton extends StatelessWidget {
  final ThemeService theme;

  /// {@macro show_tip_button}
  const ShowTipButton({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    final appStyle = theme.currentAppStyle;
    // final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            HeroDialogRoute(
              builder: (context) {
                return const _ShowTipPopupCard();
              },
            ),
          );
        },
        child: Hero(
          tag: _heroShowTip,
          createRectTween: (begin, end) {
            return CustomRectTween(begin: begin, end: end);
          },
          child: Material(
            color: appStyle.inversePrimary, // AppColors.accentColor,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.tips_and_updates_rounded,
                size: 28,
                color: appStyle.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Tag-value used for the tips popup button.
const String _heroShowTip = 'show-tip-hero';

/// {@template show_tip_popup_card}
/// Popup card to show a tip. Should be used in conjuction with
/// [HeroDialogRoute] to achieve the popup effect.
///
/// Uses a [Hero] with tag [_heroShowTip].
/// {@endtemplate}
class _ShowTipPopupCard extends StatelessWidget {
  /// {@macro show_tip_popup_card}
  const _ShowTipPopupCard();

  @override
  Widget build(BuildContext context) {
    final appStyle = GetIt.I<ThemeService>().currentAppStyle;
    // final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Hero(
          tag: _heroShowTip,
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
                    const TextField(
                      decoration: InputDecoration(
                        hintText: 'New todo',
                        border: InputBorder.none,
                      ),
                      cursorColor: Colors.white,
                    ),
                    Divider(color: appStyle.primary, thickness: 0.2),
                    const TextField(
                      decoration: InputDecoration(
                        hintText: 'Write a note',
                        border: InputBorder.none,
                      ),
                      cursorColor: Colors.white,
                      maxLines: 6,
                    ),
                    Divider(color: appStyle.primary, thickness: 0.2),
                    TextButton(onPressed: () {}, child: const Text('Add')),
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
