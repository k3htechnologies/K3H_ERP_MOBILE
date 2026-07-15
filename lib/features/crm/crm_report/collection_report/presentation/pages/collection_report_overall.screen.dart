import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/crm/crm_report/collection_report/data/model/collection_report_project_wise.model.dart';
import 'package:k3h_erp_app/features/crm/crm_report/collection_report/presentation/cubit/collection_report_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/chip_style_tab_bar.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class CollectionReportOverallScreen extends StatefulWidget {
  final int projectId;
  final String projectName;
  const CollectionReportOverallScreen({
    super.key,
    required this.projectName,
    required this.projectId,
  });

  @override
  State<CollectionReportOverallScreen> createState() =>
      _CollectionReportOverallScreenState();
}

class _CollectionReportOverallScreenState
    extends State<CollectionReportOverallScreen>
    with TickerProviderStateMixin {
  late CollectionReportCubit _collectionReportCubit;
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _collectionReportCubit = context.read<CollectionReportCubit>();
    _collectionReportCubit.getDailyCollectionReportProjectWiseList(
      context,
      projectId: widget.projectId,
      projectName: widget.projectName,
    );
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  List<String> _getUniqueTypes(List<CollectionReportProjectWiseModel> list) {
    return list.map((e) => e.type).where((e) => e.isNotEmpty).toSet().toList();
  }

  List<CollectionReportProjectWiseModel> _getTypeWiseData(
    List<CollectionReportProjectWiseModel> list,
    String type,
  ) {
    return list.where((e) => e.type == type).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Collection Report Overview",
        authorization: AuthorizationModel(),
      ),
      body: BlocBuilder<CollectionReportCubit, CollectionReportState>(
        builder: (context, state) {
          final reportList = state.collectionProjectReportList;

          if (state.isLoading ??
              true && state.collectionProjectReportList.isEmpty) {
            return Center(child: loader());
          }

          if (reportList.isEmpty) {
            return Center(child: noDataWidget(message: "No Data Found"));
          }

          final types = _getUniqueTypes(reportList);

          if (_tabController == null ||
              _tabController!.length != types.length) {
            _tabController?.dispose();

            _tabController = TabController(length: types.length, vsync: this);
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  widget.projectName,
                  style: AppTextStyle.ts16SB(color: AppColor.primary),
                ),
              ),
              verticalSpacing(),
              ChipStyleTabBar(
                controller: _tabController!,
                isSecondaryStyle: false,
                tabs: types,
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  physics: const NeverScrollableScrollPhysics(),
                  children:
                      types.map((type) {
                        final data = _getTypeWiseData(reportList, type);
                        final item = data.first;
                        return SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              _sectionCard(
                                title: "Total Unit Details",
                                child: TotalUnitDetailsWidget(item: item),
                              ),

                              verticalSpacing(),

                              _sectionCard(
                                title: "Registration Details",
                                child: RegistrationDetailsWidget(item: item),
                              ),

                              verticalSpacing(),

                              _sectionCard(
                                title: "Alloted / Booked Details",
                                child: AllotedBookedDetailsWidget(item: item),
                              ),

                              verticalSpacing(),

                              _sectionCard(
                                title: "Amount Details",
                                child: AmountDetailsWidget(item: item),
                              ),
                            ],
                          ),
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

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: commonCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Text(title, style: AppTextStyle.ts16SB()), child],
      ),
    );
  }
}

class TotalUnitDetailsWidget extends StatelessWidget {
  final CollectionReportProjectWiseModel item;

  const TotalUnitDetailsWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        verticalSpacing(),
        buildRowTitleValue(title: "Units", value: item.totalUnit.toString()),
        buildRowTitleValue(
          title: "RERA Carpet Area (SqFt)",
          value: item.totalUnitReraCarpetAreaSqFt.toString(),
        ),
      ],
    );
  }
}

class RegistrationDetailsWidget extends StatelessWidget {
  final CollectionReportProjectWiseModel item;

  const RegistrationDetailsWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        verticalSpacing(),
        buildRowTitleValue(
          title: "Completed",
          value: item.registrationCompleted.toString(),
        ),
        buildRowTitleValue(
          title: "Pending",
          value: item.registrationPending.toString(),
        ),
        buildRowTitleValue(title: "Count", value: "-"),
      ],
    );
  }
}

class AllotedBookedDetailsWidget extends StatelessWidget {
  final CollectionReportProjectWiseModel item;

  const AllotedBookedDetailsWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        verticalSpacing(),
        buildRowTitleValue(title: "Count", value: item.bookingCount.toString()),
        buildRowTitleValue(
          title: "RERA Carpet Area (SqFt)",
          value: item.totalReraCarpetAreaSqFt.toString(),
        ),
      ],
    );
  }
}

class AmountDetailsWidget extends StatelessWidget {
  final CollectionReportProjectWiseModel item;

  const AmountDetailsWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        verticalSpacing(),
        buildRowTitleValue(
          title: "Agreement",
          value: item.totalAgreementValue.toIndianCurrency(),
        ),
        buildRowTitleValue(
          title: "Due",
          value: item.dueAmount.toIndianCurrency(),
        ),
        buildRowTitleValue(
          title: "Received",
          value: item.receivedAmount.toIndianCurrency(),
        ),
        buildRowTitleValue(
          title: "Outstanding",
          value: item.outstandingAmount.toIndianCurrency(),
        ),
        buildRowTitleValue(
          title: "Balance",
          value: item.balanceAmount.toIndianCurrency(),
        ),
      ],
    );
  }
}
