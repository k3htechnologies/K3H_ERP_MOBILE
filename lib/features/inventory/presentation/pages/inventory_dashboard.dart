import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/inventory/presentation/cubit/inventory_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/charts/custom_radial_chart.dart';
import 'package:k3h_erp_app/widgets/network_image_widget.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
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
    return BlocBuilder<InventoryCubit, InventoryState>(
      builder: (context, state) {
        if (state.isLoading == true) {
          return loader();
        }
        final inventoryDashboardData = state.inventoryDashboardModelList;
        return Scaffold(
          backgroundColor: AppColor.lightGreyBackground,
          appBar: CustomAppBarWithBackButton(
            screenTitle: "Inventory",
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
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // SELECTED PROJECT TEXT PROJECT CUSTOM TEXT FIELD (ONLY DISPLAY)
                        CustomTextField(
                          readOnly: true,
                          textController: TextEditingController(
                            text: _selectedProject.projectName,
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
                            if (_routeAuthorizationModel.isAction) ...[
                              horizontalSpacing(width: 20.0),
                              Expanded(
                                child: CustomButton(
                                  leading: Icon(
                                    Icons.add,
                                    size: 18,
                                    color: AppColor.white,
                                  ),
                                  text: "Add Inventory",
                                  onPressed: () {},
                                ),
                              ),
                            ],
                          ],
                        ),
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
                                                  color: AppColor.black
                                                      .withValues(alpha: 0.5),
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
                                                  color: AppColor.black
                                                      .withValues(alpha: 0.5),
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
                                                  color: AppColor.black
                                                      .withValues(alpha: 0.5),
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
                                                "Ground",
                                                style: AppTextStyle.ts14M(
                                                  color: AppColor.black
                                                      .withValues(alpha: 0.5),
                                                ),
                                              ),
                                              Text(
                                                inventoryDashboardData
                                                    .first
                                                    .table0
                                                    .first
                                                    .totalFloors
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
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
                  items: [
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
                          state.inventoryDashboardModel!.table0.first.holdFlats,
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
                  ],
                ),
              ] else ...[
                Center(
                  child: Text(
                    "No Unit Status Distribution Available",
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
                    itemCount: table1.length,
                    shrinkWrap: true,
                    physics: AlwaysScrollableScrollPhysics(),
                    itemBuilder: (context, int index) {
                      final parkingDetails = table1[index];
                      return _buildParkingRow(
                        title: parkingDetails.floorName,
                        used: 100,
                        total: 300,
                      );
                    },
                  ),
                ),
              ] else ...[
                Expanded(
                  child: Center(
                    child: Text(
                      "No Parking Distribution Available",
                      style: AppTextStyle.ts12M(
                        color: AppColor.black.withValues(alpha: 0.50),
                      ),
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
                  itemCount: 3,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, int index) {
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
                          Text("Ratan Nagar 1", style: AppTextStyle.ts14SB()),
                          verticalSpacing(height: 20.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
              ] else ...[
                Center(
                  child: Text(
                    "No Building Overview Available",
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

  Widget _buildOverviewItem(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: AppTextStyle.ts12M(
              color: AppColor.black.withValues(alpha: 0.50),
            ),
          ),
          const SizedBox(height: 4),
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
                ListView.builder(
                  itemCount: 2,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, int index) {
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
              ] else ...[
                Center(
                  child: Text(
                    "No Alerts Available",
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
}
