import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/inventory_reports/presentation/cubit/inventory_report_cubit.dart';
import 'package:k3h_erp_app/features/inventory_reports/presentation/cubit/inventory_report_state.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_export_button.dart';
import 'package:k3h_erp_app/widgets/app_bar/search_widget.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class InventoryOverallReportScreen extends StatefulWidget {
  const InventoryOverallReportScreen({super.key});

  @override
  State<InventoryOverallReportScreen> createState() =>
      _InventoryOverallReportScreenState();
}

class _InventoryOverallReportScreenState
    extends State<InventoryOverallReportScreen> {
  late TextEditingController _searchC;
  late InventoryReportCubit _inventoryReportCubit;
  // PAGINATION
  late ScrollController scrollController;
  Timer? _debounce;
  @override
  void initState() {
    _searchC = TextEditingController();
    _onScroll();
    _inventoryReportCubit = context.read<InventoryReportCubit>();
    _inventoryReportCubit.resetState();
    _inventoryReportCubit.getInventoryReport(pageNumber: 1, context: context);
    super.initState();
  }

  // PAGINATION
  void _onScroll() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !_inventoryReportCubit.state.isLoading! &&
          _inventoryReportCubit.state.reportList.length <
              _inventoryReportCubit.state.totalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _inventoryReportCubit.getInventoryReport(
            context: context,
            pageNumber: _inventoryReportCubit.state.currentPage + 1,
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Inventory and Parking Overall Report",
        authorization: AuthorizationModel(),
        isMenuButton: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Column(
          spacing: 10,
          children: [
            Row(
              spacing: 10,
              children: [
                Expanded(
                  child: SearchWidget(
                    onSubmit: (val) {
                      _inventoryReportCubit.search(context, val);
                    },
                    textController: _searchC,
                    hintText: "Search By Project Name",
                  ),
                ),
                CustomExportButton(
                  onExport: (value) {
                    _inventoryReportCubit.exportExcelPdf(context, value);
                  },
                ),
              ],
            ),
            BlocBuilder<InventoryReportCubit, InventoryReportState>(
              builder: (context, state) {
                if ((state.isLoading ?? false) && state.reportList.isEmpty) {
                  return Expanded(
                    child: const Center(child: CircularProgressIndicator()),
                  );
                }

                if (state.reportList.isEmpty) {
                  return Expanded(
                    child: Center(
                      child: noDataWidget(message: "No report found"),
                    ),
                  );
                }

                return Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      _inventoryReportCubit.getInventoryReport(
                        pageNumber: 1,
                        context: context,
                      );
                    },
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: state.reportList.length + 1,
                      itemBuilder: (context, index) {
                        if (index == state.reportList.length) {
                          return state.reportList.length <
                                  state.totalNumberOfRecord
                              ? Padding(
                                padding: const EdgeInsets.all(16),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                              : const SizedBox.shrink();
                        }
                        final report = state.reportList[index];

                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: commonCardDecoration(),
                          margin: const EdgeInsets.only(bottom: 10),
                          child: Column(
                            spacing: 10,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  await goRouter.pushNamed(
                                    AppRoutes
                                        .inventoryParkingOverallReportOverview,
                                    queryParameters: {
                                      'projectId': Uri.encodeComponent(
                                        EncryptionManager.encryptData(
                                          report.projectId.toString(),
                                        ),
                                      ),
                                    },
                                  );
                                },
                                child: Text(
                                  report.projectName,
                                  style: AppTextStyle.ts16M(
                                    color: AppColor.primary,
                                  ).copyWith(
                                    decoration: TextDecoration.underline,
                                    decorationColor: AppColor.primary,
                                  ),
                                ),
                              ),

                              Row(
                                children: [
                                  buildColumnTitleValue(
                                    title: "Total Building",
                                    value: report.totalBuilding.toString(),
                                  ),
                                  buildColumnTitleValue(
                                    title: "Total Area",
                                    value: "${report.totalReraArea} SqFt",
                                  ),
                                ],
                              ),

                              Row(
                                children: [
                                  buildColumnTitleValue(
                                    title: "Total Units",
                                    value: report.totalUnit.toString(),
                                  ),
                                  buildColumnTitleValue(
                                    title: "Available Units",
                                    value: "${report.availableUnit} Units",
                                    valueTextStyle: AppTextStyle.ts14M(
                                      color: AppColor.darkGreen10,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
