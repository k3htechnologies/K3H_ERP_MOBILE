import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/inventory/presentation/cubit/inventory_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/charts/custom_radial_chart.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class InventoryDashboard extends StatefulWidget {
  const InventoryDashboard({super.key});

  @override
  State<InventoryDashboard> createState() => _InventoryDashboardState();
}

class _InventoryDashboardState extends State<InventoryDashboard> {
  // AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;
  // CUBIT
  late InventoryCubit _inventoryCubit;
  late ProjectModel _selectedProject;
  @override
  void initState() {
    super.initState();
    _inventoryCubit = context.read<InventoryCubit>();
    _selectedProject = getProject();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.inventory]!;
    _inventoryCubit.getInventoryDashboardList(
      context,
      _selectedProject.projectId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.lightGreyBackground,
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Inventory Dashboard",
        isMenuButton: true,
        authorization: _routeAuthorizationModel,
        onProjectChangeCallback: (value) {
          _selectedProject = value;
          _inventoryCubit.getInventoryDashboardList(
            context,
            _selectedProject.projectId,
          );
        },
        showNotification: true,
      ),
      body: SafeArea(
        child: BlocBuilder<InventoryCubit, InventoryState>(
          builder: (context, state) {
            if (state.isLoading == true) {
              return loader();
            }
            final inventoryDashboardData = state.inventoryDashboardModelList;
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SELECTED PROJECT TEXT PROJECT CUSTOM TEXT FIELD (ONLY DISPLAY)
                  showSiteSelectedWidget(),
                  // GENERATE REPORT AND ADD BUTTON
                  if (_selectedProject.projectId != 0) ...[
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
                        if (_routeAuthorizationModel.isAction) ...[
                          horizontalSpacing(width: 20.0),
                          CustomButton(
                            leading: Icon(
                              Icons.add,
                              size: 18,
                              color: AppColor.white,
                            ),
                            text: "Add Inventory",
                            onPressed: () {
                              goRouter.pushNamed(AppRoutes.inventory);
                            },
                          ),
                        ],
                      ],
                    ),
                  ] else ...[
                    SizedBox.shrink(),
                  ],
                  verticalSpacing(),
                  // TOTOAL BUILDING COUNT WIDGET
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
                            SvgPicture.asset(
                              AppAssets.totalBuildingsIcon,
                              width: 30,
                              height: 30,
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
                                    inventoryDashboardData
                                        .first
                                        .table0
                                        .first
                                        .totalBuilding
                                        .toString(),
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
                  // BASEMENT AND PODIUM COUNT WIDGET
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
                                  SvgPicture.asset(
                                    AppAssets.basementIcon,
                                    width: 30,
                                    height: 30,
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
                                          inventoryDashboardData
                                              .first
                                              .table0
                                              .first
                                              .totalBasement
                                              .toString(),
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
                                  SvgPicture.asset(
                                    AppAssets.podiumIcon,
                                    width: 30,
                                    height: 30,
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
                                          inventoryDashboardData
                                              .first
                                              .table0
                                              .first
                                              .totalPodium
                                              .toString(),
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
                  // WINGS AND FLOORS COUNT WIDGET
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
                                  SvgPicture.asset(
                                    AppAssets.wingsIcon,
                                    width: 30,
                                    height: 30,
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
                                          inventoryDashboardData
                                              .first
                                              .table0
                                              .first
                                              .totalWings
                                              .toString(),
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
                                  SvgPicture.asset(
                                    AppAssets.groundIcon,
                                    width: 30,
                                    height: 30,
                                  ),
                                  horizontalSpacing(width: 16.0),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Ground",
                                          style: AppTextStyle.ts14M(
                                            color: AppColor.black.withValues(
                                              alpha: 0.5,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          inventoryDashboardData
                                              .first
                                              .table0
                                              .first
                                              .totalBuilding
                                              .toString(),
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
                  // UNIT STATUS DISTRIBUTION WIDGET
                  _buildUnitStatusDistributionWidget(context),
                  verticalSpacing(),
                  // PARKING DISTRIBUTION WIDGET
                  _buildParkingDistributionWidget(context),
                  verticalSpacing(),
                  // BUILDING OVERVIEW WIDGET
                  _buildBuildingOverviewWidget(context),
                  verticalSpacing(),
                  // ATLERT WIDGET
                  _buildAlertsWidget(context),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildUnitStatusDistributionWidget(BuildContext context) {
    return BlocBuilder<InventoryCubit, InventoryState>(
      builder: (context, state) {
        if (state.isLoading == true) {
          return Center(child: loader());
        }

        final data = state.inventoryDashboardModel;
        final table0 = data?.table0.first;
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
              if (table0 != null) ...[
                CommonRadialChart(
                  items:
                      [
                        RadialChartItem(
                          title: "Blocked Units",
                          value:
                              state
                                  .inventoryDashboardModel!
                                  .table0
                                  .first
                                  .blockedFlats,
                          color: AppColor.black.withValues(alpha: 0.5),
                        ),
                        RadialChartItem(
                          title: "Member Units",
                          value:
                              state
                                  .inventoryDashboardModel!
                                  .table0
                                  .first
                                  .allotedFlats,
                          color: AppColor.purple,
                        ),
                        RadialChartItem(
                          title: "Booked Units",
                          value:
                              state
                                  .inventoryDashboardModel!
                                  .table0
                                  .first
                                  .bookedFlats,
                          color: AppColor.error,
                        ),
                        RadialChartItem(
                          title: "Hold Units",
                          value:
                              state
                                  .inventoryDashboardModel!
                                  .table0
                                  .first
                                  .holdFlats,
                          color: AppColor.yellow,
                        ),
                        RadialChartItem(
                          title: "Available Units",
                          value:
                              state
                                  .inventoryDashboardModel!
                                  .table0
                                  .first
                                  .availableFlats,
                          color: AppColor.green,
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

  Widget _buildParkingDistributionWidget(BuildContext context) {
    return BlocBuilder<InventoryCubit, InventoryState>(
      builder: (context, state) {
        if (state.isLoading == true) {
          return Center(child: loader());
        }

        final data = state.inventoryDashboardModel;
        final table1 = data?.table1;
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
              if (table1 != null && table1.isNotEmpty) ...[
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
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
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
                    itemCount: table1.length,
                    shrinkWrap: true,
                    physics: AlwaysScrollableScrollPhysics(),
                    itemBuilder: (context, int index) {
                      final parkingDetails = table1[index];
                      return _buildParkingRow(
                        title: parkingDetails.floorName,
                        used: parkingDetails.availableParking,
                        total: parkingDetails.totalParking,
                      );
                    },
                  ),
                ),
              ] else ...[
                Expanded(
                  child: Center(
                    child: noDataWidget(
                      message: "No Data Found",
                      iconSize: 180,
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
                style: AppTextStyle.ts14M(
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

          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
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
    return BlocBuilder<InventoryCubit, InventoryState>(
      builder: (context, state) {
        if (state.isLoading == true) {
          return Center(child: loader());
        }

        final data = state.inventoryDashboardModel;
        final table2 = data?.table2;
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
              if (table2 != null && table2.isNotEmpty) ...[
                ListView.builder(
                  itemCount: table2.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, int index) {
                    final buildingOverview = table2[index];
                    return Container(
                      margin: EdgeInsets.only(bottom: 16.0),
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 12.0,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6.0),
                        border: Border.all(width: 0.3, color: AppColor.primary),
                        color: AppColor.white,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            buildingOverview.building,
                            style: AppTextStyle.ts14SB(),
                          ),
                          verticalSpacing(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  _buildOverviewItem(
                                    buildingOverview.basement.toString(),
                                    "Basement",
                                  ),
                                  horizontalSpacing(),
                                  _buildOverviewItem(
                                    buildingOverview.podiums.toString(),
                                    "Podiums",
                                  ),
                                  horizontalSpacing(),
                                  _buildOverviewItem(
                                    buildingOverview.wings.toString(),
                                    "Wings",
                                  ),
                                ],
                              ),
                              verticalSpacing(height: 20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildOverviewItem(
                                    buildingOverview.floors.toString(),
                                    "Floor",
                                  ),
                                  horizontalSpacing(),
                                  _buildOverviewItem(
                                    buildingOverview.units.toString(),
                                    "Units",
                                  ),
                                  horizontalSpacing(),
                                  _buildOverviewItem(
                                    buildingOverview.parking.toString(),
                                    "Parkings",
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ] else ...[
                Center(
                  child: noDataWidget(message: "No Data Found", iconSize: 180),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildOverviewItem(String value, String label) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyle.ts12M(
              color: AppColor.black.withValues(alpha: 0.50),
            ),
          ),
          verticalSpacing(height: 4),
          Text(value, style: AppTextStyle.ts14M()),
        ],
      ),
    );
  }

  Widget _buildAlertsWidget(BuildContext context) {
    return BlocBuilder<InventoryCubit, InventoryState>(
      builder: (context, state) {
        if (state.isLoading == true) {
          return Center(child: loader());
        }

        final data = state.inventoryDashboardModel;
        final table3 = data?.table3;
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
              if (table3 != null && table3.isNotEmpty) ...[
                SizedBox(
                  height: 200.0,
                  child: ListView.builder(
                    itemCount: table3.length,
                    shrinkWrap: true,
                    itemBuilder: (context, int index) {
                      final alerts = table3[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: 6.0),
                        padding: EdgeInsets.symmetric(
                          vertical: 12.0,
                          horizontal: 16.0,
                        ),
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
                            Text(
                              alerts.buildingName,
                              style: AppTextStyle.ts14M(),
                            ),
                            Text(alerts.issue, style: AppTextStyle.ts14R()),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ] else ...[
                Center(
                  child: noDataWidget(message: "No Data Found", iconSize: 180),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
