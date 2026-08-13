import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/shift_mapping_master/data/model/shift_master_mapping.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/shift_mapping_master/presentation/cubit/shift_master_mapping_cubit.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/shift_mapping_master/presentation/cubit/shift_master_mapping_state.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class ShiftMappingMasterScreen extends StatefulWidget {
  const ShiftMappingMasterScreen({super.key});

  @override
  State<ShiftMappingMasterScreen> createState() =>
      _ShiftMappingMasterScreenState();
}

class _ShiftMappingMasterScreenState extends State<ShiftMappingMasterScreen> {
  //CUBIT
  late ShiftMappingMasterCubit _shiftMappingMasterCubit;

  //AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;

  //PAGINATION
  late ScrollController scrollController;
  Timer? _debounce;

  // TEXT EDITING CONTROLLERS
  late TextEditingController _searchC, _filterDepartmentC, _filterEmployeeNameC;
  final ValueNotifier<int> _filterCount = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    _shiftMappingMasterCubit = context.read<ShiftMappingMasterCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.shiftMappingMaster] ??
        AuthorizationModel();
    _onScroll();
    _initializeTextEditingController();
    _shiftMappingMasterCubit.getShiftMappingList(
      context: context,
      pageNumber: 1,
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    _searchC.dispose();
    _filterDepartmentC.dispose();
    _filterEmployeeNameC.dispose();
    _debounce?.cancel();
    _filterCount.dispose();
    super.dispose();
  }

  // INITIALIZE TEXT EDITING CONTROLLERS
  void _initializeTextEditingController() {
    _searchC = TextEditingController();
    _filterEmployeeNameC = TextEditingController();
    _filterDepartmentC = TextEditingController();
  }

  // PAGINATION
  void _onScroll() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !(_shiftMappingMasterCubit.state.isLoading ?? false) &&
          _shiftMappingMasterCubit.state.shiftMappingList.length <
              _shiftMappingMasterCubit.state.totalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _shiftMappingMasterCubit.getShiftMappingList(
            context: context,
            pageNumber: _shiftMappingMasterCubit.state.currentPage + 1,
          );
        });
      }
    });
  }

  // DELETE SHIFT MAPPING MASTER
  Future<void> _showPopupToDeleteShiftMappingMaster(
    BuildContext context,
    ShiftMappingModel obj,
    int currentPage,
    int index,
  ) async {
    var result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a Shift Mapping ?',
      'Deleting this shiftMapping will permanently remove all associated data.',
    );
    if (result && context.mounted) {
      _shiftMappingMasterCubit.deleteShiftMapping(index, obj, context);
    }
  }

  // SHIFT MAPPING FILTER
  Future<void> _showBottomSheetToFilterShiftMapping(
    BuildContext context,
  ) async {
    final state = _shiftMappingMasterCubit.state;

    // Initialize filter text controllers
    _filterDepartmentC.text = state.filterDepartmentName;
    _filterEmployeeNameC.text = state.filterEmployeeName;
    _searchC.text = state.searchText;
    // Sorting
    String? selectedDirection =
        state.currentSortColumn == "Shift Name"
            ? state.currentSortDirection
            : null;

    // Keep initial values to detect changes
    final String initialShiftName = _searchC.text;
    final String initialDepartment = _filterDepartmentC.text;
    final String initialEmployeeName = _filterEmployeeNameC.text;
    final String? initialDirection = selectedDirection;

    bool manualClose = false;
    bool applied = false;
    final ValueNotifier<bool> applyEnabled = ValueNotifier<bool>(false);

    void updateApplyState(StateSetter innerState) {
      innerState(() {
        manualClose =
            (_searchC.text.trim() != initialShiftName) ||
            (_filterDepartmentC.text.trim() != initialDepartment) ||
            (_filterEmployeeNameC.text.trim() != initialEmployeeName) ||
            (selectedDirection != initialDirection);

        applyEnabled.value = manualClose;
      });
    }

    await DialogHelper.showCustomFilterBottomSheet(
      context,
      title: "Filter - Shift Mapping",
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
                Text("Sort By Shift Name", style: AppTextStyle.ts14M()),
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
                  title: "Shift Name",
                  hint: "Enter Shift Name",
                  textController: _searchC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
                CustomTextField(
                  title: "Department",
                  hint: "Enter Department",
                  textController: _filterDepartmentC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),

                CustomTextField(
                  title: "Employee Name",
                  hint: "Enter Employee Name",
                  textController: _filterEmployeeNameC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
              ],
            ),
          );
        },
      ),
      onClear: () {
        _shiftMappingMasterCubit.applyFilterAndSort(
          context: context,
          filterDepartmentName: "",
          filterShiftName: "",
          filterEmployeeName: "",
          sortColumn: "Created Date",
          sortDirection: "DESC",
        );
      },
      onApply: () {
        applied = true;
        _shiftMappingMasterCubit.applyFilterAndSort(
          context: context,
          filterDepartmentName: _filterDepartmentC.text.trim(),
          filterEmployeeName: _filterEmployeeNameC.text.trim(),
          filterShiftName: _searchC.text.trim(),
          sortColumn: selectedDirection != null ? "Shift Name" : null,
          sortDirection: selectedDirection,
        );
      },
      isApplyEnabled: applyEnabled.value,
      applyEnabledNotifier: applyEnabled,
    );

    // If bottom sheet closed without applying, reset
    if (!applied && manualClose) {
      _searchC.clear();
      _filterDepartmentC.clear();
      _filterEmployeeNameC.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ShiftMappingMasterCubit, ShiftMappingMasterState>(
      listener: (context, state) {
        _filterCount.value = _shiftMappingMasterCubit.updateFilterCount(state);
      },
      child: Scaffold(
        appBar: CustomAppBar(
          screenTitle: "Shift Mapping Master",
          authorization: _routeAuthorizationModel,
          filterCountNotifier: _filterCount,
          onAddCallback: () async {
            await goRouter.pushNamed(AppRoutes.addShiftMappingMaster);
            if (context.mounted) {
              _shiftMappingMasterCubit.searchShiftMapping("", context);
            }
          },
          textController: _searchC,
          searchHintText: "Search by Shift Name",
          onExportCallback: (value) {
            if (_shiftMappingMasterCubit.state.totalNumberOfRecord == 0) {
              showErrorMessage(context, "Error", "No Data Found");
              return;
            }
            _shiftMappingMasterCubit.exportExcelPdf(context, value);
          },
          onSearchSubmit: (value) {
            _shiftMappingMasterCubit.searchShiftMapping(value, context);
          },
          isFilterOn: true,
          onFilterTap: () {
            _showBottomSheetToFilterShiftMapping(context);
          },
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            _searchC.clear();
            _shiftMappingMasterCubit.searchShiftMapping("", context);
          },
          child: BlocBuilder<ShiftMappingMasterCubit, ShiftMappingMasterState>(
            builder: (context, state) {
              if ((state.isLoading ?? true) && state.shiftMappingList.isEmpty) {
                return Center(child: loader());
              }
              if (state.shiftMappingList.isEmpty) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(
                      height: getActualHeight(context) * .7,
                      child: Center(
                        child: noDataWidget(
                          message: "No Shift Mappings Data Found",
                        ),
                      ),
                    ),
                  ],
                );
              }
              return ListView.builder(
                controller: scrollController,
                physics: AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                itemCount: state.shiftMappingList.length + 1,
                itemBuilder: (context, index) {
                  if (index == state.shiftMappingList.length) {
                    return state.shiftMappingList.length <
                            state.totalNumberOfRecord
                        ? const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        )
                        : const SizedBox.shrink();
                  }
                  var shiftMappingMaster = state.shiftMappingList[index];
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
                                    AppRoutes.viewShiftMappingMaster,
                                    queryParameters: {
                                      "shiftMapping": Uri.encodeQueryComponent(
                                        EncryptionManager.encryptData(
                                          jsonEncode(
                                            shiftMappingMaster.toJson(),
                                          ),
                                        ),
                                      ),
                                    },
                                  );
                                },
                                child: Text(
                                  shiftMappingMaster.shiftName,
                                  style: AppTextStyle.ts16M(
                                    color: AppColor.primary,
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
                                      AppRoutes.addShiftMappingMaster,
                                      queryParameters: {
                                        "shiftMapping":
                                            Uri.encodeQueryComponent(
                                              EncryptionManager.encryptData(
                                                jsonEncode(
                                                  shiftMappingMaster.toJson(),
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
                                    _showPopupToDeleteShiftMappingMaster(
                                      context,
                                      shiftMappingMaster,
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
                          value: shiftMappingMaster.departmentName,
                        ),
                        buildRowTitleValue(
                          title: "Employee Name",
                          value: shiftMappingMaster.employeeName,
                        ),
                        buildRowTitleValue(
                          title: "Shift Code",
                          value: shiftMappingMaster.shiftCode,
                        ),
                        buildRowTitleValue(
                          title: "Start Time",
                          value: shiftMappingMaster.shiftBeginTime,
                        ),

                        buildRowTitleValue(
                          title: "End Time",
                          value: shiftMappingMaster.shiftEndTime,
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  // BUILD ROW TITLE VALUE
  Widget buildRowTitleValue({required String title, required String value}) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TITLE
          SizedBox(
            width: 160,
            child: Text(title, style: AppTextStyle.ts14R(color: AppColor.grey)),
          ),

          // COLON
          SizedBox(
            width: 20,
            child: Text(
              ":",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColor.grey),
            ),
          ),

          // VALUE
          Expanded(
            child: Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyle.ts14R(),
            ),
          ),
        ],
      ),
    );
  }
}
