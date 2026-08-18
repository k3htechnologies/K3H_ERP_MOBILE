import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/crm/crm_report/collection_report/presentation/cubit/collection_report_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_export_button.dart';
import 'package:k3h_erp_app/widgets/app_bar/search_widget.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class CollectionReportScreen extends StatefulWidget {
  const CollectionReportScreen({super.key});

  @override
  State<CollectionReportScreen> createState() => _CollectionReportScreenState();
}

class _CollectionReportScreenState extends State<CollectionReportScreen> {
  late CollectionReportCubit _collectionReportCubit;
  late TextEditingController _searchC;

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
                                    AppRoutes.collectionReportOverview,
                                    queryParameters: {
                                      'projectId': report.projectId.toString(),
                                      'projectName': Uri.encodeComponent(
                                        EncryptionManager.encryptData(
                                          report.projectName,
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  buildColumnTitleValue(
                                    title: "Total Unit",
                                    value: report.totalUnit.toString(),
                                  ),
                                  buildColumnTitleValue(
                                    title: "Total Agreement Value",
                                    value:
                                        report.totalAgreementValue
                                            .toIndianCurrency(),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  buildColumnTitleValue(
                                    title: "Total Received Amount",
                                    value:
                                        report.receivedAmount
                                            .toIndianCurrency(),
                                  ),
                                  buildColumnTitleValue(
                                    title: "Total Balance Amount",
                                    value:
                                        report.balanceAmount.toIndianCurrency(),
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
