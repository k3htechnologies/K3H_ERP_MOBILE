import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/visitor_management/gate_pass/data/model/gate_pass.model.dart';
import 'package:k3h_erp_app/features/visitor_management/gate_pass/presentation/cubit/gate_pass_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_click_to_contact_widget.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/custom_from_to_date_picker.dart';
import 'package:k3h_erp_app/widgets/status/status.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class GatePassScreen extends StatefulWidget {
  const GatePassScreen({super.key});

  @override
  State<GatePassScreen> createState() => _GatePassScreenState();
}

class _GatePassScreenState extends State<GatePassScreen> {
  // CUBIT
  late GatePassCubit _gatePassCubit;
  late AuthorizationModel _gatePassRouteAuthorizationModel,
      _gatePassAdministrativeRouteAuthorizationModel;
  // FORM KEY
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _searchC,
      _mobileNumberC,
      _addressC,
      _purposeC,
      _appointmentWithC,
      _remarkC;

  // PAGINATION
  late ScrollController scrollController;
  Timer? _debounce;
  // FILTER
  final ValueNotifier<DateTime?> _startDateNotifier = ValueNotifier<DateTime?>(
    null,
  );
  final ValueNotifier<DateTime?> _endDateNotifier = ValueNotifier<DateTime?>(
    null,
  );
  // FILTER COUNT
  final ValueNotifier<int> _filterCount = ValueNotifier(0);

  @override
  void initState() {
    _gatePassCubit = context.read<GatePassCubit>();
    _gatePassRouteAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.gatePass] ??
        AuthorizationModel();
    _gatePassAdministrativeRouteAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes
            .gatePassAdministrativeAccess] ??
        AuthorizationModel();
    initializeTextEditingController();
    _onScroll();
    _gatePassCubit.getGatePass(context, 1);
    super.initState();
  }

  @override
  void dispose() {
    _searchC.dispose();
    _mobileNumberC.dispose();
    _addressC.dispose();
    _purposeC.dispose();
    _appointmentWithC.dispose();
    _filterCount.dispose();
    scrollController.dispose();
    _debounce?.cancel();
    _startDateNotifier.dispose();
    _endDateNotifier.dispose();
    _remarkC.dispose();
    super.dispose();
  }

  void initializeTextEditingController() {
    _searchC = TextEditingController();
    _mobileNumberC = TextEditingController();
    _addressC = TextEditingController();
    _purposeC = TextEditingController();
    _appointmentWithC = TextEditingController();
    _remarkC = TextEditingController();
  }

  // <---- PAGINATION ---->
  void _onScroll() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !(_gatePassCubit.state.isLoading ?? false) &&
          _gatePassCubit.state.gatePassList.length <
              _gatePassCubit.state.totalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _gatePassCubit.getGatePass(
            context,
            _gatePassCubit.state.currentPage + 1,
          );
        });
      }
    });
  }

  Future<void> _showPopupToDeleteGatePass(
    BuildContext context,
    GatePassModel obj,
    int index,
  ) async {
    var result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a Gate Pass ?',
      'Deleting this Gate Pass will permanently remove all associated data.',
    );
    if (result && context.mounted) {
      _gatePassCubit.deleteTermSheet(
        context: context,
        gatePass: obj,
        index: index,
      );
    }
  }

  Future<void> _showPopupToGatePassOut(
    BuildContext context,
    GatePassModel obj,
    int index,
  ) async {
    var result = await DialogHelper.showConfirmationDialog(
      context: context,
      title: 'You are about to mark this Gate Pass Out?',
      message:
          'Marking this Gate Pass Out will confirm that the visitor has exited. Do you want to continue?',
      confirmText: "Out",
      icon: Icons.logout,
      confirmColor: AppColor.error,
    );
    if (result && context.mounted) {
      _gatePassCubit.updateGatePassOut(
        context: context,
        externalId: obj.externalId,
        uniquekey: obj.uniquekey,
        type: "Out",
        index: index,
      );
    }
  }

  Future<void> _showPopupToGatePassNotify(
    BuildContext context,
    GatePassModel obj,
    int index,
  ) async {
    var result = await DialogHelper.showConfirmationDialog(
      context: context,
      title: 'Notify Appointment person',
      message:
          'The appointment contact will be notified that their visitor has arrived at reception',
      confirmText: "Notify",
      icon: LucideIcons.bell,
      iconSize: 28,
    );
    if (result && context.mounted) {
      _gatePassCubit.updateGatePassOut(
        context: context,
        externalId: obj.externalId,
        uniquekey: obj.uniquekey,
        type: "Bell",
        index: index,
      );
    }
  }

  Future<void> _showBottomSheetToFilterGatePass(BuildContext context) async {
    final state = _gatePassCubit.state;

    _searchC.text = state.searchText;

    final String initialFullName = _searchC.text;
    final String initialMobileNumber = _mobileNumberC.text;
    final String initialAddress = _addressC.text;
    final String initialPurpose = _purposeC.text;
    final String initialAppointmentWith = _appointmentWithC.text;

    _startDateNotifier.value = state.filterStartDate;
    _endDateNotifier.value = state.filterEndDate;

    bool manualClose = false;
    final ValueNotifier<bool> applyEnabled = ValueNotifier<bool>(false);
    bool applied = false;

    void updateApplyState(StateSetter innerState) {
      innerState(() {
        manualClose =
            (_searchC.text.trim() != initialFullName) ||
            (_mobileNumberC.text.trim() != initialMobileNumber) ||
            (_addressC.text.trim() != initialAddress) ||
            (_purposeC.text.trim() != initialPurpose) ||
            (_appointmentWithC.text.trim() != initialAppointmentWith) ||
            (_startDateNotifier.value != state.filterStartDate) ||
            (_endDateNotifier.value != state.filterEndDate);
        applyEnabled.value = manualClose;
      });
    }

    DialogHelper.showCustomFilterBottomSheet(
      context,
      title: "Filter - Gate Pass",
      contentWidget: StatefulBuilder(
        builder: (context, innerState) {
          return SingleChildScrollView(
            padding: const EdgeInsets.only(right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextField(
                  title: "Visitor Name",
                  hint: "Enter Visitor Name",
                  textController: _searchC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
                CustomTextField(
                  title: "Mobile Number",
                  hint: "Enter Mobile Number",
                  textController: _mobileNumberC,
                  inputFormatterList: InputValidator.digit(10),
                  prefixType: CustomTextFieldPrefix.mobile,
                  keyboardType: TextInputType.number,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
                CustomTextField(
                  title: "Address",
                  hint: "Enter Address",
                  textController: _addressC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
                CustomTextField(
                  title: "Purpose",
                  hint: "Enter Purpose",
                  textController: _purposeC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
                CustomTextField(
                  title: "Appointment With",
                  hint: "Enter Appointment With",
                  textController: _appointmentWithC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),

                CustomFromToDatePicker(
                  fromDateTitle: "From Date",
                  toDateTitle: "To Date",
                  initialFromDate: _startDateNotifier.value,
                  initialToDate: _endDateNotifier.value,
                  isRequired: false,
                  removeBottomMargin: false,
                  onToDateChanged: (DateTime? fromDate, DateTime? toDate) {
                    _startDateNotifier.value = fromDate;
                    _endDateNotifier.value = toDate;

                    updateApplyState(innerState);
                  },
                ),
              ],
            ),
          );
        },
      ),
      onClear: () {
        _searchC.clear();
        _mobileNumberC.clear();
        _addressC.clear();
        _purposeC.clear();
        _appointmentWithC.clear();
        _startDateNotifier.value = null;
        _endDateNotifier.value = null;
        _gatePassCubit.applyGatePassFilterAndSort(
          context: context,
          isClear: true,
        );
      },
      onApply: () {
        final startDate = _startDateNotifier.value;

        final endDate = _endDateNotifier.value;
        _gatePassCubit.applyGatePassFilterAndSort(
          context: context,
          visitorName: _searchC.text.trim(),
          mobileNumber: _mobileNumberC.text.trim(),
          address: _addressC.text.trim(),
          purpose: _purposeC.text.trim(),
          appointmentWith: _appointmentWithC.text.trim(),
          startDate: startDate,
          endDate: endDate,
        );
      },
      isApplyEnabled: applyEnabled.value,
      applyEnabledNotifier: applyEnabled,
    );
    // IF BOTTOM SHEET CLOSE WITHOUT APPLYING
    if (!applied && manualClose) {
      _mobileNumberC.clear();
      _addressC.clear();
      _purposeC.clear();
      _appointmentWithC.clear();
    }
  }

  Future<void> _showBottomSheetToAddApproval(
    BuildContext context,
    GatePassModel visitor,
    int index,
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
                RadioGroup<bool>(
                  groupValue: isAccepted,
                  onChanged: (value) {
                    if (value == null) return;
                    innerState(() => isAccepted = value);
                  },
                  child: Row(
                    children: [
                      Radio<bool>(value: true),
                      Text("Accept", style: AppTextStyle.ts14M()),
                      horizontalSpacing(width: 16),
                      Radio<bool>(value: false),
                      Text("Reject", style: AppTextStyle.ts14M()),
                    ],
                  ),
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
            _saveForm(isAccepted, visitor, index);
          }
        },
      ),
    );
    _remarkC.clear();
  }

  void _saveForm(bool isAccepted, GatePassModel visitor, int index) {
    _gatePassCubit.addApproval(
      context: context,
      externalId: visitor.externalId,
      uniquekey: visitor.uniquekey,
      approvalRemark: _remarkC.text.trim(),
      approvalStatus: isAccepted ? "Approved" : "Rejected",
      index: index,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GatePassCubit, GatePassState>(
      listener: (context, state) {
        _filterCount.value = _gatePassCubit.updateGatePassFilterCount(state);
      },
      child: Scaffold(
        appBar: CustomAppBar(
          screenTitle: "Gate Pass",
          authorization: _gatePassRouteAuthorizationModel,
          onFilterTap: () {
            _showBottomSheetToFilterGatePass(context);
          },
          onAddCallback: () {
            goRouter.pushNamed(AppRoutes.addGatePass);
          },
          onExportCallback: (value) {
            _gatePassCubit.exportExcelPdf(context, value);
          },
          isFilterOn: true,
          searchHintText: "Search By Visitor Name",
          textController: _searchC,
          filterCountNotifier: _filterCount,
          onSearchSubmit: (value) {
            _gatePassCubit.searchGatePass(context, value);
          },
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            await _gatePassCubit.getGatePass(context, 1);
          },
          child: BlocBuilder<GatePassCubit, GatePassState>(
            builder: (context, state) {
              if ((state.isLoading ?? false) && state.gatePassList.isEmpty) {
                return Center(child: loader());
              }
              if (state.gatePassList.isEmpty) {
                return Center(
                  child: noDataWidget(
                    message: "No Gate Pass Data Found",
                    iconSize: 160.0,
                  ),
                );
              }
              return ListView.builder(
                controller: scrollController,
                itemCount: state.gatePassList.length + 1,
                shrinkWrap: true,
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 12.0),
                itemBuilder: (context, index) {
                  if (index == state.gatePassList.length) {
                    return state.gatePassList.length < state.totalNumberOfRecord
                        ? Padding(
                          padding: const EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        )
                        : const SizedBox.shrink();
                  }
                  return gatePassCard(context, state, index);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget gatePassCard(BuildContext context, GatePassState state, int index) {
    final visitor = state.gatePassList[index];
    final canAction =
        (_gatePassRouteAuthorizationModel.isAction ||
            _gatePassAdministrativeRouteAuthorizationModel.isAction);

    final disableEdit =
        visitor.passDateTime.isBefore(DateTime.now()) || !canAction;
    final canDelete = visitor.isDelete;
    final canGatePassIn = visitor.isApproval;
    final canGatePassOut = visitor.isCheckOutEnabled;
    final canNotify = visitor.isNotificationEnabled;
    return Container(
      margin: EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(16),
      decoration: commonCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    goRouter.pushNamed(
                      AppRoutes.viewGatePass,
                      extra: {"gatePass": visitor},
                    );
                  },
                  child: Text(
                    visitor.noOfParticipants == 0
                        ? visitor.fullName
                        : "${visitor.fullName} +${visitor.noOfParticipants}",
                    style: AppTextStyle.ts14M(color: AppColor.primary),
                  ),
                ),
              ),
              horizontalSpacing(),
              Expanded(
                child: Row(
                  spacing: 10,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CustomIconButton.edit(
                      isDisabled: disableEdit,
                      onPressed: () {
                        goRouter.pushNamed(
                          AppRoutes.addGatePass,
                          extra: {"gatePass": visitor, "index": index},
                        );
                      },
                    ),
                    CustomIconButton.delete(
                      isDisabled: !canDelete,
                      onPressed: () {
                        _showPopupToDeleteGatePass(context, visitor, index);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          verticalSpacing(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildColumnTitleValue(
                title: "Mobile Number",
                value: visitor.mobileNumber,
                customValueWidget: CustomClickToContactText(
                  countryCode: "+91",
                  value: visitor.mobileNumber,
                ),
              ),
              buildColumnTitleValue(
                title: "Purpose",
                value: visitor.purpose,
                customValueWidget: gatePassPurposeWidget(
                  visitor.purpose,
                  textStyle: AppTextStyle.ts12M(),
                ),
              ),
            ],
          ),
          verticalSpacing(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildColumnTitleValue(
                title: "Appointment With",
                value: visitor.employeeName,
              ),
              buildColumnTitleValue(
                title: "Appointment Date / Time",
                value: formatDate(visitor.passDateTime),
              ),
            ],
          ),
          buildColumnTitleValue(
            title: "Status",
            value: visitor.approvalStatus,
            removeExpanded: true,
            customValueWidget: Row(
              children: [
                visitorManagementDashboardStatusWidget(visitor.approvalStatus),
                if (visitor.approvalRemark.trim().isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      DialogHelper.showNoteDialog(
                        context,
                        note: visitor.approvalRemark,
                        title: "Approval Remark",
                      );
                    },
                    child: Padding(
                      padding: EdgeInsets.only(left: 5.sp),
                      child: Icon(
                        Icons.info_outline,
                        size: 18,
                        color: AppColor.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Divider(thickness: 1.0, color: AppColor.grey50),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              buildColumnTitleValue(
                title: "Out Date / Time",
                value: formatDate(visitor.outDateTime),
              ),
              horizontalSpacing(),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomIconButton(
                      isDisable: !canGatePassIn,
                      backgroundColor: AppColor.green20.withValues(alpha: 0.15),
                      onPressed:
                          canGatePassIn
                              ? () {
                                _showBottomSheetToAddApproval(
                                  context,
                                  visitor,
                                  index,
                                );
                              }
                              : () {},
                      icon: Icon(
                        LucideIcons.logIn,
                        size: 16,
                        color:
                            canGatePassIn ? AppColor.green20 : AppColor.grey2,
                      ),
                    ),
                    horizontalSpacing(),
                    CustomIconButton(
                      isDisable: !canGatePassOut,
                      backgroundColor: AppColor.red.withValues(alpha: 0.15),
                      onPressed:
                          canGatePassOut
                              ? () {
                                _showPopupToGatePassOut(
                                  context,
                                  visitor,
                                  index,
                                );
                              }
                              : () {},
                      icon: Icon(
                        LucideIcons.logOut,
                        size: 16,
                        color: canGatePassOut ? AppColor.red : AppColor.grey2,
                      ),
                    ),
                    horizontalSpacing(),
                    CustomIconButton(
                      isDisable: !canNotify,
                      onPressed:
                          canNotify
                              ? () {
                                _showPopupToGatePassNotify(
                                  context,
                                  visitor,
                                  index,
                                );
                              }
                              : () {},
                      icon: Icon(
                        LucideIcons.bell,
                        size: 16,
                        color: canNotify ? AppColor.primary : AppColor.grey2,
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
  }
}
