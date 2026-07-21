import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/cubit/utils_cubit.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/pay_track/presentation/cubit/pay_track_cubit.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/pay_track/presentation/cubit/pay_track_state.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/functions/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/approve_reject_widget.dart';
import 'package:k3h_erp_app/widgets/custom_click_to_contact_widget.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class PayTrackScreen extends StatefulWidget {
  const PayTrackScreen({super.key});

  @override
  State<PayTrackScreen> createState() => _PayTrackScreenState();
}

class _PayTrackScreenState extends State<PayTrackScreen> {
  late PayTrackCubit _payTrackCubit;
  late ProjectModel _selectedProject;
  late TextEditingController _searchC,
      _filterApplicantNameC,
      _filterMobileNumberC,
      _filterWingC,
      _filterUnitC,
      _filterFloorC,
      _filterConfigurationC,
      _filterAgreementValueC,
      _filterBookingTypeC;
  // PAGINATION
  late ScrollController scrollController;

  // AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;
  Timer? _debounce;

  bool isFinalRegistrationCompleted = false;

  final ValueNotifier<DateTime?> _startDateNotifier = ValueNotifier<DateTime?>(
    null,
  );
  final ValueNotifier<DateTime?> _endDateNotifier = ValueNotifier<DateTime?>(
    null,
  );
  @override
  void initState() {
    super.initState();
    _payTrackCubit = context.read<PayTrackCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.payTrackMaster]!;
    _selectedProject = getProject();
    initializeControllers();

    _payTrackCubit.getPayTrackList(context, 1, _selectedProject.projectId);
    _onScroll();
  }

  @override
  void dispose() {
    _searchC.dispose();
    _filterApplicantNameC.dispose();
    _filterMobileNumberC.dispose();
    _filterWingC.dispose();
    _filterUnitC.dispose();
    _filterFloorC.dispose();
    _filterConfigurationC.dispose();
    _filterAgreementValueC.dispose();
    _filterBookingTypeC.dispose();
    scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  initializeControllers() {
    _searchC = TextEditingController();
    _filterApplicantNameC = TextEditingController();
    _filterMobileNumberC = TextEditingController();
    _filterWingC = TextEditingController();
    _filterUnitC = TextEditingController();
    _filterFloorC = TextEditingController();
    _filterConfigurationC = TextEditingController();
    _filterAgreementValueC = TextEditingController();
    _filterBookingTypeC = TextEditingController();
  }

  // <---- PAGINATION ---->
  void _onScroll() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !(_payTrackCubit.state.isLoading ?? false) &&
          _payTrackCubit.state.payTrackList.length <
              _payTrackCubit.state.totalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _payTrackCubit.getPayTrackList(
            context,
            _payTrackCubit.state.currentPage + 1,
            _selectedProject.projectId,
          );
        });
      }
    });
  }

  Future<void> _showBottomSheetToFilterPayTrack(BuildContext context) async {
    final state = _payTrackCubit.state;

    _searchC.text = state.searchText;
    _filterApplicantNameC.text = state.filterByApplicantName;
    _filterMobileNumberC.text = state.filterByMobileNumber;
    _filterWingC.text = state.filterByWing;
    _filterUnitC.text = state.filterByUnit;
    _filterFloorC.text = state.filterByFloor;
    _filterConfigurationC.text = state.filterByConfiguration;
    _filterAgreementValueC.text = state.filterByAgreementValue;
    _filterBookingTypeC.text = state.filterByBookingType;
    _startDateNotifier.value = state.filterByFromDate;
    _endDateNotifier.value = state.filterByToDate;
    final String initialFullNameName = _searchC.text;
    final String initialApplicantName = _filterApplicantNameC.text;
    final String initialMobileNumber = _filterMobileNumberC.text;
    final bool initialRegistrationCompleted =
        state.isFinalRegistrationCompleted ?? false;
    final String initialWing = _filterWingC.text;
    final String initialUnit = _filterUnitC.text;
    final String initialFloor = _filterFloorC.text;
    final String initialConfiguration = _filterConfigurationC.text;
    final String initialAgreementValue = _filterAgreementValueC.text;
    final String initialBookingType = _filterBookingTypeC.text;

    final DateTime? initialFromDate = _startDateNotifier.value;
    final DateTime? initialToDate = _endDateNotifier.value;

    bool manualClose = false;
    final ValueNotifier<bool> applyEnabled = ValueNotifier<bool>(false);
    bool applied = false;
    bool registrationCompleted = state.isFinalRegistrationCompleted ?? false;
    void updateApplyState(StateSetter innerState) {
      innerState(() {
        manualClose =
            (_searchC.text.trim() != initialFullNameName) ||
            (_filterApplicantNameC.text.trim() != initialApplicantName) ||
            (_filterMobileNumberC.text.trim() != initialMobileNumber) ||
            (registrationCompleted != initialRegistrationCompleted) ||
            (_filterWingC.text.trim() != initialWing) ||
            (_filterUnitC.text.trim() != initialUnit) ||
            (_filterFloorC.text.trim() != initialFloor) ||
            (_filterConfigurationC.text.trim() != initialConfiguration) ||
            (_filterAgreementValueC.text.trim() != initialAgreementValue) ||
            (_filterBookingTypeC.text.trim() != initialBookingType) ||
            (_startDateNotifier.value != initialFromDate) ||
            (_endDateNotifier.value != initialToDate);

        applyEnabled.value = manualClose;
      });
    }

    DialogHelper.showCustomFilterBottomSheet(
      context,
      title: "Filter - Pay Track",
      contentWidget: StatefulBuilder(
        builder: (context, innerState) {
          return SingleChildScrollView(
            padding: const EdgeInsets.only(right: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextField(
                  title: "Applicant Name",
                  hint: "Enter Applicant Name",
                  textController: _filterApplicantNameC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
                CustomTextField(
                  title: "Applicant Mobile Number",
                  hint: "Enter Applicant Mobile Number",
                  textController: _filterMobileNumberC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Final Registration Completed"),
                    Switch(
                      value: registrationCompleted,
                      onChanged: (value) {
                        innerState(() {
                          registrationCompleted = value;
                        });

                        updateApplyState(innerState);
                      },
                    ),
                  ],
                ),
                CustomTextField(
                  title: "Wing",
                  hint: "Enter Wing",
                  textController: _filterWingC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
                CustomTextField(
                  title: "Unit",
                  hint: "Enter Unit",
                  textController: _filterUnitC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
                CustomTextField(
                  title: "Floor",
                  hint: "Enter Floor",
                  textController: _filterFloorC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
                CustomTextField(
                  title: "Configuration",
                  hint: "Enter Configuration",
                  textController: _filterConfigurationC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
                Row(
                  children: [
                    Expanded(
                      child: ValueListenableBuilder<DateTime?>(
                        valueListenable: _startDateNotifier,
                        builder: (context, startDate, child) {
                          return CustomDatePicker(
                            title: "From Date",
                            initialDate: startDate,
                            setValue: (value) {
                              _startDateNotifier.value = value;

                              updateApplyState(innerState);
                            },
                            validator: (value) => null,
                          );
                        },
                      ),
                    ),

                    horizontalSpacing(),

                    Expanded(
                      child: ValueListenableBuilder<DateTime?>(
                        valueListenable: _endDateNotifier,
                        builder: (context, endDate, child) {
                          return ValueListenableBuilder<DateTime?>(
                            valueListenable: _startDateNotifier,
                            builder: (context, startDate, child) {
                              return CustomDatePicker(
                                title: "To Date",
                                isRequired: false,
                                initialDate: endDate,
                                setValue: (value) {
                                  _endDateNotifier.value = value;

                                  updateApplyState(innerState);
                                },
                                validator: (value) {
                                  if (value == null) {
                                    return null;
                                  }

                                  if (startDate != null) {
                                    final startDateOnly = DateTime(
                                      startDate.year,
                                      startDate.month,
                                      startDate.day,
                                    );

                                    final endDateOnly = DateTime(
                                      value.year,
                                      value.month,
                                      value.day,
                                    );

                                    if (endDateOnly.isBefore(startDateOnly)) {
                                      return 'To Date cannot be before From Date';
                                    }
                                  }

                                  return null;
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
                CustomTextField(
                  title: "Agreement Value",
                  hint: "Enter Agreement Value",
                  textController: _filterAgreementValueC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
                CustomTextField(
                  title: "Booking Type",
                  hint: "Enter Booking Type",
                  textController: _filterBookingTypeC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
              ],
            ),
          );
        },
      ),

      onClear: () {
        _filterApplicantNameC.clear();
        _filterMobileNumberC.clear();
        _filterWingC.clear();
        _filterUnitC.clear();
        _filterFloorC.clear();
        _filterConfigurationC.clear();
        _filterAgreementValueC.clear();
        _filterBookingTypeC.clear();
        _startDateNotifier.value = null;
        _endDateNotifier.value = null;
        _searchC.clear();
        _payTrackCubit.applyPaytrackFilterAndSort(
          context: context,
          isClear: true,
        );
      },

      onApply: () {
        applied = true;

        final startDate = _startDateNotifier.value;

        final endDate = _endDateNotifier.value;

        if (startDate != null && endDate != null) {
          final startOnly = DateTime(
            startDate.year,
            startDate.month,
            startDate.day,
          );

          final endOnly = DateTime(endDate.year, endDate.month, endDate.day);

          if (endOnly.isBefore(startOnly)) {
            showErrorMessage(
              context,
              "Invalid dates",
              "To Date cannot be before From Date",
            );

            return;
          }
        }

        _payTrackCubit.applyPaytrackFilterAndSort(
          context: context,
          applicantName: _filterApplicantNameC.text.trim(),
          mobileNumber: _filterMobileNumberC.text.trim(),
          isFinalRegistrationCompleted: registrationCompleted,
          wing: _filterWingC.text.trim(),
          unit: _filterUnitC.text.trim(),
          floor: _filterFloorC.text.trim(),
          configuration: _filterConfigurationC.text.trim(),
          agreementValue: _filterAgreementValueC.text.trim(),
          bookingType: _filterBookingTypeC.text.trim(),
          filterByFromDate: _startDateNotifier.value,
          filterByToDate: _endDateNotifier.value,
        );
      },

      isApplyEnabled: applyEnabled.value,
      applyEnabledNotifier: applyEnabled,
    );

    // IF BOTTOM SHEET CLOSE WITHOUT APPLYING
    if (!applied && manualClose) {
      _filterApplicantNameC.clear();
      _filterMobileNumberC.clear();
      _filterWingC.clear();
      _filterUnitC.clear();
      _filterFloorC.clear();
      _filterConfigurationC.clear();
      _filterAgreementValueC.clear();
      _filterBookingTypeC.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        screenTitle: 'Pay Track',
        authorization: _routeAuthorizationModel,
        onProjectChangeCallback: (value) {
          _selectedProject = value;
          _payTrackCubit.getPayTrackList(
            context,
            1,
            _selectedProject.projectId,
          );
        },
        onExportCallback: (value) {
          if (_payTrackCubit.state.totalNumberOfRecord == 0) {
            showErrorMessage(context, "Error", "No Data Found");
            return;
          }
          _payTrackCubit.exportExcelPdf(context, value);
        },
        searchHintText: "Search by Applicant Name",
        onSearchSubmit: (value) {
          _payTrackCubit.searchPayTrack(
            context,
            _selectedProject.projectId,
            value,
          );
        },
        textController: _searchC,
        isFilterOn: true,
        onFilterTap: () {
          _showBottomSheetToFilterPayTrack(context);
        },
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _searchC.clear();
          _payTrackCubit.searchPayTrack(
            context,
            _selectedProject.projectId,
            "",
          );
        },
        child: BlocBuilder<PayTrackCubit, PayTrackState>(
          builder: (context, state) {
            if ((state.isLoading ?? false) && state.payTrackList.isEmpty) {
              return Center(child: loader());
            }
            if (state.payTrackList.isEmpty) {
              return ListView(
                physics: AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: getActualHeight(context) * .7,
                    child: Center(
                      child: noDataWidget(
                        message: "No Pay Track Booking Data Found",
                      ),
                    ),
                  ),
                ],
              );
            }
            return ListView.builder(
              controller: scrollController,
              itemCount:
                  state.payTrackList.length +
                  (state.payTrackList.length < state.totalNumberOfRecord
                      ? 1
                      : 0),
              shrinkWrap: true,
              physics: BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemBuilder: (context, index) {
                if (index == state.payTrackList.length) {
                  return state.payTrackList.length < state.totalNumberOfRecord
                      ? Padding(
                        padding: const EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      )
                      : const SizedBox.shrink();
                }
                final payTrack = state.payTrackList[index];
                final cancelBookingApprovalStatus =
                    payTrack.cancelBookingApprovalStatus;
                final isAlreadyApproved =
                    cancelBookingApprovalStatus.toLowerCase() == "approved";
                final isRejected =
                    cancelBookingApprovalStatus.toLowerCase() == "rejected";
                final List<Map<String, dynamic>> summaryItems = [
                  {
                    "type": "Stamp Duty",
                    "total": payTrack.stampDutyAmount,
                    "paid": payTrack.receivedStampDutyAmount,
                  },
                  {
                    "type": "Registration Fees",
                    "total": payTrack.registrationFees,
                    "paid": payTrack.receivedRegistrationFees,
                  },
                  {
                    "type": "Agreement Value (Without TDS)",
                    "total":
                        payTrack.agreementValue - payTrack.agreementValueTds,
                    "paid":
                        payTrack.receivedAgreementValue -
                        payTrack.receivedAgreementValueTds,
                  },
                  {
                    "type": "Agreement Value GST",
                    "total": payTrack.agreementValueGstAmount,
                    "paid": payTrack.receivedAgreementValueGstAmount,
                  },
                  {
                    "type": "Agreement Value TDS",
                    "total": payTrack.agreementValueTds,
                    "paid": payTrack.receivedAgreementValueTds,
                  },
                  {
                    "type": "Other Charges Value",
                    "total": payTrack.otherChargesAmount,
                    "paid": payTrack.receivedOtherChargesAmount,
                  },
                  {
                    "type": "Other Charges GST",
                    "total": payTrack.otherChargesGstAmount,
                    "paid": payTrack.receivedOtherChargesGstAmount,
                  },
                ];
                double totalAmount = 0;
                double totalPaidAmount = 0;
                double totalPendingAmount = 0;

                for (final item in summaryItems) {
                  final total = (item["total"] as num).toDouble();
                  final paid = (item["paid"] as num).toDouble();
                  final pending = total - paid;

                  totalAmount += total;
                  totalPaidAmount += paid;
                  totalPendingAmount += pending;
                }

                final status = payTrack.bookingApprovalStatus.toLowerCase();

                Color backgroundColor;
                Color textColor;

                if (status == "refund") {
                  backgroundColor = const Color(0xFFE0E9FD);
                  textColor = const Color(0xFF2F5BEA);
                } else if (status == "cancel") {
                  backgroundColor = const Color(0xFFE9EFF7);
                  textColor = const Color(0xFF1F1F1F);
                } else {
                  backgroundColor = const Color(0xFFF0FDF4);
                  textColor = const Color(0xFF15803D);
                }
                return Container(
                  padding: EdgeInsets.all(16.0),
                  margin: EdgeInsets.only(bottom: 10.0),
                  decoration: commonCardDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              await _payTrackCubit.resetOverview();
                              await goRouter.pushNamed(
                                AppRoutes.viewPayTrackMaster,
                                queryParameters: {
                                  "applicantName": Uri.encodeQueryComponent(
                                    EncryptionManager.encryptData(
                                      payTrack.applicantName,
                                    ),
                                  ),
                                  "projectId": Uri.encodeQueryComponent(
                                    EncryptionManager.encryptData(
                                      payTrack.projectId.toString(),
                                    ),
                                  ),
                                  "bookingId": Uri.encodeQueryComponent(
                                    EncryptionManager.encryptData(
                                      payTrack.bookingId.toString(),
                                    ),
                                  ),
                                  "enquiryId": Uri.encodeQueryComponent(
                                    EncryptionManager.encryptData(
                                      payTrack.enquiryId.toString(),
                                    ),
                                  ),
                                  "bookingStatus": Uri.encodeQueryComponent(
                                    EncryptionManager.encryptData(
                                      payTrack.bookingApprovalStatus,
                                    ),
                                  ),
                                  "approvalStatus": Uri.encodeQueryComponent(
                                    EncryptionManager.encryptData(
                                      payTrack.approvalStatus,
                                    ),
                                  ),
                                },
                              );
                            },
                            child: Text(
                              payTrack.applicantName.isNotEmpty
                                  ? payTrack.applicantName
                                  : '-',
                              style: AppTextStyle.ts16M(
                                color: AppColor.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      verticalSpacing(height: 16.0),
                      Text(
                        payTrack.systemGeneratedCode,
                        style: AppTextStyle.ts14M(),
                      ),
                      verticalSpacing(height: 16.0),
                      CustomClickToContactText(
                        value: payTrack.applicantMobileNumber,
                      ),
                      verticalSpacing(height: 16.0),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.only(
                              left: 12.0,
                              right: 12.0,
                              top: 3.5,
                              bottom: 4.5,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6.0),
                              color:
                                  payTrack.tenantId == 0
                                      ? Color(0xffF0FDF4)
                                      : AppColor.lightPurpleBg2,
                              border: Border.all(
                                width: 1,
                                color:
                                    payTrack.tenantId == 0
                                        ? Color(0xffDCFCE7)
                                        : AppColor.lightPurple,
                              ),
                            ),
                            child: Text(
                              payTrack.tenantId == 0 ? "Booked" : "Alloted",
                              style: AppTextStyle.ts12M(
                                color:
                                    payTrack.tenantId == 0
                                        ? Color(0xff15803D)
                                        : Color(0xff561F64),
                              ),
                            ),
                          ),
                          if (status.toLowerCase() == "refund" ||
                              status.toLowerCase() == "cancel") ...{
                            horizontalSpacing(width: 6),
                            Text(
                              " > ",
                              style: AppTextStyle.ts16SB(
                                color: AppColor.black.withValues(alpha: 0.5),
                              ),
                            ),
                            horizontalSpacing(width: 6),
                            Container(
                              padding: const EdgeInsets.only(
                                left: 12,
                                right: 12,
                                top: 3.5,
                                bottom: 4.5,
                              ),
                              decoration: BoxDecoration(
                                color: backgroundColor,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Center(
                                child: Text(
                                  payTrack.bookingApprovalStatus,
                                  style: AppTextStyle.ts12M(color: textColor),
                                ),
                              ),
                            ),
                          } else ...{
                            SizedBox.shrink(),
                          },
                        ],
                      ),
                      payTrack.bookingApprovalStatus.toLowerCase() !=
                                  "refund" &&
                              payTrack.cancelRemark.isNotEmpty
                          ? verticalSpacing(height: 16.0)
                          : SizedBox.shrink(),
                      payTrack.bookingApprovalStatus.toLowerCase() !=
                                  "refund" &&
                              payTrack.cancelRemark.isNotEmpty
                          ? ApproveRejectWidget(
                            isActionAlreadyPerformed:
                                isAlreadyApproved || isRejected,
                            actionTitle:
                                payTrack.cancelBookingApprovalStatus.isEmpty
                                    ? "Pending"
                                    : cancelBookingApprovalStatus,
                            approveIcon: Icons.check,
                            onApprove: (onApprove) async {
                              final isSuccess = await context
                                  .read<UtilsCubit>()
                                  .updateModulesWorkflowApproval(
                                    context: context,
                                    moduleName: "CANCEL BOOKING APPROVAL",
                                    id: payTrack.bookingId,
                                    projectId: payTrack.projectId,
                                    isApproved: true,
                                    remark: onApprove.trim(),
                                  );
                              if (context.mounted && isSuccess) {
                                await _payTrackCubit.getPayTrackList(
                                  context,
                                  1,
                                  payTrack.projectId,
                                  bookingId: payTrack.bookingId,
                                );
                              }
                            },
                            onReject: (onReject) async {
                              await context
                                  .read<UtilsCubit>()
                                  .updateModulesWorkflowApproval(
                                    context: context,
                                    isApproved: false,
                                    moduleName: "CANCEL BOOKING APPROVAL",
                                    id: payTrack.bookingId,
                                    projectId: payTrack.projectId,
                                    remark: onReject.trim(),
                                  );
                            },
                            onThirdTap: () async {
                              final approvalLogHistoryList = await context
                                  .read<UtilsCubit>()
                                  .getApprovalLogHistory(
                                    context: context,
                                    projectId: payTrack.projectId,
                                    id: payTrack.bookingId,
                                    moduleName: "CANCEL BOOKING APPROVAL",
                                  );
                              if (context.mounted) {
                                goRouter.pushNamed(
                                  AppRoutes.approvalLogHistory,
                                  queryParameters: {
                                    "title": Uri.encodeComponent(
                                      EncryptionManager.encryptData(
                                        "CANCEL BOOKING APPROVAL",
                                      ),
                                    ),
                                    "approvalList": Uri.encodeComponent(
                                      EncryptionManager.encryptData(
                                        jsonEncode(
                                          approvalLogHistoryList
                                              .map((e) => e.toJson())
                                              .toList(),
                                        ),
                                      ),
                                    ),
                                  },
                                );
                              }
                            },

                            popupTitle: "CANCEL BOOKING APPROVAL",
                          )
                          : SizedBox.shrink(),
                      verticalSpacing(height: 16.0),
                      ExpansionTile(
                        tilePadding: EdgeInsets.symmetric(horizontal: 6.0),
                        childrenPadding: EdgeInsets.zero,
                        backgroundColor: AppColor.lightBlue,
                        collapsedBackgroundColor: AppColor.lightBlue,
                        expandedCrossAxisAlignment: CrossAxisAlignment.start,
                        iconColor: AppColor.black,
                        collapsedIconColor: AppColor.black,
                        shape: const Border(),
                        collapsedShape: const Border(),
                        title: Text(
                          "Cost & Tax Summary",
                          style: AppTextStyle.ts14M(),
                        ),
                        children: [
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColor.lightBlue,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 250.0,
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        ...summaryItems.map((item) {
                                          final total =
                                              (item["total"] as num).toDouble();
                                          final paid =
                                              (item["paid"] as num).toDouble();
                                          final pending = total - paid;
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                              left: 16.0,
                                              bottom: 16.0,
                                              right: 16.0,
                                            ),
                                            child: _buildSummaryItem(
                                              type: item["type"],
                                              totalAmount:
                                                  total.toIndianCurrency(),
                                              paidAmount:
                                                  paid.toIndianCurrency(),
                                              pendingAmount:
                                                  pending.toIndianCurrency(),
                                            ),
                                          );
                                        }),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: AppColor.white,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 14,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColor.blue,
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(8),
                                            topRight: Radius.circular(8),
                                          ),
                                        ),
                                        child: Text(
                                          "Total Summary",
                                          style: AppTextStyle.ts14M(
                                            color: AppColor.lightBlue,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                          top: 12.0,
                                          left: 12.0,
                                          right: 12.0,
                                        ),
                                        child: Column(
                                          children: [
                                            _summaryRow(
                                              "Total Amount",
                                              totalAmount.toIndianCurrency(),
                                            ),
                                            verticalSpacing(height: 6),
                                            Divider(
                                              height: 1,
                                              thickness: 0.3,
                                              color: AppColor.black.withValues(
                                                alpha: 0.5,
                                              ),
                                            ),
                                            verticalSpacing(height: 6),
                                            _summaryRow(
                                              "Total Outstanding Amount",
                                              totalPendingAmount
                                                  .toIndianCurrency(),
                                              valueColor: AppColor.orange,
                                            ),
                                            verticalSpacing(height: 6),
                                            Divider(
                                              height: 1,
                                              thickness: 0.3,
                                              color: AppColor.black.withValues(
                                                alpha: 0.5,
                                              ),
                                            ),
                                            verticalSpacing(height: 6),
                                            _summaryRow(
                                              "Grand Total",
                                              totalPaidAmount
                                                  .toIndianCurrency(),
                                              isBold: true,
                                              valueColor: AppColor.green,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
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
            );
          },
        ),
      ),
    );
  }

  Widget _summaryRow(
    String title,
    String value, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style:
                isBold
                    ? AppTextStyle.ts14B()
                    : AppTextStyle.ts14R(
                      color: AppColor.black.withValues(alpha: 0.5),
                    ),
          ),
        ),
        Text(value, style: AppTextStyle.ts14M(color: valueColor)),
      ],
    );
  }

  Widget _buildSummaryItem({
    required String type,
    required String totalAmount,
    required String paidAmount,
    required String pendingAmount,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _titleValue("Type", type)),
            horizontalSpacing(),
            Expanded(child: _titleValue("Total Amount", totalAmount)),
          ],
        ),
        verticalSpacing(),
        Row(
          children: [
            Expanded(child: _titleValue("Paid Amount", paidAmount)),
            horizontalSpacing(),
            Expanded(child: _titleValue("Outstanding Amount", pendingAmount)),
          ],
        ),
        verticalSpacing(),
        Divider(
          height: 1,
          thickness: 0.3,
          color: AppColor.black.withValues(alpha: 0.5),
        ),
      ],
    );
  }

  Widget _titleValue(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyle.ts12M(
            color: AppColor.black.withValues(alpha: 0.5),
          ),
        ),
        verticalSpacing(height: 6),
        Text(value, style: AppTextStyle.ts14M()),
      ],
    );
  }
}
