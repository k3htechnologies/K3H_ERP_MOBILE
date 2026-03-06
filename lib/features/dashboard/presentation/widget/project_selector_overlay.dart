import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/masters/project_master/data/repository/project_master.repository.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class ProjectSelectorOverlay extends StatefulWidget {
  final List<ProjectModel> projects;
  final int? selectedProjectId;
  final ValueChanged<ProjectModel> onSelect;
  final VoidCallback onClose;

  const ProjectSelectorOverlay({
    super.key,
    required this.projects,
    required this.selectedProjectId,
    required this.onSelect,
    required this.onClose,
  });

  @override
  State<ProjectSelectorOverlay> createState() => _ProjectSelectorOverlayState();
}

class _ProjectSelectorOverlayState extends State<ProjectSelectorOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  ProjectModel? selectedProject;
  bool isLoadingProject = false;

  // REPOSITORY
  final ProjectMasterRepository _projectMasterRepository =
      serviceLocator<ProjectMasterRepository>();

  // FETCH PROJECT BY ID
  Future<void> _fetchProjectById(int projectId) async {
    setState(() {
      isLoadingProject = true;
    });

    final result = await _projectMasterRepository.getProjectList(
      pageNumber: 1,
      pageSize: 1,
      queryParams: {"ProjectId": projectId},
    );

    result.fold(
      (failure) {
        setState(() {
          isLoadingProject = false;
        });
      },
      (response) {
        if (response["data"].isNotEmpty) {
          setState(() {
            selectedProject = response["data"].first;
            isLoadingProject = false;
          });
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    try {
      selectedProject = widget.projects.firstWhere(
        (p) => p.projectId == widget.selectedProjectId,
      );
    } catch (_) {
      selectedProject =
          widget.projects.isNotEmpty ? widget.projects.first : null;
    }

    if (widget.selectedProjectId != null) {
      _fetchProjectById(widget.selectedProjectId!);
    }
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _close() async {
    if (mounted) {
      await _controller.reverse();
      widget.onClose();
    }
  }

  void _navigateToProjectDetails(ProjectModel project) {
    widget.onClose();

    Future.delayed(const Duration(milliseconds: 150), () {
      final encryptedProject = Uri.encodeQueryComponent(
        EncryptionManager.encryptData(jsonEncode(project.toJson())),
      );

      goRouter.pushNamed(
        AppRoutes.projectOverview,
        queryParameters: {'project': encryptedProject},
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _close,
      child: Material(
        color: Colors.black54,
        child: SlideTransition(
          position: _slideAnimation,
          child: Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {},
              child: Container(
                width: MediaQuery.of(context).size.width * 0.67,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (selectedProject != null)
                            GestureDetector(
                              onTap:
                                  () => _navigateToProjectDetails(
                                    selectedProject!,
                                  ),
                              child: Icon(
                                Icons.info_outline,
                                color: AppColor.primary,
                                size: 20,
                              ),
                            ),
                          horizontalSpacing(),
                          Expanded(
                            child: Text(
                              selectedProject?.projectName ?? '',
                              style: AppTextStyle.ts16SB(),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFe5e7eb)),
                    Expanded(
                      child: Builder(
                        builder: (context) {
                          final filteredProjects =
                              widget.projects
                                  .where(
                                    (p) =>
                                        p.projectId != widget.selectedProjectId,
                                  )
                                  .toList();

                          if (filteredProjects.isEmpty) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text(
                                  'No other projects available',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF6b7280),
                                  ),
                                ),
                              ),
                            );
                          }

                          return ListView.separated(
                            itemCount: filteredProjects.length,
                            separatorBuilder:
                                (_, __) => const Divider(
                                  height: 1,
                                  color: Color(0xFFe5e7eb),
                                ),
                            itemBuilder: (context, index) {
                              final project = filteredProjects[index];
                              return GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () async {
                                    await _controller.reverse();
                                    widget.onSelect(project);
                                    widget.onClose();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          project.projectName,
                                          style: AppTextStyle.ts16M(),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
