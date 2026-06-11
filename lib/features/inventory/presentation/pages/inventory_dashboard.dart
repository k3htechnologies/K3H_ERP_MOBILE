// ignore_for_file: unused_local_variable

import 'dart:convert';
import 'dart:developer';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/inventory/data/model/inventory_dashboard.model.dart';
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
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
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
  final ValueNotifier<Map<String, dynamic>?> selectedBuildingNotifier =
      ValueNotifier(null);

  final ValueNotifier<Map<String, dynamic>?> selectedWingNotifier =
      ValueNotifier(null);
  int selectedTab = 1;
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

  Future<void> _navigateToDistribution({
    required String type,
    required String projectName,
    required String buildingNumber,
    required String wing,
    required Map<String, dynamic> queryParams,
    String? status,
    int? count,
  }) async {
    if (count == null || count == 0) {
      return;
    }

    final title = _buildTitle(type: type, status: status, count: count);

    final subTitle = _buildSubTitle(
      projectName: projectName,
      buildingNumber: buildingNumber,
      wing: wing,
    );

    /// REMOVE WING FROM QUERY PARAMS IF TOTAL
    final updatedQueryParams = Map<String, dynamic>.from(queryParams);

    if (wing.toLowerCase() == "total") {
      updatedQueryParams.remove('Wing');
    }

    await _inventoryCubit.resetUnits();

    await goRouter.pushNamed(
      AppRoutes.unitDistributionStatus,
      queryParameters: {
        'type': Uri.encodeComponent(EncryptionManager.encryptData(type)),
        'title': Uri.encodeComponent(EncryptionManager.encryptData(title)),

        'subTitle': Uri.encodeComponent(
          EncryptionManager.encryptData(subTitle),
        ),

        'queryParams': Uri.encodeComponent(
          EncryptionManager.encryptData(jsonEncode(updatedQueryParams)),
        ),

        'projectId': _selectedProject.projectId.toString(),
      },
    );
  }

  String _buildTitle({required String type, String? status, int? count}) {
    final statusText = (status != null && status.isNotEmpty) ? status : "";

    final countText = count != null ? " ($count)" : "";

    return "$statusText $type$countText";
  }

  String _buildSubTitle({
    required String projectName,
    required String buildingNumber,
    required String wing,
  }) {
    if (wing.toLowerCase() == "total") {
      return "$projectName | Bldg: $buildingNumber";
    }

    return "$projectName | Bldg: $buildingNumber | Wing: $wing";
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
            if (state.isLoading ?? true) {
              return loader();
            }

            final inventoryDashboardData = state.inventoryDashboardModelList;

            final table0 =
                inventoryDashboardData.isNotEmpty &&
                        inventoryDashboardData.first.table0.isNotEmpty
                    ? inventoryDashboardData.first.table0.first
                    : null;
            if (table0 == null) {
              return Center(
                child: noDataWidget(message: "No Data Found", iconSize: 180),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: showSiteSelectedWidget(),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                                          table0.totalBuilding.toString(),
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
                                                  color: AppColor.black
                                                      .withValues(alpha: 0.5),
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
                        verticalSpacing(height: 16),
                        // UNIT STATUS DISTRIBUTION WIDGET
                        _buildUnitStatusDistributionWidget(context),
                        verticalSpacing(height: 16),
                        // PARKING DISTRIBUTION WIDGET
                        _buildParkingDistributionWidget(context),
                        verticalSpacing(height: 16),
                        // BUILDING OVERVIEW WIDGET
                        _buildBuildingOverviewWidget(context),
                        verticalSpacing(height: 16),
                        // ATLERT WIDGET
                        _buildAlertsWidget(context),
                        verticalSpacing(height: 16.0),
                        _wingDetailsWidget(context),
                      ],
                    ),
                  ),
                ),
              ],
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
        final blockedUnits =
            state.inventoryDashboardModel!.table0.first.blockedFlats;
        final allotedUnits =
            state.inventoryDashboardModel!.table0.first.allotedFlats;
        final bookedUnits =
            state.inventoryDashboardModel!.table0.first.bookedFlats;
        final holdUnits = state.inventoryDashboardModel!.table0.first.holdFlats;
        final availableUnits =
            state.inventoryDashboardModel!.table0.first.availableFlats;

        final totalUnits =
            availableUnits +
            blockedUnits +
            bookedUnits +
            holdUnits +
            allotedUnits;

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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: CommonRadialChart(
                        items: [
                          RadialChartItem(
                            title: "Blocked Units",
                            value: blockedUnits,
                            color: AppColor.black.withValues(alpha: 0.5),
                            onValueTap:
                                blockedUnits == 0
                                    ? () {}
                                    : () async {
                                      final title =
                                          "Blocked Units ($blockedUnits)";
                                      final queryParams = {
                                        "FlatStatus": "blocked",
                                      };
                                      await _inventoryCubit.resetUnits();
                                      await goRouter.pushNamed(
                                        AppRoutes.unitDistributionStatus,
                                        queryParameters: {
                                          'title': Uri.encodeComponent(
                                            EncryptionManager.encryptData(
                                              title,
                                            ),
                                          ),
                                          'queryParams': Uri.encodeComponent(
                                            EncryptionManager.encryptData(
                                              jsonEncode(queryParams),
                                            ),
                                          ),
                                          'projectId':
                                              _selectedProject.projectId
                                                  .toString(),
                                        },
                                      );
                                    },
                          ),
                          RadialChartItem(
                            title: "Member Units",
                            value: allotedUnits,
                            color: AppColor.purple,
                            onValueTap:
                                allotedUnits == 0
                                    ? () {}
                                    : () async {
                                      final title =
                                          "Member Units ($allotedUnits)";
                                      final queryParams = {
                                        "FlatStatus": "alloted",
                                      };
                                      await _inventoryCubit.resetUnits();
                                      await goRouter.pushNamed(
                                        AppRoutes.unitDistributionStatus,
                                        queryParameters: {
                                          'title': Uri.encodeComponent(
                                            EncryptionManager.encryptData(
                                              title,
                                            ),
                                          ),
                                          'queryParams': Uri.encodeComponent(
                                            EncryptionManager.encryptData(
                                              jsonEncode(queryParams),
                                            ),
                                          ),
                                          'projectId':
                                              _selectedProject.projectId
                                                  .toString(),
                                        },
                                      );
                                    },
                          ),
                          RadialChartItem(
                            title: "Booked Units",
                            value: bookedUnits,
                            color: AppColor.error,
                            onValueTap:
                                bookedUnits == 0
                                    ? () {}
                                    : () async {
                                      final title =
                                          "Booked Units ($bookedUnits)";
                                      final queryParams = {
                                        "FlatStatus": "booked",
                                      };
                                      await _inventoryCubit.resetUnits();
                                      await goRouter.pushNamed(
                                        AppRoutes.unitDistributionStatus,
                                        queryParameters: {
                                          'title': Uri.encodeComponent(
                                            EncryptionManager.encryptData(
                                              title,
                                            ),
                                          ),
                                          'queryParams': Uri.encodeComponent(
                                            EncryptionManager.encryptData(
                                              jsonEncode(queryParams),
                                            ),
                                          ),
                                          'projectId':
                                              _selectedProject.projectId
                                                  .toString(),
                                        },
                                      );
                                    },
                          ),
                          RadialChartItem(
                            title: "Hold Units",
                            value: holdUnits,
                            color: AppColor.yellow,
                            onValueTap:
                                holdUnits == 0
                                    ? () {}
                                    : () async {
                                      final title = "Hold Units ($holdUnits)";
                                      final queryParams = {
                                        "FlatStatus": "hold",
                                      };
                                      await _inventoryCubit.resetUnits();
                                      await goRouter.pushNamed(
                                        AppRoutes.unitDistributionStatus,
                                        queryParameters: {
                                          'title': Uri.encodeComponent(
                                            EncryptionManager.encryptData(
                                              title,
                                            ),
                                          ),
                                          'queryParams': Uri.encodeComponent(
                                            EncryptionManager.encryptData(
                                              jsonEncode(queryParams),
                                            ),
                                          ),
                                          'projectId':
                                              _selectedProject.projectId
                                                  .toString(),
                                        },
                                      );
                                    },
                          ),
                          RadialChartItem(
                            title: "Available Units",
                            onValueTap:
                                availableUnits == 0
                                    ? () {}
                                    : () async {
                                      final title =
                                          "Available Units (${state.inventoryDashboardModel!.table0.first.availableFlats})";
                                      final queryParams = {
                                        "FlatStatus": "available",
                                      };
                                      await _inventoryCubit.resetUnits();
                                      await goRouter.pushNamed(
                                        AppRoutes.unitDistributionStatus,
                                        queryParameters: {
                                          'title': Uri.encodeComponent(
                                            EncryptionManager.encryptData(
                                              title,
                                            ),
                                          ),
                                          'queryParams': Uri.encodeComponent(
                                            EncryptionManager.encryptData(
                                              jsonEncode(queryParams),
                                            ),
                                          ),
                                          'projectId':
                                              _selectedProject.projectId
                                                  .toString(),
                                        },
                                      );
                                    },
                            value: availableUnits,
                            color: AppColor.green,
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      thickness: 0.3,
                      color: AppColor.black.withValues(alpha: 0.5),
                    ),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Total Units",
                            style: AppTextStyle.ts14M(
                              color: AppColor.black.withValues(alpha: 0.5),
                            ),
                          ),
                          TextSpan(
                            text: " : ",
                            style: AppTextStyle.ts14M(
                              color: AppColor.black.withValues(alpha: 0.5),
                            ),
                          ),
                          TextSpan(
                            text: totalUnits.toString(),
                            style: AppTextStyle.ts14SB(
                              color: totalUnits != 0 ? AppColor.primary : null,
                            ),
                            recognizer:
                                TapGestureRecognizer()
                                  ..onTap =
                                      totalUnits == 0
                                          ? () {}
                                          : () async {
                                            final title =
                                                "Total Units ($totalUnits)";

                                            await _inventoryCubit.resetUnits();
                                            await goRouter.pushNamed(
                                              AppRoutes.unitDistributionStatus,
                                              queryParameters: {
                                                'title': Uri.encodeComponent(
                                                  EncryptionManager.encryptData(
                                                    title,
                                                  ),
                                                ),
                                                'queryParams': Uri.encodeComponent(
                                                  EncryptionManager.encryptData(
                                                    jsonEncode({}),
                                                  ),
                                                ),
                                                'projectId':
                                                    _selectedProject.projectId
                                                        .toString(),
                                              },
                                            );
                                          },
                          ),
                        ],
                      ),
                    ),
                  ],
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
                            style: AppTextStyle.ts14R(
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
                            style: AppTextStyle.ts14R(
                              color: AppColor.black.withValues(alpha: 0.50),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                verticalSpacing(height: 20.0),
                ListView.builder(
                  itemCount: table1.length,
                  shrinkWrap: true,
                  physics: BouncingScrollPhysics(),
                  itemBuilder: (context, int index) {
                    final parkingDetails = table1[index];
                    return _buildParkingRow(
                      title: parkingDetails.floorName,
                      used: parkingDetails.availableParking,
                      total: parkingDetails.totalParking,
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

  Widget _buildParkingRow({
    required String title,
    required int used,
    required int total,
  }) {
    final double progress = total == 0 ? 0 : used / total;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title.isEmpty ? '-' : title,
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
          verticalSpacing(),
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: buildColumnTitleValueNormal(
                                      value:
                                          buildingOverview.basement.toString(),
                                      title: "Basement",
                                    ),
                                  ),
                                  horizontalSpacing(),
                                  Expanded(
                                    child: buildColumnTitleValueNormal(
                                      value:
                                          buildingOverview.podiums.toString(),
                                      title: "Podiums",
                                    ),
                                  ),
                                  horizontalSpacing(),
                                  buildColumnTitleValueNormal(
                                    value: buildingOverview.wings.toString(),
                                    title: "Wings",
                                  ),
                                ],
                              ),
                              verticalSpacing(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: buildColumnTitleValueNormal(
                                      value: buildingOverview.floors.toString(),
                                      title: "Floor",
                                    ),
                                  ),
                                  horizontalSpacing(),
                                  Expanded(
                                    child: buildColumnTitleValueNormal(
                                      value: buildingOverview.units.toString(),
                                      title: "Units",
                                    ),
                                  ),
                                  horizontalSpacing(),
                                  buildColumnTitleValueNormal(
                                    value: buildingOverview.parking.toString(),
                                    title: "Parkings",
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
                              style: AppTextStyle.ts16M(),
                            ),
                            verticalSpacing(height: 16.0),
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

  Widget _wingDetailsWidget(BuildContext context) {
    return BlocBuilder<InventoryCubit, InventoryState>(
      builder: (context, state) {
        if (state.isLoading == true) {
          return Center(child: loader());
        }

        final data = state.inventoryDashboardModel;
        final table4 = data?.table4;
        final buildings =
            table4
                ?.map((e) => e.building)
                .toSet()
                .map((e) => {"zAttributesId": e, "DisplayName": e})
                .toList();
        Table4? selectedWingData;
        List<Map<String, dynamic>> getWings(String? building) {
          return table4!
              .where((e) => building == null || e.building == building)
              .map(
                (e) => {
                  "zAttributesId": e.inventoryFlatFloorBasementPodiumWingId,
                  "DisplayName": e.wing,
                },
              )
              .toList();
        }

        if (selectedWingNotifier.value != null) {
          selectedWingData = table4?.firstWhere(
            (e) =>
                e.inventoryFlatFloorBasementPodiumWingId ==
                selectedWingNotifier.value!["zAttributesId"],
          );
        }
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
                      "Wing Details",
                      style: AppTextStyle.ts14M(
                        color: AppColor.black.withValues(alpha: 0.50),
                      ),
                    ),
                  ),
                ],
              ),
              verticalSpacing(),
              if (table4 != null && table4.isNotEmpty) ...[
                Row(
                  children: [
                    Expanded(
                      child: ValueListenableBuilder<Map<String, dynamic>?>(
                        valueListenable: selectedBuildingNotifier,
                        builder: (_, selectedBuilding, __) {
                          return CustomDropDownWidget(
                            title: "Building",
                            hintText: "Select Building",
                            dataList: buildings!,
                            initialValue: selectedBuilding,
                            onSelected: (value) {
                              selectedBuildingNotifier.value = value;
                              selectedWingNotifier.value = null;
                            },
                          );
                        },
                      ),
                    ),

                    horizontalSpacing(),

                    Expanded(
                      child: ValueListenableBuilder<Map<String, dynamic>?>(
                        valueListenable: selectedBuildingNotifier,
                        builder: (_, building, __) {
                          return ValueListenableBuilder<Map<String, dynamic>?>(
                            valueListenable: selectedWingNotifier,
                            builder: (_, wing, __) {
                              return CustomDropDownWidget(
                                title: "Wing",
                                hintText: "Select Wing",
                                dataList: getWings(building?["DisplayName"]),
                                initialValue: wing,
                                onSelected: (value) {
                                  selectedWingNotifier.value = value;
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
                ValueListenableBuilder<Map<String, dynamic>?>(
                  valueListenable: selectedWingNotifier,
                  builder: (context, selectedWing, _) {
                    if (selectedWing == null) {
                      return const SizedBox.shrink();
                    }
                    final selectedWingData = table4.firstWhere(
                      (e) =>
                          e.inventoryFlatFloorBasementPodiumWingId ==
                          selectedWing["zAttributesId"],
                    );
                    final totalCount =
                        selectedTab == 0
                            ? selectedWingData.units
                            : selectedWingData.totalParking;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextField(
                          title: "Total Floors",
                          textController: TextEditingController(
                            text: selectedWingData.floors.toString(),
                          ),
                          readOnly: true,
                        ),
                        Container(
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColor.primary),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedTab = 0;
                                    });
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color:
                                          selectedTab == 0
                                              ? AppColor.lightBlue
                                              : Colors.transparent,
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(8),
                                        bottomLeft: Radius.circular(8),
                                      ),
                                    ),
                                    child: Text(
                                      "Unit",
                                      style: AppTextStyle.ts14M(
                                        color:
                                            selectedTab == 0
                                                ? AppColor.primary
                                                : AppColor.grey,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedTab = 1;
                                    });
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color:
                                          selectedTab == 1
                                              ? AppColor.lightBlue
                                              : Colors.transparent,
                                      borderRadius: const BorderRadius.only(
                                        topRight: Radius.circular(8),
                                        bottomRight: Radius.circular(8),
                                      ),
                                    ),
                                    child: Text(
                                      "Parking",
                                      style: AppTextStyle.ts14M(
                                        color:
                                            selectedTab == 1
                                                ? AppColor.primary
                                                : AppColor.grey,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        verticalSpacing(),
                        buildRowTitleValue(
                          title:
                              selectedTab == 0
                                  ? "Total Units"
                                  : "Total Parking",
                          value: "",
                          customValueWidget: InkWell(
                            onTap:
                                totalCount > 0
                                    ? () {
                                      _navigateToDistribution(
                                        type:
                                            selectedTab == 0
                                                ? "Unit"
                                                : "Parking",
                                        count: totalCount,
                                        projectName:
                                            _selectedProject.projectName,
                                        buildingNumber:
                                            selectedWingData.building,
                                        wing: selectedWingData.wing,
                                        queryParams: {
                                          "BuildingNumber":
                                              selectedWingData.building,
                                          "Wing": selectedWingData.wing,
                                          if (selectedTab == 1)
                                            "IsAcessOnlyApprovedParking": false,
                                        },
                                      );
                                    }
                                    : null,
                            child: Text(
                              totalCount.toString(),
                              style: AppTextStyle.ts14M(
                                color:
                                    totalCount > 0
                                        ? AppColor.primary
                                        : AppColor.grey,
                              ),
                            ),
                          ),
                        ),
                        verticalSpacing(),
                        if (selectedTab == 0) ...[
                          buildProgressRow(
                            title: "Available",
                            value: selectedWingData.availableFlats,
                            total: selectedWingData.units,
                            color: Colors.green,
                            onTap: () {
                              _navigateToDistribution(
                                type: "Unit",
                                status: "Available",
                                count: selectedWingData.availableFlats,
                                projectName: _selectedProject.projectName,
                                buildingNumber: selectedWingData.building,
                                wing: selectedWingData.wing,
                                queryParams: {
                                  "BuildingNumber": selectedWingData.building,
                                  "Wing": selectedWingData.wing,
                                  "FlatStatus": "Available",
                                },
                              );
                            },
                          ),
                          buildProgressRow(
                            title: "Blocked",
                            value: selectedWingData.blockedFlats,
                            total: selectedWingData.units,
                            color: Colors.grey,
                            onTap: () {
                              _navigateToDistribution(
                                type: "Unit",
                                status: "Blocked",
                                count: selectedWingData.blockedFlats,
                                projectName: _selectedProject.projectName,
                                buildingNumber: selectedWingData.building,
                                wing: selectedWingData.wing,
                                queryParams: {
                                  "BuildingNumber": selectedWingData.building,
                                  "Wing": selectedWingData.wing,
                                  "FlatStatus": "Blocked",
                                },
                              );
                            },
                          ),
                          buildProgressRow(
                            title: "Hold",
                            value: selectedWingData.holdFlats,
                            total: selectedWingData.units,
                            color: Colors.orange,
                            onTap: () {
                              _navigateToDistribution(
                                type: "Unit",
                                status: "Hold",
                                count: selectedWingData.holdFlats,
                                projectName: _selectedProject.projectName,
                                buildingNumber: selectedWingData.building,
                                wing: selectedWingData.wing,
                                queryParams: {
                                  "BuildingNumber": selectedWingData.building,
                                  "Wing": selectedWingData.wing,
                                  "FlatStatus": "Hold",
                                },
                              );
                            },
                          ),
                          buildProgressRow(
                            title: "Booked",
                            value: selectedWingData.bookedFlats,
                            total: selectedWingData.units,
                            color: Colors.red,
                            onTap: () {
                              _navigateToDistribution(
                                type: "Unit",
                                status: "Booked",
                                count: selectedWingData.bookedFlats,
                                projectName: _selectedProject.projectName,
                                buildingNumber: selectedWingData.building,
                                wing: selectedWingData.wing,
                                queryParams: {
                                  "BuildingNumber": selectedWingData.building,
                                  "Wing": selectedWingData.wing,
                                  "FlatStatus": "Booked",
                                },
                              );
                            },
                          ),
                          buildProgressRow(
                            title: "Alloted",
                            value: selectedWingData.allotedFlats,
                            total: selectedWingData.units,
                            color: Color(0xff561F64),
                            onTap: () {
                              _navigateToDistribution(
                                type: "Unit",
                                status: "Alloted",
                                count: selectedWingData.allotedFlats,
                                projectName: _selectedProject.projectName,
                                buildingNumber: selectedWingData.building,
                                wing: selectedWingData.wing,
                                queryParams: {
                                  "BuildingNumber": selectedWingData.building,
                                  "Wing": selectedWingData.wing,
                                  "FlatStatus": "Available",
                                },
                              );
                            },
                          ),
                        ] else ...[
                          buildProgressRow(
                            title: "Available",
                            value: selectedWingData.availableParking,
                            total: selectedWingData.totalParking,
                            color: Colors.green,
                            onTap: () {
                              log("message");
                              _navigateToDistribution(
                                type: "Parking",
                                status: "Available",
                                count: selectedWingData.availableParking,
                                projectName: _selectedProject.projectName,
                                buildingNumber: selectedWingData.building,
                                wing: selectedWingData.wing,
                                queryParams: {
                                  "BuildingNumber": selectedWingData.building,
                                  "Wing": selectedWingData.wing,
                                  "FlatStatus": "Available",
                                  "IsAcessOnlyApprovedParking": false,
                                },
                              );
                            },
                          ),
                          buildProgressRow(
                            title: "Blocked",
                            value: selectedWingData.blockedParking,
                            total: selectedWingData.totalParking,
                            color: Colors.grey,
                            onTap: () {
                              _navigateToDistribution(
                                type: "Parking",
                                status: "Blocked",
                                count: selectedWingData.blockedParking,
                                projectName: _selectedProject.projectName,
                                buildingNumber: selectedWingData.building,
                                wing: selectedWingData.wing,
                                queryParams: {
                                  "BuildingNumber": selectedWingData.building,
                                  "Wing": selectedWingData.wing,
                                  "FlatStatus": "Blocked",
                                  "IsAcessOnlyApprovedParking": false,
                                },
                              );
                            },
                          ),
                          buildProgressRow(
                            title: "Hold",
                            value: selectedWingData.holdParking,
                            total: selectedWingData.totalParking,
                            color: Colors.orange,
                            onTap: () {
                              _navigateToDistribution(
                                type: "Parking",
                                status: "Hold",
                                count: selectedWingData.holdParking,
                                projectName: _selectedProject.projectName,
                                buildingNumber: selectedWingData.building,
                                wing: selectedWingData.wing,
                                queryParams: {
                                  "BuildingNumber": selectedWingData.building,
                                  "Wing": selectedWingData.wing,
                                  "FlatStatus": "Hold",
                                  "IsAcessOnlyApprovedParking": false,
                                },
                              );
                            },
                          ),
                          buildProgressRow(
                            title: "Booked",
                            value: selectedWingData.bookedParking,
                            total: selectedWingData.totalParking,
                            color: Colors.red,
                            onTap: () {
                              _navigateToDistribution(
                                type: "Parking",
                                status: "Booked",
                                count: selectedWingData.bookedParking,
                                projectName: _selectedProject.projectName,
                                buildingNumber: selectedWingData.building,
                                wing: selectedWingData.wing,
                                queryParams: {
                                  "BuildingNumber": selectedWingData.building,
                                  "Wing": selectedWingData.wing,
                                  "FlatStatus": "Booked",
                                  "IsAcessOnlyApprovedParking": false,
                                },
                              );
                            },
                          ),
                          buildProgressRow(
                            title: "Member",
                            value: 0,
                            total: selectedWingData.units,
                            color: Color(0xff561F64),
                            onTap: () {
                              _navigateToDistribution(
                                type: "Parking",
                                status: "Member",
                                count: 0,
                                projectName: _selectedProject.projectName,
                                buildingNumber: selectedWingData.building,
                                wing: selectedWingData.wing,
                                queryParams: {
                                  "BuildingNumber": selectedWingData.building,
                                  "Wing": selectedWingData.wing,
                                  "FlatStatus": "Available",
                                },
                              );
                            },
                          ),
                        ],
                      ],
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

  Widget buildProgressRow({
    required String title,
    required int value,
    required int total,
    required Color color,
    Color? valueColor,
    VoidCallback? onTap,
  }) {
    final progress = total == 0 ? 0.0 : value / total;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              title,
              style: AppTextStyle.ts14M(
                color: AppColor.black.withValues(alpha: .5),
              ),
            ),
          ),
          horizontalSpacing(),
          Expanded(
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 17,
              borderRadius: BorderRadius.circular(4),
              backgroundColor: AppColor.grey.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          horizontalSpacing(),
          SizedBox(
            width: 30.0,
            child: InkWell(
              onTap: value > 0 ? onTap : null,
              child: Text(
                value.toString(),
                style: AppTextStyle.ts14M(
                  color: value > 0 ? AppColor.primary : AppColor.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
