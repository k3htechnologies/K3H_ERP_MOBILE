import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/crm/brokerage/presentation/cubit/brokerage_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class BrokerageScreen extends StatefulWidget {
  const BrokerageScreen({super.key});

  @override
  State<BrokerageScreen> createState() => _BrokerageScreenState();
}

class _BrokerageScreenState extends State<BrokerageScreen> {
  // CUBIT
  late BrokerageCubit _brokerageCubit;

  // AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;

  // PAGINATION
  late ScrollController scrollController;
  Timer? _debounce;

  // TEXT EDITING CONTROLLERS
  late TextEditingController _searchC,
      _filterCpCompanyC,
      _filterCpMobileNoC,
      _filterApplicantNameC,
      _filterApplicantMobileNoC,
      _filterWingC,
      _filterFlatC,
      _filterFloorC,
      _filterAgreementValueC,
      _filterBookingTypeC;

  // PROJECT MODEL
  late ProjectModel _project;
  // FILTER
  final ValueNotifier<DateTime?> _startDateNotifier = ValueNotifier<DateTime?>(
    null,
  );
  final ValueNotifier<DateTime?> _endDateNotifier = ValueNotifier<DateTime?>(
    null,
  );

  @override
  void initState() {
    super.initState();
    _brokerageCubit = context.read<BrokerageCubit>();
    _initializeTextEditingController();
    _project = getProject();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.brokerage]!;
    _onScroll();
    _brokerageCubit.getBrokerageBookingList(context, 1, _project.projectId);
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
    _searchC.dispose();
  }

  void _initializeTextEditingController() {
    _searchC = TextEditingController();
    _filterCpCompanyC = TextEditingController();
    _filterCpMobileNoC = TextEditingController();
    _filterApplicantNameC = TextEditingController();
    _filterApplicantMobileNoC = TextEditingController();
    _filterWingC = TextEditingController();
    _filterFlatC = TextEditingController();
    _filterFloorC = TextEditingController();
    _filterAgreementValueC = TextEditingController();
    _filterBookingTypeC = TextEditingController();
  }

  // <---- PAGINATION ---->
  void _onScroll() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !_brokerageCubit.state.isLoading! &&
          _brokerageCubit.state.brokerageList.length <
              _brokerageCubit.state.totalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _brokerageCubit.getBrokerageBookingList(
            context,
            _brokerageCubit.state.currentPage + 1,
            _project.projectId,
          );
        });
      }
    });
  }

  Future<void> _showBottomSheetToFilterBrokerage(BuildContext context) async {
    final s = _brokerageCubit.state;

    _filterCpCompanyC.text = s.filterCpCompany;
    _filterCpMobileNoC.text = s.filterCpMobileNo;
    _filterApplicantNameC.text = s.filterApplicantName;
    _filterApplicantMobileNoC.text = s.filterApplicantMobileNo;
    _filterWingC.text = s.filterWing;
    _filterFlatC.text = s.filterFlat;
    _filterFloorC.text = s.filterFloor;

    _filterAgreementValueC.text =
        s.filterAgreementValue == 0 ? '' : s.filterAgreementValue.toString();

    _filterBookingTypeC.text = s.filterBookingType;

    _startDateNotifier.value = s.filterByFromDate;
    _endDateNotifier.value = s.filterByToDate;

    bool manualClose = false;

    final ValueNotifier<bool> applyEnabled = ValueNotifier<bool>(false);

    void updateApplyState(StateSetter innerState) {
      innerState(() {
        manualClose =
            _filterCpCompanyC.text.trim() != s.filterCpCompany ||
            _filterCpMobileNoC.text.trim() != s.filterCpMobileNo ||
            _filterApplicantNameC.text.trim() != s.filterApplicantName ||
            _filterApplicantMobileNoC.text.trim() !=
                s.filterApplicantMobileNo ||
            _filterWingC.text.trim() != s.filterWing ||
            _filterFlatC.text.trim() != s.filterFlat ||
            _filterFloorC.text.trim() != s.filterFloor ||
            (_filterAgreementValueC.text.isEmpty
                    ? 0
                    : double.tryParse(_filterAgreementValueC.text) ?? 0) !=
                s.filterAgreementValue ||
            _filterBookingTypeC.text.trim() != s.filterBookingType ||
            _startDateNotifier.value != s.filterByFromDate ||
            _endDateNotifier.value != s.filterByToDate;

        applyEnabled.value = manualClose;
      });
    }

    await DialogHelper.showCustomFilterBottomSheet(
      context,
      title: "Filter Brokerage",
      contentWidget: StatefulBuilder(
        builder: (context, innerState) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                verticalSpacing(),

                CustomTextField(
                  textController: _filterCpCompanyC,
                  title: "CP Company",
                  hint: 'Enter CP Company',
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),

                CustomTextField(
                  textController: _filterCpMobileNoC,
                  title: "CP Mobile No",
                  hint: 'Enter CP Mobile No',
                  keyboardType: TextInputType.phone,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),

                CustomTextField(
                  textController: _filterApplicantNameC,
                  title: "Applicant Name",
                  hint: 'Enter Applicant Name',
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),

                CustomTextField(
                  textController: _filterApplicantMobileNoC,
                  title: "Applicant Mobile No",
                  hint: 'Enter Applicant Mobile No',
                  keyboardType: TextInputType.phone,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),

                CustomTextField(
                  textController: _filterWingC,
                  title: "Wing",
                  hint: 'Enter Wing',
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),

                CustomTextField(
                  textController: _filterFlatC,
                  title: "Flat",
                  hint: 'Enter Flat',
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),

                CustomTextField(
                  textController: _filterFloorC,
                  title: "Floor",
                  hint: 'Enter Floor',
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),

                CustomTextField(
                  textController: _filterAgreementValueC,
                  title: "Agreement Value",
                  hint: 'Enter Agreement Value',
                  keyboardType: TextInputType.number,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),

                CustomTextField(
                  textController: _filterBookingTypeC,
                  title: "Booking Type",
                  hint: 'Enter Booking Type',
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),

                Row(
                  children: [
                    Expanded(
                      child: ValueListenableBuilder<DateTime?>(
                        valueListenable: _startDateNotifier,
                        builder: (context, startDate, child) {
                          return CustomDatePicker(
                            title: "Start Date",
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
                                title: "End Date",
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
                                      return 'End Date cannot be before Start Date';
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
              ],
            ),
          );
        },
      ),

      onClear: () {
        _filterCpCompanyC.clear();
        _filterCpMobileNoC.clear();
        _filterApplicantNameC.clear();
        _filterApplicantMobileNoC.clear();
        _filterWingC.clear();
        _filterFlatC.clear();
        _filterFloorC.clear();
        _filterAgreementValueC.clear();
        _filterBookingTypeC.clear();

        _startDateNotifier.value = null;
        _endDateNotifier.value = null;

        _brokerageCubit.applyFilterAndSort(
          context: context,
          projectId: _project.projectId,
          filterByFromDate: null,
          filterByToDate: null,
          filterCpCompany: '',
          filterCpMobileNo: '',
          filterApplicantName: '',
          filterApplicantMobileNo: '',
          filterWing: '',
          filterFlat: '',
          filterFloor: '',
          filterAgreementValue: 0,
          filterBookingType: '',
        );
      },

      onApply: () {
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
              "End Date cannot be before Start Date",
            );

            return;
          }
        }

        _brokerageCubit.applyFilterAndSort(
          context: context,
          projectId: _project.projectId,
          filterByFromDate: startDate,
          filterByToDate: endDate,
          filterCpCompany: _filterCpCompanyC.text.trim(),
          filterCpMobileNo: _filterCpMobileNoC.text.trim(),
          filterApplicantName: _filterApplicantNameC.text.trim(),
          filterApplicantMobileNo: _filterApplicantMobileNoC.text.trim(),
          filterWing: _filterWingC.text.trim(),
          filterFlat: _filterFlatC.text.trim(),
          filterFloor: _filterFloorC.text.trim(),
          filterAgreementValue:
              double.tryParse(_filterAgreementValueC.text.trim()) ?? 0,
          filterBookingType: _filterBookingTypeC.text.trim(),
        );
      },

      isApplyEnabled: applyEnabled.value,
      applyEnabledNotifier: applyEnabled,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        screenTitle: "Brokerage",
        authorization: _routeAuthorizationModel,
        searchHintText: "Search by CP Name",
        isFilterOn: true,
        onFilterTap: () {
          _showBottomSheetToFilterBrokerage(context);
        },
        onSearchSubmit: (value) {
          _brokerageCubit.searchBrokerage(context, value, _project.projectId);
        },
        textController: _searchC,
        onExportCallback: (value) {
          _brokerageCubit.exportExcelPdf(context, value, _project.projectId);
        },
        onProjectChangeCallback: (value) {
          _project = value;
          _brokerageCubit.applyFilterAndSort(
            context: context,
            projectId: _project.projectId,
            filterByFromDate: null,
            filterByToDate: null,
            filterCpCompany: '',
            filterCpMobileNo: '',
            filterApplicantName: '',
            filterApplicantMobileNo: '',
            filterWing: '',
            filterFlat: '',
            filterFloor: '',
            filterAgreementValue: 0,
            filterBookingType: '',
          );
          _brokerageCubit.searchBrokerage(context, "", value.projectId);
        },
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _searchC.clear();
          _brokerageCubit.searchBrokerage(context, "", _project.projectId);
        },
        child: BlocBuilder<BrokerageCubit, BrokerageState>(
          builder: (context, state) {
            if ((state.isLoading ?? true) && state.brokerageList.isEmpty) {
              return Center(child: loader());
            }
            if (state.brokerageList.isEmpty) {
              return ListView(
                physics: AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: getActualHeight(context) * .7,
                    child: Center(
                      child: noDataWidget(
                        message: "No Brokerage Booking Data Found",
                      ),
                    ),
                  ),
                ],
              );
            }
            return ListView.builder(
              controller: scrollController,

              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: _brokerageCubit.state.brokerageList.length + 1,
              itemBuilder: (context, index) {
                if (index == state.brokerageList.length) {
                  return state.brokerageList.length < state.totalNumberOfRecord
                      ? Padding(
                        padding: const EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      )
                      : const SizedBox.shrink();
                }
                var brokerage = state.brokerageList[index];
                return Container(
                  margin: EdgeInsets.only(bottom: 10),
                  padding: EdgeInsets.all(12),
                  decoration: commonCardDecoration(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                await _brokerageCubit.resetSearch();
                                goRouter.pushNamed(
                                  AppRoutes.viewBrokerage,
                                  queryParameters: {
                                    "brokerage": Uri.encodeQueryComponent(
                                      EncryptionManager.encryptData(
                                        jsonEncode(brokerage.toJson()),
                                      ),
                                    ),
                                  },
                                );
                              },
                              child: Text(
                                brokerage.channelPartnerName,
                                style: AppTextStyle.ts16M(
                                  color: AppColor.primary,
                                ).copyWith(
                                  decoration: TextDecoration.underline,
                                  decorationColor: AppColor.primary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      buildRowTitleValue(
                        title: "Company Name",
                        value: brokerage.channelPartnerCompany,
                      ),
                      buildRowTitleValue(
                        title: "Mobile No.",
                        value: brokerage.channelPartnerMobileNumber,
                      ),
                      buildRowTitleValue(
                        title: "Brokerage Amount",
                        value: addCommasToInteger(brokerage.brokerageAmount),
                      ),
                      buildRowTitleValue(
                        title: "Raised Invoice Amount",
                        value: addCommasToInteger(0),
                      ),

                      buildRowTitleValue(
                        title: "Paid Amount",
                        value: addCommasToInteger(
                          brokerage.paidBrokerageAmount,
                        ),
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
}
