import 'package:flutter/material.dart';
import 'package:k3h_erp_app/features/more/otp_logs/data/model/otp_logs.model.dart';

import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class OtpLogsDataSource extends DataGridSource {
  final BuildContext context;

  OtpLogsDataSource({required this.context, required List<OtpLogsModel> rows}) {
    dataGridRows =
        rows
            .map(
              (e) => DataGridRow(
                cells: [
                  DataGridCell<String>(columnName: 'module', value: e.module),
                  DataGridCell<String>(
                    columnName: 'label',
                    value: e.mobileNumber,
                  ),
                  DataGridCell<String>(columnName: 'otp', value: e.otp),
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
              case 'module':
                return Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    cell.value.toString(),
                    textAlign: TextAlign.center,
                  ),
                );

              case 'label':
                return Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(cell.value.toString()),
                );

              case 'otp':
                return Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          cell.value.toString(),
                          style: AppTextStyle.ts14M(),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          copy(context: context, text: cell.value.toString());
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            Icons.copy,
                            size: 16,
                            color: AppColor.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
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
