import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/analytics_models.dart';
import '../models/target_app.dart';
import 'blocked_apps_screen.dart';
import 'home_screen.dart';
import '../providers/app_state.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  static const List<_AppVisual> _catalog = <_AppVisual>[
    _AppVisual(
      id: 'youtube',
      name: 'YouTube',
      icon: FontAwesomeIcons.youtube,
      tint: Color(0xFFFF3B30),
      accent: Color(0xFFFF7A70),
    ),
    _AppVisual(
      id: 'instagram',
      name: 'Instagram',
      icon: FontAwesomeIcons.instagram,
      tint: Color(0xFFE4405F),
      accent: Color(0xFFFF9A62),
    ),
    _AppVisual(
      id: 'facebook',
      name: 'Facebook',
      icon: FontAwesomeIcons.facebook,
      tint: Color(0xFF1877F2),
      accent: Color(0xFF7BB1FF),
    ),
    _AppVisual(
      id: 'x',
      name: 'X',
      icon: FontAwesomeIcons.xTwitter,
      tint: Color(0xFFE7ECF5),
      accent: Color(0xFF98A3B8),
    ),
    _AppVisual(
      id: 'reddit',
      name: 'Reddit',
      icon: FontAwesomeIcons.redditAlien,
      tint: Color(0xFFFF6A33),
      accent: Color(0xFFFFB073),
    ),
    _AppVisual(
      id: 'tiktok',
      name: 'TikTok',
      icon: FontAwesomeIcons.tiktok,
      tint: Color(0xFF25F4EE),
      accent: Color(0xFFFF4D8D),
    ),
    _AppVisual(
      id: 'snapchat',
      name: 'Snapchat',
      icon: FontAwesomeIcons.snapchat,
      tint: Color(0xFFFFF15A),
      accent: Color(0xFFFFD64A),
    ),
  ];

  String _selectedAppId = 'all';
  _TimeRange _selectedRange = _TimeRange.week;
  int _totalScrollCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      unawaited(context.read<AppState>().refreshUsageFromNative());
      unawaited(_loadLocalMetrics());
    });
  }

  Future<void> _loadLocalMetrics() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int totalScroll = 0;
    for (final String key in <String>['total_scrolls', 'stats_total_scrolls']) {
      final Object? value = prefs.get(key);
      if (value is int) {
        totalScroll = value;
        break;
      }
      if (value is String) {
        totalScroll = int.tryParse(value) ?? totalScroll;
      }
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _totalScrollCount = totalScroll;
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppState state = context.watch<AppState>();
    final _AdaptiveGlassStyle glassStyle = _AdaptiveGlassStyle.of(context);
    final Map<String, _UsageMetrics> usageMap = _buildUsageMetrics(state);
    final List<_UsageEntry> entries = _buildUsageEntries(usageMap);
    final List<_ChartDatum> chartData = _buildChartData(state, usageMap);
    final _FocusScoreSnapshot focusScore = _buildFocusScore(state, usageMap);
    final List<_AppVisual> blockedApps = _blockedAppsForCard(state, entries);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              Color(0xFF090B12),
              Color(0xFF111522),
              Color(0xFF181A24),
            ],
          ),
        ),
        child: Stack(
          children: <Widget>[
            const Positioned(
              top: -110,
              right: -70,
              child: _BackgroundOrb(
                size: 260,
                colors: <Color>[Color(0x6639C6FF), Color(0x0039C6FF)],
              ),
            ),
            const Positioned(
              top: 220,
              left: -80,
              child: _BackgroundOrb(
                size: 240,
                colors: <Color>[Color(0x4425F4EE), Color(0x0025F4EE)],
              ),
            ),
            const Positioned(
              bottom: 70,
              right: -50,
              child: _BackgroundOrb(
                size: 200,
                colors: <Color>[Color(0x44FF5E7A), Color(0x00FF5E7A)],
              ),
            ),
            SafeArea(
              bottom: false,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: <Widget>[
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 124),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate(<Widget>[
                        _PageHeader(
                          glassStyle: glassStyle,
                          onBack: () => Navigator.of(context).maybePop(),
                        ),
                        const SizedBox(height: 22),
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Expanded(
                                child: _FocusScoreCard(
                                  snapshot: focusScore,
                                  glassStyle: glassStyle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: BlockedAppsCard(
                                  blockedApps: blockedApps,
                                  totalCount: math.max(
                                    blockedApps.length,
                                    state.selectedTrackedApps.length,
                                  ),
                                  glassStyle: glassStyle,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        WeeklyScrollChart(
                          glassStyle: glassStyle,
                          selectedAppId: _selectedAppId,
                          chartData: chartData,
                          apps: _catalog,
                          onChanged: (String? value) {
                            if (value == null) {
                              return;
                            }
                            setState(() {
                              _selectedAppId = value;
                            });
                          },
                        ),
                        const SizedBox(height: 10),
                        TimeRangeSelector(
                          value: _selectedRange,
                          glassStyle: glassStyle,
                          onChanged: (_TimeRange range) {
                            setState(() {
                              _selectedRange = range;
                            });
                          },
                        ),
                        const SizedBox(height: 14),
                        const _SectionHeader(
                          title: 'App activity',
                          subtitle:
                              'Your most distracting apps for the selected period',
                        ),
                        const SizedBox(height: 10),
                        GlassCard(
                          glassStyle: glassStyle,
                          radius: 28,
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            children: entries
                                .map(
                                  (_UsageEntry entry) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4,
                                    ),
                                    child: AppUsageTile(
                                      entry: entry,
                                      glassStyle: glassStyle,
                                    ),
                                  ),
                                )
                                .toList(growable: false),
                          ),
                        ),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _GlassBottomNav(glassStyle: glassStyle),
    );
  }

  Map<String, _UsageMetrics> _buildUsageMetrics(AppState state) {
    final Map<String, _UsageMetrics> metrics = <String, _UsageMetrics>{};
    final double scale = _rangeScale(_selectedRange);
    final Map<String, int> aggregatedSeconds = <String, int>{};
    final Map<String, int> aggregatedSessions = <String, int>{};

    for (final DailyAnalytics day in state.weeklyAnalytics) {
      day.perApp.forEach((String appId, DailyAppStats stats) {
        aggregatedSeconds.update(
          appId,
          (int value) => value + stats.secondsSpent,
          ifAbsent: () => stats.secondsSpent,
        );
        aggregatedSessions.update(
          appId,
          (int value) => value + stats.sessions,
          ifAbsent: () => stats.sessions,
        );
      });
    }

    final Map<String, _AppVisual> catalogById = <String, _AppVisual>{
      for (final _AppVisual visual in _catalog) visual.id: visual,
    };

    for (final _AppVisual visual in _catalog) {
      final int seed = _mockSeedFor(visual.id);
      final int seconds =
          aggregatedSeconds[visual.id] ??
          ((36 + ((seed * 19) % 120)) * 60 * scale).round();
      final int sessions =
          aggregatedSessions[visual.id] ??
          math.max(4, (8 + ((seed * 7) % 22) * scale).round());
      metrics[visual.id] = _UsageMetrics(
        visual: visual,
        secondsSpent: seconds,
        sessions: sessions,
      );
    }

    for (final TargetApp app in state.selectedTrackedApps) {
      if (catalogById.containsKey(app.meta.id)) {
        continue;
      }
      final int seed = _mockSeedFor(app.meta.id);
      metrics[app.meta.id] = _UsageMetrics(
        visual: _AppVisual(
          id: app.meta.id,
          name: app.meta.displayName,
          icon: app.meta.iconData,
          tint: app.meta.color,
          accent: Colors.white,
        ),
        secondsSpent:
            aggregatedSeconds[app.meta.id] ??
            ((28 + ((seed * 13) % 100)) * 60 * scale).round(),
        sessions:
            aggregatedSessions[app.meta.id] ??
            math.max(4, (6 + ((seed * 5) % 18) * scale).round()),
      );
    }

    return metrics;
  }

  List<_UsageEntry> _buildUsageEntries(Map<String, _UsageMetrics> usageMap) {
    final List<_UsageMetrics> metrics = usageMap.values.toList()
      ..sort(
        (_UsageMetrics a, _UsageMetrics b) =>
            b.secondsSpent.compareTo(a.secondsSpent),
      );

    final int topSeconds = metrics.isEmpty ? 1 : metrics.first.secondsSpent;
    return metrics
        .map(
          (_UsageMetrics metric) => _UsageEntry(
            visual: metric.visual,
            secondsSpent: metric.secondsSpent,
            sessions: metric.sessions,
            progress: (metric.secondsSpent / math.max(topSeconds, 1))
                .clamp(0, 1)
                .toDouble(),
          ),
        )
        .toList(growable: false);
  }

  List<_ChartDatum> _buildChartData(
    AppState state,
    Map<String, _UsageMetrics> usageMap,
  ) {
    const List<String> labels = <String>[
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ];
    final double scale = _rangeScale(_selectedRange);
    final List<_ChartDatum> data = <_ChartDatum>[];
    final List<DailyAnalytics> week = state.weeklyAnalytics;

    for (int index = 0; index < labels.length; index++) {
      final DailyAnalytics? day = index < week.length ? week[index] : null;
      final int value;
      if (day != null) {
        if (_selectedAppId == 'all') {
          value = _scaledCount(
            math.max(day.totalSessions, day.totalOpenedCount),
            scale,
          );
        } else {
          final DailyAppStats stats =
              day.perApp[_selectedAppId] ?? DailyAppStats();
          value = _scaledCount(
            math.max(stats.sessions, stats.openedCount),
            scale,
          );
        }
      } else {
        value = 0;
      }

      final int fallbackSeed = _mockSeedFor(
        '${_selectedAppId}_${labels[index]}',
      );
      final int fallback = 6 + (fallbackSeed % 22);
      data.add(
        _ChartDatum(
          label: labels[index],
          value: math.max(value, fallback),
          highlight: labels[index] == labels[DateTime.now().weekday - 1],
        ),
      );
    }

    final bool hasRealData = data.any((_ChartDatum item) => item.value > 0);
    if (hasRealData) {
      return data;
    }

    final _UsageMetrics? metric = _selectedAppId == 'all'
        ? null
        : usageMap[_selectedAppId];
    return List<_ChartDatum>.generate(labels.length, (int index) {
      final int seed = _mockSeedFor('${metric?.visual.id ?? 'all'}_$index');
      return _ChartDatum(
        label: labels[index],
        value: 7 + (seed % 24),
        highlight: index == 4,
      );
    });
  }

  _FocusScoreSnapshot _buildFocusScore(
    AppState state,
    Map<String, _UsageMetrics> usageMap,
  ) {
    final int totalUsageMinutes = usageMap.values.fold<int>(
      0,
      (int sum, _UsageMetrics item) => sum + (item.secondsSpent ~/ 60),
    );
    final int blockedAttempts = _scaledCount(
      state.scrollBlockedCount + state.totalStats.totalUnlocks,
      _rangeScale(_selectedRange),
    );
    final int successfulBlocks = _scaledCount(
      state.scrollBlockedCount,
      _rangeScale(_selectedRange),
    );
    final int totalScrolls = _scaledCount(
      math.max(_totalScrollCount, state.totalStats.totalSessions),
      _rangeScale(_selectedRange),
    );
    final int allowedUsageMinutes = math.max(
      totalUsageMinutes,
      state.totalStats.totalSecondsSpent ~/ 60,
    );
    final int distractionMinutes = math.min(
      allowedUsageMinutes,
      ((allowedUsageMinutes * 0.42) + (state.totalStats.totalUnlocks * 2.5))
          .round(),
    );
    final double goalAdherence =
        (1 - ((totalScrolls / 480) * 0.45 + (distractionMinutes / 90) * 0.55))
            .clamp(0.0, 1.0);

    final double blockEfficiency =
        successfulBlocks / math.max(blockedAttempts, 1);
    final double scrollPenalty = math.min(totalScrolls / 300.0, 1.0);
    final double usagePenalty = math.min(allowedUsageMinutes / 180.0, 1.0);
    final double distractionPenalty = math.min(distractionMinutes / 60.0, 1.0);

    final double rawScore =
        100 -
        (25 * scrollPenalty) -
        (20 * usagePenalty) -
        (25 * distractionPenalty) +
        (15 * blockEfficiency) +
        (15 * goalAdherence);
    final int score = rawScore.round().clamp(0, 100);

    if (score >= 90) {
      return const _FocusScoreSnapshot(
        score: 90,
        subtitle: 'Excellent discipline',
        tone: Color(0xFF27E8A7),
      ).copyWith(score: score);
    }
    if (score >= 75) {
      return const _FocusScoreSnapshot(
        score: 75,
        subtitle: 'Good momentum',
        tone: Color(0xFF5FB8FF),
      ).copyWith(score: score);
    }
    if (score >= 60) {
      return const _FocusScoreSnapshot(
        score: 60,
        subtitle: 'Needs improvement',
        tone: Color(0xFFFFC15D),
      ).copyWith(score: score);
    }
    return const _FocusScoreSnapshot(
      score: 0,
      subtitle: 'High distraction detected',
      tone: Color(0xFFFF6B7A),
    ).copyWith(score: score);
  }

  List<_AppVisual> _blockedAppsForCard(
    AppState state,
    List<_UsageEntry> entries,
  ) {
    final List<_AppVisual> tracked = state.selectedTrackedApps
        .map(_toVisualFromTargetApp)
        .toList(growable: false);
    if (tracked.isNotEmpty) {
      return tracked.take(4).toList(growable: false);
    }
    return entries
        .take(4)
        .map((_UsageEntry item) => item.visual)
        .toList(growable: false);
  }

  static _AppVisual _toVisualFromTargetApp(TargetApp app) {
    final _AppVisual? catalogMatch = _catalog.cast<_AppVisual?>().firstWhere(
      (_AppVisual? visual) => visual?.id == app.meta.id,
      orElse: () => null,
    );
    return catalogMatch ??
        _AppVisual(
          id: app.meta.id,
          name: app.meta.displayName,
          icon: app.meta.iconData,
          tint: app.meta.color,
          accent: Colors.white,
        );
  }

  static double _rangeScale(_TimeRange range) {
    switch (range) {
      case _TimeRange.day:
        return 0.28;
      case _TimeRange.week:
        return 1.0;
      case _TimeRange.month:
        return 1.85;
      case _TimeRange.year:
        return 2.7;
    }
  }

  static int _scaledCount(int value, double factor) {
    return math.max(0, (value * factor).round());
  }

  static int _mockSeedFor(String value) {
    return value.codeUnits.fold<int>(0, (int sum, int code) => sum + code);
  }
}

enum _TimeRange { day, week, month, year }

class _PageHeader extends StatelessWidget {
  const _PageHeader({required this.glassStyle, required this.onBack});

  final _AdaptiveGlassStyle glassStyle;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            GlassIconButton(
              icon: Icons.arrow_back_ios_new_rounded,
              glassStyle: glassStyle,
              onTap: onBack,
            ),
            const Spacer(),
            GlassCard(
              glassStyle: glassStyle,
              radius: 18,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    Icons.auto_graph_rounded,
                    color: Color(0xFFB8C3D9),
                    size: 16,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'This week',
                    style: TextStyle(
                      color: Color(0xFFDDE5F7),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        const Text(
          'Activity',
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Track focus health, blocking wins, and distracting app patterns.',
          style: TextStyle(color: Color(0xFF9AA6BF), fontSize: 12, height: 1.4),
        ),
      ],
    );
  }
}

class _FocusScoreCard extends StatelessWidget {
  const _FocusScoreCard({required this.snapshot, required this.glassStyle});

  final _FocusScoreSnapshot snapshot;
  final _AdaptiveGlassStyle glassStyle;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      glassStyle: glassStyle,
      radius: 28,
      glowColor: snapshot.tone,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Focus Score',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Performance',
            style: TextStyle(color: Color(0xFF909CB1), fontSize: 12),
          ),
          const SizedBox(height: 14),
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  snapshot.tone.withValues(alpha: 0.30),
                  snapshot.tone.withValues(alpha: 0.04),
                ],
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: snapshot.tone.withValues(alpha: 0.20),
                  blurRadius: 24,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(
                      begin: 0,
                      end: snapshot.score.toDouble(),
                    ),
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeOutCubic,
                    builder:
                        (BuildContext context, double value, Widget? child) {
                          return Text(
                            value.round().toString(),
                            style: TextStyle(
                              color: snapshot.tone,
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              height: 0.9,
                              letterSpacing: -1,
                            ),
                          );
                        },
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 4),
                    child: Text(
                      '/100',
                      style: TextStyle(
                        color: Color(0xFF93A0B8),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            snapshot.subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: snapshot.tone.withValues(alpha: 0.95),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class BlockedAppsCard extends StatelessWidget {
  const BlockedAppsCard({
    super.key,
    required this.blockedApps,
    required this.totalCount,
    required this.glassStyle,
  });

  final List<_AppVisual> blockedApps;
  final int totalCount;
  final _AdaptiveGlassStyle glassStyle;

  @override
  Widget build(BuildContext context) {
    final int extra = math.max(0, totalCount - 3);
    final List<_AppVisual> visibleApps = blockedApps
        .take(3)
        .toList(growable: false);

    return GlassCard(
      glassStyle: glassStyle,
      radius: 28,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Blocked Apps',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$totalCount protected',
            style: const TextStyle(color: Color(0xFF909CB1), fontSize: 12),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 40,
            child: Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                for (int index = 0; index < visibleApps.length; index++)
                  Positioned(
                    left: index * 20,
                    child: _OverlapAppIcon(
                      visual: visibleApps[index],
                      glassStyle: glassStyle,
                    ),
                  ),
                if (extra > 0)
                  Positioned(
                    left: visibleApps.length * 20,
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF272B38),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.14),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '+$extra',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class WeeklyScrollChart extends StatelessWidget {
  const WeeklyScrollChart({
    super.key,
    required this.glassStyle,
    required this.selectedAppId,
    required this.chartData,
    required this.apps,
    required this.onChanged,
  });

  final _AdaptiveGlassStyle glassStyle;
  final String selectedAppId;
  final List<_ChartDatum> chartData;
  final List<_AppVisual> apps;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final double maxY = math.max<double>(
      12,
      chartData.fold<double>(
            0,
            (double max, _ChartDatum item) =>
                math.max(max, item.value.toDouble()),
          ) *
          1.2,
    );
    final double interval = math.max(4, (maxY / 3).roundToDouble());

    return GlassCard(
      glassStyle: glassStyle,
      radius: 30,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Expanded(
                child: Text(
                  'Scroll Count',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _ChartFilterPill(
                value: selectedAppId,
                apps: apps,
                onChanged: onChanged,
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Mon to Sun activity for the selected app filter',
            style: TextStyle(color: Color(0xFF98A5BC), fontSize: 12),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 250,
            child: BarChart(
              swapAnimationDuration: const Duration(milliseconds: 450),
              swapAnimationCurve: Curves.easeOutCubic,
              BarChartData(
                minY: 0,
                maxY: maxY,
                alignment: BarChartAlignment.spaceAround,
                gridData: FlGridData(
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (double value) {
                    return FlLine(
                      color: Colors.white.withValues(alpha: 0.08),
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBorderRadius: BorderRadius.circular(14),
                    tooltipPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    tooltipMargin: 8,
                    getTooltipColor: (_) => const Color(0xFF1E2432),
                    getTooltipItem:
                        (
                          BarChartGroupData group,
                          int groupIndex,
                          BarChartRodData rod,
                          int rodIndex,
                        ) {
                          return BarTooltipItem(
                            '${chartData[group.x].label}\n${rod.toY.round()} scrolls',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              height: 1.35,
                            ),
                          );
                        },
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      interval: interval,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            color: Color(0xFF8490A8),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        final int index = value.toInt();
                        if (index < 0 || index >= chartData.length) {
                          return const SizedBox.shrink();
                        }
                        final bool highlight = chartData[index].highlight;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            chartData[index].label,
                            style: TextStyle(
                              color: highlight
                                  ? Colors.white
                                  : const Color(0xFF7D879C),
                              fontSize: 11,
                              fontWeight: highlight
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: List<BarChartGroupData>.generate(chartData.length, (
                  int index,
                ) {
                  final _ChartDatum datum = chartData[index];
                  final List<Color> gradient = datum.highlight
                      ? const <Color>[Color(0xFF25F4EE), Color(0xFF4696FF)]
                      : const <Color>[Color(0xFFFF4D8D), Color(0xFFFF7A45)];
                  return BarChartGroupData(
                    x: index,
                    barRods: <BarChartRodData>[
                      BarChartRodData(
                        toY: datum.value.toDouble(),
                        width: 18,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(8),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: gradient,
                        ),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: maxY,
                          color: Colors.white.withValues(alpha: 0.04),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TimeRangeSelector extends StatelessWidget {
  const TimeRangeSelector({
    super.key,
    required this.value,
    required this.onChanged,
    required this.glassStyle,
  });

  final _TimeRange value;
  final ValueChanged<_TimeRange> onChanged;
  final _AdaptiveGlassStyle glassStyle;

  @override
  Widget build(BuildContext context) {
    if (glassStyle.isIos) {
      return GlassCard(
        glassStyle: glassStyle,
        radius: 24,
        padding: const EdgeInsets.all(8),
        child: CupertinoSlidingSegmentedControl<_TimeRange>(
          backgroundColor: const Color(0x30293341),
          thumbColor: const Color(0xFF3C7CFF),
          groupValue: value,
          onValueChanged: (_TimeRange? next) {
            if (next != null) {
              onChanged(next);
            }
          },
          children: const <_TimeRange, Widget>{
            _TimeRange.day: _SegmentText(label: 'Day'),
            _TimeRange.week: _SegmentText(label: 'Week'),
            _TimeRange.month: _SegmentText(label: 'Month'),
            _TimeRange.year: _SegmentText(label: 'Year'),
          },
        ),
      );
    }

    return GlassCard(
      glassStyle: glassStyle,
      radius: 24,
      padding: const EdgeInsets.all(6),
      child: Row(
        children: _TimeRange.values
            .map((_TimeRange range) {
              final bool selected = range == value;
              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: selected
                        ? const LinearGradient(
                            colors: <Color>[
                              Color(0xFF3A86FF),
                              Color(0xFF246BFF),
                            ],
                          )
                        : null,
                    boxShadow: selected
                        ? <BoxShadow>[
                            BoxShadow(
                              color: const Color(
                                0xFF3A86FF,
                              ).withValues(alpha: 0.22),
                              blurRadius: 18,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () => onChanged(range),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          switch (range) {
                            _TimeRange.day => 'Day',
                            _TimeRange.week => 'Week',
                            _TimeRange.month => 'Month',
                            _TimeRange.year => 'Year',
                          },
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: selected
                                ? Colors.white
                                : const Color(0xFF7F8AA1),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            })
            .toList(growable: false),
      ),
    );
  }
}

class AppUsageTile extends StatelessWidget {
  const AppUsageTile({
    super.key,
    required this.entry,
    required this.glassStyle,
  });

  final _UsageEntry entry;
  final _AdaptiveGlassStyle glassStyle;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Colors.white.withValues(alpha: glassStyle.isIos ? 0.05 : 0.04),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _AppIconBadge(visual: entry.visual),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          entry.visual.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        _formatDuration(entry.secondsSpent),
                        style: const TextStyle(
                          color: Color(0xFFAAB5CB),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: SizedBox(
                      height: 8,
                      child: Stack(
                        children: <Widget>[
                          Container(
                            color: Colors.white.withValues(alpha: 0.07),
                          ),
                          TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: 0, end: entry.progress),
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeOutCubic,
                            builder:
                                (
                                  BuildContext context,
                                  double value,
                                  Widget? child,
                                ) {
                                  return FractionallySizedBox(
                                    widthFactor: value,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: <Color>[
                                            entry.visual.tint,
                                            entry.visual.accent,
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${entry.sessions} sessions',
                    style: const TextStyle(
                      color: Color(0xFF7F8AA1),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassBottomNav extends StatelessWidget {
  const _GlassBottomNav({required this.glassStyle});

  final _AdaptiveGlassStyle glassStyle;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(18, 0, 18, 12),
      child: GlassCard(
        glassStyle: glassStyle,
        radius: 26,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: <Widget>[
            Expanded(
              child: _BottomNavItem(
                icon: Icons.home_outlined,
                selected: false,
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
                  );
                },
              ),
            ),
            Expanded(
              child: _BottomNavItem(
                icon: Icons.auto_graph_rounded,
                label: 'Activity',
                selected: true,
                onTap: () {},
              ),
            ),
            Expanded(
              child: _BottomNavItem(
                icon: Icons.block_rounded,
                label: 'Blocked',
                selected: false,
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute<void>(
                      builder: (_) => const BlockedAppsScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    required this.glassStyle,
    this.padding,
    this.radius = 24,
    this.glowColor,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double radius;
  final Color? glowColor;
  final _AdaptiveGlassStyle glassStyle;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: glassStyle.blurSigma,
          sigmaY: glassStyle.blurSigma,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[glassStyle.surface, glassStyle.surfaceSecondary],
            ),
            border: Border.all(color: glassStyle.border),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: glassStyle.shadowOpacity),
                blurRadius: glassStyle.shadowBlur,
                offset: const Offset(0, 12),
              ),
              if (glowColor != null)
                BoxShadow(
                  color: glowColor!.withValues(alpha: glassStyle.glowOpacity),
                  blurRadius: 28,
                  spreadRadius: 1,
                ),
            ],
          ),
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(radius),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[
                        Colors.white.withValues(
                          alpha: glassStyle.topHighlightOpacity,
                        ),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              if (glassStyle.isIos)
                Positioned(
                  left: 18,
                  top: 10,
                  right: 18,
                  child: IgnorePointer(
                    child: Container(
                      height: 18,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: <Color>[
                            Colors.white.withValues(alpha: 0.18),
                            Colors.white.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              Padding(padding: padding ?? EdgeInsets.zero, child: child),
            ],
          ),
        ),
      ),
    );
  }
}

class GlassIconButton extends StatelessWidget {
  const GlassIconButton({
    super.key,
    required this.icon,
    required this.glassStyle,
    required this.onTap,
  });

  final IconData icon;
  final _AdaptiveGlassStyle glassStyle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 46,
      height: 46,
      child: GlassCard(
        glassStyle: glassStyle,
        radius: 16,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Center(child: Icon(icon, color: Colors.white, size: 18)),
          ),
        ),
      ),
    );
  }
}

class _ChartFilterPill extends StatelessWidget {
  const _ChartFilterPill({
    required this.value,
    required this.apps,
    required this.onChanged,
  });

  final String value;
  final List<_AppVisual> apps;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: const Color(0xFFE7EEFF),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF2E63F5),
            ),
            dropdownColor: const Color(0xFFEEF3FF),
            borderRadius: BorderRadius.circular(18),
            style: const TextStyle(
              color: Color(0xFF2E63F5),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            items: <DropdownMenuItem<String>>[
              const DropdownMenuItem<String>(
                value: 'all',
                child: Text('All Apps'),
              ),
              ...apps.map(
                (_AppVisual visual) => DropdownMenuItem<String>(
                  value: visual.id,
                  child: Text(visual.name),
                ),
              ),
            ],
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.icon,
    required this.selected,
    required this.onTap,
    this.label,
  });

  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      height: 46,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: selected
            ? const LinearGradient(
                colors: <Color>[Color(0xFF3D88FF), Color(0xFF2567FF)],
              )
            : null,
        boxShadow: selected
            ? <BoxShadow>[
                BoxShadow(
                  color: const Color(0xFF2E63F5).withValues(alpha: 0.28),
                  blurRadius: 20,
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                icon,
                color: selected ? Colors.white : const Color(0xFF7E899E),
                size: 20,
              ),
              if (label != null) ...<Widget>[
                const SizedBox(width: 8),
                Text(
                  label!,
                  style: TextStyle(
                    color: selected ? Colors.white : const Color(0xFF7E899E),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _OverlapAppIcon extends StatelessWidget {
  const _OverlapAppIcon({required this.visual, required this.glassStyle});

  final _AppVisual visual;
  final _AdaptiveGlassStyle glassStyle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF161A25),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: visual.tint.withValues(alpha: glassStyle.glowOpacity),
            blurRadius: 16,
          ),
        ],
      ),
      child: Icon(visual.icon, color: visual.tint, size: 18),
    );
  }
}

class _AppIconBadge extends StatelessWidget {
  const _AppIconBadge({required this.visual});

  final _AppVisual visual;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            visual.tint.withValues(alpha: 0.95),
            visual.accent.withValues(alpha: 0.95),
          ],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(color: visual.tint.withValues(alpha: 0.24), blurRadius: 18),
        ],
      ),
      alignment: Alignment.center,
      child: Icon(
        visual.icon,
        color: visual.id == 'snapchat' ? Colors.black : Colors.white,
        size: 18,
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(color: Color(0xFF8E9BB2), fontSize: 12),
        ),
      ],
    );
  }
}

class _SegmentText extends StatelessWidget {
  const _SegmentText({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _BackgroundOrb extends StatelessWidget {
  const _BackgroundOrb({required this.size, required this.colors});

  final double size;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: colors),
          ),
        ),
      ),
    );
  }
}

class _AdaptiveGlassStyle {
  const _AdaptiveGlassStyle({
    required this.isIos,
    required this.blurSigma,
    required this.surface,
    required this.surfaceSecondary,
    required this.border,
    required this.topHighlightOpacity,
    required this.shadowOpacity,
    required this.shadowBlur,
    required this.glowOpacity,
  });

  final bool isIos;
  final double blurSigma;
  final Color surface;
  final Color surfaceSecondary;
  final Color border;
  final double topHighlightOpacity;
  final double shadowOpacity;
  final double shadowBlur;
  final double glowOpacity;

  factory _AdaptiveGlassStyle.of(BuildContext context) {
    final TargetPlatform platform = defaultTargetPlatform;
    final bool isIos = platform == TargetPlatform.iOS;
    return _AdaptiveGlassStyle(
      isIos: isIos,
      blurSigma: isIos ? 28 : 18,
      surface: isIos ? const Color(0x30F4F7FF) : const Color(0x24F3F6FF),
      surfaceSecondary: isIos
          ? const Color(0x14AEB8D2)
          : const Color(0x121C2232),
      border: Colors.white.withValues(alpha: isIos ? 0.18 : 0.10),
      topHighlightOpacity: isIos ? 0.14 : 0.08,
      shadowOpacity: isIos ? 0.22 : 0.30,
      shadowBlur: isIos ? 28 : 20,
      glowOpacity: isIos ? 0.18 : 0.12,
    );
  }
}

class _AppVisual {
  const _AppVisual({
    required this.id,
    required this.name,
    required this.icon,
    required this.tint,
    required this.accent,
  });

  final String id;
  final String name;
  final IconData icon;
  final Color tint;
  final Color accent;
}

class _UsageMetrics {
  const _UsageMetrics({
    required this.visual,
    required this.secondsSpent,
    required this.sessions,
  });

  final _AppVisual visual;
  final int secondsSpent;
  final int sessions;
}

class _UsageEntry {
  const _UsageEntry({
    required this.visual,
    required this.secondsSpent,
    required this.sessions,
    required this.progress,
  });

  final _AppVisual visual;
  final int secondsSpent;
  final int sessions;
  final double progress;
}

class _ChartDatum {
  const _ChartDatum({
    required this.label,
    required this.value,
    required this.highlight,
  });

  final String label;
  final int value;
  final bool highlight;
}

class _FocusScoreSnapshot {
  const _FocusScoreSnapshot({
    required this.score,
    required this.subtitle,
    required this.tone,
  });

  final int score;
  final String subtitle;
  final Color tone;

  _FocusScoreSnapshot copyWith({int? score, String? subtitle, Color? tone}) {
    return _FocusScoreSnapshot(
      score: score ?? this.score,
      subtitle: subtitle ?? this.subtitle,
      tone: tone ?? this.tone,
    );
  }
}

String _formatDuration(int seconds) {
  final int safeSeconds = math.max(0, seconds);
  final int hours = safeSeconds ~/ 3600;
  final int minutes = (safeSeconds % 3600) ~/ 60;

  if (hours > 0) {
    if (minutes > 0) {
      return '$hours hr $minutes min';
    }
    return '$hours hr';
  }

  if (minutes > 0) {
    return '$minutes min';
  }

  return '${safeSeconds}s';
}
