import 'package:flutter/material.dart';
import 'package:k3h_erp_app/features/estimation_and_budget/budget/data/model/inventory_project_basement_podium_wing_budget.model.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class BudgetSummaryDataSource extends DataGridSource {
  final BuildContext context;

  BudgetSummaryDataSource({
    required this.context,
    required List<InventoryProjectBasementPodiumWingBudgetModel> rows,
  }) {
    dataGridRows =
        rows
            .map(
              (e) => DataGridRow(
                cells: [
                  DataGridCell<String>(
                    columnName: 'component',
                    value: e.projectBuildingNumberWing,
                  ),
                  DataGridCell<String>(
                    columnName: 'amount',
                    value: e.budgetAmount.toIndianCurrency(),
                  ),
                ],
              ),
            )
            .toList();
  }

  late final List<DataGridRow> dataGridRows;

  @override
  List<DataGridRow> get rows => dataGridRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells:
          row.getCells().map((cell) {
            switch (cell.columnName) {
              case 'component':
                return Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    cell.value.toString(),
                    textAlign: TextAlign.center,
                    style: AppTextStyle.ts14M(),
                  ),
                );

              case 'amount':
                return Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    cell.value.toString(),
                    style: AppTextStyle.ts14M(),
                  ),
                );

              default:
                return Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    cell.value.toString(),
                    style: AppTextStyle.ts14M(),
                  ),
                );
            }
          }).toList(),
    );
  }
}
