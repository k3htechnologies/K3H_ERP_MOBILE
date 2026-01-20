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
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/storage_key.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class CustomAppBarWithBackButton extends StatefulWidget
    implements PreferredSizeWidget {
  final String screenTitle;
  final AuthorizationModel authorization;
  final bool showNotification;
  final Function? onAddCallback;
  final Function(String)? onExportCallback;
  final Function(ProjectModel)? onProjectChangeCallback;

  const CustomAppBarWithBackButton({
    super.key,
    required this.screenTitle,
    required this.authorization,
    this.showNotification = true,
    this.onAddCallback,
    this.onExportCallback,
    this.onProjectChangeCallback,
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
  final ValueNotifier<List<ProjectModel>> _projectListNotifier =
      ValueNotifier([]);
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
      builder: (context) => SafeArea(
        child: Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              Positioned.fill(
                child: ProjectSelectorOverlay(
                  projects: _projectListNotifier.value,
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
      final projectListString = LocalStorageManager().getString(StorageKey.projectList);
      
      if (projectListString != null && projectListString.isNotEmpty) {
        // Load from storage
        final List<dynamic> projectJsonList = jsonDecode(projectListString);
        final List<ProjectModel> projects = projectJsonList
            .map((json) => ProjectModel.fromJson(json as Map<String, dynamic>))
            .toList();
        _projectListNotifier.value = projects;

        // Load selected project
        final storedJson = LocalStorageManager().getString(StorageKey.selectedProject);
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
        queryParams: {
          'EmployeeId': user.employeeId.toString(),
        },
      );

      result.fold(
        (failure) {
          // Handle failure silently
        },
        (response) {
          final List<ProjectModel> projects =
              (response['data'] as List<ProjectModel>);
          _projectListNotifier.value = projects;

          // Store in localStorage for future use
          LocalStorageManager().setString(
            StorageKey.projectList,
            jsonEncode(projects.map((p) => p.toJson()).toList()),
          );

          // Load selected project
          final storedJson =
              LocalStorageManager().getString(StorageKey.selectedProject);
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
    showSuccessMessage(context, subTitle: "Project Selected ${project.projectName}");
    
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
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: CustomIconButton(
        icon: Icon(icon, size: 16, color: iconColor),
        onPressed: onTap,
        backgroundColor: backgroundColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: widget.preferredSize.height,
      backgroundColor: AppColor.lightGreyBackground,
      centerTitle: false,
      leading: GestureDetector(
        onTap: () {
          if (goRouter.canPop()) {
            goRouter.pop();
          }
        },
        child: Icon(Icons.arrow_back),
      ),
      title: Text(
        widget.screenTitle,
        style: AppTextStyle.ts16SB(color: AppColor.black),
      ),
      actions: [
        if(widget.onProjectChangeCallback!=null)
        ValueListenableBuilder<List<ProjectModel>>(
          valueListenable: _projectListNotifier,
          builder: (context, projects, _) {
            if (projects.isEmpty) return const SizedBox.shrink();
            return CustomIconButton(
              onPressed: () {
                _showOverlayNotifier.value = true;
              },
              icon: const Icon(
                Icons.apartment_outlined,
                size: 16,
                color: AppColor.primary,
              ),
              backgroundColor: AppColor.lightBlue,
            );
          },
        ),
        if (widget.authorization.isAction) ...[
          if (widget.onAddCallback != null)
            ...[
              horizontalSpacing(),
              _buildAction(
                icon: Icons.add,
                onTap: () {
                  widget.onAddCallback!();
                },
                backgroundColor: AppColor.lightGreen,
                iconColor: AppColor.darkGreen,
              ),
            ],
          if (widget.onExportCallback != null)
           ...[
             horizontalSpacing(),
             _buildAction(
               icon: Icons.file_download,
               onTap: () {
                 final box = context.findRenderObject() as RenderBox;
                 final position = box.localToGlobal(Offset.zero);
                 CustomOverlayMenu.show(
                   width: 180,
                   context: context,
                   position: Offset(position.dx + 10, position.dy + (115)),
                   items: [
                     AddImportExportOverlayMenuItem(
                       icon: Icons.file_download_outlined,
                       label: 'Export Excel',
                       value: 'EXCEL',
                       onTap: widget.onExportCallback!,
                       iconColor: AppColor.primary,
                     ),
                     AddImportExportOverlayMenuItem(
                       icon: Icons.file_download_outlined,
                       label: 'Export PDF',
                       value: 'PDF',
                       onTap: widget.onExportCallback!,
                       iconColor: AppColor.primary,
                     ),
                   ],
                 );
               },
               backgroundColor: AppColor.lightBlue,
               iconColor: AppColor.primary,
             ),
           ]
        ],
        if (widget.showNotification)
          ...[
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
        horizontalSpacing(width: 16)
      ],
    );
  }
}
