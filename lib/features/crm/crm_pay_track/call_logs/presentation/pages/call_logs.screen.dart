import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/pay_track/presentation/cubit/pay_track_cubit.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/pay_track/presentation/cubit/pay_track_state.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/utils/static/static_dropdown_data.dart';
import 'package:k3h_erp_app/widgets/app_bar/search_widget.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class CallLogsScreen extends StatefulWidget {
  final int projectId;
  final int bookingId;
  const CallLogsScreen({
    super.key,
    required this.projectId,
    required this.bookingId,
  });

  @override
  State<CallLogsScreen> createState() => _CallLogsScreenState();
}

class _CallLogsScreenState extends State<CallLogsScreen> {
  late PayTrackCubit _payTrackCubit;
  late TextEditingController _searchTextC,
      _filterApplicantNameC,
      _filterApplicantMobileC;
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
    initialiseControllers();
    _payTrackCubit.getPayTrackCallLog(
      context,
      1,
      widget.projectId,
      widget.bookingId,
    );
  }

  @override
  void dispose() {
    _searchTextC.dispose();
    _filterApplicantNameC.dispose();
    _filterApplicantMobileC.dispose();
    _filterCount.dispose();
    super.dispose();
  }

  void initialiseControllers() {
    _searchTextC = TextEditingController();
    _filterApplicantNameC = TextEditingController();
    _filterApplicantMobileC = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PayTrackCubit, PayTrackState>(
      listener: (context, state) {
        _filterCount.value = _payTrackCubit.updateFilterCount(state);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchBar(),
          Expanded(
            child: BlocBuilder<PayTrackCubit, PayTrackState>(
              builder: (context, state) {
                if (state.isLoading == true) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.payTrackCallLogList.isEmpty) {
                  return Center(
                    child: noDataWidget(
                      message: "No Call Log Found",
                      iconSize: 180,
                    ),
                  );
                }
                return Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListView.builder(
                        itemCount: state.payTrackCallLogList.length,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final callLog = state.payTrackCallLogList[index];
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
                                title: Text(
                                  callLog.applicantName,
                                  style: AppTextStyle.ts16M(
                                    color: AppColor.primary,
                                  ),
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
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(6.0),
                                                color:
                                                    callLog.callStatus
                                                                .toLowerCase() ==
                                                            "pending"
                                                        ? AppColor.grey
                                                            .withValues(
                                                              alpha: 0.3,
                                                            )
                                                        : AppColor.green
                                                            .withValues(
                                                              alpha: 0.3,
                                                            ),
                                              ),
                                              child: Text(
                                                callLog.callStatus
                                                            .toLowerCase() ==
                                                        "pending"
                                                    ? "Pending"
                                                    : callLog.callStatus,
                                                style: AppTextStyle.ts12SB(
                                                  color:
                                                      callLog.callStatus
                                                                  .toLowerCase() ==
                                                              "pending"
                                                          ? AppColor.black
                                                          : AppColor.green,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        verticalSpacing(),
                                        buildRowTitleValue(
                                          title: "Applicant Type",
                                          value: callLog.applicantType,
                                        ),
                                        buildRowTitleValue(
                                          title: "Applicant Mobile Number",
                                          value: callLog.applicantMobileNumber,
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
                                              callLog.promiseAmount
                                                  .toIndianCurrency(),
                                        ),
                                        buildRowTitleValue(
                                          title: "Remark",
                                          value: callLog.remark,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
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

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: SearchWidget(
              hintText: "Search by Applicant Name",
              onSubmit: (value) {},
              textController: _searchTextC,
              isFilterOn: true,
              filterCountNotifier: _filterCount,
              onFilterTap: () {
                _showBottomSheetToFilterCallLogs(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  // CALL LOGS FILTER
  Future<void> _showBottomSheetToFilterCallLogs(BuildContext context) async {
    final state = _payTrackCubit.state;

    _searchTextC.text = state.searchText;
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
        _searchTextC.clear();
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
      _searchTextC.clear();
      _filterApplicantNameC.clear();
      _filterApplicantMobileC.clear();
    }
  }
}
