// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/visitor_management/visitor_management_dashboard/data/model/visitor_management_dashboard.model.dart';
import 'package:k3h_erp_app/features/visitor_management/visitor_management_dashboard/data/model/visitor_timeline.model.dart';
import 'package:k3h_erp_app/features/visitor_management/visitor_management_dashboard/presentation/cubit/visitor_management_dashboard_cubit.dart';
import 'package:k3h_erp_app/features/visitor_management/visitor_management_dashboard/presentation/pages/widgets/gate_pass_filter.dart';
import 'package:k3h_erp_app/features/visitor_management/visitor_management_dashboard/presentation/pages/widgets/overview_widget.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/network_image_widget.dart';
import 'package:k3h_erp_app/widgets/status/status.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class VisitorManagementDashboardScreen extends StatefulWidget {
  const VisitorManagementDashboardScreen({super.key});

  @override
  State<VisitorManagementDashboardScreen> createState() =>
      _VisitorManagementDashboardScreenState();
}

class _VisitorManagementDashboardScreenState
    extends State<VisitorManagementDashboardScreen>
    with SingleTickerProviderStateMixin {
  // CUBIT
  late VisitorManagementDashboardCubit _visitorManagementDashboardCubit;

  // AUTHORIZATION
  late AuthorizationModel _routhAuthorizationModel;

  final ValueNotifier<String> _selectedFilterType = ValueNotifier("Today");
  final ValueNotifier<DateTime?> _fromDateNotifier = ValueNotifier(null);
  final ValueNotifier<DateTime?> _toDateNotifier = ValueNotifier(null);
  // FORM KEY
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _remarkC;
  @override
  void initState() {
    _visitorManagementDashboardCubit =
        context.read<VisitorManagementDashboardCubit>();
    _visitorManagementDashboardCubit.getGatePassDashboard(
      context: context,
      filterType: _selectedFilterType.value,
    );
    _routhAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.gatePass]!;
    _remarkC = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _selectedFilterType.dispose();
    _fromDateNotifier.dispose();
    _toDateNotifier.dispose();
    _remarkC.dispose();
    super.dispose();
  }

  Future<void> _showBottomSheetToAddApproval(
    BuildContext context,
    Table1 visitor,
  ) async {
    bool isAccepted = true;

    await DialogHelper.showCustomBottomSheet(
      context,
      "Add Approval",
      contentWidget: StatefulBuilder(
        builder: (context, innerState) {
          return Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Radio<bool>(
                      value: true,
                      groupValue: isAccepted,
                      onChanged: (value) {
                        if (value == null) return;
                        innerState(() => isAccepted = value);
                      },
                    ),
                    Text("Accept", style: AppTextStyle.ts14M()),
                    horizontalSpacing(width: 16),
                    Radio<bool>(
                      value: false,
                      groupValue: isAccepted,
                      onChanged: (value) {
                        if (value == null) return;
                        innerState(() => isAccepted = value);
                      },
                    ),
                    Text("Reject", style: AppTextStyle.ts14M()),
                  ],
                ),
                verticalSpacing(height: 12),
                CustomTextField(
                  title: "Remark",
                  hint: "Enter remark",
                  isRequired: true,
                  textController: _remarkC,
                  minLines: 3,
                  maxLines: 10,
                  validator: (value) {
                    final text = value?.trim() ?? "";

                    if (text.isEmpty) {
                      return "Remark is required";
                    }

                    if (text.length < 25) {
                      return "Remark must be at least 25 characters";
                    }
                    return null;
                  },
                ),
              ],
            ),
          );
        },
      ),
      bottomActions: CustomButton(
        text: "Save",
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            _saveForm(isAccepted, visitor);
          }
        },
      ),
    );
    _clearBottomSheet();
  }

  void _clearBottomSheet() {
    _remarkC.clear();
  }

  void _saveForm(bool isAccepted, Table1 visitor) {
    _visitorManagementDashboardCubit.addApproval(
      context: context,
      externalId: visitor.externalId,
      uniquekey: visitor.uniquekey,
      type: _selectedFilterType.value,
      approvalRemark: _remarkC.text.trim(),
      approvalStatus: isAccepted ? "Approved" : "Rejected",
    );
  }

  Future<void> _showPopupToFinaliseTermSheetApproval(
    BuildContext context,
    Table1 visitor,
  ) async {
    var result = await DialogHelper.showConfirmationDialog(
      context: context,
      title: 'You are about to mark this Gate Pass Out?',
      message:
          'Marking this Gate Pass Out will confirm that the visitor has exited. Do you want to continue?',
      confirmText: "Out",
      icon: LucideIcons.trash,
      confirmColor: AppColor.missingInformationRed,
    );
    if (result && context.mounted) {
      _visitorManagementDashboardCubit.updateGatePassOut(
        context,
        externalId: visitor.externalId,
        type: _selectedFilterType.value,
        uniquekey: visitor.uniquekey,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Visitor Management Dashboard",
        authorization: _routhAuthorizationModel,
        isMenuButton: true,
        showNotification: true,
      ),
      body: BlocBuilder<
        VisitorManagementDashboardCubit,
        VisitorManagementDashboardState
      >(
        builder: (context, state) {
          if (state.isLoading ?? true) {
            return Center(child: loader());
          }

          final dashboard =
              state.gatePassDashboardList.isNotEmpty
                  ? state.gatePassDashboardList.first
                  : null;

          final dashboardCount =
              dashboard?.table0.isNotEmpty == true
                  ? dashboard!.table0.first
                  : null;

          final todayVisitors = dashboard?.table1 ?? [];

          final todayVisitorsTimeline = dashboard?.table2 ?? [];
          final timelineGroups = context
              .read<VisitorManagementDashboardCubit>()
              .buildTimelineGroups(todayVisitorsTimeline);
          final purposeWiseVisitors = dashboard?.table3 ?? [];
          final alertsVisitors = dashboard?.table4 ?? [];
          return SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ValueListenableBuilder<String>(
                      valueListenable: _selectedFilterType,
                      builder: (context, selectedTab, child) {
                        return GatePassFilterWidget(
                          selectedTab: selectedTab,
                          initialFromDate: _fromDateNotifier.value,
                          initialToDate: _toDateNotifier.value,
                          onTap: (tab) async {
                            _selectedFilterType.value = tab;
                            await _visitorManagementDashboardCubit
                                .clearGatePassDashboarddData();
                            if (context.mounted) {
                              if (tab.toLowerCase() != 'datewise') {
                                await _visitorManagementDashboardCubit
                                    .getGatePassDashboard(
                                      context: context,
                                      filterType: _selectedFilterType.value,
                                    );
                              } else {
                                _fromDateNotifier.value = null;
                                _toDateNotifier.value = null;
                              }
                            }
                          },
                          onDateChanged: (from, to) {
                            _fromDateNotifier.value = from;
                            _toDateNotifier.value = to;

                            if (to != null) {
                              _visitorManagementDashboardCubit
                                  .getGatePassDashboard(
                                    context: context,
                                    filterType: _selectedFilterType.value,
                                    fromDate: from,
                                    toDate: to,
                                  );
                            }
                          },
                        );
                      },
                    ),
                    verticalSpacing(),
                    if (dashboardCount == null) ...{
                      Center(
                        child: noDataWidget(
                          message:
                              _selectedFilterType.value.toLowerCase() ==
                                      'datewise'
                                  ? "Select a date range to view visitors"
                                  : "No records Found",
                          iconSize: 120.sp,
                        ),
                      ),
                    } else ...{
                      if (_routhAuthorizationModel.isAction) ...{
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            CustomButton(
                              text: "+ Add Visitor",
                              onPressed: () {
                                goRouter.pushNamed(AppRoutes.gatePass);
                              },
                            ),
                          ],
                        ),
                      } else ...{
                        SizedBox.shrink(),
                      },
                      verticalSpacing(),
                      GatePassOverviewWidget(
                        filterType: _selectedFilterType.value,
                      ),
                      verticalSpacing(height: 20.sp),
                      _buildVisitors(
                        context,
                        dashboardCount,
                        todayVisitors,
                        timelineGroups,
                      ),
                      verticalSpacing(height: 20.sp),
                      if (_selectedFilterType.value.toLowerCase() ==
                          "today") ...{
                        _buildVisitorTimeline(timelineGroups),
                        verticalSpacing(height: 20.sp),
                      },

                      _buildPurposeWiseVisitors(purposeWiseVisitors),
                      verticalSpacing(height: 20.sp),
                      _buildAlerts(alertsVisitors),
                    },
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVisitors(
    BuildContext context,
    Table0? dashboardCount,
    List<Table1> todayVisitors,
    List<TimelineGroup> timelineGroups,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 12.sp),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.sp),
        border: Border.all(width: 1.sp, color: AppColor.grey2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text:
                      _selectedFilterType.value.toLowerCase() == "today"
                          ? "${_selectedFilterType.value}'s Visitors"
                          : "${_selectedFilterType.value} Visitors",
                  style: AppTextStyle.ts14M(color: AppColor.grey),
                ),
                TextSpan(
                  text: " (${todayVisitors.length})",
                  style: AppTextStyle.ts12M(color: AppColor.grey),
                ),
              ],
            ),
          ),
          verticalSpacing(height: 16.sp),
          if (todayVisitors.isEmpty) ...{
            Center(
              child: noDataWidget(
                message: "No records Found",
                iconSize: 120.sp,
              ),
            ),
          } else ...{
            SizedBox(
              height: 300.sp,
              child: ListView.builder(
                itemCount: todayVisitors.length,
                shrinkWrap: true,
                physics: AlwaysScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final visitor = todayVisitors[index];
                  final statusColor = getVisitorPurposeColor(visitor.status);
                  final bool isLast = index == todayVisitors.length - 1;
                  return Container(
                    margin: EdgeInsets.only(bottom: isLast ? 0.sp : 16.sp),
                    padding: EdgeInsets.all(12.sp),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.sp),
                      border: Border.all(width: 1.sp, color: AppColor.grey10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 16.sp,
                              backgroundColor: AppColor.primary,
                              child:
                                  visitor.photoUrl.isNotEmpty
                                      ? ClipOval(
                                        child: NetworkImageWidget(
                                          key: ValueKey(visitor.photoUrl),
                                          imageUrl: visitor.photoUrl,
                                          fit: BoxFit.fill,
                                          width: 50.w,
                                          height: 50.h,
                                        ),
                                      )
                                      : Text(getInitials(visitor.visitorName)),
                            ),
                            horizontalSpacing(width: 12.sp),
                            Expanded(
                              child: Text(
                                visitor.visitorName,
                                style: AppTextStyle.ts14M(),
                              ),
                            ),
                            horizontalSpacing(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 4.sp,
                                    horizontal: 8.sp,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6.sp),
                                    color: statusColor.backgroundColor,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        height: 6.sp,
                                        width: 6.sp,
                                        decoration: BoxDecoration(
                                          color: statusColor.textColor,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      horizontalSpacing(),
                                      Text(
                                        visitor.status,
                                        style: AppTextStyle.ts12SB(
                                          color: statusColor.textColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        verticalSpacing(height: 16.sp),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            buildColumnTitleValue(
                              title: "Contact",
                              value:
                                  visitor.contact.isEmpty
                                      ? "-"
                                      : "+91 ${visitor.contact}",
                              removeExpanded: true,
                            ),
                            horizontalSpacing(),
                            buildColumnTitleValue(
                              title: "Appointment With",
                              value: visitor.appointmentWith,
                              removeExpanded: true,
                            ),
                          ],
                        ),
                        verticalSpacing(height: 16.sp),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            buildColumnTitleValue(
                              title: "Check-In Time",
                              value: formatTime(visitor.checkInTime),
                              removeExpanded: true,
                            ),
                            horizontalSpacing(),
                            buildColumnTitleValue(
                              title: "Purpose",
                              value: "",
                              customValueWidget: visitorManagementStatusWidget(
                                visitor.purpose,
                                textStyle: AppTextStyle.ts12M(),
                              ),
                              removeExpanded: true,
                            ),
                          ],
                        ),
                        Divider(thickness: 1.0, color: AppColor.grey50),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            buildColumnTitleValue(
                              title: "Check-Out Time",
                              value: formatTime(visitor.checkOutTime),
                            ),
                            horizontalSpacing(),
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomIconButton(
                                    isDisable: !visitor.isApproval,
                                    size: 18.sp,
                                    backgroundColor: AppColor.green20
                                        .withValues(alpha: 0.15),
                                    onPressed: () {
                                      _showBottomSheetToAddApproval(
                                        context,
                                        visitor,
                                      );
                                    },
                                    icon: Icon(
                                      LucideIcons.logIn,
                                      size: 16.sp,
                                      color:
                                          !visitor.isApproval
                                              ? AppColor.grey
                                              : AppColor.green20,
                                    ),
                                  ),
                                  horizontalSpacing(),
                                  CustomIconButton(
                                    isDisable: !visitor.isCheckOutEnabled,
                                    size: 18.sp,
                                    backgroundColor: AppColor.lightRed,
                                    onPressed: () {
                                      _showPopupToFinaliseTermSheetApproval(
                                        context,
                                        visitor,
                                      );
                                    },
                                    icon: Icon(
                                      LucideIcons.logOut,
                                      size: 16,
                                      color:
                                          !visitor.isCheckOutEnabled
                                              ? AppColor.grey
                                              : AppColor.missingInformationRed,
                                    ),
                                  ),
                                  horizontalSpacing(),
                                  CustomIconButton(
                                    isDisable: !visitor.isNoticationEnabled,
                                    size: 18.sp,
                                    backgroundColor: AppColor.primary
                                        .withValues(alpha: 0.1),
                                    onPressed: () {},
                                    icon: Icon(
                                      LucideIcons.bell,
                                      size: 16,
                                      color:
                                          !visitor.isNoticationEnabled
                                              ? AppColor.grey
                                              : AppColor.primary,
                                    ),
                                  ),
                                ],
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
          },
        ],
      ),
    );
  }

  Widget _buildVisitorTimeline(List<TimelineGroup> timelineGroups) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 12.sp),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.sp),
        border: Border.all(width: 1.sp, color: AppColor.grey2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Today's Visitor Timeline",
            style: AppTextStyle.ts14M(color: AppColor.grey),
          ),
          verticalSpacing(height: 16.sp),
          if (timelineGroups.isEmpty) ...{
            Center(child: noDataWidget(iconSize: 120.sp)),
          } else ...{
            SizedBox(
              height: 250.sp,
              child: ListView.builder(
                itemCount: timelineGroups.length,
                padding: EdgeInsets.zero,
                itemBuilder:
                    (context, index) => _TimelineRow(
                      group: timelineGroups[index],
                      isLast: index == timelineGroups.length - 1,
                    ),
              ),
            ),
          },
        ],
      ),
    );
  }

  Widget _buildPurposeWiseVisitors(List<Table3> purposeList) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 12.sp),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.sp),
        border: Border.all(width: 1.sp, color: AppColor.grey2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Purpose-wise Visitors",
            style: AppTextStyle.ts14M(color: AppColor.grey),
          ),
          verticalSpacing(height: 16.sp),
          ...List.generate(purposeList.length, (index) {
            final item = purposeList[index];
            final color = getPurposeWiseVisitorsColor(item.purpose);
            final fraction = (item.percentage / 100).clamp(0.0, 1.0);

            return Padding(
              padding: EdgeInsets.only(
                bottom: index == purposeList.length - 1 ? 4.sp : 16.sp,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 10.sp,
                        height: 10.sp,
                        decoration: BoxDecoration(
                          color: color.textColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      horizontalSpacing(width: 10.sp),
                      Expanded(
                        child: Text(
                          item.purpose,
                          style: AppTextStyle.ts14M(color: AppColor.black),
                        ),
                      ),
                      Text(
                        item.visitorCount.toString(),
                        style: AppTextStyle.ts14SB(color: AppColor.black),
                      ),
                    ],
                  ),
                  verticalSpacing(height: 8.sp),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4.sp),
                    child: Stack(
                      children: [
                        Container(height: 8.sp, color: AppColor.grey10),
                        FractionallySizedBox(
                          widthFactor: fraction,
                          child: Container(
                            height: 8.sp,
                            color: color.textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAlerts(List<Table4> alertList) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 12.sp),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.sp),
        border: Border.all(width: 1.sp, color: AppColor.grey2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Alerts", style: AppTextStyle.ts14M(color: AppColor.grey)),
          verticalSpacing(height: 16.sp),
          if (alertList.isEmpty) ...{
            Center(child: noDataWidget(iconSize: 120.sp)),
          } else ...{
            SizedBox(
              height: 200.sp,
              child: ListView.builder(
                itemCount: alertList.length,
                padding: EdgeInsets.zero,
                itemBuilder: (context, index) {
                  final alerts = alertList[index];
                  final alertColor = getAlertColor(alerts.status);
                  final bool isLast = index == alertList.length - 1;
                  return Container(
                    margin: EdgeInsets.only(bottom: isLast ? 0.sp : 16.sp),
                    padding: EdgeInsets.all(12.sp),
                    decoration: BoxDecoration(
                      color: alertColor.backgroundColor,
                      borderRadius: BorderRadius.circular(6.sp),
                      border: Border(
                        left: BorderSide(
                          width: 10.sp,
                          color: alertColor.borderColor,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          alerts.alertType,
                          style: AppTextStyle.ts14SB(
                            color: alertColor.textColor,
                          ),
                        ),
                        verticalSpacing(height: 6.sp),
                        Text(
                          alerts.alertMessage,
                          style: AppTextStyle.ts12R(
                            color: alertColor.textColor,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          },
        ],
      ),
    );
  }
}

class VisitorPurposeColor {
  final Color backgroundColor;
  final Color textColor;

  const VisitorPurposeColor({
    required this.backgroundColor,
    required this.textColor,
  });
}

class AlertColor {
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;

  const AlertColor({
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
  });
}

VisitorPurposeColor getVisitorPurposeColor(String? purpose) {
  switch (purpose?.trim().toLowerCase()) {
    case "checked out":
      return const VisitorPurposeColor(
        backgroundColor: AppColor.checkedOutBgColor,
        textColor: AppColor.checkedOut,
      );

    case "currently in":
      return const VisitorPurposeColor(
        backgroundColor: Color(0xffD7F8E9),
        textColor: Color(0xff10B981),
      );

    case "not checked out":
      return const VisitorPurposeColor(
        backgroundColor: Color(0xffFFE4E6),
        textColor: Color(0xffE11D48),
      );

    case "overstaying":
      return const VisitorPurposeColor(
        backgroundColor: Color(0xffF3E8FF),
        textColor: Color(0xff7E22CE),
      );
    case "expected":
      return const VisitorPurposeColor(
        backgroundColor: Color(0xffFFEDD5),
        textColor: Color(0xffEA580C),
      );
    case "pending approval":
      return const VisitorPurposeColor(
        backgroundColor: AppColor.lightYellow,
        textColor: AppColor.rustOrange,
      );
    case "approved":
      return const VisitorPurposeColor(
        backgroundColor: Color(0xffDCFCE7),
        textColor: Color(0xff16A34A),
      );
    case "rejected":
      return const VisitorPurposeColor(
        backgroundColor: AppColor.lightRed,
        textColor: Color(0xffDC2626),
      );
    case "not arrived":
      return const VisitorPurposeColor(
        backgroundColor: AppColor.lightBlueBg2,
        textColor: AppColor.slightDarkBlue,
      );
    case "others":
    case "other":
      return const VisitorPurposeColor(
        backgroundColor: Color(0x26FF0037),
        textColor: Color(0xFFFF0037),
      );

    default:
      return const VisitorPurposeColor(
        backgroundColor: Color(0x261D1D1D),
        textColor: Color(0xFF333333),
      );
  }
}

VisitorPurposeColor getPurposeWiseVisitorsColor(String? purpose) {
  switch (purpose?.trim().toLowerCase()) {
    case "delivery":
      return const VisitorPurposeColor(
        backgroundColor: AppColor.lightGreen,
        textColor: AppColor.bookingDoneColorText,
      );

    case "guest":
      return const VisitorPurposeColor(
        backgroundColor: AppColor.lightPurple,
        textColor: AppColor.darkPurple,
      );

    case "interview":
      return const VisitorPurposeColor(
        backgroundColor: Color(0x1D1D1D26),
        textColor: AppColor.black,
      );

    case "meeting":
      return const VisitorPurposeColor(
        backgroundColor: AppColor.lightYellow,
        textColor: AppColor.brown,
      );

    default:
      return const VisitorPurposeColor(
        backgroundColor: AppColor.greyTitleAndValueColor,
        textColor: AppColor.missingInformationRed,
      );
  }
}

AlertColor getAlertColor(String? purpose) {
  switch (purpose?.trim().toLowerCase()) {
    case "visitor arrived":
      return const AlertColor(
        backgroundColor: AppColor.bgColor,
        borderColor: AppColor.darkBlue,
        textColor: AppColor.darkBlue,
      );
    case "rejected":
      return AlertColor(
        backgroundColor: AppColor.red.withValues(alpha: 0.1),
        borderColor: AppColor.missingInformationRed,
        textColor: AppColor.redishBrown,
      );
    case "appointment starting soon":
      return AlertColor(
        backgroundColor: AppColor.redishBrown.withValues(alpha: 0.1),
        borderColor: AppColor.startingSoonColor,
        textColor: AppColor.redishBrown,
      );
    case "overstaying":
      return AlertColor(
        backgroundColor: AppColor.grassGreenColor.withValues(alpha: 0.1),
        borderColor: AppColor.grassGreenColor,
        textColor: AppColor.grassGreenColor,
      );

    case "checked out":
      return const AlertColor(
        backgroundColor: AppColor.lightPurple,
        borderColor: AppColor.darkPurple,
        textColor: AppColor.darkPurple,
      );
    case "visitor not arrived":
      return const AlertColor(
        backgroundColor: AppColor.bgColor,
        borderColor: AppColor.darkBlue900,
        textColor: AppColor.darkBlue900,
      );
    case "arriving soon":
      return AlertColor(
        backgroundColor: AppColor.arrivingSoon.withValues(alpha: 0.1),
        borderColor: AppColor.arrivingSoon,
        textColor: AppColor.arrivingSoon,
      );

    default:
      return const AlertColor(
        backgroundColor: Color(0x261D1D1D),
        borderColor: Color(0x261D1D1D),
        textColor: Color(0xFF333333),
      );
  }
}

class _TimelineRow extends StatelessWidget {
  final TimelineGroup group;
  final bool isLast;
  const _TimelineRow({required this.group, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final dotColor =
        getVisitorPurposeColor(group.visitors.first.status).textColor;

    return Stack(
      children: [
        if (!isLast)
          Positioned(
            left: 0,
            right: 0,
            bottom: 16.sp,
            child: Divider(
              height: 1.sp,
              thickness: 1.sp,
              color: AppColor.grey2.withValues(alpha: 0.4),
            ),
          ),

        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 52.sp,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      DateFormat('hh:mm').format(group.time),
                      style: AppTextStyle.ts12SB(
                        color: AppColor.black.withValues(alpha: 0.4),
                      ),
                    ),
                    Text(
                      DateFormat('a').format(group.time),
                      style: AppTextStyle.ts10SB(color: AppColor.grey),
                    ),
                  ],
                ),
              ),
              horizontalSpacing(width: 12.sp),
              Column(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    margin: const EdgeInsets.only(top: 2),
                    decoration: BoxDecoration(
                      color: dotColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        margin: const EdgeInsets.only(top: 2),
                        color: AppColor.grey.withValues(alpha: 0.2),
                      ),
                    ),
                ],
              ),
              horizontalSpacing(width: 12.sp),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:
                            group.visitors
                                .map(
                                  (v) => Padding(
                                    padding: EdgeInsets.only(right: 8.sp),
                                    child: VisitorCard(visitor: v),
                                  ),
                                )
                                .toList(),
                      ),
                    ),
                    if (!isLast) SizedBox(height: 32.sp),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildStatsCardWidget(
    BuildContext context, {
    required String title,
    required String value,
    required Color valueColor,
    required String subTitle,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
  }) {
    return Container(
      padding: EdgeInsets.all(12.sp),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(width: 1.sp, color: AppColor.lightGrey),
        boxShadow: [
          BoxShadow(
            color: AppColor.black.withValues(alpha: 0.196),
            blurRadius: 8,
            spreadRadius: 0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(6.sp),
                height: 30.sp,
                width: 30.sp,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(6.sp),
                ),
                child: Icon(icon, color: iconColor, size: 16.w),
              ),
              horizontalSpacing(),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyle.ts12M(color: AppColor.grey),
                ),
              ),
            ],
          ),
          verticalSpacing(height: 12.sp),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: AppTextStyle.ts20SB(color: valueColor),
                ),
                TextSpan(text: " "),
                TextSpan(
                  text: subTitle,
                  style: AppTextStyle.ts12M(color: AppColor.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class VisitorCard extends StatelessWidget {
  final Table2 visitor;
  const VisitorCard({super.key, required this.visitor});

  @override
  Widget build(BuildContext context) {
    final statusColor = getVisitorPurposeColor(visitor.status);
    return Container(
      padding: EdgeInsets.all(10.sp),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6.sp),
        border: Border.all(width: 1.sp, color: AppColor.grey30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${visitor.visitorName} +${visitor.noOfParticipants}",
            style: AppTextStyle.ts14M(
              color: AppColor.black.withValues(alpha: 0.6),
            ),
          ),
          verticalSpacing(),
          Text(
            visitor.status,
            style: AppTextStyle.ts12SB(color: statusColor.textColor),
          ),
        ],
      ),
    );
  }
}
