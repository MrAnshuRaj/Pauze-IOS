import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import 'home_screen.dart';

class BreathingScreen extends StatefulWidget {
  const BreathingScreen({super.key});

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen>
    with SingleTickerProviderStateMixin {
  static const int _sessionSeconds = 120;

  late final AnimationController _pulseController;

  BreathingPattern _selectedPattern = BreathingPattern.box;
  Timer? _timer;
  int _secondsLeft = _sessionSeconds;
  int _phaseSecond = 0;
  int _phaseIndex = 0;
  bool _running = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
      lowerBound: 0.7,
      upperBound: 1.0,
      value: 0.8,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<BreathingPhase> phases = _selectedPattern.phases;
    final BreathingPhase phase = phases[_phaseIndex % phases.length];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Breathing Unlock'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            _buildPatternSelector(),
            const SizedBox(height: 20),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      phase.label,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatSeconds(_secondsLeft),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 24),
                    ScaleTransition(
                      scale: _pulseController,
                      child: Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: <Color>[Color(0xFF4DB6AC), Color(0xFF00796B)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: const Color(0xFF00796B).withValues(alpha: 0.25),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _selectedPattern.description,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _running ? _stopSession : _startSession,
                icon: Icon(_running ? Icons.stop_circle_outlined : Icons.play_arrow_rounded),
                label: Text(_running ? 'Stop Session' : 'Start 2-Minute Session'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatternSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: BreathingPattern.values.map((BreathingPattern pattern) {
        final bool selected = pattern == _selectedPattern;
        return ChoiceChip(
          selected: selected,
          label: Text(pattern.title),
          onSelected: _running
              ? null
              : (bool _) {
                  setState(() {
                    _selectedPattern = pattern;
                    _phaseIndex = 0;
                    _phaseSecond = 0;
                    _secondsLeft = _sessionSeconds;
                  });
                },
        );
      }).toList(growable: false),
    );
  }

  void _startSession() {
    setState(() {
      _running = true;
      _secondsLeft = _sessionSeconds;
      _phaseSecond = 0;
      _phaseIndex = 0;
    });

    _animateForCurrentPhase();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Breathing session started.')),
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_secondsLeft <= 1) {
        timer.cancel();
        await _completeSession();
        return;
      }

      setState(() {
        _secondsLeft -= 1;
        _phaseSecond += 1;
      });

      final BreathingPhase current =
          _selectedPattern.phases[_phaseIndex % _selectedPattern.phases.length];
      if (_phaseSecond >= current.seconds) {
        setState(() {
          _phaseSecond = 0;
          _phaseIndex = (_phaseIndex + 1) % _selectedPattern.phases.length;
        });
        _animateForCurrentPhase();

      }
    });
  }

  void _stopSession() {
    _timer?.cancel();
    setState(() {
      _running = false;
      _secondsLeft = _sessionSeconds;
      _phaseSecond = 0;
      _phaseIndex = 0;
    });
    _pulseController.animateTo(0.8);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Breathing session stopped.')),
      );
    }
  }

  Future<void> _completeSession() async {
    final appState = context.read<AppState>();

    _timer?.cancel(); // ✅ stop timer

    setState(() {
      _running = false;
      _secondsLeft = 0;
    });

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
    );

    unawaited(
      appState.unblockForDuration(durationMinutes: 10),
    );
  }

  void _animateForCurrentPhase() {
    final BreathingPhase phase =
        _selectedPattern.phases[_phaseIndex % _selectedPattern.phases.length];
    switch (phase.type) {
      case BreathPhaseType.inhale:
        _pulseController.animateTo(1.0, duration: Duration(seconds: phase.seconds));
        break;
      case BreathPhaseType.exhale:
        _pulseController.animateTo(0.72, duration: Duration(seconds: phase.seconds));
        break;
      case BreathPhaseType.hold:
        _pulseController.animateTo(
          _pulseController.value,
          duration: Duration(seconds: phase.seconds),
        );
        break;
    }
  }

  String _formatSeconds(int seconds) {
    final int min = seconds ~/ 60;
    final int sec = seconds % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }
}

enum BreathingPattern {
  box(
    title: 'Box Breathing',
    description: '4-4-4-4 rhythm to reduce stress and steady your focus.',
    phases: <BreathingPhase>[
      BreathingPhase(type: BreathPhaseType.inhale, label: 'Inhale', seconds: 4),
      BreathingPhase(type: BreathPhaseType.hold, label: 'Hold', seconds: 4),
      BreathingPhase(type: BreathPhaseType.exhale, label: 'Exhale', seconds: 4),
      BreathingPhase(type: BreathPhaseType.hold, label: 'Hold', seconds: 4),
    ],
  ),
  calm(
    title: 'Calm Breathing',
    description: 'Longer exhale to calm down quickly and lower stimulation.',
    phases: <BreathingPhase>[
      BreathingPhase(type: BreathPhaseType.inhale, label: 'Inhale', seconds: 4),
      BreathingPhase(type: BreathPhaseType.exhale, label: 'Exhale', seconds: 6),
    ],
  ),
  focus(
    title: 'Focus Breathing',
    description: 'Balanced cadence to sharpen concentration before resuming apps.',
    phases: <BreathingPhase>[
      BreathingPhase(type: BreathPhaseType.inhale, label: 'Inhale', seconds: 4),
      BreathingPhase(type: BreathPhaseType.hold, label: 'Hold', seconds: 2),
      BreathingPhase(type: BreathPhaseType.exhale, label: 'Exhale', seconds: 4),
      BreathingPhase(type: BreathPhaseType.hold, label: 'Hold', seconds: 2),
    ],
  );

  const BreathingPattern({
    required this.title,
    required this.description,
    required this.phases,
  });

  final String title;
  final String description;
  final List<BreathingPhase> phases;
}

class BreathingPhase {
  const BreathingPhase({
    required this.type,
    required this.label,
    required this.seconds,
  });

  final BreathPhaseType type;
  final String label;
  final int seconds;
}

enum BreathPhaseType { inhale, hold, exhale }






