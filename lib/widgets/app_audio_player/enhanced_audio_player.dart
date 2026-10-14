import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/utils/app_text_styles/app_text_styles.dart';
import 'package:alpha_track/widgets/app_snackbar/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class EnhancedAudioPlayer extends StatefulWidget {
  final String audioPath;
  final String? audioTitle;
  final String? duration;
  final VoidCallback? onPlayComplete;

  const EnhancedAudioPlayer({
    Key? key,
    required this.audioPath,
    this.audioTitle,
    this.duration,
    this.onPlayComplete,
  }) : super(key: key);

  @override
  State<EnhancedAudioPlayer> createState() => _EnhancedAudioPlayerState();
}

class _EnhancedAudioPlayerState extends State<EnhancedAudioPlayer> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  bool _isLoading = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  double _playbackProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeAudioPlayer();
  }

  void _initializeAudioPlayer() {
    _audioPlayer = AudioPlayer();

    // Listen for playback completion
    _audioPlayer.onPlayerComplete.listen((_) {
      setState(() {
        _isPlaying = false;
        _currentPosition = Duration.zero;
        _playbackProgress = 0.0;
      });
      widget.onPlayComplete?.call();
    });

    // Listen for position changes
    _audioPlayer.onPositionChanged.listen((position) {
      setState(() {
        _currentPosition = position;
        if (_totalDuration.inMilliseconds > 0) {
          _playbackProgress =
              _currentPosition.inMilliseconds / _totalDuration.inMilliseconds;
        }
      });
    });

    // Listen for duration changes
    _audioPlayer.onDurationChanged.listen((duration) {
      setState(() {
        _totalDuration = duration;
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playAudio() async {
    try {
      setState(() {
        _isLoading = true;
      });

      if (_isPlaying) {
        await _audioPlayer.pause();
        setState(() {
          _isPlaying = false;
        });
      } else {
        // Check if audio is from network or local file
        if (widget.audioPath.startsWith('http://') ||
            widget.audioPath.startsWith('https://')) {
          await _audioPlayer.play(UrlSource(widget.audioPath));
        } else {
          await _audioPlayer.play(DeviceFileSource(widget.audioPath));
        }
        setState(() {
          _isPlaying = true;
        });
      }
    } catch (e) {
      AppSnackBar.error('Failed to play audio: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _stopAudio() async {
    try {
      await _audioPlayer.stop();
      setState(() {
        _isPlaying = false;
        _currentPosition = Duration.zero;
        _playbackProgress = 0.0;
      });
    } catch (e) {
      AppSnackBar.error('Failed to stop audio: \${e.toString()}');
    }
  }

  Future<void> _seekTo(double progress) async {
    if (_totalDuration.inMilliseconds > 0) {
      final position = Duration(
        milliseconds: (_totalDuration.inMilliseconds * progress).round(),
      );
      await _audioPlayer.seek(position);
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final String totalLabel = _totalDuration.inMilliseconds > 0
        ? _formatDuration(_totalDuration)
        : (widget.duration ?? '0:00');
    final String timeLabel = _currentPosition.inMilliseconds > 0
        ? _formatDuration(_currentPosition)
        : totalLabel;

    // Figma "recorded audio" playback pill: white rounded bar with a circular
    // blue play/pause button, a tappable waveform track and a duration label.
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.stroke),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Play / pause button (long-press to stop & rewind)
          GestureDetector(
            onTap: _isLoading ? null : _playAudio,
            onLongPress: _isLoading ? null : _stopAudio,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _isLoading ? AppColors.textFaint : AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: _isLoading
                  ? const Center(
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                    )
                  : Icon(
                      _isPlaying ? LucideIcons.pause : LucideIcons.play,
                      size: 22,
                      color: AppColors.white50,
                    ),
            ),
          ),
          const SizedBox(width: 12),
          // Waveform track (doubles as a seek bar)
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (details) {
                final width = context.size?.width ?? 0;
                if (width > 0) {
                  _seekTo((details.localPosition.dx / width).clamp(0.0, 1.0));
                }
              },
              child: SizedBox(
                height: 32,
                child: _Waveform(progress: _playbackProgress.clamp(0.0, 1.0)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(timeLabel, style: AppTextStyles.bodySemibold),
        ],
      ),
    );
  }
}

/// Static waveform bars used by the audio playback pill. The bars before
/// [progress] use the active colour; the rest are muted.
class _Waveform extends StatelessWidget {
  const _Waveform({required this.progress});

  final double progress;

  static const List<double> _heights = [
    0.5, 0.8, 0.4, 1.0, 0.6, 0.9, 0.5, 0.7, 1.0, 0.45,
    0.85, 0.6, 0.95, 0.5, 0.7, 0.4, 0.8, 0.55, 0.9, 0.5,
    0.65, 0.45, 0.8, 0.6, 0.5,
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxH = constraints.maxHeight;
        final activeCount = (progress * _heights.length).round();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(_heights.length, (i) {
            final active = i < activeCount;
            return Container(
              width: 3,
              height: (maxH * _heights[i]).clamp(4.0, maxH),
              decoration: BoxDecoration(
                color: active ? AppColors.primary : AppColors.stroke,
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        );
      },
    );
  }
}
