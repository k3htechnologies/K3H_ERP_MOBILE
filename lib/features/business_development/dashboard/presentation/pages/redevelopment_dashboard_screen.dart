import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/business_development/building/data/model/building.model.dart';
import 'package:k3h_erp_app/features/business_development/building/data/repository/building.repository.dart';
import 'package:k3h_erp_app/features/business_development/dashboard/presentation/cubit/redevlopment_dashboard_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/functions/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/charts/custom_radial_chart.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
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
              response['data'] as List<BusinessDevelopmentBuildingModel>;
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
        screenTitle: "Business Development Dashboard",
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
                  showSiteSelectedWidget(),
                  // ACCORDING TO PROJECT BUILDING WILL BE DISPLAYED
                  CustomMultipleSelectPopup(
                    isMultiSelect: false,
                    initialValue: selectedBuilding,
                    dataList: [],
                    hintText: "Select Building",
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
                  GestureDetector(
                    onTap: () {
                      goRouter.pushNamed(AppRoutes.proposedPlan);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
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
                          child: Text(
                            "Proposed Plan",
                            style: AppTextStyle.ts14M(color: AppColor.primary),
                          ),
                        ),
                      ],
                    ),
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
                  // PARKING WIDGET
                  _buildParkingWidget(context),
                  verticalSpacing(),
                  // BUILDING DETAILS WIDGET
                  _buildBuildingOverviewWidget(context),
                  verticalSpacing(),
                  // ALERT WIDGET
                  _buildAlertsWidget(context),
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
          "Additional TAA",
          "Brokerage",
          "Hardship",
          "Shifting",
          "TAA",
        ];
        final data = state.redevelopmentDashboardModel;
        final table1 = data?.table1 ?? [];

        final totalAmount = table1.fold<double>(
          0,
          (sum, item) => sum + item.amount.toDouble(),
        );

        final totalPaid = table1.fold<double>(
          0,
          (sum, item) => sum + item.paid.toDouble(),
        );

        final pendingAmount = totalAmount - totalPaid;
        final pendingAmountInCr = pendingAmount / 10000000;
        final chartData =
            table1.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;

              return _AreaChartModel(
                item.amount.toDouble() / 10000000,
                staticList[index],
              );
            }).toList();

        final maxValue =
            chartData.isEmpty
                ? 0.0
                : chartData.map((e) => e.value).reduce((a, b) => a > b ? a : b);

        final safeMax = maxValue <= 0 ? 10.0 : maxValue * 1.2;
        final safeInterval = safeMax / 4;
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
              if (table1.isNotEmpty) ...[
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 12.0,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    color: AppColor.lightBlue.withValues(alpha: 0.5),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          "Total Financial Exposure",
                          style: AppTextStyle.ts14M(color: AppColor.black),
                        ),
                      ),
                      Text(
                        " ₹ $pendingAmountInCr Cr",
                        style: AppTextStyle.ts16M(color: AppColor.black),
                      ),
                    ],
                  ),
                ),
                verticalSpacing(),
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
                    final item = table1[index];
                    final percentage =
                        totalAmount > 0
                            ? ((item.amount.toDouble() / totalAmount) * 100)
                                .round()
                            : 0;

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
                            (item.amount).toIndianCurrency(),
                            style: AppTextStyle.ts14M(),
                          ),
                          verticalSpacing(height: 6),
                          Text(
                            "$percentage% Of Total",
                            style: AppTextStyle.ts10M(
                              color: AppColor.black.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                verticalSpacing(),
                SizedBox(
                  height: 280,
                  child: SfCartesianChart(
                    tooltipBehavior: TooltipBehavior(
                      enable: true,
                      format: 'point.x : point.y CR',
                    ),
                    plotAreaBorderWidth: 0,

                    primaryXAxis: CategoryAxis(
                      majorGridLines: const MajorGridLines(width: 0),
                      labelAlignment: LabelAlignment.center,
                      labelIntersectAction: AxisLabelIntersectAction.wrap,
                      labelStyle: AppTextStyle.ts10M(
                        color: AppColor.black.withValues(alpha: 0.5),
                      ),
                    ),

                    primaryYAxis: NumericAxis(
                      minimum: 0,
                      maximum: safeMax,
                      interval: safeInterval,
                      axisLabelFormatter: (AxisLabelRenderDetails details) {
                        return ChartAxisLabel(
                          "${details.text} CR",
                          details.textStyle,
                        );
                      },
                      majorGridLines: const MajorGridLines(width: 0),
                      axisLine: const AxisLine(width: 1),
                      majorTickLines: const MajorTickLines(size: 6),
                      labelStyle: AppTextStyle.ts12M(
                        color: AppColor.black.withValues(alpha: 0.5),
                      ),
                    ),

                    series: <CartesianSeries<_AreaChartModel, String>>[
                      ColumnSeries<_AreaChartModel, String>(
                        dataSource: chartData,
                        xValueMapper: (item, _) => item.label,
                        yValueMapper: (item, _) => item.value,
                        width: 0.35,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(6),
                        ),
                        pointColorMapper: (item, _) {
                          switch (item.label) {
                            case "Additional TAA":
                              return const Color(0xFF4F46E5);
                            case "Brokerage":
                              return Color(0xFF10B981);
                            case "Hardship":
                              return Color(0xffF97316);
                            case "Shifting":
                              return Color(0xffF43F5E);
                            case "TAA":
                              return AppColor.blueBgColor;
                            default:
                              return AppColor.black;
                          }
                        },
                      ),
                    ],
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

  // BUILD AREA UTILIZATION SUMMARY WIDGET
  Widget _buildAreaUtilizationSummaryWidget(BuildContext context) {
    return BlocBuilder<RedevlopmentDashboardCubit, RedevlopmentDashboardState>(
      builder: (context, state) {
        if (state.isLoading == true) {
          return loader();
        }

        final data = state.redevelopmentDashboardModel;

        final table3 = data?.table3 ?? [];

        final existingCarpetArea = table3.fold<double>(
          0,
          (sum, item) => sum + item.flatCarpetAreaSqFt,
        );

        final freeAreaOffered = table3.fold<double>(
          0,
          (sum, item) =>
              sum +
              (item.flatCarpetAreaSqFt.toDouble() *
                  item.freeAreaOfferedPercent.toDouble() /
                  100),
        );

        final extraAreaPurchased = table3.fold<double>(
          0,
          (sum, item) => sum + item.extraAreaPurchasedSqFt.toDouble(),
        );

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
              Column(
                children: [
                  _buildAreaProgressItem(
                    title: "Existing Offered Area",
                    amount: existingCarpetArea,
                    progress: existingCarpetArea,
                    color: AppColor.primary,
                  ),
                  verticalSpacing(height: 20),

                  _buildAreaProgressItem(
                    title: "Free Area Offered",
                    amount: freeAreaOffered,
                    progress: freeAreaOffered,
                    color: Colors.green,
                  ),
                  verticalSpacing(height: 20),

                  _buildAreaProgressItem(
                    title: "Extra Area Purchased",
                    amount: extraAreaPurchased,
                    progress: extraAreaPurchased,
                    color: Colors.orange,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAreaProgressItem({
    required String title,
    required double amount,
    required double progress,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Text(
                title,
                style: AppTextStyle.ts14M(
                  color: AppColor.black.withValues(alpha: 0.7),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                "${amount.toStringAsFixed(2)} (Sq.Ft)",
                textAlign: TextAlign.end,
                style: AppTextStyle.ts14SB(
                  color: AppColor.black.withValues(alpha: 0.85),
                ),
              ),
            ),
          ],
        ),
        verticalSpacing(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 10,
            backgroundColor: AppColor.grey10,
            valueColor: AlwaysStoppedAnimation<Color>(color),
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
                  (e) => (e.unitType).toLowerCase().contains("residential"),
                )
                .length;
        final commercialCount =
            table3
                .where((e) => (e.unitType).toLowerCase().contains("commercial"))
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
                    title: "Residential",
                    value: residentialCount,
                    color: AppColor.blueBgColor,
                  ),
                  RadialChartItem(
                    title: "Commercial",
                    value: commercialCount,
                    color: Color(0xff1D703C),
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
                        color: AppColor.lightBluebg,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Residential",
                            style: AppTextStyle.ts16M(
                              color: AppColor.blueBgColor,
                            ),
                          ),
                          verticalSpacing(height: 4.0),
                          Text(
                            residentialCount.toString(),
                            style: AppTextStyle.ts16B(
                              color: AppColor.blueBgColor,
                            ),
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
                        color: Color(0xffECFDF5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Commercial",
                            style: AppTextStyle.ts16M(color: Color(0xff1D703C)),
                          ),
                          verticalSpacing(height: 4.0),
                          Text(
                            commercialCount.toString(),
                            style: AppTextStyle.ts16B(color: Color(0xff1D703C)),
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

  // BUILD PARKING WIDGET
  Widget _buildParkingWidget(BuildContext context) {
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

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: commonCardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "Parking",
                    style: AppTextStyle.ts14M(
                      color: AppColor.black.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
              verticalSpacing(),
              Container(
                margin: EdgeInsets.only(bottom: 16.sp),
                padding: EdgeInsets.symmetric(
                  horizontal: 7.sp,
                  vertical: 15.5.sp,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.sp),
                  border: Border.all(width: 1.sp, color: Color(0xffF1F5F9)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        "Sales Parking",
                        style: AppTextStyle.ts14SB(color: AppColor.primary),
                      ),
                    ),
                    Text(
                      table2.first.salesParking.toString(),
                      style: AppTextStyle.ts20B(color: AppColor.darkBlue900),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 16.sp),
                padding: EdgeInsets.symmetric(
                  horizontal: 7.sp,
                  vertical: 15.5.sp,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.sp),
                  border: Border.all(width: 1.sp, color: Color(0xffF1F5F9)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        "Member Parking",
                        style: AppTextStyle.ts14SB(color: AppColor.green),
                      ),
                    ),
                    Text(
                      table2.first.salesParking.toString(),
                      style: AppTextStyle.ts20B(color: AppColor.darkBlue900),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 7.sp,
                  vertical: 15.5.sp,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.sp),
                  border: Border.all(width: 1.sp, color: Color(0xffF1F5F9)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        "Visitors Parking",
                        style: AppTextStyle.ts14SB(color: Colors.orange),
                      ),
                    ),
                    Text(
                      table2.first.salesParking.toString(),
                      style: AppTextStyle.ts20B(color: AppColor.darkBlue900),
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

  // BUILD BUILDING DETAILS WIDGET
  Widget _buildBuildingOverviewWidget(BuildContext context) {
    return BlocBuilder<RedevlopmentDashboardCubit, RedevlopmentDashboardState>(
      builder: (context, state) {
        if (state.isLoading == true) {
          return loader();
        }
        final data = state.redevelopmentDashboardModel;

        final buildings = data?.table0;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: commonCardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "Building Overview",
                    style: AppTextStyle.ts14M(
                      color: AppColor.black.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
              verticalSpacing(),
              if (buildings != null && buildings.isNotEmpty) ...[
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

  // BUILD ALERT WIDGET
  Widget _buildAlertsWidget(BuildContext context) {
    return BlocBuilder<RedevlopmentDashboardCubit, RedevlopmentDashboardState>(
      builder: (context, state) {
        if (state.isLoading == true) {
          return loader();
        }

        final data = state.redevelopmentDashboardModel;
        final alerts = data?.table4;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: commonCardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
              if (alerts != null && alerts.isNotEmpty) ...[
                SizedBox(
                  height: 250.0,
                  child: ListView.builder(
                    itemCount: alerts.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      final alert = alerts[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 6.0),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12.0,
                          horizontal: 16.0,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6.0),
                          color: AppColor.red.withValues(alpha: 0.1),
                          border: const Border(
                            left: BorderSide(width: 4, color: AppColor.red),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              alert.buildingName,
                              style: AppTextStyle.ts14M(),
                            ),
                            verticalSpacing(),
                            Text(
                              alert.issue,
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
