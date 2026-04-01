import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/sales/performance/presentation/cubit/performance_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/chip_style_tab_bar.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class PerformanceScreen extends StatefulWidget {
  const PerformanceScreen({super.key});

  @override
  State<PerformanceScreen> createState() => _PerformanceScreenState();
}

class _PerformanceScreenState extends State<PerformanceScreen>
    with TickerProviderStateMixin {
  // CUBIT
  late PerformanceCubit _performanceCubit;

  // PROJECT
  late ProjectModel _project;

  // AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;
  // TEXT EDITING CONTROLLERS
  late TextEditingController _searchC;
  // SCROLL CONTROLLERS
  late ScrollController _sourcingTargetScrollController;
  late ScrollController _closingTargetScrollController;

  // TAB CONTROLLERS
  late TabController _tabControllerFirst;
  late TabController _tabControllerSecond;

  @override
  void initState() {
    super.initState();

    _performanceCubit = context.read<PerformanceCubit>();
    _project = getProject();

    _tabControllerFirst = TabController(length: 3, vsync: this);
    _tabControllerSecond = TabController(length: 2, vsync: this);

    _tabControllerFirst.addListener(_handleTabChangeFirst);
    _tabControllerSecond.addListener(_handleTabChangeSecond);

    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.performanceReport]!;

    _initializeTextEditingController();

    _sourcingTargetScrollController = ScrollController();
    _closingTargetScrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _callPerformanceApi();
    });
  }

  @override
  void dispose() {
    _tabControllerFirst.dispose();
    _tabControllerSecond.dispose();
    _sourcingTargetScrollController.dispose();
    _closingTargetScrollController.dispose();
    super.dispose();
  }

  // INITIALIZE TEXT EDITING CONTROLLERS
  void _initializeTextEditingController() {
    _searchC = TextEditingController();
  }

  // HANDLE TAB CHANGE
  void _handleTabChangeFirst() {
    if (!_tabControllerFirst.indexIsChanging) {
      _searchC.clear();
      _performanceCubit.resetSearch();
      _callPerformanceApi();
    }
  }

  void _handleTabChangeSecond() {
    if (!_tabControllerSecond.indexIsChanging) {
      _searchC.clear();
      _performanceCubit.resetSearch();
      _callPerformanceApi();
    }
  }

  String _getTillDateType() {
    switch (_tabControllerFirst.index) {
      case 0:
        return "WTD";
      case 1:
        return "MTD";
      case 2:
        return "YTD";
      default:
        return "WTD";
    }
  }

  String _getReportType() {
    return _tabControllerSecond.index == 0 ? "Sourcing" : "Closing";
  }

  void _callPerformanceApi() {
    final tillDateType = _getTillDateType();
    final reportType = _getReportType();

    if (_tabControllerSecond.index == 0) {
      _performanceCubit.getPerformanceSourcingReportList(
        context: context,
        projectId: _project.projectId,
        pageNumber: 1,
        reportType: reportType,
        periodType: tillDateType,
      );
    } else {
      _performanceCubit.getPerformanceClosingReportList(
        context: context,
        projectId: _project.projectId,
        pageNumber: 1,
        reportType: reportType,
        periodType: tillDateType,
      );
    }
  }

  Future<void> _onRefresh() async {
    _searchC.clear();
    _performanceCubit.resetSearch();
    _callPerformanceApi();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColor.white,
        appBar: CustomAppBar(
          screenTitle: "Performance",
          authorization: _routeAuthorizationModel,
          textController: _searchC,
          searchHintText: "Search by Name",
          onSearchSubmit: (value) {
            _performanceCubit.searchPerformanceReport(
              context,
              _project.projectId,
              _tabControllerSecond.index,
              value,
              _getReportType(),
              _getTillDateType(),
            );
          },
          onProjectChangeCallback: (value) {
            _project = value;
          },
          onExportCallback: (value) {
            if(_project.projectId==0){
              showErrorMessage(context, "Error", "Please Select a Project");
              return;
            }
            if(_performanceCubit.state.sourcingTotalNumberOfRecordPerformanceReport==0 || _performanceCubit.state.closingTotalNumberOfRecordPerformanceReport==0){
              showErrorMessage(context, "Error", "Data Not Found");
              return;
            }
            _performanceCubit.exportExcelPdf(
              context,
              value,
              _getReportType(),
              _getTillDateType(),
              _project.projectId,
              _tabControllerSecond.index == 0
                  ? _performanceCubit
                      .state
                      .sourcingTotalNumberOfRecordPerformanceReport
                  : _performanceCubit
                      .state
                      .closingTotalNumberOfRecordPerformanceReport,
            );
          },
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ChipStyleTabBar(
              controller: _tabControllerFirst,
              tabs: ["WTD", "MTD", "YTD"],
            ),
            verticalSpacing(),
            ChipStyleTabBar(
              controller: _tabControllerSecond,
              tabs: ["Sourcing Target", "Closing Target"],
            ),
            verticalSpacing(),
            Expanded(
              child: TabBarView(
                physics: NeverScrollableScrollPhysics(),
                controller: _tabControllerSecond,
                children: [
                  _buildSourcingTargetView(),
                  _buildClosingTargetView(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // BUILD SOURCING TARGET VIEW
  Widget _buildSourcingTargetView() {
    return BlocBuilder<PerformanceCubit, PerformanceState>(
      builder: (context, state) {
        if (state.isLoading! && state.performanceReportSourcingModel.isEmpty) {
          return Center(child: loader());
        }

        return RefreshIndicator(
          onRefresh: _onRefresh,
          child:
              state.performanceReportSourcingModel.isEmpty
                  ? ListView(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.3,
                      ),
                      Center(
                        child: noDataWidget(
                          message: "No Performance Report Data Found",
                        ),
                      ),
                    ],
                  )
                  : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: state.performanceReportSourcingModel.length,
                    itemBuilder: (_, index) {
                      final sourcingTarget =
                          state.performanceReportSourcingModel[index];

                      return GestureDetector(
                        onTap: () {
                          goRouter.pushNamed(
                            AppRoutes.viewPerformanceReport,
                            queryParameters: {
                              "sourcing": Uri.encodeQueryComponent(
                                EncryptionManager.encryptData(
                                  jsonEncode(sourcingTarget.toJson()),
                                ),
                              ),
                            },
                          );
                        },
                        child: Container(
                          decoration: commonCardDecoration(),
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 16,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      sourcingTarget.employeeName,
                                      style: AppTextStyle.ts14M(
                                        color: AppColor.primary,
                                      ),
                                    ),
                                    Text(
                                      sourcingTarget.designationName,
                                      style: AppTextStyle.ts12M(
                                        color: AppColor.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 20,
                                color: AppColor.black,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
        );
      },
    );
  }

  // BUILD CLOSING TARGET VIEW
  Widget _buildClosingTargetView() {
    return BlocBuilder<PerformanceCubit, PerformanceState>(
      builder: (context, state) {
        if (state.isLoading! && state.performanceReportClosingModel.isEmpty) {
          return Center(child: loader());
        }

        return RefreshIndicator(
          onRefresh: _onRefresh,
          child:
              state.performanceReportClosingModel.isEmpty
                  ? ListView(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.3,
                      ),
                      Center(
                        child: noDataWidget(
                          message: "No Performance Report Data Found",
                        ),
                      ),
                    ],
                  )
                  : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: state.performanceReportClosingModel.length,
                    itemBuilder: (_, index) {
                      final closingTarget =
                          state.performanceReportClosingModel[index];

                      return GestureDetector(
                        onTap: () {
                          goRouter.pushNamed(
                            AppRoutes.viewPerformanceReport,
                            queryParameters: {
                              "closing": Uri.encodeQueryComponent(
                                EncryptionManager.encryptData(
                                  jsonEncode(closingTarget.toJson()),
                                ),
                              ),
                            },
                          );
                        },
                        child: Container(
                          decoration: commonCardDecoration(),
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 16,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      closingTarget.employeeName,
                                      style: AppTextStyle.ts14M(
                                        color: AppColor.primary,
                                      ),
                                    ),
                                    Text(
                                      closingTarget.designationName,
                                      style: AppTextStyle.ts12M(
                                        color: AppColor.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 20,
                                color: AppColor.black,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
        );
      },
    );
  }
}
