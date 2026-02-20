import 'package:flutter/material.dart';
import '../../entities/app_style.dart';
import '../common/constants.dart';

/// A collapsible section widget for organizing settings into categories.
///
/// Uses AnimatedCrossFade for smooth expand/collapse animations.
class CollapsibleSection extends StatefulWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final bool initiallyExpanded;
  final Widget child;
  final AppStyle appStyle;
  final VoidCallback? onHelpTap;
  final ValueChanged<bool>? onExpansionChanged;

  const CollapsibleSection({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.initiallyExpanded = false,
    required this.child,
    required this.appStyle,
    this.onHelpTap,
    this.onExpansionChanged,
  });

  @override
  State<CollapsibleSection> createState() => _CollapsibleSectionState();
}

class _CollapsibleSectionState extends State<CollapsibleSection> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  void _handleTap() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    widget.onExpansionChanged?.call(_isExpanded);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: widget.appStyle.inversePrimary,
      margin: EdgeInsets.zero,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header - always visible, tappable
          InkWell(
            onTap: _handleTap,
            borderRadius: BorderRadius.vertical(
              top: const Radius.circular(16),
              bottom: _isExpanded ? Radius.zero : const Radius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      color: widget.appStyle.formText,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(
                            fontSize: kTitleFontSize,
                            fontWeight: FontWeight.bold,
                            color: widget.appStyle.formText,
                          ),
                        ),
                        if (widget.subtitle != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            widget.subtitle!,
                            style: TextStyle(
                              fontSize: kFormFontSize - 4,
                              color: widget.appStyle.formText.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (widget.onHelpTap != null) ...[
                    GestureDetector(
                      onTap: widget.onHelpTap,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Icon(
                          Icons.help_outline,
                          color: widget.appStyle.formText.withOpacity(0.7),
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.expand_more,
                      color: widget.appStyle.formText,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Content - animates in/out
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                bottom: 16.0,
              ),
              child: widget.child,
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
            sizeCurve: Curves.easeInOut,
          ),
        ],
      ),
    );
  }
}
