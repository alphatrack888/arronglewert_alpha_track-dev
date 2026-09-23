
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class AudioRecorderService {
  final AudioRecorder _audioRecorder = AudioRecorder();
  String? _recordingPath;
  Timer? _timer;
  Duration _duration = Duration.zero;

  Future<void> startRecording({required Function(Duration) onDurationChanged}) async {
    final hasPermission = await _audioRecorder.hasPermission();
    if (hasPermission) {
      final directory = await getApplicationDocumentsDirectory();
      _recordingPath = '${directory.path}/recording.m4a';
      await _audioRecorder.start(const RecordConfig(), path: _recordingPath!);
      _startTimer(onDurationChanged);
    }
  }

  Future<String?> stopRecording() async {
    final path = await _audioRecorder.stop();
    _stopTimer();
    _duration = Duration.zero;
    return path;
  }

  void _startTimer(Function(Duration) onDurationChanged) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _duration += const Duration(seconds: 1);
      onDurationChanged(_duration);
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  void dispose() {
    _audioRecorder.dispose();
    _timer?.cancel();
  }
}
