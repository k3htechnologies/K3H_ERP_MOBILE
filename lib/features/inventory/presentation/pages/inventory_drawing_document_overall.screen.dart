import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/inventory/data/model/building.model.dart';
import 'package:k3h_erp_app/features/project_document/drawing_document/data/model/inventory_drawing_document.model.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/section_card.dart';
import 'package:k3h_erp_app/widgets/status/status.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class InventoryDrawingDocumentOverallScreen extends StatefulWidget {
  final FlatModel? flatModel;
  final List<InventoryDrawingDocumentModel>? inventoryDrawingDocumentModel;
  const InventoryDrawingDocumentOverallScreen({
    super.key,
    this.inventoryDrawingDocumentModel,
    this.flatModel,
  });

  @override
  State<InventoryDrawingDocumentOverallScreen> createState() =>
      _InventoryDrawingDocumentOverallScreenState();
}

class _InventoryDrawingDocumentOverallScreenState
    extends State<InventoryDrawingDocumentOverallScreen> {
  @override
  Widget build(BuildContext context) {
    final documents =
        widget.inventoryDrawingDocumentModel ??
        <InventoryDrawingDocumentModel>[];

    final flat = widget.flatModel;
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Inventory Drawing Document",
        authorization: AuthorizationModel(),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              showSiteSelectedWidget(),
              verticalSpacing(),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: flat!.buildingNumber,
                      style: AppTextStyle.ts12M(color: AppColor.grey),
                    ),
                    TextSpan(
                      text: " : ",
                      style: AppTextStyle.ts14M(color: AppColor.grey),
                    ),
                    TextSpan(
                      text: flat.wing,
                      style: AppTextStyle.ts12M(color: AppColor.black),
                    ),
                    TextSpan(
                      text: " > ",
                      style: AppTextStyle.ts12M(color: AppColor.grey),
                    ),
                    TextSpan(
                      text: flat.floor,
                      style: AppTextStyle.ts12M(color: AppColor.black),
                    ),
                    TextSpan(
                      text: " > ",
                      style: AppTextStyle.ts12M(color: AppColor.grey),
                    ),
                    TextSpan(
                      text:
                          widget
                              .inventoryDrawingDocumentModel!
                              .first
                              .drawingDocumentCategory,
                      style: AppTextStyle.ts12M(color: AppColor.black),
                    ),
                  ],
                ),
              ),
              verticalSpacing(),
              Expanded(
                child:
                    documents.isEmpty
                        ? const Center(
                          child: Text('No drawing documents found'),
                        )
                        : ListView.builder(
                          itemCount: documents.length,
                          itemBuilder: (context, index) {
                            final document = documents[index];

                            final documentTitle =
                                document.drawingDocumentName
                                    .split('~')
                                    .first
                                    .trim();
                            final hasDwg =
                                document.drawingDocumentDwgurl
                                    .trim()
                                    .isNotEmpty;
                            final hasPdf =
                                document.drawingDocumentUrl.trim().isNotEmpty;

                            return SectionCard(
                              title: documentTitle,
                              titleTextColor: AppColor.black,
                              headerBackgroundColor: Color(0xffF9F9FF),
                              border: Border.all(
                                color: AppColor.grey.withValues(alpha: 0.3),
                                width: 1,
                              ),
                              children: [
                                buildRowTitleValue(
                                  title: "Version",
                                  value:
                                      document.drawingDocumentName.contains('~')
                                          ? document.drawingDocumentName
                                              .split('~')
                                              .last
                                              .trim()
                                          : '-',
                                ),

                                buildRowTitleValue(
                                  title: "Type",
                                  value: [
                                    if (hasPdf) 'PDF',
                                    if (hasDwg) 'DWG',
                                  ].join(', '),
                                  customValueWidget: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (hasPdf) ...[
                                        buildDocumentTypeChip(
                                          label: 'PDF',
                                          backgroundColor: AppColor.lightRed,
                                          textColor:
                                              AppColor.missingInformationRed,
                                          onTap: () {
                                            final pdfUrls =
                                                document.drawingDocumentUrl
                                                    .split(',')
                                                    .map((url) => url.trim())
                                                    .where(
                                                      (url) => url.isNotEmpty,
                                                    )
                                                    .toList();

                                            if (pdfUrls.isNotEmpty) {
                                              showFilePreviewDialog(
                                                context,
                                                pdfUrls,
                                                title:
                                                    document
                                                        .drawingDocumentName,
                                              );
                                            }
                                          },
                                        ),
                                        if (hasDwg) const SizedBox(width: 8),
                                      ],
                                      if (hasDwg)
                                        buildDocumentTypeChip(
                                          label: 'DWG',
                                          backgroundColor: const Color(
                                            0xFFDCEBFF,
                                          ),
                                          textColor: const Color(0xFF0057D9),
                                          onTap: () {
                                            final dwgUrls =
                                                document.drawingDocumentDwgurl
                                                    .split(',')
                                                    .map((url) => url.trim())
                                                    .where(
                                                      (url) => url.isNotEmpty,
                                                    )
                                                    .toList();

                                            if (dwgUrls.isNotEmpty) {
                                              showFilePreviewDialog(
                                                context,
                                                dwgUrls,
                                                title:
                                                    document
                                                        .drawingDocumentName,
                                              );
                                            }
                                          },
                                        ),
                                    ],
                                  ),
                                ),

                                buildRowTitleValue(
                                  title: "Revision Date",
                                  value: formatDateTimeAsDDMMMYYYY(
                                    document.drawingDocumentRevisionDate,
                                  ),
                                ),
                                buildRowTitleValue(
                                  title: "Status",
                                  value: document.drawingDocumentStatus,
                                  customValueWidget:
                                      drawingDocumentStatusWidget(
                                        document.drawingDocumentStatus,
                                      ),
                                ),
                                buildRowTitleValue(
                                  title: "Remark",
                                  value:
                                      document.drawingDocumentRemark
                                              .trim()
                                              .isEmpty
                                          ? "-"
                                          : document.drawingDocumentRemark
                                              .trim(),
                                  customValueWidget:
                                      document.drawingDocumentRemark
                                              .trim()
                                              .isNotEmpty
                                          ? GestureDetector(
                                            onTap: () {
                                              DialogHelper.showNoteDialog(
                                                context,
                                                note:
                                                    document
                                                        .drawingDocumentRemark,
                                                title: "Remark",
                                              );
                                            },
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                left: 10.w,
                                              ),
                                              child: Icon(
                                                Icons.info_outline,
                                                size: 18,
                                                color: AppColor.primary,
                                              ),
                                            ),
                                          )
                                          : null,
                                  singleLine: false,
                                ),
                                buildRowTitleValue(
                                  title: "Approval Status",
                                  value: document.approvalStatus,
                                  customValueWidget:
                                      document.approvalStatus.isNotEmpty
                                          ? approvalStatusWidget(
                                            document.approvalStatus,
                                          )
                                          : null,
                                ),
                                buildRowTitleValue(
                                  title: "Last Modified By",
                                  value: document.createdBy,
                                  singleLine: false,
                                ),
                                buildRowTitleValue(
                                  title: "Last Modified Date",
                                  value: formatDateTimeAsDDMMMYYYY(
                                    document.createdDate,
                                  ),
                                  singleLine: false,
                                ),
                              ],
                            );
                          },
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDocumentTypeChip({
    required String label,
    required Color backgroundColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: AppTextStyle.ts12M(color: textColor)),
            const SizedBox(width: 4),
            Icon(
              Icons.visibility_outlined,
              color: AppColor.primary,
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }
}
