import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/analytics_service.dart';
import 'onboarding_screen_2.dart';
import 'onboarding_step_header.dart';

class OnboardingScreen6 extends StatefulWidget {
  const OnboardingScreen6({
    super.key,
    required this.onNext,
    required this.onSkip,
  });

  final VoidCallback onNext;
  final VoidCallback onSkip;

  @override
  State<OnboardingScreen6> createState() => _OnboardingScreen6State();
}

class _OnboardingScreen6State extends State<OnboardingScreen6>
    with TickerProviderStateMixin {
  final AnalyticsService _analyticsService = AnalyticsService();

  late final AnimationController _entryController;
  late final AnimationController _floatController;
  late final Animation<double> _questionFade;
  late final Animation<Offset> _questionSlide;
  late final Animation<double> _valueFade;
  late final Animation<Offset> _valueSlide;
  late final Animation<double> _sliderFade;
  late final Animation<Offset> _sliderSlide;
  late final Animation<double> _buttonFade;
  late final Animation<Offset> _buttonSlide;

  double _hours = 3.0;
  DateTime? _lastSelectionHapticAt;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();

    _questionFade = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.08, 0.34, curve: Curves.easeOut),
    );
    _questionSlide =
        Tween<Offset>(begin: const Offset(0, -0.05), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entryController,
            curve: const Interval(0.08, 0.34, curve: Curves.easeOutCubic),
          ),
        );
    _valueFade = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.34, 0.62, curve: Curves.easeOut),
    );
    _valueSlide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entryController,
            curve: const Interval(0.34, 0.62, curve: Curves.easeOutCubic),
          ),
        );
    _sliderFade = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.46, 0.74, curve: Curves.easeOut),
    );
    _sliderSlide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entryController,
            curve: const Interval(0.46, 0.74, curve: Curves.easeOutCubic),
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

    _loadSavedHours();
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
    final String pauState = _getPauState(_hours);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: <Widget>[
              const SizedBox(height: 12),
              OnboardingTopBar(
                currentStep: 6,
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
                            child: Text.rich(
                              TextSpan(
                                style: TextStyle(
                                  color: const Color(0xFF2E2520),
                                  fontSize: width < 360 ? 22 : 24,
                                  height: 1.25,
                                  fontWeight: FontWeight.w800,
                                ),
                                children: const <InlineSpan>[
                                  TextSpan(text: 'How much '),
                                  TextSpan(
                                    text: 'time',
                                    style: TextStyle(color: Color(0xFFFF8C42)),
                                  ),
                                  TextSpan(
                                    text: ' do you\nspend\nscrolling each day?',
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        const SizedBox(height: 42),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 360),
                          switchInCurve: Curves.easeOutBack,
                          switchOutCurve: Curves.easeOut,
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: ScaleTransition(
                                    scale: Tween<double>(
                                      begin: 0.92,
                                      end: 1.0,
                                    ).animate(animation),
                                    child: child,
                                  ),
                                );
                              },
                          child: AnimatedBuilder(
                            key: ValueKey<String>(pauState),
                            animation: _floatController,
                            builder: (BuildContext context, Widget? child) {
                              final double wave = math.sin(
                                _floatController.value * math.pi * 2,
                              );
                              return Transform.translate(
                                offset: Offset(0, wave * -5),
                                child: child,
                              );
                            },
                            child: PauMascot(state: pauState, size: 138),
                          ),
                        ),
                        const SizedBox(height: 24),
                        FadeTransition(
                          opacity: _valueFade,
                          child: SlideTransition(
                            position: _valueSlide,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 180),
                              switchInCurve: Curves.easeOutBack,
                              switchOutCurve: Curves.easeOut,
                              transitionBuilder:
                                  (Widget child, Animation<double> animation) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child: ScaleTransition(
                                        scale: Tween<double>(
                                          begin: 0.94,
                                          end: 1.0,
                                        ).animate(animation),
                                        child: child,
                                      ),
                                    );
                                  },
                              child: Text(
                                _formatHours(_hours),
                                key: ValueKey<String>(_formatHours(_hours)),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: const Color(0xFFFF6B9D),
                                  fontSize: width < 360 ? 54 : 58,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -1.4,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        FadeTransition(
                          opacity: _sliderFade,
                          child: SlideTransition(
                            position: _sliderSlide,
                            child: Column(
                              children: <Widget>[
                                SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    trackHeight: 6,
                                    activeTrackColor: Colors.transparent,
                                    inactiveTrackColor: const Color(0xFFE0E0E0),
                                    overlayShape:
                                        SliderComponentShape.noOverlay,
                                    thumbColor: const Color(0xFFC05BD7),
                                    thumbShape: const RoundSliderThumbShape(
                                      enabledThumbRadius: 7,
                                    ),
                                    trackShape:
                                        const _GradientSliderTrackShape(),
                                  ),
                                  child: Slider(
                                    value: _hours,
                                    min: 0,
                                    max: 10,
                                    divisions: 20,
                                    onChanged: _handleSliderChanged,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Row(
                                  children: <Widget>[
                                    Text(
                                      '0h',
                                      style: TextStyle(
                                        color: Color(0xFF8B8B8B),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Spacer(),
                                    Text(
                                      '10h+',
                                      style: TextStyle(
                                        color: Color(0xFF8B8B8B),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
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

  Future<void> _loadSavedHours() async {
    final double storedHours = await _analyticsService
        .loadOnboardingDailyScrollHours();
    if (!mounted) {
      return;
    }
    setState(() => _hours = storedHours.clamp(0.0, 10.0));
  }

  void _handleSliderChanged(double value) {
    if (_hours == value) {
      return;
    }

    setState(() => _hours = value);
    _debouncedSelectionHaptic();
    _persistHours();
  }

  Future<void> _persistHours() async {
    await _analyticsService.saveOnboardingDailyScrollHours(_hours);
  }

  Future<void> _handleNext() async {
    HapticFeedback.lightImpact();
    await _persistHours();
    widget.onNext();
  }

  void _handleSkip() {
    HapticFeedback.lightImpact();
    widget.onSkip();
  }

  void _debouncedSelectionHaptic() {
    final DateTime now = DateTime.now();
    if (_lastSelectionHapticAt != null &&
        now.difference(_lastSelectionHapticAt!) <
            const Duration(milliseconds: 90)) {
      return;
    }
    _lastSelectionHapticAt = now;
    HapticFeedback.selectionClick();
  }

  String _getPauState(double hours) {
    if (hours <= 1) {
      return 'zen';
    }
    if (hours <= 2) {
      return 'okay';
    }
    if (hours <= 4) {
      return 'drained';
    }
    if (hours <= 6) {
      return 'fried';
    }
    return 'brainrot';
  }

  String _formatHours(double hours) {
    if (hours % 1 == 0) {
      return '${hours.toInt()}h';
    }
    return '${hours.toStringAsFixed(1)}h';
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

class _GradientSliderTrackShape extends RoundedRectSliderTrackShape {
  const _GradientSliderTrackShape();

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    double additionalActiveTrackHeight = 2,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isEnabled = false,
    bool isDiscrete = false,
    required TextDirection textDirection,
  }) {
    if (sliderTheme.trackHeight == null || sliderTheme.trackHeight! <= 0) {
      return;
    }

    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );
    final Radius radius = Radius.circular(trackRect.height / 2);
    final Canvas canvas = context.canvas;

    final RRect inactiveTrack = RRect.fromRectAndRadius(trackRect, radius);
    canvas.drawRRect(
      inactiveTrack,
      Paint()
        ..color = sliderTheme.inactiveTrackColor ?? const Color(0xFFE0E0E0),
    );

    final Rect activeRect = Rect.fromLTRB(
      trackRect.left,
      trackRect.top,
      thumbCenter.dx.clamp(trackRect.left, trackRect.right),
      trackRect.bottom,
    );

    if (activeRect.width <= 0) {
      return;
    }

    canvas.drawRRect(
      RRect.fromRectAndRadius(activeRect, radius),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: <Color>[Color(0xFFFF8C42), Color(0xFFFF6B9D)],
        ).createShader(activeRect),
    );
  }
}
