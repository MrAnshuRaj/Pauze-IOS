import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/target_app.dart';
import '../providers/app_state.dart';
import '../widgets/action_card.dart';
import '../widgets/app_icon_badge.dart';
import '../widgets/unlock_timer_banner.dart';
import 'analytics_screen.dart';
import 'breathing_screen.dart';
import 'package:scroll_rok/screens/game_screen.dart';
import 'safe_mode/safe_instagram_screen.dart';
import 'safe_mode/safe_youtube_screen.dart';

import 'legal_consent_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
      if (Platform.isAndroid) {
        context.read<AppState>().refreshAndroidAccessibilityStatus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppState state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scroll Rok'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Analytics',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const AnalyticsScreen(),
                ),
              );
            },
            icon: const Icon(Icons.insights_rounded),
          ),
          PopupMenuButton<String>(
            tooltip: 'Legal',
            icon: const Icon(Icons.description_outlined),
            onSelected: (String value) {
              if (value == 'privacy') {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        LegalDocumentScreen(type: LegalDocumentType.privacy),
                  ),
                );
                return;
              }

              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) =>
                      LegalDocumentScreen(type: LegalDocumentType.terms),
                ),
              );
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'privacy',
                child: Text('Privacy Policy'),
              ),
              const PopupMenuItem<String>(
                value: 'terms',
                child: Text('Terms & Conditions'),
              ),
            ],
          ),
        ],
      ),
      body: state.isReady
          ? RefreshIndicator(
              onRefresh: () => context.read<AppState>().refreshUsageFromNative(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: <Widget>[
                  if (Platform.isAndroid && !state.androidAccessibilityEnabled)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFFB74D)),
                      ),
                      child: const Text(
                        'Enable Accessibility Service for Android app blocking to work.',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  _buildStatusCard(context, state),
                  const SizedBox(height: 14),
                  _buildSafeModeCard(context, state),
                  const SizedBox(height: 14),
                  if (state.isTemporarilyUnlocked)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: UnlockTimerBanner(
                        remaining: state.unlockRemaining,
                        onLockNow: () async {
                          await context.read<AppState>().lockImmediately();
                        },
                      ),
                    ),
                  _buildAppSelectionCard(context, state),
                  const SizedBox(height: 14),
                  _buildScheduleCard(context, state),
                  const SizedBox(height: 14),
                  ActionCard(
                    title: 'Breathing Unlock',
                    subtitle: 'Complete a 2-minute guided breathing session',
                    icon: Icons.self_improvement_rounded,
                    color: const Color(0xFF00897B),
                    onTap: () {
                      unawaited(_openUnlockChallenge(const BreathingScreen()));
                    },
                  ),
                  const SizedBox(height: 12),
                  ActionCard(
                    title: 'Mini Games Unlock',
                    subtitle: 'Complete a short brain game to unlock apps',
                    icon: Icons.extension_rounded,
                    color: const Color(0xFFFF7043),
                    onTap: () {
                      unawaited(_openUnlockChallenge(const GameScreen()));
                    },
                  ),
                ],
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Future<void> _consumePendingUnlockActionIfAny() async {
    final String? action =
        await context.read<AppState>().consumePendingAndroidUnlockAction();

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
      MaterialPageRoute<bool>(
        builder: (_) => screen,
      ),
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

  Widget _buildStatusCard(BuildContext context, AppState state) {
    final ThemeData theme = Theme.of(context);
    final bool blocked = state.isBlockingEnabled && !state.isTemporarilyUnlocked;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  blocked ? Icons.shield_rounded : Icons.shield_outlined,
                  color: blocked ? const Color(0xFFD32F2F) : theme.colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    blocked ? 'Blocking Active' : 'Blocking Paused',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (state.isBusy)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              Platform.isAndroid
                  ? (state.androidAccessibilityEnabled
                      ? 'Accessibility service enabled'
                      : 'Enable Accessibility permission to enforce blocking')
                  : (state.permissionGranted
                      ? 'FamilyControls permission granted'
                      : 'Permission required before blocking can be enforced'),
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 14),
            Row(
              children: <Widget>[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final bool granted =
                          await context.read<AppState>().requestFamilyPermission();
                      if (!context.mounted) {
                        return;
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            granted
                                ? 'Permission granted successfully'
                                : Platform.isAndroid
                                    ? 'Open Accessibility settings and enable ScrollRok App Blocker'
                                    : 'Permission not granted',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.verified_user_rounded),
                    label: Text(
                      Platform.isAndroid ? 'Enable Accessibility' : 'Grant Permission',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: state.useSafeMode
                        ? null
                        : (state.permissionGranted || Platform.isAndroid)
                            ? () async {
                                if (state.isTemporarilyUnlocked) {
                                  await context.read<AppState>().lockImmediately();
                                  return;
                                }
                                await context.read<AppState>().blockAppsNow();
                              }
                            : null,
                    icon: Icon(
                      state.isTemporarilyUnlocked
                          ? Icons.lock_rounded
                          : Icons.block_rounded,
                    ),
                    label: Text(
                      state.useSafeMode
                          ? 'Safe Mode Enabled'
                          : (state.isTemporarilyUnlocked ? 'Lock Now' : 'Block Apps'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  
  Widget _buildSafeModeCard(BuildContext context, AppState state) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Icon(Icons.safety_check_rounded),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Safe Social Mode',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                Switch(
                  value: state.useSafeMode,
                  onChanged: (bool value) {
                    unawaited(context.read<AppState>().setUseSafeMode(value));
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Use in-app safe browsing instead of full app blocking for Instagram and YouTube.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: state.useSafeMode
                        ? () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const SafeInstagramScreen(),
                              ),
                            );
                          }
                        : null,
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text('Safe Instagram'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: state.useSafeMode
                        ? () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const SafeYouTubeScreen(),
                              ),
                            );
                          }
                        : null,
                    icon: const Icon(Icons.play_circle_outline_rounded),
                    label: const Text('Safe YouTube'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildAppSelectionCard(BuildContext context, AppState state) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Icon(Icons.apps_rounded),
                const SizedBox(width: 8),
                Text(
                  'Blocked Apps',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () async {
                    final int count =
                        await context.read<AppState>().selectAppsFromPicker();
                    if (!context.mounted) {
                      return;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          Platform.isAndroid
                              ? 'Blocked packages synced ($count apps)'
                              : 'Family picker selection saved ($count items)',
                        ),
                      ),
                    );
                  },
                  child: Text(Platform.isAndroid ? 'Sync' : 'Open Picker'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: state.selectedTrackedApps
                  .map((TargetApp app) => AppIconBadge(app: app))
                  .toList(growable: false),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: () => _showTrackedAppsSheet(context),
              icon: const Icon(Icons.tune_rounded),
              label: const Text('Choose Tracked App Labels'),
            ),
            if (state.nativeSelectedLabels.isNotEmpty) ...<Widget>[
              const SizedBox(height: 14),
              Text(
                'Picker Labels',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: state.nativeSelectedLabels
                    .map((String label) => _labelChip(context, label))
                    .toList(growable: false),
              ),
            ],
            if (state.nativeLabelMappings.isNotEmpty) ...<Widget>[
              const SizedBox(height: 12),
              Text(
                'Mapped Display Names',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              ...state.nativeSelectedLabels
                  .where((String label) => state.nativeLabelMappings.containsKey(label))
                  .map((String label) {
                final TargetApp app = state.nativeLabelMappings[label]!;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          label,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      const Icon(Icons.arrow_right_alt_rounded, size: 18),
                      const SizedBox(width: 4),
                      Icon(app.meta.iconData, size: 16, color: app.meta.color),
                      const SizedBox(width: 6),
                      Text(
                        app.meta.displayName,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                );
              }),
            ],
            if (state.unmappedNativeLabels.isNotEmpty) ...<Widget>[
              const SizedBox(height: 8),
              Text(
                'Unmapped labels: ${state.unmappedNativeLabels.join(', ')}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFFD84315),
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleCard(BuildContext context, AppState state) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Icon(Icons.schedule_rounded),
                const SizedBox(width: 8),
                Text(
                  'Focus Schedule',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (state.focusSchedule != null)
              Text(
                'Active: ${state.focusSchedule!.startLabel} to ${state.focusSchedule!.endLabel}',
                style: Theme.of(context).textTheme.bodyMedium,
              )
            else
              Text(
                'No schedule configured',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: Platform.isAndroid ? null : () => _configureSchedule(context),
                    icon: const Icon(Icons.event_repeat_rounded),
                    label: Text(Platform.isAndroid ? 'iOS only' : 'Set Schedule'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: state.focusSchedule == null || Platform.isAndroid
                        ? null
                        : () => context.read<AppState>().clearSchedule(),
                    icon: const Icon(Icons.delete_outline_rounded),
                    label: const Text('Clear'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _labelChip(BuildContext context, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }

  Future<void> _showTrackedAppsSheet(BuildContext context) async {
    final AppState state = context.read<AppState>();
    final Set<TargetApp> selected = state.selectedTrackedApps.toSet();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'Tracked App Labels',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 10),
                  ...TargetApp.values.map((TargetApp app) {
                    return CheckboxListTile(
                      value: selected.contains(app),
                      title: Text(app.meta.displayName),
                      secondary: Icon(app.meta.iconData, color: app.meta.color),
                      onChanged: (bool? value) {
                        setSheetState(() {
                          if (value == true) {
                            selected.add(app);
                          } else if (selected.length > 1) {
                            selected.remove(app);
                          }
                        });
                      },
                    );
                  }),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        await state.setTrackedApps(
                          selected.toList(growable: false),
                        );
                        if (!context.mounted) {
                          return;
                        }
                        Navigator.of(context).pop();
                      },
                      child: const Text('Save Selection'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _configureSchedule(BuildContext context) async {
    final TimeOfDay? start = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (start == null || !context.mounted) {
      return;
    }

    final TimeOfDay? end = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 18, minute: 0),
    );
    if (end == null || !context.mounted) {
      return;
    }

    await context.read<AppState>().saveSchedule(start: start, end: end);

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Focus schedule saved: ${start.format(context)} - ${end.format(context)}',
        ),
      ),
    );
  }
}













