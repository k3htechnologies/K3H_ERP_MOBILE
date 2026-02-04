import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/sales/call_tracker/presentation/cubit/call_tracker_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/custom_click_to_contact_widget.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
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
  late TextEditingController _searchC;

  // PAGINATION
  late ScrollController scrollController;
  late ScrollController _scrollControllerCallLog;
  Timer? _debounce;
  Timer? _debounceCallLog;

  // PROJECT
  late ProjectModel _project;

  @override
  void initState() {
    super.initState();
    _routhAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.callTracker]!;
    _callTrackerCubit = context.read<CallTrackerCubit>();
    _project = getProject();
    _searchC = TextEditingController();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
    _onScroll();
    _onScrollCallLog();
    _callTrackerCubit.getCallingDataList(context, 1, _project.projectId);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchC.dispose();
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
        _callTrackerCubit.getCallingDataList(context, 1, _project.projectId);
      } else if (_tabController.index == 1) {
        _callTrackerCubit.getCallLogList(context, 1, _project.projectId);
      }
    }
  }

  // <---- PAGINATION ---->
  void _onScroll() {
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
        },
        textController: _searchC,
        searchHintText: "Search By Customer Name",
        onExportCallback: (value) {},
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

  // OVERVIEW
  Widget _buildCallingData() {
    return BlocBuilder<CallTrackerCubit, CallTrackerState>(
      builder: (context, state) {
        if ((state.isLoading ?? true) && state.callingDataList.isEmpty) {
          return Center(child: loader());
        }
        if (state.callingDataList.isEmpty) {
          return Center(child: noDataWidget());
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
                        customValueWidget: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColor.lightBlue,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(callingData.address),
                        ),
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

  // CALL LOG
  Widget _buildCallLog() {
    return BlocBuilder<CallTrackerCubit, CallTrackerState>(
      builder: (context, state) {
        if ((state.isLoading ?? true) && state.callLogList.isEmpty) {
          return Center(child: loader());
        }
        if (state.callLogList.isEmpty) {
          return Center(child: noDataWidget());
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
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: commonCardDecoration(),
              child: Text("hahahaaha"),
            );
          },
        );
      },
    );
  }
}
