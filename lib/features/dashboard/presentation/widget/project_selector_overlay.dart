import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/local_storage_manager.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/models/user.model.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/masters/project_master/data/repository/project_master.repository.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/storage_key.dart';
import 'package:k3h_erp_app/widgets/app_bar/search_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class ProjectSelectorOverlay extends StatefulWidget {
  final int? selectedProjectId;
  final ValueChanged<ProjectModel> onSelect;
  final VoidCallback onClose;

  const ProjectSelectorOverlay({
    super.key,
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
  late TextEditingController _searchC;

  ProjectModel? selectedProject;
  List<ProjectModel> projects = [];
  List<ProjectModel> allProjects = [];

  bool isLoadingProject = false;

  final ProjectMasterRepository _projectMasterRepository =
      serviceLocator<ProjectMasterRepository>();

  //  GET EMPLOYEE ID FROM LOCAL STORAGE
  int? _getEmployeeId() {
    final storedUser = LocalStorageManager().getString(StorageKey.currentUser);

    if (storedUser == null) return null;

    final decoded = jsonDecode(storedUser);
    final user = UserModel.fromJson(decoded);

    return user.employeeId;
  }

  //  FETCH PROJECT LIST FROM API
  Future<void> _fetchProjects() async {
    final employeeId = _getEmployeeId();

    if (employeeId == null) return;

    setState(() {
      isLoadingProject = true;
    });

    try {
      final result = await _projectMasterRepository.getProjectList(
        pageNumber: 1,
        pageSize: 100,
        queryParams: {
          "EmployeeId": employeeId,
          "ProjectName": _searchC.text.trim(),
        },
      );

      result.fold(
        (failure) {
          setState(() {
            isLoadingProject = false;
          });

          showErrorMessage(context, "", failure.message);
        },
        (response) {
          final fetchedProjects = List<ProjectModel>.from(response["data"]);

          setState(() {
            if (_searchC.text.isEmpty) {
              allProjects = fetchedProjects;
            }

            projects = fetchedProjects;

            selectedProject =
                fetchedProjects.any(
                      (p) => p.projectId == widget.selectedProjectId,
                    )
                    ? fetchedProjects.firstWhere(
                      (p) => p.projectId == widget.selectedProjectId,
                    )
                    : (_searchC.text.isNotEmpty &&
                        widget.selectedProjectId != null &&
                        widget.selectedProjectId != 0)
                    ? allProjects.firstWhere(
                      (p) => p.projectId == widget.selectedProjectId,
                    )
                    : null;

            isLoadingProject = false;
          });
        },
      );
    } catch (e) {
      setState(() {
        isLoadingProject = false;
      });
      if (mounted) {
        showErrorMessage(context, "", "Something went wrong");
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _searchC = TextEditingController();
    _fetchProjects();

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
    _searchC.dispose();
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
                    // HEADER
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (selectedProject == null)
                            Text(
                              "Select Project",
                              style: AppTextStyle.ts14M(color: AppColor.grey),
                            ),
                          if (selectedProject != null) ...[
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
                        ],
                      ),
                    ),

                    Divider(height: 1, color: AppColor.grey),
                    Container(
                      margin: EdgeInsets.only(top: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: SearchWidget(
                        hintText: "Search by Project Name",
                        onSubmit: (val) {
                          _fetchProjects();
                        },
                        textController: _searchC,
                      ),
                    ),
                    // BODY
                    Expanded(
                      child: Builder(
                        builder: (context) {
                          if (isLoadingProject) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          final filteredProjects =
                              projects
                                  .where(
                                    (p) =>
                                        p.projectId !=
                                        selectedProject?.projectId,
                                  )
                                  .toList();

                          if (filteredProjects.isEmpty) {
                            return Center(
                              child: noDataWidget(
                                iconSize: 0.4.sw,
                                message: 'No results found',
                              ),
                            );
                          }

                          return ListView.separated(
                            itemCount: filteredProjects.length,
                            separatorBuilder:
                                (_, __) => Divider(
                                  height: .5,
                                  color: AppColor.lightGrey,
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
