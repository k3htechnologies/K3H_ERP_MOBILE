import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/inventory/reports/data/model/inventory_parking_overall_report.model.dart';
import 'package:k3h_erp_app/features/inventory/reports/presentation/cubit/inventory_report_cubit.dart';
import 'package:k3h_erp_app/features/inventory/reports/presentation/cubit/inventory_report_state.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/chip_style_tab_bar.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class InventoryOverallReportOverview extends StatefulWidget {
  final int projectId;

  const InventoryOverallReportOverview({super.key, required this.projectId});

  @override
  State<InventoryOverallReportOverview> createState() =>
      _InventoryOverallReportOverviewState();
}

class _InventoryOverallReportOverviewState
    extends State<InventoryOverallReportOverview>
    with TickerProviderStateMixin {
  late InventoryReportCubit _inventoryReportCubit;

  TabController? _tabController;

  @override
  void initState() {
    super.initState();

    _inventoryReportCubit = context.read<InventoryReportCubit>();

    _inventoryReportCubit.getInventoryOverallReport(
      projectId: widget.projectId,
    );
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  List<String> _getUniqueWings(List<InventoryParkingOverallReport> data) {
    return data.map((e) => e.wing).where((e) => e.isNotEmpty).toSet().toList();
  }

  List<InventoryParkingOverallReport> _getWingWiseData(
    List<InventoryParkingOverallReport> data,
    String wing,
  ) {
    return data
        .where((e) => (e.wing).toLowerCase() == wing.toLowerCase())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Report",
        authorization: AuthorizationModel(),
      ),

      body: BlocBuilder<InventoryReportCubit, InventoryReportState>(
        builder: (context, state) {
          final reportList = state.reportDetailsList;

          if (state.isLoading ?? true && state.reportDetailsList.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (reportList.isEmpty) {
            return const Center(child: Text("No Data Found"));
          }

          final wings = _getUniqueWings(reportList);

          if (_tabController == null ||
              _tabController!.length != wings.length) {
            _tabController?.dispose();

            _tabController = TabController(length: wings.length, vsync: this);
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  reportList.first.projectName,
                  style: AppTextStyle.ts16SB(color: AppColor.primary),
                ),
              ),
              verticalSpacing(height: 10),
              ChipStyleTabBar(
                isSecondaryStyle: false,
                controller: _tabController!,
                tabs: wings.map((wing) => wing).toList(),
              ),

              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children:
                      wings.map((wing) {
                        /// Wing Wise Data
                        final wingData = _getWingWiseData(reportList, wing);

                        /// =========================
                        /// AREA CALCULATION
                        /// =========================
                        final totalArea = wingData.fold<double>(
                          0,
                          (sum, item) => sum + (item.totalReraArea),
                        );

                        final soldArea = wingData.fold<double>(
                          0,
                          (sum, item) => sum + (item.bookedReraArea),
                        );

                        final availableArea = wingData.fold<double>(
                          0,
                          (sum, item) => sum + (item.availableReraArea),
                        );

                        final blockedArea = wingData.fold<double>(
                          0,
                          (sum, item) => sum + (item.blockReraArea),
                        );

                        final holdArea = wingData.fold<double>(
                          0,
                          (sum, item) => sum + (item.holdReraArea),
                        );

                        final allotedArea = wingData.fold<double>(
                          0,
                          (sum, item) => sum + (item.allotedReraArea),
                        );

                        /// =========================
                        /// UNIT CALCULATION
                        /// =========================
                        final totalUnit = wingData.fold<int>(
                          0,
                          (sum, item) => sum + (item.totalUnit),
                        );

                        final soldUnit = wingData.fold<int>(
                          0,
                          (sum, item) => sum + (item.bookedUnit),
                        );

                        final availableUnit = wingData.fold<int>(
                          0,
                          (sum, item) => sum + (item.availableUnit),
                        );

                        final blockedUnit = wingData.fold<int>(
                          0,
                          (sum, item) => sum + (item.blockUnit),
                        );

                        final holdUnit = wingData.fold<int>(
                          0,
                          (sum, item) => sum + (item.holdUnit),
                        );

                        final allotedUnit = wingData.fold<int>(
                          0,
                          (sum, item) => sum + (item.allotedUnit),
                        );

                        /// =========================
                        /// PARKING CALCULATION
                        /// =========================
                        final totalParking = wingData.fold<int>(
                          0,
                          (sum, item) => sum + (item.totalParking),
                        );

                        final availableParking = wingData.fold<int>(
                          0,
                          (sum, item) => sum + (item.availableParking),
                        );

                        final blockedParking = wingData.fold<int>(
                          0,
                          (sum, item) => sum + (item.blockedParking),
                        );

                        final bookedParking = wingData.fold<int>(
                          0,
                          (sum, item) => sum + (item.bookedParking),
                        );

                        final holdParking = wingData.fold<int>(
                          0,
                          (sum, item) => sum + (item.holdParking),
                        );

                        final memberParking = wingData.fold<int>(
                          0,
                          (sum, item) => sum + (item.memberParking),
                        );

                        return ListView.builder(
                          itemCount: wingData.length,
                          itemBuilder: (context, index) {
                            final item = wingData[index];
                            return SingleChildScrollView(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.buildingNumber,
                                    style: AppTextStyle.ts16SB(
                                      color: AppColor.primary,
                                    ),
                                  ),

                                  /// =========================
                                  /// AREA
                                  /// =========================
                                  Container(
                                    decoration: commonCardDecoration(),
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(14),

                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Area",
                                          style: AppTextStyle.ts16SB(),
                                        ),

                                        verticalSpacing(height: 5),

                                        Divider(
                                          height: 1,
                                          color: AppColor.grey50,
                                        ),

                                        verticalSpacing(height: 5),

                                        buildRowTitleValue(
                                          fixesWidth: 180.w,
                                          title: "Total",
                                          value:
                                              "${totalArea.toStringAsFixed(2)} sq.ft",
                                        ),

                                        buildRowTitleValue(
                                          fixesWidth: 180.w,
                                          title: "Sold",
                                          value:
                                              "${soldArea.toStringAsFixed(2)} sq.ft",
                                        ),

                                        buildRowTitleValue(
                                          fixesWidth: 180.w,
                                          title: "Available",
                                          value:
                                              "${availableArea.toStringAsFixed(2)} sq.ft",
                                          valueTextStyle: AppTextStyle.ts14M(
                                            color: AppColor.green,
                                          ),
                                        ),

                                        buildRowTitleValue(
                                          fixesWidth: 180.w,
                                          title: "Blocked",
                                          value:
                                              "${blockedArea.toStringAsFixed(2)} sq.ft",
                                          valueTextStyle: AppTextStyle.ts14M(
                                            color: AppColor.red,
                                          ),
                                        ),

                                        buildRowTitleValue(
                                          fixesWidth: 180.w,
                                          title: "Hold",
                                          value:
                                              "${holdArea.toStringAsFixed(2)} sq.ft",
                                          valueTextStyle: AppTextStyle.ts14M(
                                            color: AppColor.yellow,
                                          ),
                                        ),

                                        buildRowTitleValue(
                                          fixesWidth: 180.w,
                                          title: "Alloted",
                                          value:
                                              "${allotedArea.toStringAsFixed(2)} sq.ft",
                                        ),
                                      ],
                                    ),
                                  ),

                                  /// =========================
                                  /// UNIT
                                  /// =========================
                                  Container(
                                    decoration: commonCardDecoration(),
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(14),

                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Unit",
                                          style: AppTextStyle.ts16SB(),
                                        ),

                                        verticalSpacing(height: 5),

                                        Divider(
                                          height: 1,
                                          color: AppColor.grey50,
                                        ),

                                        verticalSpacing(height: 5),

                                        buildRowTitleValue(
                                          fixesWidth: 180.w,
                                          title: "Total",
                                          value: totalUnit.toString(),
                                        ),

                                        buildRowTitleValue(
                                          fixesWidth: 180.w,
                                          title: "Sold",
                                          value: soldUnit.toString(),
                                        ),

                                        buildRowTitleValue(
                                          fixesWidth: 180.w,
                                          title: "Available",
                                          value: availableUnit.toString(),
                                          valueTextStyle: AppTextStyle.ts14M(
                                            color: AppColor.green,
                                          ),
                                        ),

                                        buildRowTitleValue(
                                          fixesWidth: 180.w,
                                          title: "Blocked",
                                          value: blockedUnit.toString(),
                                          valueTextStyle: AppTextStyle.ts14M(
                                            color: AppColor.red,
                                          ),
                                        ),

                                        buildRowTitleValue(
                                          fixesWidth: 180.w,
                                          title: "Hold",
                                          value: holdUnit.toString(),
                                          valueTextStyle: AppTextStyle.ts14M(
                                            color: AppColor.yellow,
                                          ),
                                        ),

                                        buildRowTitleValue(
                                          fixesWidth: 180.w,
                                          title: "Alloted",
                                          value: allotedUnit.toString(),
                                        ),
                                      ],
                                    ),
                                  ),

                                  /// =========================
                                  /// PARKING
                                  /// =========================
                                  Container(
                                    decoration: commonCardDecoration(),
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(14),

                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Parking",
                                          style: AppTextStyle.ts16SB(),
                                        ),

                                        verticalSpacing(height: 5),

                                        Divider(
                                          height: 1,
                                          color: AppColor.grey50,
                                        ),

                                        verticalSpacing(height: 5),

                                        buildRowTitleValue(
                                          fixesWidth: 180.w,
                                          title: "Total",
                                          value: totalParking.toString(),
                                        ),

                                        buildRowTitleValue(
                                          fixesWidth: 180.w,
                                          title: "Available",
                                          value: availableParking.toString(),
                                          valueTextStyle: AppTextStyle.ts14M(
                                            color: AppColor.green,
                                          ),
                                        ),

                                        buildRowTitleValue(
                                          fixesWidth: 180.w,
                                          title: "Blocked",
                                          value: blockedParking.toString(),
                                          valueTextStyle: AppTextStyle.ts14M(
                                            color: AppColor.red,
                                          ),
                                        ),

                                        buildRowTitleValue(
                                          fixesWidth: 180.w,
                                          title: "Booked",
                                          value: bookedParking.toString(),
                                        ),

                                        buildRowTitleValue(
                                          fixesWidth: 180.w,
                                          title: "Hold",
                                          value: holdParking.toString(),
                                          valueTextStyle: AppTextStyle.ts14M(
                                            color: AppColor.yellow,
                                          ),
                                        ),

                                        buildRowTitleValue(
                                          fixesWidth: 180.w,
                                          title: "Member",
                                          value: memberParking.toString(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
