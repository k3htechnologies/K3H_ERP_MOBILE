import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/sales/booking/data/model/booking.model.dart';
import 'package:k3h_erp_app/features/sales/enquiry/data/model/enquiry.model.dart';
import 'package:k3h_erp_app/features/sales/sales_reports/achievement/data/model/achivement_drill_down_report.model.dart';
import 'package:k3h_erp_app/features/sales/sales_reports/achievement/data/model/channel_partner_sourcing.model.dart';
import 'package:k3h_erp_app/features/sales/sales_reports/achievement/presentation/cubit/achievement.state.dart';
import 'package:k3h_erp_app/features/sales/sales_reports/achievement/presentation/cubit/achievement_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/custom_click_to_contact_widget.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/status/status.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AchievementDrillDownReportScreen extends StatefulWidget {
  final int? projectId;
  final int? employeeId;
  final String? employeeName;
  final String tabName;
  final String columnName;
  final String? projectName;
  final String filterType;
  const AchievementDrillDownReportScreen({
    super.key,
    this.projectId,
    this.employeeId,
    this.employeeName,
    this.projectName,
    required this.tabName,
    required this.columnName,
    required this.filterType,
  });

  @override
  State<AchievementDrillDownReportScreen> createState() =>
      _AchievementDrillDownReportScreenState();
}

class _AchievementDrillDownReportScreenState
    extends State<AchievementDrillDownReportScreen> {
  late AchievementCubit _achievementCubit;
  late AuthorizationModel _routeAuthorizationModel;
  late ScrollController scrollController;
  Timer? _debounce;

  @override
  void initState() {
    _achievementCubit = context.read<AchievementCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.achievementReport]!;
    _achievementCubit.getAchievementDrillDownReportList(
      context: context,
      pageNumber: 1,
      projectId: widget.projectId,
      tabName: widget.tabName,
      columnName: widget.columnName,
      filterType: widget.filterType,
      employeeId: widget.employeeId,
    );
    _onScroll();
    super.initState();
  }

  void _onScroll() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !_achievementCubit.state.isLoading! &&
          _achievementCubit.state.achievementDrillDownReportList.length <
              _achievementCubit.state.achievementDrillDownTotalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _achievementCubit.getAchievementDrillDownReportList(
            context: context,
            pageNumber:
                _achievementCubit
                    .state
                    .currentAchievementDrillDownReportPageNumber +
                1,
            projectId: widget.projectId,
            tabName: widget.tabName,
            columnName: widget.columnName,
            filterType: widget.filterType,
            employeeId: widget.employeeId,
          );
        });
      }
    });
  }

  String getScreenTitle() {
    switch (_achievementCubit.state.drillDownType) {
      case AchievementDrillDownType.enquiry:
        return "Enquiry";
      case AchievementDrillDownType.booking:
        return "Booking";
      case AchievementDrillDownType.channelPartner:
        return "Channel Partner";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: getScreenTitle(),
        authorization: _routeAuthorizationModel,
        onExportCallback: (exportType) {
          _achievementCubit.exportAchievementDrillDownExcelPdf(
            context,
            exportType,
            projectId: widget.projectId,
            employeeId: widget.employeeId,
            tabName: widget.tabName.toUpperCase(),
            columnName: widget.columnName,
            filterType: widget.filterType,
          );
        },
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.projectName != null &&
                widget.projectName!.isNotEmpty) ...[
              showSiteSelectedWidget(projectName: widget.projectName),
              verticalSpacing(),
            ],
            if (widget.employeeName != null &&
                widget.employeeName!.isNotEmpty) ...[
              Text(widget.employeeName!, style: AppTextStyle.ts14M()),
              verticalSpacing(),
            ],
            RichText(
              text: TextSpan(
                style: AppTextStyle.ts14R(),
                children: [
                  TextSpan(
                    text: "Tab: ",
                    style: AppTextStyle.ts14R(color: AppColor.grey),
                  ),

                  TextSpan(text: widget.tabName, style: AppTextStyle.ts14M()),

                  TextSpan(
                    text: " | ",
                    style: AppTextStyle.ts14R(color: AppColor.grey),
                  ),

                  TextSpan(
                    text: "Column: ",
                    style: AppTextStyle.ts14R(color: AppColor.grey),
                  ),

                  TextSpan(
                    text: toTitleCase(widget.columnName),
                    style: AppTextStyle.ts14M(),
                  ),
                ],
              ),
            ),
            verticalSpacing(),
            Expanded(
              child: BlocBuilder<AchievementCubit, AchievementState>(
                builder: (context, state) {
                  if ((state.isLoading ?? true) &&
                      state.achievementDrillDownReportList.isEmpty) {
                    return Center(child: loader());
                  }
                  if (state.achievementDrillDownReportList.isEmpty) {
                    return Center(
                      child: noDataWidget(message: "No Enquiry Data Found"),
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,

                          itemCount:
                              _achievementCubit
                                  .state
                                  .achievementDrillDownReportList
                                  .length +
                              1,
                          itemBuilder: (context, index) {
                            if (index ==
                                state.achievementDrillDownReportList.length) {
                              return state
                                          .achievementDrillDownReportList
                                          .length <
                                      state
                                          .achievementDrillDownTotalNumberOfRecord
                                  ? const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                  : const SizedBox.shrink();
                            }

                            final item =
                                state.achievementDrillDownReportList[index];

                            switch (item.type) {
                              case AchievementDrillDownType.enquiry:
                                return _buildEnquiryCard(item.enquiry!);

                              case AchievementDrillDownType.booking:
                                return _buildBookingCard(item.booking!);

                              case AchievementDrillDownType.channelPartner:
                                return _buildChannelPartnerCard(
                                  item.channelPartner!,
                                );
                            }
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnquiryCard(EnquiryModel enquiry) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(12),
      decoration: commonCardDecoration(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () async {
              await goRouter.pushNamed(
                AppRoutes.achievementDrillDownReportForEnquiry,
                queryParameters: {
                  'enquiry': Uri.encodeQueryComponent(
                    EncryptionManager.encryptData(jsonEncode(enquiry.toJson())),
                  ),
                  'tabName': Uri.encodeQueryComponent(
                    EncryptionManager.encryptData(widget.tabName),
                  ),
                  'columnName': Uri.encodeQueryComponent(
                    EncryptionManager.encryptData(widget.columnName),
                  ),
                  if (widget.projectName != null)
                    'projectName': Uri.encodeQueryComponent(
                      EncryptionManager.encryptData(widget.projectName!),
                    ),
                  if (widget.employeeName != null)
                    'employeeName': Uri.encodeQueryComponent(
                      EncryptionManager.encryptData(widget.employeeName!),
                    ),
                },
              );
            },
            child: Text(
              enquiry.name,
              style: AppTextStyle.ts14M(color: AppColor.primary).copyWith(
                decoration: TextDecoration.underline,
                decorationColor: AppColor.primary,
              ),
            ),
          ),
          buildRowTitleValue(
            title: "Enquiry Code  ",
            value: enquiry.systemGeneratedCode,
            customValueWidget: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    enquiry.systemGeneratedCode,
                    style: AppTextStyle.ts14M(),
                  ),
                ),
                horizontalSpacing(width: 2),
                InkWell(
                  onTap: () {
                    copy(context: context, text: enquiry.systemGeneratedCode);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Icon(Icons.copy, size: 16, color: AppColor.primary),
                  ),
                ),
              ],
            ),
          ),
          buildRowTitleValue(
            title: "Mobile Number",
            value: enquiry.mobileNumber,
            customValueWidget: CustomClickToContactText(
              countryCode: enquiry.mobileNumberCountryCode,
              value: enquiry.mobileNumber,
            ),
          ),
          buildRowTitleValue(title: "Source", value: enquiry.source),
          buildRowTitleValue(
            title: "Customer Classification",
            value: enquiry.customerClassification,
          ),
          buildRowTitleValue(
            title: "Enquiry Follow Up Days",
            value:
                enquiry.nextFollowUpDate?.toIso8601String() ?? 'No Follow up',
            singleLine: false,
            customValueWidget: followUpStatusTextWidget(
              enquiry.nextFollowUpDate,
            ),
          ),
          buildRowTitleValue(
            title: "Next Follow-Up Date",
            value:
                enquiry.nextFollowUpDate != null
                    ? formatDateTimeAsDDMMMYYYY(enquiry.nextFollowUpDate!)
                    : "-",
            singleLine: false,
          ),
          buildRowTitleValue(
            title: "Requirement",
            value: enquiry.requirement,
            singleLine: false,
          ),
          buildRowTitleValue(
            title: "Stage",
            value: enquiry.finalStage,
            customValueWidget:
                enquiry.finalStage.isNotEmpty
                    ? enquiryStatusWidget(enquiry.finalStage)
                    : null,
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(BookingModel booking) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(12),
      decoration: commonCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    goRouter.pushNamed(
                      AppRoutes.achievementDrillDownReportForBooking,
                      queryParameters: {
                        'booking': Uri.encodeQueryComponent(
                          EncryptionManager.encryptData(
                            jsonEncode(booking.toJson()),
                          ),
                        ),
                        'tabName': Uri.encodeQueryComponent(
                          EncryptionManager.encryptData(widget.tabName),
                        ),
                        'columnName': Uri.encodeQueryComponent(
                          EncryptionManager.encryptData(widget.columnName),
                        ),
                        if (widget.projectName != null)
                          'projectName': Uri.encodeQueryComponent(
                            EncryptionManager.encryptData(widget.projectName!),
                          ),

                        if (widget.employeeName != null)
                          'employeeName': Uri.encodeQueryComponent(
                            EncryptionManager.encryptData(widget.employeeName!),
                          ),
                      },
                    );
                  },
                  child: Text(
                    booking.applicantName,
                    style: AppTextStyle.ts14M(color: AppColor.primary).copyWith(
                      decoration: TextDecoration.underline,
                      decorationColor: AppColor.primary,
                    ),
                  ),
                ),
              ),

              approvalStatusWidget(booking.approvalStatus),
            ],
          ),
          verticalSpacing(height: 5),
          buildRowTitleValue(
            title: "Enquiry Code",
            value: booking.systemGeneratedCode,
            singleLine: false,
            customValueWidget: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    booking.systemGeneratedCode,
                    style: AppTextStyle.ts14M(),
                  ),
                ),
                horizontalSpacing(width: 2),
                InkWell(
                  onTap: () {
                    copy(context: context, text: booking.systemGeneratedCode);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Icon(Icons.copy, size: 16, color: AppColor.primary),
                  ),
                ),
              ],
            ),
          ),
          buildRowTitleValue(title: "Flat", value: booking.flat),
          buildRowTitleValue(title: "Category", value: booking.flatType),
          buildRowTitleValue(
            title: "Flat Configuration:",
            value: booking.flatConfiguration,
          ),
          buildRowTitleValue(
            title: "Agreement Value (₹)",
            value: booking.agreementValue.toIndianCurrency(),
          ),
          buildRowTitleValue(
            title: "Expected Registration",
            value: formatDateTimeAsDDMMMYYYY(booking.registrationDate),
          ),
        ],
      ),
    );
  }

  Widget _buildChannelPartnerCard(ChannelPartnerSourcingModel channelPartner) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(12),
      decoration: commonCardDecoration(),
      child: Column(
        spacing: 5,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            spacing: 10,
            children: [
              Flexible(
                child: GestureDetector(
                  onTap: () async {
                    goRouter.pushNamed(
                      AppRoutes.achievementDrillDownReportForChannelPartner,
                      queryParameters: {
                        'channelPartner': Uri.encodeQueryComponent(
                          EncryptionManager.encryptData(
                            jsonEncode(channelPartner.toJson()),
                          ),
                        ),
                        'tabName': Uri.encodeQueryComponent(
                          EncryptionManager.encryptData(widget.tabName),
                        ),
                        'columnName': Uri.encodeQueryComponent(
                          EncryptionManager.encryptData(widget.columnName),
                        ),
                        if (widget.projectName != null)
                          'projectName': Uri.encodeQueryComponent(
                            EncryptionManager.encryptData(widget.projectName!),
                          ),
                        if (widget.employeeName != null)
                          'employeeName': Uri.encodeQueryComponent(
                            EncryptionManager.encryptData(widget.employeeName!),
                          ),
                      },
                    );
                  },
                  child: Text(
                    channelPartner.name,
                    style: AppTextStyle.ts16M(color: AppColor.primary).copyWith(
                      decoration: TextDecoration.underline,
                      decorationColor: AppColor.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          buildRowTitleValue(
            title: "CP Code  ",
            value: channelPartner.systemGeneratedCode,
            customValueWidget: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    channelPartner.systemGeneratedCode,
                    style: AppTextStyle.ts14M(),
                  ),
                ),
                horizontalSpacing(width: 2),
                InkWell(
                  onTap: () {
                    copy(
                      context: context,
                      text: channelPartner.systemGeneratedCode,
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Icon(Icons.copy, size: 16, color: AppColor.primary),
                  ),
                ),
              ],
            ),
          ),

          buildRowTitleValue(
            title: "Firms Type",
            value: channelPartner.firmsType,
            singleLine: false,
          ),

          buildRowTitleValue(
            title: "RERA Number",
            value: channelPartner.reraNumber,
            singleLine: false,
          ),
        ],
      ),
    );
  }
}


