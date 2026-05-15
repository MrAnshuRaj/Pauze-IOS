import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../screens/onboarding/onboarding_screen_2.dart';
import '../data/brain_stats_provider.dart';

Future<void> showDayBrainDetailsDialog(
  BuildContext context, {
  required DailyBrainStats stats,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close',
    barrierColor: const Color(0x66000000),
    transitionDuration: const Duration(milliseconds: 260),
    pageBuilder:
        (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
        ) {
          return _DialogBackdrop(stats: stats);
        },
    transitionBuilder:
        (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
          Widget child,
        ) {
          final CurvedAnimation curve = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
          return FadeTransition(
            opacity: curve,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.95, end: 1.0).animate(curve),
              child: child,
            ),
          );
        },
  );
}

class _DialogBackdrop extends StatelessWidget {
  const _DialogBackdrop({required this.stats});

  final DailyBrainStats stats;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).maybePop(),
      child: Material(
        color: Colors.transparent,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Center(
            child: GestureDetector(
              onTap: () {},
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: FractionallySizedBox(
                  widthFactor: 0.86,
                  child: _DialogCard(stats: stats),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DialogCard extends StatelessWidget {
  const _DialogCard({required this.stats});

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
        color: const Color(0xFFFFF8F7),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFFFE3DE)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x261C100B),
            blurRadius: 28,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Align(
              alignment: Alignment.topRight,
              child: Material(
                color: const Color(0xFFFFE8EE),
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () async {
                    await HapticFeedback.lightImpact();
                    if (context.mounted) {
                      Navigator.of(context).maybePop();
                    }
                  },
                  child: const SizedBox(
                    width: 34,
                    height: 34,
                    child: Center(
                      child: Text(
                        'x',
                        style: TextStyle(
                          color: Color(0xFF9D8786),
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Text(
              formatDayName(stats.date),
              style: const TextStyle(
                color: Color(0xFF4A342F),
                fontSize: 24,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              formatDate(stats.date),
              style: const TextStyle(
                color: Color(0xFF9B8D88),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: 126,
              height: 108,
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Container(
                    width: 104,
                    height: 104,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: <Color>[
                          const Color(0xFFFFC3D4).withValues(alpha: 0.32),
                          const Color(0xFFFFFBF8).withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                  PauMascot(state: pauStateName(stats.brainState), size: 82),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: <Widget>[
                Expanded(
                  child: _PopupMetricCard(
                    value: '${stats.brainLoad}',
                    label: 'Brain Load',
                    color: const Color(0xFFFF8A45),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _PopupMetricCard(
                    value: formatDuration(stats.timeSpent),
                    label: 'Time',
                    color: const Color(0xFFFF6B9C),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _PopupMetricCard(
                    value: '${stats.pickups}',
                    label: 'Pickups',
                    color: const Color(0xFFFF9A54),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'BY APP',
                style: TextStyle(
                  color: Color(0xFF9E908A),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            const SizedBox(height: 8),
            ...apps.map((AppBrainStats app) => _PopupAppRow(app: app)),
          ],
        ),
      ),
    );
  }
}

class _PopupMetricCard extends StatelessWidget {
  const _PopupMetricCard({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 92,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withValues(alpha: 0.74),
        border: Border.all(color: color.withValues(alpha: 0.9)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 28,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF9D8D88),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PopupAppRow extends StatelessWidget {
  const _PopupAppRow({required this.app});

  final AppBrainStats app;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: <Widget>[
          _AppIcon(appId: app.appId),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              app.appName,
              style: const TextStyle(
                color: Color(0xFF3A2B28),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          _TinyMetric(
            value: '${app.brainLoad}',
            label: 'load',
            color: _accentForApp(app.appId),
          ),
          const SizedBox(width: 10),
          _TinyMetric(
            value: formatDuration(app.timeSpent),
            label: 'time',
            color: _accentForApp(app.appId),
          ),
          const SizedBox(width: 10),
          _TinyMetric(
            value: '${app.pickups}',
            label: 'pickups',
            color: _accentForApp(app.appId),
          ),
        ],
      ),
    );
  }
}

class _TinyMetric extends StatelessWidget {
  const _TinyMetric({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 46,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFAA9994),
              fontSize: 8,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
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

    return Container(
      width: 28,
      height: 28,
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
            color: Color(0x14000000),
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
          size: 14,
          color: switch (appId) {
            'youtube' => const Color(0xFFFF3B30),
            'instagram' => Colors.white,
            'snapchat' => const Color(0xFF171717),
            _ => const Color(0xFF8E827D),
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
      return const Color(0xFFE1BB00);
    default:
      return const Color(0xFF8F817C);
  }
}
