import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/finalize_vendors/presentation/cubit/finalize_vendor_cubit.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/grn/presentation/cubit/grn_cubit.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/invoice/presentation/cubit/invoice_cubit.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/material_requisition/data/model/material_requisition.model.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/material_requisition/presentation/cubit/material_requisition_cubit.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/purchase_order/presentation/cubit/purchase_order_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/chip_style_tab_bar.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class MaterialRequisitionViewScreen extends StatefulWidget {
  final int materialRequisitionId;
  final int projectId;

  const MaterialRequisitionViewScreen({
    super.key,
    required this.materialRequisitionId,
    required this.projectId,
  });

  @override
  State<MaterialRequisitionViewScreen> createState() =>
      _MaterialRequisitionViewScreenState();
}

class _MaterialRequisitionViewScreenState
    extends State<MaterialRequisitionViewScreen>
    with SingleTickerProviderStateMixin {
  // TAB CONTROLLER
  late TabController _tabController;
  late MaterialRequisitionCubit _materialRequisitionCubit;
  late FinalizeVendorCubit _finalizeVendorCubit;
  late GrnCubit _grnCubit;
  late InvoiceCubit _invoiceCubit;
  late PurchaseOrderCubit _purchaseOrderCubit;
  final ValueNotifier<MaterialRequisitionModel?> materialRequisitionOverview =
      ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _tabController.addListener(_handleTabChange);
    _materialRequisitionCubit = context.read<MaterialRequisitionCubit>();
    initOverview();
  }

  void initOverview() async {
    materialRequisitionOverview.value = await _materialRequisitionCubit
        .getMaterialRequisitionDetailsById(
          context,
          1,
          widget.projectId,
          widget.materialRequisitionId,
        );
  }

  // HANDLE TAB CHANGE
  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      switch (_tabController.index) {
        case 0:
          _materialRequisitionCubit.getMaterialRequisitionDetailsById(
            context,
            1,
            widget.projectId,
            widget.materialRequisitionId,
          );
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.greyBackground,
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Material Requisition",
        authorization: AuthorizationModel(),
      ),
      body: Column(
        children: [
          ChipStyleTabBar(
            controller: _tabController,
            isSecondaryStyle: true,
            tabs: [
              'Overview',
              'Details',
              'Finalize Vendor',
              'Purchase Order',
              'GRN',
              'Invoice',
            ],
          ),
          BlocBuilder<MaterialRequisitionCubit, MaterialRequisitionState>(
            builder: (context, state) {
              return Expanded(
                child: TabBarView(
                  controller: _tabController,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    _buildOverviewTab(),
                    _buildOverviewTab(),
                    _buildOverviewTab(),
                    _buildOverviewTab(),
                    _buildOverviewTab(),
                    _buildOverviewTab(),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    if (_materialRequisitionCubit.state.isLoading ?? true) {
      return Center(child: CircularProgressIndicator());
    }
    final materialRequisition = materialRequisitionOverview.value;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),

      child: Column(
        spacing: 10,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          verticalSpacing(height: 5),
          Text(
            materialRequisition!.systemGeneratedCode,
            style: AppTextStyle.ts16SB(color: AppColor.primary),
          ),
          Container(
            decoration: commonCardDecoration(),
            padding: EdgeInsets.all(10),
            child: Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Basic Details",
                  style: AppTextStyle.ts16SB(color: AppColor.black),
                ),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Stage",
                      value: materialRequisition.materialRequisitionStage,
                    ),
                    buildColumnTitleValue(
                      title: "Document Type",
                      value: materialRequisition.materialRequisitionStage,
                    ),
                  ],
                ),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Status",
                      value: materialRequisition.materialRequisitionStatus,
                    ),
                    buildColumnTitleValue(
                      title: "Attachment",
                      value: materialRequisition.attachmentsURL.toString(),
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
}
