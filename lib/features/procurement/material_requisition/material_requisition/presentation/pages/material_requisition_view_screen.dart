import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/finalize_vendors/data/model/finalize_vendor.model.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/finalize_vendors/data/model/finalize_vendor_for_compare.model.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/finalize_vendors/presentation/cubit/finalize_vendor_cubit.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/grn/presentation/cubit/grn_cubit.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/invoice/presentation/cubit/invoice_cubit.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/material_requisition/data/model/material_requisition.model.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/material_requisition/presentation/cubit/material_requisition_cubit.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/purchase_order/presentation/cubit/purchase_order_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/chip_style_tab_bar.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class MaterialRequisitionViewScreen extends StatefulWidget {
  final int materialRequisitionId;
  final int projectId;
  final String uniquekey;

  const MaterialRequisitionViewScreen({
    super.key,
    required this.materialRequisitionId,
    required this.projectId,
    required this.uniquekey,
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
  final ValueNotifier<RequisitionVendorModel?> vendorList = ValueNotifier(null);

  final ValueNotifier<List<dynamic>> selectedVendorList = ValueNotifier([]);
  final Set<int> selectedVendorIndex = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _tabController.addListener(_handleTabChange);
    _materialRequisitionCubit = context.read<MaterialRequisitionCubit>();
    _finalizeVendorCubit = context.read<FinalizeVendorCubit>();
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
    if (mounted) {
      vendorList.value = await _materialRequisitionCubit.getFinalizedVendor(
        context,
        widget.projectId,
        widget.materialRequisitionId,
        widget.uniquekey,
      );
    }
    // if (materialRequisitionOverview.value?.uniquekey != null &&
    //     materialRequisitionOverview.value!.uniquekey.isNotEmpty) {
    //   final vendors = await _finalizeVendorCubit.getSelectedVenodeForCompare(
    //     context,
    //     widget.projectId,
    //     widget.materialRequisitionId,
    //     materialRequisitionOverview.value!.uniquekey,
    //   );

    //   selectedVendorList.value = vendors;
    // } else {
    //   selectedVendorList.value = [];
    // }
  }

  void _toggleVendorSelection(int index) {
    setState(() {
      if (selectedVendorIndex.contains(index)) {
        selectedVendorIndex.remove(index);
      } else {
        selectedVendorIndex.add(index);
      }
    });
  }

  bool _isSelected(int index) {
    return selectedVendorIndex.contains(index);
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
          break;
        case 2:
          _finalizeVendorCubit.getSelectedVenodeForCompare(
            context,
            widget.projectId,
            widget.materialRequisitionId,
            materialRequisitionOverview.value?.uniquekey ?? "",
          );
          break;
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  double get totalQuantity => materialRequisitionOverview
      .value!
      .materialRequisitionDetailData
      .fold(0.0, (p, e) => p + e.materialQuantity);

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
                    _buildFinalizedVendor(),
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
    final materialList = materialRequisition?.materialRequisitionDetailData;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
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
            padding: EdgeInsets.all(16),
            child: Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Basic Details",
                  style: AppTextStyle.ts16SB(color: AppColor.black),
                ),
                Row(
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Status",
                      value: materialRequisition.materialRequisitionStatus,
                    ),
                    buildColumnTitleValue(
                      title: "Attachment",
                      value: materialRequisition.attachmentsURL.toString(),
                      customValueWidget: CustomButton.documentOutline(
                        onPressed: () {
                          if (materialRequisition.attachmentsURL.isNotEmpty) {
                            showFilePreviewDialog(
                              context,
                              materialRequisition.attachmentsURL.split(","),
                            );
                          }
                        },
                        isDisable: materialRequisition.attachmentsURL.isEmpty,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            decoration: commonCardDecoration(),
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [
                Text(
                  "Vendor And Amount Details",
                  style: AppTextStyle.ts16SB(color: AppColor.black),
                ),
                Row(
                  children: [
                    buildColumnTitleValue(
                      title: "Vendor Name",
                      value: "dsmkld",
                    ),
                    buildColumnTitleValue(
                      title: "Vendor Company",
                      value: "ABC",
                    ),
                  ],
                ),
                Row(
                  children: [
                    buildColumnTitleValue(
                      title: "Basic Amount",
                      value: addCommasToInteger(1000),
                    ),
                    buildColumnTitleValue(
                      title: "Total Tax",
                      value: addCommasToInteger(1000.50),
                    ),
                  ],
                ),
                Row(
                  children: [
                    buildColumnTitleValue(
                      title: "Grand Total",
                      value: addCommasToInteger(1000),
                    ),
                    buildColumnTitleValue(
                      title: "Est. Delivery",
                      value: "12 Days",
                    ),
                  ],
                ),
                Row(
                  children: [
                    buildColumnTitleValue(
                      title: "Paid Amount",
                      value: addCommasToInteger(1000),
                    ),
                    buildColumnTitleValue(
                      title: "Pending Amount",
                      value: addCommasToInteger(1000.50),
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
                Text(
                  "Material Details",
                  style: AppTextStyle.ts16SB(color: AppColor.black),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.r),
                    color: AppColor.grey10,
                  ),
                  padding: EdgeInsets.all(10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "Total Material",
                        value:
                            materialRequisition
                                .materialRequisitionDetailData
                                .length
                                .toString(),
                      ),
                      buildColumnTitleValue(
                        title: "Total Quantity",
                        value: totalQuantity.toString(),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    shrinkWrap: true,

                    itemCount: materialList!.length,
                    itemBuilder: (context, index) {
                      final material = materialList[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildRowTitleValue(
                            title: "Material Name",
                            value: material.materialName,
                          ),
                          buildRowTitleValue(
                            title: "Sub-Material",
                            value: material.subMaterialName,
                          ),
                          buildRowTitleValue(
                            title: "Quantity",
                            value: addCommasToInteger(
                              material.materialQuantity,
                              withoutSign: true,
                            ),
                          ),
                          buildRowTitleValue(
                            title: "Remark",
                            value: material.remarks,
                          ),
                          if (index < (materialList.length - 1))
                            Divider(color: AppColor.grey, thickness: .3),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinalizedVendor() {
    if (_finalizeVendorCubit.state.isLoading ?? true) {
      return Center(child: CircularProgressIndicator());
    }
    final finalizeVendor = materialRequisitionOverview.value;
    final vendorForFinalize =
        _finalizeVendorCubit.state.vendorFinalisationForComparison;

    return ValueListenableBuilder(
      valueListenable: selectedVendorList,
      builder: (context, value, child) {
        return Container(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      finalizeVendor?.systemGeneratedCode.toString() ?? "",
                      style: AppTextStyle.ts16M(color: AppColor.primary),
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(bottom: 12),
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 6.0,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6.0),
                          color: AppColor.green.withValues(alpha: 0.14),
                        ),
                        child: Text(
                          "Finalize Vendor",
                          style: AppTextStyle.ts14M(color: AppColor.green),
                        ),
                      ),
                      horizontalSpacing(width: 8.h),
                      SvgPicture.asset(
                        AppAssets.compareVendorIcon,
                        height: 24.h,
                        width: 24.w,
                      ),
                    ],
                  ),
                ],
              ),
              verticalSpacing(height: 10.h),
              ListView.builder(
                itemCount: vendorForFinalize.length,
                shrinkWrap: true,
                physics: AlwaysScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final vendor = vendorForFinalize[index];
                  final vedorQuotationOfSelecetdVendor =
                      vendor.materialRequisitionQuotationTermsData[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: 12),
                    padding: EdgeInsets.all(16),
                    decoration: commonCardDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// HEADER
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    _toggleVendorSelection(index);
                                  },
                                  child: Container(
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color:
                                            _isSelected(index)
                                                ? AppColor.primary
                                                : AppColor.primary.withValues(
                                                  alpha: 0.4,
                                                ),
                                        width: 2,
                                      ),
                                      color:
                                          _isSelected(index)
                                              ? AppColor.primary.withValues(
                                                alpha: 0.2,
                                              )
                                              : Colors.transparent,
                                    ),
                                    child:
                                        _isSelected(index)
                                            ? Icon(
                                              Icons.check,
                                              size: 14,
                                              color: AppColor.primary,
                                            )
                                            : null,
                                  ),
                                ),
                                horizontalSpacing(width: 10.w),
                                Text(
                                  vendor.companyName,
                                  style: AppTextStyle.ts16M(
                                    color: AppColor.primary,
                                  ),
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap:
                                  () => copy(
                                    context: context,
                                    text: "Text Copied",
                                  ),
                              child: Icon(
                                Icons.copy,
                                color: AppColor.primary,
                                size: 20,
                              ),
                            ),
                          ],
                        ),

                        verticalSpacing(height: 12),

                        /// DETAILS
                        _buildRow("Company Name", vendor.companyName),
                        _buildRow(
                          "Base Amount",
                          "₹${vedorQuotationOfSelecetdVendor.total.toInt()}",
                        ),

                        _buildRow(
                          "Total Tax",
                          "₹${_calculateTax(vendor)}",
                          valueColor: Colors.orange,
                        ),

                        _buildRow(
                          "Grand Total",
                          "₹${_calculateGrandTotal(vendor)}",
                          valueColor: AppColor.primary,
                        ),

                        _buildRow(
                          "Est. Delivery",
                          "${vendor.materialRequisitionQuotationTermsData.first.expectedDeliveryInDays} Days",
                          valueColor: Colors.green,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRow(String title, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              title,
              style: AppTextStyle.ts14R(
                color: AppColor.black.withValues(alpha: 0.5),
              ),
            ),
          ),
          Text(
            ":   ",
            style: AppTextStyle.ts14R(
              color: AppColor.black.withValues(alpha: 0.5),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyle.ts14M(color: valueColor ?? AppColor.black),
            ),
          ),
        ],
      ),
    );
  }

  int _calculateTax(FinalizeVendorForComparisonModel vendor) {
    final terms = vendor.materialRequisitionQuotationTermsData;

    if (terms.isEmpty) return 0;

    final total = terms.first.total;
    final base = total - 4000; // 🔥 Replace with actual logic if API gives tax

    return (total - base).toInt();
  }

  int _calculateGrandTotal(FinalizeVendorForComparisonModel vendor) {
    final terms = vendor.materialRequisitionQuotationTermsData;

    if (terms.isEmpty) return 0;

    return terms.first.total.toInt();
  }
}
