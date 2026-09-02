import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/features/more/inward_outward/data/model/inward_outward.model.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_click_to_contact_widget.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/section_card.dart';

Widget overviewSection(BuildContext context, InwardOutwardModel inwardOutward) {
  final ScrollController employeeScrollController = ScrollController();
  final employeeNames =
      inwardOutward.employeeNames
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
  final departmentNames =
      inwardOutward.departmentName
          .split(',')
          .map((d) => d.trim())
          .where((d) => d.isNotEmpty)
          .toList();
  return SingleChildScrollView(
    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
    child: Column(
      children: [
        SectionCard(
          title: 'Basic Details',
          children: [
            buildColumnTitleValue(
              removeExpanded: true,
              title: "Document Title",
              value: inwardOutward.documentTitle,
            ),

            Row(
              spacing: 10,
              children: [
                buildColumnTitleValue(
                  title: "Document Type",
                  value: inwardOutward.documentType,
                ),
                buildColumnTitleValue(
                  title: "Delivery Type",
                  value: inwardOutward.deliveryType,
                ),
              ],
            ),
            Row(
              spacing: 10,
              children: [
                buildColumnTitleValue(
                  title: "Date",
                  value: formatDateTimeAsDDMMMYYYY(
                    inwardOutward.inwardOutwardDate,
                  ),
                ),
                buildColumnTitleValue(
                  title: "Invoice Number",
                  value: inwardOutward.invoiceNumber,
                ),
              ],
            ),
            Row(
              spacing: 10,
              children: [
                buildColumnTitleValue(
                  title: "Invoice Date",
                  value: formatDateTimeAsDDMMMYYYY(inwardOutward.invoiceDate),
                ),
                buildColumnTitleValue(
                  title: "Amount",
                  value: inwardOutward.amount.toIndianCurrency(),
                ),
              ],
            ),
            Row(
              spacing: 10,
              children: [
                buildColumnTitleValue(
                  title: "Cheque No.",
                  value: inwardOutward.chequeNumber,
                ),
              ],
            ),
          ],
        ),
        SectionCard(
          title: 'Document Details',
          titleTextColor: Colors.blue,
          headerBackgroundColor: Colors.blue.shade100.withValues(alpha: 0.5),
          children: [
            Row(
              children: [
                buildColumnTitleValue(
                  title: "${inwardOutward.documentType} Document",
                  value: inwardOutward.documentURL,
                  removeExpanded: true,
                  customValueWidget: CustomButton.documentOutline(
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
                ),
                Spacer(),
              ],
            ),

            Row(
              spacing: 10,
              children: [
                buildColumnTitleValue(
                  title: "Document Description",
                  value: inwardOutward.documentDescription,
                ),
              ],
            ),
          ],
        ),
        SectionCard(
          title: 'Sender Details',
          titleTextColor: AppColor.orange,
          headerBackgroundColor: AppColor.lightOrangeBg.withValues(alpha: 0.5),
          children: [
            Row(
              spacing: 10,
              children: [
                buildColumnTitleValue(
                  title: "Name",
                  value: inwardOutward.senderName,
                ),
                buildColumnTitleValue(
                  title: "Mobile No.",
                  value: inwardOutward.senderMobileNumber,
                  customValueWidget: CustomClickToContactText(
                    countryCode: inwardOutward.senderMobileNumberCountryCode,
                    value: inwardOutward.senderMobileNumber,
                  ),
                ),
              ],
            ),
            buildColumnTitleValue(
              title: "Email-Id",
              value: inwardOutward.senderEmailId,
              removeExpanded: true,
              customValueWidget: CustomClickToContactText(
                type: ContactType.email,
                value: inwardOutward.senderEmailId,
              ),
            ),
            buildColumnTitleValue(
              title: "Address",
              value: inwardOutward.senderAddress,
              removeExpanded: true,
            ),
          ],
        ),
        SectionCard(
          title: 'Receiver Details',
          titleTextColor: AppColor.darkBlue29,
          headerBackgroundColor: AppColor.darkBlue29.withValues(alpha: 0.1),
          children: [
            Row(
              spacing: 10,
              children: [
                buildColumnTitleValue(
                  title: "Name",
                  value: inwardOutward.receiverName,
                ),
                buildColumnTitleValue(
                  title: "Mobile No.",
                  value: inwardOutward.receiverMobileNumber,
                  customValueWidget: CustomClickToContactText(
                    countryCode: inwardOutward.receiverMobileNumberCountryCode,
                    value: inwardOutward.receiverMobileNumber,
                  ),
                ),
              ],
            ),
            buildColumnTitleValue(
              title: "Email-Id",
              value: inwardOutward.receiverEmailId,
              customValueWidget: CustomClickToContactText(
                type: ContactType.email,
                value: inwardOutward.receiverEmailId,
              ),
              removeExpanded: true,
            ),
            buildColumnTitleValue(
              title: "Address",
              value: inwardOutward.receiverAddress,
              removeExpanded: true,
            ),
          ],
        ),

        SectionCard(
          title: 'Assigned Employee',
          titleTextColor: AppColor.darkGreen10,
          headerBackgroundColor: AppColor.darkGreen10.withValues(alpha: 0.1),
          children: [
            SizedBox(
              height: employeeNames.length > 2 ? 150.h : 100.h,
              child: RawScrollbar(
                controller: employeeScrollController,
                thumbVisibility: true,
                thickness: 4,
                minThumbLength: 80.h,
                radius: const Radius.circular(2),
                child: ListView.separated(
                  controller: employeeScrollController,
                  itemCount: employeeNames.length,
                  shrinkWrap: true,
                  separatorBuilder:
                      (context, index) =>
                          Divider(height: 10.h, color: AppColor.lightBlue),
                  itemBuilder: (context, index) {
                    final employeeName = employeeNames[index];
                    final departmentName = departmentNames[index];
                    return ListTile(
                      contentPadding: EdgeInsets.symmetric(vertical: 2.h),
                      leading: CircleAvatar(
                        backgroundColor: AppColor.primary,
                        child: Text(
                          getInitials(employeeName),
                          style: AppTextStyle.ts16B(color: AppColor.white),
                        ),
                      ),
                      title: RichText(
                        text: TextSpan(
                          text: employeeName,
                          style: AppTextStyle.ts14M(),
                          children: [
                            TextSpan(
                              text: "\n$departmentName",
                              style: AppTextStyle.ts12M(color: AppColor.grey),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
        SectionCard(
          title: 'Delivery Details',
          titleTextColor: AppColor.brown,
          headerBackgroundColor: AppColor.lightYellow,
          children: [
            Row(
              spacing: 10,
              children: [
                buildColumnTitleValue(
                  title: "Delivery Mode",
                  value: inwardOutward.deliveryMode,
                ),
                buildColumnTitleValue(
                  title: "Status",
                  value: inwardOutward.deliveryStatus,
                ),
              ],
            ),
          ],
        ),
        SectionCard(
          title: 'Acknowledgement Details',
          titleTextColor: AppColor.purple700,
          headerBackgroundColor: AppColor.lightPurpleBg2,
          children: [
            Row(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildColumnTitleValue(
                  title: "Acknowlegded By",
                  value: inwardOutward.acknowledgementBy,
                ),
                buildColumnTitleValue(
                  title: "Acknowlegder's Signature",
                  value: inwardOutward.acknowledgementSignatureURL,
                  customValueWidget: CustomButton.documentOutline(
                    onPressed: () {
                      if (inwardOutward
                          .acknowledgementSignatureURL
                          .isNotEmpty) {
                        showFilePreviewDialog(
                          context,
                          title: "Acknowleger's Signature",
                          inwardOutward.acknowledgementSignatureURL.split(","),
                        );
                      }
                    },
                    isDisable:
                        inwardOutward.acknowledgementSignatureURL.isEmpty,
                  ),
                ),
              ],
            ),
            Row(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildColumnTitleValue(
                  title: "Attachment",
                  value: inwardOutward.acknowledgementURL,
                  customValueWidget: CustomButton.documentOutline(
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
                ),
                buildColumnTitleValue(
                  title: "Handover To",
                  value: inwardOutward.handOverTo,
                ),
              ],
            ),
            Row(
              spacing: 10,
              children: [
                buildColumnTitleValue(
                  title: "Handover Date",
                  value: formatDateTimeAsDDMMMYYYY(inwardOutward.handOverDate),
                ),
              ],
            ),
            Row(
              children: [
                buildColumnTitleValue(
                  title: "Remark",
                  value: inwardOutward.acknowledgementRemark,
                ),
              ],
            ),
          ],
        ),
        SectionCard(
          title: 'Action Details',
          titleTextColor: AppColor.black,
          headerBackgroundColor: AppColor.grey20,
          children: [
            Row(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildColumnTitleValue(
                  title: "Created By",
                  value: inwardOutward.createdBy,
                ),
                buildColumnTitleValue(
                  title: "Created Date",
                  value: formatDate(inwardOutward.createdDate),
                ),
              ],
            ),
            Row(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildColumnTitleValue(
                  title: "Modified By",
                  value: inwardOutward.modifiedBy,
                ),
                buildColumnTitleValue(
                  title: "Modified Date",
                  value: formatDate(inwardOutward.modifiedDate),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}
