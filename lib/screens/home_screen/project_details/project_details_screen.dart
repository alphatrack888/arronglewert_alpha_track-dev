import 'package:alpha_track/core/app_route/app_route.dart';
import 'package:alpha_track/screens/home_screen/main_home/controller/home_screen_controller.dart';
import 'package:alpha_track/screens/home_screen/models/single_project_model.dart';
import 'package:alpha_track/screens/home_screen/project_details/controller/project_details_screen_controller.dart';
import 'package:alpha_track/screens/home_screen/project_details/project_time_query.dart';
import 'package:alpha_track/screens/home_screen/project_details/time_tracker_sessions_body.dart';
import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/utils/app_text_styles/app_text_styles.dart';
import 'dart:io';
import 'package:alpha_track/screens/notes_screen/create_note_screen.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:alpha_track/widgets/ds/ds_back_button.dart';
import 'package:alpha_track/widgets/ds/ds_bottom_sheet.dart';
import 'package:alpha_track/widgets/ds/ds_buttons.dart';
import 'package:alpha_track/widgets/ds/ds_card.dart';
import 'package:alpha_track/widgets/ds/ds_chip.dart';
import 'package:alpha_track/widgets/ds/ds_project_tile.dart';
import 'package:alpha_track/widgets/app_snackbar/app_snackbar.dart';
import 'package:alpha_track/widgets/ds/ds_waveform.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:alpha_track/screens/home_screen/models/daily_summary_model.dart'
    as dsum;

class ProjectDetailsScreen extends StatefulWidget {
  const ProjectDetailsScreen({super.key});

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  late final ProjectDetailsScreenController controller =
      Get.isRegistered<ProjectDetailsScreenController>()
          ? Get.find<ProjectDetailsScreenController>()
          : Get.put(ProjectDetailsScreenController());
  int _tab = 0; // 0 Overview · 1 Time Tracker · 2 Notes
  bool _descExpanded = false;
  String _noteSort = 'Newest'; // 'Newest' | 'Oldest'

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      controller.syncFromRoute();
    });
  }

  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  String _fmtDate(DateTime? d) =>
      d == null ? 'Undefined' : '${_months[d.month - 1]} ${d.day}, ${d.year}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Obx(() {
          final data = controller.singleProjectData.value?.data;
          final title = data?.title ?? 'Project';
          return Column(
            children: [
              _appBar(title),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _cover(data),
                      const SizedBox(height: 16),
                      _tabBar(),
                      const SizedBox(height: 16),
                      if (_tab == 0) _overview(data),
                      if (_tab == 1) Obx(() => _timeTracker(data)),
                      if (_tab == 2) _notesTab(),
                    ],
                  ),
                ),
              ),
              _bottomBar(data, title),
            ],
          );
        }),
      ),
    );
  }

  Widget _appBar(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Row(
        children: [
          const DsBackButton(size: 42),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.title),
          ),
          DsCircleIconButton(
            icon: LucideIcons.bell,
            size: 42,
            onTap: () => Get.toNamed(AppRoute.notificationScreen),
          ),
        ],
      ),
    );
  }

  Widget _cover(SingleProjectModelData? data) {
    final img = (data?.images != null && data!.images!.isNotEmpty)
        ? data.images!.first
        : null;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 200,
        width: double.infinity,
        color: AppColors.fill,
        alignment: Alignment.center,
        child: img == null
            ? const Icon(LucideIcons.image, color: AppColors.textFaint, size: 40)
            : Image.network(img, fit: BoxFit.cover, width: double.infinity,
                errorBuilder: (_, __, ___) => const Icon(LucideIcons.image,
                    color: AppColors.textFaint, size: 40)),
      ),
    );
  }

  Widget _tabBar() {
    final labels = ['overview'.tr, 'timeTracker'.tr, 'notes'.tr];
    return Row(
      children: List.generate(labels.length, (i) {
        final selected = _tab == i;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() => _tab = i);
              if (i == 1) {
                final id = controller.currentProjectId;
                if (id != null) controller.loadTimeData(id);
              }
            },
            behavior: HitTestBehavior.opaque,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(labels[i],
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color:
                            selected ? AppColors.primary : AppColors.textMuted,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w500,
                      )),
                ),
                Container(
                  height: 2,
                  color: selected ? AppColors.primary : AppColors.stroke,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  // ---- Overview -------------------------------------------------------------
  Widget _overview(SingleProjectModelData? data) {
    final desc = data?.description ?? '';
    final lines = desc.split('\n');
    final paragraph =
        lines.where((l) => !l.trimLeft().startsWith('-')).join(' ').trim();
    final features = lines
        .where((l) => l.trimLeft().startsWith('-'))
        .map((l) => l.trimLeft().substring(1).trim())
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data?.title ?? 'Project', style: AppTextStyles.title),
                  const SizedBox(height: 2),
                  Text(data?.company?.name ?? '',
                      style: AppTextStyles.subtitle),
                ],
              ),
            ),
            _statusChip(data?.status),
          ],
        ),
        const SizedBox(height: 20),
        if (paragraph.isNotEmpty) ...[
          Text('projectDescription'.tr, style: AppTextStyles.eyebrow),
          const SizedBox(height: 8),
          Text(
            paragraph,
            maxLines: _descExpanded ? null : 3,
            overflow: _descExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
            style: AppTextStyles.body.copyWith(height: 1.5),
          ),
          GestureDetector(
            onTap: () => setState(() => _descExpanded = !_descExpanded),
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(_descExpanded ? 'showLess'.tr : 'showMore'.tr,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.primary)),
            ),
          ),
        ],
        if (features.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text('keyFeatures'.tr, style: AppTextStyles.eyebrow),
          const SizedBox(height: 8),
          ...features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 7, right: 8),
                      child: CircleAvatar(
                          radius: 2, backgroundColor: AppColors.textMuted),
                    ),
                    Expanded(
                        child: Text(f,
                            style: AppTextStyles.body.copyWith(height: 1.4))),
                  ],
                ),
              )),
        ],
        const SizedBox(height: 20),
        // Detail rows sit inside a card so the block reads as a grouped section
        // (matches the rest of the app; previously they floated on the bare
        // background with no container).
        DsCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Column(
            children: [
              _metaRow(
                  LucideIcons.calendar, 'started'.tr, _fmtDate(data?.startDate)),
              _metaDivider(),
              _metaRow(
                  LucideIcons.calendar, 'endDate'.tr, _fmtDate(data?.endDate)),
              _metaDivider(),
              _metaRow(LucideIcons.network, 'team'.tr, data?.company?.name ?? '—',
                  underline: true),
              _metaDivider(),
              _metaRow(
                LucideIcons.user,
                'responsible'.tr,
                (data?.employees != null && data!.employees!.isNotEmpty)
                    ? data.employees!.first
                    : '—',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _metaDivider() =>
      Divider(height: 1, thickness: 1, color: AppColors.stroke);

  Widget _statusChip(String? status) {
    switch ((status ?? '').toLowerCase()) {
      case 'active':
      case 'in-progress':
        return DsChip.success('activeStatus'.tr);
      case 'upcoming':
        return DsChip.primary('statusUpcoming'.tr);
      case 'completed':
        return DsChip.neutral('statusCompleted'.tr);
      case 'cancelled':
        return DsChip.warning('statusCancelled'.tr);
      case 'pending':
        return DsChip.neutral('statusPending'.tr);
      default:
        return DsChip.neutral(status ?? '');
    }
  }

  Widget _metaRow(IconData icon, String label, String value,
      {bool underline = false}) {
    // Label hugs the left (icon + text); value fills the rest, right-aligned —
    // so every row's value lines up to the same right edge (Figma).
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textMuted),
          const SizedBox(width: 10),
          Text(label,
              style: AppTextStyles.body.copyWith(color: AppColors.textMuted)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodySemibold.copyWith(
                decoration: underline ? TextDecoration.underline : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---- Time Tracker ---------------------------------------------------------

  /// Real tracked time for this project + the current user. Values come from the
  /// controller (daily summary + working-hours summary); nothing is hardcoded.
  Widget _timeTracker(SingleProjectModelData? data) {
    final daily = controller.dailySummaryData.value?.data;
    final timeState = controller.timeLoadingState.value;
    final sessions = sortedSessionsByStartDesc(daily?.sessions);
    final kind = timeTrackerListKind(
      loading: timeState == ProjectTimeLoadingState.loading,
      error: timeState == ProjectTimeLoadingState.error,
      sessionCount: sessions.length,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _ttStat('workedSoFar'.tr, _formatHours(data?.workedHours)),
            const SizedBox(width: 12),
            _ttStat('allocated'.tr, _fmtLimitHours(data?.projectTime)),
            const SizedBox(width: 12),
            _ttStat('overtime'.tr, _formatHoursMinutes(data?.overtimeHours)),
          ],
        ),
        const SizedBox(height: 16),
        DsCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('activityLog'.tr, style: AppTextStyles.eyebrow),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                        color: AppColors.neutralSoft,
                        borderRadius: BorderRadius.circular(8)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(LucideIcons.calendar,
                          size: 13, color: AppColors.textMuted),
                      const SizedBox(width: 6),
                      Text('today1'.tr, style: AppTextStyles.caption),
                    ]),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text('recentSessions'.tr, style: AppTextStyles.eyebrow),
        const SizedBox(height: 12),
        TimeTrackerSessionsBody(
          kind: kind,
          onRetry: () {
            final id = controller.currentProjectId;
            if (id != null) controller.loadTimeData(id);
          },
          empty: _timeEmptyState(),
          children: sessions.map(_sessionCard).toList(),
        ),
      ],
    );
  }

  /// Duration of a session (its `totalTime` is milliseconds) in whole hours.
  double _sessionHours(dsum.Session s) {
    final ms = s.totalTime ?? 0;
    if (ms > 0) return ms / 3600000.0;
    // Fallback: derive from start/end if totalTime is missing.
    final start = s.startTime, end = s.endTime;
    if (start != null && end != null) {
      return end.difference(start).inMinutes / 60.0;
    }
    return 0;
  }

  String _clock(DateTime? dt) {
    if (dt == null) return '--:--';
    final l = dt.toLocal();
    return '${l.hour.toString().padLeft(2, '0')}:${l.minute.toString().padLeft(2, '0')}';
  }

  String _formatHours(double? hours) {
    final h = hours ?? 0;
    final whole = h.floor();
    final minutes = ((h - whole) * 60).round();
    if (minutes == 0) return '${whole}h';
    return '${whole}h ${minutes}m';
  }

  String _fmtLimitHours(double? h) {
    final v = h ?? 0;
    if (v == v.roundToDouble()) return '${v.toInt()}h';
    final text = ((v * 100).round() / 100).toStringAsFixed(2);
    return '${text.replaceFirst(RegExp(r'0+$'), '')}h';
  }

  String _formatHoursMinutes(double? hours) {
    final totalMinutes = ((hours ?? 0) * 60).round();
    final safe = totalMinutes < 0 ? 0 : totalMinutes;
    final h = safe ~/ 60;
    final m = safe % 60;
    return '${h}h ${m}m';
  }

  Widget _timeEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      alignment: Alignment.center,
      child: Column(
        children: [
          const Icon(LucideIcons.clock, size: 28, color: AppColors.textMuted),
          const SizedBox(height: 10),
          Text('noSessionsYet'.tr,
              textAlign: TextAlign.center,
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _ttStat(String label, String value) {
    return Expanded(
      child: DsCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption),
            const SizedBox(height: 8),
            Text(value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.titleSmall),
          ],
        ),
      ),
    );
  }

  Widget _sessionCard(dsum.Session s) {
    final isCurrent = s.status == 'active' || s.status == 'paused';
    final range =
        '${_clock(s.startTime)} – ${s.endTime == null ? '…' : _clock(s.endTime)}';
    final dur = _formatHours(_sessionHours(s));
    final pauseCount = s.pauses?.length ?? 0;
    return DsCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                    color: const Color(0xFF1B8A8F).withValues(alpha: 0.15),
                    shape: BoxShape.circle),
                child: const Icon(LucideIcons.clock,
                    size: 15, color: Color(0xFF1B8A8F)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('work'.tr, style: AppTextStyles.bodySemibold),
                    const SizedBox(height: 2),
                    Text(range,
                        style: AppTextStyles.caption.copyWith(
                            color: isCurrent
                                ? AppColors.success
                                : AppColors.textMuted)),
                  ],
                ),
              ),
              Text(dur, style: AppTextStyles.bodySemibold),
            ],
          ),
          if (pauseCount > 0) ...[
            const SizedBox(height: 10),
            Row(children: [
              _sessionBadge(
                  LucideIcons.coffee,
                  '$pauseCount ${'breaks'.tr}',
                  const Color(0xFFE9856B),
                  const Color(0xFFFBEDE8)),
            ]),
          ],
        ],
      ),
    );
  }

  Widget _sessionBadge(IconData icon, String text, Color fg, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(9999)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 13, color: fg),
        const SizedBox(width: 6),
        Text(text, style: AppTextStyles.caption.copyWith(color: fg)),
      ]),
    );
  }

  // ---- Notes ----------------------------------------------------------------
  Widget _notesTab() {
    if (controller.notesLoadingState.value ==
        ProjectNotesLoadingState.loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(
          child: SizedBox(
            height: 28,
            width: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
        ),
      );
    }
    if (controller.notesLoadingState.value ==
        ProjectNotesLoadingState.error) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Column(
            children: [
              const Icon(LucideIcons.circleAlert,
                  size: 36, color: AppColors.textFaint),
              const SizedBox(height: 12),
              Text('retry'.tr, style: AppTextStyles.titleSmall),
              const SizedBox(height: 12),
              SecondaryButton(
                label: 'retry'.tr,
                isTranslate: false,
                onTap: () {
                  final id = controller.currentProjectId;
                  if (id != null) controller.loadProjectNotes(id);
                },
              ),
            ],
          ),
        ),
      );
    }
    final notes = _sortedNotes;
    if (notes.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Column(
            children: [
              const Icon(LucideIcons.fileText,
                  size: 36, color: AppColors.textFaint),
              const SizedBox(height: 12),
              Text('noNotesYet'.tr, style: AppTextStyles.titleSmall),
              const SizedBox(height: 4),
              Text('tapAddNote'.tr,
                  style: AppTextStyles.subtitle),
            ],
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('projectNotes'.tr, style: AppTextStyles.eyebrow),
            GestureDetector(
              onTap: _openSortSheet,
              behavior: HitTestBehavior.opaque,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${'sortBy'.tr}: ${_noteSort == 'Newest' ? 'newest'.tr : 'oldestFirst'.tr}', style: AppTextStyles.caption),
                  const SizedBox(width: 4),
                  const Icon(LucideIcons.chevronDown,
                      size: 14, color: AppColors.textMuted),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._sortedNotes.map(_noteCard),
      ],
    );
  }

  // Notes are stored newest-first; 'Oldest' just reverses the display order.
  List<Map<String, String>> get _sortedNotes {
    final list = controller.projectNotes.toList();
    return _noteSort == 'Oldest' ? list.reversed.toList() : list;
  }

  void _openSortSheet() {
    DsBottomSheet.show(
      DsBottomSheet(
        title: 'sortNotes'.tr,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sortOption('Newest', 'newestFirst'.tr),
            _sortOption('Oldest', 'oldestFirst'.tr),
          ],
        ),
      ),
    );
  }

  Widget _sortOption(String key, String label) {
    final selected = _noteSort == key;
    return DsSheetAction(
      icon: selected ? LucideIcons.check : LucideIcons.arrowDownUp,
      label: label,
      iconColor: selected ? AppColors.primary : AppColors.textMuted,
      onTap: () {
        setState(() => _noteSort = key);
        Get.back();
      },
    );
  }

  List<String> _imgsOf(Map<String, String> note) =>
      (note['images'] ?? '').split('|').where((e) => e.isNotEmpty).toList();

  Widget _noteCard(Map<String, String> note) {
    final imgs = _imgsOf(note);
    final hasAudio = (note['audio'] ?? '').isNotEmpty;
    return DsCard(
      onTap: () => Get.to(() => NoteDetailScreen(note: note)),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(note['title'] ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodySemibold),
          if ((note['body'] ?? '').isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(note['body'] ?? '',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.subtitle.copyWith(height: 1.4)),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              DsAvatar(name: note['author'] ?? '?', size: 24, circle: true),
              const SizedBox(width: 8),
              Expanded(
                child: Text('${note['author'] ?? ''} • ${note['time'] ?? ''}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption),
              ),
              if (hasAudio) _noteBadge(LucideIcons.mic, '1'),
              if (hasAudio && imgs.isNotEmpty) const SizedBox(width: 6),
              if (imgs.isNotEmpty)
                _noteBadge(LucideIcons.images, '${imgs.length}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _noteBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(9999)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 13, color: AppColors.primary),
        const SizedBox(width: 5),
        Text(text,
            style: AppTextStyles.caption.copyWith(
                color: AppColors.primary, fontWeight: FontWeight.w600)),
      ]),
    );
  }

  // ---- Bottom bar -----------------------------------------------------------
  HomeScreenController get _home => Get.isRegistered<HomeScreenController>()
      ? Get.find<HomeScreenController>()
      : Get.put(HomeScreenController());

  Widget _bottomBar(SingleProjectModelData? data, String title) {
    final home = _home;
    return Obx(() {
      final isThisProject = home.currentProjectId == (data?.id ?? '');
      final tracking = !home.isStopped && isThisProject;
      return Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.stroke)),
        ),
        child: tracking ? _trackingBar(home, data, title) : _startBar(data, title),
      );
    });
  }

  // Idle state: Start Tracking (+ Add Note only on the Notes tab).
  Widget _startBar(SingleProjectModelData? data, String title) {
    final home = _home;
    final projectId = data?.id ?? '';
    return Obx(() {
      final phaseLabel = home.startPrepareLabelKey;
      final apiLoading = home.isApiLoading;
      final blocked = home.isStartBlockedFor(projectId);
      return Row(
        children: [
          Expanded(
            child: PrimaryButton(
              label: phaseLabel != null ? phaseLabel.tr : 'startTracking'.tr,
              isTranslate: false,
              icon: phaseLabel == null ? LucideIcons.play : null,
              isLoading: apiLoading,
              color: blocked ? AppColors.fill : null,
              textColor: blocked ? AppColors.textMuted : null,
              onTap: (apiLoading || phaseLabel != null)
                  ? null
                  : () => _startTracking(data, title, projectId: projectId),
            ),
          ),
          if (_tab == 2) ...[
            const SizedBox(width: 12),
            Expanded(
              child: SecondaryButton(
                label: 'addNote'.tr,
                isTranslate: false,
                icon: LucideIcons.edit,
                onTap: apiLoading ? null : () => _openCreateNote(data, title),
              ),
            ),
          ],
        ],
      );
    });
  }

  // Active state: compact blue tracking pill. On the Notes tab it shrinks to
  // make room for the "Add Note" button beside it.
  Widget _trackingBar(
      HomeScreenController home, SingleProjectModelData? data, String title) {
    if (_tab == 2) {
      return Row(
        children: [
          Expanded(child: _trackingPill(home)),
          const SizedBox(width: 12),
          SecondaryButton(
            label: 'addNote'.tr,
            isTranslate: false,
            icon: LucideIcons.notebookPen,
            radius: 12,
            height: 44,
            width: 138,
            onTap: () => _openCreateNote(data, title),
          ),
        ],
      );
    }
    return _trackingPill(home);
  }

  // The mini timer widget itself (also shared with Time Tracker/Notes tabs).
  Widget _trackingPill(HomeScreenController home) {
    final onBreak = home.isPaused;
    final stopBusy = home.isTimerActionBusy(TimerActionWait.stop);
    final toggleBusy = home.isTimerActionBusy(
      onBreak ? TimerActionWait.resume : TimerActionWait.takeBreak,
    );
    final locked = home.isAnyTimerActionBusy;
    return Container(
      height: 44,
      padding: const EdgeInsets.fromLTRB(13, 5, 5, 5),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D1F2A44),
            offset: Offset(-1, 1),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Live indicator + timer.
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: (onBreak ? AppColors.warning : AppColors.trackingDot)
                      .withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: onBreak ? AppColors.warning : AppColors.trackingDot,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                onBreak ? home.formattedBreakTime : home.formattedTime,
                style: AppTextStyles.bodySemibold
                    .copyWith(color: AppColors.surface, height: 20 / 14),
              ),
            ],
          ),
          // Stop + Pause/Resume controls.
          Row(
            children: [
              _pillButton(
                icon: LucideIcons.square,
                background: AppColors.trackingStopBg,
                iconColor: AppColors.surface,
                loading: stopBusy,
                onTap: locked ? () {} : () => home.stop(),
              ),
              const SizedBox(width: 4),
              _pillButton(
                icon: onBreak ? LucideIcons.play : LucideIcons.pause,
                background: AppColors.trackingPauseBg,
                iconColor: AppColors.primary,
                loading: toggleBusy,
                onTap: locked
                    ? () {}
                    : () => onBreak ? home.resume() : home.pause(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pillButton({
    required IconData icon,
    required Color background,
    required Color iconColor,
    required VoidCallback onTap,
    bool loading = false,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: loading ? null : onTap,
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(8),
        ),
        child: loading
            ? SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: iconColor,
                ),
              )
            : Icon(icon, size: 16, color: iconColor),
      ),
    );
  }

  Future<void> _startTracking(
    SingleProjectModelData? data,
    String title, {
    required String projectId,
  }) async {
    final home = _home;
    if (home.isApiLoading) return;
    if (projectId.isEmpty) {
      AppSnackBar.error('selectProjectFirst'.tr);
      return;
    }
    await home.requestStartForProject(projectId, projectTitle: title);
  }

  Future<void> _openCreateNote(
      SingleProjectModelData? data, String title) async {
    final projectId = data?.id ?? controller.currentProjectId;
    final res = await Get.to(
      () => CreateNoteScreen(projectName: title, projectId: projectId),
    );
    if (res == true || res is Map<String, String>) {
      setState(() => _tab = 2);
      if (projectId != null) {
        await controller.loadProjectNotes(projectId);
      }
    }
  }
}

/// Full-screen detail view for a saved note (title, body, images, audio).
class NoteDetailScreen extends StatefulWidget {
  const NoteDetailScreen({super.key, required this.note});
  final Map<String, String> note;

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  bool _showTranscript = false;

  // Demo transcript for an attached voice note (real transcription is a backend
  // job; this stands in for the redesign review).
  static const _demoTranscript =
      'Lawn looks healthy overall. Trimmed the edges along the path and '
      'cleared the clippings. Flagged the broken latch at gate B for follow-up.';

  List<String> get _imgs => (widget.note['images'] ?? '')
      .split('|')
      .where((e) => e.isNotEmpty)
      .toList();

  @override
  Widget build(BuildContext context) {
    final note = widget.note;
    final audio = note['audio'] ?? '';
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Row(
                children: [
                  const DsBackButton(size: 42),
                  const SizedBox(width: 12),
                  Expanded(child: Text('Note', style: AppTextStyles.title)),
                  // Creator avatar lives in the header.
                  DsAvatar(
                      name: note['author'] ?? '?', size: 36, circle: true),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(note['title'] ?? '', style: AppTextStyles.headline),
                    const SizedBox(height: 8),
                    Text('${note['author'] ?? ''} • ${note['time'] ?? ''}',
                        style: AppTextStyles.caption),
                    if ((note['body'] ?? '').isNotEmpty) ...[
                      const SizedBox(height: 18),
                      Text(note['body'] ?? '',
                          style: AppTextStyles.body.copyWith(height: 1.6)),
                    ],
                    if (_imgs.isNotEmpty) ...[
                      const SizedBox(height: 22),
                      Text('IMAGES', style: AppTextStyles.eyebrow),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: _imgs.map(_image).toList(),
                      ),
                    ],
                    if (audio.isNotEmpty) ...[
                      const SizedBox(height: 22),
                      Text('AUDIO', style: AppTextStyles.eyebrow),
                      const SizedBox(height: 10),
                      _NoteAudioPlayer(path: audio),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () =>
                            setState(() => _showTranscript = !_showTranscript),
                        behavior: HitTestBehavior.opaque,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                                _showTranscript
                                    ? LucideIcons.chevronUp
                                    : LucideIcons.fileText,
                                size: 16,
                                color: AppColors.primary),
                            const SizedBox(width: 6),
                            Text(
                                _showTranscript
                                    ? 'hideTranscript'.tr
                                    : 'showTranscript'.tr,
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
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _image(String path) {
    final isUrl = path.startsWith('http');
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 104,
        height: 104,
        child: isUrl
            ? Image.network(path, fit: BoxFit.cover)
            : Image.file(File(path), fit: BoxFit.cover),
      ),
    );
  }
}

/// Inline audio player for a saved note (plays a local file or URL).
class _NoteAudioPlayer extends StatefulWidget {
  const _NoteAudioPlayer({required this.path});
  final String path;

  @override
  State<_NoteAudioPlayer> createState() => _NoteAudioPlayerState();
}

class _NoteAudioPlayerState extends State<_NoteAudioPlayer> {
  final AudioPlayer _player = AudioPlayer();
  bool _playing = false;

  @override
  void initState() {
    super.initState();
    _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _playing = false);
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (_playing) {
      await _player.pause();
      if (mounted) setState(() => _playing = false);
    } else {
      final src = widget.path.startsWith('http')
          ? UrlSource(widget.path)
          : DeviceFileSource(widget.path);
      await _player.play(src);
      if (mounted) setState(() => _playing = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _toggle,
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                  color: AppColors.primary, shape: BoxShape.circle),
              child: Icon(_playing ? LucideIcons.pause : LucideIcons.play,
                  color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: DsWaveform(playing: _playing, height: 28)),
          const SizedBox(width: 12),
          Text('voiceNote'.tr, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

/// Manual-session entry sheet: pick a date and start/end time, see the computed
/// duration, and add the session to the Time Tracker list. Local-only (no
/// backend call) to match how the demo session list is populated.
class _AddManualSessionSheet extends StatefulWidget {
  const _AddManualSessionSheet();

  @override
  State<_AddManualSessionSheet> createState() => _AddManualSessionSheetState();
}

class _AddManualSessionSheetState extends State<_AddManualSessionSheet> {
  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  DateTime _date = DateTime.now();
  TimeOfDay _start = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _end = const TimeOfDay(hour: 17, minute: 0);

  int get _startMin => _start.hour * 60 + _start.minute;
  int get _endMin => _end.hour * 60 + _end.minute;
  bool get _valid => _endMin > _startMin;

  String _fmtTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  String get _dateLabel =>
      '${_months[_date.month - 1]} ${_date.day}, ${_date.year}';

  String get _durationLabel {
    final mins = _endMin - _startMin;
    return '${mins ~/ 60}h ${mins % 60}m';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime({required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _start : _end,
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _start = picked;
      } else {
        _end = picked;
      }
    });
  }

  void _save() {
    if (!_valid) return;
    Get.back(result: <String, String>{
      'sub': '$_dateLabel • ${_fmtTime(_start)} – ${_fmtTime(_end)}',
      'dur': _durationLabel,
    });
  }

  @override
  Widget build(BuildContext context) {
    return DsBottomSheet(
      title: 'addSession'.tr,
      trailing: GestureDetector(
        onTap: Get.back,
        behavior: HitTestBehavior.opaque,
        child: Text('Cancel',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textMuted)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('Date'),
          _fieldBox(value: _dateLabel, onTap: _pickDate),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('startTime'.tr),
                    _fieldBox(
                        value: _fmtTime(_start),
                        onTap: () => _pickTime(isStart: true)),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('endTime'.tr),
                    _fieldBox(
                        value: _fmtTime(_end),
                        onTap: () => _pickTime(isStart: false)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Duration pill — mirrors the "Leave Duration" pill on Apply Leave.
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: _valid
                  ? AppColors.primarySoft
                  : AppColors.danger.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              _valid
                  ? '${'sessionDuration'.tr}: $_durationLabel'
                  : 'endAfterStart'.tr,
              style: AppTextStyles.bodyMedium.copyWith(
                color: _valid ? AppColors.primary : AppColors.danger,
              ),
            ),
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            label: _valid ? 'addDurationSession'.trParams({'dur': _durationLabel}) : 'addSession'.tr,
            isTranslate: false,
            color: _valid ? AppColors.primary : AppColors.textFaint,
            onTap: _valid ? _save : null,
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: AppTextStyles.caption.copyWith(fontSize: 13)),
      );

  /// Outlined, tappable field matching the Apply Leave date/type fields.
  Widget _fieldBox({required String value, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.stroke),
        ),
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body),
            ),
            const Icon(LucideIcons.chevronDown,
                size: 18, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
