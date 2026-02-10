import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/week_off_mapping_master/data/model/week_off_mapping.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/week_off_mapping_master/presentation/cubit/week_off_mapping_cubit.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/week_off_mapping_master/presentation/cubit/week_off_mapping_state.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class WeekOffMappingMasterScreen extends StatefulWidget {
  const WeekOffMappingMasterScreen({super.key});

  @override
  State<WeekOffMappingMasterScreen> createState() =>
      _WeekOffMappingMasterScreenState();
}

class _WeekOffMappingMasterScreenState
    extends State<WeekOffMappingMasterScreen> {
  //CUBIT
  late WeekOffMappingMasterCubit _weekOffMappingMasterCubit;

  //AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;

  //PAGINATION
  late ScrollController scrollController;
  Timer? _debounce;

  // TEXT EDITING CONTROLLERS
  late TextEditingController _searchC, _filterDepartmentC, _filterEmployeeNameC;
  @override
  void initState() {
    super.initState();
    _weekOffMappingMasterCubit = context.read<WeekOffMappingMasterCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.weekOffMappingMaster] ??
        AuthorizationModel();
    _onScroll();
    _initializeTextEditingController();
    _weekOffMappingMasterCubit.getWeekOffMappingList(
      context: context,
      pageNumber: 1,
    );
  }

  void _initializeTextEditingController() {
    _searchC = TextEditingController();
    _filterDepartmentC = TextEditingController();
    _filterEmployeeNameC = TextEditingController();
  }

  // <---- PAGINATION ---->
  void _onScroll() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !(_weekOffMappingMasterCubit.state.isLoading ?? false) &&
          _weekOffMappingMasterCubit.state.weekOffMappingList.length <
              _weekOffMappingMasterCubit.state.totalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _weekOffMappingMasterCubit.getWeekOffMappingList(
            context: context,
            pageNumber: _weekOffMappingMasterCubit.state.currentPage + 1,
          );
        });
      }
    });
  }

  Future<void> _showPopupToDeleteWeekOffMappingMaster(
    BuildContext context,
    WeekOffMappingModel obj,
    int currentPage,
    int index,
  ) async {
    var result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a week off?',
      'Deleting this week off will permanently remove its contents.',
    );
    if (result && context.mounted) {
      _weekOffMappingMasterCubit.deleteWeekOffMapping(index, obj, context);
    }
  }

  // WEEK OFF MAPPING FILTER
  Future<void> _showBottomSheetToFilterWeekMapping(BuildContext context) async {
    final state = _weekOffMappingMasterCubit.state;

    // Initialize filter text controllers
    _filterDepartmentC.text = state.filterDepartmentName;
    _filterEmployeeNameC.text = state.filterEmployeeName;

    // Sorting
    String? selectedDirection =
        state.currentSortColumn == "Week Off Policy Name"
            ? state.currentSortDirection
            : null;

    // Keep initial values to detect changes
    final String initialDepartment = _filterDepartmentC.text;
    final String initialEmployeeName = _filterEmployeeNameC.text;
    final String? initialDirection = selectedDirection;

    bool manualClose = false;
    bool applied = false;
    final ValueNotifier<bool> applyEnabled = ValueNotifier<bool>(false);

    void updateApplyState(StateSetter innerState) {
      innerState(() {
        manualClose =
            (_filterDepartmentC.text.trim() != initialDepartment) ||
            (_filterEmployeeNameC.text.trim() != initialEmployeeName) ||
            (selectedDirection != initialDirection);

        applyEnabled.value = manualClose;
      });
    }

    DialogHelper.showCustomFilterBottomSheet(
      context,
      title: "Filter Week Off Mapping",
      contentWidget: StatefulBuilder(
        builder: (context, innerState) {
          void selectDirection(String direction) {
            innerState(() => selectedDirection = direction);
            updateApplyState(innerState);
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Sort By Week Off Name", style: AppTextStyle.ts14M()),
                verticalSpacing(),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => selectDirection("ASC"),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color:
                              selectedDirection == "ASC"
                                  ? AppColor.lightBlue
                                  : Colors.transparent,
                          border: Border.all(color: AppColor.grey, width: .5),
                        ),
                        child: Text("A-Z", style: AppTextStyle.ts12R()),
                      ),
                    ),
                    horizontalSpacing(),
                    GestureDetector(
                      onTap: () => selectDirection("DESC"),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color:
                              selectedDirection == "DESC"
                                  ? AppColor.lightBlue
                                  : Colors.transparent,
                          border: Border.all(color: AppColor.grey, width: .5),
                        ),
                        child: Text("Z-A", style: AppTextStyle.ts12R()),
                      ),
                    ),
                  ],
                ),

                verticalSpacing(height: 20),

                CustomTextField(
                  title: "Department",
                  hint: "Enter Department",
                  textController: _filterDepartmentC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
                verticalSpacing(height: 10),

                CustomTextField(
                  title: "Employee Name",
                  hint: "Enter Employee Name",
                  textController: _filterEmployeeNameC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
                verticalSpacing(height: 10),
              ],
            ),
          );
        },
      ),
      onClear: () {
        _weekOffMappingMasterCubit.applyFilterAndSort(
          context: context,
          filterDepartmentName: "",
          filterEmployeeName: "",
          sortColumn: "Created Date",
          sortDirection: "DESC",
        );
      },
      onApply: () {
        applied = true;
        _weekOffMappingMasterCubit.applyFilterAndSort(
          context: context,
          filterDepartmentName: _filterDepartmentC.text,
          filterEmployeeName: _filterEmployeeNameC.text,
          sortColumn: selectedDirection != null ? "Week Off Policy Name" : null,
          sortDirection: selectedDirection,
        );
      },
      isApplyEnabled: applyEnabled.value,
      applyEnabledNotifier: applyEnabled,
    );

    // If bottom sheet closed without applying, reset
    if (!applied && manualClose) {
      _filterDepartmentC.clear();
      _filterEmployeeNameC.clear();
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    _searchC.dispose();
    _filterDepartmentC.dispose();
    _filterEmployeeNameC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        screenTitle: "Week Off Mapping Master",
        authorization: _routeAuthorizationModel,
        onAddCallback: () {
          goRouter.pushNamed(AppRoutes.addWeekOffMappingMaster);
        },
        textController: _searchC,
        onExportCallback: (value) {
          if (_weekOffMappingMasterCubit.state.totalNumberOfRecord == 0) {
            showErrorMessage(context, "Error", "No Data Found");
            return;
          }
          _weekOffMappingMasterCubit.exportExcelPdf(context, value);
        },
        onSearchSubmit: (value) {
          _weekOffMappingMasterCubit.searchWeekOffMapping(value, context);
        },
        isFilterOn: true,
        onFilterTap: () {
          _showBottomSheetToFilterWeekMapping(context);
        },
      ),
      body: BlocBuilder<WeekOffMappingMasterCubit, WeekOffMappingMasterState>(
        builder: (context, state) {
          if ((state.isLoading ?? true) && state.weekOffMappingList.isEmpty) {
            return Center(child: loader());
          }
          if (state.weekOffMappingList.isEmpty) {
            return Center(child: noDataWidget());
          }
          return ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemCount: state.weekOffMappingList.length + 1,
            itemBuilder: (context, index) {
              if (index == state.weekOffMappingList.length) {
                return state.weekOffMappingList.length <
                        state.totalNumberOfRecord
                    ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    )
                    : const SizedBox.shrink();
              }
              var weekOffMappingMaster = state.weekOffMappingList[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: commonCardDecoration(),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: GestureDetector(
                            onTap: () {
                              goRouter.pushNamed(
                                AppRoutes.viewWeekOffMappingMaster,
                                queryParameters: {
                                  "weekOffMapping": Uri.encodeQueryComponent(
                                    EncryptionManager.encryptData(
                                      jsonEncode(weekOffMappingMaster.toJson()),
                                    ),
                                  ),
                                },
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 0,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: AppColor.primary),
                                ),
                              ),
                              child: Text(
                                weekOffMappingMaster.weekOffPolicyName,
                                style: AppTextStyle.ts16M(
                                  color: AppColor.primary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            CustomIconButton.edit(
                              onPressed: () async {
                                await goRouter.pushNamed(
                                  AppRoutes.addWeekOffMappingMaster,
                                  queryParameters: {
                                    "weekOffMapping": Uri.encodeQueryComponent(
                                      EncryptionManager.encryptData(
                                        jsonEncode(
                                          weekOffMappingMaster.toJson(),
                                        ),
                                      ),
                                    ),
                                    'index': index.toString(),
                                  },
                                );
                              },
                            ),
                            const SizedBox(width: 8),
                            CustomIconButton.delete(
                              onPressed: () {
                                _showPopupToDeleteWeekOffMappingMaster(
                                  context,
                                  weekOffMappingMaster,
                                  state.currentPage,
                                  index,
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    verticalSpacing(height: 10),

                    buildRowTitleValue(
                      title: "Deparment Name",
                      value: weekOffMappingMaster.departmentName,
                    ),
                    buildRowTitleValue(
                      title: "Employee Name",
                      value: weekOffMappingMaster.employeeName,
                    ),
                    buildRowTitleValue(
                      title: "Week Off",
                      value: weekOffMappingMaster.weekOffPolicyCode,
                    ),
                    buildRowTitleValue(
                      title: "Week Off 2",
                      value: weekOffMappingMaster.weeklyOff2,
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
