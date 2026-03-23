import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';

import '../models/analytics_models.dart';
import '../models/focus_schedule.dart';
import '../models/target_app.dart';
import '../services/analytics_service.dart';
import '../services/android_block_service.dart';
import '../services/ios_block_service.dart';

class AppState extends ChangeNotifier {
  AppState({
    required IOSBlockService iosBlockService,
    required AnalyticsService analyticsService,
  })  : _iosBlockService = iosBlockService,
        _analyticsService = analyticsService;

  final IOSBlockService _iosBlockService;
  final AnalyticsService _analyticsService;
  final AndroidBlockService _androidBlockService = AndroidBlockService();

  bool _isReady = false;
  bool _isBusy = false;
  bool _permissionGranted = false;
  bool _isBlockingEnabled = false;
  bool _androidAccessibilityEnabled = false;

  List<TargetApp> _selectedTrackedApps = TargetApp.values.toList(growable: false);
  List<String> _nativeSelectedLabels = <String>[];
  Map<String, TargetApp> _nativeLabelMappings = <String, TargetApp>{};
  List<String> _unmappedNativeLabels = <String>[];

  FocusSchedule? _focusSchedule;
  DateTime? _unlockEndsAt;
  Timer? _unlockTicker;

  List<DailyAnalytics> _allAnalytics = <DailyAnalytics>[];
  List<DailyAnalytics> _weeklyAnalytics = <DailyAnalytics>[];
  TotalStats _totalStats = const TotalStats();

  bool get isReady => _isReady;
  bool get isBusy => _isBusy;
  bool get permissionGranted => _permissionGranted;
  bool get isBlockingEnabled => _isBlockingEnabled;
  bool get androidAccessibilityEnabled => _androidAccessibilityEnabled;
  bool get isTemporarilyUnlocked =>
      _unlockEndsAt != null && _unlockEndsAt!.isAfter(DateTime.now());

  List<TargetApp> get selectedTrackedApps =>
      List<TargetApp>.unmodifiable(_selectedTrackedApps);

  List<String> get nativeSelectedLabels =>
      List<String>.unmodifiable(_nativeSelectedLabels);

  Map<String, TargetApp> get nativeLabelMappings =>
      Map<String, TargetApp>.unmodifiable(_nativeLabelMappings);

  List<String> get unmappedNativeLabels =>
      List<String>.unmodifiable(_unmappedNativeLabels);

  List<String> get mappedDisplayNames => _selectedTrackedApps
      .map((TargetApp app) => app.meta.displayName)
      .toList(growable: false);

  FocusSchedule? get focusSchedule => _focusSchedule;

  List<DailyAnalytics> get weeklyAnalytics =>
      List<DailyAnalytics>.unmodifiable(_weeklyAnalytics);

  TotalStats get totalStats => _totalStats;

  Duration get unlockRemaining {
    if (_unlockEndsAt == null) {
      return Duration.zero;
    }
    final Duration diff = _unlockEndsAt!.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  Future<void> initialize() async {
    _setBusy(true);

    _permissionGranted = await _analyticsService.loadPermissionGranted();
    _isBlockingEnabled = await _analyticsService.loadBlockingEnabled();
    _selectedTrackedApps = await _analyticsService.loadSelectedTargetApps();
    _nativeSelectedLabels = await _analyticsService.loadNativeSelectedLabels();

    final Map<String, String> persistedMap =
        await _analyticsService.loadNativeLabelToAppMap();
    _nativeLabelMappings = _deserializeLabelMap(persistedMap);
    _unmappedNativeLabels = await _analyticsService.loadUnmappedNativeLabels();

    _focusSchedule = await _analyticsService.loadFocusSchedule();
    _allAnalytics = await _analyticsService.loadDailyAnalytics();
    _weeklyAnalytics = _analyticsService.weeklySlice(_allAnalytics, DateTime.now());
    _totalStats = await _analyticsService.loadTotalStats();

    if (Platform.isAndroid) {
      _androidAccessibilityEnabled =
          await _androidBlockService.isAccessibilityEnabled();
      await _syncAndroidBlockedApps();
    }

    _isReady = true;
    _setBusy(false);
  }

  Future<bool> requestFamilyPermission() async {
    _setBusy(true);
    try {
      if (Platform.isAndroid) {
        _androidAccessibilityEnabled =
            await _androidBlockService.isAccessibilityEnabled();
        if (!_androidAccessibilityEnabled) {
          await _androidBlockService.openAccessibilitySettings();
        }
        _permissionGranted = _androidAccessibilityEnabled;
        await _analyticsService.savePermissionGranted(_permissionGranted);
        notifyListeners();
        return _permissionGranted;
      }

      final bool granted = await _iosBlockService.requestAuthorization();
      _permissionGranted = granted;
      await _analyticsService.savePermissionGranted(granted);
      notifyListeners();
      return granted;
    } finally {
      _setBusy(false);
    }
  }

  Future<void> refreshAndroidAccessibilityStatus() async {
    if (!Platform.isAndroid) {
      return;
    }
    _androidAccessibilityEnabled =
        await _androidBlockService.isAccessibilityEnabled();
    _permissionGranted = _androidAccessibilityEnabled;
    await _analyticsService.savePermissionGranted(_permissionGranted);
    notifyListeners();
  }

  Future<int> selectAppsFromPicker() async {
    _setBusy(true);
    try {
      if (Platform.isAndroid) {
        await _syncAndroidBlockedApps();

        _nativeSelectedLabels = _selectedTrackedApps
            .map((TargetApp app) => app.meta.displayName)
            .toList(growable: false);

        _nativeLabelMappings = <String, TargetApp>{
          for (final TargetApp app in _selectedTrackedApps)
            app.meta.displayName: app,
        };

        _unmappedNativeLabels = <String>[];
        await _analyticsService.saveNativeSelectedLabels(_nativeSelectedLabels);
        await _analyticsService
            .saveNativeLabelToAppMap(_serializeLabelMap(_nativeLabelMappings));
        await _analyticsService.saveUnmappedNativeLabels(_unmappedNativeLabels);

        notifyListeners();
        return _selectedTrackedApps.length;
      }

      final AppSelectionResult result = await _iosBlockService.selectApps();
      _nativeSelectedLabels = result.selectedLabels;

      final LabelMappingResult mapping =
          mapSelectedLabelsToApps(result.selectedLabels);
      _nativeLabelMappings = mapping.labelToApp;
      _unmappedNativeLabels = mapping.unmappedLabels;

      if (mapping.mappedApps.isNotEmpty) {
        _selectedTrackedApps = mapping.mappedApps;
        await _analyticsService.saveSelectedTargetApps(_selectedTrackedApps);
      }

      await _analyticsService.saveNativeSelectedLabels(_nativeSelectedLabels);
      await _analyticsService
          .saveNativeLabelToAppMap(_serializeLabelMap(_nativeLabelMappings));
      await _analyticsService.saveUnmappedNativeLabels(_unmappedNativeLabels);

      notifyListeners();
      return result.selectedCount;
    } finally {
      _setBusy(false);
    }
  }

  Future<void> setTrackedApps(List<TargetApp> apps) async {
    _selectedTrackedApps = apps;
    await _analyticsService.saveSelectedTargetApps(apps);

    if (Platform.isAndroid) {
      await _syncAndroidBlockedApps();
    }

    notifyListeners();
  }

  Future<void> blockAppsNow() async {
    _setBusy(true);
    try {
      if (Platform.isAndroid) {
        await _syncAndroidBlockedApps();
      } else {
        await _iosBlockService.blockApps();
      }

      _isBlockingEnabled = true;
      await _analyticsService.saveBlockingEnabled(true);
      notifyListeners();
    } finally {
      _setBusy(false);
    }
  }

  Future<void> unblockForDuration({
    int durationMinutes = 10,
    bool shouldRecordAnalytics = true,
  }) async {
    _setBusy(true);
    try {
      if (Platform.isAndroid) {
        await _androidBlockService.unlockApps(durationMinutes);
      } else {
        await _iosBlockService.unblockApps(durationMinutes: durationMinutes);
      }

      _unlockEndsAt = DateTime.now().add(Duration(minutes: durationMinutes));
      _startUnlockTicker();

      if (shouldRecordAnalytics) {
        _allAnalytics = await _analyticsService.recordUnlockEvent(
          apps: _selectedTrackedApps,
          durationSeconds: durationMinutes * 60,
        );
        _weeklyAnalytics =
            _analyticsService.weeklySlice(_allAnalytics, DateTime.now());
        _totalStats = await _analyticsService.loadTotalStats();
      }

      notifyListeners();
    } finally {
      _setBusy(false);
    }
  }

  Future<void> lockImmediately() async {
    _setBusy(true);
    try {
      if (Platform.isAndroid) {
        await _syncAndroidBlockedApps();
      } else {
        await _iosBlockService.blockApps();
      }

      _unlockEndsAt = null;
      _unlockTicker?.cancel();
      _unlockTicker = null;
      notifyListeners();
    } finally {
      _setBusy(false);
    }
  }

  Future<void> saveSchedule({
    required TimeOfDay start,
    required TimeOfDay end,
  }) async {
    final FocusSchedule schedule = FocusSchedule(
      startHour: start.hour,
      startMinute: start.minute,
      endHour: end.hour,
      endMinute: end.minute,
    );

    _focusSchedule = schedule;
    await _analyticsService.saveFocusSchedule(schedule);

    if (!Platform.isAndroid) {
      await _iosBlockService.scheduleBlocking(schedule);
    }

    notifyListeners();
  }

  Future<void> clearSchedule() async {
    _focusSchedule = null;
    await _analyticsService.saveFocusSchedule(null);

    if (!Platform.isAndroid) {
      await _iosBlockService.scheduleBlocking(
        const FocusSchedule(
          startHour: 0,
          startMinute: 0,
          endHour: 0,
          endMinute: 0,
          enabled: false,
        ),
      );
    }

    notifyListeners();
  }

  Future<void> refreshUsageFromNative() async {
    if (Platform.isAndroid) {
      final Map<String, dynamic> nativeData = await _androidBlockService.getStats();
      if (nativeData.isEmpty) {
        return;
      }

      final int unlocks = (nativeData['totalUnlocks'] as num?)?.toInt() ?? 0;
      final int seconds = (nativeData['totalUsageSeconds'] as num?)?.toInt() ?? 0;

      int opened = 0;
      final dynamic opensMap = nativeData['appOpens'];
      if (opensMap is Map) {
        for (final dynamic value in opensMap.values) {
          opened += (value as num?)?.toInt() ?? 0;
        }
      }

      _totalStats = _totalStats.copyWith(
        totalUnlocks: max(_totalStats.totalUnlocks, unlocks),
        totalSessions: max(_totalStats.totalSessions, opened),
        totalSecondsSpent: max(_totalStats.totalSecondsSpent, seconds),
        totalAppsOpened: max(_totalStats.totalAppsOpened, opened),
      );

      await _analyticsService.saveTotalStats(_totalStats);
      notifyListeners();
      return;
    }

    final Map<String, dynamic> nativeData = await _iosBlockService.getUsageData();
    if (nativeData.isEmpty) {
      return;
    }

    final int unlocks = (nativeData['unlocks'] as num?)?.toInt() ?? 0;
    final int sessions = (nativeData['sessions'] as num?)?.toInt() ?? 0;
    final int seconds = (nativeData['secondsSpent'] as num?)?.toInt() ?? 0;
    final int opened = (nativeData['openedCount'] as num?)?.toInt() ?? 0;

    _totalStats = _totalStats.copyWith(
      totalUnlocks: max(_totalStats.totalUnlocks, unlocks),
      totalSessions: max(_totalStats.totalSessions, sessions),
      totalSecondsSpent: max(_totalStats.totalSecondsSpent, seconds),
      totalAppsOpened: max(_totalStats.totalAppsOpened, opened),
    );

    await _analyticsService.saveTotalStats(_totalStats);
    notifyListeners();
  }

  Future<String?> consumePendingAndroidUnlockAction() async {
    if (!Platform.isAndroid) {
      return null;
    }
    return _androidBlockService.consumePendingUnlockAction();
  }

  Future<void> _syncAndroidBlockedApps() async {
    if (!Platform.isAndroid) {
      return;
    }

    final List<String> packages = _selectedTrackedApps
        .map((TargetApp app) => app.meta.androidPackageId)
        .toList(growable: false);

    await _androidBlockService.setBlockedApps(packages);
  }

  void _startUnlockTicker() {
    _unlockTicker?.cancel();
    _unlockTicker = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (_unlockEndsAt == null) {
        timer.cancel();
        return;
      }
      if (_unlockEndsAt!.isBefore(DateTime.now())) {
        _unlockEndsAt = null;
        timer.cancel();
        if (Platform.isAndroid) {
          unawaited(_syncAndroidBlockedApps());
        } else {
          unawaited(_iosBlockService.blockApps());
        }
      }
      notifyListeners();
    });
  }

  Map<String, String> _serializeLabelMap(Map<String, TargetApp> map) {
    return map.map<String, String>(
      (String label, TargetApp app) => MapEntry<String, String>(
        label,
        app.meta.id,
      ),
    );
  }

  Map<String, TargetApp> _deserializeLabelMap(Map<String, String> map) {
    final Map<String, TargetApp> decoded = <String, TargetApp>{};
    map.forEach((String label, String appId) {
      final TargetApp? app = targetAppFromId(appId);
      if (app != null) {
        decoded[label] = app;
      }
    });
    return decoded;
  }

  void _setBusy(bool value) {
    if (_isBusy == value) {
      return;
    }
    _isBusy = value;
    notifyListeners();
  }

  String formatDuration(int seconds) {
    final Duration d = Duration(seconds: seconds);
    final int h = d.inHours;
    final int m = d.inMinutes.remainder(60);
    final int s = d.inSeconds.remainder(60);
    if (h > 0) {
      return '${h}h ${m}m ${s}s';
    }
    if (m > 0) {
      return '${m}m ${s}s';
    }
    return '${s}s';
  }

  @override
  void dispose() {
    _unlockTicker?.cancel();
    super.dispose();
  }
}
