import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:k3h_erp_app/features/sales/sales_dashboard/presentation/cubit/sales_dashboard_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class SalesDashboardScreen extends StatefulWidget {
  const SalesDashboardScreen({super.key});

  @override
  State<SalesDashboardScreen> createState() => _SalesDashboardScreenState();
}

class _SalesDashboardScreenState extends State<SalesDashboardScreen> {
  // CUBIT
  late SalesDashboardCubit _salesDashboardCubit;

  final ValueNotifier<int> selectedAreaNotifier = ValueNotifier(0);
  late ProjectModel _selectedProject;

  List<int> enquiriesList = [0, 1, 2];

  @override
  void initState() {
    super.initState();
    _salesDashboardCubit = context.read<SalesDashboardCubit>();
    _selectedProject = getProject();
    _salesDashboardCubit.getSalesDashboardList(
      context,
      _selectedProject.projectId,
    );
  }

  @override
  void dispose() {
    selectedAreaNotifier.dispose();
    super.dispose();
  }

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

  Widget _toggleItem(String title, int index) {
    return ValueListenableBuilder<int>(
      valueListenable: selectedAreaNotifier,
      builder: (context, selectedIndex, _) {
        final bool isSelected = selectedIndex == index;

        return GestureDetector(
          onTap: () {
            selectedAreaNotifier.value = index;
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
      },
    );
  }
  /*
  List<BudgetChartData> _getStaticBudgetData() {
    return [
      BudgetChartData(month: 'JAN', value: 10, slab: '10-15 CR'),
      BudgetChartData(month: 'FEB', value: 4, slab: '1-5 CR'),
      BudgetChartData(month: 'MAR', value: 8, slab: '5-10 CR'),
      BudgetChartData(month: 'APR', value: 2, slab: '<1 CR'),
      BudgetChartData(month: 'MAY', value: 12, slab: '10-15 CR'),
      BudgetChartData(month: 'JUN', value: 5, slab: '5-10 CR'),
      BudgetChartData(month: 'JUL', value: 8, slab: '5-10 CR'),
      BudgetChartData(month: 'AUG', value: 15, slab: '15-20 CR'),
      BudgetChartData(month: 'SEPT', value: 5, slab: '5-10 CR'),
      BudgetChartData(month: 'OCT', value: 9, slab: '5-10 CR'),
      BudgetChartData(month: 'NOV', value: 5, slab: '5-10 CR'),
      BudgetChartData(month: 'DEC', value: 3, slab: '1-5 CR'),
    ];
  }

  
  Future<void> _showMarkAsTimeOutPopup(BuildContext context, int index) async {
    final shouldRemove = await DialogHelper.showConfirmationDialog(
      context: context,
      title: 'Are you sure you want to mark Time Out?',
      message: '',
      confirmText: "Mark Time Out",
    );

    if (shouldRemove == true) {
      final removedItem = enquiriesList[index];

      enquiriesList.removeAt(index);

      _listKey.currentState?.removeItem(
        index,
        (context, animation) => _buildAnimatedItem(removedItem, animation),
        duration: const Duration(milliseconds: 300),
      );

      setState(() {});
    }
  }
  */

  /*
  List<StatusColor> _getActiveFollowUpData() {
    return [
      StatusColor(
        bg: AppColor.green,
        text: "Booking Done",
        textColor: AppColor.green,
      ),
      StatusColor(
        bg: Color(0xff7B6B28),
        text: "Blocked",
        textColor: Color(0xff7B6B28),
      ),
      StatusColor(
        bg: Color(0xff333333),
        text: "Cancelled",
        textColor: Color(0xff333333),
      ),
      StatusColor(
        bg: Color(0xff7B6B28),
        text: "Negotiation",
        textColor: Color(0xff7B6B28),
      ),
      StatusColor(
        bg: Color(0xffFF0037),
        text: "Lost",
        textColor: Color(0xffFF0037),
      ),
      StatusColor(
        bg: Color(0xff1AA0DB),
        text: "Retention",
        textColor: Color(0xff1AA0DB),
      ),
      StatusColor(
        bg: Color(0xff065F46),
        text: "Re-Visit Scheduled",
        textColor: Color(0xff065F46),
      ),
      StatusColor(
        bg: Color(0xffFFF2E9),
        text: "Re-Visit Proposed",
        textColor: Color(0xffFF6600),
      ),
      StatusColor(
        bg: Color(0xff7F1D1D).withValues(alpha: 0.3),
        text: "Site Visit",
        textColor: Color(0xff7F1D1D),
      ),
      StatusColor(
        bg: AppColor.darkBackground,
        text: "Unit Selection / Blocked",
        textColor: AppColor.black,
      ),
    ];
  }

  Widget _buildAnimatedItem(int item, Animation<double> animation) {
    return FadeTransition(
      opacity: animation,
      child: SizeTransition(
        sizeFactor: animation,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12.0),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.0),
            color: AppColor.lightGreyBackground,
          ),
          child: const SizedBox(height: 100),
        ),
      ),
    );
  }
*/
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SalesDashboardCubit, SalesDashboardState>(
      builder: (context, state) {
        if (state.isLoading!) {
          return Center(child: loader());
        }
        return Scaffold(
          appBar: CustomAppBarWithBackButton(
            screenTitle: "Sales",
            isMenuButton: true,
            authorization: AuthorizationModel(),
            onProjectChangeCallback: (value) {
              _selectedProject = value;
              _salesDashboardCubit.getSalesDashboardList(
                context,
                _selectedProject.projectId,
              );
            },
            showNotification: true,
          ),
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // GENERATE REPORT
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 5.0,
                      horizontal: 6.0,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6.0),
                      color: AppColor.lightBlue,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          AppAssets.generateReportIcon,
                          width: 16,
                          height: 16,
                        ),
                        horizontalSpacing(),
                        Flexible(
                          child: Text(
                            "Generate Report",
                            style: AppTextStyle.ts14M(color: AppColor.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  verticalSpacing(),
                  // COUNTS WIDGET (INCLUDING TOTAL ENQUIRIES, NEW ENQURIES, ACTIVE FOLLOW - UPS, LOST ENQURIES, TOTAL BOOKINGS, TOTAL BOOKING VALUE, TARGET VS ACHIEVED, CP CONTRIBUTION)
                  /*
                  _buildOverviewWidget(context),
                  // ENQUIRY OVERVIEW WIDGET
                  _buildEnquiryOverviewWidget(context),
                  */
                  verticalSpacing(),
                  // ENQURIES LIST WIDGET
                  _buildEnquiriesWidget(context),
                  verticalSpacing(),
                  // TARGET PERFORMANCE WIDGET
                  /* _buildTargetPerformanceWidget(context),*/
                  verticalSpacing(),
                  // ACTIVE FOLLOW-UPS WIDGET (ACCORDING TO STATUS)
                  _buildActiveFollowUpsWidget(context),
                  verticalSpacing(),
                  // CALL TRACKER AND TOP CALLER LIST WIDGET
                  /*
                  _buildCallTrackerWidget(context),*/
                  verticalSpacing(),
                  // SALES DISTRIBUTION (SOURCE WISE DISTRIBUTION, AREA WISE DISTRIBUTION {COMMERCIAL AND RESIDENTIAL},BUDGET WISE DISTRIBUTION AND CONVERSION RATE COUNT)
                  /*
                  _buildSalesDistributionWidget(context),*/
                  verticalSpacing(),
                  // REPORTS WIDGET
                  _buildReportsWidget(context),
                  verticalSpacing(),
                  // CHANNEL PARTNER COUNT WIDGET
                  /*
                  _buildChannelPartnerWidget(context),*/
                  verticalSpacing(),
                  // SALES LEADERBOARD WIDGET
                  /*
                  _buildSalesLeaderboardWidget(context),*/
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /* Widget _buildOverviewWidget(BuildContext context) {
    return BlocBuilder<SalesDashboardCubit, SalesDashboardState>(
      builder: (context, state) {
        if (state.isLoading == true) {
          return Center(child: loader());
        }
        final salesData = state.salesData;
        final table0 =
            (salesData?.table0 != null && salesData!.table0.isNotEmpty)
                ? salesData.table0.first
                : null;
        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          childAspectRatio: 1.5,
          children: [
            DashboardStatCard(
              title: "Total Enquiries",
              value: "${table0?.totalEnquiries ?? 0}",
              titleColor: AppColor.white,
              footer: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text:
                          "↑ ${table0?.increaseEnquiryPercentage.toDouble() ?? 0.0}% ",
                      style: AppTextStyle.ts12R(color: AppColor.green),
                    ),
                    TextSpan(
                      text: "vs last month",
                      style: AppTextStyle.ts12R(color: AppColor.white),
                    ),
                  ],
                ),
              ),
              valueColor: AppColor.white,
              decoration: BoxDecoration(
                color: AppColor.blueBgColor,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            DashboardStatCard(
              title: "New Enquiries",
              titleColor: AppColor.black.withValues(alpha: 0.50),
              value: "${table0?.newLeadsThisMonth ?? 0.0}",
              footer: Text(
                "This Month",
                style: AppTextStyle.ts12R(
                  color: AppColor.black.withValues(alpha: 0.5),
                ),
              ),
              decoration: BoxDecoration(
                color: AppColor.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            DashboardStatCard(
              title: "Active Follow-Ups",
              titleColor: AppColor.black.withValues(alpha: 0.50),
              value: "${table0?.activeFollowUps ?? 0.0}",
              footer: Text(
                "${table0?.todaysFollowUpDues ?? 0.0} Due Today",
                style: AppTextStyle.ts12R(color: AppColor.yellow),
              ),
              decoration: BoxDecoration(
                color: AppColor.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            DashboardStatCard(
              title: "Lost Enquiries",
              titleColor: AppColor.black.withValues(alpha: 0.50),
              value: "${table0?.lostLeadsToday ?? 0.0}",
              footer: Text(
                "High Alert",
                style: AppTextStyle.ts12R(color: AppColor.red),
              ),
              leadingStripe: Container(
                width: 6,
                decoration: BoxDecoration(
                  color: AppColor.red,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(16),
                  ),
                ),
              ),
            ),
            DashboardStatCard(
              title: "Total Bookings",
              titleColor: AppColor.black.withValues(alpha: 0.50),
              value: "${table0?.todayBookings ?? 0.0}",
              footer: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "↑ ${table0?.totalBookingConversion ?? 0.0}% ",
                      style: AppTextStyle.ts12R(color: AppColor.green),
                    ),
                    TextSpan(
                      text: "conversion up",
                      style: AppTextStyle.ts12R(color: AppColor.black),
                    ),
                  ],
                ),
              ),
              decoration: BoxDecoration(
                color: AppColor.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            DashboardStatCard(
              title: "Total Booking Value",
              titleColor: AppColor.black.withValues(alpha: 0.50),
              value: "₹ ${table0?.todayBookingValue ?? 0.0}",
              footer: Text(
                "Avg: ₹${table0?.averageBookingValue.toDouble() ?? 0.0}L",
                style: AppTextStyle.ts12R(color: AppColor.primary),
              ),
            ),
            DashboardStatCard(
              title: "Target vs Achieved",
              titleColor: AppColor.black.withValues(alpha: 0.50),
              value: "${table0?.achieved ?? 0.0}%",
              footer: Text(
                "out of 100 %",
                style: AppTextStyle.ts12R(
                  color: AppColor.black.withValues(alpha: 0.50),
                ),
              ),
            ),
            DashboardStatCard(
              title: "CP Contribution",
              titleColor: AppColor.black.withValues(alpha: 0.50),
              value: "${table0?.cpPercentage ?? 0.0}%",
              footer: Text(
                "${table0?.activeCp ?? 0.0} active partners",
                style: AppTextStyle.ts12R(color: AppColor.primary),
              ),
              decoration: BoxDecoration(
                color: AppColor.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEnquiryOverviewWidget(BuildContext context) {
    return BlocBuilder<SalesDashboardCubit, SalesDashboardState>(
      builder: (context, state) {
        if (state.isLoading == true) {
          return Center(child: loader());
        }

        final salesData = state.salesData;

        final table1 = salesData?.table1.first;
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
                      "Enquiry Overview",
                      style: AppTextStyle.ts14M(
                        color: AppColor.black.withValues(alpha: 0.50),
                      ),
                    ),
                  ),
                ],
              ),
              verticalSpacing(),
              _buildEnquiryOverviewProgress(),
              verticalSpacing(),
              if (table1 != null) ...[
                Container(
                  width: double.infinity,
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
                        "Overall Conversion Rate",
                        style: AppTextStyle.ts12R(
                          color: AppColor.lightGreyBackground,
                        ),
                      ),
                      Text(
                        "${table1.enquiryConversionRate.toDouble()}",
                        style: AppTextStyle.ts16SB(color: AppColor.white),
                      ),
                      Text(
                        "From enquiry to closed deal",
                        style: AppTextStyle.ts12R(
                          color: AppColor.lightGreyBackground,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Center(
                  child: Text(
                    "No Enquiry Overview Available",
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

  Widget _buildEnquiryOverviewProgress() {
    return BlocBuilder<SalesDashboardCubit, SalesDashboardState>(
      builder: (context, state) {
        if (state.isLoading == true) {
          return Center(child: loader());
        }

        final salesData = state.salesData;

        final table1List = salesData?.table1;
        return Column(
          children: [
            if (table1List != null && table1List.isNotEmpty) ...[
              EnquiryProgressBar(
                title: "Enquiry",
                percentage: table1List.first.totalEnquiry,
                breakdownText: "hotWarmCold",
              ),
              EnquiryProgressBar(
                title: "Site Visit",
                percentage: table1List.first.siteVisit,
                conversionText:
                    "Conversion: ${table1List.first.siteVisitConversion}%",
              ),
              EnquiryProgressBar(
                title: "Negotiation",
                percentage: table1List.first.negotiation,
                conversionText:
                    "Conversion: ${table1List.first.negotiationConversion}%",
              ),
              EnquiryProgressBar(
                title: "Booking",
                percentage: table1List.first.bookingStage,
                conversionText:
                    "Conversion: ${table1List.first.bookingConversion}%",
              ),
              EnquiryProgressBar(
                title: "Closed",
                percentage: table1List.first.closedStage,
                conversionText:
                    "Conversion: ${table1List.first.closingConversion}%",
              ),
            ] else
              ...[],
          ],
        );
      },
    );
  }

  Color _getPerformanceBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'excellent':
        return const Color(0xFFE8F8F1);
      case 'good':
        return const Color(0xFFEAF6FB);
      case 'average':
        return const Color(0xFFFFF4E5);
      case 'at risk':
        return const Color(0xFFFFEBEE);
      default:
        return AppColor.white;
    }
  }

  Color _getPerformancePrimaryColor(String status) {
    switch (status.toLowerCase()) {
      case 'excellent':
        return const Color(0xFF1ABC9C);
      case 'good':
        return const Color(0xFF2D9CDB);
      case 'average':
        return const Color(0xFFF2C94C);
      case 'at risk':
        return const Color(0xFFEB5757);
      default:
        return AppColor.primary;
    }
  }
*/
  /* Widget _buildTargetPerformanceWidget(BuildContext context) {
    return BlocBuilder<SalesDashboardCubit, SalesDashboardState>(
      builder: (context, state) {
        if (state.isLoading == true) {
          return Center(child: loader());
        }

        final salesData = state.salesData;

        final table3List = salesData?.table3;
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
                      "Target Performance",
                      style: AppTextStyle.ts14M(
                        color: AppColor.black.withValues(alpha: 0.50),
                      ),
                    ),
                  ),
                ],
              ),
              verticalSpacing(),
              if (table3List != null) ...[
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: List.generate(table3List.length, (index) {
                      final item = table3List[index];
                      final bgColor = _getPerformanceBgColor(
                        item.performanceStatus,
                      );

                      return Container(
                        width: 260,
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.0),
                          color: bgColor,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
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
                                horizontalSpacing(),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.fullName,
                                        style: AppTextStyle.ts16M(),
                                      ),
                                      Text(
                                        item.designation,
                                        style: AppTextStyle.ts14R(
                                          color: AppColor.black.withValues(
                                            alpha: 0.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            _leaveRow(
                              title: "Target",
                              value: "${item.targetAmount}",
                            ),
                            _leaveRow(
                              title: "Achieved",
                              value: "${item.achievedAmount}",
                            ),
                            verticalSpacing(),
                            SizedBox(
                              width: 208,
                              child: LinearProgressIndicator(
                                value: 100.0,
                                minHeight: 7,
                                borderRadius: BorderRadius.circular(2.0),
                                color: _getPerformancePrimaryColor(
                                  item.performanceStatus,
                                ),
                              ),
                            ),
                            verticalSpacing(),
                            Text(
                              "${item.achievementPercent.toDouble()} % Achieved",
                              style: AppTextStyle.ts14SB(
                                color: _getPerformancePrimaryColor(
                                  item.performanceStatus,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ] else ...[
                Center(
                  child: Text(
                    "No Target Performance Available",
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

  Widget _leaveRow({required String title, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(title, style: AppTextStyle.ts14R())),
          Expanded(
            child: SizedBox(
              width: 24,
              child: Center(child: Text(":", style: AppTextStyle.ts14R())),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Text(value, style: AppTextStyle.ts16SB()),
          ),
        ],
      ),
    );
  }
*/
  Widget _buildEnquiriesWidget(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        top: 12.0,
        bottom: 8.0,
      ),
      decoration: commonCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  "Enquiries  (Today's)",
                  style: AppTextStyle.ts14M(
                    color: AppColor.black.withValues(alpha: 0.50),
                  ),
                ),
              ),
            ],
          ),
          verticalSpacing(height: 10.0),
          /*
          Expanded(
            child: AnimatedList(
              key: _listKey,
              initialItemCount: enquiriesList.length,
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (context, index, animation) {
                return SizeTransition(
                  sizeFactor: animation,
                  axisAlignment: 0.0,
                  child: _buildEnquiryTile(context, index),
                );
              },
            ),
          ),
          */
          Center(
            child: Text(
              "No Enquiries for today Available",
              style: AppTextStyle.ts12M(
                color: AppColor.black.withValues(alpha: 0.50),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /*
  Widget _buildEnquiryTile(BuildContext context, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.0),
        color: AppColor.lightGreyBackground,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 90,
                child: Text(
                  "Date",
                  style: AppTextStyle.ts12R(
                    color: AppColor.black.withValues(alpha: 0.5),
                  ),
                ),
              ),
              const SizedBox(width: 16, child: Center(child: Text(":"))),
              const Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text("12 January 2026"),
                ),
              ),
            ],
          ),
          verticalSpacing(height: 20.0),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Customer Time-In",
                    style: AppTextStyle.ts12R(
                      color: AppColor.black.withValues(alpha: 0.50),
                    ),
                  ),
                  Text(
                    "09:12:22",
                    style: AppTextStyle.ts14M(color: AppColor.black),
                  ),
                ],
              ),
              CustomButton(
                text: "Mark Time Out",
                onPressed: () {
                  _showMarkAsTimeOutPopup(context, index);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
*/
  Widget _buildActiveFollowUpsWidget(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        top: 12.0,
        bottom: 8.0,
      ),
      decoration: commonCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  "Active Follow-Ups",
                  style: AppTextStyle.ts14M(
                    color: AppColor.black.withValues(alpha: 0.50),
                  ),
                ),
              ),
            ],
          ),
          verticalSpacing(height: 10.0),
          /*
          Expanded(
            child: ListView.builder(
              itemCount: 10,
              shrinkWrap: true,
              physics: AlwaysScrollableScrollPhysics(),
              itemBuilder: (context, int index) {
                var activeData = _getActiveFollowUpData()[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4.0),
                    color: AppColor.lightGreyBackground,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Client Name",
                                style: AppTextStyle.ts14M(
                                  color: AppColor.black.withValues(alpha: 0.50),
                                ),
                              ),
                              Text(
                                "Isha Patel",
                                style: AppTextStyle.ts14M(
                                  color: AppColor.black,
                                ),
                              ),
                            ],
                          ),
                          horizontalSpacing(width: 20.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Due Day(s)",
                                style: AppTextStyle.ts12R(
                                  color: AppColor.black.withValues(alpha: 0.50),
                                ),
                              ),
                              Text(
                                "Today",
                                style: AppTextStyle.ts14M(
                                  color: AppColor.black,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      verticalSpacing(),
                      Row(
                        children: [
                          SizedBox(
                            width: 90,
                            child: Text(
                              "Status",
                              style: AppTextStyle.ts14M(
                                color: AppColor.black.withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 16,
                            child: Center(
                              child: Text(
                                ":",
                                style: AppTextStyle.ts14M(
                                  color: AppColor.black.withValues(alpha: 0.5),
                                ),
                              ),
                            ),
                          ),
                          horizontalSpacing(width: 20),
                          Expanded(
                            child: Container(
                              width: 180,
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.0,
                                vertical: 4.0,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6.0),
                                color: activeData.bg.withValues(alpha: 0.1),
                              ),
                              child: Center(
                                child: Text(
                                  activeData.text,
                                  style: AppTextStyle.ts14M(
                                    color: activeData.textColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
       */
          Center(
            child: Text(
              "No Active Follow ups Available",
              style: AppTextStyle.ts12M(
                color: AppColor.black.withValues(alpha: 0.50),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /*
  Widget _buildCallTrackerWidget(BuildContext context) {
    return BlocBuilder<SalesDashboardCubit, SalesDashboardState>(
      builder: (context, state) {
        if (state.isLoading == true) {
          return Center(child: loader());
        }

        final salesData = state.salesData;

        final table6List = salesData?.table6.first;
        final table0 = salesData?.table0.first;
        final table8List = salesData?.table8;
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
                      "Call Tracker",
                      style: AppTextStyle.ts14M(
                        color: AppColor.black.withValues(alpha: 0.50),
                      ),
                    ),
                  ),
                ],
              ),
              verticalSpacing(height: 20.0),
              if (table6List != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    summaryOverallWidget(
                      title: "Total Calls",
                      subTitle: table6List.totalCalls.toString(),
                      color: Color(0xFF06B6D4),
                    ),
                    summaryOverallWidget(
                      title: "Pending",
                      subTitle: table6List.pending.toString(),
                      color: AppColor.yellow,
                    ),
                    summaryOverallWidget(
                      title: "Overdue",
                      subTitle: table6List.overdue.toString(),
                      color: AppColor.red,
                    ),
                    summaryOverallWidget(
                      title: "Avg Duration",
                      subTitle: table6List.avgDurationMinutes.toString(),
                      color: AppColor.green,
                    ),
                  ],
                ),
                verticalSpacing(height: 20.0),
                CommonRadialChart(
                  items: [
                    RadialChartItem(
                      title: "Connected",
                      value: table0?.todayConnected ?? 0,
                      color: AppColor.blue,
                    ),
                    RadialChartItem(
                      title: "Not Connected",
                      value: table0?.todayNotConnected ?? 0,
                      color: AppColor.grey50,
                    ),
                    RadialChartItem(
                      title: "Rescheduled",
                      value: table0?.todayRescheduled ?? 0,
                      color: AppColor.primary,
                    ),
                    RadialChartItem(
                      title: "Closed",
                      value: table0?.todayClosed ?? 0,
                      color: AppColor.black,
                    ),
                  ],
                ),
              ] else ...[
                Center(
                  child: Text(
                    "No Call Tracker Available",
                    style: AppTextStyle.ts12M(
                      color: AppColor.black.withValues(alpha: 0.50),
                    ),
                  ),
                ),
              ],

              verticalSpacing(height: 20.0),
              Divider(
                color: AppColor.black.withValues(alpha: 0.50),
                thickness: 0.3,
              ),
              verticalSpacing(height: 20.0),
              Text(
                "Top Caller",
                style: AppTextStyle.ts12SB(color: AppColor.black),
              ),
              verticalSpacing(),
              if (table8List != null) ...[
                Column(
                  children:
                      table8List.map((topCallerData) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                topCallerData["FullName"],
                                style: AppTextStyle.ts16M(),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 2.0,
                                horizontal: 6.0,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6.0),
                                color: AppColor.grey50.withValues(alpha: 0.50),
                              ),
                              child: Text(
                                topCallerData["TotalCalls"].toString(),
                                style: AppTextStyle.ts16M(
                                  color: AppColor.black,
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                ),
              ] else ...[
                Center(
                  child: Text(
                    "No Top Caller Available",
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
*/
  Widget summaryOverallWidget({String? title, String? subTitle, Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(subTitle!, style: AppTextStyle.ts16SB(color: color)),
        Text(
          title!,
          style: AppTextStyle.ts14R(
            color: AppColor.black.withValues(alpha: 0.50),
          ),
        ),
      ],
    );
  }

  /*
  Widget _buildSalesDistributionWidget(BuildContext context) {
    return BlocBuilder<SalesDashboardCubit, SalesDashboardState>(
      builder: (context, state) {
        if (state.isLoading == true) {
          return Center(child: loader());
        }

        final salesData = state.salesData;

        final table9List = salesData?.table9.first;
        final table12 = salesData?.table12;
        final table13 = salesData?.table13;
        final table14 = salesData?.table14;
        final table1List = salesData?.table1.first;
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
                      "Sales Distribution",
                      style: AppTextStyle.ts14M(
                        color: AppColor.black.withValues(alpha: 0.50),
                      ),
                    ),
                  ),
                ],
              ),
              verticalSpacing(),
              Divider(
                color: AppColor.black.withValues(alpha: 0.50),
                thickness: 0.3,
              ),
              verticalSpacing(),
              Text("Source Wise Distribution", style: AppTextStyle.ts14SB()),
              verticalSpacing(),
              if ((table9List != null) &&
                  table12 != null &&
                  table12.isNotEmpty) ...[
                Row(
                  children: [
                    Expanded(
                      child: _sourceCard(
                        title: "Direct Booking",
                        percentage: table9List.directBookingPct,
                        bgColor: const Color(0xFFFFF7ED),
                        borderColor: const Color(0xFFFFA742),
                        valueColor: const Color(0xFFFF8A00),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _sourceCard(
                        title: "Channel Partner\nBooking",
                        percentage: table9List.channelPartnerBookingPct,
                        bgColor: Color(0xFFEFF4FF),
                        borderColor: const Color(0xFF2563EB),
                        valueColor: const Color(0xFF2563EB),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:
                      table12.map((subSourceData) {
                        return SourceProgressBar(
                          title: subSourceData.sourceName,
                          percentage: subSourceData.sourcePct,
                        );
                      }).toList(),
                ),
              ] else ...[
                Center(
                  child: Text(
                    "No Source Wise Distribution Available",
                    style: AppTextStyle.ts12M(
                      color: AppColor.black.withValues(alpha: 0.50),
                    ),
                  ),
                ),
              ],
              verticalSpacing(),
              Divider(
                color: AppColor.black.withValues(alpha: 0.50),
                thickness: 0.3,
              ),
              verticalSpacing(),
              Text("Area Wise Distribution", style: AppTextStyle.ts14SB()),
              verticalSpacing(),
              areaToggle(),
              verticalSpacing(height: 16.0),
              if ((table13 != null && table13.isNotEmpty) &&
                  (table14 != null && table14.isNotEmpty)) ...[
                _buildAreaWiseList(table13: table13, table14: table14),
              ] else ...[
                Center(
                  child: Text(
                    "No Area Wise Distribution Available",
                    style: AppTextStyle.ts12M(
                      color: AppColor.black.withValues(alpha: 0.50),
                    ),
                  ),
                ),
              ],
              Divider(
                color: AppColor.black.withValues(alpha: 0.50),
                thickness: 0.3,
              ),
              verticalSpacing(),
              Text("Budget Wise Distribution", style: AppTextStyle.ts14SB()),
              _buildBudgetChart(),
              verticalSpacing(),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: AppColor.blueBgColor,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Booking Conversion Rate",
                      style: AppTextStyle.ts12R(
                        color: AppColor.lightGreyBackground,
                      ),
                    ),
                    Text(
                      "${table1List?.bookingConversion.toDouble() ?? 0.0}",
                      style: AppTextStyle.ts16SB(color: AppColor.white),
                    ),
                    Text(
                      "42 bookings from 342 enquiries",
                      style: AppTextStyle.ts12R(
                        color: AppColor.lightGreyBackground,
                      ),
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
*/
  /*
  Widget _buildBudgetChart() {
    final chartData = _getStaticBudgetData().reversed.toList();

    return SizedBox(
      height: 360,
      child: SfCartesianChart(
        plotAreaBorderWidth: 0,

        primaryXAxis: NumericAxis(
          minimum: 0,
          maximum: 22,
          interval: 5,
          axisLine: const AxisLine(width: 1),
          majorGridLines: const MajorGridLines(width: 0.15),
          labelStyle: AppTextStyle.ts12R(
            color: AppColor.black.withValues(alpha: 0.4),
          ),
          axisLabelFormatter: (AxisLabelRenderDetails details) {
            final value = details.value.toInt();
            switch (value) {
              case 0:
                return ChartAxisLabel('<1 CR', null);
              case 5:
                return ChartAxisLabel('1-5 CR', null);
              case 10:
                return ChartAxisLabel('5-10 CR', null);
              case 15:
                return ChartAxisLabel('10-15 CR', null);
              case 20:
                return ChartAxisLabel('15-20 CR', null);
              default:
                return ChartAxisLabel('', null);
            }
          },
        ),

        // Y AXIS = MONTH
        primaryYAxis: CategoryAxis(
          labelStyle: AppTextStyle.ts14M(
            color: AppColor.black.withValues(alpha: 0.5),
          ),
          axisLine: const AxisLine(width: 1),
          majorTickLines: const MajorTickLines(size: 6),
        ),
        series: <CartesianSeries<BudgetChartData, dynamic>>[
          BarSeries<BudgetChartData, dynamic>(
            dataSource: chartData,

            // LEFT → MONTH
            yValueMapper: (BudgetChartData data, _) => data.value,

            // BAR LENGTH (VALUE)
            xValueMapper: (BudgetChartData data, _) => data.value,

            borderRadius: BorderRadius.circular(6),
            width: 0.6,
            color: AppColor.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildAreaWiseList({
    required List<Table13> table13,
    required List<Table14> table14,
  }) {
    final List<dynamic> currentList =
        selectedAreaNotifier.value == 0 ? table13 : table14;

    if (currentList.isEmpty) {
      return const SizedBox();
    }

    return Column(
      children:
          currentList.map<Widget>((item) {
            return _areaDistributionTile(
              title: item.unitType,
              percentage: item.percentage,
            );
          }).toList(),
    );
  }

  Widget _areaDistributionTile({
    required String title,
    required num percentage,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(width: 6, color: AppColor.primary)),
        boxShadow: [
          BoxShadow(
            color: AppColor.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: AppTextStyle.ts14M(
                color: AppColor.black.withValues(alpha: 0.5),
              ),
            ),
          ),
          Text(
            "${percentage.toStringAsFixed(0)}%",
            style: AppTextStyle.ts16SB(color: AppColor.black),
          ),
        ],
      ),
    );
  }

  Widget _sourceCard({
    required String title,
    required num percentage,
    required Color bgColor,
    required Color borderColor,
    required Color valueColor,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 110),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: bgColor,
        border: Border.all(width: 1, color: borderColor.withValues(alpha: 0.6)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyle.ts14M(
              color: AppColor.black.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "${percentage.toStringAsFixed(1)}%",
            style: AppTextStyle.ts16SB(color: valueColor),
          ),
        ],
      ),
    );
  }
*/
  Widget _buildReportsWidget(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 12.0),
      decoration: commonCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  "Reports",
                  style: AppTextStyle.ts14M(
                    color: AppColor.black.withValues(alpha: 0.50),
                  ),
                ),
              ),
            ],
          ),
          verticalSpacing(height: 20.0),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisSpacing: 26.0,
            mainAxisSpacing: 16.0,
            childAspectRatio: 1.2,
            children: [
              QuickActionTile(
                icon: AppAssets.enquiryReportIcon,
                title: "Enquiry Report",
                onTap: () {},
              ),
              QuickActionTile(
                icon: AppAssets.sourceReportIcon,
                title: "Source Report",
                onTap: () {},
              ),
              QuickActionTile(
                icon: AppAssets.cpReportIcon,
                title: "CP Report",
                onTap: () {},
              ),
              QuickActionTile(
                icon: AppAssets.bookingReportIcon,
                title: "Booking Report",
                onTap: () {},
              ),
              QuickActionTile(
                icon: AppAssets.closingReportIcon,
                title: "Closing Report",
                onTap: () {},
              ),
              QuickActionTile(
                icon: AppAssets.salesAdvisorIcon,
                title: "Sales Advisor",
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  /*
  Widget _buildChannelPartnerWidget(BuildContext context) {
    return BlocBuilder<SalesDashboardCubit, SalesDashboardState>(
      builder: (context, state) {
        if (state.isLoading == true) {
          return Center(child: loader());
        }

        final salesData = state.salesData;

        final table18List = salesData?.table18.first;
        final table17 = salesData?.table17;
        return Container(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 12.0),
          decoration: commonCardDecoration(),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      "Channel Partner",
                      style: AppTextStyle.ts14M(
                        color: AppColor.black.withValues(alpha: 0.50),
                      ),
                    ),
                  ),
                ],
              ),
              verticalSpacing(height: 20),
              if (table18List != null) ...[
                Row(
                  children: [
                    Expanded(
                      child: _sourceChannelPartnerCard(
                        title: "IBM",
                        percentage: table18List.inboundConversionRate,
                        subTitle: "Inbound Meetings",
                        subTitleColor: const Color(0xFFFF8A00),
                        bgColor: const Color(0xFFFFF7ED),
                        borderColor: const Color(0xFFFFA742),
                        valueColor: const Color(0xFFFF8A00),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _sourceChannelPartnerCard(
                        title: "OBM",
                        percentage: table18List.outboundConversionRate,
                        subTitle: "Outbound Meetings",
                        subTitleColor: AppColor.purple,
                        bgColor: AppColor.lightPurple,
                        borderColor: AppColor.purple,
                        valueColor: AppColor.purple,
                      ),
                    ),
                  ],
                ),
              ] else ...[
                const SizedBox.shrink(),
              ],
              verticalSpacing(),
              if (table17 != null && table17.isNotEmpty) ...[
                ListView.builder(
                  itemCount: table17.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, int index) {
                    var item = table17[index];
                    return Container(
                      margin: EdgeInsets.all(8.0),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 16.0,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4.0),
                        color: AppColor.lightGreyBackground,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  item.channelPartnerName,
                                  style: AppTextStyle.ts14SB(),
                                ),
                              ),
                              Text(
                                item.bookingValueInCr.toString(),
                                style: AppTextStyle.ts14SB(
                                  color: AppColor.green,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  "${item.totalBookings.toString()} bookings",
                                  style: AppTextStyle.ts12R(
                                    color: AppColor.black.withValues(
                                      alpha: 0.50,
                                    ),
                                  ),
                                ),
                              ),
                              Text(
                                "${item.conversionPercent}% conv",
                                style: AppTextStyle.ts12R(),
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
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      "No Channel Partner Data Available",
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

  Widget _sourceChannelPartnerCard({
    required String title,
    required String percentage,
    required String subTitle,
    required Color subTitleColor,
    required Color bgColor,
    required Color borderColor,
    required Color valueColor,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 110),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: bgColor,
        border: Border.all(width: 1, color: borderColor.withValues(alpha: 0.6)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyle.ts14M(
              color: AppColor.black.withValues(alpha: 0.5),
            ),
          ),
          Text("$percentage %", style: AppTextStyle.ts16SB(color: valueColor)),
          Text(
            subTitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyle.ts14M(color: subTitleColor),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesLeaderboardWidget(BuildContext context) {
    return BlocBuilder<SalesDashboardCubit, SalesDashboardState>(
      builder: (context, state) {
        if (state.isLoading == true) {
          return Center(child: loader());
        }

        final salesData = state.salesData;

        final table3 = salesData?.table3;

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
                      "Sales Leaderboard",
                      style: AppTextStyle.ts14M(
                        color: AppColor.black.withValues(alpha: 0.50),
                      ),
                    ),
                  ),
                ],
              ),
              verticalSpacing(height: 20),
              if (table3 != null && table3.isNotEmpty) ...[
                ListView.builder(
                  itemCount: table3.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, int index) {
                    var item = table3[index];
                    final bool isLast = index == table3.length - 1;
                    return Column(
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
                            horizontalSpacing(),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.fullName,
                                    style: AppTextStyle.ts16M(),
                                  ),
                                  Text(
                                    item.designation,
                                    style: AppTextStyle.ts14R(
                                      color: AppColor.black.withValues(
                                        alpha: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        verticalSpacing(height: 20.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Bookings",
                                  style: AppTextStyle.ts12R(
                                    color: AppColor.black.withValues(
                                      alpha: 0.50,
                                    ),
                                  ),
                                ),
                                Text(
                                  item.bookingFromEnquiry.toString(),
                                  style: AppTextStyle.ts14SB(
                                    color: AppColor.black,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Booking Value",
                                  style: AppTextStyle.ts12R(
                                    color: AppColor.black.withValues(
                                      alpha: 0.50,
                                    ),
                                  ),
                                ),
                                Text(
                                  "₹${item.achievedAmount}",
                                  style: AppTextStyle.ts14SB(
                                    color: AppColor.black,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Conversation Rate",
                                  style: AppTextStyle.ts12R(
                                    color: AppColor.black.withValues(
                                      alpha: 0.50,
                                    ),
                                  ),
                                ),
                                Text(
                                  "31%",
                                  style: AppTextStyle.ts14SB(
                                    color: AppColor.green,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        verticalSpacing(height: 20.0),
                        if (!isLast) ...[
                          Divider(
                            thickness: 0.5,
                            color: AppColor.black.withValues(alpha: 0.5),
                          ),
                          verticalSpacing(height: 20.0),
                        ],
                      ],
                    );
                  },
                ),
              ] else ...[
                Center(
                  child: Text(
                    "No Leaderboard Data Available",
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
*/
}

class DashboardStatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color? titleColor;
  final Color? valueColor;
  final Widget? footer;
  final BoxDecoration? decoration;
  final EdgeInsetsGeometry padding;
  final Widget? trailing;
  final double borderRadius;
  final Widget? leadingStripe;

  const DashboardStatCard({
    super.key,
    required this.title,
    required this.value,
    this.titleColor,
    this.valueColor,
    this.footer,
    this.decoration,
    this.padding = const EdgeInsets.all(12),
    this.trailing,
    this.borderRadius = 16,
    this.leadingStripe,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:
          decoration ??
          BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: [
              BoxShadow(
                color: AppColor.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
      child: Row(
        children: [
          if (leadingStripe != null) leadingStripe!,
          Expanded(
            child: Padding(
              padding: padding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: AppTextStyle.ts14M(color: titleColor)),
                  Text(value, style: AppTextStyle.ts20B(color: valueColor)),
                  if (footer != null) footer!,
                ],
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class EnquiryProgressBar extends StatelessWidget {
  final String title;
  final int percentage;
  final String? conversionText;
  final String? breakdownText;

  const EnquiryProgressBar({
    super.key,
    required this.title,
    required this.percentage,
    this.conversionText,
    this.breakdownText,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (percentage / 100).clamp(0.0, 1.0);

    return BlocBuilder<SalesDashboardCubit, SalesDashboardState>(
      builder: (context, state) {
        if (state.isLoading == true) {
          return Center(child: loader());
        }
        final salesData = state.salesData;

        final table2 = salesData?.table2;
        return (table2 != null && table2.isNotEmpty)
            ? Padding(
              padding: const EdgeInsets.only(bottom: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyle.ts16SB(color: AppColor.primary),
                  ),
                  const SizedBox(height: 10),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final barWidth = constraints.maxWidth * progress;
                      return Stack(
                        children: [
                          Container(
                            height: 24,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColor.lightBlue.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          Container(
                            height: 24,
                            width: barWidth,
                            decoration: BoxDecoration(
                              color: AppColor.primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  if (breakdownText != null)
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Hot: ",
                            style: AppTextStyle.ts12R(color: AppColor.red),
                          ),
                          TextSpan(
                            text: "${table2.first.hotLeads}",
                            style: AppTextStyle.ts12R(color: AppColor.red),
                          ),
                          TextSpan(
                            text: " | Warm: ",
                            style: AppTextStyle.ts12R(color: AppColor.warning),
                          ),
                          TextSpan(
                            text: "${table2.first.warmLeads}",
                            style: AppTextStyle.ts12R(color: AppColor.warning),
                          ),
                          TextSpan(
                            text: " | Cold: ",
                            style: AppTextStyle.ts12R(color: AppColor.primary),
                          ),
                          TextSpan(
                            text: "${table2.first.coldLeads}",
                            style: AppTextStyle.ts12R(color: AppColor.primary),
                          ),
                        ],
                      ),
                    )
                  else if (conversionText != null)
                    Text(
                      conversionText!,
                      style: AppTextStyle.ts12R(
                        color: AppColor.black.withValues(alpha: 0.5),
                      ),
                    ),
                ],
              ),
            )
            : Center(
              child: Text(
                "No Enquiry Available",
                style: AppTextStyle.ts12M(
                  color: AppColor.black.withValues(alpha: 0.50),
                ),
              ),
            );
      },
    );
  }
}

class SourceProgressBar extends StatelessWidget {
  final String title;
  final num percentage;

  const SourceProgressBar({
    super.key,
    required this.title,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (percentage / 100).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyle.ts16M(
                    color: AppColor.black.withValues(alpha: 0.7),
                  ),
                ),
              ),
              Text(
                "${percentage.toStringAsFixed(1)}%",
                style: AppTextStyle.ts16M(
                  color: AppColor.black.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            height: 12,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColor.lightBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColor.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BudgetChartData {
  final String month;
  final double value; // NUMERIC FOR BAR LENGTH
  final String slab; // LABEL SHOWN ON X AXIS

  BudgetChartData({
    required this.month,
    required this.value,
    required this.slab,
  });
}

class StatusColor {
  final Color bg;
  final String text;
  final Color textColor;

  const StatusColor({
    required this.bg,
    required this.text,
    required this.textColor,
  });
}
