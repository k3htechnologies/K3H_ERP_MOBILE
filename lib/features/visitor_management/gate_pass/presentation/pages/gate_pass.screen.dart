import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/visitor_management/gate_pass/data/model/gate_pass.model.dart';
import 'package:k3h_erp_app/features/visitor_management/gate_pass/presentation/cubit/gate_pass_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
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
  late TextEditingController _searchC,
      _mobileNumberC,
      _addressC,
      _purposeC,
      _appointmentWithC;

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
    initialiseCOntrollers();
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
    super.dispose();
  }

  void initialiseCOntrollers() {
    _searchC = TextEditingController();
    _mobileNumberC = TextEditingController();
    _addressC = TextEditingController();
    _purposeC = TextEditingController();
    _appointmentWithC = TextEditingController();
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
    var result = await DialogHelper.deleteDialog(
      context,
      'You are about to mark this Gate Pass Out?',
      'Marking this Gate Pass Out will confirm that the visitor has exited. Do you want to continue?',
      deleteButtonTxt: "Out",
    );
    if (result && context.mounted) {
      _gatePassCubit.updateGatePassOut(
        context: context,
        externalId: obj.externalId,
        uniquekey: obj.uniquekey,
        type: "Out",
      );
    }
  }

  Future<void> _showPopupToGatePassNotify(
    BuildContext context,
    GatePassModel obj,
    int index,
  ) async {
    var result = await DialogHelper.deleteDialog(
      context,
      'Notify Appointment person',
      'The appointment contact will be notified that their visitor has arrived at reception',
      deleteButtonTxt: "Notify",
    );
    if (result && context.mounted) {
      _gatePassCubit.updateGatePassOut(
        context: context,
        externalId: obj.externalId,
        uniquekey: obj.uniquekey,
        type: "Bell",
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

  // GETTERS
  bool _canDeleteGatePass(GatePassModel gatePass) {
    return _gatePassRouteAuthorizationModel.isAction &&
        _gatePassAdministrativeRouteAuthorizationModel.isAction &&
        gatePass.passDateTime.isAfter(DateTime.now());
  }

  bool _canGatePassOut(GatePassModel gatePass) {
    return _gatePassRouteAuthorizationModel.isAction &&
        _gatePassAdministrativeRouteAuthorizationModel.isAction &&
        !gatePass.passDateTime.isAfter(DateTime.now()) &&
        gatePass.outDateTime == null;
  }

  bool _canNotifyGatePass(GatePassModel gatePass) {
    return _gatePassRouteAuthorizationModel.isAction &&
        _gatePassAdministrativeRouteAuthorizationModel.isAction &&
        gatePass.outDateTime == null;
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
                padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
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
    final gatePass = state.gatePassList[index];
    final canDelete = _canDeleteGatePass(gatePass);
    final canGatePassOut = _canGatePassOut(gatePass);
    final canNotify = _canNotifyGatePass(gatePass);
    return Container(
      margin: EdgeInsets.only(bottom: 10.0),
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
                      extra: {"gatePass": gatePass},
                    );
                  },
                  child: Text(
                    gatePass.noOfParticipants == 0
                        ? gatePass.fullName
                        : "${gatePass.fullName} +${gatePass.noOfParticipants}",
                    style: AppTextStyle.ts14M(color: AppColor.primary),
                  ),
                ),
              ),
              horizontalSpacing(),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CustomIconButton.delete(
                      isDisabled: !canDelete,
                      onPressed: () {
                        _showPopupToDeleteGatePass(context, gatePass, index);
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
                value: gatePass.mobileNumber,
              ),
              buildColumnTitleValue(
                title: "Purpose",
                value: gatePass.purpose,
                customValueWidget: gatePassPurposeWidget(gatePass.purpose),
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
                value: gatePass.employeeName,
              ),
              buildColumnTitleValue(
                title: "Appointment Date / Time",
                value: formatDate(gatePass.passDateTime),
              ),
            ],
          ),
          Divider(
            thickness: 1.0,
            color: AppColor.grey10.withValues(alpha: 0.5),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildColumnTitleValue(
                title: "Out Date / Time",
                value: formatDate(gatePass.outDateTime),
              ),
              horizontalSpacing(),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap:
                          canGatePassOut
                              ? () {
                                _showPopupToGatePassOut(
                                  context,
                                  gatePass,
                                  index,
                                );
                              }
                              : null,
                      child: Icon(
                        LucideIcons.logOut,
                        size: 18,
                        color:
                            canGatePassOut ? AppColor.primary : AppColor.grey,
                      ),
                    ),
                    horizontalSpacing(),
                    GestureDetector(
                      onTap:
                          canNotify
                              ? () {
                                _showPopupToGatePassNotify(
                                  context,
                                  gatePass,
                                  index,
                                );
                              }
                              : null,
                      child: Icon(
                        LucideIcons.bell,
                        size: 18,
                        color: canNotify ? AppColor.primary : AppColor.grey,
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
