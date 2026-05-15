// ignore_for_file: unused_element, unused_field

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/dashboard/data/brain_stats_provider.dart';
import '../features/dashboard/widgets/brain_health_calendar.dart';
import '../features/dashboard/widgets/dashboard_summary_card.dart';
import '../features/dashboard/widgets/day_brain_details_dialog.dart';
import '../features/dashboard/widgets/pau_status_header.dart';
import '../models/target_app.dart';
import '../providers/app_state.dart';
import '../widgets/glass_container.dart';
import 'analytics_screen.dart';
import 'blocked_apps_screen.dart';
import 'breathing_screen.dart';
import 'game_screen.dart';
import 'legal_consent_screen.dart';
import 'safe_mode/safe_facebook_screen.dart';
import 'safe_mode/safe_instagram_screen.dart';
import 'safe_mode/safe_youtube_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  static const Color _bgStart = Color(0xFF0E0E11);
  static const Color _bgEnd = Color(0xFF151821);
  static const Color _blue = Color(0xFF2F80ED);
  static const Color _green = Color(0xFF12D876);
  static const Color _purple = Color(0xFF7B61FF);

  bool _isPremium = false;
  int _totalScrollCount = 0;
  bool _hasSyncedDashboardAfterReady = false;
  bool _isDashboardLoading = true;
  late final DateTime _calendarMonth;
  DailyBrainStats? _todayBrainStats;
  Map<DateTime, DailyBrainStats> _monthBrainStats =
      <DateTime, DailyBrainStats>{};
  DateTime? _selectedCalendarDate;

  @override
  void initState() {
    super.initState();
    _calendarMonth = DateTime(DateTime.now().year, DateTime.now().month);
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_loadLocalUiData());
      unawaited(_refreshDashboardData());
      _consumePendingUnlockActionIfAny();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _consumePendingUnlockActionIfAny();
      unawaited(_loadLocalUiData());
      unawaited(_refreshDashboardData());
      if (Platform.isAndroid) {
        context.read<AppState>().refreshAndroidAccessibilityStatus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppState state = context.watch<AppState>();
    if (state.isReady && !_hasSyncedDashboardAfterReady) {
      _hasSyncedDashboardAfterReady = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          unawaited(_refreshDashboardData());
        }
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF8),
      body: Stack(
        children: <Widget>[
          const Positioned.fill(child: _DashboardBackground()),
          SafeArea(
            child: state.isReady
                ? RefreshIndicator(
                    color: const Color(0xFFFF8A45),
                    backgroundColor: Colors.white,
                    onRefresh: _handleRefresh,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(18, 10, 18, 120),
                      child: _buildDashboardContent(state),
                    ),
                  )
                : const Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildDashboardContent(AppState state) {
    final DailyBrainStats stats =
        _todayBrainStats ?? generateSampleStats(DateTime.now());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.86),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: const Color(0xFFFFE2DB)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    Icons.circle_outlined,
                    size: 14,
                    color: Color(0xFF4A342F),
                  ),
                  SizedBox(width: 4),
                  Text(
                    '100%',
                    style: TextStyle(
                      color: Color(0xFF4A342F),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        PauStatusHeader(stats: stats),
        const SizedBox(height: 18),
        AnimatedOpacity(
          duration: const Duration(milliseconds: 260),
          opacity: _isDashboardLoading ? 0.85 : 1,
          child: DashboardSummaryCard(stats: stats),
        ),
        const SizedBox(height: 22),
        Text(
          formatMonthYear(_calendarMonth),
          style: const TextStyle(
            color: Color(0xFF3F2E2A),
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        BrainHealthCalendar(
          month: _calendarMonth,
          monthStats: _monthBrainStats,
          selectedDate: _selectedCalendarDate,
          onDaySelected: (DailyBrainStats selected) async {
            setState(() {
              _selectedCalendarDate = selected.date;
            });
            await showDayBrainDetailsDialog(context, stats: selected);
          },
        ),
        const SizedBox(height: 20),
        _buildDashboardSafeModeSection(state),
        if (Platform.isAndroid &&
            !state.androidAccessibilityEnabled) ...<Widget>[
          const SizedBox(height: 20),
          _buildAndroidAccessHint(state),
        ],
      ],
    );
  }

  Widget _buildAndroidAccessHint(AppState state) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFFE3DB)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x181C1009),
            blurRadius: 24,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () async {
            await context.read<AppState>().requestFamilyPermission();
            if (!mounted) {
              return;
            }
            await context.read<AppState>().refreshAndroidAccessibilityStatus();
            await _refreshDashboardData();
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: <Widget>[
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEEE7),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.lock_open_rounded,
                    color: Color(0xFFFF8A45),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Finish Android access',
                        style: TextStyle(
                          color: Color(0xFF4A342F),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Enable Accessibility so Pauze can map pickups and usage into Brain Load.',
                        style: TextStyle(
                          color: Color(0xFF8E817C),
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFFFF8A45),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardSafeModeSection(AppState state) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFFFE3DB)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x1B20110A),
            blurRadius: 28,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0EA),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.safety_check_rounded,
                    color: Color(0xFFFF8A45),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Safe Social Mode',
                        style: TextStyle(
                          color: Color(0xFF4A342F),
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Open calmer in-app versions of Instagram, YouTube, and Facebook.',
                        style: TextStyle(
                          color: Color(0xFF8F817C),
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: state.useSafeMode,
                  onChanged: (bool value) {
                    unawaited(context.read<AppState>().setUseSafeMode(value));
                  },
                  activeThumbColor: const Color(0xFFFF8A45),
                  activeTrackColor: const Color(0xFFFFC7AE),
                  inactiveThumbColor: const Color(0xFFD4C6C0),
                  inactiveTrackColor: const Color(0xFFF2E5E0),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: <Widget>[
                Expanded(
                  child: _DashboardSafeAppButton(
                    label: 'Instagram',
                    icon: Icons.camera_alt_outlined,
                    accent: const Color(0xFFFF6B9A),
                    enabled: state.useSafeMode,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const SafeInstagramScreen(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _DashboardSafeAppButton(
                    label: 'YouTube',
                    icon: Icons.play_circle_outline_rounded,
                    accent: const Color(0xFFFF8555),
                    enabled: state.useSafeMode,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const SafeYouTubeScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _DashboardSafeAppButton(
              label: 'Facebook',
              icon: Icons.facebook_rounded,
              accent: const Color(0xFFFFA05C),
              enabled: state.useSafeMode,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const SafeFacebookScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return GlassContainer(
      borderRadius: 24,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: <Widget>[
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0x44FFFFFF),
            ),
            child: const Icon(Icons.shield_moon_rounded, color: Colors.white),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Pauze',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const AnalyticsScreen(),
                ),
              );
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x3DFFFFFF),
              ),
              child: const Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  Center(
                    child: Icon(
                      Icons.notifications_none_rounded,
                      color: Colors.white,
                    ),
                  ),
                  Positioned(
                    right: 10,
                    top: 10,
                    child: CircleAvatar(radius: 4, backgroundColor: Colors.red),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusOrb(AppState state) {
    final bool blockingActive = Platform.isAndroid
        ? state.androidAccessibilityEnabled &&
              state.selectedTrackedApps.isNotEmpty &&
              !state.isTemporarilyUnlocked
        : state.isBlockingEnabled && !state.isTemporarilyUnlocked;

    return Column(
      children: <Widget>[
        Container(
          width: 126,
          height: 126,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: <Color>[Color(0xFF22EA90), Color(0xFF12D876)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: _green.withValues(alpha: 0.5),
                blurRadius: 36,
                spreadRadius: 2,
              ),
            ],
            border: Border.all(color: const Color(0x88FFFFFF), width: 1.2),
          ),
          child: Center(
            child: Icon(
              blockingActive ? Icons.bolt_rounded : Icons.pause_rounded,
              color: Colors.white,
              size: 48,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          blockingActive ? 'Blocking Active' : 'Blocking Paused',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildGrantAccessCard(AppState state) {
    return GlassContainer(
      borderRadius: 22,
      ripple: true,
      onTap: () async {
        await context.read<AppState>().requestFamilyPermission();
        if (!mounted) {
          return;
        }
        await context.read<AppState>().refreshAndroidAccessibilityStatus();
      },
      padding: const EdgeInsets.all(14),
      activeGlowColor: _blue,
      child: Row(
        children: <Widget>[
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: const LinearGradient(
                colors: <Color>[Color(0xFF3A86FF), Color(0xFF246BFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(
              Icons.lock_open_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Grant Access',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Enable Accessibility on Android so Pauze can detect and block selected apps.',
                  style: TextStyle(
                    color: Color(0xFFBAC0CF),
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: const Color(0xFF2F80ED),
              boxShadow: <BoxShadow>[
                BoxShadow(color: _blue.withValues(alpha: 0.28), blurRadius: 20),
              ],
            ),
            child: const Text(
              'Grant',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(AppState state) {
    final bool pauseActive = state.isTemporarilyUnlocked;

    return Row(
      children: <Widget>[
        Expanded(
          child: _GlassButton(
            text: 'Pause',
            icon: Icons.pause_rounded,
            outlined: true,
            enabled: !pauseActive,
            onTap: _onPauseTap,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _GlassButton(
            text: pauseActive ? 'Paused' : 'Active',
            icon: pauseActive
                ? Icons.timer_rounded
                : Icons.not_interested_rounded,
            outlined: false,
            enabled: true,
            onTap: () {
              if (pauseActive) {
                unawaited(context.read<AppState>().lockImmediately());
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryGrid(AppState state) {
    final int timeSpent = state.totalStats.totalSecondsSpent;
    final int opened = state.totalStats.totalAppsOpened;
    final int blocked = state.scrollBlockedCount;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      childAspectRatio: 1.12,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      physics: const NeverScrollableScrollPhysics(),
      children: <Widget>[
        _SummaryTile(
          title: 'Time Wasted',
          value: _formatDuration(timeSpent),
          icon: Icons.access_time_rounded,
          badgeColor: _purple,
        ),
        _SummaryTile(
          title: 'Total Scroll',
          value: _totalScrollCount.toString(),
          icon: Icons.swap_vert_rounded,
          badgeColor: _green,
        ),
        _SummaryTile(
          title: 'Scroll Blocked',
          value: blocked.toString(),
          icon: Icons.block_rounded,
          badgeColor: _blue,
        ),
        _SummaryTile(
          title: 'App Opened',
          value: opened.toString(),
          icon: Icons.apps_rounded,
          badgeColor: const Color(0xFFF6B40E),
        ),
      ],
    );
  }

  Widget _buildSafeModeSection(AppState state) {
    return GlassContainer(
      borderRadius: 22,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(
                Icons.safety_check_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Safe Social Mode',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Switch(
                value: state.useSafeMode,
                onChanged: (bool value) {
                  unawaited(context.read<AppState>().setUseSafeMode(value));
                },
                activeThumbColor: _blue,
                activeTrackColor: _blue.withValues(alpha: 0.35),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Open safer in-app versions of Instagram, YouTube, and Facebook.',
            style: TextStyle(color: Color(0xFFBAC0CF), fontSize: 13),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: _SafeAppButton(
                  label: 'Instagram',
                  icon: Icons.camera_alt_outlined,
                  enabled: state.useSafeMode,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const SafeInstagramScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SafeAppButton(
                  label: 'YouTube',
                  icon: Icons.play_circle_outline_rounded,
                  enabled: state.useSafeMode,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const SafeYouTubeScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _SafeAppButton(
            label: 'Facebook',
            icon: Icons.facebook_rounded,
            enabled: state.useSafeMode,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const SafeFacebookScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFocusTimeCard(AppState state) {
    final String startTime = state.focusSchedule?.startLabel ?? '--';
    final String endTime = state.focusSchedule?.endLabel ?? '--';

    return GlassContainer(
      borderRadius: 22,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Focus Time',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _TimeColumn(label: 'Start Time', value: startTime),
                    ),
                    Expanded(
                      child: _TimeColumn(label: 'End Time', value: endTime),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) =>
                      LegalDocumentScreen(type: LegalDocumentType.terms),
                ),
              );
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFE8EDF8),
              ),
              child: const Icon(Icons.play_arrow_rounded, color: _blue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnlockCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GlassContainer(
      borderRadius: 20,
      ripple: true,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: <Widget>[
          Icon(icon, color: _blue, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFFBAC0CF),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFFBAC0CF),
            size: 22,
          ),
        ],
      ),
    );
  }

  Widget _buildBlockedAppsChips() {
    final List<String> apps = context
        .watch<AppState>()
        .selectedTrackedApps
        .map((TargetApp app) => app.meta.displayName)
        .toList(growable: false);

    return GlassContainer(
      borderRadius: 20,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Blocked Apps',
            style: TextStyle(
              color: Color(0xFFBAC0CF),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: apps
                .map(
                  (String app) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: const Color(0x2FFFFFFF),
                      border: Border.all(color: const Color(0x30FFFFFF)),
                    ),
                    child: Text(
                      app,
                      style: const TextStyle(
                        color: Color(0xFFD6DBE9),
                        fontSize: 12,
                      ),
                    ),
                  ),
                )
                .toList(growable: false),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(14, 0, 14, 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFFFFE4DC)),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x221B100A),
              blurRadius: 28,
              offset: Offset(0, 14),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            children: <Widget>[
              Expanded(
                child: _DashboardBottomNavItem(
                  icon: Icons.dashboard_outlined,
                  label: 'Dashboard',
                  selected: true,
                  onTap: () {},
                ),
              ),
              Expanded(
                child: _DashboardBottomNavItem(
                  icon: Icons.bar_chart_rounded,
                  label: 'Analytics',
                  selected: false,
                  onTap: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute<void>(
                        builder: (_) => const AnalyticsScreen(),
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                child: _DashboardBottomNavItem(
                  icon: Icons.settings_outlined,
                  label: 'Settings',
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
      ),
    );
  }

  Future<void> _refreshDashboardData() async {
    final BrainStatsProvider provider = BrainStatsProvider(
      appState: context.read<AppState>(),
    );

    final DailyBrainStats today = await provider.loadTodayStats();
    final Map<DateTime, DailyBrainStats> monthStats = await provider
        .loadMonthStats(_calendarMonth);

    if (!mounted) {
      return;
    }

    setState(() {
      _todayBrainStats = today;
      _monthBrainStats = monthStats;
      _selectedCalendarDate ??= _todayDateInVisibleMonth(today.date);
      _isDashboardLoading = false;
    });
  }

  DateTime _todayDateInVisibleMonth(DateTime today) {
    if (today.year == _calendarMonth.year &&
        today.month == _calendarMonth.month) {
      return today;
    }

    final int lastDay = DateTime(
      _calendarMonth.year,
      _calendarMonth.month + 1,
      0,
    ).day;
    final int day = today.day < 1
        ? 1
        : today.day > lastDay
        ? lastDay
        : today.day;
    return DateTime(_calendarMonth.year, _calendarMonth.month, day);
  }

  Future<void> _onPauseTap() async {
    final AppState state = context.read<AppState>();
    if (state.isTemporarilyUnlocked) {
      return;
    }

    if (_isPremium) {
      final int? mins = await _showPauseDurationSheet();
      if (!mounted || mins == null) {
        return;
      }
      await state.unblockForDuration(
        durationMinutes: mins,
        shouldRecordAnalytics: false,
      );
      return;
    }

    await state.unblockForDuration(
      durationMinutes: 10,
      shouldRecordAnalytics: false,
    );
  }

  Future<int?> _showPauseDurationSheet() async {
    int selected = 10;

    return showModalBottomSheet<int>(
      context: context,
      backgroundColor: const Color(0xFF1D212B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Pause Duration',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$selected mins',
                    style: const TextStyle(
                      color: _blue,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Slider(
                    value: selected.toDouble(),
                    min: 10,
                    max: 30,
                    divisions: 20,
                    activeColor: _blue,
                    inactiveColor: Colors.white24,
                    label: '$selected',
                    onChanged: (double value) {
                      setSheetState(() {
                        selected = value.round();
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white30),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(selected),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _blue,
                          ),
                          child: const Text(
                            'Apply',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _loadLocalUiData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool isPremium = _readPremium(prefs);

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
      _isPremium = isPremium;
      _totalScrollCount = totalScroll;
    });
  }

  bool _readPremium(SharedPreferences prefs) {
    for (final String key in <String>[
      'is_premium',
      'premium',
      'premium_active',
      'pro_user',
    ]) {
      final Object? value = prefs.get(key);
      if (value is bool && value) {
        return true;
      }
    }

    for (final String key in <String>['subscription_tier', 'plan']) {
      final Object? value = prefs.get(key);
      if (value is String && value.toLowerCase() == 'premium') {
        return true;
      }
    }

    return false;
  }

  Future<void> _consumePendingUnlockActionIfAny() async {
    final String? action = await context
        .read<AppState>()
        .consumePendingAndroidUnlockAction();

    if (!mounted || action == null || action.isEmpty) {
      return;
    }

    if (action == 'breathe') {
      await _openUnlockChallenge(const BreathingScreen());
      return;
    }

    if (action == 'game') {
      await _openUnlockChallenge(const GameScreen());
    }
  }

  Future<void> _openUnlockChallenge(Widget screen) async {
    final bool? unlocked = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute<bool>(builder: (_) => screen));

    if (!mounted || unlocked != true) {
      return;
    }

    await _showUnlockSuccessDialog();
  }

  Future<void> _showUnlockSuccessDialog() async {
    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reward Unlocked'),
          content: const Text('You have earned 10 mins watchtime.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleRefresh() async {
    await context.read<AppState>().refreshUsageFromNative();
    await _loadLocalUiData();
    await _refreshDashboardData();
  }

  String _formatDuration(int seconds) {
    final int safe = seconds < 0 ? 0 : seconds;
    final int mins = safe ~/ 60;
    final int secs = safe % 60;
    return '${mins}m ${secs}s';
  }
}

class _DashboardBackground extends StatelessWidget {
  const _DashboardBackground();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color(0xFFFFFCFA),
            Color(0xFFFFF7F2),
            Color(0xFFFFFBF8),
          ],
        ),
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            top: -70,
            left: -30,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: <Color>[
                    const Color(0xFFFFD9C6).withValues(alpha: 0.38),
                    const Color(0xFFFFFCFA).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 180,
            right: -20,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: <Color>[
                    const Color(0xFFFFC1D5).withValues(alpha: 0.28),
                    const Color(0xFFFFFBF8).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 120,
            left: 20,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: <Color>[
                    const Color(0xFFFFE6D8).withValues(alpha: 0.28),
                    const Color(0xFFFFFBF8).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardBottomNavItem extends StatelessWidget {
  const _DashboardBottomNavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color color = selected
        ? const Color(0xFFFF8A45)
        : const Color(0xFF9C8F8A);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: SizedBox(
          height: 56,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              const SizedBox(height: 5),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: selected ? 28 : 0,
                height: 3,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF8A45),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardSafeAppButton extends StatelessWidget {
  const _DashboardSafeAppButton({
    required this.label,
    required this.icon,
    required this.accent,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color accent;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.6,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: enabled ? onTap : null,
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: enabled
                    ? accent.withValues(alpha: 0.55)
                    : const Color(0xFFE9DBD5),
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: accent.withValues(alpha: enabled ? 0.12 : 0.05),
                  blurRadius: 14,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(icon, color: accent, size: 20),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: enabled
                          ? const Color(0xFF4A342F)
                          : const Color(0xFFAB9D98),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassButton extends StatelessWidget {
  const _GlassButton({
    required this.text,
    required this.icon,
    required this.outlined,
    required this.enabled,
    required this.onTap,
  });

  final String text;
  final IconData icon;
  final bool outlined;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color bg = outlined ? Colors.transparent : _HomeScreenState._blue;
    final Color borderColor = outlined
        ? _HomeScreenState._blue
        : Colors.transparent;

    return Opacity(
      opacity: enabled ? 1 : 0.42,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: enabled ? onTap : null,
            child: SizedBox(
              height: 48,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(icon, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.title,
    required this.value,
    required this.icon,
    required this.badgeColor,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color badgeColor;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: 18,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, color: Colors.white, size: 16),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 38,
              height: 1,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeColumn extends StatelessWidget {
  const _TimeColumn({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: const TextStyle(color: Color(0xFFBAC0CF), fontSize: 13),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _SafeAppButton extends StatelessWidget {
  const _SafeAppButton({
    required this.label,
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: const Color(0x24FFFFFF),
            border: Border.all(color: const Color(0x40FFFFFF)),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: enabled ? onTap : null,
            child: SizedBox(
              height: 44,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(icon, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
