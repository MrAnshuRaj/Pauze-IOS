import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../../models/analytics_models.dart';
import '../../../models/target_app.dart';
import '../../../providers/app_state.dart';

enum BrainState { zen, okay, drained, fried, brainrot, future, empty }

class DailyBrainStats {
  const DailyBrainStats({
    required this.date,
    required this.brainLoad,
    required this.timeSpent,
    required this.pickups,
    required this.notifications,
    required this.appStats,
    required this.brainState,
  });

  final DateTime date;
  final int brainLoad;
  final Duration timeSpent;
  final int pickups;
  final int notifications;
  final Map<String, AppBrainStats> appStats;
  final BrainState brainState;

  // Temporary backward compatibility while older dashboard helpers still
  // reference appChecks.
  int get appChecks => pickups;
}

class AppBrainStats {
  const AppBrainStats({
    required this.appName,
    required this.appId,
    required this.brainLoad,
    required this.timeSpent,
    required this.pickups,
    required this.notifications,
  });

  final String appName;
  final String appId;
  final int brainLoad;
  final Duration timeSpent;
  final int pickups;
  final int notifications;

  // Temporary backward compatibility while older dashboard helpers still
  // reference appChecks.
  int get appChecks => pickups;
}

class BrainStatsProvider {
  const BrainStatsProvider({this.appState});

  final AppState? appState;

  Future<DailyBrainStats> loadDailyBrainStats(DateTime date) async {
    final DateTime normalized = normalizeDate(date);
    final DailyBrainStats? existing = _loadFromExistingState(normalized);
    if (existing != null) {
      return existing;
    }

    // TODO: Replace fallback sample data with DeviceActivity data on iOS.
    // TODO: Map DeviceActivity time, pickups, notifications into Brain Load.
    return generateSampleStats(normalized);
  }

  Future<Map<DateTime, DailyBrainStats>> loadMonthStats(DateTime month) async {
    final DateTime firstDay = DateTime(month.year, month.month);
    final int daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final Map<DateTime, DailyBrainStats> results =
        <DateTime, DailyBrainStats>{};

    for (int day = 1; day <= daysInMonth; day++) {
      final DateTime date = DateTime(firstDay.year, firstDay.month, day);
      results[date] = await loadDailyBrainStats(date);
    }

    return results;
  }

  Future<DailyBrainStats> loadTodayStats() {
    return loadDailyBrainStats(DateTime.now());
  }

  DailyBrainStats? _loadFromExistingState(DateTime normalized) {
    final AppState? state = appState;
    if (state == null) {
      return null;
    }

    final String dateKey = _dateKey(normalized);
    DailyAnalytics? dayAnalytics;
    for (final DailyAnalytics entry in state.weeklyAnalytics) {
      if (entry.dateKey == dateKey) {
        dayAnalytics = entry;
        break;
      }
    }

    if (dayAnalytics == null && !isSameDate(normalized, DateTime.now())) {
      return null;
    }

    final int secondsSpent =
        dayAnalytics?.totalSeconds ?? state.totalStats.totalSecondsSpent;
    final int pickups =
        dayAnalytics?.totalOpenedCount ?? state.totalStats.totalAppsOpened;
    final int notifications = 0;
    final Map<String, AppBrainStats> apps = dayAnalytics != null
        ? _buildTrackedAppsFromAnalytics(dayAnalytics)
        : splitAcrossApps(
            totalBrainLoad: calculateBrainLoad(
              timeSpentMinutes: secondsSpent ~/ 60,
              pickups: pickups,
              notifications: notifications,
              limitHits: state.scrollBlockedCount,
              completedBreaks: 0,
            ),
            totalMinutes: secondsSpent ~/ 60,
            totalPickups: pickups,
            totalNotifications: notifications,
          );

    final int brainLoad = calculateBrainLoad(
      timeSpentMinutes: secondsSpent ~/ 60,
      pickups: pickups,
      notifications: notifications,
      limitHits: state.scrollBlockedCount,
      completedBreaks: 0,
    );

    if (secondsSpent == 0 &&
        pickups == 0 &&
        apps.values.every((AppBrainStats app) => app.brainLoad == 0)) {
      return null;
    }

    return DailyBrainStats(
      date: normalized,
      // On iOS, Apple APIs do not provide exact Reels/Shorts scroll counts.
      // Brain Load is computed from available metrics such as time spent,
      // pickups, notifications, limit hits, and completed breaks.
      brainLoad: brainLoad,
      timeSpent: Duration(seconds: secondsSpent),
      pickups: pickups,
      notifications: notifications,
      appStats: apps,
      brainState: getBrainStateFromLoad(brainLoad),
    );
  }

  Map<String, AppBrainStats> _buildTrackedAppsFromAnalytics(
    DailyAnalytics dayAnalytics,
  ) {
    const List<String> orderedIds = <String>[
      'youtube',
      'instagram',
      'snapchat',
    ];
    final Map<String, DailyAppStats> perApp = dayAnalytics.perApp;
    final Map<String, AppBrainStats> result = <String, AppBrainStats>{};

    for (final String id in orderedIds) {
      final DailyAppStats stats = perApp[id] ?? DailyAppStats();
      final TargetApp? app = targetAppFromId(id);
      final int seconds = stats.secondsSpent;
      final int checks = stats.openedCount > 0
          ? stats.openedCount
          : stats.sessions;
      result[id] = AppBrainStats(
        appName: app?.meta.displayName ?? _displayNameForAppId(id),
        appId: id,
        brainLoad: calculateBrainLoad(
          timeSpentMinutes: seconds ~/ 60,
          pickups: checks,
          notifications: 0,
          limitHits: 0,
          completedBreaks: 0,
        ),
        timeSpent: Duration(seconds: seconds),
        pickups: checks,
        notifications: 0,
      );
    }

    return result;
  }
}

int calculateBrainLoad({
  required int timeSpentMinutes,
  required int pickups,
  required int notifications,
  required int limitHits,
  required int completedBreaks,
}) {
  final double score =
      (timeSpentMinutes * 1.0) +
      (pickups * 3.0) +
      (notifications * 1.0) +
      (limitHits * 20.0) -
      (completedBreaks * 10.0);

  return score.clamp(0, 9999).round();
}

BrainState getBrainStateFromLoad(int score) {
  if (score <= 30) {
    return BrainState.zen;
  }
  if (score <= 70) {
    return BrainState.okay;
  }
  if (score <= 120) {
    return BrainState.drained;
  }
  if (score <= 200) {
    return BrainState.fried;
  }
  return BrainState.brainrot;
}

DailyBrainStats generateSampleStats(DateTime date) {
  final DateTime normalized = normalizeDate(date);
  final DateTime today = normalizeDate(DateTime.now());

  if (normalized.isAfter(today)) {
    return DailyBrainStats(
      date: normalized,
      brainLoad: 0,
      timeSpent: Duration.zero,
      pickups: 0,
      notifications: 0,
      appStats: const <String, AppBrainStats>{},
      brainState: BrainState.future,
    );
  }

  if (normalized.year == 2026 && normalized.month == 4 && normalized.day == 2) {
    return DailyBrainStats(
      date: normalized,
      brainLoad: 18,
      timeSpent: const Duration(minutes: 12),
      pickups: 3,
      notifications: 4,
      appStats: const <String, AppBrainStats>{
        'youtube': AppBrainStats(
          appName: 'YouTube',
          appId: 'youtube',
          brainLoad: 6,
          timeSpent: Duration(minutes: 4),
          pickups: 0,
          notifications: 0,
        ),
        'instagram': AppBrainStats(
          appName: 'Instagram',
          appId: 'instagram',
          brainLoad: 8,
          timeSpent: Duration(minutes: 5),
          pickups: 1,
          notifications: 1,
        ),
        'snapchat': AppBrainStats(
          appName: 'Snapchat',
          appId: 'snapchat',
          brainLoad: 4,
          timeSpent: Duration(minutes: 3),
          pickups: 2,
          notifications: 3,
        ),
      },
      brainState: getBrainStateFromLoad(18),
    );
  }

  if (isSameDate(normalized, today)) {
    return DailyBrainStats(
      date: normalized,
      brainLoad: 135,
      timeSpent: const Duration(hours: 1, minutes: 23),
      pickups: 25,
      notifications: 11,
      appStats: const <String, AppBrainStats>{
        'youtube': AppBrainStats(
          appName: 'YouTube',
          appId: 'youtube',
          brainLoad: 45,
          timeSpent: Duration(minutes: 24),
          pickups: 7,
          notifications: 2,
        ),
        'instagram': AppBrainStats(
          appName: 'Instagram',
          appId: 'instagram',
          brainLoad: 67,
          timeSpent: Duration(minutes: 37),
          pickups: 10,
          notifications: 5,
        ),
        'snapchat': AppBrainStats(
          appName: 'Snapchat',
          appId: 'snapchat',
          brainLoad: 23,
          timeSpent: Duration(minutes: 22),
          pickups: 8,
          notifications: 4,
        ),
      },
      brainState: getBrainStateFromLoad(135),
    );
  }

  final int base = normalized.day;
  final int brainLoad = (base * 7) % 220;
  final int minutes = (base * 5) % 180;
  final int checks = (base * 3) % 30;
  final int notifications = (base * 2) % 20;
  final Map<String, AppBrainStats> appStats = splitAcrossApps(
    totalBrainLoad: brainLoad,
    totalMinutes: minutes,
    totalPickups: checks,
    totalNotifications: notifications,
  );

  return DailyBrainStats(
    date: normalized,
    brainLoad: brainLoad,
    timeSpent: Duration(minutes: minutes),
    pickups: checks,
    notifications: notifications,
    appStats: appStats,
    brainState: getBrainStateFromLoad(brainLoad),
  );
}

Map<String, AppBrainStats> splitAcrossApps({
  required int totalBrainLoad,
  required int totalMinutes,
  required int totalPickups,
  required int totalNotifications,
}) {
  const List<String> appIds = <String>['youtube', 'instagram', 'snapchat'];
  final List<int> loadWeights = <int>[33, 43, 24];
  final List<int> minuteWeights = <int>[35, 40, 25];
  final List<int> checkWeights = <int>[28, 38, 34];
  final List<int> notificationWeights = <int>[20, 35, 45];

  final List<int> loads = _splitValue(totalBrainLoad, loadWeights);
  final List<int> minutes = _splitValue(totalMinutes, minuteWeights);
  final List<int> pickups = _splitValue(totalPickups, checkWeights);
  final List<int> notifications = _splitValue(
    totalNotifications,
    notificationWeights,
  );

  final Map<String, AppBrainStats> result = <String, AppBrainStats>{};
  for (int index = 0; index < appIds.length; index++) {
    final String appId = appIds[index];
    result[appId] = AppBrainStats(
      appName: _displayNameForAppId(appId),
      appId: appId,
      brainLoad: loads[index],
      timeSpent: Duration(minutes: minutes[index]),
      pickups: pickups[index],
      notifications: notifications[index],
    );
  }

  return result;
}

List<int> _splitValue(int total, List<int> weights) {
  if (total <= 0) {
    return List<int>.filled(weights.length, 0);
  }

  final int weightTotal = weights.fold<int>(
    0,
    (int sum, int value) => sum + value,
  );
  final List<int> results = weights
      .map((int weight) => ((total * weight) / weightTotal).floor())
      .toList(growable: false);
  int remainder =
      total - results.fold<int>(0, (int sum, int value) => sum + value);

  int index = 0;
  while (remainder > 0) {
    results[index % results.length] = results[index % results.length] + 1;
    remainder--;
    index++;
  }

  return results;
}

DateTime normalizeDate(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

bool isSameDate(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

String formatDate(DateTime date) {
  return '${_monthNames[date.month - 1]} ${date.day}, ${date.year}';
}

String formatMonthYear(DateTime date) {
  return '${_monthNames[date.month - 1]} ${date.year}';
}

String formatHeadlineDate(DateTime date) {
  return '${_weekdayNames[(date.weekday % 7)]}, ${_monthNames[date.month - 1]} ${date.day}';
}

String formatDayName(DateTime date) {
  return _weekdayNames[(date.weekday % 7)];
}

String formatDuration(Duration duration) {
  final int totalMinutes = duration.inMinutes;
  if (totalMinutes <= 0) {
    return '0m';
  }

  final int hours = totalMinutes ~/ 60;
  final int minutes = totalMinutes % 60;
  if (hours <= 0) {
    return '${minutes}m';
  }
  if (minutes == 0) {
    return '${hours}h';
  }
  return '${hours}h ${minutes}m';
}

String brainStateHeadline(BrainState state) {
  switch (state) {
    case BrainState.zen:
      return "I'm feeling calm today.";
    case BrainState.okay:
      return 'Pretty good balance today!';
    case BrainState.drained:
      return 'I really need a rest...';
    case BrainState.fried:
      return 'My brain is fried!';
    case BrainState.brainrot:
      return 'I need a serious Pauze.';
    case BrainState.future:
    case BrainState.empty:
      return "I'm easing into today.";
  }
}

String pauStateName(BrainState state) {
  switch (state) {
    case BrainState.zen:
      return 'zen';
    case BrainState.okay:
      return 'okay';
    case BrainState.drained:
      return 'drained';
    case BrainState.fried:
      return 'fried';
    case BrainState.brainrot:
      return 'brainrot';
    case BrainState.future:
    case BrainState.empty:
      return 'zen';
  }
}

String _displayNameForAppId(String appId) {
  switch (appId) {
    case 'youtube':
      return 'YouTube';
    case 'instagram':
      return 'Instagram';
    case 'snapchat':
      return 'Snapchat';
    default:
      return appId;
  }
}

String _dateKey(DateTime date) {
  final String month = date.month.toString().padLeft(2, '0');
  final String day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

const List<String> _monthNames = <String>[
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

const List<String> _weekdayNames = <String>[
  'Sunday',
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
];

void debugLogBrainDataFallback() {
  if (!kDebugMode) {
    return;
  }

  if (Platform.isIOS) {
    debugPrint(
      'TODO: Replace fallback sample data with DeviceActivity data on iOS.',
    );
    debugPrint(
      'TODO: Map DeviceActivity time, pickups, notifications into Brain Load.',
    );
  }
}
