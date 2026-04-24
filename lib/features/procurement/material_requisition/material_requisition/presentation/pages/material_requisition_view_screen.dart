import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/designation_master/presentation/pages/module_access_screen.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/finalize_vendors/data/model/finalize_vendor.model.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/finalize_vendors/data/model/finalize_vendor_for_compare.model.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/finalize_vendors/presentation/cubit/finalize_vendor_cubit.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/finalize_vendors/presentation/pages/finalize_vendor_get_quotation.screen.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/grn/presentation/cubit/grn_cubit.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/invoice/presentation/cubit/invoice_cubit.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/material_requisition/data/model/material_requisition.model.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/material_requisition/presentation/cubit/material_requisition_cubit.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/purchase_order/presentation/cubit/purchase_order_cubit.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
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
  final ValueNotifier<MaterialRequisitionModel?> materialRequisitionOverview =
      ValueNotifier(null);
  final ValueNotifier<RequisitionVendorModel?> finalizedVendor = ValueNotifier(
    null,
  );

  final ValueNotifier<List<dynamic>> selectedVendorList = ValueNotifier([]);
  final Set<int> selectedVendorIndex = {};
  FinalizeVendorForComparisonModel? selectedVendor;
  ValueNotifier<Set<int>> selectedIdsForSplit = ValueNotifier(<int>{});
  ValueNotifier<bool> isSplit = ValueNotifier(false);

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
      finalizedVendor.value = await _materialRequisitionCubit
          .getFinalizedVendor(
            context,
            widget.projectId,
            widget.materialRequisitionId,
            widget.uniquekey,
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
        case 1:
          materialRequisitionOverview.value = await _materialRequisitionCubit
              .getMaterialRequisitionDetailsById(
                context,
                1,
                widget.projectId,
                widget.materialRequisitionId,
              );
          break;
        case 2:
          _finalizeVendorCubit.getVendorForEnquiryList(
            context,
            widget.projectId,
            widget.materialRequisitionId,
            widget.uniquekey,
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
                      _buildDetailsTab(),
                      FinalizeVendorGetQuotationScreen(
                        systemgeneratedCode:
                            materialRequisitionOverview
                                .value
                                ?.systemGeneratedCode ??
                            "",
                        projectId: widget.projectId,
                        materialRequisitionId: widget.materialRequisitionId,
                        uniquekey: widget.uniquekey,
                      ),
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
          if (finalizedVendor.value != null)
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
                        value: finalizedVendor.value!.vendorName,
                      ),
                      buildColumnTitleValue(
                        title: "Vendor Company",
                        value: finalizedVendor.value!.companyName,
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
                  height: materialList!.length == 1 ? 150 : 340,
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

  Widget _buildDetailsTab() {
    if (_materialRequisitionCubit.state.isLoading ?? true) {
      return Center(child: CircularProgressIndicator());
    }
    final materialRequisition = materialRequisitionOverview.value;
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
          if (finalizedVendor.value != null)
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
                        value: finalizedVendor.value!.vendorName,
                      ),
                      buildColumnTitleValue(
                        title: "Vendor Company",
                        value: finalizedVendor.value!.companyName,
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
                                            remarks: "",
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
                        value: totalQuantity.toString(),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: materialList!.length == 1 ? 150 : 340,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: materialList!.length,
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
                                  value: material.remarks,
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
}
