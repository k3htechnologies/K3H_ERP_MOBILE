import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:k3h_erp_app/core/local_storage_manager.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/models/user.model.dart';
import 'package:k3h_erp_app/core/presentation/pages/main_screen.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/dashboard/presentation/widget/project_selector_overlay.dart';
import 'package:k3h_erp_app/features/masters/project_master/data/repository/project_master.repository.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/storage_key.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/network_image_widget.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class InventoryDashboard extends StatefulWidget {
  const InventoryDashboard({super.key});

  @override
  State<InventoryDashboard> createState() => _InventoryDashboardState();
}

class _InventoryDashboardState extends State<InventoryDashboard> {
  // PROJECT MASTER REPOSITORY
  final ProjectMasterRepository _projectMasterRepository =
      serviceLocator<ProjectMasterRepository>();

  final ValueNotifier<List<ProjectModel>> _projectListNotifier = ValueNotifier(
    [],
  );

  final ValueNotifier<bool> _showOverlayNotifier = ValueNotifier(false);

  ProjectModel? _selectedProject;
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
  }

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    await _fetchProjects(1);
    final projects = _projectListNotifier.value;
    ProjectModel? storedProject;
    final storedJson = LocalStorageManager().getString(
      StorageKey.selectedProject,
    );
    if (storedJson != null && storedJson.isNotEmpty) {
      storedProject = ProjectModel.fromJson(jsonDecode(storedJson));
    }
    if (storedProject != null &&
        projects.any((p) => p.projectId == storedProject!.projectId)) {
      _selectedProject = storedProject;
    } else if (projects.isNotEmpty) {
      _selectedProject = projects.first;
      LocalStorageManager().setString(
        StorageKey.selectedProject,
        jsonEncode(_selectedProject!.toJson()),
      );
    }
  }

  // FETCH PROJECTS
  Future<Map<String, dynamic>> _fetchProjects(
    int pageNumber, {
    String? value,
  }) async {
    final userJson = jsonDecode(
      LocalStorageManager().getString(StorageKey.currentUser) ?? '',
    );
    final user = UserModel.fromJson(userJson);

    final result = await _projectMasterRepository.getProjectList(
      pageNumber: pageNumber,
      pageSize: 100,
      queryParams: {
        'EmployeeId': user.employeeId.toString(),
        if (value != null && value.isNotEmpty) 'ProjectName': value,
      },
    );

    return result.fold(
      (failure) {
        return {"itemList": <Map<String, dynamic>>[], "totalNumberOfRecord": 0};
      },
      (response) {
        final List<ProjectModel> projects =
            (response['data'] as List<ProjectModel>);
        if (pageNumber == 1) {
          _projectListNotifier.value = projects;
        } else {
          _projectListNotifier.value = [
            ..._projectListNotifier.value,
            ...projects,
          ];
        }
        final List<Map<String, dynamic>> itemList =
            projects
                .map(
                  (project) => {
                    'zAttributesId': project.projectId,
                    'DisplayName': project.projectName,
                  },
                )
                .toList();
        return {
          "itemList": itemList,
          "totalNumberOfRecord": response['totalNumberOfRecord'] ?? 0,
        };
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.lightGreyBackground,
      appBar: AppBar(
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            mobileScreenGlobalScaffoldKey.currentState?.openDrawer();
          },
        ),
        title: const Text("Inventory Dashboard"),
        actions: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () {
                  DialogHelper.showProcessingOverlay(context);
                },
                icon: SvgPicture.asset(
                  AppAssets.dashboardNotificationIcon,
                  height: 32,
                  width: 32,
                ),
              ),
              ValueListenableBuilder<List<ProjectModel>>(
                valueListenable: _projectListNotifier,
                builder: (context, projects, _) {
                  if (projects.isEmpty) return const SizedBox.shrink();
                  return IconButton(
                    onPressed: () {
                      _showOverlayNotifier.value = true;
                    },
                    icon: SvgPicture.asset(
                      AppAssets.projectIcon,
                      height: 32,
                      width: 32,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextField(
                    readOnly: true,
                    textController: TextEditingController(
                      text: _selectedProject?.projectName ?? '',
                    ),
                    hint: 'Select Project',
                  ),
                  // GENERATE REPORT AND ADD BUTTON
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 5.0,
                          horizontal: 12.0,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6.0),
                          color: AppColor.lightBlue,
                        ),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              AppAssets.generateReportIcon,
                              width: 16,
                              height: 16,
                            ),
                            horizontalSpacing(),
                            Text(
                              "Generate Report",
                              style: AppTextStyle.ts14M(
                                color: AppColor.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      horizontalSpacing(width: 20.0),
                      Expanded(
                        child: CustomButton(
                          leading: Icon(
                            Icons.add,
                            size: 18,
                            color: AppColor.white,
                          ),
                          text: "Add",
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                  verticalSpacing(),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 16.0,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      color: AppColor.white,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            ClipOval(
                              child: NetworkImageWidget(
                                imageUrl:
                                    'https://toppng.com/uploads/preview/immagini-divertenti-115510630433jfc6mpnb0.png',
                                width: 42,
                                height: 42,
                                fit: BoxFit.cover,
                              ),
                            ),
                            horizontalSpacing(width: 16.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Total Buildings",
                                    style: AppTextStyle.ts14M(
                                      color: AppColor.black.withValues(
                                        alpha: 0.5,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    "10",
                                    style: AppTextStyle.ts20SB(
                                      color: AppColor.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  verticalSpacing(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 16.0,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            color: AppColor.white,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  ClipOval(
                                    child: NetworkImageWidget(
                                      imageUrl:
                                          'https://toppng.com/uploads/preview/immagini-divertenti-115510630433jfc6mpnb0.png',
                                      width: 42,
                                      height: 42,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  horizontalSpacing(width: 16.0),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Basement",
                                          style: AppTextStyle.ts14M(
                                            color: AppColor.black.withValues(
                                              alpha: 0.5,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          "02",
                                          style: AppTextStyle.ts20SB(
                                            color: AppColor.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      horizontalSpacing(),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 16.0,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            color: AppColor.white,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  ClipOval(
                                    child: NetworkImageWidget(
                                      imageUrl:
                                          'https://toppng.com/uploads/preview/immagini-divertenti-115510630433jfc6mpnb0.png',
                                      width: 42,
                                      height: 42,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  horizontalSpacing(width: 16.0),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Podium",
                                          style: AppTextStyle.ts14M(
                                            color: AppColor.black.withValues(
                                              alpha: 0.5,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          "04",
                                          style: AppTextStyle.ts20SB(
                                            color: AppColor.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  verticalSpacing(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 16.0,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            color: AppColor.white,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  ClipOval(
                                    child: NetworkImageWidget(
                                      imageUrl:
                                          'https://toppng.com/uploads/preview/immagini-divertenti-115510630433jfc6mpnb0.png',
                                      width: 42,
                                      height: 42,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  horizontalSpacing(width: 16.0),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Wings",
                                          style: AppTextStyle.ts14M(
                                            color: AppColor.black.withValues(
                                              alpha: 0.5,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          "40",
                                          style: AppTextStyle.ts20SB(
                                            color: AppColor.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      horizontalSpacing(),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 16.0,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            color: AppColor.white,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  ClipOval(
                                    child: NetworkImageWidget(
                                      imageUrl:
                                          'https://toppng.com/uploads/preview/immagini-divertenti-115510630433jfc6mpnb0.png',
                                      width: 42,
                                      height: 42,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  horizontalSpacing(width: 16.0),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Floors",
                                          style: AppTextStyle.ts14M(
                                            color: AppColor.black.withValues(
                                              alpha: 0.5,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          "120",
                                          style: AppTextStyle.ts20SB(
                                            color: AppColor.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  verticalSpacing(),
                  _buildUnitStatusDistributionWidget(context),
                  verticalSpacing(),
                  _buildParkingDistributionWidget(context),
                  verticalSpacing(),
                  _buildBuildingOverviewWidget(context),
                  verticalSpacing(),
                  _buildAlertsWidget(context),
                ],
              ),
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: _showOverlayNotifier,
            builder: (context, showOverlay, _) {
              if (!showOverlay) return const SizedBox.shrink();
              return ProjectSelectorOverlay(
                projects: _projectListNotifier.value,
                selectedProjectId: _selectedProject?.projectId,
                onSelect: _onProjectSelected,
                onClose: () {
                  _showOverlayNotifier.value = false;
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUnitStatusDistributionWidget(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: commonCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  "Unit Status Distribution",
                  style: AppTextStyle.ts14M(
                    color: AppColor.black.withValues(alpha: 0.50),
                  ),
                ),
              ),
            ],
          ),
          verticalSpacing(height: 20),
          UnitStatusDistributionRadialChart(
            blocked: 100,
            allotted: 200,
            sold: 300,
            hold: 400,
            available: 500,
          ),
        ],
      ),
    );
  }

  Widget _buildParkingDistributionWidget(BuildContext context) {
    return Container(
      height: 300.0,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: commonCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  "Parking Distribution",
                  style: AppTextStyle.ts14M(
                    color: AppColor.black.withValues(alpha: 0.50),
                  ),
                ),
              ),
            ],
          ),
          verticalSpacing(),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: 6.0,
                      height: 6.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100.0),
                        color: AppColor.primary.withValues(alpha: 0.25),
                      ),
                    ),
                    horizontalSpacing(width: 6.0),
                    Text(
                      "Total Parking",
                      style: AppTextStyle.ts12R(
                        color: AppColor.black.withValues(alpha: 0.50),
                      ),
                    ),
                  ],
                ),
              ),
              horizontalSpacing(width: 50.0),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: 6.0,
                      height: 6.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100.0),
                        color: AppColor.primary,
                      ),
                    ),
                    horizontalSpacing(width: 6.0),
                    Text(
                      "Available Parking",
                      style: AppTextStyle.ts12R(
                        color: AppColor.black.withValues(alpha: 0.50),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          verticalSpacing(height: 20.0),
          Expanded(
            child: ListView.builder(
              itemCount: 5,
              shrinkWrap: true,
              physics: AlwaysScrollableScrollPhysics(),
              itemBuilder: (context, int index) {
                return _buildParkingRow(
                  title: "Basement 1",
                  used: 100,
                  total: 300,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParkingRow({
    required String title,
    required int used,
    required int total,
  }) {
    final double progress = total == 0 ? 0 : used / total;

    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTextStyle.ts16M(
                  color: AppColor.black.withValues(alpha: 0.7),
                ),
              ),
              Text(
                "$used/$total",
                style: AppTextStyle.ts16M(
                  color: AppColor.black.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),

          verticalSpacing(height: 10),

          // Progress Bar (like your design)
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress, // 🔥 IMPORTANT: 0 to 1 only
              minHeight: 10,
              borderRadius: BorderRadius.circular(4.0),
              backgroundColor: AppColor.primary.withValues(alpha: 0.25),
              valueColor: AlwaysStoppedAnimation(AppColor.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuildingOverviewWidget(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: commonCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  "Building Overview",
                  style: AppTextStyle.ts14M(
                    color: AppColor.black.withValues(alpha: 0.50),
                  ),
                ),
              ),
            ],
          ),
          verticalSpacing(),
          ListView.builder(
            itemCount: 3,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, int index) {
              return Container(
                margin: EdgeInsets.only(bottom: 16.0),
                padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.0),
                  color: AppColor.lightGreyBackground,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Ratan Nagar 1", style: AppTextStyle.ts14SB()),
                    verticalSpacing(height: 20.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Row
                        Row(
                          children: [
                            _buildOverviewItem("02", "Basement"),
                            _buildOverviewItem("02", "Podiums"),
                            _buildOverviewItem("05", "Wings"),
                          ],
                        ),
                        verticalSpacing(height: 20),
                        Row(
                          children: [
                            _buildOverviewItem("20", "Floor"),
                            _buildOverviewItem("400", "Units"),
                            _buildOverviewItem("800", "Parkings"),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewItem(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: AppTextStyle.ts14R()),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyle.ts12R(
              color: AppColor.black.withValues(alpha: 0.50),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsWidget(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: commonCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  "Alerts",
                  style: AppTextStyle.ts14M(
                    color: AppColor.black.withValues(alpha: 0.50),
                  ),
                ),
              ),
            ],
          ),
          verticalSpacing(),
          ListView.builder(
            itemCount: 2,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, int index) {
              return Container(
                margin: EdgeInsets.only(bottom: 6.0),
                padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6.0),
                  color: AppColor.red.withValues(alpha: 0.1),
                  border: Border(
                    left: BorderSide(width: 4, color: AppColor.red),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Basement 2", style: AppTextStyle.ts16M()),
                    Text(
                      "87% Occupancy Reached In Building A",
                      style: AppTextStyle.ts14R(),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class UnitStatusDistributionRadialChart extends StatelessWidget {
  final int blocked;
  final int allotted;
  final int sold;
  final int hold;
  final int available;

  const UnitStatusDistributionRadialChart({
    super.key,
    required this.blocked,
    required this.allotted,
    required this.sold,
    required this.hold,
    required this.available,
  });

  int get total => blocked + allotted + sold + hold + available;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Center Chart
        Center(
          child: SizedBox(
            height: 120,
            width: 120,
            child: CustomPaint(
              painter: UnitRadialPainter(
                blocked: blocked,
                allotted: allotted,
                sold: sold,
                hold: hold,
                available: available,
              ),
            ),
          ),
        ),
        verticalSpacing(),
        Center(
          child: Text("Total Units : $total", style: AppTextStyle.ts16SB()),
        ),
        verticalSpacing(),

        _legendRow(AppColor.grey, "Blocked Units", blocked),
        const SizedBox(height: 14),
        _legendRow(AppColor.purple, "Allotted Units", allotted),
        const SizedBox(height: 14),
        _legendRow(AppColor.red, "Sold Units", sold),
        const SizedBox(height: 14),
        _legendRow(const Color(0xFFB3B300), "Hold Units", hold),
        const SizedBox(height: 14),
        _legendRow(AppColor.green, "Available Units", available),
      ],
    );
  }

  Widget _legendRow(Color color, String title, int value) {
    return Row(
      children: [
        Container(
          height: 6,
          width: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        horizontalSpacing(),

        Expanded(child: Text(title, style: AppTextStyle.ts14M(color: color))),

        Text(value.toString(), style: AppTextStyle.ts16B(color: color)),
      ],
    );
  }
}

class UnitRadialPainter extends CustomPainter {
  final int blocked;
  final int allotted;
  final int sold;
  final int hold;
  final int available;

  UnitRadialPainter({
    required this.blocked,
    required this.allotted,
    required this.sold,
    required this.hold,
    required this.available,
  });

  final double stroke = 20; // thicker like UI
  final double gap = 25; // smooth gap between arcs

  @override
  void paint(Canvas canvas, Size size) {
    final total = blocked + allotted + sold + hold + available;
    if (total == 0) return;

    final center = size.center(Offset.zero);
    final radius = size.width / 2.4;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round;

    final usableDegrees = 360 - (gap * 5);
    double startAngle = -90; // start from top

    void drawSegment(int value, Color color) {
      if (value == 0) return;
      final sweep = (value / total) * usableDegrees;
      paint.color = color;
      canvas.drawArc(
        rect,
        _degToRad(startAngle),
        _degToRad(sweep),
        false,
        paint,
      );
      startAngle += sweep + gap;
    }

    /// Order matches screenshot colors
    drawSegment(sold, AppColor.red);
    drawSegment(allotted, AppColor.purple);
    drawSegment(blocked, AppColor.grey);
    drawSegment(hold, const Color(0xFFB3B300));
    drawSegment(available, AppColor.green);
  }

  double _degToRad(double deg) => deg * pi / 180;

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
