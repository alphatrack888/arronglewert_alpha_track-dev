// audio_controller.dart
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:http/http.dart' as http;

class AudioController extends GetxController {
  final AudioPlayer _audioPlayer = AudioPlayer();
  var isPlaying = false.obs;
  var duration = const Duration(seconds: 0).obs;
  var position = const Duration(seconds: 0).obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    _audioPlayer.durationStream.listen((d) {
      duration.value = d ?? Duration.zero;
    });
    
    _audioPlayer.positionStream.listen((p) {
      position.value = p;
    });
    
    _audioPlayer.playerStateStream.listen((state) {
      isPlaying.value = state.playing;
    });
    super.onInit();
  }

  Future<void> loadAudioFromUrl(String url) async {
    try {
      isLoading.value = true;
      await _audioPlayer.setUrl(url);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadAudioFromApi(String apiUrl) async {
    try {
      isLoading.value = true;
      
      // Fetch audio data from API
      final response = await http.get(Uri.parse(apiUrl));
      
      if (response.statusCode == 200) {
        // Load audio from bytes
        await _audioPlayer.setAudioSource(
          AudioSource.uri(Uri.parse(apiUrl)), 
        );
      } else {
        throw Exception('Failed to load audio');
      }
    } finally {
      isLoading.value = false;
    }
  }

  void play() => _audioPlayer.play();
  void pause() => _audioPlayer.pause();
  void stop() => _audioPlayer.stop();
  
  void seek(Duration position) => _audioPlayer.seek(position);

  @override
  void onClose() {
    _audioPlayer.dispose();
    super.onClose();
  }
}