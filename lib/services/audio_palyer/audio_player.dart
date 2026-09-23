// audio_player_view.dart
import 'package:alpha_track/services/audio_palyer/controller/audio_controller.dart';
import 'package:alpha_track/utils/app_size/app_gap.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class AudioPlayerView extends StatelessWidget {
  final String audioUrl;

  const AudioPlayerView({Key? key, required this.audioUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AudioController controller = Get.find<AudioController>();

    // // Load audio when view initializes
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   controller.loadAudioFromUrl(audioUrl);
    // });

    return Scaffold(
      appBar: AppBar(title: const Text('Audio Player')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Play/Pause button
            Obx(
              () => IconButton(
                icon: Icon(
                  controller.isPlaying.value
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_fill,
                  size: 20,
                ),
                onPressed: controller.isLoading.value
                    ? null
                    : () {
                        if (controller.isPlaying.value) {
                          controller.pause();
                        } else {
                          controller.play();
                        }
                      },
              ),
            ),
            Gap(height: 20,),
            // Progress bar
            Obx(
              () => Slider(
                value: controller.position.value.inSeconds.toDouble(),
                min: 0.0,
                max: controller.duration.value.inSeconds.toDouble(),
                onChanged: (value) {
                  controller.seek(Duration(seconds: value.toInt()));
                },
              ),
            ),

            // Time display
            Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(formatDuration(controller.position.value)),
                  Text(formatDuration(controller.duration.value)),
                ],
              ),
            ),

            // Loading indicator
            Obx(
              () => Visibility(
                visible: controller.isLoading.value,
                child: LoadingAnimationWidget.beat(
                  size: 24,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }
}
