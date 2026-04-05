import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/app_state.dart';
import '../widgets/glass_container.dart';
import 'analytics_screen.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_loadLocalUiData());
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
      if (Platform.isAndroid) {
        context.read<AppState>().refreshAndroidAccessibilityStatus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppState state = context.watch<AppState>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[_bgStart, _bgEnd],
          ),
        ),
        child: SafeArea(
          child: state.isReady
              ? RefreshIndicator(
                  onRefresh: _handleRefresh,
                  child: NestedScrollView(
                    headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                      return const <Widget>[];
                    },
                    body: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 110),
                      children: <Widget>[
                        _buildHeader(),
                        const SizedBox(height: 24),
                        _buildStatusOrb(state),
                        const SizedBox(height: 16),
                        _buildActionButtons(state),
                        const SizedBox(height: 14),
                        _buildSafeModeSection(state),
                        const SizedBox(height: 24),
                        Text(
                          'Summary',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 12),
                        _buildSummaryGrid(state),
                        const SizedBox(height: 16),
                        _buildFocusTimeCard(state),
                        const SizedBox(height: 14),
                        _buildUnlockCard(
                          title: 'Breathing Unlock',
                          subtitle: 'Complete a 2-minute guided breathing session',
                          icon: Icons.self_improvement_rounded,
                          onTap: () => unawaited(_openUnlockChallenge(const BreathingScreen())),
                        ),
                        const SizedBox(height: 12),
                        _buildUnlockCard(
                          title: 'Mini Games Unlock',
                          subtitle: 'Complete a short brain game to unlock apps',
                          icon: Icons.extension_rounded,
                          onTap: () => unawaited(_openUnlockChallenge(const GameScreen())),
                        ),
                        const SizedBox(height: 14),
                        _buildBlockedAppsChips(),
                      ],
                    ),
                  ),
                )
              : const Center(child: CircularProgressIndicator()),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
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
              'ScrollRok',
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
                MaterialPageRoute<void>(builder: (_) => const AnalyticsScreen()),
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
                    child: Icon(Icons.notifications_none_rounded, color: Colors.white),
                  ),
                  Positioned(
                    right: 10,
                    top: 10,
                    child: CircleAvatar(
                      radius: 4,
                      backgroundColor: Colors.red,
                    ),
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
    final bool blockingActive = state.isBlockingEnabled && !state.isTemporarilyUnlocked;

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
            icon: pauseActive ? Icons.timer_rounded : Icons.not_interested_rounded,
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
              const Icon(Icons.safety_check_rounded, color: Colors.white, size: 20),
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
            style: TextStyle(
              color: Color(0xFFBAC0CF),
              fontSize: 13,
            ),
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
                      MaterialPageRoute<void>(builder: (_) => const SafeInstagramScreen()),
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
                      MaterialPageRoute<void>(builder: (_) => const SafeYouTubeScreen()),
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
                MaterialPageRoute<void>(builder: (_) => const SafeFacebookScreen()),
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
                  builder: (_) => LegalDocumentScreen(type: LegalDocumentType.terms),
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
          const Icon(Icons.chevron_right_rounded, color: Color(0xFFBAC0CF), size: 22),
        ],
      ),
    );
  }

  Widget _buildBlockedAppsChips() {
    const List<String> apps = <String>[
      'Instagram',
      'YouTube',
      'Facebook',
      'Snapchat',
      'LinkedIn',
      'TikTok',
    ];

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
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: const Color(0x2FFFFFFF),
                      border: Border.all(color: const Color(0x30FFFFFF)),
                    ),
                    child: Text(
                      app,
                      style: const TextStyle(color: Color(0xFFD6DBE9), fontSize: 12),
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
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: GlassContainer(
        borderRadius: 24,
        padding: const EdgeInsets.all(8),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: _blue,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.home_outlined, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Home',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const AnalyticsScreen()),
                  );
                },
                icon: const Icon(Icons.pie_chart_outline_rounded, color: Color(0xFF7A8092)),
              ),
            ),
            Expanded(
              child: IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => LegalDocumentScreen(type: LegalDocumentType.privacy),
                    ),
                  );
                },
                icon: const Icon(Icons.person_outline_rounded, color: Color(0xFF7A8092)),
              ),
            ),
          ],
        ),
      ),
    );
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
      await state.unblockForDuration(durationMinutes: mins, shouldRecordAnalytics: false);
      return;
    }

    await state.unblockForDuration(durationMinutes: 10, shouldRecordAnalytics: false);
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
                    style: const TextStyle(color: _blue, fontWeight: FontWeight.w700),
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
                          child: const Text('Cancel', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(selected),
                          style: ElevatedButton.styleFrom(backgroundColor: _blue),
                          child: const Text('Apply', style: TextStyle(color: Colors.white)),
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
    for (final String key in <String>['is_premium', 'premium', 'premium_active', 'pro_user']) {
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
    final String? action = await context.read<AppState>().consumePendingAndroidUnlockAction();

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
    final bool? unlocked = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (_) => screen),
    );

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
  }

  String _formatDuration(int seconds) {
    final int safe = seconds < 0 ? 0 : seconds;
    final int mins = safe ~/ 60;
    final int secs = safe % 60;
    return '${mins}m ${secs}s';
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
    final Color borderColor = outlined ? _HomeScreenState._blue : Colors.transparent;

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
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(9)),
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
