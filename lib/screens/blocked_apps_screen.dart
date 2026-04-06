import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/target_app.dart';
import '../providers/app_state.dart';
import 'analytics_screen.dart';
import 'home_screen.dart';

class BlockedAppsScreen extends StatelessWidget {
  const BlockedAppsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppState state = context.watch<AppState>();
    final _BlockedGlassStyle glassStyle = _BlockedGlassStyle.of(context);
    final Set<TargetApp> selected = state.selectedTrackedApps.toSet();

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[Color(0xFF0A0C13), Color(0xFF131722), Color(0xFF1A1C25)],
          ),
        ),
        child: Stack(
          children: <Widget>[
            const Positioned(
              top: -100,
              left: -60,
              child: _GlowOrb(
                size: 220,
                colors: <Color>[Color(0x443A86FF), Color(0x003A86FF)],
              ),
            ),
            const Positioned(
              bottom: 90,
              right: -70,
              child: _GlowOrb(
                size: 220,
                colors: <Color>[Color(0x33FF6F91), Color(0x00FF6F91)],
              ),
            ),
            SafeArea(
              bottom: false,
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 124),
                children: <Widget>[
                  _BlockedHeader(glassStyle: glassStyle),
                  const SizedBox(height: 24),
                  _BlockedSectionCard(
                    glassStyle: glassStyle,
                    child: Column(
                      children: TargetApp.values.map((TargetApp app) {
                        final bool enabled = selected.contains(app);
                        return _BlockedAppTile(
                          app: app,
                          enabled: enabled,
                          glassStyle: glassStyle,
                          onChanged: (bool value) {
                            unawaited(_toggleApp(context, state, selected, app, value));
                          },
                        );
                      }).toList(growable: false),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _BlockedBottomNav(glassStyle: glassStyle),
    );
  }

  Future<void> _toggleApp(
    BuildContext context,
    AppState state,
    Set<TargetApp> selected,
    TargetApp app,
    bool value,
  ) async {
    final List<TargetApp> next = TargetApp.values
        .where((TargetApp item) => value ? (selected.contains(item) || item == app) : (selected.contains(item) && item != app))
        .toList(growable: false);

    await state.setTrackedApps(next);

    if (!context.mounted) {
      return;
    }
  }
}

class _BlockedHeader extends StatelessWidget {
  const _BlockedHeader({required this.glassStyle});

  final _BlockedGlassStyle glassStyle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            _GlassIconButton(
              icon: Icons.arrow_back_ios_new_rounded,
              glassStyle: glassStyle,
              onTap: () => Navigator.of(context).maybePop(),
            ),
            const SizedBox(width: 12),
            const Text(
              'Blocked Apps',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        const Text(
          'Tap any supported app to include it in your active block list.',
          style: TextStyle(
            color: Color(0xFF96A2B9),
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _BlockedSectionCard extends StatelessWidget {
  const _BlockedSectionCard({
    required this.glassStyle,
    required this.child,
  });

  final _BlockedGlassStyle glassStyle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: glassStyle.blurSigma,
          sigmaY: glassStyle.blurSigma,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[glassStyle.surface, glassStyle.surfaceSecondary],
            ),
            border: Border.all(color: glassStyle.border),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: glassStyle.shadowOpacity),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _BlockedAppTile extends StatelessWidget {
  const _BlockedAppTile({
    required this.app,
    required this.enabled,
    required this.glassStyle,
    required this.onChanged,
  });

  final TargetApp app;
  final bool enabled;
  final _BlockedGlassStyle glassStyle;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final bool lightIcon = app == TargetApp.linkedIn || app == TargetApp.facebook;
    return Column(
      children: <Widget>[
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => onChanged(!enabled),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(13),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: <Color>[
                          app.meta.color.withValues(alpha: 0.95),
                          (lightIcon ? Colors.white : app.meta.color).withValues(alpha: lightIcon ? 0.28 : 0.72),
                        ],
                      ),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: app.meta.color.withValues(alpha: 0.20),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      app.meta.iconData,
                      color: app == TargetApp.snapchat ? Colors.black : Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      app.meta.displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Transform.scale(
                    scale: 0.92,
                    child: Switch.adaptive(
                      value: enabled,
                      activeColor: const Color(0xFF3E87FF),
                      activeTrackColor: const Color(0xFF3E87FF).withValues(alpha: 0.45),
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: Colors.white.withValues(alpha: 0.14),
                      onChanged: onChanged,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (app != TargetApp.values.last)
          Divider(
            height: 1,
            thickness: 1,
            color: Colors.white.withValues(alpha: 0.06),
          ),
      ],
    );
  }
}

class _BlockedBottomNav extends StatelessWidget {
  const _BlockedBottomNav({required this.glassStyle});

  final _BlockedGlassStyle glassStyle;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(18, 0, 18, 12),
      child: _BlockedSectionCard(
        glassStyle: glassStyle,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
          child: Row(
            children: <Widget>[
              Expanded(
                child: _BottomNavChip(
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
                child: _BottomNavChip(
                  icon: Icons.auto_graph_rounded,
                  label: 'Activity',
                  selected: false,
                  onTap: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute<void>(builder: (_) => const AnalyticsScreen()),
                    );
                  },
                ),
              ),
              Expanded(
                child: _BottomNavChip(
                  icon: Icons.block_rounded,
                  label: 'Blocked',
                  selected: true,
                  onTap: () {},
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavChip extends StatelessWidget {
  const _BottomNavChip({
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
                    fontSize: 13,
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

class _GlassIconButton extends StatelessWidget {
  const _GlassIconButton({
    required this.icon,
    required this.glassStyle,
    required this.onTap,
  });

  final IconData icon;
  final _BlockedGlassStyle glassStyle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: _BlockedSectionCard(
        glassStyle: glassStyle,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Icon(icon, color: Colors.white, size: 18),
          ),
        ),
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.colors});

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

class _BlockedGlassStyle {
  const _BlockedGlassStyle({
    required this.blurSigma,
    required this.surface,
    required this.surfaceSecondary,
    required this.border,
    required this.shadowOpacity,
  });

  final double blurSigma;
  final Color surface;
  final Color surfaceSecondary;
  final Color border;
  final double shadowOpacity;

  factory _BlockedGlassStyle.of(BuildContext context) {
    final bool isIos = defaultTargetPlatform == TargetPlatform.iOS;
    return _BlockedGlassStyle(
      blurSigma: isIos ? 26 : 18,
      surface: isIos ? const Color(0x30F4F7FF) : const Color(0x24F3F6FF),
      surfaceSecondary: isIos ? const Color(0x14AEB8D2) : const Color(0x121C2232),
      border: Colors.white.withValues(alpha: isIos ? 0.18 : 0.10),
      shadowOpacity: isIos ? 0.22 : 0.30,
    );
  }
}
