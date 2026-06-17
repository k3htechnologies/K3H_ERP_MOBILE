import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/sales/sales_dashboard/presentation/cubit/sales_dashboard_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/app_bar/search_widget.dart';
import 'package:k3h_erp_app/widgets/chip_style_tab_bar.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class PerformanceWithoutAccessScreen extends StatefulWidget {
  const PerformanceWithoutAccessScreen({super.key});

  @override
  State<PerformanceWithoutAccessScreen> createState() =>
      _PerformanceWithoutAccessScreenState();
}

class _PerformanceWithoutAccessScreenState
    extends State<PerformanceWithoutAccessScreen>
    with TickerProviderStateMixin {
  // TEXT EDITING CONTROLLERS
  late TextEditingController _searchC;

  // TAB CONTROLLERS
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);

    _tabController.addListener(_handleTabChangeSecond);

    _initializeTextEditingController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchC.dispose();
    super.dispose();
  }

  // INITIALIZE TEXT EDITING CONTROLLERS
  void _initializeTextEditingController() {
    _searchC = TextEditingController();
  }

  void _handleTabChangeSecond() {
    if (!_tabController.indexIsChanging) {
      _searchC.clear();
    }
  }

  Future<void> _onRefresh() async {
    _searchC.clear();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBarWithBackButton(
          screenTitle: "Performance Report",
          authorization: AuthorizationModel(),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SearchWidget(
                hintText: "Search by Name",
                onSubmit: (value) {},
                textController: _searchC,
              ),
            ),

            verticalSpacing(),
            ChipStyleTabBar(
              controller: _tabController,
              tabs: ["Sourcing Target", "Closing Target"],
            ),
            verticalSpacing(),
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

  // BUILD SOURCING TARGET VIEW
  Widget _buildSourcingTargetView() {
    return BlocBuilder<SalesDashboardCubit, SalesDashboardState>(
      builder: (context, state) {
        if (state.isLoading ?? true) {
          return Center(child: loader());
        }

        return RefreshIndicator(
          onRefresh: _onRefresh,
          child:
              state.salesDashboardListForFilter.first.table3.isEmpty
                  ? Center(
                    child: noDataWidget(
                      message: "No Performance Report Data Found",
                    ),
                  )
                  : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount:
                        state.salesDashboardListForFilter.first.table3.length,
                    itemBuilder: (_, index) {
                      final sourcingTarget =
                          state.salesDashboardListForFilter.first.table3[index];

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
    return BlocBuilder<SalesDashboardCubit, SalesDashboardState>(
      builder: (context, state) {
        if (state.isLoading ?? true) {
          return Center(child: loader());
        }

        return RefreshIndicator(
          onRefresh: _onRefresh,
          child:
              state.salesDashboardListForFilter.first.table2.isEmpty
                  ? Center(
                    child: noDataWidget(
                      message: "No Performance Report Data Found",
                    ),
                  )
                  : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount:
                        state.salesDashboardListForFilter.first.table2.length,
                    itemBuilder: (_, index) {
                      final closingTarget =
                          state.salesDashboardListForFilter.first.table2[index];

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
