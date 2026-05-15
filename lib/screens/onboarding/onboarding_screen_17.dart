import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'onboarding_screen_2.dart';
import 'onboarding_step_header.dart';

class OnboardingScreen17 extends StatefulWidget {
  const OnboardingScreen17({
    super.key,
    required this.onNext,
    required this.onSkip,
  });

  final VoidCallback onNext;
  final VoidCallback onSkip;

  @override
  State<OnboardingScreen17> createState() => _OnboardingScreen17State();
}

class _OnboardingScreen17State extends State<OnboardingScreen17>
    with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final AnimationController _wobbleController;
  late final AnimationController _ctaGlowController;
  late final Animation<double> _mascotFade;
  late final Animation<double> _mascotScale;
  late final Animation<double> _headlineFade;
  late final Animation<Offset> _headlineSlide;
  late final Animation<double> _subtitleFade;
  late final Animation<Offset> _subtitleSlide;
  late final Animation<double> _ctaFade;
  late final Animation<Offset> _ctaSlide;
  late final Animation<double> _buttonFade;
  late final Animation<Offset> _buttonSlide;
  late final Animation<double> _wobbleRotation;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..forward();
    _wobbleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();
    _ctaGlowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _mascotFade = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.04, 0.28, curve: Curves.easeOut),
    );
    _mascotScale = Tween<double>(begin: 0.90, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.04, 0.32, curve: Curves.easeOutBack),
      ),
    );
    _headlineFade = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.28, 0.52, curve: Curves.easeOut),
    );
    _headlineSlide =
        Tween<Offset>(begin: const Offset(0, 0.10), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entryController,
            curve: const Interval(0.28, 0.52, curve: Curves.easeOutCubic),
          ),
        );
    _subtitleFade = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.40, 0.64, curve: Curves.easeOut),
    );
    _subtitleSlide =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entryController,
            curve: const Interval(0.40, 0.64, curve: Curves.easeOutCubic),
          ),
        );
    _ctaFade = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.54, 0.78, curve: Curves.easeOut),
    );
    _ctaSlide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entryController,
            curve: const Interval(0.54, 0.78, curve: Curves.easeOutCubic),
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
    _wobbleRotation =
        TweenSequence<double>(<TweenSequenceItem<double>>[
          TweenSequenceItem<double>(
            tween: Tween<double>(begin: 0.0, end: 5 * math.pi / 180),
            weight: 1,
          ),
          TweenSequenceItem<double>(
            tween: Tween<double>(
              begin: 5 * math.pi / 180,
              end: -5 * math.pi / 180,
            ),
            weight: 1,
          ),
          TweenSequenceItem<double>(
            tween: Tween<double>(begin: -5 * math.pi / 180, end: 0.0),
            weight: 1,
          ),
        ]).animate(
          CurvedAnimation(parent: _wobbleController, curve: Curves.easeInOut),
        );
  }

  @override
  void dispose() {
    _entryController.dispose();
    _wobbleController.dispose();
    _ctaGlowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double width = mediaQuery.size.width;
    final bool compact = width < 360;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F3EE),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: <Widget>[
              const SizedBox(height: 12),
              OnboardingTopBar(
                currentStep: 17,
                totalSteps: 18,
                onSkip: _handleSkip,
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return SingleChildScrollView(
                      padding: EdgeInsets.only(
                        top: compact ? 26 : 38,
                        bottom: compact ? 18 : 24,
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
                                    child: SizedBox(
                                      width: compact ? 220 : 240,
                                      height: compact ? 190 : 210,
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: <Widget>[
                                          const _Screen17SparkleCluster(),
                                          AnimatedBuilder(
                                            animation: _wobbleRotation,
                                            builder:
                                                (
                                                  BuildContext context,
                                                  Widget? child,
                                                ) {
                                                  return Transform.rotate(
                                                    angle:
                                                        _wobbleRotation.value,
                                                    child: child,
                                                  );
                                                },
                                            child: PauMascot(
                                              state: 'zen',
                                              size: compact ? 150 : 160,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: compact ? 20 : 28),
                                FadeTransition(
                                  opacity: _headlineFade,
                                  child: SlideTransition(
                                    position: _headlineSlide,
                                    child: Text.rich(
                                      TextSpan(
                                        style: TextStyle(
                                          color: const Color(0xFF2E2520),
                                          fontSize: compact ? 28 : 34,
                                          height: 1.14,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: -1.0,
                                        ),
                                        children: const <InlineSpan>[
                                          TextSpan(text: 'Let\'s take your '),
                                          TextSpan(
                                            text: 'time\nback',
                                            style: TextStyle(
                                              color: Color(0xFFFF6B9D),
                                            ),
                                          ),
                                          TextSpan(text: '.'),
                                        ],
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                SizedBox(height: compact ? 16 : 18),
                                FadeTransition(
                                  opacity: _subtitleFade,
                                  child: SlideTransition(
                                    position: _subtitleSlide,
                                    child: Text(
                                      'Start with Pau.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: const Color(0xFF5C5148),
                                        fontSize: compact ? 18 : 19.5,
                                        height: 1.55,
                                        fontStyle: FontStyle.italic,
                                        fontFamily: 'serif',
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: compact ? 26 : 32),
                                FadeTransition(
                                  opacity: _ctaFade,
                                  child: SlideTransition(
                                    position: _ctaSlide,
                                    child: _GetStartedButton(
                                      animation: _ctaGlowController,
                                      onPressed: _handleNext,
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

class _Screen17SparkleCluster extends StatelessWidget {
  const _Screen17SparkleCluster();

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: <Widget>[
        _Screen17Sparkle(
          top: 36,
          left: 52,
          delay: 0.0,
          color: Color(0xFFA59B94),
          size: 14,
        ),
        _Screen17Sparkle(
          top: 50,
          left: 136,
          delay: 0.7,
          color: Color(0xFF645955),
          size: 18,
        ),
        _Screen17Sparkle(
          top: 84,
          left: 162,
          delay: 1.4,
          color: Color(0xFFB19A9E),
          size: 12,
        ),
      ],
    );
  }
}

class _Screen17Sparkle extends StatefulWidget {
  const _Screen17Sparkle({
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
  State<_Screen17Sparkle> createState() => _Screen17SparkleState();
}

class _Screen17SparkleState extends State<_Screen17Sparkle>
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
          final double progress =
              (_controller.value + (widget.delay / 3)) % 1.0;
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

class _GetStartedButton extends StatefulWidget {
  const _GetStartedButton({required this.animation, required this.onPressed});

  final Animation<double> animation;
  final VoidCallback onPressed;

  @override
  State<_GetStartedButton> createState() => _GetStartedButtonState();
}

class _GetStartedButtonState extends State<_GetStartedButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 0.98 : 1,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onPressed,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          borderRadius: BorderRadius.circular(24),
          child: Ink(
            width: double.infinity,
            height: 58,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: <Color>[Color(0xFFFF8C42), Color(0xFFFF6B9D)],
              ),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color(0x332E2520),
                  blurRadius: 22,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                AnimatedBuilder(
                  animation: widget.animation,
                  builder: (BuildContext context, Widget? child) {
                    final double wave = math.sin(
                      widget.animation.value * math.pi * 2,
                    );
                    final double scale = 1.0 + (((wave + 1) / 2) * 0.5);
                    final double opacity = 0.20 + (((wave + 1) / 2) * 0.10);

                    return Opacity(
                      opacity: opacity,
                      child: Transform.scale(scale: scale, child: child),
                    );
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 0.75,
                        colors: <Color>[Color(0xCCFFFFFF), Colors.transparent],
                      ),
                    ),
                  ),
                ),
                const Text(
                  'Get Started',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
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
