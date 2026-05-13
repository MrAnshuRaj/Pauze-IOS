import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/analytics_service.dart';
import 'onboarding_step_header.dart';

class OnboardingScreen8 extends StatefulWidget {
  const OnboardingScreen8({
    super.key,
    required this.onNext,
    required this.onSkip,
  });

  final VoidCallback onNext;
  final VoidCallback onSkip;

  @override
  State<OnboardingScreen8> createState() => _OnboardingScreen8State();
}

class _OnboardingScreen8State extends State<OnboardingScreen8>
    with TickerProviderStateMixin {
  static const List<TrapAppOption> _apps = <TrapAppOption>[
    TrapAppOption(
      id: 'instagram',
      name: 'Instagram',
      emoji: '\u{1F4F7}',
      color: Color(0xFFE1306C),
    ),
    TrapAppOption(
      id: 'youtube',
      name: 'YouTube',
      emoji: '\u25B6',
      color: Color(0xFFFF0000),
    ),
    TrapAppOption(
      id: 'tiktok',
      name: 'TikTok',
      emoji: '\u{1F3B5}',
      color: Color(0xFF000000),
    ),
    TrapAppOption(
      id: 'snapchat',
      name: 'Snapchat',
      emoji: '\u{1F47B}',
      color: Color(0xFFFFFC00),
    ),
    TrapAppOption(
      id: 'twitter',
      name: 'Twitter',
      emoji: '\u{1F426}',
      color: Color(0xFF1DA1F2),
    ),
    TrapAppOption(
      id: 'facebook',
      name: 'Facebook',
      emoji: '\u{1F44D}',
      color: Color(0xFF4267B2),
    ),
  ];

  final AnalyticsService _analyticsService = AnalyticsService();
  final Set<String> _selectedAppIds = <String>{'instagram'};
  final Set<String> _pressedAppIds = <String>{};

  late final AnimationController _entryController;
  late final Animation<double> _questionFade;
  late final Animation<Offset> _questionSlide;
  late final Animation<double> _gridFade;
  late final Animation<Offset> _gridSlide;
  late final Animation<double> _buttonFade;
  late final Animation<Offset> _buttonSlide;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1450),
    )..forward();

    _questionFade = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.08, 0.36, curve: Curves.easeOut),
    );
    _questionSlide =
        Tween<Offset>(begin: const Offset(0, -0.05), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entryController,
            curve: const Interval(0.08, 0.36, curve: Curves.easeOutCubic),
          ),
        );
    _gridFade = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.30, 0.78, curve: Curves.easeOut),
    );
    _gridSlide = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entryController,
            curve: const Interval(0.30, 0.78, curve: Curves.easeOutCubic),
          ),
        );
    _buttonFade = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.64, 0.96, curve: Curves.easeOut),
    );
    _buttonSlide = Tween<Offset>(begin: const Offset(0, 0.10), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entryController,
            curve: const Interval(0.64, 0.96, curve: Curves.easeOutCubic),
          ),
        );

    _loadSavedSelection();
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double width = mediaQuery.size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: <Widget>[
              const SizedBox(height: 12),
              OnboardingTopBar(
                currentStep: 8,
                totalSteps: 18,
                onSkip: _handleSkip,
              ),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 340),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        FadeTransition(
                          opacity: _questionFade,
                          child: SlideTransition(
                            position: _questionSlide,
                            child: Column(
                              children: <Widget>[
                                Text.rich(
                                  TextSpan(
                                    style: TextStyle(
                                      color: const Color(0xFF2E2520),
                                      fontSize: width < 360 ? 25 : 27,
                                      height: 1.12,
                                      fontWeight: FontWeight.w800,
                                    ),
                                    children: const <InlineSpan>[
                                      TextSpan(text: 'Which app '),
                                      TextSpan(
                                        text: 'traps you',
                                        style: TextStyle(
                                          color: Color(0xFFFF6B9D),
                                        ),
                                      ),
                                      TextSpan(text: '\nthe most?'),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Select all that apply',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0xFF8B8B8B),
                                    fontSize: 13,
                                    height: 1.4,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 42),
                        FadeTransition(
                          opacity: _gridFade,
                          child: SlideTransition(
                            position: _gridSlide,
                            child: GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _apps.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 12,
                                    crossAxisSpacing: 12,
                                    mainAxisExtent: 84,
                                  ),
                              itemBuilder: (BuildContext context, int index) {
                                final TrapAppOption app = _apps[index];
                                return _AnimatedAppOptionCard(
                                  app: app,
                                  isSelected: _selectedAppIds.contains(app.id),
                                  isPressed: _pressedAppIds.contains(app.id),
                                  animation: _entryController,
                                  delayStart: 0.28 + (index * 0.05),
                                  onTap: () => _toggleApp(app),
                                  onTapDown: () => _setPressed(app.id, true),
                                  onTapUp: () => _setPressed(app.id, false),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              FadeTransition(
                opacity: _buttonFade,
                child: SlideTransition(
                  position: _buttonSlide,
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: math.max(mediaQuery.padding.bottom, 12),
                    ),
                    child: _GradientPillButton(
                      label: 'Continue',
                      onPressed: _handleNext,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _loadSavedSelection() async {
    final List<String> savedApps = await _analyticsService
        .loadOnboardingSelectedTrapApps();
    if (!mounted || savedApps.isEmpty) {
      return;
    }

    final Set<String> validIds = _apps
        .map((TrapAppOption app) => app.id)
        .toSet();
    setState(() {
      _selectedAppIds
        ..clear()
        ..addAll(savedApps.where(validIds.contains));
      if (_selectedAppIds.isEmpty) {
        _selectedAppIds.add('instagram');
      }
    });
  }

  void _toggleApp(TrapAppOption app) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_selectedAppIds.contains(app.id)) {
        _selectedAppIds.remove(app.id);
      } else {
        _selectedAppIds.add(app.id);
      }
    });
  }

  void _setPressed(String appId, bool pressed) {
    setState(() {
      if (pressed) {
        _pressedAppIds.add(appId);
      } else {
        _pressedAppIds.remove(appId);
      }
    });
  }

  Future<void> _handleNext() async {
    if (_selectedAppIds.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Select at least one app')));
      return;
    }

    HapticFeedback.lightImpact();
    await _analyticsService.saveOnboardingSelectedTrapApps(
      _selectedAppIds.toList(growable: false),
    );
    widget.onNext();
  }

  void _handleSkip() {
    HapticFeedback.lightImpact();
    widget.onSkip();
  }
}

class _AnimatedAppOptionCard extends StatelessWidget {
  const _AnimatedAppOptionCard({
    required this.app,
    required this.isSelected,
    required this.isPressed,
    required this.animation,
    required this.delayStart,
    required this.onTap,
    required this.onTapDown,
    required this.onTapUp,
  });

  final TrapAppOption app;
  final bool isSelected;
  final bool isPressed;
  final Animation<double> animation;
  final double delayStart;
  final VoidCallback onTap;
  final VoidCallback onTapDown;
  final VoidCallback onTapUp;

  @override
  Widget build(BuildContext context) {
    final double delayEnd = (delayStart + 0.24).clamp(0.0, 1.0);
    final Animation<double> fade = CurvedAnimation(
      parent: animation,
      curve: Interval(
        delayStart.clamp(0.0, 1.0),
        delayEnd,
        curve: Curves.easeOut,
      ),
    );
    final Animation<double> scale = Tween<double>(begin: 0.90, end: 1.0)
        .animate(
          CurvedAnimation(
            parent: animation,
            curve: Interval(
              delayStart.clamp(0.0, 1.0),
              delayEnd,
              curve: Curves.easeOutBack,
            ),
          ),
        );

    return FadeTransition(
      opacity: fade,
      child: ScaleTransition(
        scale: scale,
        child: AnimatedScale(
          scale: isPressed ? 0.96 : 1.0,
          duration: const Duration(milliseconds: 110),
          curve: Curves.easeOut,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              onTapDown: (_) => onTapDown(),
              onTapUp: (_) => onTapUp(),
              onTapCancel: onTapUp,
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: <Color>[Color(0xFFFF8C42), Color(0xFFFF6B9D)],
                        )
                      : null,
                  color: isSelected ? null : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFFFF6B9D)
                        : const Color(0xFFE0E0E0),
                    width: 1.4,
                  ),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(
                      color: Color(0x1A2E2520),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      app.emoji,
                      style: TextStyle(
                        color: app.color,
                        fontSize: 26,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      app.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF2E2520),
                        fontSize: 13,
                        height: 1.1,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GradientPillButton extends StatefulWidget {
  const _GradientPillButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  State<_GradientPillButton> createState() => _GradientPillButtonState();
}

class _GradientPillButtonState extends State<_GradientPillButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 0.985 : 1,
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onPressed,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          borderRadius: BorderRadius.circular(999),
          child: Ink(
            height: 58,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: <Color>[Color(0xFFFF8C42), Color(0xFFFF5F8F)],
              ),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color(0x332E2520),
                  blurRadius: 22,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: Center(
              child: Text(
                widget.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TrapAppOption {
  const TrapAppOption({
    required this.id,
    required this.name,
    required this.emoji,
    required this.color,
  });

  final String id;
  final String name;
  final String emoji;
  final Color color;
}
