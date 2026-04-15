import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/leave_type_master/data/model/leave_type_master.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/leave_type_master/data/repository/leave_type_master.repository.dart';
import 'package:k3h_erp_app/features/payroll/leave/model/leave.model.dart';
import 'package:k3h_erp_app/features/payroll/leave/presentation/cubit/leave_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/chip_style_tab_bar.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_multi_select_pop_up.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class LeaveScreen extends StatefulWidget {
  const LeaveScreen({super.key});

  @override
  State<LeaveScreen> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends State<LeaveScreen>
    with TickerProviderStateMixin {
  // CUBIT
  late LeaveCubit _leaveCubit;

  // AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;

  final LeaveTypeMasterRepository _leaveTypeMasterRepository =
      serviceLocator<LeaveTypeMasterRepository>();

  // PAGINATION
  late ScrollController scrollController;
  Timer? _debounce;

  // TAB
  TabController? _tabController;

  // TEXT EDITING CONTROLLERS
  late TextEditingController _searchC;

  // LEAVE TYPE VARIABLE
  final ValueNotifier<List<Map<String, dynamic>>> _selectedLeaveTypeNotifier =
      ValueNotifier([]);

  // DATE VARIABLES
  final ValueNotifier<DateTime?> _startDateNotifier = ValueNotifier(null);
  final ValueNotifier<DateTime?> _endDateNotifier = ValueNotifier(null);

  static const List<String> _statusTabs = [
    "All",
    "Pending",
    "Approved",
    "Rejected",
  ];

  @override
  void initState() {
    super.initState();
    _leaveCubit = context.read<LeaveCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.leave]!;
    _initializeTextEditingController();
    _onScroll();
    _leaveCubit.getLeaveList(context, 1);
    _tabController = TabController(
      length: _statusTabs.length,
      vsync: this,
      initialIndex: _leaveCubit.state.currentTabIndex.clamp(
        0,
        _statusTabs.length - 1,
      ),
    );
    _tabController!.addListener(_onStatusTabChanged);
  }

  void _onStatusTabChanged() {
    if (_tabController != null && !_tabController!.indexIsChanging && mounted) {
      _leaveCubit.onTabChanged(_tabController!.index, context);
    }
  }

  @override
  void dispose() {
    _tabController?.removeListener(_onStatusTabChanged);
    _tabController?.dispose();
    _searchC.dispose();
    _selectedLeaveTypeNotifier.dispose();
    _startDateNotifier.dispose();
    _endDateNotifier.dispose();
    scrollController.dispose();
    super.dispose();
  }

  // PREFILL FILTER FROM STATE
  void _prefillFilterFromState() {
    final s = _leaveCubit.state;
    if (s.filterLeaveType != null && s.filterLeaveType!.isNotEmpty) {
      final match =
          s.leaveTypeList
              .where((t) => t.leaveType == s.filterLeaveType)
              .toList();
      if (match.isNotEmpty) {
        final t = match.first;
        _selectedLeaveTypeNotifier.value = [
          {
            "zAttributesId": t.leaveTypeMasterId.toString(),
            "DisplayName": t.leaveType,
          },
        ];
      } else {
        _selectedLeaveTypeNotifier.value = [];
      }
    } else {
      _selectedLeaveTypeNotifier.value = [];
    }
    _startDateNotifier.value = s.filterStartDate;
    _endDateNotifier.value = s.filterEndDate;
  }

  // INITIALIZE TEXT EDITING CONTROLLERS
  void _initializeTextEditingController() {
    _searchC = TextEditingController();
  }

  // <---- PAGINATION ---->
  void _onScroll() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !_leaveCubit.state.isLoading! &&
          _leaveCubit.state.leaveList.length <
              _leaveCubit.state.totalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _leaveCubit.getLeaveList(context, _leaveCubit.state.currentPage + 1);
        });
      }
    });
  }

  // FETCH LEAVE TYPE
  Future<Map<String, dynamic>> _fetchLeaveType(
    int pageNumber, {
    String? value,
  }) async {
    final result = await _leaveTypeMasterRepository.getLeaveTypeList(
      pageNumber: pageNumber,
      pageSize: 15,
      queryParams:
          value != null && value.isNotEmpty ? {"DepartmentName": value} : {},
    );

    return result.fold(
      (failure) => {
        "itemList": <Map<String, dynamic>>[],
        "totalNumberOfRecord": 0,
      },
      (response) {
        final departments = response['data'] as List<LeaveTypeModel>;

        return {
          "itemList":
              departments.map((department) {
                return {
                  "zAttributesId": department.leaveTypeMasterId,
                  "DisplayName": department.leaveType,
                };
              }).toList(),
          "totalNumberOfRecord": response['totalNumberOfRecord'] ?? 0,
        };
      },
    );
  }

  // <---- DELETE LEAVE ---->
  Future<void> _showPopupToDeleteLeave(
    BuildContext context,
    LeaveModel obj,
    int currentPage,
    int index,
  ) async {
    var result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a leave?',
      'Deleting this leave will permanently remove its contents.',
    );
    if (result && context.mounted) {
      _leaveCubit.deleteLeave(
        context: context,
        leaveId: obj.leaveId,
        uniqueKey: obj.uniquekey,
        pageNumber: currentPage,
        index: index,
      );
    }
  }

  // LEAVE FILTER
  Future<void> _showBottomSheetToFilterLeave(BuildContext context) async {
    _prefillFilterFromState();
    final state = _leaveCubit.state;
    _selectedLeaveTypeNotifier.value = [
      {"DisplayName": state.filterLeaveType},
    ];
    final ValueNotifier<bool> applyEnabled = ValueNotifier<bool>(
      state.filterLeaveType != null ||
          state.filterStartDate != null ||
          state.filterEndDate != null,
    );
    DialogHelper.showCustomFilterBottomSheet(
      context,
      title: "Filter Leave",
      contentWidget: StatefulBuilder(
        builder: (context, innerState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              verticalSpacing(),
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
                            applyEnabled.value = true;
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
                                applyEnabled.value = true;
                              },
                              validator: (value) {
                                if (value == null) return null;
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
              ValueListenableBuilder<List<Map<String, dynamic>>>(
                valueListenable: _selectedLeaveTypeNotifier,
                builder: (context, leaveTy, child) {
                  return CustomMultipleSelectPopup(
                    title: "Leave Type",
                    isRequired: false,
                    isMultiSelect: false,
                    initialValue: leaveTy,
                    dataFetchCallBack: _fetchLeaveType,
                    onSelected: (value) {
                      _selectedLeaveTypeNotifier.value = value;
                      applyEnabled.value = true;
                    },
                    validator: (value) => null,
                  );
                },
              ),
            ],
          );
        },
      ),
      onClear: () {
        _selectedLeaveTypeNotifier.value = [];
        _startDateNotifier.value = null;
        _endDateNotifier.value = null;
        _leaveCubit.clearFilterOnLeave(context);
      },
      onApply: () {
        final leaveType =
            _selectedLeaveTypeNotifier.value.isNotEmpty
                ? (_selectedLeaveTypeNotifier.value[0]["DisplayName"]
                    as String?)
                : null;
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
        _leaveCubit.applyFilterOnLeave(
          context,
          leaveType: leaveType,
          startDate: startDate,
          endDate: endDate,
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
        screenTitle: "Leave",
        authorization: _routeAuthorizationModel,
        textController: _searchC,
        searchHintText: "Search by Leave Type",
        onSearchSubmit: (value) {
          _leaveCubit.searchOutdoor(context, value);
        },
        onExportCallback: (value) {
          _leaveCubit.exportExcelPdf(context, value);
        },
        isFilterOn: true,
        onFilterTap: () {
          _showBottomSheetToFilterLeave(context);
        },
        secondaryBuilder:
            (_) => CustomButton(
              text: "Apply",
              onPressed: () async {
                await goRouter.pushNamed(AppRoutes.applyLeave);
                if (context.mounted) {
                  _leaveCubit.getLeaveList(context, 1);
                }
              },
              backgroundColor: AppColor.primary,
              leading: Icon(Icons.add, size: 16, color: AppColor.white),
            ),
      ),
      body: BlocBuilder<LeaveCubit, LeaveState>(
        builder: (context, state) {
          if ((state.isLoading ?? true) && state.leaveList.isEmpty) {
            return Center(child: loader());
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusTabBar(),
              Expanded(
                child:
                    state.leaveList.isEmpty
                        ? Center(child: noDataWidget(message: "No Leave Found"))
                        : ListView.builder(
                          controller: scrollController,
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          itemCount: state.leaveList.length + 1,
                          itemBuilder: (context, index) {
                            if (index == state.leaveList.length) {
                              return state.leaveList.length <
                                      state.totalNumberOfRecord
                                  ? Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                  : const SizedBox.shrink();
                            }
                            var leave = state.leaveList[index];
                            return Container(
                              margin: EdgeInsets.only(bottom: 10),
                              padding: EdgeInsets.all(12),
                              decoration: commonCardDecoration(),
                              child: Column(
                                spacing: 5,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 6,
                                        child: GestureDetector(
                                          onTap: () {
                                            goRouter.pushNamed(
                                              AppRoutes.viewLeave,
                                              queryParameters: {
                                                "leave": Uri.encodeQueryComponent(
                                                  EncryptionManager.encryptData(
                                                    jsonEncode(leave.toJson()),
                                                  ),
                                                ),
                                              },
                                            );
                                          },
                                          child: Text(
                                            leave.leaveType,
                                            style: AppTextStyle.ts16M(
                                              color: AppColor.primary,
                                            ).copyWith(
                                              decoration:
                                                  TextDecoration.underline,
                                              decorationColor: AppColor.primary,
                                            ),
                                          ),
                                        ),
                                      ),

                                      Spacer(),
                                      _statusWidget(leave.leaveStatus),
                                      horizontalSpacing(),

                                      Row(
                                        spacing: 10,
                                        children: [
                                          CustomIconButton.edit(
                                            onPressed: () {
                                              /* your code */
                                            },
                                          ),
                                          CustomIconButton.delete(
                                            onPressed: () {
                                              /* your code */
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  buildRowTitleValue(
                                    title: "Start Date",
                                    value: formatDateTimeAsDDMMMYYYY(
                                      leave.startDate,
                                    ),
                                  ),
                                  buildRowTitleValue(
                                    title: "End Date",
                                    value: formatDateTimeAsDDMMMYYYY(
                                      leave.endDate,
                                    ),
                                  ),
                                  buildRowTitleValue(
                                    title: "No. Of Days",
                                    value: leave.noOfDays.toString(),
                                  ),
                                  buildRowTitleValue(
                                    title: "Reason",
                                    value: leave.reason,
                                  ),
                                ],
                              ),
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

  Widget _buildStatusTabBar() {
    return ChipStyleTabBar(
      controller: _tabController!,
      tabs: _statusTabs.map((t) => t).toList(),
    );
  }

  // STATUS WIDGET
  Widget _statusWidget(String status) {
    if (status.trim().isEmpty) {
      return SizedBox.shrink();
    }
    final statusConfig = _getStatusConfig(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: statusConfig.backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        statusConfig.label,
        style: AppTextStyle.ts12M().copyWith(color: statusConfig.textColor),
      ),
    );
  }

  // HELPER METHOD TO GET STATUS CONFIG
  StatusConfig _getStatusConfig(String status) {
    switch (status.toLowerCase()) {
      case "pending":
        return StatusConfig(
          label: "Pending",
          textColor: AppColor.white,
          backgroundColor: AppColor.darkBlue,
        );

      case "approved":
        return StatusConfig(
          label: "Approved",
          textColor: AppColor.white,
          backgroundColor: AppColor.green,
        );

      case "rejected":
        return StatusConfig(
          label: "Rejected",
          textColor: AppColor.white,
          backgroundColor: AppColor.error,
        );

      default:
        return StatusConfig(
          label: status,
          textColor: AppColor.grey,
          backgroundColor: AppColor.grey.withValues(alpha: 0.1),
        );
    }
  }
}

// HELPER CLASS TO STORE STATUS CONFIG
class StatusConfig {
  final String label;
  final Color textColor;
  final Color backgroundColor;

  const StatusConfig({
    required this.label,
    required this.textColor,
    required this.backgroundColor,
  });
}
