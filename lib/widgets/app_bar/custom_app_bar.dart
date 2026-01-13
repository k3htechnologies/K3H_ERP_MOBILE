import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
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
import 'package:k3h_erp_app/widgets/app_bar/search_widget.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String screenTitle;
  final AuthorizationModel authorization;
  final String? searchHintText;
  final Widget? widgets;
  final Widget? secondaryWidget;
  final bool? showNotification;
  final Function(String)? onSearchSubmit;
  final TextEditingController? textController;
  final Function? onAddCallback;
  final Function(String)? onExportCallback;
  final List<String>? sortOptionList;
  final String? initialSortType;
  final Future Function(String)? onSortOptionCallback;
  final double extraHeight;
  final Function(ProjectModel)? onProjectChangeCallback;

  const CustomAppBar({
    super.key,
    required this.screenTitle,
    required this.authorization,
    this.searchHintText,
    this.widgets,
    this.secondaryWidget,
    this.showNotification = true,
    this.onSearchSubmit,
    this.textController,
    this.onAddCallback,
    this.onExportCallback,
    this.sortOptionList,
    this.initialSortType,
    this.onSortOptionCallback,
    this.extraHeight = 0,
    this.onProjectChangeCallback,
  });

  static const double _baseHeight = 90;

  @override
  State<CustomAppBar> createState() => _CustomAppBarMobileState();

  @override
  Size get preferredSize => Size.fromHeight(_baseHeight + extraHeight);
}

class _CustomAppBarMobileState extends State<CustomAppBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool isDescending = true;
  String? selectedSortType;
  bool isDarkMode = false;

  // PROJECT SWITCH FUNCTIONALITY
  final ProjectMasterRepository _projectMasterRepository =
      serviceLocator<ProjectMasterRepository>();
  final ValueNotifier<List<ProjectModel>> _projectListNotifier = ValueNotifier(
    [],
  );
  final ValueNotifier<bool> _showOverlayNotifier = ValueNotifier(false);
  ProjectModel? _selectedProject;

  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    selectedSortType = widget.initialSortType;
    _loadProjects();

    // Listen to overlay notifier changes
    _showOverlayNotifier.addListener(_handleOverlayVisibility);
  }

  @override
  void dispose() {
    _animationController.dispose();
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
          _projectListNotifier.value = projects;

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
      subTitle: "Project Selected ${project.projectName}",
    );

    // Call the callback if provided
    if (widget.onProjectChangeCallback != null) {
      widget.onProjectChangeCallback!(project);
    }
  }

  @override
  Widget build(BuildContext context) {
    isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final currentPath = GoRouterState.of(context).uri.toString();

    final rootScreens = [
      AppRoutes.dashboardScreen,
      AppRoutes.menu,
      AppRoutes.profile,
    ];
    final isRootScreen = rootScreens.contains(currentPath);
    final showMenuIcon = isRootScreen;

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor:
          isDarkMode ? AppColor.primary : AppColor.lightGreyBackground,
      surfaceTintColor: Colors.transparent,

      title: Row(
        spacing: 10,
        children: [
          InkWell(
            onTap: () {
              if (showMenuIcon) {
                if (currentPath != AppRoutes.menu) {
                  goRouter.pushNamed(AppRoutes.menu);
                }
              } else {
                if (goRouter.canPop()) {
                  goRouter.pop();
                } else {
                  goRouter.goNamed(AppRoutes.menu);
                }
              }
            },
            child: Icon(
              showMenuIcon ? Icons.menu : Icons.arrow_back,
              color: isDarkMode ? AppColor.white : AppColor.black,
            ),
          ),
          Expanded(
            child: Text(
              widget.screenTitle,
              style: AppTextStyle.ts16R().copyWith(
                color: isDarkMode ? AppColor.white : AppColor.black,
              ),
            ),
          ),
          if (widget.onProjectChangeCallback != null)
            ValueListenableBuilder<List<ProjectModel>>(
              valueListenable: _projectListNotifier,
              builder: (context, projects, _) {
                if (projects.isEmpty) return const SizedBox.shrink();
                return CustomIconButton(
                  onPressed: () {
                    _showOverlayNotifier.value = true;
                  },
                  icon: const Icon(
                    Icons.apartment_rounded,
                    size: 16,
                    color: AppColor.primary,
                  ),
                  backgroundColor: AppColor.lightBlue,
                );
              },
            ),
          if (widget.showNotification!)
            CustomIconButton(
              onPressed: () {
                goRouter.pushNamed(AppRoutes.notificationScreenMobile);
              },
              icon: SvgPicture.asset(AppAssets.notificationIcon, height: 16),
              backgroundColor: AppColor.lightBlue,
            ),
        ],
      ),

      bottom: PreferredSize(
        preferredSize: Size.fromHeight(
          widget.extraHeight == 0 ? 54 : widget.extraHeight + 54,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Column(
            spacing: 6,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.widgets != null && widget.extraHeight > 0)
                widget.widgets!,

              Row(
                spacing: 10,
                children: [
                  if (widget.onSearchSubmit != null)
                    Expanded(
                      child: SearchWidget(
                        onSubmit: widget.onSearchSubmit!,
                        hintText: widget.searchHintText!,
                        textController: widget.textController!,
                      ),
                    ),

                  if (widget.secondaryWidget == null)
                    Row(
                      spacing: 10,
                      children: [
                        if (widget.authorization.isAction &&
                            widget.onAddCallback != null)
                          CustomIconButton(
                            onPressed: () => widget.onAddCallback!(),
                            icon: Icon(
                              Icons.add,
                              size: 16,
                              color: AppColor.darkGreen,
                            ),
                            backgroundColor: AppColor.lightGreen,
                          ),

                        if (widget.authorization.isAction &&
                            widget.onExportCallback != null)
                          CustomIconButton(
                            onPressed: () {
                              final box =
                                  context.findRenderObject() as RenderBox;
                              final position = box.localToGlobal(Offset.zero);
                              CustomOverlayMenu.show(
                                width: 180,
                                context: context,
                                position: Offset(
                                  position.dx + 10,
                                  position.dy + (145 + widget.extraHeight),
                                ),
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
                            icon: Icon(
                              Icons.file_download,
                              size: 16,
                              color: AppColor.primary,
                            ),
                            backgroundColor: AppColor.lightBlue,
                          ),
                        //FOR NEW WIDGET WHICH IS NEXT TO SEARCH BAR
                      ],
                    ),
                  if (widget.secondaryWidget != null) widget.secondaryWidget!,
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomOverlayMenu {
  static OverlayEntry? _entry;

  static void show({
    required BuildContext context,
    required Offset position,
    required List<AddImportExportOverlayMenuItem> items,
    double width = 160,
  }) {
    final overlay = Overlay.of(context);

    _entry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () => close(),
                behavior: HitTestBehavior.translucent,
              ),
            ),
            Positioned(
              top: position.dy,
              right: position.dx,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: width,
                  decoration: BoxDecoration(
                    color: AppColor.white,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: AppColor.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (int i = 0; i < items.length; i++) ...[
                        _buildItem(
                          icon: items[i].icon,
                          iconColor: items[i].iconColor,
                          label: items[i].label,
                          value: items[i].value,
                          onTap: items[i].onTap,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    overlay.insert(_entry!);
  }

  static void close() {
    if (_entry != null && _entry!.mounted) {
      _entry!.remove();
      _entry = null;
    }
  }

  static Widget _buildItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required void Function(String) onTap,
  }) {
    return InkWell(
      onTap: () {
        close();
        onTap(value);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            Icon(icon, color: iconColor),
            Text(label, style: AppTextStyle.ts14R(color: iconColor)),
          ],
        ),
      ),
    );
  }
}

class SortOverlayMenu {
  static OverlayEntry? _entry;

  static void show({
    required BuildContext context,
    required Offset position,
    required List<SortOverlayMenuItem> items,
    double width = 120,
  }) {
    final overlay = Overlay.of(context);

    _entry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () => close(),
                behavior: HitTestBehavior.translucent,
              ),
            ),
            Positioned(
              top: position.dy,
              left: position.dx,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: width,
                  decoration: BoxDecoration(
                    color: AppColor.white,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: AppColor.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children:
                        items
                            .map(
                              (item) => InkWell(
                                onTap: () {
                                  close();
                                  item.onTap(item.value);
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  child: Text(
                                    item.label,
                                    style: AppTextStyle.ts14R(),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    overlay.insert(_entry!);
  }

  static void close() {
    if (_entry != null && _entry!.mounted) {
      _entry!.remove();
      _entry = null;
    }
  }
}

class AddImportExportOverlayMenuItem {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final void Function(String) onTap;

  AddImportExportOverlayMenuItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.onTap,
  });
}

class SortOverlayMenuItem {
  final String label;
  final String value;
  final void Function(String) onTap;

  SortOverlayMenuItem({
    required this.label,
    required this.value,
    required this.onTap,
  });
}
