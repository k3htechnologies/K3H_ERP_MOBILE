import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/estimation_and_budget/budget/data/model/inventory_project_basement_podium_wing_budget.model.dart';
import 'package:k3h_erp_app/features/estimation_and_budget/budget/presentation/cubit/budget_cubit.dart';
import 'package:k3h_erp_app/features/estimation_and_budget/budget/presentation/cubit/budget_state.dart';
import 'package:k3h_erp_app/features/estimation_and_budget/budget/presentation/pages/budget_summary_datasource.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class ViewBudgetSummaryScreen extends StatefulWidget {
  final int projectId;
  final int inventoryFlatFloorBasementPodiumWingId;
  const ViewBudgetSummaryScreen({
    super.key,
    required this.projectId,
    required this.inventoryFlatFloorBasementPodiumWingId,
  });

  @override
  State<ViewBudgetSummaryScreen> createState() =>
      _ViewBudgetSummaryScreenState();
}

class _ViewBudgetSummaryScreenState extends State<ViewBudgetSummaryScreen> {
  late BudgetCubit _budgetCubit;
  final ValueNotifier<List<InventoryProjectBasementPodiumWingBudgetModel>>
  _budgetSummaryList = ValueNotifier([]);

  @override
  void initState() {
    _budgetCubit = context.read<BudgetCubit>();
    loadBudgetSummary();
    super.initState();
  }

  void loadBudgetSummary() async {
    _budgetSummaryList.value = await _budgetCubit.getBudgetSummary(
      projectId: widget.projectId,
      inventoryFlatFloorBasementPodiumWingId:
          widget.inventoryFlatFloorBasementPodiumWingId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: 'Budget Summary',
        authorization: AuthorizationModel(),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
        child: Column(
          spacing: 10,
          children: [
            showSiteSelectedWidget(),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: _budgetSummaryList,
                builder: (context, summary, child) {
                  return BlocBuilder<BudgetCubit, BudgetState>(
                    builder: (context, state) {
                      if ((state.isLoading ?? false)) {
                        return loader();
                      }
                      if ((state.isLoading ?? false) && summary.isEmpty) {
                        return Center(child: noDataWidget());
                      }
                      return Column(
                        children: [
                          Expanded(
                            child: SfDataGridTheme(
                              data: SfDataGridThemeData(
                                headerColor: AppColor.lightBlue2.withValues(
                                  alpha: 0.3,
                                ),
                                gridLineColor: AppColor.grey50,
                                gridLineStrokeWidth: 0.5,
                              ),
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Builder(
                                      builder: (context) {
                                        final dataSource =
                                            BudgetSummaryDataSource(
                                              context: context,
                                              rows: summary,
                                            );
                                        return SfDataGrid(
                                          source: dataSource,
                                          columnWidthMode: ColumnWidthMode.fill,
                                          onQueryRowHeight: (details) {
                                            return details
                                                .getIntrinsicRowHeight(
                                                  details.rowIndex,
                                                );
                                          },
                                          columns: [
                                            GridColumn(
                                              columnName: 'component',
                                              label: Padding(
                                                padding: const EdgeInsets.all(
                                                  16.0,
                                                ),
                                                child: Text(
                                                  'Component',
                                                  style: AppTextStyle.ts12SB(),
                                                ),
                                              ),
                                            ),
                                            GridColumn(
                                              columnName: 'amount',
                                              label: Padding(
                                                padding: const EdgeInsets.all(
                                                  16.0,
                                                ),
                                                child: Text(
                                                  'Budget Amount (₹)',
                                                  style: AppTextStyle.ts12SB(),
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
