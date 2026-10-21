import 'package:alpha_track/screens/home_screen/main_home/controller/home_screen_controller.dart';
import 'package:alpha_track/screens/home_screen/models/all_project_models.dart';
import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/utils/app_text_styles/app_text_styles.dart';
import 'package:alpha_track/widgets/ds/ds_card.dart';
import 'package:alpha_track/widgets/ds/ds_chip.dart';
import 'package:alpha_track/widgets/ds/ds_project_tile.dart';
import 'package:alpha_track/widgets/ds/ds_running_project_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:alpha_track/widgets/ds/ds_back_button.dart';

/// Projects tab (2026 redesign).
///
/// RESTYLE ONLY: reuses [HomeScreenController] for all data and navigation.
class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  late final HomeScreenController controller;
  final RxInt _activeTab = 0.obs;

  static const _tabs = ['Active', 'Upcoming', 'Completed', 'Cancelled'];

  @override
  void initState() {
    super.initState();
    controller = Get.find<HomeScreenController>();
    controller.loadProjectList();
    controller.loadProjectTrackedHours();
  }

  // Bucket projects by their status field into the four tabs.
  // Index 0 = Active, 1 = Upcoming, 2 = Completed, 3 = Cancelled.
  int _bucketFor(Datum project) {
    final status = (project.status ?? '').toLowerCase();
    if (status.contains('upcoming') || status.contains('pending')) return 1;
    if (status.contains('complete') || status.contains('done')) return 2;
    if (status.contains('cancel')) return 3;
    return 0; // default everything else to Active
  }

  String _formatHours(double? hours) {
    final h = hours ?? 0;
    final whole = h.floor();
    final minutes = ((h - whole) * 60).round();
    if (minutes == 0) return '${whole}h';
    return '${whole}h ${minutes}m';
  }

  String _todayLabel(String? projectId) =>
      _formatHours(controller.projectTodayHours[projectId]);

  String _weekLabel(String? projectId) =>
      _formatHours(controller.projectWeekHours[projectId]);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Obx(() {
          final all = controller.allProjectData.value?.data?.data ?? <Datum>[];
          final buckets = <List<Datum>>[[], [], [], []];
          for (final p in all) {
            buckets[_bucketFor(p)].add(p);
          }
          final selected = _activeTab.value;
          final visible = buckets[selected];

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _header(),
                    const SizedBox(height: 20),
                    _tabRow(buckets),
                    const SizedBox(height: 16),
                    if (selected == 0 && visible.isNotEmpty)
                      _featuredCard(visible.first),
                    if (selected == 0 && visible.isNotEmpty)
                      const SizedBox(height: 12),
                    ..._rowsFor(selected, visible),
                    if (visible.isEmpty) _emptyState(),
                    const SizedBox(height: 20),
                  ]),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _header() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('projects'.tr, style: AppTextStyles.headline),
        GestureDetector(
          onTap: _openSearch,
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(LucideIcons.search,
                size: 20, color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }

  void _openSearch() {
    final all = controller.allProjectData.value?.data?.data ?? <Datum>[];
    Get.to(() => ProjectSearchScreen(
          projects: all,
          onOpen: _openProject,
          formatTime: _todayLabel,
        ));
  }

  Widget _tabRow(List<List<Datum>> buckets) {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 22),
        itemBuilder: (context, i) {
          final isSelected = _activeTab.value == i;
          final count = buckets[i].length;
          final base = const ['activeStatus', 'statusUpcoming', 'statusCompleted', 'statusCancelled'][i].tr;
          final label = i == 3 ? base : '$base ($count)';
          return GestureDetector(
            onTap: () => _activeTab.value = i,
            behavior: HitTestBehavior.opaque,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textMuted,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  height: 2,
                  width: 28,
                  color: isSelected ? AppColors.primary : Colors.transparent,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Featured/active project card at the top of the Active tab.
  Widget _featuredCard(Datum project) {
    final title = project.title ?? 'Untitled';
    final company = project.company?.name ?? '';
    final isThis = controller.currentProjectId == (project.id ?? '');
    final running = isThis && controller.isRunning;
    final paused = isThis && controller.isPaused;
    // While tracking, show the running-project card (Stop + Pause + stats).
    if (running || paused) {
      return DsRunningProjectCard(
        title: title,
        company: company,
        today: _todayLabel(project.id),
        thisWeek: _weekLabel(project.id),
        billable: '\$0',
        paused: paused,
        isLoading: controller.isApiLoading,
        onStop: () => controller.stop(),
        onToggle: () => _toggleTracking(project),
        onTap: () => _openProject(project),
      );
    }
    return DsCard(
      onTap: () => _openProject(project),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              DsAvatar(name: title),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.titleSmall),
                    const SizedBox(height: 2),
                    Text(company,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.subtitle),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _toggleTracking(project),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(running ? LucideIcons.pause : LucideIcons.play,
                          size: 16, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(running ? 'Pause' : (paused ? 'Resume' : 'Start'),
                          style: AppTextStyles.bodySemibold
                              .copyWith(color: AppColors.primary)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _stat('today1'.tr, _todayLabel(project.id)),
              _divider(),
              _stat('thisWeek'.tr, _weekLabel(project.id)),
              _divider(),
              _stat('billable'.tr, '\$0'),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              DsChip.primary('chipDefault'.tr),
              DsChip.success('chipRunning'.tr),
              DsChip.warning('overtime'.tr),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.caption),
          const SizedBox(height: 4),
          Text(value, style: AppTextStyles.titleSmall),
        ],
      ),
    );
  }

  Widget _divider() => Container(
        width: 1,
        height: 34,
        margin: const EdgeInsets.symmetric(horizontal: 12),
        color: AppColors.stroke,
      );

  List<Widget> _rowsFor(int selected, List<Datum> visible) {
    // On the Active tab, the first project is the featured card; list the rest.
    final rows = (selected == 0 && visible.isNotEmpty)
        ? visible.sublist(1)
        : visible;
    return rows.map((project) {
      final title = project.title ?? 'Untitled';
      final company = project.company?.name ?? '';
      final isThis = controller.currentProjectId == (project.id ?? '');
      final running = isThis && controller.isRunning;
      return DsProjectTile(
        title: title,
        subtitle: company,
        trailingText: _todayLabel(project.id),
        trailingSub: 'today1'.tr,
        actionIcon:
            running ? Icons.pause_rounded : Icons.play_arrow_rounded,
        onTap: () => _openProject(project), // card → details
        onAction: () => _toggleTracking(project), // icon → start/pause/resume
      );
    }).toList();
  }

  // Icon tap: start tracking this project, or pause/resume if it's the active one.
  Future<void> _toggleTracking(Datum project) async {
    final isThis = controller.currentProjectId == (project.id ?? '');
    if (isThis && controller.isRunning) {
      controller.pause();
    } else if (isThis && controller.isPaused) {
      controller.resume();
    } else {
      await controller.setCurrentProjectId(project.id ?? '',
          projectTitle: project.title);
      await controller.start();
    }
  }

  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.only(top: 48),
      child: Center(
        child: Text(
          'noProjectsHere'.tr,
          style: AppTextStyles.subtitle,
        ),
      ),
    );
  }

  Future<void> _openProject(Datum project) async {
    await controller.setCurrentProjectId(
      project.id ?? '',
      projectTitle: project.title,
    );
    controller.gototheDetailsPage();
  }
}

/// Full-screen project search: autofocused field + live-filtered results.
class ProjectSearchScreen extends StatefulWidget {
  const ProjectSearchScreen({
    super.key,
    required this.projects,
    required this.onOpen,
    required this.formatTime,
  });

  final List<Datum> projects;
  final Future<void> Function(Datum) onOpen;
  final String Function(String? projectId) formatTime;

  @override
  State<ProjectSearchScreen> createState() => _ProjectSearchScreenState();
}

class _ProjectSearchScreenState extends State<ProjectSearchScreen> {
  final TextEditingController _ctrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  List<Datum> get _results {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return widget.projects;
    return widget.projects.where((p) {
      final t = (p.title ?? '').toLowerCase();
      final c = (p.company?.name ?? '').toLowerCase();
      return t.contains(q) || c.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final results = _results;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Search bar row: back + field + clear
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  const DsBackButton(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 46,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(9999),
                        border: Border.all(color: AppColors.stroke),
                      ),
                      child: Row(
                        children: [
                          const Icon(LucideIcons.search,
                              size: 18, color: AppColors.textMuted),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _ctrl,
                              autofocus: true,
                              onChanged: (v) => setState(() => _query = v),
                              textInputAction: TextInputAction.search,
                              style: AppTextStyles.body,
                              decoration: InputDecoration(
                                isDense: true,
                                border: InputBorder.none,
                                hintText: 'searchProjects'.tr,
                                hintStyle: AppTextStyles.body
                                    .copyWith(color: AppColors.textMuted),
                              ),
                            ),
                          ),
                          if (_query.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _ctrl.clear();
                                setState(() => _query = '');
                              },
                              behavior: HitTestBehavior.opaque,
                              child: const Icon(LucideIcons.x,
                                  size: 18, color: AppColors.textMuted),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                // Rebuild when tracked hours arrive after this screen opened.
                Get.find<HomeScreenController>().projectTodayHours.length;
                if (results.isEmpty) return _noResults();
                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  children: [
                    Text(
                        _query.isEmpty
                            ? 'allProjects'.tr
                            : '${results.length} RESULT${results.length == 1 ? '' : 'S'}',
                        style: AppTextStyles.eyebrow),
                    const SizedBox(height: 12),
                    ...results.map((p) => DsProjectTile(
                          title: p.title ?? 'Untitled',
                          subtitle: p.company?.name ?? '',
                          trailingText: widget.formatTime(p.id),
                          trailingSub: 'today1'.tr,
                          onTap: () => widget.onOpen(p),
                        )),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _noResults() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.searchX, size: 36, color: AppColors.textFaint),
          const SizedBox(height: 12),
          Text('noProjectsFound'.tr, style: AppTextStyles.titleSmall),
          const SizedBox(height: 4),
          Text('tryDifferentName'.tr, style: AppTextStyles.subtitle),
        ],
      ),
    );
  }
}
