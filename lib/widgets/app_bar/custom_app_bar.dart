import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/storage_key.dart';
import 'package:k3h_erp_app/widgets/app_bar/search_widget.dart';
import 'package:k3h_erp_app/core/presentation/pages/main_screen.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String screenTitle;
  final AuthorizationModel authorization;
  final String? searchHintText;
  final Widget? widgets;
  final WidgetBuilder? secondaryBuilder;
  final bool? showNotification;
  final Function(String)? onSearchSubmit;
  final TextEditingController? textController;
  final VoidCallback? onAddCallback;
  final Function(String)? onExportCallback;
  final List<String>? sortOptionList;
  final String? initialSortType;
  final Future Function(String)? onSortOptionCallback;
  final double extraHeight;
  final Function(ProjectModel)? onProjectChangeCallback;
  final bool isFilterOn;
  final VoidCallback? onFilterTap;

  final String? importTableName;
  final int? projectId;
  final int? buildingId;
  final String? exportMonthYear;
  final Function(String)? onImportResult;

  const CustomAppBar({
    super.key,
    required this.screenTitle,
    required this.authorization,
    this.searchHintText,
    this.widgets,
    this.secondaryBuilder,
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
    this.isFilterOn = false,
    this.onFilterTap,

    this.importTableName,
    this.projectId,
    this.buildingId,
    this.exportMonthYear,
    this.onImportResult,
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
            bottom: false,
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
        return;
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
    //CLEAR SEARCH CONTROLLER
    if (widget.textController != null) {
      widget.textController!.clear();
    }
    // Call the callback if provided
    if (widget.onProjectChangeCallback != null) {
      widget.onProjectChangeCallback!(project);
    }
  }

  final LayerLink _exportLayerLink = LayerLink();
  OverlayEntry? _exportOverlayEntry;
  final GlobalKey _exportButtonKey = GlobalKey();

  void _toggleExportOverlay() {
    if (_exportOverlayEntry != null) {
      _removeExportOverlay();
    } else {
      _showExportOverlay();
    }
  }

  void _showExportOverlay() {
    const double dropdownWidth = 180;

    final RenderBox buttonBox =
        _exportButtonKey.currentContext!.findRenderObject() as RenderBox;

    final Offset buttonPosition = buttonBox.localToGlobal(Offset.zero);
    final double screenWidth = MediaQuery.of(context).size.width;

    double shiftX = 0;

    // check overflow on right
    final overflowRight = buttonPosition.dx + dropdownWidth - screenWidth;

    if (overflowRight > 0) {
      shiftX = -overflowRight - 8;
    }

    _exportOverlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: _removeExportOverlay,
                behavior: HitTestBehavior.translucent,
              ),
            ),

            CompositedTransformFollower(
              link: _exportLayerLink,
              showWhenUnlinked: false,
              offset: Offset(shiftX, 40),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: dropdownWidth,
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
                      _buildExportItem(
                        label: 'Export as Excel',
                        value: 'EXCEL',
                      ),
                      _buildExportItem(label: 'Export as PDF', value: 'PDF'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context, rootOverlay: true).insert(_exportOverlayEntry!);
  }

  void _removeExportOverlay() {
    _exportOverlayEntry?.remove();
    _exportOverlayEntry = null;
  }

  Widget _buildExportItem({required String label, required String value}) {
    return InkWell(
      onTap: () {
        _removeExportOverlay();
        widget.onExportCallback?.call(value);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(Icons.file_download_outlined, color: AppColor.primary),
            const SizedBox(width: 8),
            Text(label, style: AppTextStyle.ts14R()),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor:
          isDarkMode ? AppColor.primary : AppColor.lightGreyBackground,
      surfaceTintColor: Colors.transparent,

      title: Row(
        spacing: 10,
        children: [
          GestureDetector(
            onTap: () {
              mobileScreenGlobalScaffoldKey.currentState?.openDrawer();
            },
            child: Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: AppColor.lightBlue,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                Icons.menu,
                color: isDarkMode ? AppColor.white : AppColor.primary,
                size: 16,
              ),
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
            GestureDetector(
              onTap: () {
                _showOverlayNotifier.value = true;
              },
              child: SvgPicture.asset(AppAssets.projectIcon, height: 28),
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
                children: [
                  if (widget.onSearchSubmit != null)
                    Expanded(
                      child: SearchWidget(
                        onSubmit: widget.onSearchSubmit!,
                        hintText: widget.searchHintText ?? "Search...",
                        textController: widget.textController!,
                        isFilterOn: widget.isFilterOn,
                        onFilterTap: widget.onFilterTap,
                      ),
                    ),
                  Row(
                    children: [
                      if (widget.authorization.isAction &&
                          widget.secondaryBuilder != null) ...[
                        horizontalSpacing(),
                        widget.secondaryBuilder!(context),
                      ],

                      if (widget.authorization.isExport &&
                          widget.onExportCallback != null) ...[
                        horizontalSpacing(),
                        CompositedTransformTarget(
                          link: _exportLayerLink,
                          child: CustomIconButton(
                            key: _exportButtonKey,
                            onPressed: _toggleExportOverlay,
                            icon: Icon(
                              Icons.file_download_outlined,
                              size: 16,
                              color: AppColor.darkGreen,
                            ),
                            backgroundColor: AppColor.lightGreen,
                          ),
                        ),
                      ],

                      if (widget.authorization.isAction &&
                          widget.onAddCallback != null) ...[
                        horizontalSpacing(),
                        CustomIconButton(
                          onPressed: () {
                            if (widget.textController != null) {
                              widget.textController!.clear();
                            }
                            widget.onAddCallback!();
                          },
                          icon: const Icon(
                            Icons.add,
                            size: 16,
                            color: AppColor.primary,
                          ),
                          backgroundColor: AppColor.lightBlue,
                        ),
                      ],
                      if (widget.authorization.isExport &&
                          widget.importTableName != null) ...[
                        horizontalSpacing(),
                        importButton(
                          context,
                          widget.importTableName!,
                          widget.onImportResult ?? (value) {},
                          projectId: widget.projectId,
                          buildingId: widget.buildingId,
                          monthYear: widget.exportMonthYear,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget importButton(
    BuildContext context,
    String importTableName,
    Function(String) onImportCallback, {
    int? projectId,
    int? buildingId,
    String? monthYear,
  }) {
    Future<bool> importFile() async {
      final Map<String, dynamic>? dialogResult =
          await DialogHelper.showDeleteAllConfirmationDialog(context: context);

      if (dialogResult == null || !context.mounted) {
        return false;
      }

      final bool deleteAll = dialogResult["deleteAll"];
      final Uint8List fileBytes = dialogResult["fileBytes"];
      final String fileName = dialogResult["fileName"];

      var result = await importExcel(
        context,
        {
          "TableName": importTableName,
          "IsAllDelete": deleteAll ? "1" : "0",
          "ProjectId": projectId?.toString() ?? "0",
          "BuildingId": buildingId?.toString() ?? "0",
          "MonthYear": monthYear ?? "",
        },
        [
          {"key": "ExcelFile", "value": fileBytes, "fileName": fileName},
        ],
      );

      return result;
    }

    return CustomIconButton(
      onPressed: () async {
        if (projectId == 0) {
          showErrorMessage(context, "", "Please select a project");
          return;
        }
        if ((monthYear ?? "").isEmpty) {
          showErrorMessage(context, "", "Please select a month");
          return;
        }

        final result = await DialogHelper.showUploadExcelDialog(context);
        if (result != null) {
          if (result == true) {
            var resultValue = await importFile();

            if (context.mounted) {
              onImportCallback(resultValue ? "success" : "failed");
            }
          } else if (result == false) {
            if (context.mounted) {
              if (importTableName == "SALES TARGET SOURCING") {
                widget.onImportResult!("download");
              } else if (importTableName == "SALES TARGET CLOSING") {
                widget.onImportResult!("download");
              } else {
                sampleExcelImport(context, importTableName);
              }
            }
          }
        }
      },
      icon: Icon(
        Icons.file_upload_outlined,
        size: 16.0,
        color: AppColor.primary,
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
