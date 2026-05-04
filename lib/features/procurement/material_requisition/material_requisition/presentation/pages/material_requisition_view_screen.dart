import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/designation_master/presentation/pages/module_access_screen.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/finalize_vendors/data/model/finalize_vendor_for_compare.model.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/finalize_vendors/presentation/cubit/finalize_vendor_cubit.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/finalize_vendors/presentation/pages/finalize_vendor_mainscreen.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/grn/presentation/cubit/grn_cubit.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/grn/presentation/pages/grn_screen.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/invoice/data/model/invoice.model.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/invoice/presentation/cubit/invoice_cubit.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/material_requisition/presentation/cubit/material_requisition_cubit.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/purchase_order/presentation/cubit/purchase_order_cubit.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/purchase_order/presentation/pages/purchase_order.screen.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
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

  final Set<int> selectedVendorIndex = {};
  FinalizeVendorForComparisonModel? selectedVendor;
  ValueNotifier<Set<int>> selectedIdsForSplit = ValueNotifier(<int>{});
  ValueNotifier<List<InvoiceModel>> invoiceList = ValueNotifier([]);
  ValueNotifier<bool> isSplit = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _tabController.addListener(_handleTabChange);
    _materialRequisitionCubit = context.read<MaterialRequisitionCubit>();
    _finalizeVendorCubit = context.read<FinalizeVendorCubit>();
    _purchaseOrderCubit = context.read<PurchaseOrderCubit>();
    _grnCubit = context.read<GrnCubit>();
    _invoiceCubit = context.read<InvoiceCubit>();
    initOverview();
  }

  void initOverview() async {
    _purchaseOrderCubit.resetState();
    _grnCubit.resetState();
    await _materialRequisitionCubit.getMaterialRequisitionDetailsById(
      context,
      1,
      widget.projectId,
      widget.materialRequisitionId,
    );
    if (mounted) {
      await _materialRequisitionCubit.getFinalizedVendor(
        context,
        widget.projectId,
        widget.materialRequisitionId,
        widget.uniquekey,
      );
      invoiceList.value = await _materialRequisitionCubit.getInvoiceForOverview(
        context: context,
        projectId: widget.projectId,
        materialRequisitionId: widget.materialRequisitionId,
        uniqueKey: widget.uniquekey,
      );
    }
  }

  // HANDLE TAB CHANGE
  void _handleTabChange() async {
    if (!_tabController.indexIsChanging) {
      switch (_tabController.index) {
        case 0:
          initOverview();
          break;
        case 2:
          _finalizeVendorCubit.getVendorForEnquiryList(
            context,
            widget.projectId,
            widget.materialRequisitionId,
            widget.uniquekey,
          );
          break;

        case 3:
          _purchaseOrderCubit.getPurchaseOrder(
            context: context,
            projectId: widget.projectId,
            materialRequisitionId: widget.materialRequisitionId,
            uniqueKey: widget.uniquekey,
          );
          break;
        case 4:
          if (_purchaseOrderCubit.state.purchaseOrderList.isEmpty) {
            showErrorMessage(context, "", "Please Generate PO");
            _tabController.animateTo(3);
            return;
          }
          _grnCubit.getAllGRNList(
            context: context,
            projectId: widget.projectId,
            materialRequisitionId: widget.materialRequisitionId,
            uniqueKey: widget.uniquekey,
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

  double get totalQuantity => _materialRequisitionCubit
      .state
      .materialRequisitionOverview!
      .materialRequisitionDetailData
      .fold(0.0, (p, e) => p + e.materialQuantity);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: selectedVendor == null,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && selectedVendor != null) {
          setState(() {
            selectedVendor = null;
          });
        }
      },
      child: Scaffold(
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
                      _buildOverviewTab(state),
                      _buildDetailsTab(state),
                      FinalizeVendorMainscreen(
                        systemgeneratedCode:
                            state
                                .materialRequisitionOverview
                                ?.systemGeneratedCode ??
                            "",
                        projectId: widget.projectId,
                        materialRequisitionId: widget.materialRequisitionId,
                        uniquekey: widget.uniquekey,
                      ),
                      PurchaseOrderScreen(
                        projectId: widget.projectId,
                        materialRequisitionId: widget.materialRequisitionId,
                        uniquekey: widget.uniquekey,
                      ),
                      GRNScreen(),
                      _buildOverviewTab(state),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab(MaterialRequisitionState state) {
    if ((_materialRequisitionCubit.state.isLoading ?? true) ||
        state.materialRequisitionOverview == null) {
      return Center(child: CircularProgressIndicator());
    }
    final materialRequisition = state.materialRequisitionOverview;
    final materialList = materialRequisition?.materialRequisitionDetailData;
    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
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
          BlocBuilder<MaterialRequisitionCubit, MaterialRequisitionState>(
            builder: (context, state) {
              if (state.finalizedVendor == null) return SizedBox.shrink();
              final vendor = state.finalizedVendor!;

              return Container(
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
                          value: vendor.vendorName,
                        ),
                        buildColumnTitleValue(
                          title: "Vendor Company",
                          value: vendor.companyName,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        buildColumnTitleValue(
                          title: "Basic Amount",
                          value: addCommasToInteger(vendor.baseTotal),
                        ),
                        buildColumnTitleValue(
                          title: "Total Tax",
                          value: addCommasToInteger(vendor.taxTotal),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        buildColumnTitleValue(
                          title: "Grand Total",
                          value: addCommasToInteger(vendor.grandTotal),
                        ),
                        buildColumnTitleValue(
                          title: "Est. Delivery",
                          value:
                              vendor.avgDeliveryDays > 0
                                  ? "${vendor.avgDeliveryDays} days"
                                  : "-",
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        buildColumnTitleValue(
                          title: "Paid Amount",
                          value: addCommasToInteger(vendor.paid),
                        ),
                        buildColumnTitleValue(
                          title: "Pending Amount",
                          value: addCommasToInteger(vendor.pendingAmount),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
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
                        value: addCommasToInteger(
                          totalQuantity,
                          withoutSign: true,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: materialList!.length == 1 ? 150 : 340,
                  child: ListView.builder(
                    shrinkWrap: true,

                    itemCount: materialList.length,
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
                            value:
                                material.remarks.isEmpty
                                    ? "-"
                                    : material.remarks,
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
          ValueListenableBuilder(
            valueListenable: invoiceList,
            builder: (context, value, child) {
              if (value.isEmpty) return SizedBox.shrink();
              return Container(
                decoration: commonCardDecoration(),
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 10,
                  children: [
                    Text(
                      "Invoice Details",
                      style: AppTextStyle.ts16SB(color: AppColor.black),
                    ),
                    SizedBox(
                      height: invoiceList.value.length == 1 ? 160.h : 340.h,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: invoiceList.value.length,
                        itemBuilder: (context, index) {
                          final invoice = invoiceList.value[index];
                          return infoCard(
                            bgColor: AppColor.white,
                            borderColor: AppColor.primary,
                            [
                              {
                                "title": "Invoice No.",
                                "value": invoice.invoiceNumber,
                              },
                              {
                                "title": "Invoice Amount",
                                "value": addCommasToInteger(
                                  invoice.invoiceAmount,
                                ),
                              },
                              {
                                "title": "Due Date",
                                "value": formatDateTimeAsDDMMMYYYY(
                                  invoice.invoiceDueDate,
                                ),
                              },
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          Container(
            padding: EdgeInsets.all(16),
            decoration: commonCardDecoration(),
            child: Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Remark",
                  style: AppTextStyle.ts16SB(color: AppColor.black),
                ),
                Text(
                  materialRequisition.remarks.isEmpty
                      ? "-"
                      : materialRequisition.remarks,
                  style: AppTextStyle.ts14M(color: AppColor.black),
                ),
              ],
            ),
          ),
          actionCardWidget(
            createdBy: materialRequisition.createdBy,
            createdDate: materialRequisition.createdDate,
            modifiedBy: materialRequisition.modifiedBy,
            modifiedDate: materialRequisition.modifiedDate,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsTab(MaterialRequisitionState state) {
    if ((_materialRequisitionCubit.state.isLoading ?? true) ||
        state.materialRequisitionOverview == null) {
      return Center(child: CircularProgressIndicator());
    }
    final materialRequisition = state.materialRequisitionOverview;
    final materialList = materialRequisition?.materialRequisitionDetailData;
    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
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
            padding: EdgeInsets.all(16),
            decoration: commonCardDecoration(),
            child: Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Material Details",
                      style: AppTextStyle.ts16SB(color: AppColor.black),
                    ),
                    if (materialRequisition.isSplit)
                      CustomButton(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 4,
                        ),
                        text: "Split",
                        onPressed: () {
                          if (isSplit.value &&
                              selectedIdsForSplit.value.isNotEmpty) {
                            // Show popup
                            DialogHelper.showCustomDialogue(
                              context,
                              title: "Split Material Entry",
                              childContent: Column(
                                spacing: 10,
                                children: [
                                  ...materialList!
                                      .where(
                                        (e) =>
                                            selectedIdsForSplit.value.contains(
                                              e.materialRequisitionDetailId,
                                            ),
                                      )
                                      .map((e) {
                                        return Row(
                                          spacing: 10,
                                          children: [
                                            CustomCheckBox(isSelected: true),
                                            Text(
                                              e.materialName,
                                              style: AppTextStyle.ts12M(),
                                            ),
                                          ],
                                        );
                                      }),
                                  CustomButton(
                                    text: "Move To New Entry",
                                    onPressed: () {
                                      _materialRequisitionCubit
                                          .splitMaterialRequisition(
                                            context: context,
                                            materialRequisitionId: 0,
                                            uniqueKey: widget.uniquekey,
                                            projectId: widget.projectId,
                                            remarks:
                                                materialRequisition.remarks,
                                            selectedIds:
                                                selectedIdsForSplit.value,
                                            materialRequisitionDetailJSON:
                                                materialList,
                                          );
                                      isSplit.value = false;
                                      selectedIdsForSplit.value = {};
                                    },
                                  ),
                                ],
                              ),
                            );
                          } else {
                            // Normal toggle
                            isSplit.value = !isSplit.value;
                          }
                        },
                      ),
                  ],
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
                        value: addCommasToInteger(
                          totalQuantity,
                          withoutSign: true,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: materialList!.length == 1 ? 150 : 340,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: materialList.length,
                    itemBuilder: (context, index) {
                      final material = materialList[index];
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 10,
                        children: [
                          ValueListenableBuilder(
                            valueListenable: isSplit,
                            builder: (context, value, child) {
                              if (!value) return SizedBox.shrink();

                              return ValueListenableBuilder(
                                valueListenable: selectedIdsForSplit,
                                builder: (context, value, child) {
                                  return CustomCheckBox(
                                    isSelected: value.contains(
                                      material.materialRequisitionDetailId,
                                    ),
                                    onChanged: (val) {
                                      final current = selectedIdsForSplit.value;

                                      if (val == true) {
                                        selectedIdsForSplit.value = {
                                          ...current,
                                          material.materialRequisitionDetailId,
                                        };
                                      } else {
                                        selectedIdsForSplit.value =
                                            current
                                                .where(
                                                  (e) =>
                                                      e !=
                                                      material
                                                          .materialRequisitionDetailId,
                                                )
                                                .toSet();
                                      }
                                    },
                                  );
                                },
                              );
                            },
                          ),
                          Expanded(
                            child: Column(
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
                                  value:
                                      material.remarks.isEmpty
                                          ? "-"
                                          : material.remarks,
                                ),
                                if (index < (materialList.length - 1))
                                  Divider(color: AppColor.grey, thickness: .3),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: EdgeInsets.all(16),
            decoration: commonCardDecoration(),
            child: Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Remark",
                  style: AppTextStyle.ts16SB(color: AppColor.black),
                ),
                Text(
                  materialRequisition.remarks,
                  style: AppTextStyle.ts14M(color: AppColor.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
