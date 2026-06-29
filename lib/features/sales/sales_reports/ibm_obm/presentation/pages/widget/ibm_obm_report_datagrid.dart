import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class IbmObmGridRowModel {
  final String label;
  final int ibm;
  final int obm;

  IbmObmGridRowModel({
    required this.label,
    required this.ibm,
    required this.obm,
  });
}

class IbmObmReportDataSource extends DataGridSource {
  IbmObmReportDataSource({required List<IbmObmGridRowModel> rows}) {
    dataGridRows =
        rows
            .map(
              (e) => DataGridRow(
                cells: [
                  DataGridCell<String>(columnName: 'label', value: e.label),
                  DataGridCell<int>(columnName: 'ibm', value: e.ibm),
                  DataGridCell<int>(columnName: 'obm', value: e.obm),
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
                    cell.value.toString(),
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
