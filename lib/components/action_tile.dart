import 'package:flutter/material.dart';
import 'package:qr_code_app/providers/theme_globals.dart';
import 'package:qr_code_app/theme/app_theme.dart';
import 'package:qr_code_app/theme/tokens.dart';

/// Home-screen action tile. Featured tiles are full-width with subtitle.
class ActionTile extends StatelessWidget {
  /// Creates an action tile.
  const new({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.featured = false,
    super.key,
  });

  /// Leading icon.
  final IconData icon;

  /// Title.
  final String title;

  /// Optional supporting line (shown on featured tiles).
  final String? subtitle;

  /// Navigation callback.
  final VoidCallback onTap;

  /// When true, uses the larger horizontal layout.
  final bool featured;

  @override
  Widget build(BuildContext context) {
    final c = currentColors;
    final copper = c['button-color']!;
    final theme = Theme.of(context);
    final radius = BorderRadius.circular(AppTokens.rLg);

    var wellSize = AppTokens.compactWell;
    var iconSize = AppTokens.compactIcon;
    var minHeight = 72.0;
    var pad = AppTokens.s3;
    var textCross = CrossAxisAlignment.center;
    var titleAlign = TextAlign.center;
    if (featured) {
      wellSize = 44;
      iconSize = 22;
      minHeight = AppTokens.featuredH;
      pad = AppTokens.s4;
      textCross = CrossAxisAlignment.start;
      titleAlign = TextAlign.start;
    }

    final iconWell = Container(
      key: const Key('action-tile-well'),
      width: wellSize,
      height: wellSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: copper.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppTokens.rSm),
      ),
      child: Icon(icon, color: copper, size: iconSize),
    );

    final texts = Column(
      crossAxisAlignment: textCross,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: titleAlign,
          style: theme.textTheme.titleMedium,
        ),
        if (featured && subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ],
    );

    late final Widget inner;
    if (featured) {
      inner = Row(
        children: [
          iconWell,
          const SizedBox(width: AppTokens.s4),
          Expanded(child: texts),
          Icon(
            Icons.chevron_right_rounded,
            color: c['text-muted'],
          ),
        ],
      );
    } else {
      inner = Column(
        children: [
          Expanded(
            child: Center(child: iconWell),
          ),
          texts,
        ],
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Ink(
          decoration: BoxDecoration(
            color: c['surface'],
            borderRadius: radius,
            border: Border.all(color: c['border']!),
            boxShadow: paperShadow(c['shadow']!),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: minHeight),
            child: Padding(
              padding: EdgeInsets.all(pad),
              child: inner,
            ),
          ),
        ),
      ),
    );
  }
}
