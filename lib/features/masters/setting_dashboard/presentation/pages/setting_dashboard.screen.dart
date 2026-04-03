import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/setting_dashboard/presentation/cubit/setting_dashboard_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/charts/custom_radial_chart.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class SettingDashboardScreen extends StatefulWidget {
  const SettingDashboardScreen({super.key});

  @override
  State<SettingDashboardScreen> createState() => _SettingDashboardScreenState();
}

class _SettingDashboardScreenState extends State<SettingDashboardScreen> {
  // CUBIT
  late SettingDashboardCubit _settingDashboardCubit;

  @override
  void initState() {
    super.initState();
    _settingDashboardCubit = context.read<SettingDashboardCubit>();
    _settingDashboardCubit.getSettingDashboardList(context);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        _settingDashboardCubit.getSettingDashboardList(context);
      },
      child: BlocBuilder<SettingDashboardCubit, SettingDashboardState>(
        builder: (context, state) {
          if (state.isLoading == true) {
            return Center(child: loader());
          }
          return Scaffold(
            appBar: CustomAppBarWithBackButton(
              screenTitle: "Setting",
              isMenuButton: true,
              authorization: AuthorizationModel(),
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
                            verticalSpacing(height: 15.0),
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
      ),
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
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _dashboardCard(
                    icon: AppAssets.totalCompaniesIcon,
                    value: table0?.totalCompanies.toString() ?? "0.0",
                    title: "Total Companies",
                    subtitle:
                        "+${table0?.companiesAddedThisMonth.toInt() ?? 0} this month",
                    subtitleColor: AppColor.green,
                  ),
                ),
                horizontalSpacing(),
                Expanded(
                  child: _dashboardCard(
                    icon: AppAssets.totalEmployeeeIcon,
                    value: table0?.totalEmployees.toString() ?? "0.0",
                    title: "Total Employees",
                    subtitle:
                        "+${table0?.employeesAddedThisMonth.toInt() ?? 0} this month",
                    subtitleColor: AppColor.green,
                  ),
                ),
              ],
            ),
            verticalSpacing(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _dashboardCard(
                    icon: AppAssets.activeProjectsIcon,
                    value: table0?.activeProjects.toString() ?? "0.0",
                    title: "Active Projects",
                    subtitle: "${table0?.onHoldProjects.toInt() ?? 0} on hold",
                    subtitleColor: Colors.orange,
                  ),
                ),
                horizontalSpacing(),
                _dashboardCard(
                  icon: AppAssets.registeredVendorsIcon,
                  value: table0?.registeredVendors.toString() ?? "0.0",
                  title: "Registered Vendors",
                  subtitle:
                      "+${table0?.vendorsAddedThisMonth.toInt() ?? 0} this month",
                  subtitleColor: AppColor.green,
                ),
              ],
            ),
          ],
        );
        // return GridView.count(
        //   shrinkWrap: true,
        //   physics: NeverScrollableScrollPhysics(),
        //   crossAxisCount: 2,
        //   mainAxisSpacing: 10,
        //   crossAxisSpacing: 10,
        //   childAspectRatio: 1.10,

        // );
      },
    );
  }

  Widget _dashboardCard({
    required String icon,
    required String value,
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
                      "Company Master",
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
        final table7 =
            (state.settingDashboardModel?.table7.isNotEmpty ?? false)
                ? state.settingDashboardModel!.table7.first
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
              verticalSpacing(height: 20.0),
              if (table7 != null) ...[
                CommonRadialChart(
                  items:
                      [
                        RadialChartItem(
                          title: "Ongoing Projects",
                          value: table7.ongoingProjects,
                          color: AppColor.primary,
                        ),
                        RadialChartItem(
                          title: "On hold Projects",
                          value: table7.onHoldProjects,
                          color: AppColor.yellow,
                        ),
                        RadialChartItem(
                          title: "Completed Projects",
                          value: table7.completedProjects,
                          color: AppColor.green,
                        ),
                        RadialChartItem(
                          title: "Cancelled Projects",
                          value: table7.cancelledProjects,
                          color: AppColor.grey,
                        ),
                        RadialChartItem(
                          title: "Planning Projects",
                          value: table7.planningProjects,
                          color: AppColor.blue,
                        ),
                      ].where((e) => e.value > 0).toList(),
                ),
              ] else ...[
                Center(
                  child: Text(
                    "No Data Found",
                    style: AppTextStyle.ts12M(
                      color: AppColor.black.withValues(alpha: 0.50),
                    ),
                  ),
                ),
              ],
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
                      value: table3?.missingDetails.toInt() ?? 0,
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
                  children:
                      table5.map((item) {
                        return VendorDistributionProgressBar(
                          title: item.companyType,
                          value: item.vendorCount,
                          total: table5.fold(
                            0,
                            (sum, e) => sum + e.vendorCount,
                          ),
                        );
                      }).toList(),
                ),
              ] else ...[
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      "No Data Found",
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
                      table3?.missingDetails.toString() ?? "0",
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

class VendorDistributionProgressBar extends StatelessWidget {
  final String title;
  final int value;
  final int total;

  const VendorDistributionProgressBar({
    super.key,
    required this.title,
    required this.value,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = total == 0 ? 0 : value / total;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Title + Count
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyle.ts14M(color: AppColor.black),
                ),
              ),
              Text(
                "$value/$total",
                style: AppTextStyle.ts14M(color: AppColor.black),
              ),
            ],
          ),

          const SizedBox(height: 8),

          /// Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColor.primary.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation(AppColor.primary),
            ),
          ),
        ],
      ),
    );
  }
}
