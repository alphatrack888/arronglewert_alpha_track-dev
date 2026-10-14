import 'dart:io';
import 'package:alpha_track/core/app_route/app_route.dart';
import 'package:alpha_track/screens/notes_screen/notes_view/controller/note_veiw_controller.dart';
import 'package:alpha_track/services/repository/note_repository/note_repository.dart';
import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/utils/demo_data/demo_data.dart';
import 'package:alpha_track/widgets/app_snackbar/app_snackbar.dart';
import 'package:alpha_track/utils/app_text_styles/app_text_styles.dart';
import 'package:alpha_track/widgets/ds/ds_back_button.dart';
import 'package:alpha_track/widgets/ds/ds_bottom_sheet.dart';
import 'package:alpha_track/widgets/ds/ds_waveform.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Full-screen Create Note (Figma Notes flow): title + description, a GALLERY
/// section (images + add tile), an AUDIO section, and a Record Audio bottom
/// sheet driving the real recorder (start / pause / resume / done).
class CreateNoteScreen extends StatefulWidget {
  const CreateNoteScreen({
    super.key,
    this.projectName = 'Project',
    this.projectId,
  });
  final String projectName;
  final String? projectId;

  @override
  State<CreateNoteScreen> createState() => _CreateNoteScreenState();
}

class _CreateNoteScreenState extends State<CreateNoteScreen> {
  final NoteVeiwController c = Get.put(NoteVeiwController());
  final TextEditingController _titleCtrl = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  bool _showTranscript = false;

  // Demo transcript shown for an attached voice note (real transcription is a
  // backend job; this stands in for the redesign review).
  static const _demoTranscript =
      'Lawn looks healthy overall. Trimmed the edges along the path and '
      'cleared the clippings. Flagged the broken latch at gate B for follow-up.';

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  String get _todayLabel {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final n = DateTime.now();
    final h = n.hour % 12 == 0 ? 12 : n.hour % 12;
    final ap = n.hour < 12 ? 'AM' : 'PM';
    return '${months[n.month - 1]} ${n.day}, ${n.year} • $h:${n.minute.toString().padLeft(2, '0')} $ap';
  }

  Future<void> _pickImages() async {
    final imgs = await _picker.pickMultiImage();
    if (imgs.isNotEmpty) c.selectedImages.addAll(imgs);
  }

  Future<void> _save(BuildContext context) async {
    final title = _titleCtrl.text.trim();
    final body = c.textController.text.trim();
    final images = c.selectedImages.map((x) => File(x.path)).toList();
    final audio = c.hasRecording.value && c.audioPath != null
        ? File(c.audioPath!)
        : null;

    if (widget.projectId != null && !kDemoMode) {
      final content = [title, body]
          .where((s) => s.isNotEmpty)
          .join('\n')
          .trim();
      if (content.isEmpty && images.isEmpty && audio == null) {
        AppSnackBar.error('pleaseAddAtLeastOneContentType'.tr);
        return;
      }
      final ok = await NoteRepository().createNote(
        projectId: widget.projectId!,
        content: content.isEmpty ? null : content,
        images: images.isEmpty ? null : images,
        audio: audio,
      );
      if (!ok) {
        AppSnackBar.error('failedCreateNote'.tr);
        return;
      }
      dsPop(context, result: true);
      return;
    }

    final note = <String, String>{
      'title': title.isEmpty ? 'untitledNote'.tr : title,
      'body': body,
      'author': 'Marc G.',
      'time': 'justNow'.tr,
      'images': c.selectedImages.map((x) => x.path).join('|'),
      'audio': c.hasRecording.value ? (c.audioPath ?? '') : '',
    };
    dsPop(context, result: note);
  }

  void _openProject() {
    if (widget.projectId != null) {
      Get.toNamed(AppRoute.projectDetailsScreen,
          arguments: {'projectId': widget.projectId});
    }
  }

  // Opaque, generously-padded tap target so Cancel/Save register reliably on
  // touch (a plain TextButton's glyph is a small target).
  Widget _topBarAction(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(label,
            style: AppTextStyles.bodyMedium.copyWith(color: color)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  _topBarAction('Cancel', AppColors.textMuted, () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    dsPop(context);
                  }),
                  Expanded(
                    child: Text('createNote'.tr,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.titleSmall),
                  ),
                  _topBarAction('Save', AppColors.primary, () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    _save(context);
                  }),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.stroke),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _titleCtrl,
                      style: AppTextStyles.headline,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        hintText: 'enterTitle'.tr,
                        hintStyle: AppTextStyles.headline
                            .copyWith(color: AppColors.textFaint),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: c.textController,
                      maxLines: null,
                      minLines: 3,
                      style: AppTextStyles.body.copyWith(height: 1.5),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        hintText: 'enterDescription'.tr,
                        hintStyle: AppTextStyles.body
                            .copyWith(color: AppColors.textMuted),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // GALLERY — only once at least one image is added.
                    Obx(() => c.selectedImages.isEmpty
                        ? const SizedBox()
                        : _gallerySection()),
                    // AUDIO — only once a recording exists.
                    Obx(() => c.hasRecording.value
                        ? _audioSection()
                        : const SizedBox()),
                  ],
                ),
              ),
            ),
            _bottomBar(),
          ],
        ),
      ),
    );
  }

  // ---- GALLERY --------------------------------------------------------------
  Widget _gallerySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('GALLERY', style: AppTextStyles.eyebrow),
        const SizedBox(height: 10),
        SizedBox(
          height: 88,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: c.selectedImages.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) {
              if (i == c.selectedImages.length) return _addImageTile();
              return _imageThumb(i);
            },
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _addImageTile() {
    return GestureDetector(
      onTap: _pickImages,
      child: Container(
        width: 88,
        height: 88,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.5),
              style: BorderStyle.solid),
        ),
        child: const Icon(LucideIcons.imagePlus,
            color: AppColors.primary, size: 24),
      ),
    );
  }

  Widget _imageThumb(int i) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(File(c.selectedImages[i].path),
              width: 88, height: 88, fit: BoxFit.cover),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => c.selectedImages.removeAt(i),
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                  color: Colors.black54, shape: BoxShape.circle),
              child: const Icon(LucideIcons.x, size: 12, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  // ---- AUDIO ----------------------------------------------------------------
  Widget _audioSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('AUDIO', style: AppTextStyles.eyebrow),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.stroke),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: c.togglePlayback,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                      color: AppColors.primary, shape: BoxShape.circle),
                  child: Obx(() => Icon(
                      c.isPlaying.value ? LucideIcons.pause : LucideIcons.play,
                      color: Colors.white,
                      size: 20)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Obx(() => DsWaveform(playing: c.isPlaying.value)),
              ),
              const SizedBox(width: 12),
              Obx(() => Text(c.formattedDuration, style: AppTextStyles.caption)),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: c.resetRecordingState,
                child: const Icon(LucideIcons.trash2,
                    size: 18, color: AppColors.danger),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () => setState(() => _showTranscript = !_showTranscript),
          behavior: HitTestBehavior.opaque,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_showTranscript ? LucideIcons.chevronUp : LucideIcons.fileText,
                  size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(_showTranscript ? 'hideTranscript'.tr : 'showTranscript'.tr,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.primary)),
            ],
          ),
        ),
        if (_showTranscript) ...[
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.neutralSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(_demoTranscript,
                style: AppTextStyles.body.copyWith(height: 1.5)),
          ),
        ],
        const SizedBox(height: 20),
      ],
    );
  }

  // ---- Bottom bar -----------------------------------------------------------
  Widget _bottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.stroke)),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _openProject,
              behavior: HitTestBehavior.opaque,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(children: [
                    const Icon(LucideIcons.folder,
                        size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(widget.projectName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.primary)),
                    ),
                  ]),
                  const SizedBox(height: 2),
                  Text(_todayLabel, style: AppTextStyles.caption),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          _roundBtn(LucideIcons.imagePlus, AppColors.neutralSoft,
              AppColors.textSecondary, _pickImages),
          const SizedBox(width: 10),
          _roundBtn(LucideIcons.mic, AppColors.primary, Colors.white,
              _showRecordSheet),
        ],
      ),
    );
  }

  Widget _roundBtn(IconData icon, Color bg, Color fg, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
        child: Icon(icon, color: fg, size: 22),
      ),
    );
  }

  // ---- Record Audio bottom sheet -------------------------------------------
  void _showRecordSheet() {
    // Start fresh each time.
    if (!c.isRecording.value) c.resetRecordingState();
    DsBottomSheet.show(
      DsBottomSheet(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    if (c.isRecording.value) c.stopRecording();
                    c.resetRecordingState();
                    Get.back();
                  },
                  child: Text('Cancel',
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.textMuted)),
                ),
                Expanded(
                  child: Text('recordAudio'.tr,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.titleSmall),
                ),
                GestureDetector(
                  onTap: () async {
                    if (c.isRecording.value) await c.stopRecording();
                    Get.back();
                    setState(() {}); // reflect new AUDIO section
                  },
                  child: Text('Done',
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.primary)),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Obx(() {
              final recording = c.isRecording.value;
              final paused = c.isRecordingPaused.value;
              return Column(
                children: [
                  if (!recording)
                    Text('clickStartToRecord'.tr,
                        style: AppTextStyles.subtitle)
                  else
                    // Freeze the animation while recording is paused.
                    DsWaveform(
                        playing: !paused, barCount: 32, height: 48),
                  const SizedBox(height: 20),
                  Text(_clock(c.recordingDuration.value),
                      style: AppTextStyles.timer.copyWith(fontSize: 28)),
                  const SizedBox(height: 28),
                  _recordButton(recording, paused),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  String _clock(int seconds) {
    final m = seconds ~/ 60, s = seconds % 60;
    return '00:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Widget _recordButton(bool recording, bool paused) {
    if (!recording) {
      return OutlinedButton.icon(
        onPressed: c.startRecording,
        icon: const Icon(LucideIcons.mic, size: 18, color: AppColors.primary),
        label: Text('Start',
            style: AppTextStyles.bodySemibold
                .copyWith(color: AppColors.primary)),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(9999)),
        ),
      );
    }
    return GestureDetector(
      onTap: () => paused ? c.resumeRecording() : c.pauseRecording(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.danger.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(9999),
        ),
        child: Icon(paused ? LucideIcons.play : LucideIcons.pause,
            color: AppColors.danger, size: 22),
      ),
    );
  }
}

