import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/analytics_models.dart';
import '../models/focus_schedule.dart';
import '../models/target_app.dart';

class AnalyticsService {
  static const String _dailyAnalyticsKey = 'daily_analytics';
  static const String _totalStatsKey = 'total_stats';
  static const String _selectedTargetAppsKey = 'selected_target_apps';
  static const String _selectedNativeLabelsKey = 'selected_native_labels';
  static const String _nativeLabelMapKey = 'native_label_to_app_map';
  static const String _unmappedNativeLabelsKey = 'native_unmapped_labels';
  static const String _focusScheduleKey = 'focus_schedule';
  static const String _isBlockingEnabledKey = 'is_blocking_enabled';
  static const String _useSafeModeKey = 'use_safe_mode';
  static const String _hasPermissionKey = 'has_family_permission';
  static const String _legalAcceptedKey = 'legal_consent_accepted_v1';
  static const String _onboardingCompletedKey = 'onboarding_completed_v1';
  static const String _onboardingDailyScrollHoursKey =
      'onboarding_daily_scroll_hours';
  static const String _onboardingSelectedTrapAppsKey =
      'onboarding_selected_trap_apps';

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  Future<List<TargetApp>> loadSelectedTargetApps() async {
    final SharedPreferences prefs = await _prefs;
    final List<String> ids =
        prefs.getStringList(_selectedTargetAppsKey) ??
        TargetApp.values
            .map((TargetApp e) => e.meta.id)
            .toList(growable: false);

    final List<TargetApp> selected = <TargetApp>[];
    for (final String id in ids) {
      final TargetApp? app = targetAppFromId(id);
      if (app != null) {
        selected.add(app);
      }
    }
    return selected;
  }

  Future<void> saveSelectedTargetApps(List<TargetApp> apps) async {
    final SharedPreferences prefs = await _prefs;
    await prefs.setStringList(
      _selectedTargetAppsKey,
      apps.map((TargetApp e) => e.meta.id).toList(growable: false),
    );
  }

  Future<List<String>> loadNativeSelectedLabels() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getStringList(_selectedNativeLabelsKey) ?? <String>[];
  }

  Future<void> saveNativeSelectedLabels(List<String> labels) async {
    final SharedPreferences prefs = await _prefs;
    await prefs.setStringList(_selectedNativeLabelsKey, labels);
  }

  Future<Map<String, String>> loadNativeLabelToAppMap() async {
    final SharedPreferences prefs = await _prefs;
    final String? raw = prefs.getString(_nativeLabelMapKey);
    if (raw == null || raw.isEmpty) {
      return <String, String>{};
    }

    final Map<String, dynamic> decoded =
        jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map<String, String>(
      (String key, dynamic value) =>
          MapEntry<String, String>(key, value.toString()),
    );
  }

  Future<void> saveNativeLabelToAppMap(Map<String, String> map) async {
    final SharedPreferences prefs = await _prefs;
    await prefs.setString(_nativeLabelMapKey, jsonEncode(map));
  }

  Future<List<String>> loadUnmappedNativeLabels() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getStringList(_unmappedNativeLabelsKey) ?? <String>[];
  }

  Future<void> saveUnmappedNativeLabels(List<String> labels) async {
    final SharedPreferences prefs = await _prefs;
    await prefs.setStringList(_unmappedNativeLabelsKey, labels);
  }

  Future<FocusSchedule?> loadFocusSchedule() async {
    final SharedPreferences prefs = await _prefs;
    final String? raw = prefs.getString(_focusScheduleKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return FocusSchedule.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveFocusSchedule(FocusSchedule? schedule) async {
    final SharedPreferences prefs = await _prefs;
    if (schedule == null) {
      await prefs.remove(_focusScheduleKey);
      return;
    }
    await prefs.setString(_focusScheduleKey, jsonEncode(schedule.toJson()));
  }

  Future<bool> loadBlockingEnabled() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getBool(_isBlockingEnabledKey) ?? false;
  }

  Future<void> saveBlockingEnabled(bool value) async {
    final SharedPreferences prefs = await _prefs;
    await prefs.setBool(_isBlockingEnabledKey, value);
  }

  Future<bool> loadUseSafeMode() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getBool(_useSafeModeKey) ?? false;
  }

  Future<void> saveUseSafeMode(bool value) async {
    final SharedPreferences prefs = await _prefs;
    await prefs.setBool(_useSafeModeKey, value);
  }

  Future<bool> loadPermissionGranted() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getBool(_hasPermissionKey) ?? false;
  }

  Future<void> savePermissionGranted(bool value) async {
    final SharedPreferences prefs = await _prefs;
    await prefs.setBool(_hasPermissionKey, value);
  }

  Future<List<DailyAnalytics>> loadDailyAnalytics() async {
    final SharedPreferences prefs = await _prefs;
    final List<String> raw =
        prefs.getStringList(_dailyAnalyticsKey) ?? <String>[];
    return raw
        .map(
          (String item) =>
              DailyAnalytics.fromJson(jsonDecode(item) as Map<String, dynamic>),
        )
        .toList(growable: false);
  }

  Future<void> saveDailyAnalytics(List<DailyAnalytics> list) async {
    final SharedPreferences prefs = await _prefs;
    await prefs.setStringList(
      _dailyAnalyticsKey,
      list
          .map((DailyAnalytics e) => jsonEncode(e.toJson()))
          .toList(growable: false),
    );
  }

  Future<TotalStats> loadTotalStats() async {
    final SharedPreferences prefs = await _prefs;
    final String? raw = prefs.getString(_totalStatsKey);
    if (raw == null || raw.isEmpty) {
      return const TotalStats();
    }
    return TotalStats.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveTotalStats(TotalStats stats) async {
    final SharedPreferences prefs = await _prefs;
    await prefs.setString(_totalStatsKey, jsonEncode(stats.toJson()));
  }

  Future<List<DailyAnalytics>> recordUnlockEvent({
    required List<TargetApp> apps,
    required int durationSeconds,
  }) async {
    final DateTime now = DateTime.now();
    final String key = _dateKey(now);

    final List<DailyAnalytics> current = await loadDailyAnalytics();
    final int index = current.indexWhere(
      (DailyAnalytics d) => d.dateKey == key,
    );

    DailyAnalytics day = index >= 0
        ? current[index]
        : DailyAnalytics(dateKey: key, perApp: <String, DailyAppStats>{});

    final Map<String, DailyAppStats> updatedPerApp =
        Map<String, DailyAppStats>.from(day.perApp);

    for (final TargetApp app in apps) {
      final DailyAppStats existing =
          updatedPerApp[app.meta.id] ?? DailyAppStats();
      updatedPerApp[app.meta.id] = existing.copyWith(
        unlocks: existing.unlocks + 1,
        sessions: existing.sessions + 1,
        secondsSpent: existing.secondsSpent + durationSeconds,
        openedCount: existing.openedCount + 1,
      );
    }

    day = day.copyWith(perApp: updatedPerApp);

    if (index >= 0) {
      current[index] = day;
    } else {
      current.add(day);
    }

    await saveDailyAnalytics(current);

    final TotalStats total = await loadTotalStats();
    final TotalStats next = total.copyWith(
      totalUnlocks: total.totalUnlocks + 1,
      totalSessions: total.totalSessions + 1,
      totalSecondsSpent: total.totalSecondsSpent + durationSeconds,
      totalAppsOpened: total.totalAppsOpened + apps.length,
    );
    await saveTotalStats(next);

    return current;
  }

  List<DailyAnalytics> weeklySlice(List<DailyAnalytics> all, DateTime now) {
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime monday = today.subtract(Duration(days: today.weekday - 1));

    final List<String> keys = List<String>.generate(7, (int index) {
      final DateTime day = monday.add(Duration(days: index));
      return _dateKey(day);
    });

    final Map<String, DailyAnalytics> byKey = <String, DailyAnalytics>{
      for (final DailyAnalytics day in all) day.dateKey: day,
    };

    return keys
        .map(
          (String key) =>
              byKey[key] ??
              DailyAnalytics(dateKey: key, perApp: <String, DailyAppStats>{}),
        )
        .toList(growable: false);
  }

  Future<bool> loadLegalAccepted() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getBool(_legalAcceptedKey) ?? false;
  }

  Future<void> saveLegalAccepted(bool value) async {
    final SharedPreferences prefs = await _prefs;
    await prefs.setBool(_legalAcceptedKey, value);
  }

  Future<bool> loadOnboardingCompleted() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getBool(_onboardingCompletedKey) ?? false;
  }

  Future<void> saveOnboardingCompleted(bool value) async {
    final SharedPreferences prefs = await _prefs;
    await prefs.setBool(_onboardingCompletedKey, value);
  }

  Future<double> loadOnboardingDailyScrollHours() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getDouble(_onboardingDailyScrollHoursKey) ?? 3.0;
  }

  Future<void> saveOnboardingDailyScrollHours(double value) async {
    final SharedPreferences prefs = await _prefs;
    await prefs.setDouble(_onboardingDailyScrollHoursKey, value);
  }

  Future<List<String>> loadOnboardingSelectedTrapApps() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getStringList(_onboardingSelectedTrapAppsKey) ??
        <String>['instagram'];
  }

  Future<void> saveOnboardingSelectedTrapApps(List<String> appIds) async {
    final SharedPreferences prefs = await _prefs;
    await prefs.setStringList(_onboardingSelectedTrapAppsKey, appIds);
  }

  String _dateKey(DateTime dateTime) {
    final String y = dateTime.year.toString().padLeft(4, '0');
    final String m = dateTime.month.toString().padLeft(2, '0');
    final String d = dateTime.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
