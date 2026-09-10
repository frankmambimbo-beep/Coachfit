import 'dart:async';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';

/// A simple countdown shown between sets. Self-contained — starts
/// automatically when built, counts down, and calls [onFinished] once
/// (not repeatedly) when it hits zero.
class RestTimerWidget extends StatefulWidget {
  const RestTimerWidget({
    super.key,
    this.initialSeconds = 60,
    this.onFinished,
    this.onDismiss,
  });

  final int initialSeconds;
  final VoidCallback? onFinished;
  final VoidCallback? onDismiss;

  @override
  State<RestTimerWidget> createState() => _RestTimerWidgetState();
}

class _RestTimerWidgetState extends State<RestTimerWidget> {
  late int _secondsLeft;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _secondsLeft = widget.initialSeconds;
    _start();
  }

  void _start() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 1) {
        timer.cancel();
        setState(() => _secondsLeft = 0);
        widget.onFinished?.call();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  void _addTime(int seconds) {
    setState(() => _secondsLeft = (_secondsLeft + seconds).clamp(0, 600));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = _secondsLeft ~/ 60;
    final seconds = _secondsLeft % 60;
    final label = '$minutes:${seconds.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.accentPrimary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          const Icon(Icons.timer_outlined, color: AppColors.accentPrimary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Rest', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted)),
                Text(label,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          TextButton(onPressed: () => _addTime(30), child: const Text('+30s')),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: widget.onDismiss,
          ),
        ],
      ),
    );
  }
}
