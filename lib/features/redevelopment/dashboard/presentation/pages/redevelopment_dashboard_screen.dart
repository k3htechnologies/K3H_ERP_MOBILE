import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/redevelopment/building/data/model/building.model.dart';
import 'package:k3h_erp_app/features/redevelopment/building/data/repository/building.repository.dart';
import 'package:k3h_erp_app/features/redevelopment/dashboard/data/model/redevelopment_dashboard.model.dart';
import 'package:k3h_erp_app/features/redevelopment/dashboard/presentation/cubit/redevlopment_dashboard_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/charts/custom_radial_chart.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_multi_select_pop_up.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class RedevelopmentDashboardScreen extends StatefulWidget {
  const RedevelopmentDashboardScreen({super.key});

  @override
  State<RedevelopmentDashboardScreen> createState() =>
      _RedevelopmentDashboardScreenState();
}

class _RedevelopmentDashboardScreenState
    extends State<RedevelopmentDashboardScreen> {
  // REDEVELOPMENT  REPOSITORY
  final BuildingRepository _buildingRepository =
      serviceLocator<BuildingRepository>();

  // CUBIT
  late RedevlopmentDashboardCubit _redevelopmentDashboardCubit;

  List<Map<String, dynamic>> selectedBuilding = [];
  int selectedAreaIndex = 0;

  @override
  void initState() {
    super.initState();
    _redevelopmentDashboardCubit = context.read<RedevlopmentDashboardCubit>();

    final project = getProject();
    _redevelopmentDashboardCubit.getRedevelopmentDashboardList(
      context,
      project.projectId,
    );
  }

  // FETCH BUILDING LIST
  Future<Map<String, dynamic>> _fetchBuildingList(
    int pageNumber, {
    String? value,
    int? projectId,
  }) async {
    try {
      final result = await _buildingRepository.pullBuilding(
        pageNumber: pageNumber,
        pageSize: 15,
        projectId: getProject().projectId,
        queryParams:
            value != null && value.isNotEmpty ? {"BuildingName": value} : null,
      );

      return result.fold(
        (failure) => {'itemList': [], 'totalNumberOfRecord': 0},
        (response) {
          final buildings =
              response['data'] as List<RedevelopmentBuildingModel>;
          final itemList =
              buildings
                  .map(
                    (c) => {
                      'zAttributesId': c.buildingId,
                      'DisplayName': c.buildingName,
                    },
                  )
                  .toList();

          return {
            'itemList': itemList,
            'totalNumberOfRecord':
                response['totalNumberOfRecord'] ?? itemList.length,
          };
        },
      );
    } catch (error) {
      return {'itemList': [], 'totalNumberOfRecord': 0};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.lightGreyBackground,
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Redevelopment",
        isMenuButton: true,
        authorization: AuthorizationModel(),
        onProjectChangeCallback: (value) {
          _redevelopmentDashboardCubit.getRedevelopmentDashboardList(
            context,
            getProject().projectId,
          );
        },
        showNotification: true,
      ),
      body: BlocBuilder<RedevlopmentDashboardCubit, RedevlopmentDashboardState>(
        builder: (context, state) {
          if (state.isLoading == true) {
            return Center(child: loader());
          }
          final data = state.redevelopmentDashboardModel;

          if (data == null) {
            return const Center(child: Text("No data available"));
          }

          final table0 = data.table0;
          final table4 = data.table4;
          final table1 = data.table1;

          final selectedBuildingName =
              selectedBuilding.isNotEmpty
                  ? selectedBuilding.first['DisplayName'] as String?
                  : null;

          final filteredTable0 =
              selectedBuildingName == null
                  ? table0
                  : table0
                      .where((e) => e.buildingName == selectedBuildingName)
                      .toList();

          final filteredTable4 =
              selectedBuildingName == null
                  ? table4
                  : table4
                      .where((e) => e.buildingName == selectedBuildingName)
                      .toList();

          final buildingCount =
              selectedBuildingName == null
                  ? table0.map((e) => e.buildingName).toSet().length
                  : (filteredTable4.isNotEmpty ? 1 : 0);

          final alertsCount = filteredTable4.length;

          final totalPlotArea = filteredTable0.fold<double>(
            0,
            (sum, item) => sum + (item.totalPlotAreaSqFt.toDouble()),
          );
          final totalAmount = table1.fold<double>(
            0,
            (sum, item) => sum + (item.amount.toDouble()),
          );
          final totalPaid = table1.fold<double>(
            0,
            (sum, item) => sum + (item.paid.toDouble()),
          );
          final pendingAmount = totalAmount - totalPaid;
          final pendingAmountInCr = pendingAmount / 10000000;
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ACCORDING TO PROJECT BUILDING WILL BE DISPLAYED
                  CustomMultipleSelectPopup(
                    isMultiSelect: false,
                    initialValue: selectedBuilding,
                    dataList: [],
                    dataFetchCallBack: _fetchBuildingList,
                    onSelected: (selectedValue) {
                      setState(() {
                        selectedBuilding = selectedValue;
                      });
                      int buildingId = 0;
                      if (selectedValue.isNotEmpty) {
                        buildingId =
                            selectedValue.first['zAttributesId'] as int;
                      }
                      _redevelopmentDashboardCubit
                          .getRedevelopmentDashboardList(
                            context,
                            getProject().projectId,
                            buildingId: buildingId,
                          );
                    },
                  ),
                  // GENERATE REPORT AND VIEW PROJECT BUTTONS
                  Row(
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
                      Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 5.0,
                          horizontal: 12.0,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6.0),
                          color: AppColor.green.withValues(alpha: 0.3),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.remove_red_eye_outlined,
                              color: AppColor.green,
                              size: 16,
                            ),
                            horizontalSpacing(),
                            Text(
                              "Project Plan",
                              style: AppTextStyle.ts14M(color: AppColor.green),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  verticalSpacing(),
                  // BUILDING COUNT WIDGET
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 16.0,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      color: AppColor.white,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SvgPicture.asset(
                          AppAssets.buildingCountIcon,
                          width: 32,
                          height: 32,
                        ),
                        horizontalSpacing(width: 20.0),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Building Count", style: AppTextStyle.ts14M()),
                            verticalSpacing(height: 6.0),
                            Text(
                              "Total Plot Area :${totalPlotArea.toStringAsFixed(2)} SqMt",
                              style: AppTextStyle.ts12R(
                                color: AppColor.black.withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                        Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              buildingCount.toString(),
                              style: AppTextStyle.ts20SB(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  verticalSpacing(),
                  // FINANCIAL COUNT WIDGET
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 16.0,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      color: AppColor.white,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SvgPicture.asset(
                          AppAssets.financialRentIcon,
                          width: 32,
                          height: 32,
                        ),
                        horizontalSpacing(width: 20.0),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Financial (Rent)",
                              style: AppTextStyle.ts14M(),
                            ),
                            verticalSpacing(height: 6.0),
                            Text(
                              "Pending : ₹ $pendingAmountInCr CR",
                              style: AppTextStyle.ts12R(
                                color: AppColor.black.withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                        Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              pendingAmountInCr.toString(),
                              style: AppTextStyle.ts20SB(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  verticalSpacing(),
                  // ALERT COUNT WIDGET
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 16.0,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      color: AppColor.white,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SvgPicture.asset(
                          AppAssets.alerttIcon,
                          width: 32,
                          height: 32,
                        ),
                        horizontalSpacing(width: 20.0),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Alert", style: AppTextStyle.ts14M()),
                            verticalSpacing(height: 6.0),
                            Text(
                              "Requires Actions",
                              style: AppTextStyle.ts12R(
                                color: AppColor.black.withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                        Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              alertsCount.toString(),
                              style: AppTextStyle.ts20SB(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  verticalSpacing(),
                  // PROJECT PROGRESS WIDGET
                  _buildProjectProgressWidget(context),
                  verticalSpacing(),
                  // FINANCIAL OVERVIEW WIDGET
                  _buildFinancialOverviewWidget(context),
                  verticalSpacing(),
                  // AREA UTILIZATION SUMMARY WIDGET
                  _buildAreaUtilizationSummaryWidget(context),
                  verticalSpacing(),
                  // TENANT OVERVIEW WIDGET (RESIDENTIAL AND COMMERCIAL COUNT)
                  _buildTenantOverviewWidget(context),
                  verticalSpacing(),
                  // BUILDING DETAILS WIDGET
                  _buildBuildingDetailsWidget(context),
                  verticalSpacing(),
                  // ALERT WIDGET
                  _buildAlertsWidget(context),
                  verticalSpacing(),
                  // PROPOSED PLAN WIDGET (NO. OF FLOORS, UNITS AND TOTAL PARKING, BUILDING TYPE PLANS)
                  _buildProposedPlanWidget(context),
                  verticalSpacing(),
                  // AMENITIES WIDGET
                  _buildProposedOfferWidget(context),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // BUILD PROJECT PROGRESS WIDGET
  Widget _buildProjectProgressWidget(BuildContext context) {
    final steps = [
      ProjectProgressStep(
        title: "Project Onboarding",
        percentage: 100,
        status: "Completed",
      ),
      ProjectProgressStep(
        title: "Tenant Data",
        percentage: 100,
        status: "Completed",
      ),
      ProjectProgressStep(title: "Offer", percentage: 100, status: "Completed"),
      ProjectProgressStep(
        title: "Plan Data",
        percentage: 56,
        status: "In Progress",
      ),
      ProjectProgressStep(title: "Execution", percentage: 0, status: "Pending"),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: commonCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Project Progress",
            style: AppTextStyle.ts14M(
              color: AppColor.black.withValues(alpha: 0.5),
            ),
          ),
          verticalSpacing(height: 20.0),
          Stack(
            children: [
              Column(
                children: List.generate(steps.length, (index) {
                  final step = steps[index];
                  final isBeforeOrEqualPlanData = index < 3;
                  final isLast = index == steps.length - 1;
                  return _buildProgressStep(
                    step: step,
                    isLast: isLast,
                    isCompletedLine: isBeforeOrEqualPlanData,
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // BUILD PROGRESS STEPS
  Widget _buildProgressStep({
    required ProjectProgressStep step,
    required bool isLast,
    required bool isCompletedLine,
  }) {
    Color circleColor;
    Widget circleChild;

    switch (step.status) {
      case "Completed":
        circleColor = AppColor.primary;
        circleChild = const Icon(Icons.check, color: Colors.white, size: 14);
        break;

      case "In Progress":
        circleColor = AppColor.purple20.withValues(alpha: 1);
        circleChild = Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        );
        break;

      default:
        circleColor = AppColor.lightBlue;
        circleChild = const SizedBox.shrink();
    }

    final lineColor = isCompletedLine ? AppColor.primary : AppColor.lightBlue;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: circleColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.black.withValues(alpha: 0.2),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Center(child: circleChild),
              ),

              if (!isLast)
                Expanded(
                  child: Container(
                    width: 4,
                    decoration: BoxDecoration(
                      color: lineColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
            ],
          ),
          horizontalSpacing(width: 16),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step.title,
                          style: AppTextStyle.ts14R(
                            color:
                                step.status == "Pending"
                                    ? AppColor.black.withValues(alpha: 0.35)
                                    : AppColor.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${step.percentage}%",
                          style: AppTextStyle.ts12SB(
                            color: AppColor.black.withValues(alpha: 0.50),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(step.status),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // BUILD STATUS CHIP
  Widget _buildStatusChip(String status) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case "Completed":
        bgColor = AppColor.green.withValues(alpha: 0.1);
        textColor = AppColor.green;
        break;
      case "In Progress":
        bgColor = AppColor.primary.withValues(alpha: 0.1);
        textColor = AppColor.primary;
        break;
      default:
        bgColor = AppColor.black.withValues(alpha: 0.1);
        textColor = AppColor.black.withValues(alpha: 0.2);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(status, style: AppTextStyle.ts12M(color: textColor)),
    );
  }

  // BUILD FINANCIAL OVERVIEW WIDGET
  Widget _buildFinancialOverviewWidget(BuildContext context) {
    return BlocBuilder<RedevlopmentDashboardCubit, RedevlopmentDashboardState>(
      builder: (context, state) {
        if (state.isLoading == true) {
          return loader();
        }
        final staticList = [
          "Corpus",
          "Brokerage",
          "Additional Rent",
          "Rent",
          "Shifting",
        ];
        final data = state.redevelopmentDashboardModel;

        if (data == null) {
          return const Center(child: Text("No data available"));
        }
        final table1 = data.table1;
        final totalAmount = table1.fold<double>(
          0,
          (sum, item) => sum + (item.amount.toDouble()),
        );
        final totalPaid = table1.fold<double>(
          0,
          (sum, item) => sum + (item.paid.toDouble()),
        );
        final pendingAmount = totalAmount - totalPaid;
        final pendingAmountInCr = pendingAmount / 10000000;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: commonCardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "Financial Overview",
                    style: AppTextStyle.ts14M(
                      color: AppColor.black.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
              verticalSpacing(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: AppColor.lightBlue.withValues(alpha: 0.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total Financial Exposure",
                      style: AppTextStyle.ts14M(color: AppColor.black),
                    ),
                    Spacer(),
                    Text(
                      " ₹ $pendingAmountInCr Cr",
                      style: AppTextStyle.ts16M(color: AppColor.black),
                    ),
                  ],
                ),
              ),
              verticalSpacing(),
              _leaveRow(title: "Paid", value: "₹ 0.0"),
              _leaveRow(title: "Pending", value: "₹ $pendingAmountInCr Cr"),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.6,
                ),
                itemCount: table1.length,
                itemBuilder: (context, index) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 12.0,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      color: AppColor.lightGreyBackground,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          staticList[index],
                          style: AppTextStyle.ts14M(
                            color: AppColor.black.withValues(alpha: 0.5),
                          ),
                        ),
                        verticalSpacing(height: 6),
                        Text(
                          "₹ ${table1[index].amount}",
                          style: AppTextStyle.ts14M(),
                        ),
                        verticalSpacing(height: 6),
                        Text(
                          "0 % Of Total",
                          style: AppTextStyle.ts10M(
                            color: AppColor.black.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // LEAVE ROW WIDGET
  Widget _leaveRow({required String title, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12.0),
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: Text(
              title,
              style: AppTextStyle.ts14M(
                color: AppColor.black.withValues(alpha: 0.5),
              ),
            ),
          ),
          SizedBox(
            width: 24,
            child: Center(
              child: Text(
                ":",
                style: AppTextStyle.ts14M(
                  color: AppColor.black.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(value, style: AppTextStyle.ts14M()),
            ),
          ),
        ],
      ),
    );
  }

  // BUILD AREA UTILIZATION SUMMARY WIDGET
  Widget _buildAreaUtilizationSummaryWidget(BuildContext context) {
    return BlocBuilder<RedevlopmentDashboardCubit, RedevlopmentDashboardState>(
      builder: (context, state) {
        if (state.isLoading == true) {
          return loader();
        }

        final data = state.redevelopmentDashboardModel;

        if (data == null) {
          return const Center(child: Text("No data available"));
        }
        final table3 = data.table3;

        final existingCarpetArea = table3.fold<double>(
          0.0,
          (sum, item) => sum + (item.flatCarpetAreaSqFt.toDouble()),
        );

        final freeAreaOffered = table3.fold<double>(
          0.0,
          (sum, item) => sum + (item.freeAreaOfferedPercent.toDouble()),
        );
        final extraAreaPurchased = table3.fold<double>(
          0.0,
          (sum, item) => sum + (item.extraAreaPurchasedSqFt.toDouble()),
        );
        final totalArea =
            existingCarpetArea + freeAreaOffered + extraAreaPurchased;

        final existingPercent =
            totalArea == 0 ? 0 : (existingCarpetArea / totalArea) * 100;

        final freePercent =
            totalArea == 0 ? 0 : (freeAreaOffered / totalArea) * 100;

        final extraPercent =
            totalArea == 0 ? 0 : (extraAreaPurchased / totalArea) * 100;
        final chartData = <_AreaChartModel>[
          _AreaChartModel(existingPercent.toDouble(), "Existing Carpet Area"),
          _AreaChartModel(freePercent.toDouble(), "Free Area Offered"),
          _AreaChartModel(extraPercent.toDouble(), "Extra Area Purchased"),
        ];

        final maxValue =
            chartData.isEmpty
                ? 0.0
                : chartData.map((e) => e.value).reduce((a, b) => a > b ? a : b);

        final safeMax = maxValue <= 0 ? 10 : maxValue * 1.2;
        final safeInterval = maxValue <= 0 ? 2 : (safeMax / 4);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: commonCardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "Area Utilization Summary",
                    style: AppTextStyle.ts14M(
                      color: AppColor.black.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
              verticalSpacing(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _legendItem(
                              AppColor.primary,
                              "Existing Carpet Area",
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            _legendItem(Colors.green, "Free Area Offered"),
                          ],
                        ),
                        Row(
                          children: [
                            _legendItem(Colors.orange, "Extra Area Purchased"),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              verticalSpacing(),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SfCartesianChart(
                  tooltipBehavior: TooltipBehavior(
                    enable: true,
                    format: 'point.x : point.y Sq.Ft',
                  ),
                  plotAreaBorderWidth: 0,
                  primaryXAxis: CategoryAxis(
                    majorGridLines: const MajorGridLines(width: 0),
                    labelAlignment: LabelAlignment.center,
                    labelIntersectAction: AxisLabelIntersectAction.wrap,
                    axisLabelFormatter: (AxisLabelRenderDetails details) {
                      Color dotColor = AppColor.primary;

                      if (details.text.contains("Existing")) {
                        dotColor = AppColor.primary;
                      } else if (details.text.contains("Free")) {
                        dotColor = Colors.green;
                      } else if (details.text.contains("Extra")) {
                        dotColor = Colors.orange;
                      }

                      return ChartAxisLabel(
                        "●",
                        TextStyle(
                          color: dotColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                  primaryYAxis: NumericAxis(
                    minimum: 0,
                    maximum: safeMax.toDouble(),
                    interval: safeInterval.toDouble(),
                    labelAlignment: LabelAlignment.center,
                    opposedPosition: false,
                    majorGridLines: const MajorGridLines(width: 0),
                    axisLine: const AxisLine(width: 1),
                    majorTickLines: const MajorTickLines(size: 6),
                    labelStyle: AppTextStyle.ts12M(
                      color: AppColor.black.withValues(alpha: 0.5),
                    ),
                  ),
                  series: <CartesianSeries>[
                    ColumnSeries<_AreaChartModel, String>(
                      dataSource: chartData,
                      xValueMapper: (data, _) => data.label,
                      yValueMapper: (data, _) => data.value,
                      width: 0.35,
                      borderRadius: const BorderRadius.all(Radius.circular(6)),
                      pointColorMapper: (data, _) {
                        switch (data.label) {
                          case "Existing Carpet Area":
                            return AppColor.primary;
                          case "Free Area Offered":
                            return Colors.green;
                          case "Extra Area Purchased":
                            return Colors.orange;
                          default:
                            return AppColor.black.withValues(alpha: 0.50);
                        }
                      },
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

  // LEGEND ITEM WIDGET
  Widget _legendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: AppTextStyle.ts10M(
            color: AppColor.black.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  // BUILD TENANT OVERVIEW WIDGET
  Widget _buildTenantOverviewWidget(BuildContext context) {
    return BlocBuilder<RedevlopmentDashboardCubit, RedevlopmentDashboardState>(
      builder: (context, state) {
        if (state.isLoading == true) {
          return loader();
        }

        final data = state.redevelopmentDashboardModel;

        if (data == null) {
          return const Center(child: Text("No data available"));
        }
        final table3 = data.table3;
        final residentialCount =
            table3
                .where(
                  (e) => (e.flatType).toLowerCase().contains("residential"),
                )
                .length;
        final commercialCount =
            table3
                .where((e) => (e.flatType).toLowerCase().contains("commercial"))
                .length;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: commonCardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "Tenant Overview",
                    style: AppTextStyle.ts14M(
                      color: AppColor.black.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
              verticalSpacing(),
              CommonRadialChart(
                items: [
                  RadialChartItem(
                    title: "Present",
                    value: residentialCount,
                    color: AppColor.primary,
                  ),
                  RadialChartItem(
                    title: "Present",
                    value: commercialCount,
                    color: AppColor.blueBgColor,
                  ),
                ],
              ),
              verticalSpacing(height: 20.0),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 12.0,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        color: AppColor.primary,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Residential",
                            style: AppTextStyle.ts16M(color: AppColor.white),
                          ),
                          verticalSpacing(height: 4.0),
                          Text(
                            residentialCount.toString(),
                            style: AppTextStyle.ts16B(color: AppColor.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  horizontalSpacing(),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 12.0,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        color: AppColor.blueBgColor,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Commercial",
                            style: AppTextStyle.ts16M(color: AppColor.white),
                          ),
                          verticalSpacing(height: 4.0),
                          Text(
                            commercialCount.toString(),
                            style: AppTextStyle.ts16B(color: AppColor.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // BUILD BUILDING DETAILS WIDGET
  Widget _buildBuildingDetailsWidget(BuildContext context) {
    return BlocBuilder<RedevlopmentDashboardCubit, RedevlopmentDashboardState>(
      builder: (context, state) {
        if (state.isLoading == true) {
          return loader();
        }
        final data = state.redevelopmentDashboardModel;
        if (data == null) {
          return const Center(child: Text("No data available"));
        }
        final buildings = data.table0;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: commonCardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "Building Details",
                    style: AppTextStyle.ts14M(
                      color: AppColor.black.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
              verticalSpacing(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        "Name",
                        style: AppTextStyle.ts12M(
                          color: AppColor.black.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        "Plot Area (Sq.Ft)",
                        textAlign: TextAlign.center,
                        style: AppTextStyle.ts12M(
                          color: AppColor.black.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        "CTS Number",
                        textAlign: TextAlign.end,
                        style: AppTextStyle.ts12M(
                          color: AppColor.black.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ListView.separated(
                itemCount: buildings.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                separatorBuilder:
                    (_, __) => Divider(
                      height: 16,
                      color: AppColor.black.withValues(alpha: 0.08),
                    ),
                itemBuilder: (context, index) {
                  final building = buildings[index];
                  return Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          building.buildingName,
                          style: AppTextStyle.ts14M(color: AppColor.black),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          (building.totalPlotAreaSqFt).toStringAsFixed(0),
                          textAlign: TextAlign.center,
                          style: AppTextStyle.ts14M(color: AppColor.black),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          building.ctsNumber,
                          textAlign: TextAlign.end,
                          style: AppTextStyle.ts14M(color: AppColor.black),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // BUILD ALERT WIDGET
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
          SizedBox(
            height: 250.0,
            child: ListView.builder(
              itemCount: 4,
              shrinkWrap: true,
              physics: AlwaysScrollableScrollPhysics(),
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
                      Text("Invalid GST", style: AppTextStyle.ts16M()),
                      verticalSpacing(),
                      Text(
                        "4 Commercial Tenant",
                        style: AppTextStyle.ts14R(
                          color: AppColor.black.withValues(alpha: 0.50),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // BUILD PROPOSED PLAN WIDGET
  Widget _buildProposedPlanWidget(BuildContext context) {
    return BlocBuilder<RedevlopmentDashboardCubit, RedevlopmentDashboardState>(
      builder: (context, state) {
        if (state.isLoading == true) {
          return loader();
        }
        final data = state.redevelopmentDashboardModel;
        if (data == null) {
          return const Center(child: Text("No data available"));
        }
        final table2 = data.table2;
        if (table2.isEmpty) {
          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 20.0,
            ),
            decoration: commonCardDecoration(),
            child: const Center(child: Text("No Proposed Plan Data")),
          );
        }

        final plan = table2.first;
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
                      "Proposed Plan",
                      style: AppTextStyle.ts14M(
                        color: AppColor.black.withValues(alpha: 0.50),
                      ),
                    ),
                  ),
                ],
              ),
              verticalSpacing(),
              Container(
                margin: EdgeInsets.only(bottom: 10.0),
                padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.0),
                  color: AppColor.lightGreyBackground,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total Floors",
                      style: AppTextStyle.ts16M(
                        color: AppColor.black.withValues(alpha: 0.50),
                      ),
                    ),
                    Text(
                      plan.totalNumberOfFloors.toString(),
                      style: AppTextStyle.ts16SB(color: AppColor.black),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 10.0),
                padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.0),
                  color: AppColor.lightGreyBackground,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total Units",
                      style: AppTextStyle.ts16M(
                        color: AppColor.black.withValues(alpha: 0.50),
                      ),
                    ),
                    Text(
                      plan.totalUnits.toString(),
                      style: AppTextStyle.ts16SB(color: AppColor.black),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 10.0),
                padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.0),
                  color: AppColor.lightGreyBackground,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total Parkings",
                      style: AppTextStyle.ts16M(
                        color: AppColor.black.withValues(alpha: 0.50),
                      ),
                    ),
                    Text(
                      plan.totalParking.toString(),
                      style: AppTextStyle.ts16SB(color: AppColor.black),
                    ),
                  ],
                ),
              ),
              areaToggle(),
              verticalSpacing(),
              _buildAreaWiseList(table3: data.table3),
            ],
          ),
        );
      },
    );
  }

  // AREA TOGGLE WIDGET
  Widget areaToggle() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColor.primary, width: 0.6),
        color: AppColor.white,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [_toggleItem("Commercial", 0), _toggleItem("Residential", 1)],
      ),
    );
  }

  // AREA TOGGLE ITEM WIDGET
  Widget _toggleItem(String title, int index) {
    final bool isSelected = selectedAreaIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedAreaIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border:
              isSelected
                  ? Border.all(width: 0.5, color: AppColor.primary)
                  : null,
          color: isSelected ? const Color(0xFFEFF4FF) : Colors.transparent,
        ),
        child: Text(
          title,
          style: AppTextStyle.ts14M(
            color:
                isSelected
                    ? AppColor.primary
                    : AppColor.black.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }

  // BUILD AREA WISE LIST WIDGET
  Widget _buildAreaWiseList({required List<Table3> table3}) {
    final filteredList =
        selectedAreaIndex == 0
            ? table3
                .where((e) => e.flatType.toLowerCase() == "commercial")
                .toList()
            : table3
                .where((e) => e.flatType.toLowerCase() == "residential")
                .toList();

    if (filteredList.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Center(
          child: Text(
            "No ${selectedAreaIndex == 0 ? "Commercial" : "Residential"} Units",
            style: AppTextStyle.ts12M(
              color: AppColor.black.withValues(alpha: 0.5),
            ),
          ),
        ),
      );
    }

    final Map<String, int> configCountMap = {};

    for (final item in filteredList) {
      final config = item.flatConfiguration.trim();

      if (configCountMap.containsKey(config)) {
        configCountMap[config] = configCountMap[config]! + 1;
      } else {
        configCountMap[config] = 1;
      }
    }

    final groupedList = configCountMap.entries.toList();

    return SizedBox(
      height: 250,
      child: ListView.separated(
        itemCount: groupedList.length,
        physics: const AlwaysScrollableScrollPhysics(),
        separatorBuilder:
            (_, __) => Divider(
              height: 16,
              color: AppColor.black.withValues(alpha: 0.08),
            ),
        itemBuilder: (context, index) {
          final entry = groupedList[index];

          return _areaTile(title: entry.key, count: entry.value);
        },
      ),
    );
  }

  // AREA TILE WIDGET
  Widget _areaTile({required String title, required int count}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyle.ts14M(color: AppColor.black)),
          Text(
            count.toString().padLeft(2, '0'),
            style: AppTextStyle.ts14M(color: AppColor.black),
          ),
        ],
      ),
    );
  }

  // BUILD PROPOSED OFFER WIDGET
  Widget _buildProposedOfferWidget(BuildContext context) {
    return BlocBuilder<RedevlopmentDashboardCubit, RedevlopmentDashboardState>(
      builder: (context, state) {
        if (state.isLoading == true) {
          return loader();
        }
        final data = state.redevelopmentDashboardModel;
        if (data == null) {
          return const Center(child: Text("No data available"));
        }
        final table2 = data.table2;
        if (table2.isEmpty) {
          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 20.0,
            ),
            decoration: commonCardDecoration(),
            child: const Center(child: Text("No Proposed Offer Data")),
          );
        }

        final amenitiesRaw = table2.first.amenities;
        final List<String> amenitiesList =
            amenitiesRaw
                .split(',')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList();

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
                      "Proposed Offer",
                      style: AppTextStyle.ts14M(
                        color: AppColor.black.withValues(alpha: 0.50),
                      ),
                    ),
                  ),
                ],
              ),
              verticalSpacing(),
              SizedBox(
                height: 200.0,
                child: ListView.builder(
                  itemCount: amenitiesList.length,
                  itemBuilder: (context, int index) {
                    return Container(
                      margin: EdgeInsets.only(bottom: 10.0),
                      padding: EdgeInsets.symmetric(
                        vertical: 12.0,
                        horizontal: 12.0,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4.0),
                        color: AppColor.lightBlue,
                      ),
                      child: Text(
                        amenitiesList[index],
                        style: AppTextStyle.ts14M(color: AppColor.primary),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ProjectProgressStep {
  final String title;
  final int percentage;
  final String status;

  ProjectProgressStep({
    required this.title,
    required this.percentage,
    required this.status,
  });
}

class _AreaChartModel {
  final double value;
  final String label;

  _AreaChartModel(this.value, this.label);
}

class TenantRadialChart extends StatelessWidget {
  final int residential;
  final int commercial;

  const TenantRadialChart({
    super.key,
    required this.residential,
    required this.commercial,
  });

  int get total => residential + commercial;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: SizedBox(
            height: 140,
            width: 140,
            child: CustomPaint(
              painter: RadialPainter(
                residential: residential,
                commercial: commercial,
              ),
              child: Center(
                child: Text("Total :$total", style: AppTextStyle.ts14SB()),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class RadialPainter extends CustomPainter {
  final int residential;
  final int commercial;

  RadialPainter({required this.residential, required this.commercial});

  final double stroke = 20;
  final double gapDegrees = 25;

  @override
  void paint(Canvas canvas, Size size) {
    final total = residential + commercial;

    final center = size.center(Offset.zero);
    final radius = size.width / 2.2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round;

    final usable = 360 - (gapDegrees * 3);

    final residentialSweep = (residential / total) * usable;
    final commercialSweep = (commercial / total) * usable;

    double start = -90 - (residentialSweep / 2);

    void draw(Color color, double sweep) {
      paint.color = color;
      canvas.drawArc(rect, _deg(start), _deg(sweep), false, paint);
      start += sweep + gapDegrees;
    }

    draw(AppColor.primary, residentialSweep); // RESIDENTIAL
    draw(AppColor.blueBgColor, commercialSweep); // COMMMERCIAL
  }

  double _deg(double d) => d * pi / 180;

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
