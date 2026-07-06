import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/leave_type_master/data/model/leave_type_master.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/leave_type_master/presentation/cubit/leave_type_master_cubit.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/leave_type_master/presentation/cubit/leave_type_master_state.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class LeaveTypeMasterScreen extends StatefulWidget {
  const LeaveTypeMasterScreen({super.key});

  @override
  State<LeaveTypeMasterScreen> createState() => _LeaveTypeMasterScreenState();
}

class _LeaveTypeMasterScreenState extends State<LeaveTypeMasterScreen> {
  //CUBIT
  late LeaveTypeMasterCubit _leaveTypeMasterCubit;

  //AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;

  //PAGINATION
  late ScrollController scrollController;
  Timer? _debounce;

  // TEXT EDITING CONTROLLERS
  late TextEditingController _searchC;

  @override
  void initState() {
    super.initState();
    _leaveTypeMasterCubit = context.read<LeaveTypeMasterCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.leaveTypeMaster] ??
        AuthorizationModel();

    _onScroll();
    _initializeTextEditingController();
    _leaveTypeMasterCubit.getLeaveTypeList(context: context, pageNumber: 1);
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
    _searchC.dispose();
  }

  // INITIALIZE TEXT EDITING CONTROLLERS
  void _initializeTextEditingController() {
    _searchC = TextEditingController();
  }

  // PAGINATION
  void _onScroll() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !(_leaveTypeMasterCubit.state.isLoading ?? false) &&
          _leaveTypeMasterCubit.state.leaveTypeList.length <
              _leaveTypeMasterCubit.state.totalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _leaveTypeMasterCubit.getLeaveTypeList(
            context: context,
            pageNumber: _leaveTypeMasterCubit.state.currentPage + 1,
          );
        });
      }
    });
  }

  // DELETE LEAVE TYPE MASTER
  Future<void> _showPopupToDeleteLeaveTypeMaster(
    BuildContext context,
    LeaveTypeModel obj,
    int currentPage,
    int index,
  ) async {
    var result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a Leave Type?',
      'Deleting this Leave Type will permanently remove its contents.',
    );
    if (result && context.mounted) {
      _leaveTypeMasterCubit.deleteLeaveType(index, obj, context);
    }
  }

  // SORT BOTTOM SHEET - LEAVE TYPE (LEAVE TYPE)
  Future<void> _showSortBottomSheetForLeaveType(BuildContext context) async {
    final state = _leaveTypeMasterCubit.state;

    String? selectedDirection =
        state.currentSortColumn == "Leave Type"
            ? state.currentSortDirection
            : null;

    final String? initialDirection = selectedDirection;

    final ValueNotifier<bool> applyEnabled = ValueNotifier<bool>(false);

    void updateApplyState(StateSetter innerState) {
      innerState(() {
        applyEnabled.value = selectedDirection != initialDirection;
      });
    }

    DialogHelper.showCustomFilterBottomSheet(
      context,
      title: "Sort Leave Type",
      contentWidget: StatefulBuilder(
        builder: (context, innerState) {
          void selectDirection(String direction) {
            innerState(() {
              selectedDirection = direction;
            });
            updateApplyState(innerState);
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Sort By Leave Type", style: AppTextStyle.ts14M()),
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
            ],
          );
        },
      ),
      onClear: () {
        _leaveTypeMasterCubit.applyFilterAndSort(
          context: context,
          sortColumn: "Created Date",
          sortDirection: "DESC",
        );
      },
      onApply: () {
        _leaveTypeMasterCubit.applyFilterAndSort(
          context: context,
          sortColumn: "Leave Type",
          sortDirection: selectedDirection,
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
        screenTitle: "Leave Type Master",
        authorization: _routeAuthorizationModel,
        onAddCallback: () async {
          await goRouter.pushNamed(AppRoutes.addLeaveTypeMaster);
          if (context.mounted) {
            _leaveTypeMasterCubit.searchLeaveType("", context);
          }
        },
        textController: _searchC,
        searchHintText: "Search by Leave Type",
        onExportCallback: (value) {
          if (_leaveTypeMasterCubit.state.totalNumberOfRecord == 0) {
            showErrorMessage(context, "Error", "No Data Found");
            return;
          }
          _leaveTypeMasterCubit.exportExcelPdf(context, value);
        },
        onSearchSubmit: (value) {
          _leaveTypeMasterCubit.searchLeaveType(value, context);
        },
        isFilterOn: true,
        onFilterTap: () {
          _showSortBottomSheetForLeaveType(context);
        },
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _searchC.clear();
          _leaveTypeMasterCubit.searchLeaveType("", context);
        },
        child: BlocBuilder<LeaveTypeMasterCubit, LeaveTypeMasterState>(
          builder: (context, state) {
            if ((state.isLoading ?? true) && state.leaveTypeList.isEmpty) {
              return Center(child: loader());
            }
            if (state.leaveTypeList.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: getActualHeight(context) * .7,
                    child: Center(
                      child: noDataWidget(message: "No Leave Types Data Found"),
                    ),
                  ),
                ],
              );
            }
            return ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: state.leaveTypeList.length + 1,
              itemBuilder: (context, index) {
                if (index == state.leaveTypeList.length) {
                  return state.leaveTypeList.length < state.totalNumberOfRecord
                      ? const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      )
                      : const SizedBox.shrink();
                }
                var leaveType = state.leaveTypeList[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: commonCardDecoration(),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              leaveType.leaveType,
                              style: AppTextStyle.ts16M(),
                            ),
                          ),
                          horizontalSpacing(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              CustomIconButton.edit(
                                onPressed: () async {
                                  await goRouter.pushNamed(
                                    AppRoutes.addLeaveTypeMaster,
                                    queryParameters: {
                                      "leaveType": Uri.encodeQueryComponent(
                                        EncryptionManager.encryptData(
                                          jsonEncode(leaveType.toJson()),
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
                                  _showPopupToDeleteLeaveTypeMaster(
                                    context,
                                    leaveType,
                                    state.currentPage,
                                    index,
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      buildRowTitleValue(
                        title: "Leave Type Code",
                        value: leaveType.leaveTypeCode,
                      ),
                      buildRowTitleValue(
                        title: "Carry Forward",
                        value: leaveType.isCarryForward == true ? "Yes" : "No",
                      ),
                      buildRowTitleValue(
                        title: "Max Carry Forward",
                        value: leaveType.maxCarryForward.toString(),
                      ),
                      buildRowTitleValue(
                        title: "Encashable",
                        value: leaveType.isEncashable == true ? "Yes" : "No",
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
