import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/sales/target/data/repository/target.repository.dart';
import 'package:k3h_erp_app/features/sales/target/presentation/cubit/target_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/chip_style_tab_bar.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/custom_month_year_picker.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class TargetScreen extends StatefulWidget {
  const TargetScreen({super.key});

  @override
  State<TargetScreen> createState() => _TargetScreenState();
}

class _TargetScreenState extends State<TargetScreen>
    with SingleTickerProviderStateMixin {
  // CUBIT
  late TargetCubit _targetCubit;

  // PROJECT
  late ProjectModel _project;

  // AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;

  // SCROLL CONTROLLERS
  late ScrollController _sourcingTargetScrollController;
  late ScrollController _closingTargetScrollController;

  // TEXT EDITING CONTROLLERS
  late TextEditingController _searchC;

  // TAB CONTROLLER
  late TabController _tabController;

  // FILTER
  final ValueNotifier<DateTime?> _startDateNotifier = ValueNotifier<DateTime?>(
    null,
  );
  final ValueNotifier<DateTime?> _endDateNotifier = ValueNotifier<DateTime?>(
    null,
  );

  // MONTH SELECTION
  final ValueNotifier<DateTime?> _monthNotifier = ValueNotifier<DateTime?>(
    null,
  );

  // DEBOUNCE TIMER
  Timer? _sourcingTargetDebounce;
  Timer? _closingTargetDebounce;

  int _lastHandledTabIndex = 0;
  bool _isHandlingTabChange = false;
  bool ignoreSearch = false;

  @override
  void initState() {
    super.initState();
    _targetCubit = context.read<TargetCubit>();
    _project = getProject();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.salesTarget]!;
    _initializeTextEditingController();
    // INITIALIZE SCROLL CONTROLLERS
    _sourcingTargetScrollController = ScrollController();
    _closingTargetScrollController = ScrollController();

    // ADD SCROLL LISTENER
    _sourcingTargetScrollController.addListener(_onSourcingTargetScroll);
    _closingTargetScrollController.addListener(_onClosingTargetScroll);
    _targetCubit.getSalesTargetSourcingList(
      context: context,
      projectId: _project.projectId,
      pageNumber: 1,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _sourcingTargetScrollController.dispose();
    _closingTargetScrollController.dispose();
    _monthNotifier.dispose();
    super.dispose();
  }

  // INITIALIZE TEXT EDITING CONTROLLERS
  void _initializeTextEditingController() {
    _searchC = TextEditingController();
  }

  // HANDLE TAB CHANGE
  void _handleTabChange() {
    if (_tabController.indexIsChanging) return;
    if (_isHandlingTabChange) return;
    final index = _tabController.index;
    if (index == _lastHandledTabIndex) return;
    ignoreSearch = true;
    _isHandlingTabChange = true;
    _lastHandledTabIndex = index;
    // _monthNotifier.value = null;

    _searchC.text = "";
    _startDateNotifier.value = null;
    _endDateNotifier.value = null;

    _targetCubit.onTabChanged(index, context);
    // _monthNotifier.value = null;
    _callMonthFilterAPI();
    Future.delayed(const Duration(milliseconds: 300), () {
      ignoreSearch = false;
    });
    _isHandlingTabChange = false;
  }

  // PAGINATION - SOURCING TARGET
  void _onSourcingTargetScroll() {
    if (_tabController.index != 0) return;

    if (_sourcingTargetScrollController.position.pixels >=
            _sourcingTargetScrollController.position.maxScrollExtent - 100 &&
        !_targetCubit.state.isSourcingLoading &&
        _targetCubit.state.salesTargetSourcing.length <
            _targetCubit.state.sourcingTotalNumberOfRecordSalesTarget) {
      if (_sourcingTargetDebounce?.isActive ?? false) {
        _sourcingTargetDebounce?.cancel();
      }

      _sourcingTargetDebounce = Timer(const Duration(milliseconds: 300), () {
        _targetCubit.getSalesTargetSourcingList(
          context: context,
          pageNumber: _targetCubit.state.sourcingPage + 1,
          projectId: getProject().projectId,
        );
      });
    }
  }

  // PAGINATION - CLOSING TARGET
  void _onClosingTargetScroll() {
    if (_tabController.index != 1) return;

    if (_closingTargetScrollController.position.pixels >=
            _closingTargetScrollController.position.maxScrollExtent - 100 &&
        !_targetCubit.state.isClosingLoading &&
        _targetCubit.state.salesTargetClosing.length <
            _targetCubit.state.closingTotalNumberOfRecordSalesTarget) {
      if (_closingTargetDebounce?.isActive ?? false) {
        _closingTargetDebounce?.cancel();
      }

      _closingTargetDebounce = Timer(const Duration(milliseconds: 300), () {
        _targetCubit.getSalesTargetClosingList(
          context: context,
          pageNumber: _targetCubit.state.closingPage + 1,
          projectId: getProject().projectId,
        );
      });
    }
  }

  void _callMonthFilterAPI() {
    final formatted = _getFormattedMonth();

    _targetCubit.setMonthFilter(formatted);

    if (_tabController.index == 0) {
      _targetCubit.getSalesTargetSourcingList(
        context: context,
        pageNumber: 1,
        projectId: getProject().projectId,
      );
    } else {
      _targetCubit.getSalesTargetClosingList(
        context: context,
        pageNumber: 1,
        projectId: getProject().projectId,
      );
    }
  }

  String? _getFormattedMonth() {
    final m = _monthNotifier.value;
    if (m == null) return null;
    return "${m.month.toString().padLeft(2, '0')}-${m.year}";
  }

  // <---- IMPORT SALES TARGET SAMPLE FILE FOR WEB ---->
  Future<bool> salesTargetSampleExcelImportSourcing(
    BuildContext context,
  ) async {
    final TargetRepository targetRepository =
        serviceLocator<TargetRepository>();
    final ProjectModel project = getProject();
    try {
      final formatedMonth = _getFormattedMonth();
      DialogHelper.showProcessingOverlay(context);
      var result = await targetRepository.exportTargetSourcing(
        pageNumber: 1,
        pageSize: 1000000,
        projectId: project.projectId,
        queryParams: {
          "MonthYear": formatedMonth,
          "ExportType": "Excel",
          "IsSampleDownload": "true",
          "IsCheckPermission": "true",
        },
      );
      goRouter.pop();
      return result.fold(
        (failure) {
          showErrorMessage(context, "Import Error", failure.message);
          return false;
        },
        (response) {
          exportExcelOrPdfMobile(
            response["data"],
            "SALES SOURCING TARGET ${DateTime.now()}.xlsx",
          );
          showSuccessMessage(
            context,
            subTitle: "Excel downloaded successfully",
          );
          return true;
        },
      );
    } catch (e) {
      return false;
    }
  }

  Future<bool> salesTargetSampleExcelImportClosing(BuildContext context) async {
    final TargetRepository targetRepository =
        serviceLocator<TargetRepository>();
    final ProjectModel project = getProject();
    try {
      final formatedMonth = _getFormattedMonth();
      DialogHelper.showProcessingOverlay(context);
      var result = await targetRepository.exportTargetClosing(
        pageNumber: 1,
        pageSize: 1000000,
        projectId: project.projectId,
        queryParams: {
          "MonthYear": formatedMonth,
          "ExportType": "Excel",
          "IsSampleDownload": "true",
          "IsCheckPermission": "true",
        },
      );
      goRouter.pop();
      return result.fold(
        (failure) {
          showErrorMessage(context, "Import Error", failure.message);
          return false;
        },
        (response) {
          exportExcelOrPdfMobile(
            response["data"],
            "SALES CLOSING ${DateTime.now()}.xlsx",
          );
          showSuccessMessage(
            context,
            subTitle: "Excel downloaded successfully",
          );
          return true;
        },
      );
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TargetCubit, TargetState>(
      builder: (context, state) {
        return Scaffold(
          appBar: CustomAppBar(
            screenTitle: "Sales Target",
            authorization: _routeAuthorizationModel,
            textController: _searchC,
            searchHintText: "Search by Employee Name",
            projectId: _project.projectId,
            onSearchSubmit: (value) {
              _targetCubit.searchSalesTarget(
                context,
                getProject().projectId,
                _tabController.index,
                value,
              );
            },
            onProjectChangeCallback: (value) {
              _project = value;
              _monthNotifier.value = null;

              _searchC.clear();

              _startDateNotifier.value = null;
              _endDateNotifier.value = null;

              if (_tabController.index == 0) {
                _targetCubit.getSalesTargetSourcingList(
                  context: context,
                  projectId: getProject().projectId,
                  pageNumber: 1,
                );
              } else {
                _targetCubit.getSalesTargetClosingList(
                  context: context,
                  projectId: getProject().projectId,
                  pageNumber: 1,
                );
              }
              setState(() {});
            },
            importTableName:
                _tabController.index == 0
                    ? "SALES TARGET SOURCING"
                    : "SALES TARGET CLOSING",
            exportMonthYear: _getFormattedMonth(),
            onImportResult: (action) {
              if (action == "success") {
                if (_tabController.index == 0) {
                  _targetCubit.getSalesTargetSourcingList(
                    context: context,
                    projectId: getProject().projectId,
                    pageNumber: 1,
                  );
                  _tabController.animateTo(0);
                } else {
                  _targetCubit.getSalesTargetClosingList(
                    context: context,
                    projectId: getProject().projectId,
                    pageNumber: 1,
                  );
                  _tabController.animateTo(1);
                }
              } else if (action == "download") {
                if (_tabController.index == 0) {
                  salesTargetSampleExcelImportSourcing(context);
                } else {
                  salesTargetSampleExcelImportClosing(context);
                }
              }
            },
            onExportCallback: (value) {
              if (_tabController.index == 0) {
                salesTargetSampleExcelImportSourcing(context);
              } else {
                salesTargetSampleExcelImportClosing(context);
              }
            },
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: showSiteSelectedWidget(),
              ),
              ChipStyleTabBar(
                controller: _tabController,
                tabs: ["Sourcing Target", "Closing Target"],
              ),

              verticalSpacing(),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ValueListenableBuilder<DateTime?>(
                  valueListenable: _monthNotifier,
                  builder: (context, value, _) {
                    return CustomMonthYearPicker(
                      key: ValueKey(value),
                      title: "Select Month",
                      initialDate: value,
                      isRequired: true,
                      setValue: (val) {
                        _monthNotifier.value = val;
                        setState(() {});
                        _callMonthFilterAPI();
                      },
                    );
                  },
                ),
              ),

              Expanded(
                child: TabBarView(
                  physics: NeverScrollableScrollPhysics(),
                  controller: _tabController,
                  children: [
                    // SOURCING TARGET TAB
                    BlocBuilder<TargetCubit, TargetState>(
                      builder: (context, state) {
                        if (state.isSourcingLoading &&
                            state.salesTargetSourcing.isEmpty) {
                          return Center(child: loader());
                        }

                        if (state.salesTargetSourcing.isEmpty) {
                          return Center(
                            child: noDataWidget(message: "No Data Found"),
                          );
                        }

                        return ListView.builder(
                          controller: _sourcingTargetScrollController,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          itemCount: state.salesTargetSourcing.length + 1,
                          itemBuilder: (context, index) {
                            if (index == state.salesTargetSourcing.length) {
                              return state.salesTargetSourcing.length <
                                      state
                                          .sourcingTotalNumberOfRecordSalesTarget
                                  ? const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                  : const SizedBox.shrink();
                            }
                            var sourcing = state.salesTargetSourcing[index];
                            return GestureDetector(
                              onTap: () {
                                goRouter.pushNamed(
                                  AppRoutes.viewTarget,
                                  queryParameters: {
                                    "sourcing": Uri.encodeQueryComponent(
                                      EncryptionManager.encryptData(
                                        jsonEncode(sourcing.toJson()),
                                      ),
                                    ),
                                  },
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                margin: EdgeInsets.only(bottom: 10),
                                decoration: commonCardDecoration(),
                                child: Text(
                                  sourcing.employeeName,
                                  style: AppTextStyle.ts14M(
                                    color: AppColor.primary,
                                  ).copyWith(
                                    decoration: TextDecoration.underline,
                                    decorationColor: AppColor.primary,
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    // BOOKING TAB
                    BlocBuilder<TargetCubit, TargetState>(
                      builder: (context, state) {
                        if (state.isClosingLoading &&
                            state.salesTargetClosing.isEmpty) {
                          return Center(child: loader());
                        }
                        if (state.salesTargetClosing.isEmpty) {
                          return Center(
                            child: noDataWidget(message: "No Data found"),
                          );
                        }
                        return ListView.builder(
                          controller: _closingTargetScrollController,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          itemCount: state.salesTargetClosing.length + 1,
                          itemBuilder: (context, index) {
                            if (index == state.salesTargetClosing.length) {
                              return state.salesTargetClosing.length <
                                      state
                                          .closingTotalNumberOfRecordSalesTarget
                                  ? const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                  : const SizedBox.shrink();
                            }
                            var closing = state.salesTargetClosing[index];
                            return GestureDetector(
                              onTap: () {
                                goRouter.pushNamed(
                                  AppRoutes.viewTarget,
                                  queryParameters: {
                                    "closing": Uri.encodeQueryComponent(
                                      EncryptionManager.encryptData(
                                        jsonEncode(closing.toJson()),
                                      ),
                                    ),
                                  },
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                margin: EdgeInsets.only(bottom: 10),
                                decoration: commonCardDecoration(),
                                child: Text(
                                  closing.employeeName,
                                  style: AppTextStyle.ts14M(
                                    color: AppColor.primary,
                                  ).copyWith(
                                    decoration: TextDecoration.underline,
                                    decorationColor: AppColor.primary,
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
