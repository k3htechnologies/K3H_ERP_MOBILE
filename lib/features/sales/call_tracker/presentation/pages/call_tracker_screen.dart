import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
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
  // CUBIT
  late CallTrackerCubit _callTrackerCubit;

  // TAB CONTROLLER
  late TabController _tabController;

  // AUTHORIZATION MODEL
  late AuthorizationModel _routhAuthorizationModel;

  // TEXT EDITING CONTROLLER
  late TextEditingController _searchC, _remarkC;

  // FORM KEY
  final _formKey = GlobalKey<FormState>();

  // PAGINATION
  late ScrollController scrollController;
  late ScrollController _scrollControllerCallLog;
  Timer? _debounce;
  Timer? _debounceCallLog;

  // PROJECT
  late ProjectModel _project;

  // RESCHEDULE DATE SELECT
  DateTime? selectedRescheduleDate;

  @override
  void initState() {
    super.initState();
    _routhAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.callTracker]!;
    _callTrackerCubit = context.read<CallTrackerCubit>();
    _project = getProject();
    _searchC = TextEditingController();
    _remarkC = TextEditingController();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
    _onScrollCallingData();
    _onScrollCallLog();
    _callTrackerCubit.getCallingDataList(context, 1, _project.projectId);
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

  // HANDLE TAB CHANGE
  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      _searchC.clear();
      _callTrackerCubit.onTabChanged(_tabController.index, context);
      if (_tabController.index == 0) {
        _callTrackerCubit.getCallingDataList(context, 1, _project.projectId);
      } else if (_tabController.index == 1) {
        _callTrackerCubit.getCallLogList(context, 1, _project.projectId);
      }
    }
  }

  // <---- PAGINATION ---->
  void _onScrollCallingData() {
    scrollController = ScrollController();
    scrollController.addListener(() {
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

  // <---- PAGINATION ---->
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

  // <---- UPDATE CALL LOG ---->
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
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomDatePicker(
                isRequired: true,
                title: "Reschedule Date",
                initialDate: selectedRescheduleDate,
                setValue: (value) {
                  selectedRescheduleDate = value;
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a date';
                  }
                  return null;
                },
              ),
              verticalSpacing(),
              CustomTextField(
                isRequired: true,
                title: "Remark",
                hint: "Enter Remark",
                textController: _remarkC,
                minLines: 3,
                maxLines: 3,
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
                      rescheduleDate: selectedRescheduleDate!,
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

  // <---- DELETE CALL LOG ---->
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        screenTitle: "Call Tracker",
        authorization: _routhAuthorizationModel,
        onSearchSubmit: (value) {
          if (_callTrackerCubit.state.currentTabIndex == 0) {
            _callTrackerCubit.searchCallingData(
              context,
              value,
              _project.projectId,
            );
          }
          if (_callTrackerCubit.state.currentTabIndex == 1) {
            _callTrackerCubit.searchCallingLog(
              context,
              value,
              _project.projectId,
            );
          }
        },
        textController: _searchC,
        searchHintText: "Search By Customer Name",
        onExportCallback: (value) {
          if (_callTrackerCubit.state.currentTabIndex == 0) {
            if (_callTrackerCubit.state.totalNumberOfRecordCallingData==0) {
              showErrorMessage(context, "Error", "Data Not Found");
              return;
            }
            _callTrackerCubit.exportCallingDataExcelPdf(
              context,
              value,
              _project.projectId,
            );
          }
          if (_callTrackerCubit.state.currentTabIndex == 1) {
            if (_callTrackerCubit.state.totalNumberOfRecordCallLog==0) {
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
        onProjectChangeCallback: (value){
          _project = value;
          if (_tabController.index == 0) {
            _callTrackerCubit.searchCallingData(context, "", value.projectId);
          } else if (_tabController.index == 1) {
            _callTrackerCubit.searchCallingLog(context, "", value.projectId);
          }
        },
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
              physics: NeverScrollableScrollPhysics(),
              controller: _tabController,
              children: [_buildCallingData(), _buildCallLog()],
            ),
          ),
        ],
      ),
    );
  }

  // CALLING DATA SECTION
  Widget _buildCallingData() {
    return BlocBuilder<CallTrackerCubit, CallTrackerState>(
      builder: (context, state) {
        if ((state.isLoading ?? true) && state.callingDataList.isEmpty) {
          return Center(child: loader());
        }
        if (state.callingDataList.isEmpty) {
          return Center(child: noDataWidget(message: "No Calling Data Found"));
        }
        return ListView.builder(
          controller: scrollController,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          itemCount: _callTrackerCubit.state.callingDataList.length + 1,
          itemBuilder: (context, index) {
            if (index == state.callingDataList.length) {
              return state.callingDataList.length <
                      state.totalNumberOfRecordCallingData
                  ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                  : const SizedBox.shrink();
            }
            var callingData = state.callingDataList[index];
            return Container(
              margin: EdgeInsets.only(bottom: 10),
              padding: EdgeInsets.all(12),
              decoration: commonCardDecoration(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      buildColumnTitleValue(
                        title: "Receiver’s Name",
                        value: callingData.name,
                      ),
                      buildColumnTitleValue(
                        title: "Location",
                        value: callingData.address,
                        customValueWidget:callingData.address.isNotEmpty? Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColor.lightBlue,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(callingData.address),
                        ):Text("-"),
                      ),
                    ],
                  ),
                  verticalSpacing(),
                  Row(
                    children: [
                      buildColumnTitleValue(
                        title: "Phone No.",
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
        );
      },
    );
  }

  // CALL LOG SECTION
  Widget _buildCallLog() {
    return BlocBuilder<CallTrackerCubit, CallTrackerState>(
      builder: (context, state) {
        if ((state.isLoading ?? true) && state.callLogList.isEmpty) {
          return Center(child: loader());
        }
        if (state.callLogList.isEmpty) {
          return Center(child: noDataWidget(message: "No Call Log Found"));
        }
        return ListView.builder(
          controller: _scrollControllerCallLog,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          itemCount: state.callLogList.length + 1,
          itemBuilder: (context, index) {
            if (index == state.callLogList.length) {
              return state.callLogList.length < state.totalNumberOfRecordCallLog
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
            );
          },
        );
      },
    );
  }
}

// EXPANDABLE CARD
class CallLogExpandableCard extends StatefulWidget {
  final Function deleteCallBack;
  final Function editCallBack;
  final CallLogModel callLog;
  final int index;

  const CallLogExpandableCard({
    super.key,
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
                      child: _expandedContent(callLog, widget.index),
                    )
                    : const SizedBox(),
          ),
        ],
      ),
    );
  }

  // HEADER
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

  // EXPANDED CONTENT
  Widget _expandedContent(CallLogModel callLog, int index) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        spacing: 10,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
            ],
          ),
        ],
      ),
    );
  }

  // STATUS CHIP
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
