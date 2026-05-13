import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'onboarding_step_header.dart';

class OnboardingScreen5 extends StatefulWidget {
  const OnboardingScreen5({
    super.key,
    required this.onNext,
    required this.onSkip,
  });

  final VoidCallback onNext;
  final VoidCallback onSkip;

  @override
  State<OnboardingScreen5> createState() => _OnboardingScreen5State();
}

class _OnboardingScreen5State extends State<OnboardingScreen5>
    with TickerProviderStateMixin {
  static const List<_DemoAppItem> _apps = <_DemoAppItem>[
    _DemoAppItem(
      icon: Icons.play_arrow_rounded,
      backgroundStart: Color(0xFFFFF0F3),
      backgroundEnd: Color(0xFFFFF7F8),
      borderColor: Color(0xFFFFB6C1),
      iconColor: Color(0xFF3A2A27),
    ),
    _DemoAppItem(
      icon: Icons.photo_camera_rounded,
      backgroundStart: Color(0xFFFFEEF4),
      backgroundEnd: Color(0xFFFFF6F8),
      borderColor: Color(0xFFFF9CB8),
      iconColor: Color(0xFFE1306C),
    ),
    _DemoAppItem(
      icon: Icons.music_note_rounded,
      backgroundStart: Color(0xFFFFF1F5),
      backgroundEnd: Color(0xFFFFF9FB),
      borderColor: Color(0xFFFFB7C8),
      iconColor: Color(0xFF2E2520),
    ),
  ];

  late final AnimationController _entryController;
  late final AnimationController _cardPulseController;
  late final AnimationController _iconCycleController;
  late final Animation<double> _cardFade;
  late final Animation<double> _cardScale;
  late final Animation<double> _lineOneFade;
  late final Animation<Offset> _lineOneSlide;
  late final Animation<double> _lineTwoFade;
  late final Animation<Offset> _lineTwoSlide;
  late final Animation<double> _buttonFade;
  late final Animation<Offset> _buttonSlide;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1450),
    )..forward();
    _cardPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
    _iconCycleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2100),
    )..repeat();

    _cardFade = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.08, 0.30, curve: Curves.easeOut),
    );
    _cardScale = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.08, 0.34, curve: Curves.easeOutBack),
      ),
    );
    _lineOneFade = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.28, 0.56, curve: Curves.easeOut),
    );
    _lineOneSlide =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entryController,
            curve: const Interval(0.28, 0.56, curve: Curves.easeOutCubic),
          ),
        );
    _lineTwoFade = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.42, 0.72, curve: Curves.easeOut),
    );
    _lineTwoSlide =
        Tween<Offset>(begin: const Offset(0, 0.07), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entryController,
            curve: const Interval(0.42, 0.72, curve: Curves.easeOutCubic),
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
    _entryController.dispose();
    _cardPulseController.dispose();
    _iconCycleController.dispose();
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
                currentStep: 5,
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
                        const SizedBox(height: 24),
                        FadeTransition(
                          opacity: _cardFade,
                          child: ScaleTransition(
                            scale: _cardScale,
                            child: AnimatedBuilder(
                              animation: Listenable.merge(<Listenable>[
                                _cardPulseController,
                                _iconCycleController,
                              ]),
                              builder: (BuildContext context, Widget? child) {
                                final double pulseWave = math.sin(
                                  _cardPulseController.value * math.pi * 2,
                                );
                                final double scale =
                                    1.0 + (((pulseWave + 1) / 2) * 0.08);
                                final double floatY = pulseWave * -3.5;
                                final double opacity =
                                    (0.92 + (pulseWave * 0.05))
                                        .clamp(0.84, 1.0)
                                        .toDouble();
                                final int activeIndex =
                                    (_iconCycleController.value * _apps.length)
                                        .floor()
                                        .clamp(0, _apps.length - 1);
                                final _DemoAppItem app = _apps[activeIndex];

                                return Transform.translate(
                                  offset: Offset(0, floatY),
                                  child: Transform.scale(
                                    scale: scale,
                                    child: Opacity(
                                      opacity: opacity,
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 420,
                                        ),
                                        curve: Curves.easeOut,
                                        width: 74,
                                        height: 74,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: <Color>[
                                              app.backgroundStart,
                                              app.backgroundEnd,
                                            ],
                                          ),
                                          border: Border.all(
                                            color: app.borderColor,
                                            width: 1.4,
                                          ),
                                          boxShadow: const <BoxShadow>[
                                            BoxShadow(
                                              color: Color(0x1F2E2520),
                                              blurRadius: 18,
                                              offset: Offset(0, 12),
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: AnimatedSwitcher(
                                            duration: const Duration(
                                              milliseconds: 320,
                                            ),
                                            switchInCurve: Curves.easeOut,
                                            switchOutCurve: Curves.easeOut,
                                            transitionBuilder:
                                                (
                                                  Widget child,
                                                  Animation<double> animation,
                                                ) {
                                                  return FadeTransition(
                                                    opacity: animation,
                                                    child: ScaleTransition(
                                                      scale: Tween<double>(
                                                        begin: 0.88,
                                                        end: 1.0,
                                                      ).animate(animation),
                                                      child: child,
                                                    ),
                                                  );
                                                },
                                            child: Icon(
                                              app.icon,
                                              key: ValueKey<IconData>(app.icon),
                                              size: 36,
                                              color: app.iconColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 116),
                        FadeTransition(
                          opacity: _lineOneFade,
                          child: SlideTransition(
                            position: _lineOneSlide,
                            child: Text(
                              'Sometimes...',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: const Color(0xFF5C5148),
                                fontSize: width < 360 ? 18 : 20,
                                height: 1.45,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        FadeTransition(
                          opacity: _lineTwoFade,
                          child: SlideTransition(
                            position: _lineTwoSlide,
                            child: Text.rich(
                              TextSpan(
                                style: TextStyle(
                                  color: const Color(0xFF2E2520),
                                  fontSize: width < 360 ? 18 : 20,
                                  height: 1.35,
                                  fontWeight: FontWeight.w600,
                                ),
                                children: const <InlineSpan>[
                                  TextSpan(text: 'you open apps '),
                                  TextSpan(
                                    text: 'without even\nrealizing',
                                    style: TextStyle(
                                      color: Color(0xFFFF6B9D),
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  TextSpan(text: ' why.'),
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

class _DemoAppItem {
  const _DemoAppItem({
    required this.icon,
    required this.backgroundStart,
    required this.backgroundEnd,
    required this.borderColor,
    required this.iconColor,
  });

  final IconData icon;
  final Color backgroundStart;
  final Color backgroundEnd;
  final Color borderColor;
  final Color iconColor;
}
