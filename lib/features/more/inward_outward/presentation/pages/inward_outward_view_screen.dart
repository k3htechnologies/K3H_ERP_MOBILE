import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/more/inward_outward/data/model/inward_outward.model.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/static/static_dropdown_data.dart';
import 'package:k3h_erp_app/utils/static/static_tab_values.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/chip_style_tab_bar.dart';
import 'package:k3h_erp_app/widgets/custom_click_to_contact_widget.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

import '../../../../../widgets/app_bar/custom_app_bar_with_back_button.dart';

class InwardOutwardViewScreen extends StatefulWidget {
  final InwardOutwardModel inwardOutwardModel;
  const InwardOutwardViewScreen({super.key, required this.inwardOutwardModel});

  @override
  State<InwardOutwardViewScreen> createState() =>
      _InwardOutwardViewScreenState();
}

class _InwardOutwardViewScreenState extends State<InwardOutwardViewScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _employeeScrollController = ScrollController();

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _employeeScrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Inward Outward",
        authorization: AuthorizationModel(),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            child: Text(
              widget.inwardOutwardModel.systemGeneratedCode,
              style: AppTextStyle.ts16M(),
            ),
          ),
          ChipStyleTabBar(
            isSecondaryStyle: true,
            controller: _tabController,
            tabs: inwardOutwardViewTabs,
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: NeverScrollableScrollPhysics(),
              children: [overviewSection(), documentSection(), revertSection()],
            ),
          ),
        ],
      ),
    );
  }

  Widget overviewSection() {
    final inwardOutward = widget.inwardOutwardModel;
    final employeeNames =
        widget.inwardOutwardModel.employeeNames
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
    final departmentNames =
        widget.inwardOutwardModel.departmentName
            .split(',')
            .map((d) => d.trim())
            .where((d) => d.isNotEmpty)
            .toList();
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Column(
        children: [
          Container(
            decoration: commonCardDecoration(),
            margin: EdgeInsets.only(bottom: 10),
            padding: EdgeInsets.all(16),
            child: Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Basic Details', style: AppTextStyle.ts16SB()),
                Row(
                  spacing: 10,
                  children: [
                    buildColumnTitleValue(
                      title: "Document Title",
                      value: inwardOutward.documentTitle,
                    ),
                  ],
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
                      value: formatDateTimeAsDDMMMYYYY(
                        inwardOutward.invoiceDate,
                      ),
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
          ),
          Container(
            decoration: commonCardDecoration(),
            margin: EdgeInsets.only(bottom: 10),
            padding: EdgeInsets.all(16),
            child: Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Document Details', style: AppTextStyle.ts16SB()),

                Row(
                  spacing: 10,
                  children: [
                    buildColumnTitleValue(
                      title: "Attachment",
                      value: inwardOutward.documentURL,
                      customValueWidget: CustomButton.documentOutline(
                        onPressed: () {
                          if (inwardOutward.documentURL.isNotEmpty) {
                            showFilePreviewDialog(
                              context,
                              title: "Attachment",
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
          ),
          Container(
            decoration: commonCardDecoration(),
            margin: EdgeInsets.only(bottom: 10),
            padding: EdgeInsets.all(16),
            child: Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sender Details', style: AppTextStyle.ts16SB()),
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
                        countryCode:
                            inwardOutward.senderMobileNumberCountryCode,
                        value: inwardOutward.senderMobileNumber,
                      ),
                    ),
                  ],
                ),
                Row(
                  spacing: 10,
                  children: [
                    buildColumnTitleValue(
                      title: "Email-Id",
                      value: inwardOutward.senderEmailId,
                      customValueWidget: CustomClickToContactText(
                        type: ContactType.email,
                        value: inwardOutward.senderEmailId,
                      ),
                    ),
                    buildColumnTitleValue(
                      title: "Address",
                      value: inwardOutward.senderAddress,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            decoration: commonCardDecoration(),
            margin: EdgeInsets.only(bottom: 10),
            padding: EdgeInsets.all(16),
            child: Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Receiver Details', style: AppTextStyle.ts16SB()),
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
                        countryCode:
                            inwardOutward.receiverMobileNumberCountryCode,
                        value: inwardOutward.receiverMobileNumber,
                      ),
                    ),
                  ],
                ),
                Row(
                  spacing: 10,
                  children: [
                    buildColumnTitleValue(
                      title: "Email-Id",
                      value: inwardOutward.receiverEmailId,
                      customValueWidget: CustomClickToContactText(
                        type: ContactType.email,
                        value: inwardOutward.receiverEmailId,
                      ),
                    ),
                    buildColumnTitleValue(
                      title: "Address",
                      value: inwardOutward.receiverAddress,
                    ),
                  ],
                ),
              ],
            ),
          ),

          Container(
            decoration: commonCardDecoration(),
            margin: EdgeInsets.only(bottom: 10),
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10.h,
              children: [
                Text('Assigned Employee', style: AppTextStyle.ts16SB()),

                SizedBox(
                  height: employeeNames.length > 2 ? 150.h : 100.h,
                  child: RawScrollbar(
                    controller: _employeeScrollController,
                    thumbVisibility: true,
                    thickness: 4,
                    minThumbLength: 80.h,
                    radius: const Radius.circular(2),
                    child: ListView.builder(
                      controller: _employeeScrollController,
                      itemCount: employeeNames.length,
                      shrinkWrap: true,

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
                                  style: AppTextStyle.ts12M(
                                    color: AppColor.grey,
                                  ),
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
          ),
          Container(
            decoration: commonCardDecoration(),
            margin: EdgeInsets.only(bottom: 10),
            padding: EdgeInsets.all(16),
            child: Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Delivery Details', style: AppTextStyle.ts16SB()),
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
          ),
          Container(
            decoration: commonCardDecoration(),
            margin: EdgeInsets.only(bottom: 10),
            padding: EdgeInsets.all(16),
            child: Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Acknowledgement Details', style: AppTextStyle.ts16SB()),
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
                              inwardOutward.acknowledgementSignatureURL.split(
                                ",",
                              ),
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
                      value: formatDateTimeAsDDMMMYYYY(
                        inwardOutward.handOverDate,
                      ),
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
          ),
          actionCardWidget(
            createdBy: inwardOutward.createdBy,
            createdDate: inwardOutward.createdDate,
            modifiedBy: inwardOutward.modifiedBy,
            modifiedDate: inwardOutward.modifiedDate,
          ),
        ],
      ),
    );
  }

  Widget documentSection() {
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
                  "${widget.inwardOutwardModel.documentType} Document",
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
                          if (widget
                              .inwardOutwardModel
                              .documentURL
                              .isNotEmpty) {
                            showFilePreviewDialog(
                              context,
                              title:
                                  "${widget.inwardOutwardModel.documentType} Document",
                              widget.inwardOutwardModel.documentURL.split(","),
                            );
                          }
                        },
                        isDisable:
                            widget.inwardOutwardModel.documentURL.isEmpty,
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
                            widget.inwardOutwardModel.documentURL
                                .split(',')
                                .length
                                .toString(),
                      ),
                      buildColumnTitleValue(
                        title: "Uploaded By / Date",
                        value:
                            widget.inwardOutwardModel.modifiedBy
                                    .trim()
                                    .isNotEmpty
                                ? "${widget.inwardOutwardModel.modifiedBy} /${formatDate(widget.inwardOutwardModel.modifiedDate)}"
                                : "${widget.inwardOutwardModel.createdBy} /${formatDate(widget.inwardOutwardModel.createdDate)}",
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (widget.inwardOutwardModel.acknowledgementSignatureURL
                    .trim()
                    .isNotEmpty ||
                widget.inwardOutwardModel.acknowledgementURL.trim().isNotEmpty)
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
                    if (widget.inwardOutwardModel.acknowledgementSignatureURL
                        .trim()
                        .isNotEmpty) ...[
                      Row(
                        children: [
                          CustomButton.documentOutline(
                            onPressed: () {
                              if (widget
                                  .inwardOutwardModel
                                  .acknowledgementSignatureURL
                                  .isNotEmpty) {
                                showFilePreviewDialog(
                                  context,
                                  title: "Acknowleger's Signature",
                                  widget
                                      .inwardOutwardModel
                                      .acknowledgementSignatureURL
                                      .split(","),
                                );
                              }
                            },
                            isDisable:
                                widget
                                    .inwardOutwardModel
                                    .acknowledgementSignatureURL
                                    .isEmpty,
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
                                widget
                                    .inwardOutwardModel
                                    .acknowledgementSignatureURL
                                    .split(',')
                                    .length
                                    .toString(),
                          ),
                          buildColumnTitleValue(
                            title: "Uploaded By / Date",
                            value:
                                widget.inwardOutwardModel.modifiedBy
                                        .trim()
                                        .isNotEmpty
                                    ? "${widget.inwardOutwardModel.modifiedBy} /${formatDate(widget.inwardOutwardModel.modifiedDate)}"
                                    : "${widget.inwardOutwardModel.createdBy} /${formatDate(widget.inwardOutwardModel.createdDate)}",
                          ),
                        ],
                      ),
                    ],
                    if (widget.inwardOutwardModel.acknowledgementSignatureURL
                            .trim()
                            .isNotEmpty &&
                        widget.inwardOutwardModel.acknowledgementURL
                            .trim()
                            .isNotEmpty) ...[
                      verticalSpacing(),
                      Divider(height: 1, color: AppColor.grey50),
                      verticalSpacing(),
                    ],
                    if (widget.inwardOutwardModel.acknowledgementURL
                        .trim()
                        .isNotEmpty) ...[
                      Row(
                        children: [
                          CustomButton.documentOutline(
                            onPressed: () {
                              if (widget
                                  .inwardOutwardModel
                                  .acknowledgementURL
                                  .isNotEmpty) {
                                showFilePreviewDialog(
                                  context,
                                  title: "Acknowlegement Document",
                                  widget.inwardOutwardModel.acknowledgementURL
                                      .split(","),
                                );
                              }
                            },
                            isDisable:
                                widget
                                    .inwardOutwardModel
                                    .acknowledgementURL
                                    .isEmpty,
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
                                widget.inwardOutwardModel.acknowledgementURL
                                    .split(',')
                                    .length
                                    .toString(),
                          ),
                          buildColumnTitleValue(
                            title: "Uploaded By / Date",
                            value:
                                widget.inwardOutwardModel.modifiedBy
                                        .trim()
                                        .isNotEmpty
                                    ? "${widget.inwardOutwardModel.modifiedBy} /${formatDateTimeAsDDMMMYYYY(widget.inwardOutwardModel.modifiedDate)}"
                                    : "${widget.inwardOutwardModel.createdBy} /${formatDateTimeAsDDMMMYYYY(widget.inwardOutwardModel.createdDate)}",
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

  Widget revertSection() {
    if (widget.inwardOutwardModel.inwardOutwardRevertHistory.isEmpty) {
      return Center(child: noDataWidget(message: "No Revert Data Found"));
    }
    return ListView.separated(
      separatorBuilder: (context, index) => verticalSpacing(),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      itemCount: widget.inwardOutwardModel.inwardOutwardRevertHistory.length,
      itemBuilder: (context, index) {
        final revert =
            widget.inwardOutwardModel.inwardOutwardRevertHistory[index];
        return Container(
          decoration: commonCardDecoration(),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          child: Column(
            children: [
              buildRowTitleValue(
                title: "Date",
                fixesWidth: 60.w,
                value: formatDateTimeAsDDMMMYYYY(revert.revertDate),
                customValueWidget: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatDateTimeAsDDMMMYYYY(revert.revertDate),
                      style: AppTextStyle.ts14M(),
                    ),
                    CustomButton.documentOutline(
                      isDisable: revert.revertDocumentURL.isEmpty,
                      onPressed: () {
                        if (revert.revertDocumentURL.isNotEmpty) {
                          showFilePreviewDialog(
                            context,
                            title: "Revert Document",
                            revert.revertDocumentURL.split(","),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
              buildRowTitleValue(
                title: "Remark",
                fixesWidth: 60.w,
                singleLine: false,
                value: revert.revertRemark,
              ),
            ],
          ),
        );
      },
    );
  }
}
