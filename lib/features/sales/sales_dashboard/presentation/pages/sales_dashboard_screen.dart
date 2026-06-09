// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/local_storage_manager.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/models/user.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/sales/sales_dashboard/data/model/sales.dashboard.model.dart';
import 'package:k3h_erp_app/features/sales/sales_dashboard/presentation/cubit/sales_dashboard_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/storage_key.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/chip_style_tab_bar.dart';
import 'package:k3h_erp_app/widgets/custom_click_to_contact_widget.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class SalesDashboardScreen extends StatefulWidget {
  const SalesDashboardScreen({super.key});

  @override
  State<SalesDashboardScreen> createState() => _SalesDashboardScreenState();
}

class _SalesDashboardScreenState extends State<SalesDashboardScreen>
    with SingleTickerProviderStateMixin {
  // CUBIT
  late SalesDashboardCubit _salesDashboardCubit;

  // PROJECT MODEL
  late ProjectModel _selectedProject;

  // USER MODEL
  late UserModel? _user;

  // TAB CONTROLLER
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _salesDashboardCubit = context.read<SalesDashboardCubit>();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
    getCurrentUser();
    _selectedProject = getProject();
    _salesDashboardCubit.getSalesDashboardList(
      context,
      _selectedProject.projectId,
    );
  }

  Future getCurrentUser() async {
    var userJson = jsonDecode(
      LocalStorageManager().getString(StorageKey.currentUser) ?? "",
    );
    _user = UserModel.fromJson(userJson);
  }

  Table2? getCurrentUserDataClosing(List<Table2> list) {
    final empId = _user?.employeeId;

    if (empId == null) return null;

    return list.where((e) => e.employeeId == empId).isNotEmpty
        ? list.firstWhere((e) => e.employeeId == empId)
        : null;
  }

  Table3? getCurrentUserDataSourcing(List<Table3> list) {
    final empId = _user?.employeeId;

    if (empId == null) return null;

    return list.where((e) => e.employeeId == empId).isNotEmpty
        ? list.firstWhere((e) => e.employeeId == empId)
        : null;
  }

  // HANDLE TAB CHANGE
  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      _salesDashboardCubit.onTabChanged(_tabController.index, context);
    }
  }

  Future<void> _showMarkAsTimeOutPopup(
    BuildContext context,
    Table0 item,
  ) async {
    final shouldRemove = await DialogHelper.showConfirmationDialog(
      context: context,
      title: 'Are you sure you want to mark Time Out?',
      message: '',
      confirmText: "Time Out",
    );
    if (shouldRemove == true) {
      _salesDashboardCubit.markTimeOutEnquiry(
        context: context,
        enquiryId: item.enquiryId,
        projectId: item.projectId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        _salesDashboardCubit.getSalesDashboardList(
          context,
          _selectedProject.projectId,
        );
      },
      child: BlocBuilder<SalesDashboardCubit, SalesDashboardState>(
        builder: (context, state) {
          if (state.isLoading!) {
            return Center(child: loader());
          }
          return Scaffold(
            appBar: CustomAppBarWithBackButton(
              screenTitle: "Sales Dashboard",
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
                              style: AppTextStyle.ts14M(
                                color: AppColor.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    verticalSpacing(height: 16),
                    _buildEnquiriesWidget(context),
                    verticalSpacing(height: 16), 
                    _buildActiveFollowUpsWidget(context),
                    verticalSpacing(height: 16),
                    _buildPerformanceWidget(context),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEnquiriesWidget(BuildContext context) {
    return BlocBuilder<SalesDashboardCubit, SalesDashboardState>(
      builder: (context, state) {
        if (state.isLoading == true) {
          return Center(child: loader());
        }

        final data =
            (state.salesDashboardList.isNotEmpty)
                ? state.salesDashboardList.first.table0
                : <Table0>[];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: commonCardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Enquiries  (Today's)",
                style: AppTextStyle.ts14M(
                  color: AppColor.greyTitleAndValueColor.withValues(
                    alpha: 0.50,
                  ),
                ),
              ),
              verticalSpacing(height: 10.0),
              if (data.isNotEmpty) ...[
                SizedBox(
                  height: data.length > 1 ? 0.4.sh : null,
                  child: SingleChildScrollView(
                    child: Column(
                      children:
                          List.generate(data.length, (index) {
                            final item = data[index];
                            final isLast = index == data.length - 1;
                            return Container(
                              margin:
                                  !isLast
                                      ? EdgeInsets.only(bottom: 10)
                                      : EdgeInsets.zero,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12.0,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: AppColor.lightGreyBackground,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: _infoColumn(
                                          "Project Name",
                                          item.projectName,
                                        ),
                                      ),
                                      horizontalSpacing(),
                                      Expanded(
                                        child: _infoColumn(
                                          "Enquiry Code",
                                          item.systemGeneratedCode,
                                          customWidget: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  item.systemGeneratedCode,
                                                  style: AppTextStyle.ts14M(),
                                                ),
                                              ),
                                              horizontalSpacing(width: 2),
                                              InkWell(
                                                onTap: () {
                                                  copy(
                                                    context: context,
                                                    text:
                                                        item.systemGeneratedCode,
                                                  );
                                                },
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        top: 2,
                                                      ),
                                                  child: Icon(
                                                    Icons.copy,
                                                    size: 16,
                                                    color: AppColor.primary,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  verticalSpacing(),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: _infoColumn(
                                          "Client Name",
                                          item.name,
                                        ),
                                      ),
                                      horizontalSpacing(),
                                      Expanded(
                                        child: _infoColumn(
                                          "Mobile Number",
                                          item.mobileNumber,
                                          customWidget: CustomClickToContactText(
                                            value:
                                                "${item.mobileNumberCountryCode} ${item.mobileNumber}",
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  verticalSpacing(),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: _infoColumn(
                                          "Date",
                                          formatDateTimeAsDDMMMYYYY(
                                            item.enquiryDate,
                                          ),
                                        ),
                                      ),
                                      horizontalSpacing(),
                                      Expanded(
                                        child: _infoColumn(
                                          "Customer Time-in",
                                          item.enquiryTimeIn,
                                        ),
                                      ),
                                    ],
                                  ),
                                  verticalSpacing(),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: _infoColumn(
                                          "Sales Advisor",
                                          item.salesAdvisor,
                                        ),
                                      ),
                                      horizontalSpacing(),
                                      Expanded(
                                        child: _infoColumn(
                                          "Sourcing Manager",
                                          item.sourcingManager.isEmpty
                                              ? "-"
                                              : item.sourcingManager,
                                        ),
                                      ),
                                    ],
                                  ),
                                  verticalSpacing(),
                                  CustomButton(
                                    text: "Time Out",
                                    backgroundColor:
                                        item.canTimeOut == 0
                                            ? AppColor.grey2
                                            : AppColor.primary,
                                    onPressed:
                                        item.canTimeOut == 0
                                            ? null
                                            : () {
                                              _showMarkAsTimeOutPopup(
                                                context,
                                                item,
                                              );
                                            },
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                    ),
                  ),
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

  Widget _buildActiveFollowUpsWidget(BuildContext context) {
    return BlocBuilder<SalesDashboardCubit, SalesDashboardState>(
      builder: (context, state) {
        if (state.isLoading == true) {
          return Center(child: loader());
        }

        final data =
            (state.salesDashboardList.isNotEmpty)
                ? state.salesDashboardList.first.table1
                : <Table1>[];
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
              Text(
                "Follow Up",
                style: AppTextStyle.ts14M(
                  color: AppColor.greyTitleAndValueColor.withValues(
                    alpha: 0.50,
                  ),
                ),
              ),
              verticalSpacing(height: 10.0),
              if (data.isNotEmpty) ...[
                SizedBox(
                  height: data.length > 1 ? 300 : null,
                  child: ListView.separated(
                    itemCount: data.length,
                    shrinkWrap: true,
                    physics:
                        data.length > 1
                            ? AlwaysScrollableScrollPhysics()
                            : NeverScrollableScrollPhysics(),
                    separatorBuilder: (context, index) => SizedBox(height: 12),
                    itemBuilder: (context, int index) {
                      final activeFollowUps = data[index];
                      final bool isLast = index == data.length - 1;
                      return Container(
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: _infoColumn(
                                    "Project Name",
                                    activeFollowUps.projectName,
                                  ),
                                ),
                                horizontalSpacing(),
                                Expanded(
                                  child: _infoColumn(
                                    "Enquiry Code",
                                    activeFollowUps.systemGeneratedCode,
                                    customWidget: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            activeFollowUps.systemGeneratedCode,
                                            style: AppTextStyle.ts14M(),
                                          ),
                                        ),
                                        horizontalSpacing(width: 2),
                                        InkWell(
                                          onTap: () {
                                            copy(
                                              context: context,
                                              text:
                                                  activeFollowUps
                                                      .systemGeneratedCode,
                                            );
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              top: 2,
                                            ),
                                            child: Icon(
                                              Icons.copy,
                                              size: 16,
                                              color: AppColor.primary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
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
                                  child: _infoColumn(
                                    "Client Name",
                                    activeFollowUps.name,
                                    customWidget: InkWell(
                                      onTap: () async {
                                        await loadAndSelectProjectById(
                                          activeFollowUps.projectId,
                                        );
                                        goRouter.pushNamed(
                                          AppRoutes.enquiry,
                                          queryParameters: {
                                            "enquiryName":
                                                Uri.encodeQueryComponent(
                                                  EncryptionManager.encryptData(
                                                    activeFollowUps.name,
                                                  ),
                                                ),
                                            "enquiryCode":
                                                Uri.encodeQueryComponent(
                                                  EncryptionManager.encryptData(
                                                    activeFollowUps
                                                        .systemGeneratedCode,
                                                  ),
                                                ),
                                          },
                                        );
                                      },
                                      child: Text(
                                        activeFollowUps.name,
                                        style:
                                            activeFollowUps.isAction == 1
                                                ? AppTextStyle.ts14M().copyWith(
                                                  color: AppColor.primary,
                                                  decoration:
                                                      TextDecoration.underline,
                                                  decorationColor:
                                                      AppColor.primary,
                                                )
                                                : AppTextStyle.ts14M(),
                                      ),
                                    ),
                                  ),
                                ),
                                horizontalSpacing(),
                                Expanded(
                                  child: _infoColumn(
                                    "Mobile Number",
                                    activeFollowUps.mobileNumber,
                                    customWidget: CustomClickToContactText(
                                      value:
                                          "${activeFollowUps.mobileNumberCountryCode} ${activeFollowUps.mobileNumber}",
                                    ),
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
                                  child: _infoColumn(
                                    "Due Day(s)",
                                    activeFollowUps.nextFollowUpDate
                                            ?.toIso8601String() ??
                                        "-",
                                    customWidget: followUpStatusTextWidget(
                                      activeFollowUps.nextFollowUpDate,
                                    ),
                                  ),
                                ),
                                horizontalSpacing(),
                                Expanded(
                                  child: _infoColumn(
                                    "Next FollowUp Date",
                                    activeFollowUps.nextFollowUpDate == null
                                        ? '-'
                                        : formatDateTimeAsDDMMMYYYY(
                                          activeFollowUps.nextFollowUpDate!,
                                        ),
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
                                  child: _infoColumn(
                                    "Sales Advisor",
                                    activeFollowUps.salesAdvisor,
                                  ),
                                ),
                                horizontalSpacing(),
                                Expanded(
                                  child: _infoColumn(
                                    "Sourcing Manager",
                                    activeFollowUps.sourcingManager.isEmpty
                                        ? '-'
                                        : activeFollowUps.sourcingManager,
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
                                  child: _infoColumn(
                                    "Created Date",
                                    formatDateTimeAsDDMMMYYYY(
                                      activeFollowUps.createdDate,
                                    ),
                                  ),
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
                                      color: AppColor.black.withValues(
                                        alpha: 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 16,
                                  child: Center(
                                    child: Text(
                                      ":",
                                      style: AppTextStyle.ts14M(
                                        color: AppColor.black.withValues(
                                          alpha: 0.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                horizontalSpacing(width: 20),
                                Expanded(
                                  child:
                                      activeFollowUps.finalStage.isEmpty
                                          ? Text(
                                            "-",
                                            style: AppTextStyle.ts12M(),
                                          )
                                          : enquiryStatusWidget(
                                            activeFollowUps.finalStage,
                                          ),
                                ),
                                !isLast ? SizedBox.shrink() : SizedBox.shrink(),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
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

  Widget _infoColumn(String title, String value, {Widget? customWidget}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyle.ts12R(
            color: AppColor.black.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: 4),
        customWidget ??
            Text(value, style: AppTextStyle.ts14M(color: AppColor.black)),
      ],
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

  Widget _buildPerformanceWidget(BuildContext context) {
    return BlocBuilder<SalesDashboardCubit, SalesDashboardState>(
      builder: (context, state) {
        if (state.isLoading == true) {
          return Center(child: loader());
        }

        final closingData =
            (state.salesDashboardList.isNotEmpty)
                ? state.salesDashboardList.first.table2
                : <Table2>[];

        final sourcingData =
            (state.salesDashboardList.isNotEmpty)
                ? state.salesDashboardList.first.table3
                : <Table3>[];
        final userClosingData = getCurrentUserDataClosing(closingData);
        final userSourcingData = getCurrentUserDataSourcing(sourcingData);
        final hasClosingData =
            closingData.isNotEmpty && userClosingData != null;

        final hasSourcingData =
            sourcingData.isNotEmpty && userSourcingData != null;

        final showViewAll =
            (state.currentTabIndex == 0 && hasClosingData) ||
            (state.currentTabIndex == 1 && hasSourcingData);
        return Container(
          padding: const EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            top: 12.0,
            bottom: 8.0,
          ),
          decoration: commonCardDecoration(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                      text: "Performance Report",
                      style: AppTextStyle.ts14M(),
                      children: [
                        TextSpan(
                          text: "\n(Current Month)",
                          style: AppTextStyle.ts12M(color: AppColor.grey),
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: showViewAll,
                    child: CustomButton(
                      text: "View All",
                      titleTextStyle: AppTextStyle.ts12M(color: AppColor.white),
                      onPressed: () {
                        goRouter.pushNamed(AppRoutes.salesPerformanceReport);
                      },
                    ),
                  ),
                ],
              ),
              verticalSpacing(),
              ChipStyleTabBar(
                controller: _tabController,
                tabs: ["Closing", "Sourcing"],
                margin: EdgeInsets.zero,
              ),
              verticalSpacing(),
              Builder(
                builder: (_) {
                  if (state.currentTabIndex == 0) {
                    return _buildClosingExpansionList(closingData);
                  } else {
                    return _buildSourcingExpansionList(sourcingData);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSourcingExpansionList(List<Table3> list) {
    final data = getCurrentUserDataSourcing(list);

    if (_user == null) {
      return Center(child: loader());
    }

    if (data == null) {
      return Center(
        child: Column(
          children: [
            noDataWidget(
              message:
                  list.isEmpty
                      ? "No Performance Report Data Found"
                      : "No performance report available for the logged-in user.",
              iconSize: 180,
            ),
            if (list.isNotEmpty) ...[
              verticalSpacing(),
              SizedBox(
                width: 200.w,
                child: CustomButton(
                  text: "View Team Report",
                  titleTextStyle: AppTextStyle.ts12M(color: AppColor.white),
                  onPressed: () {
                    goRouter.pushNamed(AppRoutes.salesPerformanceReport);
                  },
                ),
              ),
            ],
          ],
        ),
      );
    }

    final walkinsExpanded = ValueNotifier(false);
    final bookingsExpanded = ValueNotifier(false);
    final meetingExpanded = ValueNotifier(false);
    final cpsExpanded = ValueNotifier(false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDescriptionRow(),
        verticalSpacing(height: 10),
        _buildExpandableCard(
          title: "Walkins",
          subTitle:
              "${((data.performanceWalkinsByCP + data.performanceFreshVisits + data.performanceRevisits) / 300) * 100}",
          notifier: walkinsExpanded,
          children: [
            _buildTitleRow(),
            Divider(color: AppColor.grey50),

            _buildRow(
              "Walkins By CP",
              data.walkinsByCP,
              data.actualWalkinsByCP,
              data.performanceWalkinsByCP,
            ),
            Divider(color: AppColor.grey50),
            _buildRow(
              "Fresh Visits",
              data.freshVisits,
              data.actualFreshVisits,
              data.performanceFreshVisits,
            ),
            Divider(color: AppColor.grey50),

            _buildRow(
              "Revisits",
              data.revisits,
              data.actualRevisits,
              data.performanceRevisits,
            ),
          ],
        ),

        _buildExpandableCard(
          title: "Bookings",
          subTitle: "${(data.performanceBookings)}",
          notifier: bookingsExpanded,
          children: [
            _buildTitleRow(),
            Divider(color: AppColor.grey50),

            _buildRow(
              "Bookings",
              data.bookings,
              data.actualBookings,
              data.performanceBookings,
            ),
          ],
        ),

        _buildExpandableCard(
          title: "Meetings",
          subTitle: "${(data.performanceTotalMeetings) / 500 * 100}",
          notifier: meetingExpanded,
          children: [
            _buildTitleRow(),
            Divider(color: AppColor.grey50),

            _buildRow(
              "Total Meetings",
              data.totalMeetings,
              data.actualTotalMeetings,
              data.performanceTotalMeetings,
            ),
            Divider(color: AppColor.grey50),
            _buildRow(
              "Total OBM",
              data.totalOBM,
              data.actualTotalOBM,
              data.performanceTotalOBM,
            ),
            Divider(color: AppColor.grey50),
            _buildRow(
              "OBM Fresh Visits",
              data.totalOBMFreshVisits,
              data.actualTotalOBMFreshVisits,
              data.performanceTotalOBMFreshVisits,
            ),
            Divider(color: AppColor.grey50),
            _buildRow(
              "OBM Revisits",
              data.totalOBMRevisits,
              data.actualTotalOBMRevisits,
              data.performanceTotalOBMRevisits,
            ),
            Divider(color: AppColor.grey50),
            _buildRow(
              "Total IBM",
              data.totalIBM,
              data.actualTotalIBM,
              data.performanceTotalIBM,
            ),
          ],
        ),

        _buildExpandableCard(
          title: "CPs",
          subTitle:
              "${(data.performanceUniqueCPs + data.performanceActiveCP + data.performanceNewCP)}",
          notifier: cpsExpanded,
          children: [
            _buildTitleRow(),
            Divider(color: AppColor.grey50),
            _buildRow(
              "Unique CPs",
              data.uniqueCPs,
              data.actualUniqueCPs,
              data.performanceUniqueCPs,
            ),
            Divider(color: AppColor.grey50),

            _buildRow(
              "Active CP",
              data.activeCP,
              data.actualActiveCP,
              data.performanceActiveCP,
            ),
            Divider(color: AppColor.grey50),

            _buildRow(
              "New CP",
              data.newCP,
              data.actualNewCP,
              data.performanceNewCP,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildClosingExpansionList(List<Table2> list) {
    final data = getCurrentUserDataClosing(list);

    if (_user == null) {
      return Center(child: loader());
    }

    if (data == null) {
      return Center(
        child: Column(
          children: [
            noDataWidget(
              message:
                  list.isEmpty
                      ? "No Performance Report Data Found"
                      : "No performance report available for the logged-in user.",
              iconSize: 180,
            ),
            if (list.isNotEmpty) ...[
              verticalSpacing(),
              SizedBox(
                width: 200.w,
                child: CustomButton(
                  text: "View Team Report",
                  titleTextStyle: AppTextStyle.ts12M(color: AppColor.white),
                  onPressed: () {
                    goRouter.pushNamed(AppRoutes.salesPerformanceReport);
                  },
                ),
              ),
            ],
          ],
        ),
      );
    }

    final walkinsExpanded = ValueNotifier(false);
    final bookingsExpanded = ValueNotifier(false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDescriptionRow(),
        verticalSpacing(height: 10),
        _buildExpandableCard(
          title: "Walkins",
          subTitle:
              "${((data.performanceWalkinsByCp + data.performanceFreshVisits + data.performanceRevisits + data.performanceWalkinsDirect) / 400) * 100}",
          notifier: walkinsExpanded,
          children: [
            _buildTitleRow(),
            Divider(color: AppColor.grey50),

            _buildRow(
              "Walkins By CP",
              data.walkinsByCp,
              data.actualWalkinsByCp,
              data.performanceWalkinsByCp,
            ),
            Divider(color: AppColor.grey50),
            _buildRow(
              "Walkins Direct",
              data.walkinsDirect,
              data.actualWalkinsDirect,
              data.performanceWalkinsDirect,
            ),
            Divider(color: AppColor.grey50),

            _buildRow(
              "Fresh Visits",
              data.freshVisits,
              data.actualFreshVisits,
              data.performanceFreshVisits,
            ),
            Divider(color: AppColor.grey50),

            _buildRow(
              "Revisits",
              data.revisits,
              data.actualRevisits,
              data.performanceRevisits,
            ),
          ],
        ),

        _buildExpandableCard(
          title: "Bookings",
          subTitle:
              (((data.performanceBookingByCp + data.performanceBookingDirect) /
                          200) *
                      100)
                  .toString(),
          notifier: bookingsExpanded,
          children: [
            _buildTitleRow(),
            Divider(color: AppColor.grey50),

            _buildRow(
              "Booking By CP",
              data.bookingByCp,
              data.actualBookingByCp,
              data.performanceBookingByCp,
            ),
            Divider(color: AppColor.grey50),

            _buildRow(
              "Booking Direct",
              data.bookingDirect,
              data.actualBookingDirect,
              data.performanceBookingDirect,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExpandableCard({
    required String title,
    required String subTitle,
    required ValueNotifier<bool> notifier,
    required List<Widget> children,
  }) {
    return ValueListenableBuilder<bool>(
      valueListenable: notifier,
      builder: (context, isExpanded, child) {
        return GestureDetector(
          onTap: () => notifier.value = !isExpanded,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppColor.white,
              border: Border.all(color: AppColor.lightGrey),
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: AppTextStyle.ts14M()),
                        Text(
                          "Performance: $subTitle %",
                          style: AppTextStyle.ts12M(color: AppColor.grey),
                        ),
                      ],
                    ),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                    ),
                  ],
                ),

                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child:
                      isExpanded
                          ? Column(
                            key: ValueKey(true),
                            children: [verticalSpacing(), ...children],
                          )
                          : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRow(String title, int target, int actual, double performance) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(title, style: AppTextStyle.ts12R())),
          Expanded(child: Text("$target", textAlign: TextAlign.center)),
          Expanded(child: Text("$actual", textAlign: TextAlign.center)),
          Expanded(
            child: Text(
              "${performance.toStringAsFixed(1)}%",
              textAlign: TextAlign.center,
              style: AppTextStyle.ts12M(
                color: performance >= 100 ? Colors.green : Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildTitleRow() {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Expanded(flex: 3, child: Text("Metrics", style: AppTextStyle.ts12SB())),
        Expanded(
          child: Text(
            "T",
            textAlign: TextAlign.center,
            style: AppTextStyle.ts12SB(),
          ),
        ),
        Expanded(
          child: Text(
            "A",
            textAlign: TextAlign.center,
            style: AppTextStyle.ts12SB(),
          ),
        ),
        Expanded(
          child: Text(
            "P",
            textAlign: TextAlign.center,
            style: AppTextStyle.ts12SB(),
          ),
        ),
      ],
    ),
  );
}

Widget _buildDescriptionRow() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 6),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        RichText(
          text: TextSpan(
            style: AppTextStyle.ts12M(color: AppColor.black),
            text: "T : ",
            children: [
              TextSpan(
                style: AppTextStyle.ts12M(color: AppColor.grey),
                text: "Target",
              ),
            ],
          ),
        ),
        horizontalSpacing(),
        RichText(
          text: TextSpan(
            style: AppTextStyle.ts12M(color: AppColor.black),
            text: "A : ",
            children: [
              TextSpan(
                style: AppTextStyle.ts12M(color: AppColor.grey),
                text: "Actual",
              ),
            ],
          ),
        ),
        horizontalSpacing(),

        RichText(
          text: TextSpan(
            style: AppTextStyle.ts12M(color: AppColor.black),
            text: "P : ",
            children: [
              TextSpan(
                style: AppTextStyle.ts12M(color: AppColor.grey),
                text: "Performance",
              ),
            ],
          ),
        ),
      ],
    ),
  );
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
