import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/inventory/data/model/building.model.dart';
import 'package:k3h_erp_app/features/project_document/drawing_document/data/model/inventory_drawing_document.model.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/functions/common_date_function.dart';
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
        screenTitle: "Inventory Drawing Report",
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

                            final type = hasDwg ? 'DWG' : 'PDF';
                            final backgroundColor =
                                hasDwg
                                    ? const Color(0xFFDCEBFF)
                                    : AppColor.lightRed;

                            final textColor =
                                hasDwg
                                    ? const Color(0xFF0057D9)
                                    : AppColor.missingInformationRed;
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
                                  value:
                                      document.drawingDocumentUrl.contains('~')
                                          ? document.drawingDocumentUrl
                                              .split('~')
                                              .last
                                              .trim()
                                          : '-',
                                  customValueWidget: GestureDetector(
                                    onTap: () {},
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: backgroundColor,

                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 4.0,
                                          horizontal: 8.0,
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              type,
                                              style: AppTextStyle.ts12M(
                                                color: textColor,
                                              ),
                                            ),
                                            horizontalSpacing(width: 4),
                                            Icon(
                                              Icons.visibility_outlined,
                                              color: AppColor.primary,
                                              size: 16.sp,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
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
                                  value: document.drawingDocumentRemark,
                                  customValueWidget: GestureDetector(
                                    onTap: () {
                                      DialogHelper.showNoteDialog(
                                        context,
                                        note: document.drawingDocumentRemark,
                                      );
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 10.w),
                                      child: Icon(
                                        Icons.info_outline,
                                        size: 18,
                                        color: AppColor.primary,
                                      ),
                                    ),
                                  ),
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
}
