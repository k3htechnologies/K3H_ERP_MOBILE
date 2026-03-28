// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/sales/sales_dashboard/data/model/sales.dashboard.model.dart';
import 'package:k3h_erp_app/features/sales/sales_dashboard/presentation/cubit/sales_dashboard_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class SalesDashboardScreen extends StatefulWidget {
  const SalesDashboardScreen({super.key});

  @override
  State<SalesDashboardScreen> createState() => _SalesDashboardScreenState();
}

class _SalesDashboardScreenState extends State<SalesDashboardScreen> {
  // CUBIT
  late SalesDashboardCubit _salesDashboardCubit;

  late ProjectModel _selectedProject;

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
        projectId: _selectedProject.projectId,
      );
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

  StatusColor getStatusColor(String status) {
    final list = _getActiveFollowUpData();

    return list.firstWhere(
      (e) => e.text.toLowerCase() == status.toLowerCase(),
      orElse:
          () => StatusColor(
            bg: AppColor.lightGreyBackground,
            text: status,
            textColor: AppColor.black,
          ),
    );
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
                              style: AppTextStyle.ts14M(
                                color: AppColor.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    verticalSpacing(),
                    // ENQURIES LIST WIDGET
                    _buildEnquiriesWidget(context),
                    verticalSpacing(),
                    // TARGET PERFORMANCE WIDGET
                    /* _buildTargetPerformanceWidget(context),*/
                    verticalSpacing(),
                    // ACTIVE FOLLOW-UPS WIDGET (ACCORDING TO STATUS)
                    _buildActiveFollowUpsWidget(context),
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
              if (data.isNotEmpty) ...[
                SizedBox(
                  height: 300.0,
                  child: ListView.builder(
                    itemCount: data.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      final item = data[index];
                      return _buildEnquiryTile(context, item);
                    },
                  ),
                ),
              ] else ...[
                Center(
                  child: Text(
                    "No Enquiries for today Available",
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

  Widget _buildEnquiryTile(BuildContext context, Table0 item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: AppColor.lightGreyBackground,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: _infoColumn("Project Name", item.projectName)),
              horizontalSpacing(),
              Expanded(child: _infoColumn("Client Name", item.name)),
            ],
          ),
          verticalSpacing(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _infoColumn(
                  "Date",
                  formatDateTimeAsDDMMMYYYY(item.enquiryDate),
                ),
              ),
              horizontalSpacing(),
              Expanded(child: _infoColumn("Mobile Number", item.mobileNumber)),
            ],
          ),
          verticalSpacing(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _infoColumn("Customer Time In", item.enquiryTimeIn),
              ),
              horizontalSpacing(),
              Expanded(child: _infoColumn("Sales Advisor", item.salesAdvisor)),
            ],
          ),
          verticalSpacing(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _infoColumn(
                  "Sourcing Manager",
                  item.sourcingManager.isEmpty ? "-" : item.sourcingManager,
                ),
              ),
            ],
          ),
          verticalSpacing(),
          if (item.canTimeOut == 1) ...{
            CustomButton(
              text: "Time Out",
              onPressed: () {
                _showMarkAsTimeOutPopup(context, item);
              },
            ),
          },
        ],
      ),
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
              if (data.isNotEmpty) ...[
                SizedBox(
                  height: 350.0,
                  child: ListView.builder(
                    itemCount: data.length,
                    shrinkWrap: true,
                    physics: AlwaysScrollableScrollPhysics(),
                    itemBuilder: (context, int index) {
                      var activeData = getStatusColor(data[index].finalStage);
                      final activeFollowUps = data[index];
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
                                  ),
                                ),
                                horizontalSpacing(),
                                Expanded(
                                  child: _infoColumn(
                                    "Mobile Number",
                                    activeFollowUps.mobileNumber,
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
                                    activeFollowUps.enquiryFollowUpDays,
                                  ),
                                ),
                                horizontalSpacing(),
                                Expanded(
                                  child: _infoColumn(
                                    "Next FollowUp Date",
                                    formatDateTimeAsDDMMMYYYY(
                                      activeFollowUps.nextFollowUpDate,
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
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10.0,
                                      vertical: 4.0,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6.0),
                                      color: activeData.bg.withValues(
                                        alpha: 0.1,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        activeData.text.isEmpty
                                            ? '-'
                                            : activeData.text,
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
              ] else ...[
                Center(
                  child: Text(
                    "No Active Follow ups Available",
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

  Widget _infoColumn(String title, String value) {
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
