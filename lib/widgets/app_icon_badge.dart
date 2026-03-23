import 'package:flutter/material.dart';

import '../models/target_app.dart';

class AppIconBadge extends StatelessWidget {
  const AppIconBadge({
    super.key,
    required this.app,
    this.small = false,
  });

  final TargetApp app;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final double size = small ? 14 : 18;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 10,
        vertical: small ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: app.meta.color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(app.meta.iconData, size: size, color: app.meta.color),
          SizedBox(width: small ? 6 : 8),
          Text(
            app.meta.displayName,
            style: TextStyle(
              fontSize: small ? 11 : 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

