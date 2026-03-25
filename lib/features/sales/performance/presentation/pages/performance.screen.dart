import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/sales/performance/presentation/cubit/performance_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/app_bar/search_widget.dart';
import 'package:k3h_erp_app/widgets/chip_style_tab_bar.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class PerformanceScreen extends StatefulWidget {
  const PerformanceScreen({super.key});

  @override
  State<PerformanceScreen> createState() => _PerformanceScreenState();
}

class _PerformanceScreenState extends State<PerformanceScreen>
    with SingleTickerProviderStateMixin {
  // CUBIT
  late PerformanceCubit _performanceCubit;

  // PROJECT
  late ProjectModel selectedProject;

  // AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;
  // TEXT EDITING CONTROLLERS
  late TextEditingController _searchC;
  // SCROLL CONTROLLERS
  late ScrollController _sourcingTargetScrollController;
  late ScrollController _closingTargetScrollController;

  // TAB CONTROLLER
  late TabController _tabController;
  int _lastHandledTabIndex = 0;
  bool _isHandlingTabChange = false;
  bool ignoreSearch = false;
  String selectedType = "WTD";
  // FILTER
  final ValueNotifier<DateTime?> _startDateNotifier = ValueNotifier<DateTime?>(
    null,
  );
  final ValueNotifier<DateTime?> _endDateNotifier = ValueNotifier<DateTime?>(
    null,
  );
  void _onTypeSelected(String value) {
    setState(() {
      selectedType = value;
    });
  }

  @override
  void initState() {
    super.initState();
    _performanceCubit = context.read<PerformanceCubit>();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.performanceReport]!;
    _initializeTextEditingController();
    // INITIALIZE SCROLL CONTROLLERS
    _sourcingTargetScrollController = ScrollController();
    _closingTargetScrollController = ScrollController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _sourcingTargetScrollController.dispose();
    _closingTargetScrollController.dispose();
    super.dispose();
  } // INITIALIZE TEXT EDITING CONTROLLERS

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
    _searchC.text = "";
    _startDateNotifier.value = null;
    _endDateNotifier.value = null;
    _performanceCubit.onTabChanged(index, context);
    if (index == 0) {
      _performanceCubit.getPerformanceSourcingReportList(
        context: context,
        pageNumber: 1,
        projectId: getProject().projectId,
        reportType: "Sourcing",
      );
    } else {
      _performanceCubit.getPerformanceClosingReportList(
        context: context,
        pageNumber: 1,
        projectId: getProject().projectId,
        reportType: "Closing",
      );
    }
    Future.delayed(const Duration(milliseconds: 300), () {
      ignoreSearch = false;
    });
    _isHandlingTabChange = false;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColor.white,
        appBar: CustomAppBarWithBackButton(
          screenTitle: "Performance Report",
          authorization: _routeAuthorizationModel,
          onProjectChangeCallback: (value) {
            selectedProject = value;
            _performanceCubit.getPerformanceSourcingReportList(
              context: context,
              projectId: getProject().projectId,
              reportType: "Sorucing",
            );
          },
          isMenuButton: true,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _performaneReportTillDateWidget(context),
            // Expanded(
            //   child: ListView.builder(
            //     itemCount: 10,
            //     shrinkWrap: true,
            //     physics: AlwaysScrollableScrollPhysics(),
            //     itemBuilder: (context, int index) {
            //       return Container(
            //         margin: EdgeInsets.only(
            //           bottom: 20.0,
            //           left: 20.0,
            //           right: 20.0,
            //         ),
            //         padding: EdgeInsets.symmetric(
            //           horizontal: 16.0,
            //           vertical: 16.0,
            //         ),
            //         decoration: commonCardDecoration(),
            //         child: Column(
            //           crossAxisAlignment: CrossAxisAlignment.start,
            //           children: [
            //             GestureDetector(
            //               onTap: () {
            //                 goRouter.pushNamed(AppRoutes.viewPerformanceReport);
            //               },
            //               child: Text(
            //                 "Prachin Bari",
            //                 style: AppTextStyle.ts16M(
            //                   color: AppColor.primary,
            //                 ).copyWith(
            //                   decoration: TextDecoration.underline,
            //                   decorationColor: AppColor.primary,
            //                 ),
            //               ),
            //             ),
            //             _leaveRow(title: "Overall Target", value: "200"),
            //             _leaveRow(title: "Overall Achieved", value: "200"),
            //             _leaveRow(title: "Overall Performance", value: "200"),
            //           ],
            //         ),
            //       );
            //     },
            //   ),
            // ),
            ChipStyleTabBar(
              controller: _tabController,
              tabs: ["Sorucing Target", "Closing Target"],
            ),
            Expanded(
              child: TabBarView(
                physics: NeverScrollableScrollPhysics(),
                controller: _tabController,
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

  Widget _buildSourcingTargetView() {
    return Center(child: Text("Sourcing Target"));
  }

  Widget _buildClosingTargetView() {
    return Center(child: Text("Closing Target"));
  }

  Widget _performaneReportTillDateWidget(BuildContext context) {
    final List<String> items = ["WTD", "MTD", "YTD"];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children:
                items.map((item) {
                  final bool isSelected = selectedType == item;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: InkWell(
                        onTap: () => _onTypeSelected(item),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 5.0,
                            horizontal: 18.0,
                          ),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? AppColor.primary.withValues(alpha: 0.2)
                                    : AppColor.white,
                            borderRadius: BorderRadius.circular(4.0),
                            border: Border.all(
                              color: AppColor.primary,
                              width: 0.5,
                            ),
                          ),
                          child: Text(
                            item,
                            style:
                                isSelected
                                    ? AppTextStyle.ts12M(color: AppColor.black)
                                    : AppTextStyle.ts10M(
                                      color: AppColor.black.withValues(
                                        alpha: 0.5,
                                      ),
                                    ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
          verticalSpacing(height: 20.0),
          SearchWidget(
            onSubmit: (value) {},
            hintText: "Search By Employee Name",
            textController: TextEditingController(),
            isFilterOn: true,
            onFilterTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _leaveRow({required String title, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              title,
              style: AppTextStyle.ts14R(
                color: AppColor.black.withValues(alpha: 0.5),
              ),
            ),
          ),
          SizedBox(
            width: 24,
            child: Center(child: Text(":", style: AppTextStyle.ts14M())),
          ),

          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(value, style: AppTextStyle.ts14M()),
            ),
          ),
        ],
      ),
    );
  }
}
