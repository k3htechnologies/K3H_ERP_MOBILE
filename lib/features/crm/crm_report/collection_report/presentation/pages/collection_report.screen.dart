import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/crm/crm_report/collection_report/presentation/cubit/collection_report_cubit.dart';
import 'package:k3h_erp_app/features/crm/crm_report/collection_report/presentation/pages/widgets/wing_summary.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_export_button.dart';
import 'package:k3h_erp_app/widgets/app_bar/search_widget.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/expansion_tile/custom_expansion_tile.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class CollectionReportScreen extends StatefulWidget {
  const CollectionReportScreen({super.key});

  @override
  State<CollectionReportScreen> createState() => _CollectionReportScreenState();
}

class _CollectionReportScreenState extends State<CollectionReportScreen> {
  late CollectionReportCubit _collectionReportCubit;
  late TextEditingController _searchC;
  final ValueNotifier<String?> _selectedWingKey = ValueNotifier<String?>(null);
  late ScrollController scrollController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchC = TextEditingController();
    _onScroll();
    _collectionReportCubit = context.read<CollectionReportCubit>();
    _collectionReportCubit.getDailyCollectionReportList(context, pageNumber: 1);
  }

  void _onScroll() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !_collectionReportCubit.state.isLoading! &&
          _collectionReportCubit.state.collectionReportList.length <
              _collectionReportCubit.state.totalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _collectionReportCubit.getDailyCollectionReportList(
            context,
            pageNumber: _collectionReportCubit.state.currentPage + 1,
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _selectedWingKey.dispose();
    _searchC.dispose();
    scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Collection Report",
        authorization: AuthorizationModel(),
        isMenuButton: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Column(
          spacing: 10.0,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              spacing: 10,
              children: [
                Expanded(
                  child: SearchWidget(
                    onSubmit: (val) {
                      _collectionReportCubit.searchDCR(context, val);
                    },
                    textController: _searchC,
                    hintText: "Search By Project Name",
                  ),
                ),
                CustomExportButton(
                  onExport: (value) {
                    _collectionReportCubit.exportExcelPdf(context, value);
                  },
                ),
              ],
            ),
            BlocBuilder<CollectionReportCubit, CollectionReportState>(
              builder: (context, state) {
                if ((state.isLoading ?? false) &&
                    state.collectionReportList.isEmpty) {
                  return Expanded(
                    child: const Center(child: CircularProgressIndicator()),
                  );
                }

                if (state.collectionReportList.isEmpty) {
                  return Expanded(
                    child: Center(
                      child: noDataWidget(
                        message: "No collection reports found",
                      ),
                    ),
                  );
                }

                return Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      _collectionReportCubit.getDailyCollectionReportList(
                        context,
                        pageNumber: 1,
                      );
                    },
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: state.collectionReportList.length + 1,
                      itemBuilder: (context, index) {
                        if (index == state.collectionReportList.length) {
                          return state.collectionReportList.length <
                                  state.totalNumberOfRecord
                              ? Padding(
                                padding: const EdgeInsets.all(16),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                              : const SizedBox.shrink();
                        }
                        final report = state.collectionReportList[index];
                        final projectWings =
                            state.projectWiseReportMap[report.projectId] ?? [];

                        final isProjectLoading = state.loadingProjectIds
                            .contains(report.projectId);

                        return CustomExpandableCard(
                          onExpansionChanged: (isExpanded) {
                            if (isExpanded &&
                                !state.projectWiseReportMap.containsKey(
                                  report.projectId,
                                )) {
                              _collectionReportCubit
                                  .getDailyCollectionReportProjectWiseList(
                                    context,
                                    projectId: report.projectId,
                                    projectName: report.projectName,
                                  );
                            }
                          },
                          header: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    report.projectName,
                                    style: AppTextStyle.ts14M(
                                      color: AppColor.primary,
                                    ),
                                  ),
                                  verticalSpacing(height: 6.sp),
                                  Text(
                                    "Total Unit : ${report.totalUnit.toString()} | Total Wing : ${report.wing}",
                                    style: AppTextStyle.ts14M(
                                      color: AppColor.grey,
                                    ),
                                  ),
                                ],
                              ),
                              verticalSpacing(height: 12.sp),
                              Divider(thickness: 1.sp, color: AppColor.grey10),
                              verticalSpacing(height: 12.sp),
                              buildRowTitleValue(
                                title: "Total Agreement Value",
                                value:
                                    report.totalAgreementValue
                                        .toIndianCurrency(),
                                singleLine: false,
                              ),
                              buildRowTitleValue(
                                title: "Total Received Amount",
                                value: report.receivedAmount.toIndianCurrency(),
                                singleLine: false,
                              ),
                              verticalSpacing(height: 12.sp),
                              Divider(thickness: 1.sp, color: AppColor.grey10),
                              verticalSpacing(height: 12.sp),
                              buildRowTitleValue(
                                title: "Total Balance Amount",
                                valueTextStyle: AppTextStyle.ts14SB(
                                  color: AppColor.darkGreen10,
                                ),
                                value:
                                    report.totalAgreementValue
                                        .toIndianCurrency(),
                                singleLine: false,
                              ),
                            ],
                          ),
                          body: Builder(
                            builder: (context) {
                              if (isProjectLoading) {
                                return const Padding(
                                  padding: EdgeInsets.all(24),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }
                              if (projectWings.isEmpty) {
                                return Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Center(child: noDataWidget()),
                                );
                              }
                              final wingMap = _collectionReportCubit
                                  .groupUnitsByWing(projectWings);
                              final wingEntries = wingMap.entries.toList();

                              return ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: wingEntries.length,
                                separatorBuilder:
                                    (_, __) => verticalSpacing(height: 10.sp),
                                itemBuilder: (context, wingIndex) {
                                  final wing = wingEntries[wingIndex].key;
                                  final summary = buildWingSummary(
                                    wingEntries[wingIndex].value,
                                  );
                                  final wingKey = '${report.projectId}-$wing';

                                  return ValueListenableBuilder<String?>(
                                    valueListenable: _selectedWingKey,
                                    builder: (context, selectedKey, _) {
                                      return _buildWingTile(
                                        wingName:
                                            '$wing - ${summary.buildingNumber}',
                                        isSelected: selectedKey == wingKey,
                                        totalUnits: summary.totalUnits.toInt(),
                                        residentialUnits:
                                            summary.residentialUnits.toInt(),
                                        commercialUnits:
                                            summary.commercialUnits.toInt(),
                                        agreementAmount:
                                            summary.agreementAmount,
                                        receivedAmount: summary.receivedAmount,
                                        balanceAmount: summary.balanceAmount,
                                        onTap: () async {
                                          _selectedWingKey.value = wingKey;

                                          final selectedWingUnits =
                                              wingEntries[wingIndex].value;
                                          await goRouter.pushNamed(
                                            AppRoutes.collectionReportOverview,
                                            queryParameters: {
                                              "collectionReportProjectWiseModel":
                                                  Uri.encodeComponent(
                                                    EncryptionManager.encryptData(
                                                      jsonEncode(
                                                        selectedWingUnits
                                                            .map(
                                                              (unit) =>
                                                                  unit.toJson(),
                                                            )
                                                            .toList(),
                                                      ),
                                                    ),
                                                  ),
                                              "totalUnits":
                                                  summary.totalUnits
                                                      .toInt()
                                                      .toString(),
                                              "residentialUnits":
                                                  summary.residentialUnits
                                                      .toInt()
                                                      .toString(),
                                              "commercialUnits":
                                                  summary.commercialUnits
                                                      .toInt()
                                                      .toString(),
                                            },
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                              );
                            },
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

  Widget _buildWingTile({
    required bool isSelected,
    required String wingName,
    required int totalUnits,
    required int residentialUnits,
    required int commercialUnits,
    required double agreementAmount,
    required double receivedAmount,
    required double balanceAmount,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: EdgeInsets.all(12.sp),
      decoration: BoxDecoration(
        color: isSelected ? AppColor.lightBlue2 : AppColor.white,
        border: Border.all(
          width: 1,
          color:
              isSelected
                  ? AppColor.primary.withValues(alpha: 0.18)
                  : AppColor.grey10,
        ),
        borderRadius: BorderRadius.circular(12.sp),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onTap,
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 7.sp,
                    vertical: 4.sp,
                  ),
                  width: 24.sp,
                  height: 24.sp,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color:
                        isSelected ? AppColor.primary : AppColor.lightBlueBg2,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    wingName.isNotEmpty
                        ? wingName.substring(0, 1).toUpperCase()
                        : '',
                    style: AppTextStyle.ts12SB(
                      color: isSelected ? Colors.white : AppColor.primary,
                    ),
                  ),
                ),
                horizontalSpacing(width: 8.sp),
                Expanded(
                  child: Text(
                    wingName,
                    style: AppTextStyle.ts14M(color: AppColor.primary),
                  ),
                ),
                Icon(Icons.chevron_right, color: AppColor.primary, size: 22.sp),
              ],
            ),
          ),
          verticalSpacing(height: 12.sp),
          Text(
            "Total Units: $totalUnits (Residential: $residentialUnits | Commercial: $commercialUnits)",
            style: AppTextStyle.ts12R(color: AppColor.grey),
          ),
          verticalSpacing(height: 8.sp),
          buildRowTitleValue(
            title: "Agreement",
            value: agreementAmount.toIndianCurrency(),
            singleLine: false,
          ),
          buildRowTitleValue(
            title: "Received",
            value: receivedAmount.toIndianCurrency(),
            singleLine: false,
          ),
          Divider(thickness: 1.sp, color: AppColor.grey10),
          buildRowTitleValue(
            title: "Balance",
            value: balanceAmount.toIndianCurrency(),
            valueTextStyle: AppTextStyle.ts14SB(color: AppColor.darkGreen10),
            singleLine: false,
          ),
        ],
      ),
    );
  }
}
