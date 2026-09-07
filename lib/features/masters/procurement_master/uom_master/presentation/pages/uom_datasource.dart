import 'package:flutter/material.dart';
import 'package:k3h_erp_app/features/masters/procurement_master/uom_master/data/model/uom_master.model.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class UomScreenDataSource extends DataGridSource {
  final BuildContext context;

  UomScreenDataSource({required this.context, required List<UOMModel> rows}) {
    dataGridRows =
        rows
            .map(
              (e) => DataGridRow(
                cells: [
                  DataGridCell<String>(columnName: 'uom', value: e.uom),
                  DataGridCell<String>(columnName: 'code', value: e.uomCode),
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
              case 'uom':
                return Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    cell.value.toString(),
                    textAlign: TextAlign.center,
                  ),
                );

              case 'code':
                return Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(cell.value.toString()),
                );

              default:
                return Container(
                  alignment: Alignment.center,
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
