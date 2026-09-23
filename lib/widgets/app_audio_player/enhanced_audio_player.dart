import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/utils/app_size/app_gap.dart';
import 'package:alpha_track/widgets/app_snackbar/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:alpha_track/utils/app_size/app_size.dart';
import 'package:alpha_track/widgets/app_text/app_text.dart';
import 'package:audioplayers/audioplayers.dart';

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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.blue50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.blue300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with audio icon and title
          Row(
            children: [
              Icon(Icons.audiotrack, size: 20, color: AppColors.blue600),
              const Gap(width: 8),
              Expanded(
                child: AppText(
                  text: widget.audioTitle ?? 'Audio Recording',
                  fontSize: AppSize.width(value: 16),
                  fontWeight: FontWeight.w600,
                  color: AppColors.blue600,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Gap(height: 16),

          // Audio controls container
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.blue300),
            ),
            child: Column(
              children: [
                // Progress slider
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppColors.blue500,
                    inactiveTrackColor: AppColors.blue100,
                    thumbColor: AppColors.blue500,
                    overlayColor: AppColors.blue500.withValues(alpha: 0.2),
                    trackHeight: 4.0,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 8.0,
                    ),
                  ),
                  child: Slider(
                    value: _playbackProgress.clamp(0.0, 1.0),
                    onChanged: (value) {
                      _seekTo(value);
                    },
                    min: 0.0,
                    max: 1.0,
                  ),
                ),
                // Time display
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppText(
                        text: _formatDuration(_currentPosition),
                        fontSize: AppSize.width(value: 12),
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                      AppText(
                        text: _totalDuration.inMilliseconds > 0
                            ? _formatDuration(_totalDuration)
                            : widget.duration ?? '0:00',
                        fontSize: AppSize.width(value: 12),
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ],
                  ),
                ),
                // Control buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Stop button
                    IconButton(
                      onPressed: _isLoading ? null : _stopAudio,
                      icon: Icon(
                        Icons.stop,
                        size: 32,
                        color: _isLoading
                            ? Colors.grey
                            : (_isPlaying ? Colors.red : AppColors.blue500),
                      ),
                    ),
                    const Gap(width: 06),
                    // Play/Pause button
                    GestureDetector(
                      onTap: _isLoading ? null : _playAudio,
                      child: Container(
                        width: AppSize.width(value: 40),
                        height: AppSize.height(value: 40),
                        decoration: BoxDecoration(
                          color: _isLoading ? Colors.grey : AppColors.blue500,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.blue.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: _isLoading
                            ? Center(
                                child: SizedBox(
                                  width: AppSize.width(value: 24),
                                  height: AppSize.height(value: 24),
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : Icon(
                                _isPlaying ? Icons.pause : Icons.play_arrow,
                                size: 32,
                                color: Colors.white,
                              ),
                      ),
                    ),
                  ],
                ),
                // Status text
                AppText(
                  text: _isPlaying
                      ? 'Playing...'
                      : _currentPosition.inMilliseconds > 0
                      ? 'Paused'
                      : 'Tap to play audio',
                  fontSize: AppSize.width(value: 14),
                  fontWeight: FontWeight.w500,
                  color: AppColors.blue700,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
