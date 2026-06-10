import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/inventory/presentation/cubit/inventory_cubit.dart';
import 'package:k3h_erp_app/features/inventory_reports/data/model/inventory_parking_overall_report.model.dart';
import 'package:k3h_erp_app/features/inventory_reports/presentation/cubit/inventory_report_cubit.dart';
import 'package:k3h_erp_app/features/inventory_reports/presentation/cubit/inventory_report_state.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/chip_style_tab_bar.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class InventoryOverallReportOverview extends StatefulWidget {
  final int projectId;

  const InventoryOverallReportOverview({super.key, required this.projectId});

  @override
  State<InventoryOverallReportOverview> createState() =>
      _InventoryOverallReportOverviewState();
}

class _InventoryOverallReportOverviewState
    extends State<InventoryOverallReportOverview>
    with TickerProviderStateMixin {
  late InventoryReportCubit _inventoryReportCubit;
  late InventoryCubit _inventoryCubit;

  TabController? _tabController;

  /// WING TAB CONTROLLERS
  final Map<String, TabController> _wingTabControllers = {};

  @override
  void initState() {
    super.initState();

    _inventoryReportCubit = context.read<InventoryReportCubit>();
    _inventoryCubit = context.read<InventoryCubit>();

    _inventoryReportCubit.getInventoryOverallReport(
      projectId: widget.projectId,
    );
  }

  @override
  void dispose() {
    _tabController?.dispose();

    for (final controller in _wingTabControllers.values) {
      controller.dispose();
    }

    super.dispose();
  }

  /// BUILDING LIST
  List<String> _getUniqueBuildings(List<InventoryParkingOverallReport> data) {
    return data
        .map((e) => e.buildingNumber)
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();
  }

  /// BUILDING WISE DATA
  List<InventoryParkingOverallReport> _getBuildingWiseData(
    List<InventoryParkingOverallReport> data,
    String building,
  ) {
    return data
        .where((e) => e.buildingNumber.toLowerCase() == building.toLowerCase())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Report Overview",
        authorization: AuthorizationModel(),
      ),

      body: BlocBuilder<InventoryReportCubit, InventoryReportState>(
        builder: (context, state) {
          final reportList = state.reportDetailsList;

          if (state.isLoading ?? true && state.reportDetailsList.isEmpty) {
            return Center(child: loader());
          }

          if (reportList.isEmpty) {
            return Center(child: noDataWidget(message: "No Data Found"));
          }

          /// BUILDING TABS
          final buildings = _getUniqueBuildings(reportList);

          if (_tabController == null ||
              _tabController!.length != buildings.length) {
            _tabController?.dispose();

            _tabController = TabController(
              length: buildings.length,
              vsync: this,
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  reportList.first.projectName,
                  style: AppTextStyle.ts16SB(color: AppColor.primary),
                ),
              ),

              verticalSpacing(height: 10),

              /// BUILDING TAB
              ChipStyleTabBar(
                isSecondaryStyle: false,
                controller: _tabController!,
                tabs: buildings.map((building) => building).toList(),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),

                  child: TabBarView(
                    controller: _tabController,
                    physics: const NeverScrollableScrollPhysics(),

                    children:
                        buildings.map((building) {
                          /// BUILDING WISE DATA
                          final buildingData = _getBuildingWiseData(
                            reportList,
                            building,
                          );

                          /// WING LIST
                          final wings =
                              buildingData
                                  .map((e) => e.wing)
                                  .where((e) => e.isNotEmpty)
                                  .toSet()
                                  .toList();
                          if (!_wingTabControllers.containsKey(building) ||
                              _wingTabControllers[building]!.length !=
                                  wings.length) {
                            _wingTabControllers[building]?.dispose();

                            _wingTabControllers[building] = TabController(
                              length: wings.length,
                              vsync: this,
                            );
                          }

                          final wingTabController =
                              _wingTabControllers[building]!;

                          return Column(
                            children: [
                              /// WING TAB
                              ChipStyleTabBar(
                                isSecondaryStyle: true,
                                controller: wingTabController,
                                tabs: wings.map((wing) => wing).toList(),
                              ),

                              verticalSpacing(height: 12),

                              Expanded(
                                child: TabBarView(
                                  controller: wingTabController,
                                  physics: const NeverScrollableScrollPhysics(),

                                  children:
                                      wings.map((wing) {
                                        /// WING DATA
                                        final wingData =
                                            buildingData
                                                .where(
                                                  (e) =>
                                                      e.wing.toLowerCase() ==
                                                      wing.toLowerCase(),
                                                )
                                                .toList();

                                        if (wingData.isEmpty) {
                                          return const SizedBox.shrink();
                                        }

                                        /// SINGLE ROW DATA
                                        final data = wingData.first;

                                        /// AREA
                                        final totalArea = data.totalReraArea;
                                        final bookedArea = data.bookedReraArea;
                                        final availableArea =
                                            data.availableReraArea;
                                        final blockedArea = data.blockReraArea;
                                        final holdArea = data.holdReraArea;
                                        final allotedArea =
                                            data.allotedReraArea;

                                        /// UNIT
                                        final totalUnit = data.totalUnit;
                                        final bookedUnit = data.bookedUnit;
                                        final availableUnit =
                                            data.availableUnit;
                                        final blockedUnit = data.blockUnit;
                                        final holdUnit = data.holdUnit;
                                        final allotedUnit = data.allotedUnit;

                                        /// PARKING
                                        final totalParking = data.totalParking;
                                        final availableParking =
                                            data.availableParking;
                                        final blockedParking =
                                            data.blockedParking;
                                        final bookedParking =
                                            data.bookedParking;
                                        final holdParking = data.holdParking;
                                        final memberParking =
                                            data.memberParking;

                                        return SingleChildScrollView(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              /// AREA
                                              Container(
                                                decoration:
                                                    commonCardDecoration(),
                                                margin: const EdgeInsets.only(
                                                  bottom: 12,
                                                ),
                                                padding: const EdgeInsets.all(
                                                  14,
                                                ),

                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "RERA Carpet Area (SqFt)",
                                                      style:
                                                          AppTextStyle.ts16SB(),
                                                    ),

                                                    verticalSpacing(height: 5),

                                                    Divider(
                                                      height: 1,
                                                      color: AppColor.grey50,
                                                    ),

                                                    verticalSpacing(height: 5),

                                                    _buildRowTitleValue(
                                                      title: "Total",
                                                      value:
                                                          totalArea.addCommas(),
                                                      valueTextStyle:
                                                          AppTextStyle.ts14SB(
                                                            color:
                                                                totalArea > 0
                                                                    ? AppColor
                                                                        .primary
                                                                    : AppColor
                                                                        .grey,
                                                          ),
                                                      onTap: () {
                                                        _navigateToDistribution(
                                                          type: "Unit",
                                                          status: "Total",
                                                          count: totalUnit,
                                                          projectName:
                                                              wingData
                                                                  .first
                                                                  .projectName,
                                                          buildingNumber:
                                                              building,
                                                          wing: wing,
                                                          queryParams: {
                                                            "BuildingNumber":
                                                                building,
                                                            "Wing": wing,
                                                          },
                                                        );
                                                      },
                                                    ),

                                                    _buildRowTitleValue(
                                                      title: "Alloted",
                                                      value:
                                                          allotedArea
                                                              .addCommas(),
                                                      valueTextStyle:
                                                          AppTextStyle.ts14SB(
                                                            color:
                                                                allotedArea > 0
                                                                    ? AppColor
                                                                        .primary
                                                                    : AppColor
                                                                        .grey,
                                                          ),
                                                      onTap: () {
                                                        _navigateToDistribution(
                                                          type: "Unit",
                                                          status: "Alloted",
                                                          count: allotedUnit,
                                                          projectName:
                                                              wingData
                                                                  .first
                                                                  .projectName,
                                                          buildingNumber:
                                                              building,
                                                          wing: wing,
                                                          queryParams: {
                                                            "BuildingNumber":
                                                                building,
                                                            "Wing": wing,
                                                            "FlatStatus":
                                                                "Alloted",
                                                          },
                                                        );
                                                      },
                                                    ),

                                                    _buildRowTitleValue(
                                                      title: "Booked",
                                                      value:
                                                          bookedArea
                                                              .addCommas(),
                                                      valueTextStyle:
                                                          AppTextStyle.ts14SB(
                                                            color:
                                                                bookedArea > 0
                                                                    ? AppColor
                                                                        .primary
                                                                    : AppColor
                                                                        .grey,
                                                          ),
                                                      onTap: () {
                                                        _navigateToDistribution(
                                                          type: "Unit",
                                                          status: "Booked",
                                                          count: bookedUnit,
                                                          projectName:
                                                              wingData
                                                                  .first
                                                                  .projectName,
                                                          buildingNumber:
                                                              building,
                                                          wing: wing,
                                                          queryParams: {
                                                            "BuildingNumber":
                                                                building,
                                                            "Wing": wing,
                                                            "FlatStatus":
                                                                "Booked",
                                                          },
                                                        );
                                                      },
                                                    ),

                                                    _buildRowTitleValue(
                                                      title: "Hold",
                                                      value:
                                                          holdArea.addCommas(),
                                                      valueTextStyle:
                                                          AppTextStyle.ts14SB(
                                                            color:
                                                                holdArea > 0
                                                                    ? AppColor
                                                                        .primary
                                                                    : AppColor
                                                                        .grey,
                                                          ),
                                                      onTap: () {
                                                        _navigateToDistribution(
                                                          type: "Unit",
                                                          status: "Hold",
                                                          count: holdUnit,
                                                          projectName:
                                                              wingData
                                                                  .first
                                                                  .projectName,
                                                          buildingNumber:
                                                              building,
                                                          wing: wing,
                                                          queryParams: {
                                                            "BuildingNumber":
                                                                building,
                                                            "Wing": wing,
                                                            "FlatStatus":
                                                                "Hold",
                                                          },
                                                        );
                                                      },
                                                    ),

                                                    _buildRowTitleValue(
                                                      title: "Available",
                                                      value:
                                                          availableArea
                                                              .addCommas(),
                                                      valueTextStyle:
                                                          AppTextStyle.ts14SB(
                                                            color:
                                                                availableArea >
                                                                        0
                                                                    ? AppColor
                                                                        .primary
                                                                    : AppColor
                                                                        .grey,
                                                          ),
                                                      onTap: () {
                                                        _navigateToDistribution(
                                                          type: "Unit",
                                                          status: "Available",
                                                          count: availableUnit,
                                                          projectName:
                                                              wingData
                                                                  .first
                                                                  .projectName,
                                                          buildingNumber:
                                                              building,
                                                          wing: wing,
                                                          queryParams: {
                                                            "BuildingNumber":
                                                                building,
                                                            "Wing": wing,
                                                            "FlatStatus":
                                                                "Available",
                                                          },
                                                        );
                                                      },
                                                    ),

                                                    _buildRowTitleValue(
                                                      title: "Blocked",
                                                      value:
                                                          blockedArea
                                                              .addCommas(),

                                                      valueTextStyle:
                                                          AppTextStyle.ts14SB(
                                                            color:
                                                                blockedArea > 0
                                                                    ? AppColor
                                                                        .primary
                                                                    : AppColor
                                                                        .grey,
                                                          ),
                                                      onTap: () {
                                                        _navigateToDistribution(
                                                          type: "Unit",
                                                          status: "Blocked",
                                                          count: blockedUnit,
                                                          projectName:
                                                              wingData
                                                                  .first
                                                                  .projectName,
                                                          buildingNumber:
                                                              building,
                                                          wing: wing,
                                                          queryParams: {
                                                            "BuildingNumber":
                                                                building,
                                                            "Wing": wing,
                                                            "FlatStatus":
                                                                "Blocked",
                                                          },
                                                        );
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              /// UNIT
                                              Container(
                                                decoration:
                                                    commonCardDecoration(),
                                                margin: const EdgeInsets.only(
                                                  bottom: 12,
                                                ),
                                                padding: const EdgeInsets.all(
                                                  14,
                                                ),

                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "Number Of Units",
                                                      style:
                                                          AppTextStyle.ts16SB(),
                                                    ),

                                                    verticalSpacing(height: 5),

                                                    Divider(
                                                      height: 1,
                                                      color: AppColor.grey50,
                                                    ),

                                                    verticalSpacing(height: 5),

                                                    _buildRowTitleValue(
                                                      title: "Total",
                                                      value:
                                                          totalUnit.toString(),
                                                      valueTextStyle:
                                                          AppTextStyle.ts14SB(
                                                            color:
                                                                totalUnit > 0
                                                                    ? AppColor
                                                                        .primary
                                                                    : AppColor
                                                                        .grey,
                                                          ),
                                                      onTap: () {
                                                        _navigateToDistribution(
                                                          type: "Units",
                                                          status: "Total",
                                                          count: totalUnit,
                                                          projectName:
                                                              wingData
                                                                  .first
                                                                  .projectName,
                                                          buildingNumber:
                                                              building,
                                                          wing: wing,
                                                          queryParams: {
                                                            "BuildingNumber":
                                                                building,
                                                            "Wing": wing,
                                                          },
                                                        );
                                                      },
                                                    ),

                                                    _buildRowTitleValue(
                                                      title: "Alloted",
                                                      value:
                                                          allotedUnit
                                                              .toString(),
                                                      valueTextStyle:
                                                          AppTextStyle.ts14SB(
                                                            color:
                                                                allotedUnit > 0
                                                                    ? AppColor
                                                                        .primary
                                                                    : AppColor
                                                                        .grey,
                                                          ),
                                                      onTap: () {
                                                        _navigateToDistribution(
                                                          type: "Units",
                                                          status: "Alloted",
                                                          count: allotedUnit,
                                                          projectName:
                                                              wingData
                                                                  .first
                                                                  .projectName,
                                                          buildingNumber:
                                                              building,
                                                          wing: wing,
                                                          queryParams: {
                                                            "BuildingNumber":
                                                                building,
                                                            "Wing": wing,
                                                            "FlatStatus":
                                                                "Alloted",
                                                          },
                                                        );
                                                      },
                                                    ),

                                                    _buildRowTitleValue(
                                                      title: "Booked",
                                                      value:
                                                          bookedUnit.toString(),
                                                      valueTextStyle:
                                                          AppTextStyle.ts14SB(
                                                            color:
                                                                bookedUnit > 0
                                                                    ? AppColor
                                                                        .primary
                                                                    : AppColor
                                                                        .grey,
                                                          ),
                                                      onTap: () {
                                                        _navigateToDistribution(
                                                          type: "Units",
                                                          status: "Booked",
                                                          count: bookedUnit,
                                                          projectName:
                                                              wingData
                                                                  .first
                                                                  .projectName,
                                                          buildingNumber:
                                                              building,
                                                          wing: wing,
                                                          queryParams: {
                                                            "BuildingNumber":
                                                                building,
                                                            "Wing": wing,
                                                            "FlatStatus":
                                                                "Booked",
                                                          },
                                                        );
                                                      },
                                                    ),

                                                    _buildRowTitleValue(
                                                      title: "Hold",
                                                      value:
                                                          holdUnit.toString(),
                                                      valueTextStyle:
                                                          AppTextStyle.ts14SB(
                                                            color:
                                                                holdUnit > 0
                                                                    ? AppColor
                                                                        .primary
                                                                    : AppColor
                                                                        .grey,
                                                          ),
                                                      onTap: () {
                                                        _navigateToDistribution(
                                                          type: "Units",
                                                          status: "Hold",
                                                          count: holdUnit,
                                                          projectName:
                                                              wingData
                                                                  .first
                                                                  .projectName,
                                                          buildingNumber:
                                                              building,
                                                          wing: wing,
                                                          queryParams: {
                                                            "BuildingNumber":
                                                                building,
                                                            "Wing": wing,
                                                            "FlatStatus":
                                                                "Hold",
                                                          },
                                                        );
                                                      },
                                                    ),

                                                    _buildRowTitleValue(
                                                      title: "Available",
                                                      value:
                                                          availableUnit
                                                              .toString(),
                                                      valueTextStyle:
                                                          AppTextStyle.ts14SB(
                                                            color:
                                                                availableUnit >
                                                                        0
                                                                    ? AppColor
                                                                        .primary
                                                                    : AppColor
                                                                        .grey,
                                                          ),
                                                      onTap: () {
                                                        _navigateToDistribution(
                                                          type: "Units",
                                                          status: "Available",
                                                          count: availableUnit,
                                                          projectName:
                                                              wingData
                                                                  .first
                                                                  .projectName,
                                                          buildingNumber:
                                                              building,
                                                          wing: wing,
                                                          queryParams: {
                                                            "BuildingNumber":
                                                                building,
                                                            "Wing": wing,
                                                            "FlatStatus":
                                                                "Available",
                                                          },
                                                        );
                                                      },
                                                    ),

                                                    _buildRowTitleValue(
                                                      title: "Blocked",
                                                      value:
                                                          blockedUnit
                                                              .toString(),
                                                      valueTextStyle:
                                                          AppTextStyle.ts14SB(
                                                            color:
                                                                blockedUnit > 0
                                                                    ? AppColor
                                                                        .primary
                                                                    : AppColor
                                                                        .grey,
                                                          ),
                                                      onTap: () {
                                                        _navigateToDistribution(
                                                          type: "Units",
                                                          status: "Blocked",
                                                          count: blockedUnit,
                                                          projectName:
                                                              wingData
                                                                  .first
                                                                  .projectName,
                                                          buildingNumber:
                                                              building,
                                                          wing: wing,
                                                          queryParams: {
                                                            "BuildingNumber":
                                                                building,
                                                            "Wing": wing,
                                                            "FlatStatus":
                                                                "Blocked",
                                                          },
                                                        );
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              /// PARKING
                                              Container(
                                                decoration:
                                                    commonCardDecoration(),
                                                margin: const EdgeInsets.only(
                                                  bottom: 12,
                                                ),
                                                padding: const EdgeInsets.all(
                                                  14,
                                                ),

                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "Number Of Parking",
                                                      style:
                                                          AppTextStyle.ts16SB(),
                                                    ),

                                                    verticalSpacing(height: 5),

                                                    Divider(
                                                      height: 1,
                                                      color: AppColor.grey50,
                                                    ),

                                                    verticalSpacing(height: 5),

                                                    _buildRowTitleValue(
                                                      title: "Total",
                                                      value:
                                                          totalParking
                                                              .toString(),
                                                      valueTextStyle:
                                                          AppTextStyle.ts14SB(
                                                            color:
                                                                totalParking > 0
                                                                    ? AppColor
                                                                        .primary
                                                                    : AppColor
                                                                        .grey,
                                                          ),
                                                      onTap: () {
                                                        _navigateToDistribution(
                                                          type: "Parking",
                                                          status: "Total",
                                                          count: totalParking,
                                                          projectName:
                                                              wingData
                                                                  .first
                                                                  .projectName,
                                                          buildingNumber:
                                                              building,
                                                          wing: wing,
                                                          queryParams: {
                                                            "BuildingNumber":
                                                                building,
                                                            "Wing": wing,
                                                            "IsAcessOnlyApprovedParking":
                                                                false,
                                                          },
                                                        );
                                                      },
                                                    ),

                                                    _buildRowTitleValue(
                                                      title: "Available",
                                                      value:
                                                          availableParking
                                                              .toString(),
                                                      valueTextStyle:
                                                          AppTextStyle.ts14SB(
                                                            color:
                                                                availableParking >
                                                                        0
                                                                    ? AppColor
                                                                        .primary
                                                                    : AppColor
                                                                        .grey,
                                                          ),
                                                      onTap: () {
                                                        _navigateToDistribution(
                                                          type: "Parking",
                                                          status: "Available",
                                                          count:
                                                              availableParking,
                                                          projectName:
                                                              wingData
                                                                  .first
                                                                  .projectName,
                                                          buildingNumber:
                                                              building,
                                                          wing: wing,
                                                          queryParams: {
                                                            "BuildingNumber":
                                                                building,
                                                            "Wing": wing,
                                                            "FlatStatus":
                                                                "Available",
                                                            "IsAcessOnlyApprovedParking":
                                                                false,
                                                          },
                                                        );
                                                      },
                                                    ),

                                                    _buildRowTitleValue(
                                                      title: "Blocked",
                                                      value:
                                                          blockedParking
                                                              .toString(),
                                                      valueTextStyle:
                                                          AppTextStyle.ts14SB(
                                                            color:
                                                                blockedParking >
                                                                        0
                                                                    ? AppColor
                                                                        .primary
                                                                    : AppColor
                                                                        .grey,
                                                          ),
                                                      onTap: () {
                                                        _navigateToDistribution(
                                                          type: "Parking",
                                                          status: "Blocked",
                                                          count: blockedParking,
                                                          projectName:
                                                              wingData
                                                                  .first
                                                                  .projectName,
                                                          buildingNumber:
                                                              building,
                                                          wing: wing,
                                                          queryParams: {
                                                            "BuildingNumber":
                                                                building,
                                                            "Wing": wing,
                                                            "FlatStatus":
                                                                "Blocked",
                                                            "IsAcessOnlyApprovedParking":
                                                                false,
                                                          },
                                                        );
                                                      },
                                                    ),

                                                    _buildRowTitleValue(
                                                      title: "Booked",
                                                      value:
                                                          bookedParking
                                                              .toString(),
                                                      valueTextStyle:
                                                          AppTextStyle.ts14SB(
                                                            color:
                                                                bookedParking >
                                                                        0
                                                                    ? AppColor
                                                                        .primary
                                                                    : AppColor
                                                                        .grey,
                                                          ),
                                                      onTap: () {
                                                        _navigateToDistribution(
                                                          type: "Parking",
                                                          status: "Booked",
                                                          count: bookedParking,
                                                          projectName:
                                                              wingData
                                                                  .first
                                                                  .projectName,
                                                          buildingNumber:
                                                              building,
                                                          wing: wing,
                                                          queryParams: {
                                                            "BuildingNumber":
                                                                building,
                                                            "Wing": wing,
                                                            "FlatStatus":
                                                                "Booked",
                                                            "IsAcessOnlyApprovedParking":
                                                                false,
                                                          },
                                                        );
                                                      },
                                                    ),

                                                    _buildRowTitleValue(
                                                      title: "Hold",
                                                      value:
                                                          holdParking
                                                              .toString(),
                                                      valueTextStyle:
                                                          AppTextStyle.ts14SB(
                                                            color:
                                                                holdParking > 0
                                                                    ? AppColor
                                                                        .primary
                                                                    : AppColor
                                                                        .grey,
                                                          ),
                                                      onTap: () {
                                                        _navigateToDistribution(
                                                          type: "Parking",
                                                          status: "Hold",
                                                          count: holdParking,
                                                          projectName:
                                                              wingData
                                                                  .first
                                                                  .projectName,
                                                          buildingNumber:
                                                              building,
                                                          wing: wing,
                                                          queryParams: {
                                                            "BuildingNumber":
                                                                building,
                                                            "Wing": wing,
                                                            "FlatStatus":
                                                                "Hold",
                                                            "IsAcessOnlyApprovedParking":
                                                                false,
                                                          },
                                                        );
                                                      },
                                                    ),

                                                    _buildRowTitleValue(
                                                      title: "Member",
                                                      value:
                                                          memberParking
                                                              .toString(),
                                                      valueTextStyle:
                                                          AppTextStyle.ts14SB(
                                                            color:
                                                                memberParking >
                                                                        0
                                                                    ? AppColor
                                                                        .primary
                                                                    : AppColor
                                                                        .grey,
                                                          ),
                                                      onTap: () {
                                                        _navigateToDistribution(
                                                          type: "Parking",
                                                          status: "Member",
                                                          count: memberParking,
                                                          projectName:
                                                              wingData
                                                                  .first
                                                                  .projectName,
                                                          buildingNumber:
                                                              building,
                                                          wing: wing,
                                                          queryParams: {
                                                            "BuildingNumber":
                                                                building,
                                                            "Wing": wing,
                                                            "FlatStatus":
                                                                "Member",
                                                            "IsAcessOnlyApprovedParking":
                                                                false,
                                                          },
                                                        );
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRowTitleValue({
    required String title,
    required String value,
    TextStyle? valueTextStyle,
    bool singleLine = true,
    VoidCallback? onTap,
  }) {
    return buildRowTitleValue(
      fixesWidth: 180.w,
      title: title,
      value: value,
      customValueWidget: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            value.isNotEmpty ? value : "-",
            maxLines: singleLine ? 1 : null,
            overflow: singleLine ? TextOverflow.ellipsis : TextOverflow.visible,
            style: valueTextStyle ?? AppTextStyle.ts14M(),
          ),
        ),
      ),
    );
  }

  String _buildSubTitle({
    required String projectName,
    required String buildingNumber,
    required String wing,
  }) {
    final base = "$projectName | Bldg: $buildingNumber | Wing: $wing";

    return base;
  }

  String _buildTitle({required String type, String? status, int? count}) {
    final statusText = (status != null && status.isNotEmpty) ? status : "";

    final countText = count != null ? " ($count)" : "";

    return "$statusText $type$countText";
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

        'projectId': widget.projectId.toString(),
      },
    );
  }
}
