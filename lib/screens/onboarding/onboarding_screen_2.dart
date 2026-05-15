import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'onboarding_step_header.dart';

class OnboardingScreen2 extends StatefulWidget {
  const OnboardingScreen2({
    super.key,
    required this.onNext,
    required this.onSkip,
  });

  final VoidCallback onNext;
  final VoidCallback onSkip;

  @override
  State<OnboardingScreen2> createState() => _OnboardingScreen2State();
}

class _OnboardingScreen2State extends State<OnboardingScreen2>
    with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final AnimationController _floatController;
  late final Animation<double> _mascotFade;
  late final Animation<double> _mascotScale;
  late final Animation<double> _headlineFade;
  late final Animation<Offset> _headlineSlide;
  late final Animation<double> _subtitleOneFade;
  late final Animation<Offset> _subtitleOneSlide;
  late final Animation<double> _subtitleTwoFade;
  late final Animation<Offset> _subtitleTwoSlide;
  late final Animation<double> _buttonFade;
  late final Animation<Offset> _buttonSlide;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    _mascotFade = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.00, 0.28, curve: Curves.easeOut),
    );
    _mascotScale = Tween<double>(begin: 0.80, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.00, 0.34, curve: ElasticOutCurve(0.88)),
      ),
    );
    _headlineFade = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.24, 0.52, curve: Curves.easeOut),
    );
    _headlineSlide =
        Tween<Offset>(begin: const Offset(0, 0.10), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entryController,
            curve: const Interval(0.24, 0.52, curve: Curves.easeOutCubic),
          ),
        );
    _subtitleOneFade = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.42, 0.68, curve: Curves.easeOut),
    );
    _subtitleOneSlide =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entryController,
            curve: const Interval(0.42, 0.68, curve: Curves.easeOutCubic),
          ),
        );
    _subtitleTwoFade = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.54, 0.80, curve: Curves.easeOut),
    );
    _subtitleTwoSlide =
        Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entryController,
            curve: const Interval(0.54, 0.80, curve: Curves.easeOutCubic),
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
  }

  @override
  void dispose() {
    _entryController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double width = mediaQuery.size.width;
    final double headlineSize = width < 360 ? 38 : 44;
    final double subtitleSize = width < 360 ? 16 : 18;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: <Widget>[
              const SizedBox(height: 12),
              OnboardingTopBar(
                currentStep: 2,
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
                          opacity: _mascotFade,
                          child: ScaleTransition(
                            scale: _mascotScale,
                            child: AnimatedBuilder(
                              animation: _floatController,
                              builder: (BuildContext context, Widget? child) {
                                final double wave = math.sin(
                                  _floatController.value * math.pi * 2,
                                );
                                final double scale =
                                    1.0 + ((wave + 1) / 2) * 0.05;
                                final double translateY = wave * -10;

                                return Transform.translate(
                                  offset: Offset(0, translateY),
                                  child: Transform.scale(
                                    scale: scale,
                                    child: child,
                                  ),
                                );
                              },
                              child: const _PauVisual(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 36),
                        FadeTransition(
                          opacity: _headlineFade,
                          child: SlideTransition(
                            position: _headlineSlide,
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: TextStyle(
                                  color: const Color(0xFF2E2520),
                                  fontSize: headlineSize,
                                  height: 1.02,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -1.15,
                                ),
                                children: const <InlineSpan>[
                                  TextSpan(text: 'Hi, I\'m '),
                                  TextSpan(
                                    text: 'Pau',
                                    style: TextStyle(color: Color(0xFFFF6B9D)),
                                  ),
                                  TextSpan(text: '.'),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        FadeTransition(
                          opacity: _subtitleOneFade,
                          child: SlideTransition(
                            position: _subtitleOneSlide,
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: TextStyle(
                                  color: const Color(0xFF5C5148),
                                  fontSize: subtitleSize,
                                  height: 1.45,
                                  fontStyle: FontStyle.italic,
                                ),
                                children: const <InlineSpan>[
                                  TextSpan(text: 'I\'m '),
                                  TextSpan(
                                    text: 'your brain',
                                    style: TextStyle(
                                      color: Color(0xFFFF8C42),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  TextSpan(text: '.'),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        FadeTransition(
                          opacity: _subtitleTwoFade,
                          child: SlideTransition(
                            position: _subtitleTwoSlide,
                            child: Text(
                              'I start fresh every day.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: const Color(0xFF5C5148),
                                fontSize: width < 360 ? 15 : 16.5,
                                height: 1.5,
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

class _PauVisual extends StatelessWidget {
  const _PauVisual();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 180,
      child: Stack(
        alignment: Alignment.center,
        children: const <Widget>[
          _SoftGlow(),
          _Sparkle(alignment: Alignment(-0.46, -0.22), size: 14, delay: 0.0),
          _Sparkle(alignment: Alignment(0.44, -0.08), size: 8, delay: 0.28),
          _Sparkle(alignment: Alignment(0.10, 0.24), size: 6, delay: 0.55),
          PauMascot(size: 142),
        ],
      ),
    );
  }
}

class PauMascot extends StatelessWidget {
  const PauMascot({super.key, this.state = 'zen', this.size = 142});

  final String state;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _PauMascotPainter(state: state)),
    );
  }
}

class _SoftGlow extends StatelessWidget {
  const _SoftGlow();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: <Color>[
            const Color(0xFFFFC1D5).withValues(alpha: 0.28),
            const Color(0xFFFFF9F5).withValues(alpha: 0.0),
          ],
        ),
      ),
    );
  }
}

class _Sparkle extends StatefulWidget {
  const _Sparkle({
    required this.alignment,
    required this.size,
    required this.delay,
  });

  final Alignment alignment;
  final double size;
  final double delay;

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
      duration: const Duration(milliseconds: 2100),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: widget.alignment,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget? child) {
          final double progress = (_controller.value + widget.delay) % 1.0;
          final double wave = math.sin(progress * math.pi * 2);
          final double opacity = (0.60 + (wave * 0.28)).clamp(0.18, 0.88);
          final double scale = 0.86 + ((wave + 1) / 2) * 0.35;

          return Opacity(
            opacity: opacity.toDouble(),
            child: Transform.scale(scale: scale, child: child),
          );
        },
        child: Icon(
          Icons.auto_awesome,
          size: widget.size,
          color: const Color(0xFF8F827B),
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

class _PauMascotPainter extends CustomPainter {
  const _PauMascotPainter({required this.state});

  final String state;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint bodyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[Color(0xFFFFD6E2), Color(0xFFFFE7EE)],
      ).createShader(Offset.zero & size);

    final Paint accentPaint = Paint()
      ..color = const Color(0xFFFFC6D7).withValues(alpha: 0.75);
    final Paint featurePaint = Paint()
      ..color = const Color(0xFF594540)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.width * 0.028
      ..style = PaintingStyle.stroke;
    final Paint blushPaint = Paint()
      ..color = const Color(0xFFFFA7BD).withValues(alpha: 0.20)
      ..style = PaintingStyle.fill;
    final Paint eyeWhitePaint = Paint()..color = Colors.white;
    final Paint pupilPaint = Paint()..color = const Color(0xFF3A2A27);
    final Paint eyebrowPaint = Paint()
      ..color = const Color(0xFFFFC2D0).withValues(alpha: 0.95)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.width * 0.022
      ..style = PaintingStyle.stroke;

    final Rect bodyRect = Rect.fromCenter(
      center: Offset(size.width * 0.5, size.height * 0.43),
      width: size.width * 0.56,
      height: size.height * 0.76,
    );
    final RRect body = RRect.fromRectAndRadius(
      bodyRect,
      Radius.circular(size.width * 0.28),
    );
    canvas.drawRRect(body, bodyPaint);

    final RRect leftFoot = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width * 0.42, size.height * 0.86),
        width: size.width * 0.14,
        height: size.height * 0.22,
      ),
      Radius.circular(size.width * 0.07),
    );
    final RRect rightFoot = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width * 0.58, size.height * 0.86),
        width: size.width * 0.14,
        height: size.height * 0.22,
      ),
      Radius.circular(size.width * 0.07),
    );
    canvas.drawRRect(leftFoot, accentPaint);
    canvas.drawRRect(rightFoot, accentPaint);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.38, size.height * 0.50),
        width: size.width * 0.12,
        height: size.height * 0.07,
      ),
      blushPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.62, size.height * 0.50),
        width: size.width * 0.12,
        height: size.height * 0.07,
      ),
      blushPaint,
    );

    if (state == 'zen') {
      final Path leftEye = Path()
        ..moveTo(size.width * 0.36, size.height * 0.44)
        ..quadraticBezierTo(
          size.width * 0.40,
          size.height * 0.48,
          size.width * 0.45,
          size.height * 0.44,
        );
      final Path rightEye = Path()
        ..moveTo(size.width * 0.55, size.height * 0.44)
        ..quadraticBezierTo(
          size.width * 0.60,
          size.height * 0.48,
          size.width * 0.64,
          size.height * 0.44,
        );
      canvas.drawPath(leftEye, featurePaint);
      canvas.drawPath(rightEye, featurePaint);

      final Path browLeft = Path()
        ..moveTo(size.width * 0.36, size.height * 0.33)
        ..quadraticBezierTo(
          size.width * 0.40,
          size.height * 0.29,
          size.width * 0.46,
          size.height * 0.33,
        );
      final Path browRight = Path()
        ..moveTo(size.width * 0.54, size.height * 0.33)
        ..quadraticBezierTo(
          size.width * 0.60,
          size.height * 0.29,
          size.width * 0.64,
          size.height * 0.33,
        );
      canvas.drawPath(browLeft, eyebrowPaint);
      canvas.drawPath(browRight, eyebrowPaint);

      final Path smile = Path()
        ..moveTo(size.width * 0.38, size.height * 0.56)
        ..quadraticBezierTo(
          size.width * 0.50,
          size.height * 0.61,
          size.width * 0.62,
          size.height * 0.56,
        );
      canvas.drawPath(smile, featurePaint);
      return;
    }

    final Offset leftEyeCenter = Offset(size.width * 0.40, size.height * 0.44);
    final Offset rightEyeCenter = Offset(size.width * 0.60, size.height * 0.44);
    final double eyeRadius = size.width * 0.048;
    final double pupilRadius = size.width * 0.022;

    canvas.drawCircle(leftEyeCenter, eyeRadius, eyeWhitePaint);
    canvas.drawCircle(rightEyeCenter, eyeRadius, eyeWhitePaint);
    canvas.drawCircle(leftEyeCenter, pupilRadius, pupilPaint);
    canvas.drawCircle(rightEyeCenter, pupilRadius, pupilPaint);

    if (state == 'drained') {
      final Path leftEyelid = Path()
        ..moveTo(size.width * 0.35, size.height * 0.43)
        ..quadraticBezierTo(
          size.width * 0.40,
          size.height * 0.46,
          size.width * 0.45,
          size.height * 0.43,
        );
      final Path rightEyelid = Path()
        ..moveTo(size.width * 0.55, size.height * 0.43)
        ..quadraticBezierTo(
          size.width * 0.60,
          size.height * 0.46,
          size.width * 0.65,
          size.height * 0.43,
        );
      canvas.drawPath(leftEyelid, featurePaint);
      canvas.drawPath(rightEyelid, featurePaint);

      final Path mouth = Path()
        ..moveTo(size.width * 0.40, size.height * 0.58)
        ..quadraticBezierTo(
          size.width * 0.50,
          size.height * 0.595,
          size.width * 0.60,
          size.height * 0.58,
        );
      canvas.drawPath(mouth, featurePaint);
      return;
    }

    if (state == 'fried') {
      final Path browLeft = Path()
        ..moveTo(size.width * 0.34, size.height * 0.36)
        ..lineTo(size.width * 0.45, size.height * 0.34);
      final Path browRight = Path()
        ..moveTo(size.width * 0.55, size.height * 0.34)
        ..lineTo(size.width * 0.66, size.height * 0.36);
      canvas.drawPath(browLeft, featurePaint);
      canvas.drawPath(browRight, featurePaint);

      final Path mouth = Path()
        ..moveTo(size.width * 0.38, size.height * 0.58)
        ..quadraticBezierTo(
          size.width * 0.44,
          size.height * 0.54,
          size.width * 0.50,
          size.height * 0.58,
        )
        ..quadraticBezierTo(
          size.width * 0.56,
          size.height * 0.62,
          size.width * 0.62,
          size.height * 0.58,
        );
      canvas.drawPath(mouth, featurePaint);
      return;
    }

    if (state == 'brainrot') {
      canvas.drawLine(
        Offset(size.width * 0.35, size.height * 0.40),
        Offset(size.width * 0.45, size.height * 0.48),
        featurePaint,
      );
      canvas.drawLine(
        Offset(size.width * 0.45, size.height * 0.40),
        Offset(size.width * 0.35, size.height * 0.48),
        featurePaint,
      );
      canvas.drawLine(
        Offset(size.width * 0.55, size.height * 0.40),
        Offset(size.width * 0.65, size.height * 0.48),
        featurePaint,
      );
      canvas.drawLine(
        Offset(size.width * 0.65, size.height * 0.40),
        Offset(size.width * 0.55, size.height * 0.48),
        featurePaint,
      );

      final Path mouth = Path()
        ..moveTo(size.width * 0.38, size.height * 0.59)
        ..quadraticBezierTo(
          size.width * 0.44,
          size.height * 0.56,
          size.width * 0.50,
          size.height * 0.59,
        )
        ..quadraticBezierTo(
          size.width * 0.56,
          size.height * 0.62,
          size.width * 0.62,
          size.height * 0.59,
        );
      canvas.drawPath(mouth, featurePaint);
      return;
    }

    if (state == 'worried') {
      final Path browLeft = Path()
        ..moveTo(size.width * 0.34, size.height * 0.36)
        ..quadraticBezierTo(
          size.width * 0.39,
          size.height * 0.34,
          size.width * 0.44,
          size.height * 0.37,
        );
      final Path browRight = Path()
        ..moveTo(size.width * 0.56, size.height * 0.37)
        ..quadraticBezierTo(
          size.width * 0.61,
          size.height * 0.34,
          size.width * 0.66,
          size.height * 0.36,
        );
      canvas.drawPath(browLeft, featurePaint);
      canvas.drawPath(browRight, featurePaint);

      final Path mouth = Path()
        ..moveTo(size.width * 0.40, size.height * 0.58)
        ..quadraticBezierTo(
          size.width * 0.50,
          size.height * 0.565,
          size.width * 0.60,
          size.height * 0.585,
        );
      canvas.drawPath(mouth, featurePaint);
      return;
    }

    if (state == 'healing') {
      final Path browLeft = Path()
        ..moveTo(size.width * 0.35, size.height * 0.34)
        ..quadraticBezierTo(
          size.width * 0.40,
          size.height * 0.31,
          size.width * 0.45,
          size.height * 0.35,
        );
      final Path browRight = Path()
        ..moveTo(size.width * 0.55, size.height * 0.35)
        ..quadraticBezierTo(
          size.width * 0.60,
          size.height * 0.31,
          size.width * 0.65,
          size.height * 0.34,
        );
      canvas.drawPath(browLeft, eyebrowPaint);
      canvas.drawPath(browRight, eyebrowPaint);

      final Path mouth = Path()
        ..moveTo(size.width * 0.39, size.height * 0.56)
        ..quadraticBezierTo(
          size.width * 0.50,
          size.height * 0.62,
          size.width * 0.61,
          size.height * 0.56,
        );
      canvas.drawPath(mouth, featurePaint);
      return;
    }

    final Path neutralSmile = Path()
      ..moveTo(size.width * 0.40, size.height * 0.56)
      ..quadraticBezierTo(
        size.width * 0.50,
        size.height * 0.60,
        size.width * 0.60,
        size.height * 0.56,
      );
    canvas.drawPath(neutralSmile, featurePaint);
  }

  @override
  bool shouldRepaint(covariant _PauMascotPainter oldDelegate) {
    return oldDelegate.state != state;
  }
}
