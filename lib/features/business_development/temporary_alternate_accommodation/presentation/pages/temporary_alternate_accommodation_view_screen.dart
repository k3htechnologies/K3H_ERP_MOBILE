import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/business_development/temporary_alternate_accommodation/data/model/temporary_alternate_accommodation.model.dart';
import 'package:k3h_erp_app/features/business_development/temporary_alternate_accommodation/presentation/cubit/temporary_alternate_accommodation_cubit.dart';
import 'package:k3h_erp_app/features/business_development/temporary_alternate_accommodation/presentation/pages/widgets/temporary_alternate_accomodation_datasource.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_extension_helpers.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class TemporaryAlternateAccommodationViewScreen extends StatefulWidget {
  final TemporaryAlternativeAccommodationModel tenantModel;
  final double totalAmount;
  final double paidAmount;
  const TemporaryAlternateAccommodationViewScreen({
    super.key,
    required this.tenantModel,
    required this.totalAmount,
    required this.paidAmount,
  });
  @override
  State<TemporaryAlternateAccommodationViewScreen> createState() =>
      _TemporaryAlternateAccommodationViewScreenState();
}

class _TemporaryAlternateAccommodationViewScreenState
    extends State<TemporaryAlternateAccommodationViewScreen> {
  final ValueNotifier<List<TemporaryAlternateAccommodationGridRowModel>>
  taaRows = ValueNotifier([]);

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    final taaList = await context
        .read<TemporaryAlternateAccommodationCubit>()
        .getChargesDetailsForView(
          context: context,
          projectId: widget.tenantModel.projectId,
          buildingId: widget.tenantModel.buildingId,
        );
    final filtered =
        taaList.where((e) => e.date.year != 1997).toList()
          ..sort((a, b) => a.date.compareTo(b.date));
    taaRows.value =
        filtered
            .map(
              (e) => TemporaryAlternateAccommodationGridRowModel(
                label: DateFormat('dd MMM yyyy').format(e.date),
                amount: e.amount,
              ),
            )
            .toList();
  }

  @override
  void dispose() {
    taaRows.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Temporary Alternate\nAccommodation",
        authorization: AuthorizationModel(),
      ),
      body: BlocBuilder<
        TemporaryAlternateAccommodationCubit,
        TemporaryAlternateAccommodationState
      >(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: ValueListenableBuilder<
              List<TemporaryAlternateAccommodationGridRowModel>
            >(
              valueListenable: taaRows,
              builder: (context, rows, _) {
                return Column(
                  spacing: 12,
                  children: [
                    infoCard([
                      {
                        "title": "Flat Number",
                        "value": widget.tenantModel.flatNumber,
                      },
                      {
                        "title": "Applicant Name",
                        "value": widget.tenantModel.applicantName,
                      },
                      {"title": "Tenure", "value": widget.tenantModel.tenure},
                      {
                        "title": "Charge Type",
                        "value":
                            context
                                .read<TemporaryAlternateAccommodationCubit>()
                                .state
                                .chargeType,
                      },
                      {
                        "title": "Carpet Area (SqFt)",
                        "value":
                            '${widget.tenantModel.flatCarpetAreaSqFt.addCommas()} SqFt',
                      },
                      {
                        "title": "Unit Type",
                        "value": widget.tenantModel.flatType,
                      },
                      {
                        "title": "Total Amount",
                        "value": widget.totalAmount.toIndianCurrency(),
                      },
                      {
                        "title": "Paid Total Amount",
                        "value": widget.paidAmount.toIndianCurrency(),
                      },
                    ]),
                    Expanded(
                      child: SfDataGridTheme(
                        data: SfDataGridThemeData(
                          headerColor: AppColor.lightBlue2.withValues(
                            alpha: 0.3,
                          ),
                          gridLineColor: AppColor.grey50,
                          gridLineStrokeWidth: 0.5,
                        ),
                        child: Builder(
                          builder: (context) {
                            if (state.isLoading ?? true) {
                              return Center(child: loader());
                            }
                            if (rows.isEmpty) {
                              return Center(
                                child: noDataWidget(
                                  message: 'No records found',
                                ),
                              );
                            }
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: SfDataGrid(
                                source:
                                    TemporaryAlternateAccommodationReportDataSource(
                                      rows: rows,
                                    ),
                                columnWidthMode: ColumnWidthMode.fill,
                                columns: [
                                  GridColumn(
                                    columnName: 'label',
                                    label: Center(
                                      child: Text(
                                        'Month',
                                        style: AppTextStyle.ts12SB(),
                                      ),
                                    ),
                                  ),
                                  GridColumn(
                                    columnName: 'amount',
                                    label: Center(
                                      child: Text(
                                        'Amount',
                                        style: AppTextStyle.ts12SB(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
