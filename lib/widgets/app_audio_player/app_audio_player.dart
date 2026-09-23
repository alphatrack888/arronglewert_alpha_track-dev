// app_audio_player.dart

import 'package:alpha_track/core/api_urls/api_urls.dart';
import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/utils/app_size/app_gap.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AppAudioPlayer extends StatefulWidget {
  final String audioUrl;

  const AppAudioPlayer({Key? key, required this.audioUrl}) : super(key: key);

  @override
  State<AppAudioPlayer> createState() => _AppAudioPlayerState();
}

class _AppAudioPlayerState extends State<AppAudioPlayer> {
  late final AudioPlayer _player;
  String? _resolvedUrl;
  bool _isInitialized = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _resolveUrl();
    _setupPlayerStateListener();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializePlayer();
    });
  }

  void _setupPlayerStateListener() {
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        // Audio has finished playing, reset to beginning
        _player.seek(Duration.zero);
        _player.pause();
      }
    });
  }

  void _resolveUrl() {
    try {
      if (widget.audioUrl.isEmpty) {
        _resolvedUrl = null;
        return;
      }
      final uri = Uri.tryParse(widget.audioUrl);
      if (uri != null && (uri.isScheme('http') || uri.isScheme('https'))) {
        _resolvedUrl = widget.audioUrl;
      } else {
        // Ensure there's no double slash
        String baseUrl = ApiUrls.liveDomain;
        if (baseUrl.endsWith('/') && widget.audioUrl.startsWith('/')) {
          _resolvedUrl =
              '${baseUrl.substring(0, baseUrl.length - 1)}${widget.audioUrl}';
        } else if (!baseUrl.endsWith('/') && !widget.audioUrl.startsWith('/')) {
          _resolvedUrl = '$baseUrl/${widget.audioUrl}';
        } else {
          _resolvedUrl = '$baseUrl$widget.audioUrl';
        }
      }
    } catch (e) {
      debugPrint("Error resolving URL: $e");
      _resolvedUrl = widget.audioUrl;
    }
  }

  Future<void> _initializePlayer() async {
    if (_resolvedUrl == null || _resolvedUrl!.isEmpty) {
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      await _player.setUrl(_resolvedUrl!);
      setState(() {
        _isInitialized = true;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Failed to load audio: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Don't show anything if URL is empty
    if (widget.audioUrl.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.blue50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isLoading)
            const CircularProgressIndicator()
          else if (_isInitialized)
            StreamBuilder<PlayerState>(
              stream: _player.playerStateStream,
              builder: (context, snapshot) {
                final isPlaying = _player.playing;
                return IconButton(
                  icon: Icon(
                    isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_fill,
                    size: 30,
                  ),
                  onPressed: () async {
                    if (isPlaying) {
                      await _player.pause();
                    } else {
                      await _player.play();
                    }
                  },
                );
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.play_circle_fill, size: 30),
              onPressed: _initializePlayer,
            ),

          if (_isInitialized) ...[
            const Gap(height: 10),
            StreamBuilder<Duration?>(
              stream: _player.durationStream,
              builder: (context, durationSnapshot) {
                final duration = durationSnapshot.data ?? Duration.zero;
                return StreamBuilder<Duration>(
                  stream: _player.positionStream,
                  builder: (context, positionSnapshot) {
                    final position = positionSnapshot.data ?? Duration.zero;
                    return Slider(
                      activeColor: AppColors.blue600,
                      min: 0.0,
                      max: duration.inSeconds > 0
                          ? duration.inSeconds.toDouble()
                          : 1.0,
                      value: duration.inSeconds > 0
                          ? (position.inSeconds.toDouble() >
                                    duration.inSeconds.toDouble()
                                ? duration.inSeconds.toDouble()
                                : position.inSeconds.toDouble())
                          : 0.0,
                      onChanged: (value) {
                        _player.seek(Duration(seconds: value.toInt()));
                      },
                    );
                  },
                );
              },
            ),
            const Gap(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StreamBuilder<Duration>(
                  stream: _player.positionStream,
                  builder: (context, snapshot) {
                    final position = snapshot.data ?? Duration.zero;
                    return Text(_formatDuration(position));
                  },
                ),
                StreamBuilder<Duration?>(
                  stream: _player.durationStream,
                  builder: (context, snapshot) {
                    final duration = snapshot.data ?? Duration.zero;
                    return Text(_formatDuration(duration));
                  },
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }
}
