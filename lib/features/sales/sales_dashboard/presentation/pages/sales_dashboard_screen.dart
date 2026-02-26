import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:k3h_erp_app/core/local_storage_manager.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/models/user.model.dart';
import 'package:k3h_erp_app/core/presentation/pages/main_screen.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:k3h_erp_app/features/dashboard/presentation/widget/project_selector_overlay.dart';
import 'package:k3h_erp_app/features/masters/project_master/data/repository/project_master.repository.dart';
import 'package:k3h_erp_app/features/sales/sales_dashboard/data/model/sales.dashboard.model.dart';
import 'package:k3h_erp_app/features/sales/sales_dashboard/presentation/cubit/sales_dashboard_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/storage_key.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/network_image_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class SalesDashboardScreen extends StatefulWidget {
  const SalesDashboardScreen({super.key});

  @override
  State<SalesDashboardScreen> createState() => _SalesDashboardScreenState();
}

class _SalesDashboardScreenState extends State<SalesDashboardScreen> {
  // PROJECT MASTER REPOSITORY
  final ProjectMasterRepository _projectMasterRepository =
      serviceLocator<ProjectMasterRepository>();

  // CUBIT
  late SalesDashboardCubit _salesDashboardCubit;

  final ValueNotifier<List<ProjectModel>> _projectListNotifier = ValueNotifier(
    [],
  );

  final ValueNotifier<bool> _showOverlayNotifier = ValueNotifier(false);

  int selectedAreaIndex = 0;

  ProjectModel? _selectedProject;

  // FOR ANIMATION
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  List<int> enquiriesList = [0, 1, 2];
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
    _salesDashboardCubit = context.read<SalesDashboardCubit>();
    _loadProjects();
    _salesDashboardCubit.getSalesDashboardList(context, getProject().projectId);
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

      // Remove from list first
      enquiriesList.removeAt(index);

      // Trigger animation
      _listKey.currentState?.removeItem(
        index,
        (context, animation) => _buildAnimatedItem(removedItem, animation),
        duration: const Duration(milliseconds: 300),
      );

      setState(() {});
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SalesDashboardCubit, SalesDashboardState>(
      builder: (context, state) {
        if (state.isLoading!) {
          return Center(child: loader());
        }
        return Scaffold(
          appBar: AppBar(
            centerTitle: false,
            leading: IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                mobileScreenGlobalScaffoldKey.currentState?.openDrawer();
              },
            ),
            title: const Text("Sales Dashboard"),
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
                      // GENERATE REPORT
                      Container(
                        width: 160,
                        padding: EdgeInsets.symmetric(
                          vertical: 5.0,
                          horizontal: 6.0,
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
                      verticalSpacing(),
                      _buildOverviewWidget(context),
                      _buildEnquiryOverviewWidget(context),
                      verticalSpacing(),
                      _buildEnquiriesWidget(context),
                      verticalSpacing(),
                      _buildTargetPerformanceWidget(context),
                      verticalSpacing(),
                      _buildActiveFollowUpsWidget(context),
                      verticalSpacing(),
                      _buildCallTrackerWidget(context),
                      verticalSpacing(),
                      _buildSalesDistributionWidget(context),
                      verticalSpacing(),
                      _buildReportsWidget(context),
                      verticalSpacing(),
                      _buildChannelPartnerWidget(context),
                      verticalSpacing(),
                      _buildSalesLeaderboardWidget(context),
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
      },
    );
  }

  Widget _buildOverviewWidget(BuildContext context) {
    return BlocBuilder<SalesDashboardCubit, SalesDashboardState>(
      builder: (context, state) {
        if (state.isLoading == true) {
          return Center(child: loader());
        }
        final salesData = state.salesData;
        if (salesData == null || salesData.table0.isEmpty) {
          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 20.0,
            ),
            decoration: commonCardDecoration(),
            child: const Center(child: Text("No Attendance Data Available")),
          );
        }
        final table0 = salesData.table0.first;
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
              value: "${table0.totalEnquiries}",
              titleColor: AppColor.white,
              footer: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text:
                          "↑ ${table0.increaseEnquiryPercentage.toDouble()}% ",
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
              value: "${table0.newLeadsThisMonth}",
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
              value: "${table0.activeFollowUps}",
              footer: Text(
                "${table0.todaysFollowUpDues} Due Today",
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
              value: "${table0.lostLeadsToday}",
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
              value: "${table0.todayBookings}",
              footer: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "↑ ${table0.totalBookingConversion}% ",
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
              value: "₹ ${table0.todayBookingValue}",
              footer: Text(
                "Avg: ₹${table0.averageBookingValue.toDouble()}L",
                style: AppTextStyle.ts12R(color: AppColor.primary),
              ),
            ),
            DashboardStatCard(
              title: "Target vs Achieved",
              titleColor: AppColor.black.withValues(alpha: 0.50),
              value: "${table0.achieved}%",
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
              value: "${table0.cpPercentage}%",
              footer: Text(
                "${table0.activeCp} active partners",
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

        if (salesData == null || salesData.table1.isEmpty) {
          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 20.0,
            ),
            decoration: commonCardDecoration(),
            child: const Center(child: Text("No Daily Attendance Data")),
          );
        }
        final table1 = salesData.table1.first;
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

        if (salesData == null || salesData.table1.isEmpty) {
          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 20.0,
            ),
            decoration: commonCardDecoration(),
            child: const Center(child: Text("No Daily Attendance Data")),
          );
        }
        final table1List = salesData.table1;
        return Column(
          children: [
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
          ],
        );
      },
    );
  }

  Color _getPerformanceBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'excellent':
        return const Color(0xFFE8F8F1); // light green bg
      case 'good':
        return const Color(0xFFEAF6FB); // light blue bg
      case 'average':
        return const Color(0xFFFFF4E5); // light yellow bg
      case 'at risk':
        return const Color(0xFFFFEBEE); // light red bg
      default:
        return AppColor.white;
    }
  }

  Color _getPerformancePrimaryColor(String status) {
    switch (status.toLowerCase()) {
      case 'excellent':
        return const Color(0xFF1ABC9C); // green
      case 'good':
        return const Color(0xFF2D9CDB); // blue
      case 'average':
        return const Color(0xFFF2C94C); // yellow
      case 'at risk':
        return const Color(0xFFEB5757); // red
      default:
        return AppColor.primary;
    }
  }

  Widget _buildTargetPerformanceWidget(BuildContext context) {
    return BlocBuilder<SalesDashboardCubit, SalesDashboardState>(
      builder: (context, state) {
        if (state.isLoading == true) {
          return Center(child: loader());
        }

        final salesData = state.salesData;

        if (salesData == null || salesData.table3.isEmpty) {
          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 20.0,
            ),
            decoration: commonCardDecoration(),
            child: const Center(child: Text("No Daily Attendance Data")),
          );
        }
        final table3List = salesData.table3;
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

  Widget _buildEnquiriesWidget(BuildContext context) {
    return Container(
      height: 300.0,
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
                  "Enquiries",
                  style: AppTextStyle.ts14M(
                    color: AppColor.black.withValues(alpha: 0.50),
                  ),
                ),
              ),
            ],
          ),
          verticalSpacing(height: 10.0),
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
        ],
      ),
    );
  }

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

  Widget _buildActiveFollowUpsWidget(BuildContext context) {
    return Container(
      height: 300.0,
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
        ],
      ),
    );
  }

  Widget _buildCallTrackerWidget(BuildContext context) {
    return BlocBuilder<SalesDashboardCubit, SalesDashboardState>(
      builder: (context, state) {
        if (state.isLoading == true) {
          return Center(child: loader());
        }

        final salesData = state.salesData;

        if (salesData == null || salesData.table6.isEmpty) {
          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 20.0,
            ),
            decoration: commonCardDecoration(),
            child: const Center(child: Text("No Daily Attendance Data")),
          );
        }
        final table6List = salesData.table6.first;
        final table0 = salesData.table0.first;
        final table8List = salesData.table8;
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CallTrackerRadialChart(
                    connected: table0.todayConnected,
                    notConnected: table0.todayNotConnected,
                    rescheduled: table0.todayRescheduled,
                    closed: table0.todayClosed,
                  ),
                ],
              ),
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
                              style: AppTextStyle.ts16M(color: AppColor.black),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

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

  Widget _buildSalesDistributionWidget(BuildContext context) {
    return BlocBuilder<SalesDashboardCubit, SalesDashboardState>(
      builder: (context, state) {
        if (state.isLoading == true) {
          return Center(child: loader());
        }

        final salesData = state.salesData;

        if (salesData == null || salesData.table9.isEmpty) {
          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 20.0,
            ),
            decoration: commonCardDecoration(),
            child: const Center(child: Text("No Daily Attendance Data")),
          );
        }
        final table9List = salesData.table9.first;
        final table12 = salesData.table12;
        final table13 = salesData.table13;
        final table14 = salesData.table14;
        final table1List = salesData.table1.first;
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
              verticalSpacing(),
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
              Divider(
                color: AppColor.black.withValues(alpha: 0.50),
                thickness: 0.3,
              ),
              verticalSpacing(),
              Text("Area Wise Distribution", style: AppTextStyle.ts14SB()),
              verticalSpacing(),
              areaToggle(),
              verticalSpacing(height: 16.0),
              _buildAreaWiseList(table13: table13, table14: table14),
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
                      "${table1List.bookingConversion.toDouble()}",
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

          /// 👇 This makes bottom labels like Figma slabs
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

        /// ⭐ Y AXIS = MONTH (LEFT SIDE like Figma)
        primaryYAxis: CategoryAxis(
          labelStyle: AppTextStyle.ts14M(
            color: AppColor.black.withValues(alpha: 0.5),
          ),
          axisLine: const AxisLine(width: 1),
          majorTickLines: const MajorTickLines(size: 6),
        ),

        /// ⭐ CRITICAL: <T, String> (because Y axis is category)
        series: <CartesianSeries<BudgetChartData, dynamic>>[
          BarSeries<BudgetChartData, dynamic>(
            dataSource: chartData,

            /// LEFT → Month (STRING ✔)
            yValueMapper: (BudgetChartData data, _) => data.value,

            /// BAR LENGTH → MUST be DOUBLE ✔ (THIS FIXES YOUR ERROR)
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
        selectedAreaIndex == 0 ? table13 : table14;

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
          // Title
          Expanded(
            child: Text(
              title,
              style: AppTextStyle.ts14M(
                color: AppColor.black.withValues(alpha: 0.5),
              ),
            ),
          ),
          // Percentage
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

  Widget _buildChannelPartnerWidget(BuildContext context) {
    return BlocBuilder<SalesDashboardCubit, SalesDashboardState>(
      builder: (context, state) {
        if (state.isLoading == true) {
          return Center(child: loader());
        }

        final salesData = state.salesData;

        if (salesData == null || salesData.table18.isEmpty) {
          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 20.0,
            ),
            decoration: commonCardDecoration(),
            child: const Center(child: Text("No Daily Attendance Data")),
          );
        }
        final table18List = salesData.table18.first;
        final table17 = salesData.table17;
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
              verticalSpacing(),
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
                              style: AppTextStyle.ts14SB(color: AppColor.green),
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
                                  color: AppColor.black.withValues(alpha: 0.50),
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

        if (salesData == null || salesData.table3.isEmpty) {
          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 20.0,
            ),
            decoration: commonCardDecoration(),
            child: const Center(child: Text("No Daily Attendance Data")),
          );
        }
        final table3 = salesData.table3;

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
                                  color: AppColor.black.withValues(alpha: 0.50),
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
                                  color: AppColor.black.withValues(alpha: 0.50),
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
                                  color: AppColor.black.withValues(alpha: 0.50),
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
            ],
          ),
        );
      },
    );
  }
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

        if (salesData == null || salesData.table2.isEmpty) {
          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 20.0,
            ),
            decoration: commonCardDecoration(),
            child: const Center(child: Text("No Daily Attendance Data")),
          );
        }
        final table2List = salesData.table2;
        return Padding(
          padding: const EdgeInsets.only(bottom: 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyle.ts16SB(color: AppColor.primary)),
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
                        text: "${table2List.first.hotLeads}",
                        style: AppTextStyle.ts12R(color: AppColor.red),
                      ),
                      TextSpan(
                        text: " | Warm: ",
                        style: AppTextStyle.ts12R(color: AppColor.warning),
                      ),
                      TextSpan(
                        text: "${table2List.first.warmLeads}",
                        style: AppTextStyle.ts12R(color: AppColor.warning),
                      ),
                      TextSpan(
                        text: " | Cold: ",
                        style: AppTextStyle.ts12R(color: AppColor.primary),
                      ),
                      TextSpan(
                        text: "${table2List.first.coldLeads}",
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
        );
      },
    );
  }
}

class CallTrackerRadialChart extends StatelessWidget {
  final int connected;
  final int notConnected;
  final int rescheduled;
  final int closed;

  const CallTrackerRadialChart({
    super.key,
    required this.connected,
    required this.notConnected,
    required this.rescheduled,
    required this.closed,
  });

  int get total => connected + notConnected + rescheduled + closed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              height: 110,
              width: 110,
              child: CustomPaint(
                painter: RadialPainter(
                  connected: connected,
                  notConnected: notConnected,
                  rescheduled: rescheduled,
                  closed: closed,
                ),
              ),
            ),
            const SizedBox(width: 30),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _legend(AppColor.primary, rescheduled, "Rescheduled"),
                const SizedBox(height: 8),
                _legend(AppColor.blue, connected, "Connected"),
                const SizedBox(height: 8),
                _legend(AppColor.grey50, notConnected, "Not Connected"),
                const SizedBox(height: 8),
                _legend(AppColor.black, closed, "Closed"),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _legend(Color color, int value, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min, // ⭐ prevents flex overflow
      children: [
        Container(
          height: 14,
          width: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(100),
          ),
        ),
        const SizedBox(width: 8),
        Text(value.toString().padLeft(2, '0'), style: AppTextStyle.ts16SB()),
        const SizedBox(width: 6),
        Flexible(
          // ⭐ NOT Expanded
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyle.ts16M(
              color: AppColor.black.withValues(alpha: 0.5),
            ),
          ),
        ),
      ],
    );
  }
}

class RadialPainter extends CustomPainter {
  final int connected;
  final int notConnected;
  final int rescheduled;
  final int closed;

  RadialPainter({
    required this.connected,
    required this.notConnected,
    required this.rescheduled,
    required this.closed,
  });

  final double stroke = 20;
  final double gapDegrees = 25;

  @override
  void paint(Canvas canvas, Size size) {
    final total = connected + notConnected + rescheduled + closed;

    final center = size.center(Offset.zero);
    final radius = size.width / 2.2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round;

    // Total degrees available after gaps
    final usable = 360 - (gapDegrees * 3);

    final connectedSweep = (connected / total) * usable;
    final notConnectedSweep = (notConnected / total) * usable;
    final rescheduledSweep = (rescheduled / total) * usable;
    final closedSweep = (closed / total) * usable;

    // ⭐ KEY: center PRESENT arc at top
    double start = -90 - (connectedSweep / 2);

    void draw(Color color, double sweep) {
      paint.color = color;
      canvas.drawArc(rect, _deg(start), _deg(sweep), false, paint);
      start += sweep + gapDegrees;
    }

    draw(AppColor.primary, rescheduledSweep); // Rescheduled
    draw(AppColor.blue, connectedSweep); // Connected
    draw(AppColor.grey50, notConnectedSweep); // Not Connected
    draw(AppColor.black, closedSweep); // Closed
  }

  double _deg(double d) => d * pi / 180;

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
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
  final double value; // numeric for bar length
  final String slab; // label shown on X axis

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
