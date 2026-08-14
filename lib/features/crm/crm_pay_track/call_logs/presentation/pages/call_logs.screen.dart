import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/pay_track/data/model/pay_track_call_log.model.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/pay_track/presentation/cubit/pay_track_cubit.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/pay_track/presentation/cubit/pay_track_state.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/utils/static/static_dropdown_data.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_export_button.dart';
import 'package:k3h_erp_app/widgets/app_bar/search_widget.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_click_to_contact_widget.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/status/status.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class CallLogsScreen extends StatefulWidget {
  final int projectId;
  final int bookingId;
  final String? bookingApprovalStatus;
  const CallLogsScreen({
    super.key,
    required this.projectId,
    required this.bookingId,
    this.bookingApprovalStatus,
  });

  @override
  State<CallLogsScreen> createState() => _CallLogsScreenState();
}

class _CallLogsScreenState extends State<CallLogsScreen> {
  late PayTrackCubit _payTrackCubit;

  // PAGINATION
  late ScrollController scrollController;
  Timer? _debounce;
  late TextEditingController _filterApplicantNameC, _filterApplicantMobileC;
  late AuthorizationModel _payTrackCallLogsAuthorization;
  final ValueNotifier<Map<String, dynamic>?> _selectedCallStatus =
      ValueNotifier(null);
  final ValueNotifier<Map<String, dynamic>?> _selectedCallPurpose =
      ValueNotifier(null);
  final ValueNotifier<DateTime?> _fromDateNotifier = ValueNotifier<DateTime?>(
    null,
  );
  final ValueNotifier<DateTime?> _toDateNotifier = ValueNotifier<DateTime?>(
    null,
  );
  final ValueNotifier<int> _filterCount = ValueNotifier(0);
  @override
  void initState() {
    super.initState();
    _payTrackCubit = context.read<PayTrackCubit>();
    _payTrackCallLogsAuthorization =
        Authorization.routeAuthorizationMap[AppRoutes.payTrackCallLog] ??
        AuthorizationModel();
    initialiseControllers();
    _onScroll();
    _payTrackCubit.applyCallLogsFilter(
      bookingId: widget.bookingId,
      context: context,
      isClear: true,
    );
    _payTrackCubit.getPayTrackCallLog(
      context,
      1,
      widget.projectId,
      widget.bookingId,
    );
  }

  @override
  void dispose() {
    _filterApplicantNameC.dispose();
    _filterApplicantMobileC.dispose();
    _filterCount.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void initialiseControllers() {
    _filterApplicantNameC = TextEditingController();
    _filterApplicantMobileC = TextEditingController();
  }

  // PAGINATION
  void _onScroll() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !_payTrackCubit.state.isLoading! &&
          _payTrackCubit.state.payTrackCallLogList.length <
              _payTrackCubit.state.callLogsTotalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _payTrackCubit.getPayTrackCallLog(
            context,
            _payTrackCubit.state.callLogsCurrentPage + 1,
            widget.projectId,
            widget.bookingId,
          );
        });
      }
    });
  }

  Future<void> _showPopupToDeletePayTrackCallLogs(
    BuildContext context,
    PayTrackCallLogModel obj,
    int page,
    int index,
  ) async {
    final shouldDelete = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a Call Log ?',
      'Deleting this Call Log will permanently remove all associated data.',
    );

    if (shouldDelete && context.mounted) {
      _payTrackCubit.deletePayTrackCallLogs(
        index,
        obj.payTrackCallLogId,
        obj.uniquekey,
        widget.projectId,
        widget.bookingId,
        context,
      );
    }
  }

  // CALL LOGS FILTER
  Future<void> _showBottomSheetToFilterCallLogs(BuildContext context) async {
    final state = _payTrackCubit.state;

    _filterApplicantNameC.text = state.filterByCallLogApplicantName;
    _filterApplicantMobileC.text = state.filterCallLogApplicantMobileNumber;
    _fromDateNotifier.value = state.filterCallLogFromDate;
    _toDateNotifier.value = state.filterCallLogToDate;

    final String initialCallLogApplicantNameC = _filterApplicantNameC.text;
    final String initialCallLogApplicantMobileC = _filterApplicantMobileC.text;
    final initialCallStatus = state.filterCallStatus;
    final initialCallPurpose = state.filterCallPurpose;

    if (initialCallStatus.isNotEmpty) {
      _selectedCallStatus.value = callStatus.firstWhere(
        (e) => e['DisplayName'] == initialCallStatus,
        orElse: () => callStatus.first,
      );
    }
    if (initialCallPurpose.isNotEmpty) {
      _selectedCallPurpose.value = callPurpose.firstWhere(
        (e) => e['DisplayName'] == initialCallPurpose,
        orElse: () => callPurpose.first,
      );
    }
    bool manualClose = false;
    final ValueNotifier<bool> applyEnabled = ValueNotifier<bool>(false);
    bool applied = false;
    void updateApplyState(StateSetter innerState) {
      final currentCallStatus = _selectedCallStatus.value?['DisplayName'] ?? '';

      final currentCallPurpose =
          _selectedCallPurpose.value?['DisplayName'] ?? '';

      innerState(() {
        manualClose =
            (_filterApplicantNameC.text.trim() !=
                initialCallLogApplicantNameC) ||
            (_filterApplicantMobileC.text.trim() !=
                initialCallLogApplicantMobileC) ||
            (currentCallStatus != initialCallStatus) ||
            (currentCallPurpose != initialCallPurpose) ||
            (_fromDateNotifier.value != state.filterCallLogFromDate) ||
            (_toDateNotifier.value != state.filterCallLogToDate);

        applyEnabled.value = manualClose;
      });
    }

    await DialogHelper.showCustomFilterBottomSheet(
      context,
      title: "Filter - Call Log",
      contentWidget: StatefulBuilder(
        builder: (context, innerState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ValueListenableBuilder(
                valueListenable: _selectedCallStatus,
                builder: (context, value, child) {
                  return CustomDropDownWidget(
                    title: "Call Status",
                    hintText: "Select Call Status",
                    initialValue: value,
                    dataList: callStatus,
                    onSelected: (value) {
                      _selectedCallStatus.value = value;
                      updateApplyState(innerState);
                    },
                    onValueClear: () {
                      _selectedCallStatus.value = null;
                      updateApplyState(innerState);
                    },
                  );
                },
              ),
              ValueListenableBuilder(
                valueListenable: _selectedCallPurpose,
                builder: (context, value, child) {
                  return CustomDropDownWidget(
                    title: "Call Purpose",
                    hintText: "Select Call Purpose",
                    initialValue: value,
                    dataList: callPurpose,
                    onSelected: (value) {
                      _selectedCallPurpose.value = value;
                      updateApplyState(innerState);
                    },
                    onValueClear: () {
                      _selectedCallPurpose.value = null;
                      updateApplyState(innerState);
                    },
                  );
                },
              ),
              CustomTextField(
                title: "Applicant Name",
                hint: "Enter Applicant Name",
                textController: _filterApplicantNameC,
                onChangeFunction: (_) {
                  updateApplyState(innerState);
                },
              ),
              CustomTextField(
                title: "Applicant Mobile Number",
                hint: "Enter Applicant Mobile Number",
                textController: _filterApplicantMobileC,
                keyboardType: TextInputType.phone,
                inputFormatterList: InputValidator.digit(10),
                onChangeFunction: (_) {
                  updateApplyState(innerState);
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ValueListenableBuilder<DateTime?>(
                      valueListenable: _fromDateNotifier,
                      builder: (context, fromDate, child) {
                        return CustomDatePicker(
                          title: "Reschedule From Date",
                          initialDate: fromDate,
                          setValue: (value) {
                            _fromDateNotifier.value = value;
                            updateApplyState(innerState);
                          },
                          validator: (value) => null,
                        );
                      },
                    ),
                  ),
                  horizontalSpacing(),
                  Expanded(
                    child: ValueListenableBuilder(
                      valueListenable: _toDateNotifier,
                      builder: (context, toDate, child) {
                        return CustomDatePicker(
                          title: "Reschedule To Date",
                          initialDate: toDate,
                          setValue: (value) {
                            _toDateNotifier.value = value;
                            updateApplyState(innerState);
                          },
                          validator: (value) => null,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),

      onClear: () {
        _filterApplicantNameC.clear();
        _filterApplicantMobileC.clear();

        _selectedCallStatus.value = null;
        _selectedCallPurpose.value = null;

        _fromDateNotifier.value = null;
        _toDateNotifier.value = null;

        _payTrackCubit.applyCallLogsFilter(
          context: context,
          bookingId: widget.bookingId,
          isClear: true,
        );
      },

      onApply: () {
        applied = true;
        final startDate = _fromDateNotifier.value;

        final endDate = _toDateNotifier.value;

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
              "End Date cannot be before Start Date",
            );

            return;
          }
        }

        _payTrackCubit.applyCallLogsFilter(
          context: context,
          bookingId: widget.bookingId,
          callLogApplicantName: _filterApplicantNameC.text.trim(),
          callLogApplicantMobileNumber: _filterApplicantMobileC.text.trim(),
          callLogStatus: _selectedCallStatus.value?['DisplayName'] ?? "",
          callLogPurpose: _selectedCallPurpose.value?['DisplayName'] ?? "",
          fromDate: startDate,
          toDate: endDate,
        );
      },

      isApplyEnabled: applyEnabled.value,
      applyEnabledNotifier: applyEnabled,
    );
    // IF BOTTOM SHEET CLOSE WITHOUT APPLYING
    if (!applied && manualClose) {
      _filterApplicantNameC.clear();
      _filterApplicantMobileC.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PayTrackCubit, PayTrackState>(
      listener: (context, state) {
        _filterCount.value = _payTrackCubit.updateFilterCount(state);
      },
      child: BlocBuilder<PayTrackCubit, PayTrackState>(
        builder: (context, state) {
          final bool isBookingCancelledOrRefund =
              widget.bookingApprovalStatus?.toUpperCase() == "CANCEL" ||
              widget.bookingApprovalStatus?.toUpperCase() == "REFUND";
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchBar(),
              Expanded(
                child: BlocBuilder<PayTrackCubit, PayTrackState>(
                  builder: (context, state) {
                    if (state.isLoading == true &&
                        state.payTrackCallLogList.isEmpty) {
                      return Center(child: loader());
                    }

                    if (state.payTrackCallLogList.isEmpty) {
                      return Center(
                        child: noDataWidget(
                          message: "No Call Log Found Found",
                          iconSize: 180,
                        ),
                      );
                    }
                    return ListView.builder(
                      controller: scrollController,
                      itemCount: state.payTrackCallLogList.length + 1,
                      shrinkWrap: true,
                      physics: AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 16.0,
                      ),
                      itemBuilder: (context, index) {
                        if (index == state.payTrackCallLogList.length) {
                          return state.payTrackCallLogList.length <
                                  state.callLogsTotalNumberOfRecord
                              ? Padding(
                                padding: const EdgeInsets.all(16),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                              : const SizedBox.shrink();
                        }
                        final callLog = state.payTrackCallLogList[index];
                        final String status = callLog.callStatus.trim();
                        return Container(
                          margin: EdgeInsets.only(bottom: 10.0),
                          padding: EdgeInsets.all(12.0),
                          decoration: commonCardDecoration(),
                          child: Theme(
                            data: Theme.of(
                              context,
                            ).copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              tilePadding: EdgeInsets.zero,
                              childrenPadding: EdgeInsets.zero,
                              expandedCrossAxisAlignment:
                                  CrossAxisAlignment.start,
                              iconColor: AppColor.black,
                              collapsedIconColor: AppColor.black,
                              shape: const Border(),
                              collapsedShape: const Border(),
                              title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      callLog.applicantName,
                                      style: AppTextStyle.ts16M(
                                        color: AppColor.primary,
                                      ),
                                    ),
                                  ),
                                  horizontalSpacing(),
                                  if (_payTrackCallLogsAuthorization.isAction &&
                                      !isBookingCancelledOrRefund)
                                    Expanded(
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          CustomIconButton.edit(
                                            isDisabled:
                                                callLog.callStatus.isNotEmpty,
                                            onPressed: () {
                                              goRouter.pushNamed(
                                                AppRoutes.editPayTrackCallLog,
                                                extra: {
                                                  "projectId": widget.projectId,
                                                  "bookingId": widget.bookingId,
                                                  "callLog": callLog,
                                                },
                                              );
                                            },
                                          ),
                                          horizontalSpacing(),
                                          CustomIconButton.delete(
                                            isDisabled:
                                                callLog.callStatus.isNotEmpty,
                                            onPressed: () {
                                              _showPopupToDeletePayTrackCallLogs(
                                                context,
                                                callLog,
                                                state.currentPage,
                                                index,
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.0,
                                    vertical: 16.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColor.lightGreyBackground,
                                    borderRadius: BorderRadius.circular(6.0),
                                    border: Border.all(
                                      width: 0.3,
                                      color: AppColor.black.withValues(
                                        alpha: 0.3,
                                      ),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          if (status.isNotEmpty)
                                            callLogStatusWidget(status),
                                        ],
                                      ),
                                      verticalSpacing(),
                                      buildRowTitleValue(
                                        title: "Applicant Type",
                                        value: callLog.applicantType,
                                      ),
                                      buildRowTitleValue(
                                        title: "Mobile Number",
                                        value: callLog.applicantMobileNumber,
                                        customValueWidget:
                                            CustomClickToContactText(
                                              value:
                                                  callLog.applicantMobileNumber,
                                              type: ContactType.phone,
                                            ),
                                      ),
                                      buildRowTitleValue(
                                        title: "Call Time",
                                        value: formatDateTimeReadable(
                                          callLog.callDate,
                                        ),
                                        singleLine: false,
                                      ),
                                      buildRowTitleValue(
                                        title: "Duration",
                                        value: callLog.duration,
                                      ),
                                      buildRowTitleValue(
                                        title: "Call Purpose",
                                        value: callLog.callPurpose,
                                        singleLine: false,
                                      ),
                                      buildRowTitleValue(
                                        title: "Reschedule Date",
                                        value: formatDateTimeAsDDMMMYYYY(
                                          callLog.rescheduleDate,
                                        ),
                                      ),
                                      buildRowTitleValue(
                                        title: "Registration Date",
                                        value: formatDateTimeAsDDMMMYYYY(
                                          callLog.registrationDate,
                                        ),
                                      ),
                                      buildRowTitleValue(
                                        title: "Promise Amount",
                                        value:
                                            callLog.promiseAmount <= 0
                                                ? "-"
                                                : callLog.promiseAmount
                                                    .toIndianCurrency(),
                                      ),
                                      buildRowTitleValue(
                                        title: "Remark",
                                        value: callLog.remark,
                                        singleLine: false,
                                      ),
                                      if (callLog.callStatus.isEmpty)
                                        buildRowTitleValue(
                                          title: "Status",
                                          value: callLog.callStatus,
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return BlocBuilder<PayTrackCubit, PayTrackState>(
      builder: (context, state) {
        final disableExport =
            (state.payTrackCallLogList.isEmpty ? true : false) ||
            !_payTrackCallLogsAuthorization.isExport;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: SearchWidget(
                  hintText: "Search by Applicant Name",
                  onSubmit: (value) async {
                    await _payTrackCubit.searchPayTrackCallLogs(
                      context,
                      widget.projectId,
                      widget.bookingId,
                      value,
                    );
                  },
                  textController: _filterApplicantNameC,
                  isFilterOn: true,
                  filterCountNotifier: _filterCount,
                  onFilterTap: () {
                    _showBottomSheetToFilterCallLogs(context);
                  },
                ),
              ),
              horizontalSpacing(),
              CustomExportButton(
                onExport: (v) {
                  if (disableExport) {
                    showErrorMessage(context, "Error", "No Data Found");
                    return;
                  }
                  _payTrackCubit.exportPayTrackCallLogsExcelPdf(
                    context,
                    v,
                    projectId: widget.projectId,
                    bookingId: widget.bookingId,
                    fromDate: _fromDateNotifier.value,
                    toDate: _toDateNotifier.value,
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
