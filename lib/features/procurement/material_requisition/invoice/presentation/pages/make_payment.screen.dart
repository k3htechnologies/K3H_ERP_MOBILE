import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/core/cubit/utils_cubit.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/grn/data/model/grn.model.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/invoice/presentation/cubit/invoice_cubit.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/material_requisition/presentation/cubit/material_requisition_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/approve_reject_widget.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class MakePaymentScreen extends StatefulWidget {
  final String systemgeneratedCode;
  final GRNModel? grn;
  const MakePaymentScreen({
    super.key,
    required this.systemgeneratedCode,
    this.grn,
  });

  @override
  State<MakePaymentScreen> createState() => _MakePaymentScreenState();
}

class _MakePaymentScreenState extends State<MakePaymentScreen> {
  late InvoiceCubit _invoiceCubit;
  late MaterialRequisitionCubit _materialRequisitionCubit;
  late ProjectModel _selectedProject;
  
  @override
  void initState() {
    super.initState();
    _invoiceCubit = context.read<InvoiceCubit>();
    _materialRequisitionCubit = context.read<MaterialRequisitionCubit>();
    _selectedProject = getProject();
    _invoiceCubit.getInvoice(
      projectId: _selectedProject.projectId,
      materialRequisitionId:
          _materialRequisitionCubit
              .state
              .materialRequisitionOverview!
              .materialRequisitionId,
      uniqueKey:
          _materialRequisitionCubit
              .state
              .materialRequisitionOverview!
              .uniquekey,
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Payment",
        authorization: AuthorizationModel(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.systemgeneratedCode,
              style: AppTextStyle.ts16M(color: AppColor.primary),
            ),
            verticalSpacing(),
            BlocBuilder<InvoiceCubit, InvoiceState>(
              builder: (context, state) {
                if (state.isLoading ?? true) {
                  return Center(child: loader());
                }
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 12.0,
                  ),
                  decoration: BoxDecoration(
                    color: AppColor.lightBluebg,
                    boxShadow: [
                      BoxShadow(
                        color: AppColor.black.withValues(alpha: 0.05),
                        blurRadius: 2,
                        spreadRadius: 0,
                        offset: Offset(0, 2),
                      ),
                      BoxShadow(
                        color: AppColor.black.withValues(alpha: 0.0),
                        blurRadius: 0,
                        spreadRadius: 0,
                        offset: Offset(0, 2),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: _buildRow(
                              "Date",
                              formatDateTimeAsDDMMMYYYY(
                                widget.grn!.createdDate,
                              ),
                            ),
                          ),
                          Expanded(
                            child: _buildRow(
                              "Vehicle No.",
                              widget.grn!.vehicleNumber,
                            ),
                          ),
                        ],
                      ),
                      verticalSpacing(height: 16.h),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: _buildRow(
                              "Challan No.",
                              widget.grn!.challanNumber,
                            ),
                          ),
                          Expanded(
                            child: _buildRow(
                              "Total Requisition Amount",
                              state.invoiceList.first.invoiceAmount.toString(),
                            ),
                          ),
                        ],
                      ),
                      verticalSpacing(height: 16.h),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: _buildRow(
                              "Paid  Requisition Amount",
                              state.invoiceList.first.invoiceAmountPaidTillDate
                                  .toString(),
                            ),
                          ),
                          Expanded(
                            child: _buildRow(
                              "Remaining Requisition Amount ",
                              (state.invoiceList.first.invoiceAmount -
                                      state
                                          .invoiceList
                                          .first
                                          .invoiceAmountPaidTillDate)
                                  .toStringAsFixed(2),
                            ),
                          ),
                        ],
                      ),
                      verticalSpacing(height: 16.h),
                      ListView.builder(
                        itemCount:
                            widget
                                .grn
                                ?.materialRequisitionDetailGrnData
                                .length ??
                            0,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final material =
                              widget
                                  .grn!
                                  .materialRequisitionDetailGrnData[index];
                          return Container(
                            margin: EdgeInsets.only(bottom: 10.0),
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.0,
                              vertical: 12.0,
                            ),
                            decoration: BoxDecoration(
                              color: AppColor.lightGreyBackground,
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(
                                width: 0.1,
                                color: AppColor.black.withValues(alpha: 0.5),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: _buildRow(
                                    "Material",
                                    material.materialName,
                                  ),
                                ),
                                Expanded(
                                  child: _buildRow(
                                    "Sub-Material",
                                    material.subMaterialName,
                                  ),
                                ),
                                Expanded(
                                  child: _buildRow(
                                    "Quantity",
                                    material.materialQuantity.toString(),
                                  ),
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
            ),
            verticalSpacing(height: 20.0),
            BlocBuilder<InvoiceCubit, InvoiceState>(
              builder: (context, state) {
                final invoiceDetails = state.invoiceList.first;
                final invoice = state.invoiceList.first;

                final isApproved =
                    invoice.invoiceStatus.toLowerCase() == "approved";
                final approvalStatus = invoice.invoiceStatus;
                final isActionCompleted =
                    approvalStatus.toLowerCase() == "approved" ||
                    approvalStatus.toLowerCase() == "rejected" ||
                    !invoice.isApproval;
                final hasPayment = invoice.invoiceAmountPaidTillDate > 0;
                final makePayment =
                    (invoice.invoiceAmountPaidTillDate != invoice.invoiceAmount);
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 16.0,
                  ),
                  decoration: commonCardDecoration(),
                  child: Column(
                    spacing: 10.0,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "Invoice No.",
                                  style: AppTextStyle.ts14R(
                                    color: AppColor.black.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                ),
                                TextSpan(
                                  text: ": ",
                                  style: AppTextStyle.ts14R(
                                    color: AppColor.black.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                ),
                                TextSpan(
                                  text: invoiceDetails.invoiceNumber,
                                  style: AppTextStyle.ts14R(
                                    color: AppColor.black.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildInvoiceDetailsColumn(
                            "Due Date",
                            formatDateTimeAsDDMMMYYYY(
                              invoiceDetails.invoiceDueDate,
                            ),
                          ),
                          horizontalSpacing(),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: _buildInvoiceDetailsColumn(
                              "Invoice Amount",
                              invoiceDetails.invoiceAmount.toString(),
                            ),
                          ),
                          horizontalSpacing(),
                          Expanded(
                            child: _buildInvoiceDetailsColumn(
                              "Invoice Date",
                              formatDateTimeAsDDMMMYYYY(
                                invoiceDetails.invoiceDate,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          buildColumnTitleValue(
                            title: "Measurement Report",
                            value:
                                invoiceDetails.measurementReportUrl.isEmpty
                                    ? "-"
                                    : invoiceDetails.measurementReportUrl,
                            customValueWidget: CustomButton.documentOutline(
                              onPressed: () {
                                if (invoiceDetails
                                    .measurementReportUrl
                                    .isNotEmpty) {
                                  showFilePreviewDialog(
                                    context,
                                    invoiceDetails.measurementReportUrl.split(
                                      ",",
                                    ),
                                  );
                                }
                              },
                              isDisable:
                                  invoiceDetails.measurementReportUrl.isEmpty,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          buildColumnTitleValue(
                            title: "Invoice Document",
                            value:
                                invoiceDetails.uploadInvoiceUrl.isEmpty
                                    ? "-"
                                    : invoiceDetails.uploadInvoiceUrl,
                            customValueWidget: CustomButton.documentOutline(
                              onPressed: () {
                                if (invoiceDetails
                                    .uploadInvoiceUrl
                                    .isNotEmpty) {
                                  showFilePreviewDialog(
                                    context,
                                    invoiceDetails.uploadInvoiceUrl.split(","),
                                  );
                                }
                              },
                              isDisable:
                                  invoiceDetails.uploadInvoiceUrl.isEmpty,
                            ),
                          ),

                          horizontalSpacing(),
                          buildColumnTitleValue(
                            title: "Performance Report",
                            value:
                                invoiceDetails.performaInvoiceUrl.isEmpty
                                    ? "-"
                                    : invoiceDetails.performaInvoiceUrl,
                            customValueWidget: CustomButton.documentOutline(
                              onPressed: () {
                                if (invoiceDetails
                                    .performaInvoiceUrl
                                    .isNotEmpty) {
                                  showFilePreviewDialog(
                                    context,
                                    invoiceDetails.performaInvoiceUrl.split(
                                      ",",
                                    ),
                                  );
                                }
                              },
                              isDisable:
                                  invoiceDetails.uploadInvoiceUrl.isEmpty,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildInvoiceDetailsColumn(
                            "Remark",
                            invoiceDetails.remarks.isEmpty
                                ? "-"
                                : invoiceDetails.remarks,
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          if (isApproved) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                /// VIEW PAYMENT
                                if (hasPayment)
                                  Expanded(
                                    child: CustomButton(
                                      text: "View Payment",
                                      backgroundColor: AppColor.lightBlue,
                                      textColor: AppColor.primary,
                                      onPressed: () {
                                        goRouter.pushNamed(
                                          AppRoutes.viewPayment,
                                          extra: {
                                            'systemGeneratedCode':
                                                widget.systemgeneratedCode,
                                            'invoiceNumber':
                                                invoice.invoiceNumber,
                                          },
                                        );
                                      },
                                    ),
                                  ),

                                if (hasPayment) horizontalSpacing(),

                                /// MAKE PAYMENT
                                if (makePayment)
                                  Expanded(
                                    child: CustomButton(
                                      text: "Make Payment",
                                      onPressed: () {
                                        goRouter.pushNamed(
                                          AppRoutes.makePaymentScreen,
                                          extra: {
                                            'systemGeneratedCode':
                                                widget.systemgeneratedCode,
                                            "grn": widget.grn,
                                          },
                                        );
                                      },
                                    ),
                                  ),
                              ],
                            ),
                          ],
                          verticalSpacing(),
                          ApproveRejectWidget(
                            isActionAlreadyPerformed: isActionCompleted,
                            actionTitle: approvalStatus,

                            onApprove: (remark) async {
                              final isSuccess = await context
                                  .read<UtilsCubit>()
                                  .updateModulesWorkflowApproval(
                                    context: context,
                                    moduleName: 'MATERIAL REQUISITION',
                                    id: invoice.materialRequisitionId,
                                    subId: invoice.materialRequisitionInvoiceId,
                                    projectId: _selectedProject.projectId,
                                    isApproved: true,
                                    remark: remark.trim(),
                                  );

                              if (context.mounted && isSuccess) {
                                await _invoiceCubit.getInvoice(
                                  projectId: _selectedProject.projectId,
                                  materialRequisitionId:
                                      _materialRequisitionCubit
                                          .state
                                          .materialRequisitionOverview!
                                          .materialRequisitionId,
                                  uniqueKey:
                                      _materialRequisitionCubit
                                          .state
                                          .materialRequisitionOverview!
                                          .uniquekey,
                                  context: context,
                                );
                              }
                            },

                            onReject: (remark) async {
                              await context
                                  .read<UtilsCubit>()
                                  .updateModulesWorkflowApproval(
                                    context: context,
                                    moduleName: 'MATERIAL REQUISITION',
                                    id: invoice.materialRequisitionId,
                                    subId: invoice.materialRequisitionInvoiceId,
                                    projectId: _selectedProject.projectId,
                                    isApproved: false,
                                    remark: remark.trim(),
                                  );
                            },

                            onThirdTap: () async {
                              final approvalLogHistoryList = await context
                                  .read<UtilsCubit>()
                                  .getApprovalLogHistory(
                                    context: context,
                                    projectId: _selectedProject.projectId,
                                    id: invoice.materialRequisitionId,
                                    subId: invoice.materialRequisitionInvoiceId,
                                    moduleName: 'ADD INVOICE',
                                  );
                              if (context.mounted) {
                                goRouter.pushNamed(
                                  AppRoutes.approvalLogHistory,
                                  queryParameters: {
                                    "title": Uri.encodeComponent(
                                      EncryptionManager.encryptData(
                                        "Invoice Log History",
                                      ),
                                    ),
                                    "approvalList": Uri.encodeComponent(
                                      EncryptionManager.encryptData(
                                        jsonEncode(
                                          approvalLogHistoryList
                                              .map((e) => e.toJson())
                                              .toList(),
                                        ),
                                      ),
                                    ),
                                  },
                                );
                              }
                            },

                            popupTitle: "Invoice",
                            isMaster: true,
                          ),
                        ],
                      ),
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

  Widget _buildInvoiceDetailsColumn(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyle.ts14R(
            color: AppColor.black.withValues(alpha: 0.5),
          ),
        ),
        Text(value, style: AppTextStyle.ts14M()),
      ],
    );
  }

  Widget _buildRow(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyle.ts14R(
            color: AppColor.black.withValues(alpha: 0.5),
          ),
        ),
        verticalSpacing(height: 6.0),
        Text(value, style: AppTextStyle.ts14M(color: AppColor.black)),
      ],
    );
  }
}
