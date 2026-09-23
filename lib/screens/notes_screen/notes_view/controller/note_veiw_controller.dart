// note_veiw_controller.dart
import 'dart:async';
import 'dart:io';
import 'package:alpha_track/core/api_urls/api_urls.dart';
import 'package:alpha_track/screens/notes_screen/models/get_all_notes_models.dart';
import 'package:alpha_track/services/audio_palyer/audio_player_service.dart';
import 'package:alpha_track/services/audio_palyer/audio_recorder_service.dart';
import 'package:alpha_track/services/repository/note_repository/note_repository.dart';
import 'package:alpha_track/utils/app_log/app_log.dart';
import 'package:alpha_track/widgets/app_snackbar/app_snackbar.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

class NoteVeiwController extends GetxController {
  final TextEditingController textController = TextEditingController();
  final RxList<Map<String, dynamic>> messages = <Map<String, dynamic>>[].obs;
  final RxList<XFile> selectedImages = <XFile>[].obs;
  final AudioRecorderService _audioRecorderService = AudioRecorderService();
  final AudioPlayerService _audioPlayerService = AudioPlayerService();
  final NoteRepository _noteRepository = NoteRepository();
  final Rxn<AllNoteModel> noteList = Rxn<AllNoteModel>();

  // Enhanced audio recording properties
  var isRecording = false.obs;
  var isPlaying = false.obs;
  var recordingDuration = 0.obs;
  var hasRecording = false.obs;
  var isLoading = false.obs;

  // Progress bar properties
  var currentPlaybackPosition = 0.obs;
  var totalDuration = 0.obs;
  var playbackProgress = 0.0.obs;

  Timer? _recordingTimer;
  Timer? _playbackTimer;

  // Audio recording and playback instances
  late final AudioRecorder _audioRecorder;
  late final AudioPlayer _audioPlayer;
  String? _audioPath;

  // Public getter for audioPath
  String? get audioPath => _audioPath;

  // Add a variable to store project ID
  String? _projectId;

  @override
  void onInit() {
    super.onInit();
    _initializeAudio();

    // Safely get project ID with null check and store it
    final arguments = Get.arguments;
    appLog('🔍 DEBUG: Get.arguments = $arguments (type: ${arguments.runtimeType})');
    
    if (arguments != null) {
      _projectId = arguments.toString();
      appLog('✅ Project ID found and stored: $_projectId');
      fetchAlltheNote(_projectId!);
    } else {
      appLog('⚠️ Project ID not found in arguments during initialization');
    }
  }

  void _initializeAudio() {
    _audioRecorder = AudioRecorder();
    _audioPlayer = AudioPlayer();
    // Listen for playback completion
    _audioPlayer.onPlayerComplete.listen((_) {
      isPlaying.value = false;
      currentPlaybackPosition.value = 0;
      playbackProgress.value = 0.0;
      _stopPlaybackTimer();
    });

    // Listen for position changes
    _audioPlayer.onPositionChanged.listen((position) {
      currentPlaybackPosition.value = position.inMilliseconds;
      if (totalDuration.value > 0) {
        playbackProgress.value =
            currentPlaybackPosition.value / totalDuration.value;
      }
    });

    // Listen for duration changes
    _audioPlayer.onDurationChanged.listen((duration) {
      totalDuration.value = duration.inMilliseconds;
    });
  }

  @override
  void onClose() {
    _recordingTimer?.cancel();
    _playbackTimer?.cancel();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    _audioRecorderService.dispose();
    _audioPlayerService.dispose();
    super.onClose();
  }

  // Audio recording methods
  Future<bool> _requestPermission() async {
    final status = await Permission.microphone.request();
    return status == PermissionStatus.granted;
  }

  Future<String> _getAudioPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/audio_note_${DateTime.now().millisecondsSinceEpoch}.m4a';
  }

  Future<void> startRecording() async {
    try {
      isLoading.value = true;
      // Request permission
      final hasPermission = await _requestPermission();
      if (!hasPermission) {
        Get.snackbar(
          'Permission Required',
          'Microphone permission is needed to record audio',
          snackPosition: SnackPosition.BOTTOM,
        );
        isLoading.value = false;
        return;
      }

      // Reset duration BEFORE starting recording
      recordingDuration.value = 0;

      // Generate audio path
      _audioPath = await _getAudioPath();

      // Start recording
      await _audioRecorder.start(
        RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: _audioPath!,
      );

      // Update state
      isRecording.value = true;
      isLoading.value = false;

      // Start timer AFTER everything is set up
      _recordingTimer = Timer.periodic(Duration(seconds: 1), (timer) {
        recordingDuration.value++;
      });
    } catch (e) {
      isLoading.value = false;
      isRecording.value = false;
      Get.snackbar(
        'Recording Error',
        'Failed to start recording: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> stopRecording() async {
    try {
      isLoading.value = true;

      // Cancel timer FIRST
      _recordingTimer?.cancel();
      _recordingTimer = null;

      // Stop the recorder
      await _audioRecorder.stop();

      // Update state
      isRecording.value = false;
      isLoading.value = false;

      // Mark as having recording if duration > 0
      if (recordingDuration.value > 0 && _audioPath != null) {
        final file = File(_audioPath!);
        if (await file.exists()) {
          hasRecording.value = true;
          // Set total duration based on recording duration
          totalDuration.value = recordingDuration.value * 1000;
        }
      }
    } catch (e) {
      isLoading.value = false;
      isRecording.value = false;
      // Cancel timer in case of error too
      _recordingTimer?.cancel();
      _recordingTimer = null;
      Get.snackbar(
        'Recording Error',
        'Failed to stop recording: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void toggleRecording() {
    if (isLoading.value) return;

    if (isRecording.value) {
      stopRecording();
    } else {
      startRecording();
    }
  }

  void _startPlaybackTimer() {
    _playbackTimer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      // This will be handled by the audioplayer's onPositionChanged listener
      // But we can add additional logic here if needed
    });
  }

  void _stopPlaybackTimer() {
    _playbackTimer?.cancel();
    _playbackTimer = null;
  }

  Future<void> startPlayback() async {
    if (!hasRecording.value || _audioPath == null) {
      Get.snackbar(
        'No Recording',
        'Please record something first',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;

      // Stop any existing playback
      await _audioPlayer.stop();

      // Reset position
      currentPlaybackPosition.value = 0;
      playbackProgress.value = 0.0;

      // Start playing
      await _audioPlayer.play(DeviceFileSource(_audioPath!));

      isPlaying.value = true;
      isLoading.value = false;

      // Start the playback timer
      _startPlaybackTimer();
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        'Playback Error',
        'Failed to play audio: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> stopPlayback() async {
    try {
      await _audioPlayer.stop();
      isPlaying.value = false;
      currentPlaybackPosition.value = 0;
      playbackProgress.value = 0.0;
      _stopPlaybackTimer();
    } catch (e) {
      AppSnackBar.error('Failed to stop playback: ${e.toString()}');
    }
  }

  void togglePlayback() {
    if (isLoading.value) return;

    if (isPlaying.value) {
      stopPlayback();
    } else {
      startPlayback();
    }
  }

  // Seek to specific position (for progress bar interaction)
  Future<void> seekTo(double progress) async {
    if (!hasRecording.value || totalDuration.value == 0) return;

    final position = (totalDuration.value * progress).round();
    await _audioPlayer.seek(Duration(milliseconds: position));
  }

  // Formatting methods
  String get formattedDuration {
    int minutes = recordingDuration.value ~/ 60;
    int seconds = recordingDuration.value % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get formattedCurrentPosition {
    int totalSeconds = (currentPlaybackPosition.value / 1000).round();
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get formattedTotalDuration {
    int totalSeconds = (totalDuration.value / 1000).round();
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> saveAudioNote() async {
    if (hasRecording.value && _audioPath != null) {
      try {
        isLoading(true);

        // Use stored project ID instead of Get.arguments
        if (_projectId == null) {
          AppSnackBar.error('Project ID not found. Please try again.');
          isLoading(false);
          return;
        }

        // Call API to create audio note with the original audio file
        bool success = await _noteRepository.createNote(
          projectId: _projectId!,
          audio: File(
            _audioPath!,
          ), // Send original audio file without conversion
        );

        if (success) {
          appLog('✅ Audio note created successfully');
          resetRecordingState();
          // Refresh notes list to show the new note
          await fetchAlltheNote(_projectId!);
        } else {
          appLog('❌ Failed to create audio note');
          AppSnackBar.error('Failed to create audio note. Please try again.');
        }
      } catch (e) {
        appLog('💥 Error creating audio note: $e');
        AppSnackBar.error('An error occurred while creating the audio note.');
      } finally {
        isLoading(false);
      }
    }
  }

  void resetRecordingState() {
    _recordingTimer?.cancel();
    _playbackTimer?.cancel();
    _recordingTimer = null;
    _playbackTimer = null;

    isRecording.value = false;
    isPlaying.value = false;
    recordingDuration.value = 0;
    hasRecording.value = false;
    isLoading.value = false;
    currentPlaybackPosition.value = 0;
    totalDuration.value = 0;
    playbackProgress.value = 0.0;
    _audioPath = null;
  }

  // Comprehensive note creation method
  Future<void> createMixedNote({
    String? content,
    List<File>? images,
    File? audio,
  }) async {
    try {
      isLoading(true);

      // Use stored project ID instead of Get.arguments
      if (_projectId == null) {
        AppSnackBar.error('Project ID not found. Please try again.');
        isLoading(false);
        return;
      }
      
      appLog('✅ sendMessage using stored Project ID: $_projectId');

      // Call API to create note with mixed content (use original audio file)
      bool success = await _noteRepository.createNote(
        projectId: _projectId!,
        content: content,
        images: images,
        audio: audio, // Send original audio file without conversion
      );

      if (success) {
        appLog('✅ Mixed content note created successfully');
        // Clear all inputs
        textController.clear();
        selectedImages.clear();
        resetRecordingState();
        // Refresh notes list to show the new note
        await fetchAlltheNote(_projectId!);
        AppSnackBar.success('Mixed content note created successfully!');
      } else {
        appLog('❌ Failed to create mixed content note');
        AppSnackBar.error('Failed to create note. Please try again.');
      }
    } catch (e) {
      appLog('💥 Error creating mixed content note: $e');
      AppSnackBar.error('An error occurred while creating the note.');
    } finally {
      isLoading(false);
    }
  }

  // Image note methods
  Future<void> sendSelectedImages() async {
    // Validate input
    if (selectedImages.isEmpty) {
      AppSnackBar.error('Please select at least one image before saving.');
      return;
    }
    // Check image count limit
    if (selectedImages.length > 10) {
      AppSnackBar.error('Maximum 10 images allowed per note.');
      return;
    }
    try {
      isLoading(true);

      // Use stored project ID instead of Get.arguments
      if (_projectId == null) {
        AppSnackBar.error('Project ID not found. Please try again.');
        isLoading(false);
        return;
      }

      appLog(
        '🖼️ Attempting to create image note with ${selectedImages.length} images',
      );

      // Convert XFile paths to File objects and validate
      List<File> validImageFiles = [];
      int totalSize = 0;
      const int maxFileSize = 10 * 1024 * 1024; // 10MB per file
      const int maxTotalSize = 50 * 1024 * 1024; // 50MB total

      for (int i = 0; i < selectedImages.length; i++) {
        try {
          final file = File(selectedImages[i].path);

          // Check if file exists
          if (!await file.exists()) {
            appLog('⚠️ Image file not found: ${file.path}');
            continue;
          }

          // Check file size
          final fileSize = await file.length();
          if (fileSize > maxFileSize) {
            appLog('⚠️ Image file too large: ${file.path} (${fileSize} bytes)');
            AppSnackBar.error(
              'Image ${i + 1} is too large. Maximum 10MB per image.',
            );
            continue;
          }

          totalSize += fileSize;
          if (totalSize > maxTotalSize) {
            AppSnackBar.error('Total image size exceeds 50MB limit.');
            break;
          }

          validImageFiles.add(file);
        } catch (e) {
          appLog('❌ Error validating image ${selectedImages[i].path}: $e');
        }
      }

      if (validImageFiles.isEmpty) {
        AppSnackBar.error('No valid images found to upload.');
        return;
      }

      // Call API to create image note
      bool success = await _noteRepository.createNote(
        projectId: _projectId!,
        images: validImageFiles,
      );

      if (success) {
        appLog('✅ Image note created successfully');
        selectedImages.clear();
        // Refresh notes list to show the new note
        await fetchAlltheNote(_projectId!);
        AppSnackBar.success('Image note created successfully!');
      } else {
        appLog('❌ Failed to create image note');
      }
    } catch (e) {
      appLog('💥 Error creating image note: $e');
      String errorMessage = 'An error occurred while creating the image note.';

      if (e.toString().contains('SocketException')) {
        errorMessage = 'Network error. Please check your internet connection.';
      } else if (e.toString().contains('TimeoutException')) {
        errorMessage = 'Request timed out. Please try again.';
      } else if (e.toString().contains('FormatException')) {
        errorMessage = 'Invalid image format. Please select valid images.';
      }
      AppSnackBar.error(errorMessage);
    } finally {
      isLoading(false);
    }
  }

  // Text note methods
  Future<void> sendMessage() async {
    // Validate input
    if (textController.text.trim().isEmpty) {
      AppSnackBar.error('Please enter some text before saving the note.');
      return;
    }

    // Check text length
    if (textController.text.trim().length > 5000) {
      AppSnackBar.error(
        'Text content is too long. Maximum 5000 characters allowed.',
      );
      return;
    }

    try {
      isLoading(true);

      // Use stored project ID instead of Get.arguments
      if (_projectId == null) {
        AppSnackBar.error('Project ID not found. Please try again.');
        isLoading(false);
        return;
      }

      appLog(
        '📝 Attempting to create text note with ${textController.text.trim().length} characters',
      );

      // Call API to create note
      bool success = await _noteRepository.createNote(
        projectId: _projectId!,
        content: textController.text.trim(),
      );

      if (success) {
        appLog('✅ Text note created successfully');
        textController.clear();
        // Refresh notes list to show the new note
        await fetchAlltheNote(_projectId!);
        AppSnackBar.success('Text note created successfully!');
      } else {
        appLog('❌ Failed to create text note');
        AppSnackBar.error(
          'Failed to create note. Please check your internet connection and try again.',
        );
      }
    } catch (e) {
      appLog('💥 Error creating text note: $e');
      String errorMessage = 'An error occurred while creating the note.';

      if (e.toString().contains('SocketException')) {
        errorMessage = 'Network error. Please check your internet connection.';
      } else if (e.toString().contains('TimeoutException')) {
        errorMessage = 'Request timed out. Please try again.';
      } else if (e.toString().contains('FormatException')) {
        errorMessage = 'Invalid data format. Please try again.';
      }

      AppSnackBar.error(errorMessage);
    } finally {
      isLoading(false);
    }
  }

  // Time formatting utility
  String formatTime(DateTime time) {
    String hour = time.hour > 12
        ? (time.hour - 12).toString()
        : time.hour.toString();
    if (time.hour == 0) hour = '12';
    String minute = time.minute.toString().padLeft(2, '0');
    String period = time.hour >= 12 ? 'PM' : 'AM';
    return "$hour:$minute $period";
  }

  void playAudio(String path) {
    String audioPath = path;
    if (path.startsWith('/')) {
      // API relative path - construct full URL
      String baseUrl = ApiUrls.baseUrl;
      audioPath = baseUrl + path;
    }
    _audioPlayerService.play(audioPath);
  }

  Future<void> fetchAlltheNote(String projectId) async {
    try {
      isLoading(true);
      appLog('🚀 Starting to fetch notes for project: $projectId');

      // Add this debug call to see raw API response
      final notes = await _noteRepository.getAllNotes(projectId: projectId);

      appLog('📋 Repository response received:');
      appLog('   - statusCode: ${notes.statusCode}');
      appLog('   - success: ${notes.success}');
      appLog('   - message: ${notes.message}');
      appLog('   - data: ${notes.data?.runtimeType}');
      appLog('   - data length: ${notes.data?.length ?? 0}');

      if (notes.success == true) {
        if (notes.data != null && notes.data!.isNotEmpty) {
          noteList.value = notes;
          appLog('📦 Received ${notes.data!.length} notes from API');

          // Debug first note structure
          var firstNote = notes.data!.first;
          appLog('🔍 First note structure:');
          appLog('   - id: ${firstNote.id}');
          appLog(
            '   - content: ${firstNote.content?.substring(0, firstNote.content!.length.clamp(0, 50))}...',
          );
          appLog('   - createdBy: ${firstNote.createdBy?.name}');
          appLog('   - images count: ${firstNote.images?.length ?? 0}');
          appLog('   - audio count: ${firstNote.audio?.length ?? 0}');
          appLog('   - createdAt: ${firstNote.createdAt}');

          _convertApiNotesToMessages(notes.data!);
          appLog(
            '✅ Notes loaded successfully - Messages count: ${messages.length}',
          );

          // Debug messages after conversion
          if (messages.isNotEmpty) {
            appLog('🎯 First message after conversion: ${messages.first}');
          }
        } else {
          appLog('📭 API returned success but no notes data (empty array)');
          messages.clear();
        }
      } else {
        appLog('⚠️ API call unsuccessful:');
        appLog('   - success: ${notes.success}');
        appLog('   - message: ${notes.message}');
        appLog('   - statusCode: ${notes.statusCode}');
      }
    } catch (e, stackTrace) {
      appLog('❌ Error loading notes: $e');
      appLog('📍 Stack trace: $stackTrace');
    } finally {
      isLoading(false);
    }
  }

  // Manual refresh method for testing
  void refreshNotes() {
    // Use stored project ID instead of Get.arguments
    if (_projectId != null) {
      fetchAlltheNote(_projectId!);
    } else {
      appLog('⚠️ Project ID not found in stored variable during refresh');
      AppSnackBar.error('Project ID not found. Please try again.');
    }
  }

  void _convertApiNotesToMessages(List<Datum> apiNotes) {
    appLog(
      '🔄 Starting conversion of ${apiNotes.length} API notes to messages',
    );
    messages.clear();
    const String baseUrl = ApiUrls.liveDomain;

    if (apiNotes.isEmpty) {
      appLog('📭 No API notes to convert');
      return;
    }

    for (var note in apiNotes) {
      appLog('📋 Processing note: ID=${note.id}');

      // Create base note data
      Map<String, dynamic> noteData = {
        'id': note.id,
        'timestamp': note.createdAt ?? DateTime.now(),
        'createdBy': note.createdBy?.name ?? 'Unknown',
        'isSentByMe': false, // Notes from API are not sent by current user
      };

      // Check what content types this note has
      bool hasContent = note.content != null && note.content!.trim().isNotEmpty;
      bool hasImages = note.images != null && note.images!.isNotEmpty;
      bool hasAudio = note.audio != null && note.audio!.isNotEmpty;

      // Add text content if available
      if (hasContent) {
        noteData['text'] = note.content!.trim();
        noteData['content'] = note.content!
            .trim(); // Keep both for compatibility
        appLog(
          '✏️ Added text content: ${note.content!.substring(0, note.content!.length.clamp(0, 50))}...',
        );
      }

      // Add images if available
      if (hasImages) {
        List<String> fullImageUrls = note.images!.map((imagePath) {
          // Handle both relative and absolute URLs
          if (imagePath.startsWith('http://') ||
              imagePath.startsWith('https://')) {
            return imagePath;
          } else {
            // Remove leading slash if present to avoid double slashes
            String cleanPath = imagePath.startsWith('/')
                ? imagePath.substring(1)
                : imagePath;
            return '$baseUrl/$cleanPath';
          }
        }).toList();

        noteData['images'] = fullImageUrls;
        appLog('🖼️ Added ${fullImageUrls.length} images');

        // Log first image URL for debugging
        if (fullImageUrls.isNotEmpty) {
          appLog('📸 First image URL: ${fullImageUrls.first}');
        }
      }

      // Add audio if available
      if (hasAudio) {
        String audioPath = note.audio!.first;
        String fullAudioUrl;

        if (audioPath.startsWith('http://') ||
            audioPath.startsWith('https://')) {
          fullAudioUrl = audioPath;
        } else {
          // Remove leading slash if present to avoid double slashes
          String cleanPath = audioPath.startsWith('/')
              ? audioPath.substring(1)
              : audioPath;
          fullAudioUrl = '$baseUrl/$cleanPath';
        }

        noteData['audio'] = fullAudioUrl;
        noteData['duration'] =
            '0:00'; // Duration not provided by API, you might want to calculate this
        appLog('🎵 Added audio: $fullAudioUrl');
      }

      // Determine the primary type based on content (for backward compatibility)
      if (hasContent && hasImages && hasAudio) {
        noteData['type'] = 'mixed'; // All three types
      } else if (hasContent && hasImages) {
        noteData['type'] = 'text_images';
      } else if (hasContent && hasAudio) {
        noteData['type'] = 'text_audio';
      } else if (hasImages && hasAudio) {
        noteData['type'] = 'images_audio';
      } else if (hasContent) {
        noteData['type'] = 'text';
      } else if (hasImages) {
        noteData['type'] = 'images';
      } else if (hasAudio) {
        noteData['type'] = 'audio';
      } else {
        noteData['type'] = 'empty';
      }

      // Add content summary for debugging and UI
      List<String> contentTypes = [];
      if (hasContent) contentTypes.add('Text');
      if (hasImages)
        contentTypes.add(
          '${note.images!.length} Image${note.images!.length > 1 ? 's' : ''}',
        );
      if (hasAudio) contentTypes.add('Audio');
      noteData['contentSummary'] = contentTypes.join(' • ');

      // Add the note to messages
      messages.add(noteData);
      appLog(
        '✅ Added note: ID=${note.id}, Type=${noteData['type']}, Summary=${noteData['contentSummary']}',
      );
    }
    // Sort messages by timestamp (newest first)
    messages.sort(
      (a, b) =>
          (b['timestamp'] as DateTime).compareTo(a['timestamp'] as DateTime),
    );
    appLog('🔄 Conversion complete: ${messages.length} messages created');
    // Debug log for first few messages
    for (int i = 0; i < messages.length && i < 3; i++) {
      var msg = messages[i];
      appLog(
        '📄 Message $i: ${msg['contentSummary']}, CreatedBy: ${msg['createdBy']}, Type: ${msg['type']}',
      );
    }
    // Force UI update
    update();
    appLog('🔄 UI update triggered');
  }
}
