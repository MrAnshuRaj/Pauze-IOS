import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'onboarding_step_header.dart';

class OnboardingScreen1 extends StatefulWidget {
  const OnboardingScreen1({
    super.key,
    required this.onNext,
    required this.onSkip,
  });

  final VoidCallback onNext;
  final VoidCallback onSkip;

  @override
  State<OnboardingScreen1> createState() => _OnboardingScreen1State();
}

class _OnboardingScreen1State extends State<OnboardingScreen1>
    with TickerProviderStateMixin {
  static const List<_FloatingCardConfig> _cardConfigs = <_FloatingCardConfig>[
    _FloatingCardConfig(
      leftFactor: -0.10,
      width: 248,
      height: 430,
      rotation: -0.035,
      speed: 0.84,
      delay: 0.05,
      opacity: 0.26,
    ),
    _FloatingCardConfig(
      leftFactor: 0.18,
      width: 236,
      height: 474,
      rotation: 0.028,
      speed: 1.02,
      delay: 0.42,
      opacity: 0.20,
    ),
    _FloatingCardConfig(
      leftFactor: 0.47,
      width: 262,
      height: 492,
      rotation: 0.018,
      speed: 0.90,
      delay: 0.21,
      opacity: 0.24,
    ),
    _FloatingCardConfig(
      leftFactor: 0.66,
      width: 230,
      height: 404,
      rotation: -0.022,
      speed: 1.10,
      delay: 0.62,
      opacity: 0.18,
    ),
    _FloatingCardConfig(
      leftFactor: 0.03,
      width: 286,
      height: 512,
      rotation: -0.012,
      speed: 0.76,
      delay: 0.70,
      opacity: 0.15,
    ),
    _FloatingCardConfig(
      leftFactor: 0.55,
      width: 244,
      height: 452,
      rotation: 0.040,
      speed: 0.96,
      delay: 0.86,
      opacity: 0.20,
    ),
    _FloatingCardConfig(
      leftFactor: 0.28,
      width: 252,
      height: 468,
      rotation: -0.026,
      speed: 1.08,
      delay: 0.12,
      opacity: 0.17,
    ),
    _FloatingCardConfig(
      leftFactor: 0.78,
      width: 236,
      height: 420,
      rotation: 0.024,
      speed: 0.88,
      delay: 0.51,
      opacity: 0.14,
    ),
  ];

  late final AnimationController _backgroundController;
  late final AnimationController _introController;
  late final Animation<double> _headlineFade;
  late final Animation<Offset> _headlineSlide;
  late final Animation<double> _subtitleFade;
  late final Animation<Offset> _subtitleSlide;
  late final Animation<double> _buttonFade;
  late final Animation<Offset> _buttonSlide;

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat();

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..forward();

    _headlineFade = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.18, 0.55, curve: Curves.easeOut),
    );
    _headlineSlide =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _introController,
            curve: const Interval(0.18, 0.55, curve: Curves.easeOutCubic),
          ),
        );
    _subtitleFade = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.40, 0.72, curve: Curves.easeOut),
    );
    _subtitleSlide =
        Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _introController,
            curve: const Interval(0.40, 0.72, curve: Curves.easeOutCubic),
          ),
        );
    _buttonFade = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.56, 0.96, curve: Curves.easeOut),
    );
    _buttonSlide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _introController,
            curve: const Interval(0.56, 0.96, curve: Curves.easeOutCubic),
          ),
        );
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _introController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final Size size = mediaQuery.size;
    final double headlineSize = size.width < 360 ? 38 : 44;
    final double subtitleSize = size.width < 360 ? 15 : 17;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F5),
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: RepaintBoundary(
                child: AnimatedBuilder(
                  animation: _backgroundController,
                  builder: (BuildContext context, Widget? child) {
                    return LayoutBuilder(
                      builder:
                          (BuildContext context, BoxConstraints constraints) {
                            final Size layoutSize = constraints.biggest;
                            return ClipRect(
                              child: Stack(
                                children: _cardConfigs
                                    .map((_FloatingCardConfig config) {
                                      return _buildFloatingCard(
                                        layoutSize,
                                        config,
                                      );
                                    })
                                    .toList(growable: false),
                              ),
                            );
                          },
                    );
                  },
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      const Color(0xFFFFF9F5).withValues(alpha: 0.88),
                      const Color(0xFFFFF9F5).withValues(alpha: 0.96),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 12),
                  OnboardingTopBar(
                    currentStep: 1,
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
                              opacity: _headlineFade,
                              child: SlideTransition(
                                position: _headlineSlide,
                                child: Column(
                                  children: <Widget>[
                                    Text(
                                      'Reels. Shorts.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: const Color(0xFF2E2520),
                                        fontSize: headlineSize,
                                        height: 1.0,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Scroll. Repeat.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: const Color(0xFFFF6B9D),
                                        fontSize: headlineSize,
                                        height: 1.0,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -1.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 26),
                            FadeTransition(
                              opacity: _subtitleFade,
                              child: SlideTransition(
                                position: _subtitleSlide,
                                child: Text(
                                  'Ever feel like you didn\'t mean to keep going?',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: const Color(0xFF6B6057),
                                    fontSize: subtitleSize,
                                    height: 1.5,
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.w500,
                                  ),
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
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingCard(Size size, _FloatingCardConfig config) {
    final double progress =
        ((_backgroundController.value * config.speed) + config.delay) % 1.0;
    final double travelStart = -config.height * 0.92;
    final double travelEnd = size.height + config.height * 0.92;
    final double top = lerpDouble(travelStart, travelEnd, progress)!;
    final double left = size.width * config.leftFactor;
    final double wave = math.sin((progress * math.pi * 2) + (config.delay * 5));
    final double opacity = (config.opacity + (wave * 0.05))
        .clamp(0.10, 0.30)
        .toDouble();
    final double rotation = config.rotation + (wave * 0.012);

    return Positioned(
      left: left,
      top: top,
      child: Transform.rotate(
        angle: rotation,
        child: Opacity(
          opacity: opacity,
          child: Container(
            width: config.width,
            height: config.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[Color(0xFFFFE5EC), Color(0xFFFFF5F7)],
              ),
              border: Border.all(color: const Color(0xFFFFB6C1), width: 1.2),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 18,
                  offset: Offset(0, 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleNext() {
    HapticFeedback.lightImpact();
    widget.onNext();
  }

  void _handleSkip() {
    HapticFeedback.lightImpact();
    widget.onSkip();
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

class _FloatingCardConfig {
  const _FloatingCardConfig({
    required this.leftFactor,
    required this.width,
    required this.height,
    required this.rotation,
    required this.speed,
    required this.delay,
    required this.opacity,
  });

  final double leftFactor;
  final double width;
  final double height;
  final double rotation;
  final double speed;
  final double delay;
  final double opacity;
}
