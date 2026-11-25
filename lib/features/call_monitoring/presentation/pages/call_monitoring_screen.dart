import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/call_monitoring/data/model/call_monitoring.model.dart';
import 'package:k3h_erp_app/features/call_monitoring/presentation/cubit/call_monitoring_cubit.dart';
import 'package:k3h_erp_app/features/call_monitoring/presentation/cubit/call_monitoring_state.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/functions/utility_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/utils/static/static_dropdown_data.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_export_button.dart';
import 'package:k3h_erp_app/widgets/app_bar/search_widget.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_click_to_contact_widget.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/custom_from_to_date_picker.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/expansion_tile/custom_expansion_tile.dart';
import 'package:k3h_erp_app/widgets/status/status.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class CallMonitoringScreen extends StatefulWidget {
  final String pageName;
  final int id;
  final AuthorizationModel routeAuthorizationModel;

  const CallMonitoringScreen({
    super.key,
    required this.pageName,
    required this.id,
    required this.routeAuthorizationModel,
  });

  @override
  State<CallMonitoringScreen> createState() => _CallMonitoringScreenState();
}

class _CallMonitoringScreenState extends State<CallMonitoringScreen> {
  late final CallMonitoringCubit _cubit;
  late final ScrollController _scrollController;
  late final TextEditingController _filterNameC;
  late final TextEditingController _filterMobileC;
  Timer? _debounce;

  final ValueNotifier<Map<String, dynamic>?> _selectedCallStatus =
      ValueNotifier(null);
  final ValueNotifier<Map<String, dynamic>?> _selectedCallPurpose =
      ValueNotifier(null);
  final ValueNotifier<DateTime?> _fromDateNotifier = ValueNotifier(null);
  final ValueNotifier<DateTime?> _toDateNotifier = ValueNotifier(null);
  final ValueNotifier<int> _filterCount = ValueNotifier(0);

  int get _projectId => getProject().projectId;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<CallMonitoringCubit>();
    updatePageInfo();
    _filterNameC = TextEditingController();
    _filterMobileC = TextEditingController();

    _onScroll();

    // Clears filters and fetches page 1.
    _cubit.applyCallMonitoringFilter(
      id: widget.id,
      context: context,
      isClear: true,
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _filterNameC.dispose();
    _filterMobileC.dispose();
    _selectedCallStatus.dispose();
    _selectedCallPurpose.dispose();
    _fromDateNotifier.dispose();
    _toDateNotifier.dispose();
    _filterCount.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void updatePageInfo() async {
    await _cubit.updatePageInfo(id: widget.id, pageName: widget.pageName);
  }

  // PAGINATION
  void _onScroll() {
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      final state = _cubit.state;
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 100 &&
          !(state.isLoading ?? false) &&
          state.callMonitoringList.length < state.totalNumberOfRecord) {
        _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          if (!mounted) return;
          _cubit.getCallMonitoring(
            context: context,
            pageNumber: _cubit.state.currentPage + 1,
            projectId: _projectId,
          );
        });
      }
    });
  }

  Future<void> _showDeleteCallLogDialog(
    BuildContext context,
    CallMonitoringModel obj,
    int index,
  ) async {
    final shouldDelete = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a Call Log ?',
      'Deleting this Call Log will permanently remove all associated data.',
    );

    if (shouldDelete && context.mounted) {
      _cubit.deleteCallMonitoring(
        index,
        obj.callMonitoringId,
        obj.uniquekey,
        _projectId,
        widget.id,
        context,
      );
    }
  }

  // FILTER
  Future<void> _showBottomSheetToFilterCallLog(BuildContext context) async {
    final state = _cubit.state;

    _filterNameC.text = state.filterByName;
    _filterMobileC.text = state.filterByMobileNumber;
    _fromDateNotifier.value = state.filterByFromDate;
    _toDateNotifier.value = state.filterByToDate;

    final initialName = _filterNameC.text;
    final initialMobile = _filterMobileC.text;
    final initialCallStatus = state.filterByCallStatus;
    final initialCallPurpose = state.filterByCallPurpose;

    _selectedCallStatus.value =
        initialCallStatus.isEmpty
            ? null
            : callStatus.firstWhere(
              (e) => e['DisplayName'] == initialCallStatus,
              orElse: () => callStatus.first,
            );
    _selectedCallPurpose.value =
        initialCallPurpose.isEmpty
            ? null
            : callPurpose.firstWhere(
              (e) => e['DisplayName'] == initialCallPurpose,
              orElse: () => callPurpose.first,
            );

    final ValueNotifier<bool> applyEnabled = ValueNotifier<bool>(false);
    bool applied = false;

    void updateApplyState(StateSetter innerState) {
      final currentStatus = _selectedCallStatus.value?['DisplayName'] ?? '';
      final currentPurpose = _selectedCallPurpose.value?['DisplayName'] ?? '';

      innerState(() {
        applyEnabled.value =
            _filterNameC.text.trim() != initialName ||
            _filterMobileC.text.trim() != initialMobile ||
            currentStatus != initialCallStatus ||
            currentPurpose != initialCallPurpose ||
            _fromDateNotifier.value != state.filterByFromDate ||
            _toDateNotifier.value != state.filterByToDate;
      });
    }

    await DialogHelper.showCustomFilterBottomSheet(
      context,
      title: "Filter - Call Log",
      contentWidget: StatefulBuilder(
        builder: (context, innerState) {
          return SingleChildScrollView(
            padding: const EdgeInsets.only(right: 16),
            child: Column(
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
                  title: "Name",
                  hint: "Enter Name",
                  textController: _filterNameC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
                CustomTextField(
                  title: "Mobile Number",
                  hint: "Enter Mobile Number",
                  prefixType: CustomTextFieldPrefix.mobile,
                  textController: _filterMobileC,
                  keyboardType: TextInputType.phone,
                  inputFormatterList: InputValidator.digit(10),
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
                CustomFromToDatePicker(
                  fromDateTitle: "Reschedule From Date",
                  toDateTitle: "Reschedule To Date",
                  initialFromDate: _fromDateNotifier.value,
                  initialToDate: _toDateNotifier.value,
                  isRequired: false,
                  removeBottomMargin: false,
                  alignVertical: true,
                  onToDateChanged: (DateTime? fromDate, DateTime? toDate) {
                    _fromDateNotifier.value = fromDate;
                    _toDateNotifier.value = toDate;
                    updateApplyState(innerState);
                  },
                ),
              ],
            ),
          );
        },
      ),
      onClear: () {
        _filterNameC.clear();
        _filterMobileC.clear();
        _selectedCallStatus.value = null;
        _selectedCallPurpose.value = null;
        _fromDateNotifier.value = null;
        _toDateNotifier.value = null;

        _cubit.applyCallMonitoringFilter(
          context: context,
          id: widget.id,
          isClear: true,
        );
      },
      onApply: () {
        applied = true;
        _cubit.applyCallMonitoringFilter(
          context: context,
          id: widget.id,
          callLogApplicantName: _filterNameC.text.trim(),
          callLogApplicantMobileNumber: _filterMobileC.text.trim(),
          callLogStatus: _selectedCallStatus.value?['DisplayName'] ?? "",
          callLogPurpose: _selectedCallPurpose.value?['DisplayName'] ?? "",
          fromDate: _fromDateNotifier.value,
          toDate: _toDateNotifier.value,
        );
      },
      isApplyEnabled: applyEnabled.value,
      applyEnabledNotifier: applyEnabled,
    );

    // Sheet closed without applying: restore the search box to applied state.
    if (!applied) {
      _filterNameC.text = _cubit.state.filterByName;
      _filterMobileC.text = _cubit.state.filterByMobileNumber;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CallMonitoringCubit, CallMonitoringState>(
      listener: (context, state) {
        _filterCount.value = _cubit.updateFilterCount(state);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchBar(),
          Expanded(
            child: BlocBuilder<CallMonitoringCubit, CallMonitoringState>(
              builder: (context, state) {
                if ((state.isLoading ?? false) &&
                    state.callMonitoringList.isEmpty) {
                  return Center(child: loader());
                }

                if (state.callMonitoringList.isEmpty) {
                  return Center(
                    child: noDataWidget(
                      message: "No Call Logs Data Found.",
                      iconSize: 180,
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: state.callMonitoringList.length + 1,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 16.0,
                  ),
                  itemBuilder: (context, index) {
                    if (index == state.callMonitoringList.length) {
                      return state.callMonitoringList.length <
                              state.totalNumberOfRecord
                          ? const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          )
                          : const SizedBox.shrink();
                    }
                    return _buildCard(
                      context,
                      state.callMonitoringList[index],
                      index,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, CallMonitoringModel item, int index) {
    final String status = item.callStatus.trim();

    return CustomExpandableCard(
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  item.name,
                  style: AppTextStyle.ts14M(color: AppColor.primary),
                ),
              ),
              horizontalSpacing(),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CustomIconButton.edit(
                      isDisabled:
                          item.callStatus.isNotEmpty ||
                          !widget.routeAuthorizationModel.isAction,

                      onPressed: () {
                        // Adjust route name to your actual edit route.
                        goRouter.pushNamed(
                          AppRoutes.updateCallMonitoring,
                          extra: {"callMonitoring": item, "index": index},
                        );
                      },
                    ),
                    horizontalSpacing(),
                    CustomIconButton.delete(
                      isDisabled:
                          item.callStatus.isNotEmpty ||
                          !widget.routeAuthorizationModel.isAction,
                      onPressed:
                          () => _showDeleteCallLogDialog(context, item, index),
                    ),
                  ],
                ),
              ),
            ],
          ),
          callLogStatusWidget(
            status.isEmpty ? "-" : status,
            textStyle: AppTextStyle.ts10M(),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 16.0,
            ),
            decoration: BoxDecoration(
              color: AppColor.lightGreyBackground,
              borderRadius: BorderRadius.circular(6.0),
              border: Border.all(
                width: 0.3,
                color: AppColor.black.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                verticalSpacing(),
                buildRowTitleValue(
                  title: "Mobile Number",
                  value: item.mobileNumber,
                  customValueWidget: CustomClickToContactText(
                    value: item.mobileNumber,
                    countryCode: "+91",
                    type: ContactType.phone,
                  ),
                ),
                buildRowTitleValue(
                  title: "Call Time",
                  value: formatDateTimeReadable(item.callDate),
                  singleLine: false,
                ),
                buildRowTitleValue(title: "Duration", value: item.duration),
                buildRowTitleValue(
                  title: "Reschedule Date",
                  value: formatDateTimeAsDDMMMYYYY(item.rescheduleDate),
                ),
                buildRowTitleValue(
                  title: "Call Purpose",
                  value: item.callPurpose,
                  singleLine: false,
                ),

                buildRowTitleValue(
                  title: "Remark",
                  value: item.remark,
                  singleLine: false,
                ),
                if (item.callStatus.isEmpty)
                  buildRowTitleValue(title: "Status", value: item.callStatus),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return BlocBuilder<CallMonitoringCubit, CallMonitoringState>(
      builder: (context, state) {
        final disableExport =
            state.callMonitoringList.isEmpty ||
            !widget.routeAuthorizationModel.isExport;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: SearchWidget(
                  hintText: "Search by Name",
                  onSubmit: (value) async {
                    await _cubit.searchCallMonitoring(
                      context,
                      _projectId,
                      value,
                    );
                  },
                  textController: _filterNameC,
                  isFilterOn: true,
                  filterCountNotifier: _filterCount,
                  onFilterTap: () => _showBottomSheetToFilterCallLog(context),
                ),
              ),
              horizontalSpacing(),
              CustomExportButton(
                onExport: (v) {
                  if (disableExport) {
                    showErrorMessage(context, "Error", "No Data Found");
                    return;
                  }
                  _cubit.exportCallMonitoringExcelPdf(
                    context: context,
                    exportType: v,
                    projectId: _projectId,
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
