import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../data/brain_stats_provider.dart';

class DashboardSummaryCard extends StatelessWidget {
  const DashboardSummaryCard({super.key, required this.stats});

  final DailyBrainStats stats;

  @override
  Widget build(BuildContext context) {
    final List<AppBrainStats> apps = <AppBrainStats>[
      stats.appStats['youtube'] ??
          const AppBrainStats(
            appName: 'YouTube',
            appId: 'youtube',
            brainLoad: 0,
            timeSpent: Duration.zero,
            pickups: 0,
            notifications: 0,
          ),
      stats.appStats['instagram'] ??
          const AppBrainStats(
            appName: 'Instagram',
            appId: 'instagram',
            brainLoad: 0,
            timeSpent: Duration.zero,
            pickups: 0,
            notifications: 0,
          ),
      stats.appStats['snapchat'] ??
          const AppBrainStats(
            appName: 'Snapchat',
            appId: 'snapchat',
            brainLoad: 0,
            timeSpent: Duration.zero,
            pickups: 0,
            notifications: 0,
          ),
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7F5),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFFFE4DD)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x221D0F09),
            blurRadius: 28,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
        child: Column(
          children: <Widget>[
            // On iOS, Apple APIs do not provide exact Reels/Shorts scroll
            // counts. Brain Load is computed from time spent, pickups,
            // notifications, limit hits, and completed breaks.
            Row(
              children: <Widget>[
                Expanded(
                  child: _TopMetric(
                    value: '${stats.brainLoad}',
                    label: 'Brain Load',
                    accent: const Color(0xFFFF8A45),
                  ),
                ),
                Expanded(
                  child: _TopMetric(
                    value: formatDuration(stats.timeSpent),
                    label: 'Time Spent',
                    accent: const Color(0xFFFF6C9B),
                  ),
                ),
                Expanded(
                  child: _TopMetric(
                    value: '${stats.pickups}',
                    label: 'Pickups',
                    accent: const Color(0xFFFFA05C),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(height: 1, color: const Color(0xFFFFE3DD)),
            const SizedBox(height: 12),
            Row(
              children: apps
                  .map(
                    (AppBrainStats app) =>
                        Expanded(child: _MiniAppMetric(app: app)),
                  )
                  .toList(growable: false),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopMetric extends StatelessWidget {
  const _TopMetric({
    required this.value,
    required this.label,
    required this.accent,
  });

  final String value;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: accent,
              fontSize: 31,
              fontWeight: FontWeight.w300,
              letterSpacing: -0.6,
            ),
          ),
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF9D8E89),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _MiniAppMetric extends StatelessWidget {
  const _MiniAppMetric({required this.app});

  final AppBrainStats app;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        _AppIcon(appId: app.appId),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            '${app.brainLoad}',
            style: TextStyle(
              color: _accentForApp(app.appId),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _AppIcon extends StatelessWidget {
  const _AppIcon({required this.appId});

  final String appId;

  @override
  Widget build(BuildContext context) {
    final bool isInstagram = appId == 'instagram';
    final bool isSnapchat = appId == 'snapchat';
    const double size = 28;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isInstagram
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  Color(0xFFFEDA77),
                  Color(0xFFF58529),
                  Color(0xFFDD2A7B),
                  Color(0xFF8134AF),
                ],
              )
            : null,
        color: isSnapchat ? const Color(0xFFFFF15A) : Colors.white,
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x16000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: FaIcon(
          switch (appId) {
            'youtube' => FontAwesomeIcons.youtube,
            'instagram' => FontAwesomeIcons.instagram,
            'snapchat' => FontAwesomeIcons.snapchat,
            _ => FontAwesomeIcons.mobileScreenButton,
          },
          size: size * 0.5,
          color: switch (appId) {
            'youtube' => const Color(0xFFFF3B30),
            'instagram' => Colors.white,
            'snapchat' => const Color(0xFF171717),
            _ => const Color(0xFF8B807B),
          },
        ),
      ),
    );
  }
}

Color _accentForApp(String appId) {
  switch (appId) {
    case 'youtube':
      return const Color(0xFFFF6B67);
    case 'instagram':
      return const Color(0xFFFF5B91);
    case 'snapchat':
      return const Color(0xFFE0B600);
    default:
      return const Color(0xFF8F817C);
  }
}
