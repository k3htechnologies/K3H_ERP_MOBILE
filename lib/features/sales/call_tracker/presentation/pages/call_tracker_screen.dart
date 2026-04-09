import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/core/services/app_call_tracker_service.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/sales/call_tracker/data/model/call_log.model.dart';
import 'package:k3h_erp_app/features/sales/call_tracker/presentation/cubit/call_tracker_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
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
  late TextEditingController _searchC, _remarkC;
  final _formKey = GlobalKey<FormState>();
  late AppCallTrackerService _appCallTrackerService;

  late ScrollController scrollController;
  late ScrollController _scrollControllerCallLog;
  Timer? _debounce;
  Timer? _debounceCallLog;

  late ProjectModel _project;

  DateTime? selectedRescheduleDate;

  @override
  void initState() {
    super.initState();
    _routhAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.callTracker]!;
    _callTrackerCubit = context.read<CallTrackerCubit>();
    _appCallTrackerService = serviceLocator<AppCallTrackerService>();
    _project = getProject();
    _searchC = TextEditingController();
    _remarkC = TextEditingController();
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
    scrollController.dispose();
    _scrollControllerCallLog.dispose();
    _debounce?.cancel();
    _debounceCallLog?.cancel();
    super.dispose();
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

  Future<void> _showBottomSheetToUpdateCallLog(
    BuildContext context,
    CallLogModel obj,
    int projectId,
    int index,
  ) async {
    _remarkC.text = obj.remark;
    selectedRescheduleDate = obj.rescheduleDate;

    DialogHelper.showCustomBottomSheet(
      context,
      "Update Call Log",
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                isRequired: true,
                title: "Remark",
                hint: "Enter Remark",
                textController: _remarkC,
                minLines: 3,
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter remark";
                  }
                  return null;
                },
              ),
              CustomDatePicker(
                title: "Reschedule Date",
                initialDate: selectedRescheduleDate,
                setValue: (value) {
                  selectedRescheduleDate = value;
                },
              ),
              Spacer(),
              CustomButton(
                text: "Save",
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _callTrackerCubit.updateCallLog(
                      context: context,
                      callLogId: obj.callLogId,
                      projectId: projectId,
                      uniqueKey: obj.uniquekey,
                      remark: _remarkC.text,
                      rescheduleDate: selectedRescheduleDate,
                      index: index,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(110),
        child: BlocBuilder<CallTrackerCubit, CallTrackerState>(
          builder: (context, state) {
            return CustomAppBar(
              screenTitle: "Call Tracker",
              authorization: _routhAuthorizationModel,

              searchHintText: state.currentTabIndex == 0
                  ? "Search By Customer Name"
                  : "Search By Receiver Name",

              onSearchSubmit: (value) {
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

              textController: _searchC,

              onExportCallback: (value) {
                if(_project.projectId==0){
                  showErrorMessage(context, "Error", "Please Select a Project");
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

              onProjectChangeCallback: (value) async {
                _project = value;
                _searchC.clear();

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
          Align(
            alignment: Alignment.centerLeft,
            child: IntrinsicWidth(
              child: Container(
                height: 35,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColor.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColor.grey.withValues(alpha: 0.2),
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  labelColor: AppColor.primary,
                  unselectedLabelColor: AppColor.grey,
                  indicator: BoxDecoration(
                    color: AppColor.lightBlue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelStyle: AppTextStyle.ts14M(),
                  unselectedLabelStyle: AppTextStyle.ts14M(),
                  labelPadding: const EdgeInsets.symmetric(horizontal: 16),
                  padding: EdgeInsets.zero,
                  tabs: const [
                    Tab(text: 'Calling Data'),
                    Tab(text: 'Call Log'),
                  ],
                ),
              ),
            ),
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

  Widget _buildCallingData() {
    return BlocBuilder<CallTrackerCubit, CallTrackerState>(
      builder: (context, state) {
        if ((state.isLoading ?? true) && state.callingDataList.isEmpty) {
          return Center(child: loader());
        }

        return RefreshIndicator(
          onRefresh: _onRefresh,
          child:
              state.callingDataList.isEmpty
                  ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: Center(
                          child: noDataWidget(message: "No Calling Data Found"),
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
                              child: Center(child: CircularProgressIndicator()),
                            )
                            : const SizedBox.shrink();
                      }

                      var callingData = state.callingDataList[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: commonCardDecoration(),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                buildColumnTitleValue(
                                  title: "Customer Name",
                                  value: callingData.name,
                                ),
                                buildColumnTitleValue(
                                  title: "Location",
                                  value: callingData.address,
                                  customValueWidget:
                                      callingData.address.isNotEmpty
                                          ? Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColor.lightBlue,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(callingData.address),
                                          )
                                          : const Text("-"),
                                ),
                              ],
                            ),
                            verticalSpacing(),
                            Row(
                              children: [
                                buildColumnTitleValue(
                                  title: "Mobile No.",
                                  value: callingData.mobileNumber,
                                  customValueWidget: CustomClickToContactText(
                                    value: callingData.mobileNumber,
                                  ),
                                ),
                                buildColumnTitleValue(
                                  title: "E-Mail ID",
                                  value: callingData.emailId,
                                  customValueWidget: CustomClickToContactText(
                                    value: callingData.emailId,
                                    type: ContactType.email,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
        );
      },
    );
  }

  Widget _buildCallLog() {
    return BlocBuilder<CallTrackerCubit, CallTrackerState>(
      builder: (context, state) {
        if ((state.isLoading ?? true) && state.callLogList.isEmpty) {
          return Center(child: loader());
        }

        return  state.callLogList.isEmpty
            ? ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: Center(
                child: noDataWidget(message: "No Call Log Found"),
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
                    _callTrackerCubit.state.totalNumberOfRecordCallLog) {

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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemCount: state.callLogList.length + 1,
            itemBuilder: (context, index) {
              if (index == state.callLogList.length) {
                return state.callLogList.length <
                    state.totalNumberOfRecordCallLog
                    ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                )
                    : const SizedBox.shrink();
              }

              final callLog = state.callLogList[index];
              return CallLogExpandableCard(
                callLog: callLog,
                index: index,
                editCallBack: () {
                  _showBottomSheetToUpdateCallLog(
                    context,
                    callLog,
                    _project.projectId,
                    index,
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
                routhAuthorizationModel: _routhAuthorizationModel,
              );
            },
          ),
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
                      child: _expandedContent(callLog, widget.index,widget.routhAuthorizationModel),
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
      child: Row(
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
    );
  }

  Widget _expandedContent(CallLogModel callLog, int index,AuthorizationModel authorization) {
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
                title: "Call Date",
                value: formatDateTimeAsDDMMMYYYY(callLog.callDate),
              ),
              buildColumnTitleValue(title: "Duration", value: callLog.duration),
            ],
          ),
          Row(
            children: [
              buildColumnTitleValue(
                title: "Call Rescheduled Date",
                value:
                    callLog.rescheduleDate != null
                        ? formatDateTimeAsDDMMMYYYY(callLog.rescheduleDate!)
                        : "-",
              ),
            ],
          ),
          Row(
            children: [
              buildColumnTitleValue(title: "Remark", value: callLog.remark),
              if(authorization.isAction && callLog.remark.isEmpty)...[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 10,
                  children: [
                    CustomIconButton.edit(
                      onPressed: () {
                        widget.editCallBack();
                      },
                    ),
                    CustomIconButton.delete(
                      onPressed: () {
                        widget.deleteCallBack();
                      },
                    ),
                  ],
                ),
              ]
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
