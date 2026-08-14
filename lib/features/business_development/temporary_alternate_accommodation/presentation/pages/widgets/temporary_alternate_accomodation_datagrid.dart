import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class TemporaryAlternateAccommodationGridRowModel {
  final String label;
  final double amount;

  TemporaryAlternateAccommodationGridRowModel({
    required this.label,
    required this.amount,
  });
}

class TemporaryAlternateAccommodationReportDataSource extends DataGridSource {
  TemporaryAlternateAccommodationReportDataSource({
    required List<TemporaryAlternateAccommodationGridRowModel> rows,
  }) {
    dataGridRows =
        rows
            .map(
              (e) => DataGridRow(
                cells: [
                  DataGridCell<String>(columnName: 'label', value: e.label),
                  // Keep the raw numeric value here, NOT the formatted string
                  DataGridCell<double>(columnName: 'amount', value: e.amount),
                ],
              ),
            )
            .toList();
  }

  late List<DataGridRow> dataGridRows;

  @override
  List<DataGridRow> get rows => dataGridRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells:
          row
              .getCells()
              .mapWithIndex(
                (cell, index) => Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    // Format only the amount column for display; label stays as-is
                    index == 0
                        ? cell.value.toString()
                        : (cell.value as double).toIndianCurrency(),
                    style:
                        index == 0
                            ? AppTextStyle.ts14R()
                            : AppTextStyle.ts14M(),
                  ),
                ),
              )
              .toList(),
    );
  }
}
