import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:k3h_erp_app/core/local_storage_manager.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/models/user.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/dashboard/presentation/widget/project_selector_overlay.dart';
import 'package:k3h_erp_app/features/masters/project_master/data/repository/project_master.repository.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/storage_key.dart';
import 'package:k3h_erp_app/core/presentation/pages/main_screen.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_export_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class CustomAppBarWithBackButton extends StatefulWidget
    implements PreferredSizeWidget {
  final String screenTitle;
  final AuthorizationModel authorization;
  final bool showNotification;
  final bool isMenuButton;
  final Function? onAddCallback;
  final Function(String)? onExportCallback;
  final Function(ProjectModel)? onProjectChangeCallback;
  final VoidCallback? onFilterTap;
  final Widget? secondaryWidget;
  final ValueNotifier<int>? filterCountNotifier;

  const CustomAppBarWithBackButton({
    super.key,
    required this.screenTitle,
    required this.authorization,
    this.showNotification = true,
    this.isMenuButton = false,
    this.onAddCallback,
    this.onExportCallback,
    this.onProjectChangeCallback,
    this.onFilterTap,
    this.secondaryWidget,
    this.filterCountNotifier,
  });

  @override
  State<CustomAppBarWithBackButton> createState() =>
      _CustomAppBarWithBackButtonState();

  @override
  Size get preferredSize => Size.fromHeight(50);
}

class _CustomAppBarWithBackButtonState
    extends State<CustomAppBarWithBackButton> {
  // PROJECT SWITCH FUNCTIONALITY
  final ProjectMasterRepository _projectMasterRepository =
      serviceLocator<ProjectMasterRepository>();
  final ValueNotifier<bool> _showOverlayNotifier = ValueNotifier(false);
  ProjectModel? _selectedProject;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _loadProjects();
    _showOverlayNotifier.addListener(_handleOverlayVisibility);
  }

  @override
  void dispose() {
    _showOverlayNotifier.removeListener(_handleOverlayVisibility);
    _showOverlayNotifier.dispose();
    _closeOverlay();
    super.dispose();
  }

  void _handleOverlayVisibility() {
    if (_showOverlayNotifier.value) {
      _showOverlay();
    } else {
      _closeOverlay();
    }
  }

  void _showOverlay() {
    if (_overlayEntry != null || !mounted) return;

    _overlayEntry = OverlayEntry(
      builder:
          (context) => SafeArea(
            child: Material(
              color: Colors.transparent,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ProjectSelectorOverlay(
                      selectedProjectId: _selectedProject?.projectId,
                      onSelect: _onProjectSelected,
                      onClose: () {
                        _showOverlayNotifier.value = false;
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _closeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Future<void> _loadProjects() async {
    try {
      // First check if project list exists in storage
      final projectListString = LocalStorageManager().getString(
        StorageKey.projectList,
      );

      if (projectListString != null && projectListString.isNotEmpty) {
        // Load from storage
        final List<dynamic> projectJsonList = jsonDecode(projectListString);
        final List<ProjectModel> projects =
            projectJsonList
                .map(
                  (json) => ProjectModel.fromJson(json as Map<String, dynamic>),
                )
                .toList();

        // Load selected project
        final storedJson = LocalStorageManager().getString(
          StorageKey.selectedProject,
        );
        if (storedJson != null && storedJson.isNotEmpty) {
          final storedProject = ProjectModel.fromJson(jsonDecode(storedJson));
          if (projects.any((p) => p.projectId == storedProject.projectId)) {
            _selectedProject = storedProject;
          }
        }
        return; // Exit early if loaded from storage
      }

      // Only make API call if not in storage
      final userJson = LocalStorageManager().getString(StorageKey.currentUser);
      if (userJson == null || userJson.isEmpty) return;

      final user = UserModel.fromJson(jsonDecode(userJson));
      final result = await _projectMasterRepository.getProjectList(
        pageNumber: 1,
        pageSize: 100,
        queryParams: {'EmployeeId': user.employeeId.toString()},
      );

      result.fold(
        (failure) {
          // Handle failure silently
        },
        (response) {
          final List<ProjectModel> projects =
              (response['data'] as List<ProjectModel>);

          // Store in localStorage for future use
          LocalStorageManager().setString(
            StorageKey.projectList,
            jsonEncode(projects.map((p) => p.toJson()).toList()),
          );

          // Load selected project
          final storedJson = LocalStorageManager().getString(
            StorageKey.selectedProject,
          );
          if (storedJson != null && storedJson.isNotEmpty) {
            final storedProject = ProjectModel.fromJson(jsonDecode(storedJson));
            if (projects.any((p) => p.projectId == storedProject.projectId)) {
              _selectedProject = storedProject;
            }
          }
        },
      );
    } catch (e) {
      // Handle error silently
    }
  }

  void _onProjectSelected(ProjectModel project) {
    _selectedProject = project;
    LocalStorageManager().setString(
      StorageKey.selectedProject,
      jsonEncode(project.toJson()),
    );
    showSuccessMessage(
      context,
      subTitle: "Project Selected : ${project.projectName}",
    );

    // Call the callback if provided
    if (widget.onProjectChangeCallback != null) {
      widget.onProjectChangeCallback!(project);
    }
  }

  Widget _buildAction({
    required IconData icon,
    required VoidCallback onTap,
    required Color backgroundColor,
    required Color iconColor,
  }) {
    return CustomIconButton(
      icon: Icon(icon, size: 16, color: iconColor),
      onPressed: onTap,
      backgroundColor: backgroundColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        height: widget.preferredSize.height,
        color: AppColor.lightGreyBackground,
        // padding: const EdgeInsets.symmetric(horizontal: 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // LEADING BUTTON
            GestureDetector(
              onTap: () {
                if (widget.isMenuButton) {
                  mobileScreenGlobalScaffoldKey.currentState?.openDrawer();
                } else {
                  if (goRouter.canPop()) {
                    FocusManager.instance.primaryFocus?.unfocus();
                    goRouter.pop();
                  }
                }
              },
              child:
                  widget.isMenuButton
                      ? Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.fromLTRB(7, 6, 6, 6),
                        margin: EdgeInsets.fromLTRB(16, 12, 10, 12),
                        decoration: BoxDecoration(
                          color: AppColor.lightBlue,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Icon(
                          Icons.menu,
                          size: 14,
                          color: AppColor.primary,
                        ),
                      )
                      : Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.fromLTRB(7, 6, 6, 6),
                        margin: EdgeInsets.fromLTRB(16, 12, 10, 12),
                        decoration: BoxDecoration(
                          color: AppColor.primary.withValues(alpha: .2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 3.0),
                          child: Icon(
                            Icons.arrow_back_ios,
                            size: 14,
                            color: AppColor.black,
                          ),
                        ),
                      ),
            ),

            // TITLE
            Expanded(
              child: Text(
                widget.screenTitle,
                style: AppTextStyle.ts16SB(color: AppColor.black),
              ),
            ),
            if (widget.secondaryWidget != null) widget.secondaryWidget!,
            // ACTIONS
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.onProjectChangeCallback != null) ...[
                  horizontalSpacing(),
                  GestureDetector(
                    onTap: () {
                      _showOverlayNotifier.value = true;
                    },
                    child: SvgPicture.asset(AppAssets.projectIcon, height: 28),
                  ),
                ],

                if (widget.onFilterTap != null) ...[
                  horizontalSpacing(),
                  GestureDetector(
                    onTap: widget.onFilterTap,
                    child: ValueListenableBuilder<int>(
                      valueListenable:
                          widget.filterCountNotifier ?? ValueNotifier<int>(0),
                      builder: (context, filterCount, child) {
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColor.lightBlue,
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: SvgPicture.asset(
                                AppAssets.filterIcon,
                                colorFilter: const ColorFilter.mode(
                                  AppColor.primary,
                                  BlendMode.srcIn,
                                ),
                                width: 14,
                                height: 14,
                              ),
                            ),

                            if (filterCount > 0)
                              Positioned(
                                top: -6,
                                right: -6,
                                child: Container(
                                  constraints: const BoxConstraints(
                                    minWidth: 16,
                                    minHeight: 16,
                                  ),
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    filterCount > 99 ? '99+' : '$filterCount',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ],

                if (widget.onExportCallback != null &&
                    widget.authorization.isExport) ...[
                  horizontalSpacing(),
                  CustomExportButton(onExport: widget.onExportCallback!),
                ],
                if (widget.onAddCallback != null &&
                    widget.authorization.isAction) ...[
                  horizontalSpacing(),
                  _buildAction(
                    icon: Icons.add,
                    onTap: () {
                      widget.onAddCallback!();
                    },
                    backgroundColor: AppColor.lightBlue,
                    iconColor: AppColor.primary,
                  ),
                ],

                if (widget.showNotification) ...[
                  horizontalSpacing(),

                  CustomIconButton(
                    onPressed: () {
                      goRouter.pushNamed(AppRoutes.notificationScreenMobile);
                    },
                    icon: SvgPicture.asset(
                      AppAssets.notificationIcon,
                      height: 16,
                    ),
                    backgroundColor: AppColor.lightBlue,
                  ),
                ],

                horizontalSpacing(width: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
