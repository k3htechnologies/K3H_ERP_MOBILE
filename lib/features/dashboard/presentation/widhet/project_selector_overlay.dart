import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';

/// Slide-in overlay from right to left to pick a project.
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

  @override
  void initState() {
    super.initState();
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

  void _close() {
    _controller.reverse().then((_) {
      widget.onClose();
    });
  }

  void _navigateToProjectDetails(ProjectModel project) {
    final encryptedProject = Uri.encodeQueryComponent(
      EncryptionManager.encryptData(jsonEncode(project.toJson())),
    );
    goRouter.pushNamed(
      AppRoutes.projectDetails,
      queryParameters: {'project': encryptedProject},
    );
  }

  @override
  Widget build(BuildContext context) {
    ProjectModel? selectedProject;
    try {
      selectedProject = widget.projects.firstWhere(
        (p) => p.projectId == widget.selectedProjectId,
      );
    } catch (_) {
      selectedProject =
          widget.projects.isNotEmpty ? widget.projects.first : null;
    }

    return GestureDetector(
      onTap: _close,
      child: Material(
        color: Colors.black54,
        child: SlideTransition(
          position: _slideAnimation,
          child: Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {}, // Prevent tap from closing when tapping inside
              child: Container(
                width: MediaQuery.of(context).size.width * 0.67,
                height: double.infinity,
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
                        children: [
                          _selectionDot(true),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              selectedProject?.projectName ?? '',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2b2b2b),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (selectedProject != null)
                            GestureDetector(
                              onTap:
                                  () => _navigateToProjectDetails(
                                    selectedProject!,
                                  ),
                              child: Icon(
                                Icons.info_outline,
                                color: AppColor.primary,
                                size: 18,
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
                              return InkWell(
                                onTap: () {
                                  widget.onSelect(project);
                                  _close();
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
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF1f2937),
                                          ),
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

  Widget _selectionDot(bool isSelected) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? const Color(0xFFd6d6d6) : Colors.transparent,
        border: Border.all(
          color: isSelected ? Colors.transparent : const Color(0xFFd6d6d6),
          width: 1.2,
        ),
      ),
    );
  }
}
