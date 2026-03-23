import 'package:flutter/material.dart';

class UnlockTimerBanner extends StatelessWidget {
  const UnlockTimerBanner({
    super.key,
    required this.remaining,
    required this.onLockNow,
  });

  final Duration remaining;
  final VoidCallback onLockNow;

  @override
  Widget build(BuildContext context) {
    final int minutes = remaining.inMinutes;
    final int seconds = remaining.inSeconds.remainder(60);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF66BB6A), width: 1.2),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.lock_open_rounded, color: Color(0xFF2E7D32)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Unlocked for ${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          TextButton(
            onPressed: onLockNow,
            child: const Text('Lock Now'),
          ),
        ],
      ),
    );
  }
}

