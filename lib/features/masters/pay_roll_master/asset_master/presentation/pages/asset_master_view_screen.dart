import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/asset_master/data/model/asset_master.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/asset_master/presentation/cubit/asset_master_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AssetMasterViewScreen extends StatefulWidget {
  final AssetMasterModel assetMaster;

  const AssetMasterViewScreen({super.key, required this.assetMaster});

  @override
  State<AssetMasterViewScreen> createState() => _AssetMasterViewScreenState();
}

class _AssetMasterViewScreenState extends State<AssetMasterViewScreen>
    with SingleTickerProviderStateMixin {
  // TAB CONtROLLER
  late TabController _tabController;

  // CUBIT
  late AssetMasterCubit _assetMasterCubit;

  @override
  void initState() {
    super.initState();
    _assetMasterCubit = context.read<AssetMasterCubit>();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // HANDLE TAB CHANGE
  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      _assetMasterCubit.onTabChanged(
        _tabController.index,
        context,
        widget.assetMaster.assetMasterId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Asset Master",
        authorization: AuthorizationModel(),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IntrinsicWidth(
                child: Container(
                  height: 35,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColor.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColor.grey.withValues(alpha: 0.2),
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    labelColor: AppColor.primary,
                    unselectedLabelColor: AppColor.grey,
                    indicator: BoxDecoration(
                      color: AppColor.lightBlue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelStyle: AppTextStyle.ts14M(),
                    unselectedLabelStyle: AppTextStyle.ts14M(),
                    labelPadding: const EdgeInsets.symmetric(horizontal: 16),
                    padding: EdgeInsets.zero,
                    tabs: const [
                      Tab(text: 'Overview'),
                      Tab(text: 'Return History'),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                physics: NeverScrollableScrollPhysics(),
                controller: _tabController,
                children: [_buildOverviewTab(), _buildReturnHistoryTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // OVERVIEW TAB
  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        spacing: 10,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: commonCardDecoration(),
            child: Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Asset Details", style: AppTextStyle.ts16SB()),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Asset Name",
                      value: widget.assetMaster.assetName,
                    ),
                    buildColumnTitleValue(
                      title: "Asset Code",
                      value: widget.assetMaster.assetCode,
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Asset Type",
                      value: widget.assetMaster.assetType,
                    ),
                    buildColumnTitleValue(
                      title: "Asset Brand",
                      value: widget.assetMaster.assetBrand,
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Asset Model",
                      value: widget.assetMaster.assetModel,
                    ),
                    buildColumnTitleValue(
                      title: "Serial Number",
                      value: widget.assetMaster.serialNumber,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            decoration: commonCardDecoration(),
            child: Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Purchase Details", style: AppTextStyle.ts16SB()),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Purchase Date",
                      value: formatDateTimeAsDDMMMYYYY(
                        widget.assetMaster.purchaseDate,
                      ),
                    ),
                    buildColumnTitleValue(
                      title: "Warranty Expiry Date",
                      value:
                          widget.assetMaster.warrantyExpiryDate != null
                              ? formatDateTimeAsDDMMMYYYY(
                                widget.assetMaster.warrantyExpiryDate!,
                              )
                              : "-",
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Supplier Name",
                      value: widget.assetMaster.supplierName,
                    ),
                    buildColumnTitleValue(
                      title: "Asset Cost",
                      value: "₹ ${widget.assetMaster.assetCost}",
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            decoration: commonCardDecoration(),
            child: Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Action Details", style: AppTextStyle.ts16SB()),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Created By",
                      value: widget.assetMaster.createdBy,
                    ),
                    buildColumnTitleValue(
                      title: "Created Date",
                      value: formatDateTimeAsDDMMMYYYY(
                        widget.assetMaster.createdDate,
                      ),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Modified By",
                      value:
                          widget.assetMaster.modifiedBy.isEmpty
                              ? "-"
                              : widget.assetMaster.modifiedBy,
                    ),
                    buildColumnTitleValue(
                      title: "Modified Date",
                      value:
                          widget.assetMaster.modifiedDate != null
                              ? formatDateTimeAsDDMMMYYYY(
                                widget.assetMaster.modifiedDate!,
                              )
                              : "-",
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // RETURN HISTORY TAB
  Widget _buildReturnHistoryTab() {
    return BlocBuilder<AssetMasterCubit, AssetMasterState>(
      builder: (context, state) {
        if (state.isLoading! && state.assetMappingList.isEmpty) {
          return loader();
        }
        if (state.assetMappingList.isEmpty) {
          return noDataWidget();
        }
        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 16,vertical: 10),
          shrinkWrap: true,
          itemCount: state.assetMappingList.length,
          itemBuilder: (_, index) {
            final assetMapping = state.assetMappingList[index];
            return Container(
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.only(bottom:10),
              decoration: commonCardDecoration(),
              child: Column(
                spacing: 10,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Asset Details",style: AppTextStyle.ts16SB(),),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(title: "Employee Name", value: assetMapping.employeeName,),
                      buildColumnTitleValue(title: "Branch", value: assetMapping.branch)
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(title: "Department", value: assetMapping.department,),
                      buildColumnTitleValue(title: "Designation", value: assetMapping.designation)
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(title: "Duration Date", value: "${formatDateTimeAsDDMMMYYYY(assetMapping.assignedDate)} to ${formatDateTimeAsDDMMMYYYY(assetMapping.returnDate!)}",),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(title: "Condition At Return", value: assetMapping.conditionOnReturn),
                    ],
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }
}
