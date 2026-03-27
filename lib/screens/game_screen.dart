import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import 'home_screen.dart';

enum MiniGameType { memoryPattern, numberRecall, reactionTap }

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  MiniGameType? _activeGame;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mini Games Unlock')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _activeGame == null
            ? _buildChooser(context)
            : _buildGame(context),
      ),
    );
  }

  Widget _buildChooser(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Choose a game to unlock apps',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(
          'Complete one game successfully to unlock for 10 minutes.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        _gameCard(
          title: 'Memory Pattern Repeat',
          subtitle: 'Watch the pattern and tap it back.',
          icon: Icons.psychology_alt_rounded,
          color: const Color(0xFF1E88E5),
          onTap: () => setState(() => _activeGame = MiniGameType.memoryPattern),
        ),
        const SizedBox(height: 12),
        _gameCard(
          title: 'Number Sequence Recall',
          subtitle: 'Memorize digits and enter them correctly.',
          icon: Icons.pin_outlined,
          color: const Color(0xFF43A047),
          onTap: () => setState(() => _activeGame = MiniGameType.numberRecall),
        ),
        const SizedBox(height: 12),
        _gameCard(
          title: 'Reaction Tap',
          subtitle: 'Tap as soon as the screen turns green.',
          icon: Icons.flash_on_rounded,
          color: const Color(0xFFF4511E),
          onTap: () => setState(() => _activeGame = MiniGameType.reactionTap),
        ),
      ],
    );
  }

  Widget _buildGame(BuildContext context) {
    switch (_activeGame) {
      case MiniGameType.memoryPattern:
        return MemoryPatternGame(
          onBack: () => setState(() => _activeGame = null),
          onSuccess: _handleSuccess,
        );
      case MiniGameType.numberRecall:
        return NumberRecallGame(
          onBack: () => setState(() => _activeGame = null),
          onSuccess: _handleSuccess,
        );
      case MiniGameType.reactionTap:
        return ReactionTapGame(
          onBack: () => setState(() => _activeGame = null),
          onSuccess: _handleSuccess,
        );
      case null:
        return const SizedBox.shrink();
    }
  }

  Future<void> _handleSuccess() async {
    final appState = context.read<AppState>();

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
    );

    unawaited(appState.unblockForDuration(durationMinutes: 10));
  }

  Widget _gameCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: color.withValues(alpha: 0.12),
        ),
        child: Row(
          children: <Widget>[
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.18),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}

class MemoryPatternGame extends StatefulWidget {
  const MemoryPatternGame({
    super.key,
    required this.onSuccess,
    required this.onBack,
  });

  final Future<void> Function() onSuccess;
  final VoidCallback onBack;

  @override
  State<MemoryPatternGame> createState() => _MemoryPatternGameState();
}

class _MemoryPatternGameState extends State<MemoryPatternGame> {
  final Random _random = Random();
  final List<Color> _colors = <Color>[
    const Color(0xFF42A5F5),
    const Color(0xFFAB47BC),
    const Color(0xFF66BB6A),
    const Color(0xFFFFA726),
  ];

  int _round = 1;
  int _secondsLeft = 90;
  Timer? _countdown;

  List<int> _sequence = <int>[];
  final List<int> _inputs = <int>[];
  int _highlightIndex = -1;
  bool _showingSequence = true;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    unawaited(_startRound());
  }

  @override
  void dispose() {
    _countdown?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _header(
          context,
          title: 'Memory Pattern',
          subtitle: 'Round $_round / 3',
          secondsLeft: _secondsLeft,
          onBack: widget.onBack,
        ),
        const SizedBox(height: 14),
        Text(
          _showingSequence ? 'Watch carefully...' : 'Repeat the pattern',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 14),
        Expanded(
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 4,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (BuildContext context, int index) {
              final bool highlighted = index == _highlightIndex;
              return GestureDetector(
                onTap: () => _onTapPad(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  decoration: BoxDecoration(
                    color: highlighted
                        ? _colors[index]
                        : _colors[index].withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: highlighted
                        ? <BoxShadow>[
                            BoxShadow(
                              color: _colors[index].withValues(alpha: 0.4),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ]
                        : const <BoxShadow>[],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _startCountdown() {
    _countdown?.cancel();
    _countdown = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsLeft <= 1) {
        timer.cancel();
        _showFailure('Time is up. Try again.');
        return;
      }
      setState(() => _secondsLeft -= 1);
    });
  }

  Future<void> _startRound() async {
    _inputs.clear();
    _sequence = List<int>.generate(_round + 2, (_) => _random.nextInt(4));
    _showingSequence = true;
    _busy = true;
    setState(() {});

    await Future<void>.delayed(const Duration(milliseconds: 500));

    for (int i = 0; i < _sequence.length; i++) {
      if (!mounted) {
        return;
      }
      setState(() => _highlightIndex = _sequence[i]);
      await Future<void>.delayed(const Duration(milliseconds: 550));
      if (!mounted) {
        return;
      }
      setState(() => _highlightIndex = -1);
      await Future<void>.delayed(const Duration(milliseconds: 240));
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _showingSequence = false;
      _busy = false;
    });
  }

  Future<void> _onTapPad(int index) async {
    if (_showingSequence || _busy) {
      return;
    }

    _inputs.add(index);
    setState(() => _highlightIndex = index);
    await Future<void>.delayed(const Duration(milliseconds: 120));
    if (mounted) {
      setState(() => _highlightIndex = -1);
    }

    final int position = _inputs.length - 1;
    if (_sequence[position] != index) {
      _showFailure('Wrong pattern. Keep training and try again.');
      return;
    }

    if (_inputs.length == _sequence.length) {
      if (_round >= 3) {
        _countdown?.cancel();
        await widget.onSuccess();
      } else {
        _round += 1;
        await _startRound();
      }
    }
  }

  void _showFailure(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
    widget.onBack();
  }
}

class NumberRecallGame extends StatefulWidget {
  const NumberRecallGame({
    super.key,
    required this.onSuccess,
    required this.onBack,
  });

  final Future<void> Function() onSuccess;
  final VoidCallback onBack;

  @override
  State<NumberRecallGame> createState() => _NumberRecallGameState();
}

class _NumberRecallGameState extends State<NumberRecallGame> {
  final Random _random = Random();
  final TextEditingController _controller = TextEditingController();

  int _round = 1;
  int _secondsLeft = 90;
  Timer? _countdown;
  String _currentNumber = '';
  bool _showNumber = true;
  bool _lockedInput = true;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    unawaited(_nextRound());
  }

  @override
  void dispose() {
    _controller.dispose();
    _countdown?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _header(
          context,
          title: 'Number Recall',
          subtitle: 'Round $_round / 3',
          secondsLeft: _secondsLeft,
          onBack: widget.onBack,
        ),
        const SizedBox(height: 14),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                _showNumber ? 'Memorize this number' : 'Type the number',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _showNumber
                    ? Text(
                        _currentNumber,
                        key: const ValueKey<String>('number_visible'),
                        style: Theme.of(context).textTheme.displaySmall
                            ?.copyWith(
                              letterSpacing: 3,
                              fontWeight: FontWeight.bold,
                            ),
                      )
                    : const Text(
                        '••••••',
                        key: ValueKey<String>('number_hidden'),
                        style: TextStyle(fontSize: 36, letterSpacing: 6),
                      ),
              ),
              const SizedBox(height: 22),
              TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                enabled: !_lockedInput,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter sequence',
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _lockedInput ? null : _submit,
                  child: const Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _startCountdown() {
    _countdown = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsLeft <= 1) {
        timer.cancel();
        _showFailure('Time is up. Try again.');
        return;
      }
      setState(() => _secondsLeft -= 1);
    });
  }

  Future<void> _nextRound() async {
    _controller.clear();
    _showNumber = true;
    _lockedInput = true;
    _currentNumber = _buildDigits(length: 3 + _round);
    setState(() {});

    await Future<void>.delayed(const Duration(seconds: 5));
    if (!mounted) {
      return;
    }

    setState(() {
      _showNumber = false;
      _lockedInput = false;
    });
  }

  Future<void> _submit() async {
    if (_controller.text.trim() == _currentNumber) {
      if (_round >= 3) {
        _countdown?.cancel();
        await widget.onSuccess();
      } else {
        setState(() => _round += 1);
        await _nextRound();
      }
      return;
    }

    _showFailure('Not quite. Try again.');
  }

  String _buildDigits({required int length}) {
    return List<int>.generate(length, (_) => _random.nextInt(10)).join();
  }

  void _showFailure(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
    widget.onBack();
  }
}

class ReactionTapGame extends StatefulWidget {
  const ReactionTapGame({
    super.key,
    required this.onSuccess,
    required this.onBack,
  });

  final Future<void> Function() onSuccess;
  final VoidCallback onBack;

  @override
  State<ReactionTapGame> createState() => _ReactionTapGameState();
}

class _ReactionTapGameState extends State<ReactionTapGame> {
  final Random _random = Random();
  final List<int> _reactionTimes = <int>[];

  int _round = 1;
  int _secondsLeft = 75;
  Timer? _countdown;

  bool _canTap = false;
  bool _waiting = true;
  DateTime? _signalTime;
  Timer? _delayTimer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    _beginRound();
  }

  @override
  void dispose() {
    _countdown?.cancel();
    _delayTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color boxColor = _canTap
        ? const Color(0xFF66BB6A)
        : (_waiting ? const Color(0xFFFFCC80) : const Color(0xFFEF9A9A));

    return Column(
      children: <Widget>[
        _header(
          context,
          title: 'Reaction Tap',
          subtitle: 'Round $_round / 5',
          secondsLeft: _secondsLeft,
          onBack: widget.onBack,
        ),
        const SizedBox(height: 20),
        Expanded(
          child: GestureDetector(
            onTap: _handleTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: double.infinity,
              decoration: BoxDecoration(
                color: boxColor,
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              padding: const EdgeInsets.all(20),
              child: Text(
                _canTap
                    ? 'Tap now!'
                    : _waiting
                    ? 'Wait for green'
                    : 'Too early!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        if (_reactionTimes.isNotEmpty)
          Text(
            'Avg reaction: ${(_reactionTimes.reduce((int a, int b) => a + b) / _reactionTimes.length).round()} ms',
          ),
      ],
    );
  }

  void _startCountdown() {
    _countdown = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_secondsLeft <= 1) {
        timer.cancel();
        _showFailure('Time is up. Try again.');
        return;
      }

      setState(() => _secondsLeft -= 1);
    });
  }

  void _beginRound() {
    _canTap = false;
    _waiting = true;
    _signalTime = null;
    setState(() {});

    _delayTimer?.cancel();
    _delayTimer = Timer(
      Duration(milliseconds: 1400 + _random.nextInt(2000)),
      () {
        if (!mounted) {
          return;
        }
        setState(() {
          _canTap = true;
          _waiting = false;
          _signalTime = DateTime.now();
        });
      },
    );
  }

  Future<void> _handleTap() async {
    if (_canTap && _signalTime != null) {
      final int ms = DateTime.now().difference(_signalTime!).inMilliseconds;
      _reactionTimes.add(ms);

      if (_round >= 5) {
        _countdown?.cancel();
        final double avg =
            _reactionTimes.reduce((int a, int b) => a + b) /
            _reactionTimes.length;
        if (avg <= 700) {
          await widget.onSuccess();
        } else {
          _showFailure(
            'Average reaction too slow (${avg.round()} ms). Try again.',
          );
        }
      } else {
        setState(() => _round += 1);
        _beginRound();
      }
      return;
    }

    if (_waiting) {
      _delayTimer?.cancel();
      setState(() {
        _waiting = false;
      });
      _showFailure('Too early. Wait for green and try again.');
    }
  }

  void _showFailure(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
    widget.onBack();
  }
}

Widget _header(
  BuildContext context, {
  required String title,
  required String subtitle,
  required int secondsLeft,
  required VoidCallback onBack,
}) {
  final int min = secondsLeft ~/ 60;
  final int sec = secondsLeft % 60;

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: <Widget>[
        IconButton(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              Text(subtitle),
            ],
          ),
        ),
        Text(
          '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    ),
  );
}
