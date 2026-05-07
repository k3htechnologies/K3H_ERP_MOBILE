import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
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
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
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
                          formatDateTimeAsDDMMMYYYY(widget.grn!.createdDate),
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
                          widget.grn!.challanNumber,
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
                          widget.grn!.challanNumber,
                        ),
                      ),
                      Expanded(
                        child: _buildRow(
                          "Remaining Requisition Amount ",
                          widget.grn!.challanNumber,
                        ),
                      ),
                    ],
                  ),
                  verticalSpacing(height: 16.h),
                  ListView.builder(
                    itemCount:
                        widget.grn?.materialRequisitionDetailGrnData.length ??
                        0,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final material =
                          widget.grn!.materialRequisitionDetailGrnData[index];
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
            ),
            verticalSpacing(height: 20.0),
            BlocBuilder<InvoiceCubit, InvoiceState>(
              builder: (context, state) {
                final invoiceDetails = state.invoiceList.first;
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
                          Expanded(
                            child: RichText(
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
                          ),
                          Expanded(
                            child: CustomButton(
                              text: "Make Payment",
                              onPressed: () {
                                goRouter.pushNamed(
                                  AppRoutes.makePaymentScreen,
                                  extra: {
                                    'systemGeneratedCode':
                                        widget.systemgeneratedCode,
                                  },
                                );
                              },
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
                          Expanded(
                            child: buildColumnTitleValue(
                              title: "Measurement Report",
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
                                      invoiceDetails.uploadInvoiceUrl.split(
                                        ",",
                                      ),
                                    );
                                  }
                                },
                                isDisable:
                                    invoiceDetails.uploadInvoiceUrl.isEmpty,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: buildColumnTitleValue(
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
                                      invoiceDetails.uploadInvoiceUrl.split(
                                        ",",
                                      ),
                                    );
                                  }
                                },
                                isDisable:
                                    invoiceDetails.uploadInvoiceUrl.isEmpty,
                              ),
                            ),
                          ),

                          horizontalSpacing(),
                          Expanded(
                            child: buildColumnTitleValue(
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
                          horizontalSpacing(),
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
