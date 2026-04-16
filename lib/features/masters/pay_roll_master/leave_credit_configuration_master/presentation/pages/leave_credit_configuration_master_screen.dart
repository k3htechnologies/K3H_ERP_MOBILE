import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/leave_credit_configuration_master/data/model/leave_credit_configuration_master.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/leave_credit_configuration_master/presentation/cubit/leave_credit_configuration_master_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class LeaveCreditConfigurationMasterScreen extends StatefulWidget {
  const LeaveCreditConfigurationMasterScreen({super.key});

  @override
  State<LeaveCreditConfigurationMasterScreen> createState() =>
      _LeaveCreditConfigurationMasterScreenState();
}

class _LeaveCreditConfigurationMasterScreenState
    extends State<LeaveCreditConfigurationMasterScreen> {
  // CUBIT
  late LeaveCreditConfigurationMasterCubit _leaveCreditConfigurationMasterCubit;

  // AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;

  // TEXT EDITING CONTROLLER
  late TextEditingController _searchC, _filterDesignationNameC;

  // PAGINATION
  late ScrollController scrollController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _leaveCreditConfigurationMasterCubit =
        context.read<LeaveCreditConfigurationMasterCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes
            .leaveCreditConfigurationMaster]!;
    _initializeTextEditingController();
    _initializeScrollController();
    _loadInitialData();
  }

  @override
  void dispose() {
    scrollController.dispose();
    _searchC.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // INITIALIZING TEXT EDITING CONTROLLER
  void _initializeTextEditingController() {
    _searchC = TextEditingController();
    _filterDesignationNameC = TextEditingController();
  }

  // INITIALIZE SCROLL CONTROLLER
  void _initializeScrollController() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !_leaveCreditConfigurationMasterCubit.state.isLoading! &&
          _leaveCreditConfigurationMasterCubit
                  .state
                  .leaveCreditConfigurationMasterList
                  .length <
              _leaveCreditConfigurationMasterCubit.state.totalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _leaveCreditConfigurationMasterCubit.getLeaveCreditConfigurationList(
            context,
            _leaveCreditConfigurationMasterCubit.state.currentPage + 1,
          );
        });
      }
    });
  }

  // LOAD INITIAL DATA
  void _loadInitialData() {
    if (_leaveCreditConfigurationMasterCubit
        .state
        .leaveCreditConfigurationMasterList
        .isEmpty) {
      _leaveCreditConfigurationMasterCubit.getLeaveCreditConfigurationList(
        context,
        1,
      );
    }
  }

  // SHOW DELETE DIALOG
  void _showDeleteDialog(
    BuildContext context,
    LeaveCreditConfigurationMasterModel leaveCreditConfigurationMaster,
    int currentPage,
    int index,
  ) {
    DialogHelper.deleteDialog(
      context,
      "You are about to delete a Leave Credit Configuration ?",
      "Deleting this Leave Credit Configuration will permanently remove all associated data.",
    ).then((value) {
      if (value == true) {
        if (context.mounted) {
          _leaveCreditConfigurationMasterCubit
              .deleteLeaveCreditConfigurationMaster(
                context: context,
                leaveCreditConfigurationId:
                    leaveCreditConfigurationMaster.leaveCreditConfigurationId,
                uniqueKey: leaveCreditConfigurationMaster.uniquekey,
                pageNumber: currentPage,
              );
        }
      }
    });
  }

  // Filter: Leave Credit Configuration
  Future<void> _showBottomSheetToFilterLeaveCreditConfiguration(
    BuildContext context,
  ) async {
    final state = _leaveCreditConfigurationMasterCubit.state;

    _filterDesignationNameC.text = state.filterDesignationName;

    final String initialBranchName = _filterDesignationNameC.text;

    DateTime? filterFromDate = state.filterFromLeaveCreditDate;
    DateTime? filterToDate = state.filterToLeaveCreditDate;
    final DateTime? initialFromDate = state.filterFromLeaveCreditDate;
    final DateTime? initialToDate = state.filterToLeaveCreditDate;

    bool manualClose = false;
    final ValueNotifier<bool> applyEnabled = ValueNotifier<bool>(false);
    bool applied = false;
    final filterFormKey = GlobalKey<FormState>();

    void updateApplyState(StateSetter innerState) {
      innerState(() {
        manualClose =
            (_filterDesignationNameC.text.trim() != initialBranchName) ||
            (filterFromDate != initialFromDate) ||
            (filterToDate != initialToDate);
        // Disable Apply when only one of From/To is set (both or neither required)
        final bool onlyOneSet =
            (filterFromDate != null && filterToDate == null) ||
            (filterToDate != null && filterFromDate == null);
        // Disable Apply when From > To (invalid range)
        final bool invalidRange =
            filterFromDate != null &&
            filterToDate != null &&
            filterFromDate!.isAfter(
              DateTime(
                filterToDate!.year,
                filterToDate!.month,
                filterToDate!.day,
              ),
            );
        final bool dobInvalid = onlyOneSet || invalidRange;
        applyEnabled.value = manualClose && !dobInvalid;
      });
    }

    DialogHelper.showCustomFilterBottomSheet(
      context,
      title: "Filter Leave Credit Configuration",
      contentWidget: StatefulBuilder(
        builder: (context, innerState) {
          return Form(
            key: filterFormKey,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(right: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextField(
                    textController: _filterDesignationNameC,
                    hint: "Enter Designation Name",
                    title: "Designation Name",
                    onChangeFunction: (_) => updateApplyState(innerState),
                  ),
                  CustomDatePicker(
                    title: "Date of Leave Credit (From)",
                    initialDate: filterFromDate,
                    setValue: (value) {
                      innerState(() {
                        filterFromDate = value;
                        updateApplyState(innerState);
                      });
                    },
                  ),
                  if (filterFromDate != null && filterToDate == null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 4),
                      child: Text(
                        'Please select To date also',
                        style: AppTextStyle.ts12R().copyWith(
                          color: AppColor.error,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  if (filterToDate != null && filterFromDate == null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 4),
                      child: Text(
                        'Please select From date also',
                        style: AppTextStyle.ts12R().copyWith(
                          color: AppColor.error,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  if (filterFromDate != null &&
                      filterToDate != null &&
                      filterFromDate!.isAfter(
                        DateTime(
                          filterToDate!.year,
                          filterToDate!.month,
                          filterToDate!.day,
                        ),
                      ))
                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 4),
                      child: Text(
                        'Invalid Date range',
                        style: AppTextStyle.ts12R().copyWith(
                          color: AppColor.error,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  CustomDatePicker(
                    title: "Date of Leave Credit (To)",
                    initialDate: filterToDate,
                    setValue: (value) {
                      innerState(() {
                        filterToDate = value;
                        updateApplyState(innerState);
                      });
                    },
                    validator: (value) {
                      if (filterFromDate != null && value == null) {
                        return 'Date of Birth (To) is required when Date of Birth (From) is entered';
                      }
                      if (filterFromDate != null &&
                          value != null &&
                          filterFromDate!.isAfter(
                            DateTime(value.year, value.month, value.day),
                          )) {
                        return 'Invalid Date range';
                      }
                      return null;
                    },
                  ),
                  verticalSpacing(),
                ],
              ),
            ),
          );
        },
      ),
      onClear: () {
        _filterDesignationNameC.clear();

        _leaveCreditConfigurationMasterCubit.applyFilterAndSort(
          context: context,
          filterFromLeaveCreditDate: null,
          filterToLeaveCreditDate: null,
          filterDesignationName: '',
        );
      },
      onApply: () {
        if (filterFormKey.currentState?.validate() ?? false) {
          applied = true;
          _leaveCreditConfigurationMasterCubit.applyFilterAndSort(
            context: context,
            filterDesignationName: _filterDesignationNameC.text,
            filterFromLeaveCreditDate: filterFromDate,
            filterToLeaveCreditDate: filterToDate,
          );
        }
      },
      isApplyEnabled: applyEnabled.value,
      applyEnabledNotifier: applyEnabled,
    );

    // IF BOTTOM SHEET CLOSE WITHOUT APPLYING
    if (!applied && manualClose) {
      _filterDesignationNameC.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        screenTitle: "Leave Credit Configuration",
        authorization: _routeAuthorizationModel,
        textController: _searchC,
        searchHintText: "Search by Department Name",
        onSearchSubmit: (value) {
          _leaveCreditConfigurationMasterCubit.searchLeaveCreditConfiguration(
            context,
            value,
          );
        },
        onAddCallback: () async {
          await goRouter.pushNamed(AppRoutes.addLeaveCreditConfigurationMaster);
          if (context.mounted) {
            _leaveCreditConfigurationMasterCubit.searchLeaveCreditConfiguration(
              context,
              "",
            );
          }
        },
        onExportCallback: (value) {
          if (_leaveCreditConfigurationMasterCubit.state.totalNumberOfRecord ==
              0) {
            showErrorMessage(context, "Error", "No Data Found");
            return;
          }
          _leaveCreditConfigurationMasterCubit.exportExcelPdf(context, value);
        },
        isFilterOn: true,
        onFilterTap: () {
          _showBottomSheetToFilterLeaveCreditConfiguration(context);
        },
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _searchC.clear();
          _leaveCreditConfigurationMasterCubit.searchLeaveCreditConfiguration(
            context,
            "",
          );
        },
        child: BlocBuilder<
          LeaveCreditConfigurationMasterCubit,
          LeaveCreditConfigurationMasterState
        >(
          builder: (context, state) {
            if ((state.isLoading ?? true) &&
                state.leaveCreditConfigurationMasterList.isEmpty) {
              return Center(child: loader());
            }
            if (state.leaveCreditConfigurationMasterList.isEmpty) {
              return ListView(
                physics: AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: getActualHeight(context) * .7,
                    child: Center(
                      child: noDataWidget(
                        message: "No Leave Credit Configuration Data Found",
                      ),
                    ),
                  ),
                ],
              );
            }
            return ListView.builder(
              controller: scrollController,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount:
                  _leaveCreditConfigurationMasterCubit
                      .state
                      .leaveCreditConfigurationMasterList
                      .length +
                  1,
              itemBuilder: (context, index) {
                if (index == state.leaveCreditConfigurationMasterList.length) {
                  return state.leaveCreditConfigurationMasterList.length <
                          state.totalNumberOfRecord
                      ? Padding(
                        padding: const EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      )
                      : const SizedBox.shrink();
                }
                var leaveCreditConfigurationMaster =
                    state.leaveCreditConfigurationMasterList[index];
                return Container(
                  margin: EdgeInsets.only(bottom: 10),
                  padding: EdgeInsets.all(12),
                  decoration: commonCardDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: GestureDetector(
                              onTap: () {
                                goRouter.pushNamed(
                                  AppRoutes.viewLeaveCreditConfigurationMaster,
                                  queryParameters: {
                                    "leaveCreditConfiguration":
                                        Uri.encodeComponent(
                                          EncryptionManager.encryptData(
                                            jsonEncode(
                                              leaveCreditConfigurationMaster
                                                  .toJson(),
                                            ),
                                          ),
                                        ),
                                  },
                                );
                              },
                              child: Text(
                                leaveCreditConfigurationMaster.departmentName,
                                style: AppTextStyle.ts16M(
                                  color: AppColor.primary,
                                ).copyWith(
                                  color: AppColor.primary,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              CustomIconButton.edit(
                                onPressed: () async {
                                  await goRouter.pushNamed(
                                    AppRoutes.addLeaveCreditConfigurationMaster,
                                    queryParameters: {
                                      'leaveCreditConfiguration':
                                          Uri.encodeComponent(
                                            EncryptionManager.encryptData(
                                              jsonEncode(
                                                leaveCreditConfigurationMaster
                                                    .toJson(),
                                              ),
                                            ),
                                          ),
                                      'index': index.toString(),
                                    },
                                  );
                                },
                              ),
                              horizontalSpacing(),
                              CustomIconButton.delete(
                                onPressed: () {
                                  _showDeleteDialog(
                                    context,
                                    leaveCreditConfigurationMaster,
                                    state.currentPage,
                                    index,
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      verticalSpacing(),
                      _buildInfoRow(
                        "Period Mode",
                        leaveCreditConfigurationMaster.leavePeriodMode,
                      ),
                      verticalSpacing(height: 5),
                      _buildInfoRow(
                        "Financial Year Start Date",
                        formatDateTimeAsDDMMMYYYY(
                          leaveCreditConfigurationMaster.financialYearStartDate,
                        ),
                      ),
                      verticalSpacing(height: 5),
                      _buildInfoRow(
                        "Financial Year End Date",
                        formatDateTimeAsDDMMMYYYY(
                          leaveCreditConfigurationMaster.financialYearEndDate,
                        ),
                      ),
                      verticalSpacing(height: 5),
                      _buildInfoRow(
                        "Designation",
                        leaveCreditConfigurationMaster.designationName.isEmpty
                            ? "-"
                            : leaveCreditConfigurationMaster.designationName,
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

  // BUILD INFO ROW
  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 170,
          child: Text(label, style: AppTextStyle.ts12R(color: AppColor.grey)),
        ),
        Text(": "),
        Expanded(child: Text(value, style: AppTextStyle.ts12R())),
      ],
    );
  }
}
