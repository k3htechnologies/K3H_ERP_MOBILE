import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/setting_dashboard/presentation/cubit/setting_dashboard_cubit.dart';
import 'package:k3h_erp_app/features/sales/sales_dashboard/presentation/pages/sales_dashboard_screen.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class SettingDashboardScreen extends StatefulWidget {
  const SettingDashboardScreen({super.key});

  @override
  State<SettingDashboardScreen> createState() => _SettingDashboardScreenState();
}

class _SettingDashboardScreenState extends State<SettingDashboardScreen> {
  // CUBIT
  late SettingDashboardCubit _settingDashboardCubit;

  // PROJECT
  late ProjectModel _selectedProject;

  @override
  void initState() {
    super.initState();
    _settingDashboardCubit = context.read<SettingDashboardCubit>();
    _selectedProject = getProject();
    _settingDashboardCubit.getSettingDashboardList(
      context,
      _selectedProject.projectId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingDashboardCubit, SettingDashboardState>(
      builder: (context, state) {
        if (state.isLoading == true) {
          return Center(child: loader());
        }
        return Scaffold(
          appBar: CustomAppBarWithBackButton(
            screenTitle: "Setting",
            isMenuButton: true,
            authorization: AuthorizationModel(),
            onProjectChangeCallback: (value) {
              _selectedProject = value;
              _settingDashboardCubit.getSettingDashboardList(
                context,
                _selectedProject.projectId,
              );
            },
            showNotification: true,
          ),
          body: BlocBuilder<SettingDashboardCubit, SettingDashboardState>(
            builder: (context, state) {
              if (state.isLoading == true) {
                return Center(child: loader());
              }

              return SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // TOTAL COMPANINES, EMPLOYEES, ACTIVE PROJECT AND REGISTERED VENDORS COUNT WIDGET
                          _buildSettingsDashboardOverview(context),
                          // COMPANY SETUP WIDGET
                          _buildCompanySetupWidget(context),
                          verticalSpacing(height: 15.0),
                          // PROCUREMENT MASTER WIDGET
                          _buildProcurementMasterWidget(context),
                          verticalSpacing(height: 15.0),
                          // PROJECT MANAGEMENT WIDGET
                          _buildProjectManagementWidget(context),
                          verticalSpacing(height: 15.0),
                          // VENDOR MANAGEMENT WIDGET
                          _buildVendorManagementWidget(context),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSettingsDashboardOverview(BuildContext context) {
    return BlocBuilder<SettingDashboardCubit, SettingDashboardState>(
      builder: (context, state) {
        if (state.isLoading == true) {
          return Center(child: loader());
        }

        final table0 =
            (state.settingDashboardModel?.table0.isNotEmpty ?? false)
                ? state.settingDashboardModel!.table0.first
                : null;

        return GridView.count(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          childAspectRatio: 1.25,
          children: [
            _dashboardCard(
              icon: AppAssets.totalCompaniesIcon,
              value: table0?.totalCompanies.toInt() ?? 0,
              title: "Total Companies",
              subtitle: "+2 this month",
              subtitleColor: AppColor.green,
            ),

            _dashboardCard(
              icon: AppAssets.totalEmployeeeIcon,
              value: table0?.totalEmployees.toInt() ?? 0,
              title: "Total Employees",
              subtitle: "+12 this month",
              subtitleColor: AppColor.green,
            ),

            _dashboardCard(
              icon: AppAssets.activeProjectsIcon,
              value: table0?.activeProjects.toInt() ?? 0,
              title: "Active Projects",
              subtitle: "8 on hold",
              subtitleColor: Colors.orange,
            ),

            _dashboardCard(
              icon: AppAssets.registeredVendorsIcon,
              value: table0?.registeredVendors.toInt() ?? 0,
              title: "Registered Vendors",
              subtitle: "12 added recently",
              subtitleColor: AppColor.green,
            ),
          ],
        );
      },
    );
  }

  Widget _dashboardCard({
    required String icon,
    required int value,
    required String title,
    required String subtitle,
    required Color subtitleColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12.0),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              SvgPicture.asset(icon, width: 30, height: 30),
              horizontalSpacing(width: 12),
              Text(
                value.toString(),
                style: AppTextStyle.ts20SB(color: AppColor.black),
              ),
            ],
          ),
          verticalSpacing(height: 12),
          Text(
            title,
            style: AppTextStyle.ts14M(
              color: AppColor.black.withValues(alpha: 0.5),
            ),
          ),
          verticalSpacing(height: 4),
          Text(subtitle, style: AppTextStyle.ts12R(color: subtitleColor)),
        ],
      ),
    );
  }

  Widget _buildCompanySetupWidget(BuildContext context) {
    return BlocBuilder<SettingDashboardCubit, SettingDashboardState>(
      builder: (context, state) {
        if (state.isLoading == true) {
          return Center(child: loader());
        }

        final table1 =
            (state.settingDashboardModel?.table1.isNotEmpty ?? false)
                ? state.settingDashboardModel!.table1.first
                : null;
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
                      "Company Setup",
                      style: AppTextStyle.ts14M(
                        color: AppColor.black.withValues(alpha: 0.50),
                      ),
                    ),
                  ),
                ],
              ),
              verticalSpacing(),
              GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 3,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  _companyDepartmentChip(
                    title: "Departments",
                    value: table1?.departments.toInt() ?? 0,
                  ),
                  _companyDepartmentChip(
                    title: "Designations",
                    value: table1?.designations.toInt() ?? 0,
                  ),
                  _companyDepartmentChip(
                    title: "Employees",
                    value: table1?.employees.toInt() ?? 0,
                  ),
                  _companyDepartmentChip(
                    title: "Branches",
                    value: table1?.branches.toInt() ?? 0,
                  ),
                  _companyDepartmentChip(
                    title: "Banks Listed",
                    value: table1?.banksListed.toInt() ?? 0,
                  ),
                  _companyDepartmentChip(
                    title: "TnC",
                    value: table1?.tnc.toInt() ?? 0,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _companyDepartmentChip({String? title, int? value}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          width: 0.8,
          color: AppColor.black.withValues(alpha: 0.12),
        ),
        color: AppColor.lightGreyBackground,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title!,
              style: AppTextStyle.ts14M(
                color: AppColor.black.withValues(alpha: 0.6),
              ),
            ),
          ),
          horizontalSpacing(),
          Text(
            value.toString(),
            style: AppTextStyle.ts16SB(
              color: AppColor.black.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcurementMasterWidget(BuildContext context) {
    return BlocBuilder<SettingDashboardCubit, SettingDashboardState>(
      builder: (context, state) {
        if (state.isLoading == true) {
          return Center(child: loader());
        }

        final table2 =
            (state.settingDashboardModel?.table2.isNotEmpty ?? false)
                ? state.settingDashboardModel!.table2.first
                : null;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: commonCardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      "Procurement Master",
                      style: AppTextStyle.ts14M(
                        color: AppColor.black.withValues(alpha: 0.50),
                      ),
                    ),
                  ),
                ],
              ),
              verticalSpacing(),
              Row(
                children: [
                  Expanded(
                    child: _procurementMasterWiget(
                      table2?.totalMaterial.toString() ?? "0",
                      "Material",
                    ),
                  ),
                  _verticalDivider(),
                  Expanded(
                    child: _procurementMasterWiget(
                      table2?.totalSubMaterial.toString() ?? "0",
                      "Sub-Material",
                    ),
                  ),
                  _verticalDivider(),
                  Expanded(
                    child: _procurementMasterWiget(
                      table2?.uom.toString() ?? "0",
                      "UOM",
                    ),
                  ),
                ],
              ),
              verticalSpacing(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  color: AppColor.lightYellow.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xffE6C65C)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Pending Material Setup",
                            style: AppTextStyle.ts14M(color: AppColor.black),
                          ),
                          verticalSpacing(height: 4),
                          Text(
                            "Requires configuration",
                            style: AppTextStyle.ts12R(
                              color: AppColor.black.withValues(alpha: .5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      table2?.materialWithoutSubMaterial.toString() ?? "0",
                      style: AppTextStyle.ts16SB(color: AppColor.orange),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _procurementMasterWiget(String value, String title) {
    return Column(
      children: [
        Text(value, style: AppTextStyle.ts16SB(color: AppColor.black)),
        verticalSpacing(height: 6),
        Text(
          title,
          style: AppTextStyle.ts12M(
            color: AppColor.black.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  Widget _verticalDivider() {
    return Container(
      height: 60,
      width: 1,
      color: AppColor.black.withValues(alpha: .2),
    );
  }

  Widget _buildProjectManagementWidget(BuildContext context) {
    return BlocBuilder<SettingDashboardCubit, SettingDashboardState>(
      builder: (context, state) {
        if (state.isLoading == true) {
          return Center(child: loader());
        }

        final table4 =
            (state.settingDashboardModel?.table4.isNotEmpty ?? false)
                ? state.settingDashboardModel!.table4.first
                : null;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: commonCardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      "Project Management",
                      style: AppTextStyle.ts14M(
                        color: AppColor.black.withValues(alpha: 0.50),
                      ),
                    ),
                  ),
                ],
              ),
              verticalSpacing(),
              _projectManagementChip(
                title: "Total Project",
                value: table4?.totalProjects.toInt() ?? 0,
                bgColor: AppColor.lightGreyBackground,
                valueColor: AppColor.black,
              ),
              verticalSpacing(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _projectManagementChip(
                      title: "RERA Registered",
                      value: table4?.reraRegistered.toInt() ?? 0,
                      bgColor: AppColor.green.withValues(alpha: 0.15),
                      valueColor: AppColor.green,
                    ),
                  ),
                  horizontalSpacing(),
                  Expanded(
                    child: _projectManagementChip(
                      title: "Redevelopment",
                      value: table4?.redevelopment.toInt() ?? 0,
                      bgColor: AppColor.lightPurple.withValues(alpha: 0.15),
                      valueColor: AppColor.darkBlue,
                    ),
                  ),
                ],
              ),
              verticalSpacing(),
              verticalSpacing(height: 20),
              ProjectManagementRadialChart(
                ongoing: 7,
                onHold: 1,
                completed: 2,
                cancelled: 5,
                planning: 5,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _projectManagementChip({
    String? title,
    int? value,
    Color? bgColor,
    Color? valueColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          width: 0.8,
          color: AppColor.black.withValues(alpha: 0.12),
        ),
        color: bgColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title!,
              style: AppTextStyle.ts14M(
                color: AppColor.black.withValues(alpha: 0.6),
              ),
            ),
          ),
          horizontalSpacing(),
          Text(value.toString(), style: AppTextStyle.ts16SB(color: valueColor)),
        ],
      ),
    );
  }

  Widget _buildVendorManagementWidget(BuildContext context) {
    return BlocBuilder<SettingDashboardCubit, SettingDashboardState>(
      builder: (context, state) {
        if (state.isLoading == true) {
          return Center(child: loader());
        }

        final table3 =
            (state.settingDashboardModel?.table3.isNotEmpty ?? false)
                ? state.settingDashboardModel!.table3.first
                : null;

        final table5 =
            (state.settingDashboardModel?.table5.isNotEmpty ?? false)
                ? state.settingDashboardModel!.table5
                : null;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: commonCardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      "Vendor Management",
                      style: AppTextStyle.ts14M(
                        color: AppColor.black.withValues(alpha: 0.50),
                      ),
                    ),
                  ),
                ],
              ),
              verticalSpacing(),
              Row(
                children: [
                  Expanded(
                    child: _procurementMasterWiget(
                      table3?.totalVendors.toString() ?? "0",
                      "Total Vendors",
                    ),
                  ),
                  _verticalDivider(),
                  Expanded(
                    child: _procurementMasterWiget(
                      table3?.totalMaterial.toString() ?? "0",
                      "Total Material",
                    ),
                  ),
                  _verticalDivider(),
                  Expanded(
                    child: _procurementMasterWiget(
                      table3?.contractCount.toString() ?? "0",
                      "Total Contract",
                    ),
                  ),
                ],
              ),
              verticalSpacing(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _projectManagementChip(
                      title: "Company Type",
                      value: 0,
                      bgColor: AppColor.lightGreyBackground,
                      valueColor: AppColor.black,
                    ),
                  ),
                  horizontalSpacing(),
                  Expanded(
                    child: _projectManagementChip(
                      title: "Missing Details",
                      value: 0,
                      bgColor: AppColor.yellow.withValues(alpha: 0.2),
                      valueColor: AppColor.yellow,
                    ),
                  ),
                ],
              ),
              verticalSpacing(),
              Divider(
                color: AppColor.black.withValues(alpha: 0.5),
                thickness: 0.3,
              ),
              verticalSpacing(),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      "Vendor Distribution",
                      style: AppTextStyle.ts14SB(color: AppColor.black),
                    ),
                  ),
                ],
              ),
              verticalSpacing(),
              if (table5 != null && table5.isNotEmpty) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:
                      table5.map((subSourceData) {
                        return SourceProgressBar(
                          title: subSourceData.companyType,
                          percentage: subSourceData.vendorCount,
                        );
                      }).toList(),
                ),
              ] else ...[
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      "No Vendor Distribution Available",
                      style: AppTextStyle.ts12M(
                        color: AppColor.black.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),
              ],
              verticalSpacing(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(
                    width: 0.8,
                    color: AppColor.purple.withValues(alpha: 0.8),
                  ),
                  color: AppColor.lightPurple,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Recently Added Vendors",
                          style: AppTextStyle.ts14M(),
                        ),
                        Text(
                          "Last 30 days",
                          style: AppTextStyle.ts12R(
                            color: AppColor.black.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      "12",
                      style: AppTextStyle.ts16SB(color: AppColor.purple),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ProjectManagementRadialChart extends StatelessWidget {
  final int ongoing;
  final int onHold;
  final int completed;
  final int cancelled;
  final int planning;

  const ProjectManagementRadialChart({
    super.key,
    required this.ongoing,
    required this.onHold,
    required this.completed,
    required this.cancelled,
    required this.planning,
  });

  int get total => ongoing + onHold + completed + cancelled + planning;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: SizedBox(
            height: 120,
            width: 120,
            child: CustomPaint(
              painter: UnitRadialPainter(
                ongoing: ongoing,
                onHold: onHold,
                completed: completed,
                cancelled: cancelled,
                planning: planning,
              ),
              child: Center(
                child: Text(total.toString(), style: AppTextStyle.ts16SB()),
              ),
            ),
          ),
        ),
        verticalSpacing(height: 20),
        _legendRow(AppColor.primary, "Ongoing Projects", ongoing),
        verticalSpacing(height: 14),
        _legendRow(AppColor.yellow, "On hold Projects", onHold),
        verticalSpacing(height: 14),
        _legendRow(AppColor.green, "Completed Projects", completed),
        verticalSpacing(height: 14),
        _legendRow(AppColor.grey, "Cancelled Projects", cancelled),
        verticalSpacing(height: 14),
        _legendRow(AppColor.blue, "Planning Projects", planning),
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
  final int ongoing;
  final int onHold;
  final int completed;
  final int cancelled;
  final int planning;

  UnitRadialPainter({
    required this.ongoing,
    required this.onHold,
    required this.completed,
    required this.cancelled,
    required this.planning,
  });

  final double stroke = 20;
  final double gap = 25;

  @override
  void paint(Canvas canvas, Size size) {
    final total = ongoing + onHold + completed + cancelled + planning;
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
    double startAngle = -90;

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

    drawSegment(ongoing, AppColor.primary);
    drawSegment(onHold, AppColor.yellow);
    drawSegment(completed, AppColor.green);
    drawSegment(cancelled, AppColor.grey);
    drawSegment(planning, AppColor.blue);
  }

  double _degToRad(double deg) => deg * pi / 180;

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
