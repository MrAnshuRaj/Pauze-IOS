import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/analytics_models.dart';
import '../models/target_app.dart';
import '../providers/app_state.dart';
import '../widgets/stat_card.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _selectedAppId = 'all';

  @override
  Widget build(BuildContext context) {
    final AppState state = context.watch<AppState>();
    final List<DailyAnalytics> week = state.weeklyAnalytics;

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          _filters(),
          const SizedBox(height: 12),
          _chartCard(context, week),
          const SizedBox(height: 14),
          StatCard(
            title: 'Total Unlocks',
            value: state.totalStats.totalUnlocks.toString(),
            icon: Icons.lock_open_rounded,
            color: const Color(0xFF2E7D32),
          ),
          const SizedBox(height: 10),
          StatCard(
            title: 'Total Sessions',
            value: state.totalStats.totalSessions.toString(),
            icon: Icons.timer_outlined,
            color: const Color(0xFF0277BD),
          ),
          const SizedBox(height: 10),
          StatCard(
            title: 'Total Time Spent',
            value: state.formatDuration(state.totalStats.totalSecondsSpent),
            icon: Icons.hourglass_bottom_rounded,
            color: const Color(0xFF8E24AA),
          ),
          const SizedBox(height: 10),
          StatCard(
            title: 'Apps Opened Count',
            value: state.totalStats.totalAppsOpened.toString(),
            icon: Icons.open_in_new_rounded,
            color: const Color(0xFFEF6C00),
          ),
        ],
      ),
    );
  }

  Widget _filters() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: <Widget>[
            const Icon(Icons.filter_alt_outlined),
            const SizedBox(width: 10),
            const Text('App'),
            const SizedBox(width: 14),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _selectedAppId,
                items: <DropdownMenuItem<String>>[
                  const DropdownMenuItem<String>(
                    value: 'all',
                    child: Text('All Apps'),
                  ),
                  ...TargetApp.values.map(
                    (TargetApp app) => DropdownMenuItem<String>(
                      value: app.meta.id,
                      child: Text(app.meta.displayName),
                    ),
                  ),
                ],
                onChanged: (String? value) {
                  if (value == null) {
                    return;
                  }
                  setState(() => _selectedAppId = value);
                },
                decoration: const InputDecoration(
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chartCard(BuildContext context, List<DailyAnalytics> week) {
    final List<_BarItem> barItems = <_BarItem>[];
    for (int i = 0; i < week.length; i++) {
      final DailyAnalytics day = week[i];
      final _Metric metric = _extractMetric(day);
      barItems.add(_BarItem(
        x: i,
        dayLabel: _weekdayLabel(day.dateKey),
        unlocks: metric.unlocks,
        sessions: metric.sessions,
      ));
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Weekly Activity (Mon-Sun)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'Blue = sessions, green = unlocks',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 230,
              child: BarChart(
                BarChartData(
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(
                    show: true,
                    drawVerticalLine: false,
                  ),
                  groupsSpace: 16,
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          if (value % 2 != 0) {
                            return const SizedBox.shrink();
                          }
                          return Text(value.toInt().toString());
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final int idx = value.toInt();
                          if (idx < 0 || idx >= barItems.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(barItems[idx].dayLabel),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: barItems.map(( _BarItem item) {
                    return BarChartGroupData(
                      x: item.x,
                      barsSpace: 4,
                      barRods: <BarChartRodData>[
                        BarChartRodData(
                          toY: item.sessions.toDouble(),
                          width: 9,
                          borderRadius: BorderRadius.circular(4),
                          color: const Color(0xFF1E88E5),
                        ),
                        BarChartRodData(
                          toY: item.unlocks.toDouble(),
                          width: 9,
                          borderRadius: BorderRadius.circular(4),
                          color: const Color(0xFF43A047),
                        ),
                      ],
                    );
                  }).toList(growable: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _Metric _extractMetric(DailyAnalytics day) {
    if (_selectedAppId == 'all') {
      return _Metric(unlocks: day.totalUnlocks, sessions: day.totalSessions);
    }

    final DailyAppStats stats = day.perApp[_selectedAppId] ?? DailyAppStats();
    return _Metric(unlocks: stats.unlocks, sessions: stats.sessions);
  }

  String _weekdayLabel(String dateKey) {
    final List<String> split = dateKey.split('-');
    if (split.length != 3) {
      return dateKey;
    }
    final DateTime date = DateTime(
      int.parse(split[0]),
      int.parse(split[1]),
      int.parse(split[2]),
    );

    const List<String> labels = <String>['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return labels[date.weekday - 1];
  }
}

class _Metric {
  const _Metric({required this.unlocks, required this.sessions});

  final int unlocks;
  final int sessions;
}

class _BarItem {
  const _BarItem({
    required this.x,
    required this.dayLabel,
    required this.unlocks,
    required this.sessions,
  });

  final int x;
  final String dayLabel;
  final int unlocks;
  final int sessions;
}

