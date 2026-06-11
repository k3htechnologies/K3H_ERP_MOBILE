import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/core/services/app_call_tracker_service.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/sales/call_tracker/data/model/call_log.model.dart';
import 'package:k3h_erp_app/features/sales/call_tracker/presentation/cubit/call_tracker_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_export_button.dart';
import 'package:k3h_erp_app/widgets/app_bar/search_widget.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/chip_style_tab_bar.dart';
import 'package:k3h_erp_app/widgets/custom_click_to_contact_widget.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class CallTrackerScreen extends StatefulWidget {
  const CallTrackerScreen({super.key});

  @override
  State<CallTrackerScreen> createState() => _CallTrackerScreenState();
}

class _CallTrackerScreenState extends State<CallTrackerScreen>
    with SingleTickerProviderStateMixin {
  late CallTrackerCubit _callTrackerCubit;
  late TabController _tabController;
  late AuthorizationModel _routhAuthorizationModel;
  late TextEditingController _searchC,
      _remarkC,
      _filterMobileNoC,
      _filterSourceC;
  late AppCallTrackerService _appCallTrackerService;

  late ScrollController scrollController;
  late ScrollController _scrollControllerCallLog;
  Timer? _debounce;
  Timer? _debounceCallLog;

  late ProjectModel _project;
  final ValueNotifier<DateTime?> _startDateNotifier = ValueNotifier<DateTime?>(
    null,
  );
  final ValueNotifier<DateTime?> _endDateNotifier = ValueNotifier<DateTime?>(
    null,
  );

  DateTime? selectedRescheduleDate;
  @override
  void initState() {
    super.initState();
    _routhAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.callTracker]!;
    _callTrackerCubit = context.read<CallTrackerCubit>();
    _appCallTrackerService = serviceLocator<AppCallTrackerService>();
    _project = getProject();
    _initializeTextEditingControllers();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
    _onScrollCallingData();
    _onScrollCallLog();
    _syncAndLoadCallingData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchC.dispose();
    _remarkC.dispose();
    _filterMobileNoC.dispose();
    _filterSourceC.dispose();
    scrollController.dispose();
    _scrollControllerCallLog.dispose();
    _debounce?.cancel();
    _debounceCallLog?.cancel();
    super.dispose();
  }

  void _initializeTextEditingControllers() {
    _searchC = TextEditingController();
    _remarkC = TextEditingController();
    _filterMobileNoC = TextEditingController();
    _filterSourceC = TextEditingController();
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      _searchC.clear();
      _callTrackerCubit.onTabChanged(_tabController.index, context);

      if (_tabController.index == 0) {
        _syncAndLoadCallingData();
      } else if (_tabController.index == 1) {
        _callTrackerCubit.getCallLogList(context, 1, _project.projectId);
      }
    }
  }

  Future<void> _onRefresh() async {
    if (_tabController.index == 0) {
      await _syncAndLoadCallingData();
    } else {
      await _callTrackerCubit.getCallLogList(context, 1, _project.projectId);
    }
    await Future.delayed(const Duration(milliseconds: 300));
  }

  void _onScrollCallingData() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (_tabController.index != 0) return;

      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !_callTrackerCubit.state.isLoading! &&
          _callTrackerCubit.state.callingDataList.length <
              _callTrackerCubit.state.totalNumberOfRecordCallingData) {
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _callTrackerCubit.getCallingDataList(
            context,
            _callTrackerCubit.state.currentPageCallingData + 1,
            _project.projectId,
          );
        });
      }
    });
  }

  void _onScrollCallLog() {
    _scrollControllerCallLog = ScrollController();
    _scrollControllerCallLog.addListener(() {
      if (_tabController.index != 1) return;

      if (_scrollControllerCallLog.position.pixels >=
              _scrollControllerCallLog.position.maxScrollExtent - 100 &&
          !_callTrackerCubit.state.isLoading! &&
          _callTrackerCubit.state.callLogList.length <
              _callTrackerCubit.state.totalNumberOfRecordCallLog) {
        if (_debounceCallLog?.isActive ?? false) _debounceCallLog?.cancel();
        _debounceCallLog = Timer(const Duration(milliseconds: 300), () {
          _callTrackerCubit.getCallLogList(
            context,
            _callTrackerCubit.state.currentPageCallLog + 1,
            _project.projectId,
          );
        });
      }
    });
  }

  Future<void> _showPopupToDeleteCallLog(
    BuildContext context,
    CallLogModel obj,
    int projectId,
    int index,
  ) async {
    var result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a call log?',
      'Deleting this call log will permanently remove its contents.',
    );
    if (result && context.mounted) {
      _callTrackerCubit.deleteCallLog(
        context: context,
        callLogId: obj.callLogId,
        uniqueKey: obj.uniquekey,
        projectId: projectId,
        index: index,
      );
    }
  }

  Future<void> _syncAndLoadCallingData() async {
    debugPrint("_syncAndLoadCallingData called");

    final isSynced = await _appCallTrackerService.syncTodayCallLogsToApi();
    debugPrint("syncTodayCallLogsToApi result => $isSynced");

    if (!mounted) return;

    await _callTrackerCubit.getCallingDataList(context, 1, _project.projectId);
  }

  Future<void> _showBottomSheetToFilter(BuildContext context) async {
    final state = _callTrackerCubit.state;

    _searchC.text = state.searchText;
    _filterMobileNoC.text = state.filterMobileNo;
    _startDateNotifier.value = state.filterRescheduleFromDate;
    _endDateNotifier.value = state.filterRescheduleToDate;
    _filterSourceC.text = state.filterSource ?? "";

    bool manualClose = false;

    final ValueNotifier<bool> applyEnabled = ValueNotifier<bool>(false);

    void updateApplyState(StateSetter innerState) {
      innerState(() {
        manualClose =
            _searchC.text.trim() != state.searchText ||
            _filterMobileNoC.text.trim() != state.filterMobileNo ||
            _startDateNotifier.value != state.filterRescheduleFromDate ||
            _endDateNotifier.value != state.filterRescheduleToDate ||
            _filterSourceC.text.trim() != state.filterSource;

        applyEnabled.value = manualClose;
      });
    }

    await DialogHelper.showCustomFilterBottomSheet(
      context,
      title:
          _tabController.index == 0 ? "Filter Calling Data" : "Filter Call Log",
      contentWidget: StatefulBuilder(
        builder: (context, innerState) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                verticalSpacing(),
                CustomTextField(
                  textController: _searchC,
                  title:
                      _tabController.index == 0
                          ? "Customer Name"
                          : "Receiver Name",
                  hint:
                      _tabController.index == 0
                          ? "Enter Customer Name"
                          : "Enter Receiver Name",
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
                CustomTextField(
                  textController: _filterMobileNoC,
                  title: "Mobile Number",
                  hint: "Enter Mobile Number",
                  keyboardType: TextInputType.phone,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),

                ValueListenableBuilder<DateTime?>(
                  valueListenable: _startDateNotifier,
                  builder: (context, startDate, child) {
                    return CustomDatePicker(
                      title:
                          _tabController.index == 0
                              ? "From Date"
                              : "Reschedule From Date",
                      initialDate: startDate,
                      setValue: (value) {
                        _startDateNotifier.value = value;

                        updateApplyState(innerState);
                      },
                      validator: (value) => null,
                    );
                  },
                ),

                ValueListenableBuilder<DateTime?>(
                  valueListenable: _endDateNotifier,
                  builder: (context, endDate, child) {
                    return ValueListenableBuilder<DateTime?>(
                      valueListenable: _startDateNotifier,
                      builder: (context, startDate, child) {
                        return CustomDatePicker(
                          title:
                              _tabController.index == 0
                                  ? "To Date"
                                  : "Reschedule To Date",
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
                                return 'To Date cannot be before From Date';
                              }
                            }

                            return null;
                          },
                        );
                      },
                    );
                  },
                ),
                CustomTextField(
                  textController: _filterSourceC,
                  title: "Source",
                  hint: "Enter Source",
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
              ],
            ),
          );
        },
      ),

      onClear: () {
        _filterMobileNoC.clear();

        _startDateNotifier.value = null;
        _endDateNotifier.value = null;
        _searchC.clear();
        _filterSourceC.clear();
        _callTrackerCubit.applyFilterAndSort(
          context: context,
          mobileNumber: '',
          rescheduleFromDate: null,
          rescheduleToDate: null,
          name: "",
          projectId: _project.projectId,
          source: "",
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
              "To Date cannot be before From Date",
            );

            return;
          }
        }

        _callTrackerCubit.applyFilterAndSort(
          context: context,
          name: _searchC.text.trim(),
          projectId: _project.projectId,
          mobileNumber: _filterMobileNoC.text.trim(),
          rescheduleFromDate: startDate,
          rescheduleToDate: endDate,
          source: _tabController.index == 0 ? _filterSourceC.text.trim() : null,
        );
      },

      isApplyEnabled: applyEnabled.value,
      applyEnabledNotifier: applyEnabled,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(110),
        child: BlocBuilder<CallTrackerCubit, CallTrackerState>(
          builder: (context, state) {
            return CustomAppBarWithBackButton(
              screenTitle: "Call Tracker",
              authorization: _routhAuthorizationModel,
              isMenuButton: true,
              onProjectChangeCallback: (value) async {
                _project = value;
                _searchC.clear();
                _callTrackerCubit.resetState();
                if (state.currentTabIndex == 0) {
                  await _syncAndLoadCallingData();
                } else {
                  await _callTrackerCubit.getCallLogList(
                    context,
                    1,
                    value.projectId,
                  );
                }
              },
            );
          },
        ),
      ),
      body: Column(
        children: [
          ChipStyleTabBar(
            controller: _tabController,
            tabs: ['Calling Data', 'Call Log'],
          ),
          Expanded(
            child: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              controller: _tabController,
              children: [_buildCallingData(), _buildCallLog()],
            ),
          ),
        ],
      ),
    );
  }

  Widget searchWidget() {
    return BlocBuilder<CallTrackerCubit, CallTrackerState>(
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          child: Row(
            spacing: 10,
            children: [
              Expanded(
                child: SearchWidget(
                  textController: _searchC,
                  hintText:
                      state.currentTabIndex == 0
                          ? "Search By Customer Name"
                          : "Search By Receiver Name",
                  isFilterOn: true,
                  onFilterTap: () {
                    _showBottomSheetToFilter(context);
                  },

                  onSubmit: (value) {
                    if (state.currentTabIndex == 0) {
                      _callTrackerCubit.searchCallingData(
                        context,
                        value,
                        _project.projectId,
                      );
                    } else {
                      _callTrackerCubit.searchCallingLog(
                        context,
                        value,
                        _project.projectId,
                      );
                    }
                  },
                ),
              ),
              if (_routhAuthorizationModel.isExport)
                CustomExportButton(
                  onExport: (value) {
                    if (_project.projectId == 0) {
                      showErrorMessage(
                        context,
                        "Error",
                        "Please Select a Project",
                      );
                      return;
                    }
                    if (state.currentTabIndex == 0) {
                      if (state.totalNumberOfRecordCallingData == 0) {
                        showErrorMessage(context, "Error", "Data Not Found");
                        return;
                      }
                      _callTrackerCubit.exportCallingDataExcelPdf(
                        context,
                        value,
                        _project.projectId,
                      );
                    } else {
                      if (state.totalNumberOfRecordCallLog == 0) {
                        showErrorMessage(context, "Error", "Data Not Found");
                        return;
                      }
                      _callTrackerCubit.exportCallLogExcelPdf(
                        context,
                        value,
                        _project.projectId,
                      );
                    }
                  },
                ),
              if (_routhAuthorizationModel.isAction &&
                  state.currentTabIndex == 0)
                CustomIconButton(
                  icon: Icon(Icons.add, color: AppColor.primary, size: 16),
                  backgroundColor: AppColor.lightBlue,
                  onPressed: () {
                    if (_project.projectId == 0) {
                      showErrorMessage(
                        context,
                        "Error",
                        "Please Select a Project",
                      );
                      return;
                    }
                    goRouter.pushNamed(AppRoutes.addCallingData);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCallingData() {
    return BlocBuilder<CallTrackerCubit, CallTrackerState>(
      builder: (context, state) {
        return Column(
          children: [
            searchWidget(),
            if ((state.isLoading ?? true) && state.callingDataList.isEmpty) ...[
              Expanded(child: Center(child: CircularProgressIndicator())),
            ] else ...[
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _onRefresh,
                  child:
                      state.callingDataList.isEmpty
                          ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.6,
                                child: Center(
                                  child: noDataWidget(
                                    message: "No Calling Data Found",
                                  ),
                                ),
                              ),
                            ],
                          )
                          : ListView.builder(
                            controller: scrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            itemCount: state.callingDataList.length + 1,
                            itemBuilder: (context, index) {
                              if (index == state.callingDataList.length) {
                                return state.callingDataList.length <
                                        state.totalNumberOfRecordCallingData
                                    ? const Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    )
                                    : const SizedBox.shrink();
                              }

                              var callingData = state.callingDataList[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(12),
                                decoration: commonCardDecoration(),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: 10.h,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            callingData.name,
                                            style: AppTextStyle.ts14M(
                                              color: AppColor.primary,
                                            ),
                                          ),
                                        ),
                                        CustomIconButton.edit(
                                          isDisabled:
                                              // DISABLE EDIT WHEN USER HAD NO ACCESS OF ACTION OR NO OF TIME CALLING IS NON-ZERO
                                              (!_routhAuthorizationModel
                                                      .isAction ||
                                                  callingData.noOfTimeCalling !=
                                                      0),
                                          onPressed: () {
                                            goRouter.pushNamed(
                                              AppRoutes.addCallingData,
                                              queryParameters: {
                                                "callingData":
                                                    Uri.encodeQueryComponent(
                                                      EncryptionManager.encryptData(
                                                        jsonEncode(
                                                          callingData.toJson(),
                                                        ),
                                                      ),
                                                    ),
                                                "index": index.toString(),
                                              },
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        buildColumnTitleValue(
                                          title: "Mobile No.",
                                          value: callingData.mobileNumber,
                                          customValueWidget:
                                              CustomClickToContactText(
                                                value: callingData.mobileNumber,
                                              ),
                                        ),
                                        buildColumnTitleValue(
                                          title: "E-Mail ID",
                                          value: callingData.emailId,
                                          customValueWidget:
                                              CustomClickToContactText(
                                                value: callingData.emailId,
                                                type: ContactType.email,
                                              ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        buildColumnTitleValue(
                                          title: "Designation",
                                          value: callingData.designation,
                                        ),
                                        buildColumnTitleValue(
                                          title: "Last Modified Date",
                                          value:
                                              callingData.modifiedDate != null
                                                  ? formatDate(
                                                    callingData.modifiedDate!,
                                                  )
                                                  : "-",
                                        ),
                                      ],
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        buildColumnTitleValue(
                                          title: "Source ",
                                          value: callingData.source,
                                        ),
                                        buildColumnTitleValue(
                                          title: "No. of Time Calling",
                                          value:
                                              callingData.noOfTimeCalling
                                                  .toString(),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        buildColumnTitleValue(
                                          title: "Address",
                                          value: callingData.address,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildCallLog() {
    return BlocBuilder<CallTrackerCubit, CallTrackerState>(
      builder: (context, state) {
        return Column(
          children: [
            searchWidget(),
            if ((state.isLoading ?? true) && state.callLogList.isEmpty) ...[
              Expanded(child: Center(child: CircularProgressIndicator())),
            ] else
              Expanded(
                child:
                    state.callLogList.isEmpty
                        ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.6,
                              child: Center(
                                child: noDataWidget(
                                  message: "No Call Log Found",
                                ),
                              ),
                            ),
                          ],
                        )
                        : NotificationListener<ScrollNotification>(
                          onNotification: (scrollInfo) {
                            if (scrollInfo.metrics.pixels >=
                                    scrollInfo.metrics.maxScrollExtent - 100 &&
                                !_callTrackerCubit.state.isLoading! &&
                                _callTrackerCubit.state.callLogList.length <
                                    _callTrackerCubit
                                        .state
                                        .totalNumberOfRecordCallLog) {
                              _callTrackerCubit.getCallLogList(
                                context,
                                _callTrackerCubit.state.currentPageCallLog + 1,
                                _project.projectId,
                              );
                            }
                            return false;
                          },
                          child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            itemCount: state.callLogList.length + 1,
                            itemBuilder: (context, index) {
                              if (index == state.callLogList.length) {
                                return state.callLogList.length <
                                        state.totalNumberOfRecordCallLog
                                    ? const Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    )
                                    : const SizedBox.shrink();
                              }

                              final callLog = state.callLogList[index];
                              return CallLogExpandableCard(
                                callLog: callLog,
                                index: index,
                                editCallBack: () {
                                  goRouter.pushNamed(
                                    AppRoutes.updateCallTracker,
                                    queryParameters: {
                                      "callLog": Uri.encodeQueryComponent(
                                        EncryptionManager.encryptData(
                                          jsonEncode(callLog.toJson()),
                                        ),
                                      ),
                                      "index": index.toString(),
                                    },
                                  );
                                },
                                deleteCallBack: () {
                                  _showPopupToDeleteCallLog(
                                    context,
                                    callLog,
                                    _project.projectId,
                                    index,
                                  );
                                },
                                routhAuthorizationModel:
                                    _routhAuthorizationModel,
                              );
                            },
                          ),
                        ),
              ),
          ],
        );
      },
    );
  }
}

class CallLogExpandableCard extends StatefulWidget {
  final AuthorizationModel routhAuthorizationModel;
  final Function deleteCallBack;
  final Function editCallBack;
  final CallLogModel callLog;
  final int index;

  const CallLogExpandableCard({
    super.key,
    required this.routhAuthorizationModel,
    required this.callLog,
    required this.index,
    required this.deleteCallBack,
    required this.editCallBack,
  });

  @override
  State<CallLogExpandableCard> createState() => _CallLogExpandableCardState();
}

class _CallLogExpandableCardState extends State<CallLogExpandableCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final callLog = widget.callLog;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: commonCardDecoration(),
      child: Column(
        children: [
          _header(callLog),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child:
                isExpanded
                    ? AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: 1,
                      child: _expandedContent(
                        callLog,
                        widget.index,
                        widget.routhAuthorizationModel,
                      ),
                    )
                    : const SizedBox(),
          ),
        ],
      ),
    );
  }

  Widget _header(CallLogModel callLog) {
    return InkWell(
      onTap: () => setState(() => isExpanded = !isExpanded),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(callLog.receiverName, style: AppTextStyle.ts14SB()),
              ),
              _statusChip("Outgoing"),
              horizontalSpacing(width: 6),
              AnimatedRotation(
                turns: isExpanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 300),
                child: const Icon(Icons.keyboard_arrow_down),
              ),
            ],
          ),
          Row(
            children: [
              buildColumnTitleValue(
                title: "Rescheduled Date",
                value:
                    callLog.rescheduleDate != null
                        ? formatDateTimeAsDDMMMYYYY(callLog.rescheduleDate!)
                        : "-",
              ),

              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 10,
                children: [
                  CustomIconButton.edit(
                    isDisabled:
                        !(widget.routhAuthorizationModel.isAction &&
                            callLog.isEditable),
                    onPressed: () {
                      widget.editCallBack();
                    },
                  ),
                  CustomIconButton.delete(
                    isDisabled:
                        !(widget.routhAuthorizationModel.isAction &&
                            callLog.isEditable),
                    onPressed: () {
                      widget.deleteCallBack();
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _expandedContent(
    CallLogModel callLog,
    int index,
    AuthorizationModel authorization,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        spacing: 10,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildColumnTitleValue(
                title: "Sales Executive Name",
                value: callLog.callerName,
              ),
              buildColumnTitleValue(
                title: "Customer’s Phone No.",
                value: callLog.mobileNumber,
              ),
            ],
          ),
          Row(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildColumnTitleValue(
                title: "Call DateTime",
                value: formatDate(callLog.callDate),
              ),
              buildColumnTitleValue(title: "Duration", value: callLog.duration),
            ],
          ),
          Row(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildColumnTitleValue(
                title: "Location",
                value: callLog.villageName,
              ),
              buildColumnTitleValue(
                title: "Budget (In CR)",
                value: callLog.budget,
              ),
            ],
          ),
          Row(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildColumnTitleValue(
                title: "Requirement",
                value: callLog.requirement,
              ),
              buildColumnTitleValue(
                title: "Requirement Type",
                value: callLog.requirementType,
              ),
            ],
          ),
          Row(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildColumnTitleValue(
                title: "Site Visit Proposed Date",
                value:
                    callLog.siteVisitProposedDate != null
                        ? formatDateTimeAsDDMMMYYYY(
                          callLog.siteVisitProposedDate!,
                        )
                        : "-",
              ),
              buildColumnTitleValue(
                title: "Status",
                value: callLog.status,
                customValueWidget: callLogStatusWidget(callLog.status),
              ),
            ],
          ),
          Row(
            children: [
              buildColumnTitleValue(title: "Remark", value: callLog.remark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String? type) {
    late Color bg;
    late Color text;
    late IconData icon;
    late String label;

    switch (type) {
      case "Outgoing":
        bg = Colors.green.shade50;
        text = Colors.green;
        icon = Icons.call_made;
        label = "Outgoing";
        break;
      case "Incoming":
        bg = Colors.blue.shade50;
        text = Colors.blue;
        icon = Icons.call_received;
        label = "Incoming";
        break;
      default:
        bg = Colors.red.shade50;
        text = Colors.red;
        icon = Icons.call_missed;
        label = "Missed";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: text),
          const SizedBox(width: 4),
          Text(label, style: AppTextStyle.ts12SB(color: text)),
        ],
      ),
    );
  }
}
