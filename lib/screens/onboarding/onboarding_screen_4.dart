import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'onboarding_screen_2.dart';
import 'onboarding_step_header.dart';

class OnboardingScreen4 extends StatefulWidget {
  const OnboardingScreen4({
    super.key,
    required this.onNext,
    required this.onSkip,
  });

  final VoidCallback onNext;
  final VoidCallback onSkip;

  @override
  State<OnboardingScreen4> createState() => _OnboardingScreen4State();
}

class _OnboardingScreen4State extends State<OnboardingScreen4>
    with TickerProviderStateMixin {
  static const List<_CardStackConfig> _cardConfigs = <_CardStackConfig>[
    _CardStackConfig(
      leftFactor: -0.08,
      topFactor: 0.36,
      width: 214,
      height: 344,
      rotation: 0.0,
      speed: 0.62,
      delay: 0.10,
      drift: 14,
      opacity: 0.34,
    ),
    _CardStackConfig(
      leftFactor: 0.24,
      topFactor: 0.26,
      width: 222,
      height: 358,
      rotation: 0.0,
      speed: 0.88,
      delay: 0.34,
      drift: 18,
      opacity: 0.30,
    ),
    _CardStackConfig(
      leftFactor: 0.56,
      topFactor: 0.14,
      width: 202,
      height: 328,
      rotation: 0.0,
      speed: 1.02,
      delay: 0.58,
      drift: 20,
      opacity: 0.28,
    ),
    _CardStackConfig(
      leftFactor: 0.24,
      topFactor: 0.54,
      width: 222,
      height: 360,
      rotation: 0.0,
      speed: 0.74,
      delay: 0.76,
      drift: 16,
      opacity: 0.22,
    ),
    _CardStackConfig(
      leftFactor: -0.02,
      topFactor: 0.58,
      width: 206,
      height: 324,
      rotation: 0.0,
      speed: 0.56,
      delay: 0.02,
      drift: 12,
      opacity: 0.18,
    ),
  ];

  late final AnimationController _cardsController;
  late final AnimationController _entryController;
  late final AnimationController _floatController;
  late final Animation<double> _mascotFade;
  late final Animation<double> _mascotScale;
  late final Animation<double> _headlineFade;
  late final Animation<Offset> _headlineSlide;
  late final Animation<double> _subtitleFade;
  late final Animation<Offset> _subtitleSlide;
  late final Animation<double> _buttonFade;
  late final Animation<Offset> _buttonSlide;

  @override
  void initState() {
    super.initState();
    _cardsController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1450),
    )..forward();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();

    _mascotFade = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.08, 0.32, curve: Curves.easeOut),
    );
    _mascotScale = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.08, 0.34, curve: Curves.easeOutBack),
      ),
    );
    _headlineFade = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.30, 0.58, curve: Curves.easeOut),
    );
    _headlineSlide =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entryController,
            curve: const Interval(0.30, 0.58, curve: Curves.easeOutCubic),
          ),
        );
    _subtitleFade = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.46, 0.72, curve: Curves.easeOut),
    );
    _subtitleSlide =
        Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entryController,
            curve: const Interval(0.46, 0.72, curve: Curves.easeOutCubic),
          ),
        );
    _buttonFade = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.62, 0.96, curve: Curves.easeOut),
    );
    _buttonSlide = Tween<Offset>(begin: const Offset(0, 0.10), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entryController,
            curve: const Interval(0.62, 0.96, curve: Curves.easeOutCubic),
          ),
        );
  }

  @override
  void dispose() {
    _cardsController.dispose();
    _entryController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double width = mediaQuery.size.width;
    final double headlineSize = width < 360 ? 36 : 42;
    final double subtitleSize = width < 360 ? 16 : 18;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F5),
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: RepaintBoundary(
                child: AnimatedBuilder(
                  animation: _cardsController,
                  builder: (BuildContext context, Widget? child) {
                    return LayoutBuilder(
                      builder:
                          (BuildContext context, BoxConstraints constraints) {
                            final Size size = constraints.biggest;
                            return ClipRect(
                              child: Stack(
                                children: _cardConfigs
                                    .map(
                                      (_CardStackConfig config) =>
                                          _buildBackgroundCard(size, config),
                                    )
                                    .toList(growable: false),
                              ),
                            );
                          },
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 12),
                  OnboardingTopBar(
                    currentStep: 4,
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
                            const SizedBox(height: 14),
                            FadeTransition(
                              opacity: _mascotFade,
                              child: ScaleTransition(
                                scale: _mascotScale,
                                child: AnimatedBuilder(
                                  animation: _floatController,
                                  builder:
                                      (BuildContext context, Widget? child) {
                                        final double wave = math.sin(
                                          _floatController.value * math.pi * 2,
                                        );
                                        final double wobble = math.sin(
                                          _floatController.value * math.pi * 4,
                                        );
                                        return Transform.translate(
                                          offset: Offset(
                                            wobble * 0.8,
                                            wave * -6,
                                          ),
                                          child: Transform.rotate(
                                            angle: wobble * 0.015,
                                            child: child,
                                          ),
                                        );
                                      },
                                  child: const PauMascot(
                                    state: 'worried',
                                    size: 142,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 34),
                            FadeTransition(
                              opacity: _headlineFade,
                              child: SlideTransition(
                                position: _headlineSlide,
                                child: Text.rich(
                                  TextSpan(
                                    style: TextStyle(
                                      color: const Color(0xFF2E2520),
                                      fontSize: headlineSize,
                                      height: 1.03,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -1.05,
                                    ),
                                    children: const <InlineSpan>[
                                      TextSpan(text: 'One turns into '),
                                      TextSpan(
                                        text: 'many.',
                                        style: TextStyle(
                                          color: Color(0xFFFF6B9D),
                                        ),
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            FadeTransition(
                              opacity: _subtitleFade,
                              child: SlideTransition(
                                position: _subtitleSlide,
                                child: Text(
                                  'Focus starts slipping.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: const Color(0xFFFF8C42),
                                    fontSize: subtitleSize,
                                    height: 1.45,
                                    fontStyle: FontStyle.italic,
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

  Widget _buildBackgroundCard(Size size, _CardStackConfig config) {
    final double progress =
        ((_cardsController.value * config.speed) + config.delay) % 1.0;
    final double wave = math.sin(progress * math.pi * 2);
    final double driftY = wave * config.drift;
    final double driftX = math.cos(progress * math.pi * 2) * 3.0;
    final double opacity = (config.opacity + (wave * 0.025))
        .clamp(0.14, 0.38)
        .toDouble();

    return Positioned(
      left: (size.width * config.leftFactor) + driftX,
      top: (size.height * config.topFactor) + driftY,
      child: Transform.rotate(
        angle: config.rotation,
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
              border: Border.all(
                color: const Color(0xFFFFB6C1).withValues(alpha: 0.82),
                width: 1.1,
              ),
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

class _CardStackConfig {
  const _CardStackConfig({
    required this.leftFactor,
    required this.topFactor,
    required this.width,
    required this.height,
    required this.rotation,
    required this.speed,
    required this.delay,
    required this.drift,
    required this.opacity,
  });

  final double leftFactor;
  final double topFactor;
  final double width;
  final double height;
  final double rotation;
  final double speed;
  final double delay;
  final double drift;
  final double opacity;
}
