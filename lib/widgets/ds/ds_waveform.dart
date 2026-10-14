import 'dart:math' as math;
import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:flutter/material.dart';

/// A small bar waveform that animates while [playing] is true and rests as a
/// static waveform otherwise. Shared by the audio note player and the create
/// note recorder preview so playback feedback looks consistent app-wide.
class DsWaveform extends StatefulWidget {
  const DsWaveform({
    super.key,
    required this.playing,
    this.color,
    this.barCount = 24,
    this.height = 32,
  });

  final bool playing;
  final Color? color;
  final int barCount;
  final double height;

  @override
  State<DsWaveform> createState() => _DsWaveformState();
}

class _DsWaveformState extends State<DsWaveform>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<double> _base;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 850));
    // Deterministic but varied rest heights (no Random → reproducible).
    _base = List.generate(
        widget.barCount, (i) => 0.35 + 0.4 * (0.5 + 0.5 * math.sin(i * 1.7)));
    if (widget.playing) _ctrl.repeat();
  }

  @override
  void didUpdateWidget(covariant DsWaveform old) {
    super.didUpdateWidget(old);
    if (widget.playing && !_ctrl.isAnimating) {
      _ctrl.repeat();
    } else if (!widget.playing && _ctrl.isAnimating) {
      _ctrl.stop();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  // Center-weighted envelope (taller in the middle) for a voice-memo look.
  double _envelope(int i) {
    final t = widget.barCount <= 1 ? 0.5 : i / (widget.barCount - 1);
    return 0.3 + 0.7 * math.sin(t * math.pi);
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppColors.primary;
    return SizedBox(
      height: widget.height,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(widget.barCount, (i) {
              final env = _envelope(i);
              double f;
              if (widget.playing) {
                final phase = _ctrl.value * 2 * math.pi + i * 0.5;
                f = env * (0.45 + 0.55 * (0.5 + 0.5 * math.sin(phase)));
              } else {
                f = env * _base[i];
              }
              return Container(
                width: 3,
                height: widget.height * f.clamp(0.1, 1.0),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: widget.playing ? 0.9 : 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
