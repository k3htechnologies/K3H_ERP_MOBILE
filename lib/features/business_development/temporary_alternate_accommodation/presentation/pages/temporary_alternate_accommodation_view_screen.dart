import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/business_development/temporary_alternate_accommodation/data/model/temporary_alternate_accommodation.model.dart';
import 'package:k3h_erp_app/features/business_development/temporary_alternate_accommodation/presentation/cubit/temporary_alternate_accommodation_cubit.dart';
import 'package:k3h_erp_app/features/business_development/temporary_alternate_accommodation/presentation/pages/widgets/temporary_alternate_accomodation_datagrid.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class TemporaryAlternateAccommodationViewScreen extends StatefulWidget {
  final TemporaryAlternativeAccommodationModel tenantModel;
  const TemporaryAlternateAccommodationViewScreen({
    super.key,
    required this.tenantModel,
  });

  @override
  State<TemporaryAlternateAccommodationViewScreen> createState() =>
      _TemporaryAlternateAccommodationViewScreenState();
}

class _TemporaryAlternateAccommodationViewScreenState
    extends State<TemporaryAlternateAccommodationViewScreen> {
  final List<String> tabTitles = [
    'Additional TAA',
    'TAA',
    'Hardship',
    'Brokerage',
    'Shifting',
  ];

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
        .pullChargesDetailsForView(
          context: context,
          projectId: widget.tenantModel.projectId,
          buildingId: widget.tenantModel.buildingId,
          chargeName:
              tabTitles[context
                  .read<TemporaryAlternateAccommodationCubit>()
                  .state
                  .currentTabIndex],
        );

    // Skip the 1997 adjustment/lump-sum records, keep only real month-wise entries
    final filtered =
        taaList.where((e) => e.date.year != 1997).toList()
          ..sort((a, b) => a.date.compareTo(b.date));

    taaRows.value =
        filtered
            .map(
              (e) => TemporaryAlternateAccommodationGridRowModel(
                label: DateFormat('MMM yyyy').format(e.date),
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
        screenTitle: "TAA",
        authorization: AuthorizationModel(),
      ),
      body: BlocBuilder<
        TemporaryAlternateAccommodationCubit,
        TemporaryAlternateAccommodationState
      >(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: ValueListenableBuilder<
              List<TemporaryAlternateAccommodationGridRowModel>
            >(
              valueListenable: taaRows,
              builder: (context, rows, _) {
                if (state.isLoading ?? true) {
                  return Center(child: loader());
                }
                if (rows.isEmpty) {
                  return Center(
                    child: noDataWidget(message: 'No records found'),
                  );
                }
                return Column(
                  children: [
                    infoCard([
                      {
                        "title": "Flat Number",
                        "value": widget.tenantModel.flatNumber,
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
                            return SfDataGrid(
                              source:
                                  TemporaryAlternateAccommodationReportDataSource(
                                    rows: rows,
                                  ),
                              columnWidthMode: ColumnWidthMode.fill,
                              columns: [
                                GridColumn(
                                  columnName: 'label',
                                  label: const Center(child: Text('Month')),
                                ),
                                GridColumn(
                                  columnName: 'amount',
                                  label: const Center(child: Text('Amount')),
                                ),
                              ],
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
