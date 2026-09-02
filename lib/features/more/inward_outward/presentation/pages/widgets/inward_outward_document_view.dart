import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/features/more/inward_outward/data/model/inward_outward.model.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

Widget documentSection(BuildContext context, InwardOutwardModel inwardOutward) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
    child: Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Column(
        spacing: 10.h,
        children: [
          Container(
            decoration: commonCardDecoration(),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            child: ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: Text(
                "${inwardOutward.documentType} Document",
                style: AppTextStyle.ts14SB(),
              ),
              trailing: const Icon(Icons.keyboard_arrow_down),
              childrenPadding: EdgeInsets.zero,
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CustomButton.documentOutline(
                      onPressed: () {
                        if (inwardOutward.documentURL.isNotEmpty) {
                          showFilePreviewDialog(
                            context,
                            title: "${inwardOutward.documentType} Document",
                            inwardOutward.documentURL.split(","),
                          );
                        }
                      },
                      isDisable: inwardOutward.documentURL.isEmpty,
                    ),
                    Spacer(),
                  ],
                ),
                verticalSpacing(),
                Row(
                  spacing: 10.w,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Document Count",
                      value:
                          inwardOutward.documentURL
                              .split(',')
                              .length
                              .toString(),
                    ),
                    buildColumnTitleValue(
                      title: "Uploaded By / Date",
                      value:
                          inwardOutward.modifiedBy.trim().isNotEmpty
                              ? "${inwardOutward.modifiedBy} /${formatDate(inwardOutward.modifiedDate)}"
                              : "${inwardOutward.createdBy} /${formatDate(inwardOutward.createdDate)}",
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (inwardOutward.acknowledgementSignatureURL.trim().isNotEmpty ||
              inwardOutward.acknowledgementURL.trim().isNotEmpty)
            Container(
              decoration: commonCardDecoration(),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: Text(
                  "Acknowledgement Documents",
                  style: AppTextStyle.ts14SB(),
                ),
                trailing: const Icon(Icons.keyboard_arrow_down),
                childrenPadding: EdgeInsets.zero,
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (inwardOutward.acknowledgementSignatureURL
                      .trim()
                      .isNotEmpty) ...[
                    Row(
                      children: [
                        CustomButton.documentOutline(
                          onPressed: () {
                            if (inwardOutward
                                .acknowledgementSignatureURL
                                .isNotEmpty) {
                              showFilePreviewDialog(
                                context,
                                title: "Acknowleger's Signature",
                                inwardOutward.acknowledgementSignatureURL.split(
                                  ",",
                                ),
                              );
                            }
                          },
                          isDisable:
                              inwardOutward.acknowledgementSignatureURL.isEmpty,
                        ),
                        Spacer(),
                      ],
                    ),
                    verticalSpacing(),
                    Row(
                      spacing: 10.w,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildColumnTitleValue(
                          title: "Document Count",
                          value:
                              inwardOutward.acknowledgementSignatureURL
                                  .split(',')
                                  .length
                                  .toString(),
                        ),
                        buildColumnTitleValue(
                          title: "Uploaded By / Date",
                          value:
                              inwardOutward.modifiedBy.trim().isNotEmpty
                                  ? "${inwardOutward.modifiedBy} /${formatDate(inwardOutward.modifiedDate)}"
                                  : "${inwardOutward.createdBy} /${formatDate(inwardOutward.createdDate)}",
                        ),
                      ],
                    ),
                  ],
                  if (inwardOutward.acknowledgementSignatureURL
                          .trim()
                          .isNotEmpty &&
                      inwardOutward.acknowledgementURL.trim().isNotEmpty) ...[
                    verticalSpacing(),
                    Divider(height: 1, color: AppColor.grey50),
                    verticalSpacing(),
                  ],
                  if (inwardOutward.acknowledgementURL.trim().isNotEmpty) ...[
                    Row(
                      children: [
                        CustomButton.documentOutline(
                          onPressed: () {
                            if (inwardOutward.acknowledgementURL.isNotEmpty) {
                              showFilePreviewDialog(
                                context,
                                title: "Acknowlegement Document",
                                inwardOutward.acknowledgementURL.split(","),
                              );
                            }
                          },
                          isDisable: inwardOutward.acknowledgementURL.isEmpty,
                        ),
                        Spacer(),
                      ],
                    ),
                    verticalSpacing(),
                    Row(
                      spacing: 10.w,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildColumnTitleValue(
                          title: "Document Count",
                          value:
                              inwardOutward.acknowledgementURL
                                  .split(',')
                                  .length
                                  .toString(),
                        ),
                        buildColumnTitleValue(
                          title: "Uploaded By / Date",
                          value:
                              inwardOutward.modifiedBy.trim().isNotEmpty
                                  ? "${inwardOutward.modifiedBy} /${formatDateTimeAsDDMMMYYYY(inwardOutward.modifiedDate)}"
                                  : "${inwardOutward.createdBy} /${formatDateTimeAsDDMMMYYYY(inwardOutward.createdDate)}",
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    ),
  );
}
