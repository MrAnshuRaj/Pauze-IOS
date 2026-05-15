import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'onboarding_screen_2.dart';
import 'onboarding_step_header.dart';

class OnboardingScreen16 extends StatefulWidget {
  const OnboardingScreen16({
    super.key,
    required this.onNext,
    required this.onSkip,
  });

  final VoidCallback onNext;
  final VoidCallback onSkip;

  @override
  State<OnboardingScreen16> createState() => _OnboardingScreen16State();
}

class _OnboardingScreen16State extends State<OnboardingScreen16>
    with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final AnimationController _glowController;
  late final AnimationController _floatController;
  late final Animation<double> _mascotFade;
  late final Animation<double> _mascotScale;
  late final Animation<double> _lineOneFade;
  late final Animation<Offset> _lineOneSlide;
  late final Animation<double> _lineTwoFade;
  late final Animation<Offset> _lineTwoSlide;
  late final Animation<double> _lineThreeFade;
  late final Animation<Offset> _lineThreeSlide;
  late final Animation<double> _buttonFade;
  late final Animation<Offset> _buttonSlide;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..forward();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat();

    _mascotFade = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.04, 0.28, curve: Curves.easeOut),
    );
    _mascotScale = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.04, 0.32, curve: ElasticOutCurve(0.90)),
      ),
    );
    _lineOneFade = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.28, 0.50, curve: Curves.easeOut),
    );
    _lineOneSlide =
        Tween<Offset>(begin: const Offset(0, 0.10), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entryController,
            curve: const Interval(0.28, 0.50, curve: Curves.easeOutCubic),
          ),
        );
    _lineTwoFade = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.40, 0.62, curve: Curves.easeOut),
    );
    _lineTwoSlide =
        Tween<Offset>(begin: const Offset(0, 0.10), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entryController,
            curve: const Interval(0.40, 0.62, curve: Curves.easeOutCubic),
          ),
        );
    _lineThreeFade = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.50, 0.76, curve: Curves.easeOut),
    );
    _lineThreeSlide =
        Tween<Offset>(begin: const Offset(0, 0.10), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entryController,
            curve: const Interval(0.50, 0.76, curve: Curves.easeOutCubic),
          ),
        );
    _buttonFade = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.68, 0.98, curve: Curves.easeOut),
    );
    _buttonSlide = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entryController,
            curve: const Interval(0.68, 0.98, curve: Curves.easeOutCubic),
          ),
        );
  }

  @override
  void dispose() {
    _entryController.dispose();
    _glowController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double width = mediaQuery.size.width;
    final bool compact = width < 360;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F3EE),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[Color(0x66FFE5EC), Color(0xFFF7F3EE)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: <Widget>[
                const SizedBox(height: 12),
                OnboardingTopBar(
                  currentStep: 16,
                  totalSteps: 18,
                  onSkip: _handleSkip,
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints constraints) {
                      return SingleChildScrollView(
                        padding: EdgeInsets.only(
                          top: compact ? 24 : 38,
                          bottom: compact ? 20 : 28,
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 340),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  FadeTransition(
                                    opacity: _mascotFade,
                                    child: ScaleTransition(
                                      scale: _mascotScale,
                                      child: AnimatedBuilder(
                                        animation: Listenable.merge(
                                          <Listenable>[
                                            _glowController,
                                            _floatController,
                                          ],
                                        ),
                                        builder:
                                            (
                                              BuildContext context,
                                              Widget? child,
                                            ) {
                                              final double glowWave = math.sin(
                                                _glowController.value *
                                                    math.pi *
                                                    2,
                                              );
                                              final double glowScale =
                                                  1.0 +
                                                  (((glowWave + 1) / 2) * 0.30);
                                              final double glowOpacity =
                                                  0.30 +
                                                  (((glowWave + 1) / 2) * 0.20);

                                              final double floatWave = math.sin(
                                                _floatController.value *
                                                    math.pi *
                                                    2,
                                              );
                                              final double translateY =
                                                  floatWave * -10;
                                              final double pauScale =
                                                  1.0 +
                                                  (((floatWave + 1) / 2) *
                                                      0.05);

                                              return SizedBox(
                                                width: compact ? 220 : 250,
                                                height: compact ? 210 : 240,
                                                child: Stack(
                                                  alignment: Alignment.center,
                                                  children: <Widget>[
                                                    Opacity(
                                                      opacity: glowOpacity,
                                                      child: Transform.scale(
                                                        scale: glowScale,
                                                        child:
                                                            const _SoftZenGlow(),
                                                      ),
                                                    ),
                                                    const _SparkleCluster(),
                                                    Transform.translate(
                                                      offset: Offset(
                                                        0,
                                                        translateY,
                                                      ),
                                                      child: Transform.scale(
                                                        scale: pauScale,
                                                        child: child,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                        child: PauMascot(
                                          state: 'zen',
                                          size: compact ? 150 : 178,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: compact ? 20 : 28),
                                  FadeTransition(
                                    opacity: _lineOneFade,
                                    child: SlideTransition(
                                      position: _lineOneSlide,
                                      child: Text(
                                        'Less mindless scrolling',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: const Color(0xFF2E2520),
                                          fontSize: compact ? 24 : 29,
                                          height: 1.18,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: -0.9,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: compact ? 10 : 14),
                                  FadeTransition(
                                    opacity: _lineTwoFade,
                                    child: SlideTransition(
                                      position: _lineTwoSlide,
                                      child: Text(
                                        'Clearer mind',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: const Color(0xFFFF8C42),
                                          fontSize: compact ? 24 : 29,
                                          height: 1.18,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: -0.9,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: compact ? 10 : 14),
                                  FadeTransition(
                                    opacity: _lineThreeFade,
                                    child: SlideTransition(
                                      position: _lineThreeSlide,
                                      child: Text.rich(
                                        TextSpan(
                                          style: TextStyle(
                                            color: const Color(0xFF2E2520),
                                            fontSize: compact ? 24 : 29,
                                            height: 1.18,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: -0.9,
                                          ),
                                          children: const <InlineSpan>[
                                            TextSpan(text: 'More '),
                                            TextSpan(
                                              text: 'time',
                                              style: TextStyle(
                                                color: Color(0xFFFF6B9D),
                                              ),
                                            ),
                                            TextSpan(
                                              text: ' for what\nmatters',
                                            ),
                                          ],
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
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

class _SoftZenGlow extends StatelessWidget {
  const _SoftZenGlow();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 185,
      height: 185,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: <Color>[
            Color(0x66FFE5EC),
            Color(0x55FFB6C1),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

class _SparkleCluster extends StatelessWidget {
  const _SparkleCluster();

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: <Widget>[
        _Sparkle(
          top: 34,
          left: 44,
          delay: 0.0,
          color: Color(0xFF8E8178),
          size: 16,
        ),
        _Sparkle(
          top: 60,
          left: 150,
          delay: 0.7,
          color: Color(0xFF5F5550),
          size: 18,
        ),
        _Sparkle(
          top: 126,
          left: 164,
          delay: 1.4,
          color: Color(0xFF9A8E86),
          size: 14,
        ),
      ],
    );
  }
}

class _Sparkle extends StatefulWidget {
  const _Sparkle({
    required this.top,
    required this.left,
    required this.delay,
    required this.color,
    required this.size,
  });

  final double top;
  final double left;
  final double delay;
  final Color color;
  final double size;

  @override
  State<_Sparkle> createState() => _SparkleState();
}

class _SparkleState extends State<_Sparkle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.top,
      left: widget.left,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget? child) {
          final double progress = (_controller.value + widget.delay / 3) % 1.0;
          final double opacity = math.sin(progress * math.pi).clamp(0.0, 1.0);
          final double scale = 0.5 + (math.sin(progress * math.pi) * 0.5);
          final double rotation = progress * math.pi * 2;

          return Opacity(
            opacity: opacity,
            child: Transform.rotate(
              angle: rotation,
              child: Transform.scale(scale: scale, child: child),
            ),
          );
        },
        child: Text(
          '\u2726',
          style: TextStyle(
            color: widget.color,
            fontSize: widget.size,
            height: 1,
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
            width: double.infinity,
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
