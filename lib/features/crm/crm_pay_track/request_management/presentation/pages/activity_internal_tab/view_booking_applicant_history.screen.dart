import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/request_management/data/model/booking_applicant_modification_request.model.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/request_management/presentation/pages/widgets/document_preview.screen.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_click_to_contact_widget.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class ViewBookingApplicantHistoryScreen extends StatefulWidget {
  final BookingApplicantModificationRequestModel applicantDetail;
  const ViewBookingApplicantHistoryScreen({
    super.key,
    required this.applicantDetail,
  });

  @override
  State<ViewBookingApplicantHistoryScreen> createState() =>
      _ViewBookingApplicantHistoryScreenState();
}

class _ViewBookingApplicantHistoryScreenState
    extends State<ViewBookingApplicantHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle:
            "Modified Requests > Activity > Version ${widget.applicantDetail.versionNumber}",
        authorization: AuthorizationModel(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColor.lightGreyBackground,
            border: Border.all(width: 0.5, color: AppColor.grey50),
            borderRadius: BorderRadius.circular(6.0),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: buildColumnTitleValueNormal(
                        title: "Type",
                        value: widget.applicantDetail.applicantType,
                      ),
                    ),
                    horizontalSpacing(),
                    Expanded(
                      child: buildColumnTitleValueNormal(
                        title: "Proof Of Document",
                        value: widget.applicantDetail.proofOfDocumentUrl,
                        customValueWidget: CustomButton.documentOutline(
                          onPressed: () {
                            if (widget
                                .applicantDetail
                                .proofOfDocumentUrl
                                .isNotEmpty) {
                              showFilePreviewDialog(
                                title: "Proof Of Document",
                                context,
                                widget.applicantDetail.proofOfDocumentUrl.split(
                                  ",",
                                ),
                              );
                            }
                          },
                          isDisable:
                              widget.applicantDetail.proofOfDocumentUrl.isEmpty,
                        ),
                      ),
                    ),
                  ],
                ),
                verticalSpacing(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: buildColumnTitleValueNormal(
                        title: "Applicant Name",
                        value: widget.applicantDetail.applicantName,
                        customValueWidget: DocumentPreviewText(
                          title: "Profile Photo",
                          text: widget.applicantDetail.applicantName,
                          fileUrl: widget.applicantDetail.photoUrl,
                        ),
                      ),
                    ),
                    horizontalSpacing(),
                    Expanded(
                      child: buildColumnTitleValueNormal(
                        title: "Mobile Number",
                        value: widget.applicantDetail.applicantMobileNumber,
                        customValueWidget: CustomClickToContactText(
                          countryCode:
                              widget
                                  .applicantDetail
                                  .applicantMobileNumberCountryCode,
                          value: widget.applicantDetail.applicantMobileNumber,
                        ),
                      ),
                    ),
                  ],
                ),
                verticalSpacing(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: buildColumnTitleValueNormal(
                        title: "E-Mail ID",
                        value: widget.applicantDetail.applicantEmailId,
                      ),
                    ),
                    horizontalSpacing(),
                    Expanded(
                      child: buildColumnTitleValueNormal(
                        title: "Aadhaar Card No.",
                        value: widget.applicantDetail.aadharCardNumber,
                        customValueWidget: DocumentPreviewText(
                          title: "Aadhaar Card No.",
                          text: widget.applicantDetail.aadharCardNumber,
                          fileUrl: widget.applicantDetail.aadharCardUrl,
                        ),
                      ),
                    ),
                  ],
                ),
                verticalSpacing(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: buildColumnTitleValueNormal(
                        title: "PAN No.",
                        value: widget.applicantDetail.panNumber,
                        customValueWidget: DocumentPreviewText(
                          title: "PAN No.",
                          text: widget.applicantDetail.panNumber,
                          fileUrl: widget.applicantDetail.panCardUrl,
                        ),
                      ),
                    ),
                    horizontalSpacing(),
                    Expanded(
                      child: buildColumnTitleValueNormal(
                        title: "Driving License",
                        value: widget.applicantDetail.drivingLicenseNumber,
                        customValueWidget: DocumentPreviewText(
                          title: "Driving License",
                          text: widget.applicantDetail.drivingLicenseNumber,
                          fileUrl: widget.applicantDetail.drivingLicenseUrl,
                        ),
                      ),
                    ),
                  ],
                ),
                verticalSpacing(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: buildColumnTitleValueNormal(
                        title: "Voting ID No.",
                        value: widget.applicantDetail.votingIdNumber,
                        customValueWidget: DocumentPreviewText(
                          title: "Voting ID No.",
                          text: widget.applicantDetail.votingIdNumber,
                          fileUrl: widget.applicantDetail.votingIdUrl,
                        ),
                      ),
                    ),
                    horizontalSpacing(),
                    Expanded(
                      child: buildColumnTitleValueNormal(
                        title: "Passport No.",
                        value: widget.applicantDetail.passportNumber,
                        customValueWidget: DocumentPreviewText(
                          title: "Passport No.",
                          text: widget.applicantDetail.passportNumber,
                          fileUrl: widget.applicantDetail.passportUrl,
                        ),
                      ),
                    ),
                  ],
                ),
                verticalSpacing(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: buildColumnTitleValueNormal(
                        title: "GST No.",
                        value: widget.applicantDetail.gstNumber,
                        customValueWidget: DocumentPreviewText(
                          title: "GST No.",
                          text: widget.applicantDetail.gstNumber,
                          fileUrl: widget.applicantDetail.gstNumberUrl,
                        ),
                      ),
                    ),
                    horizontalSpacing(),
                    Expanded(
                      child: buildColumnTitleValueNormal(
                        title: "Cancelled Cheque",
                        value: widget.applicantDetail.cancelledChequeUrl,
                        customValueWidget: CustomButton.documentOutline(
                          onPressed: () {
                            if (widget
                                .applicantDetail
                                .cancelledChequeUrl
                                .isNotEmpty) {
                              showFilePreviewDialog(
                                title: "Cancelled Cheque",
                                context,
                                widget.applicantDetail.cancelledChequeUrl.split(
                                  ",",
                                ),
                              );
                            }
                          },
                          isDisable:
                              widget.applicantDetail.cancelledChequeUrl.isEmpty,
                        ),
                      ),
                    ),
                  ],
                ),
                verticalSpacing(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: buildColumnTitleValueNormal(
                        title: "POA (if NRI Execution)",
                        value: widget.applicantDetail.poaurl,
                        customValueWidget: CustomButton.documentOutline(
                          onPressed: () {
                            if (widget.applicantDetail.poaurl.isNotEmpty) {
                              showFilePreviewDialog(
                                title: "POA (if NRI Execution)",
                                context,
                                widget.applicantDetail.poaurl.split(","),
                              );
                            }
                          },
                          isDisable: widget.applicantDetail.poaurl.isEmpty,
                        ),
                      ),
                    ),
                    horizontalSpacing(),
                    Expanded(
                      child: buildColumnTitleValueNormal(
                        title: "Income Docs (Form 16 / ITR)",
                        value: widget.applicantDetail.incomeForm16Itrurl,
                        customValueWidget: CustomButton.documentOutline(
                          onPressed: () {
                            if (widget
                                .applicantDetail
                                .incomeForm16Itrurl
                                .isNotEmpty) {
                              showFilePreviewDialog(
                                title: "Income Docs (Form 16 / ITR)",
                                context,
                                widget.applicantDetail.incomeForm16Itrurl.split(
                                  ",",
                                ),
                              );
                            }
                          },
                          isDisable:
                              widget.applicantDetail.incomeForm16Itrurl.isEmpty,
                        ),
                      ),
                    ),
                  ],
                ),
                verticalSpacing(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: buildColumnTitleValueNormal(
                        title: "NRE / NRO Bank Details",
                        value: widget.applicantDetail.nreNroBankDetailsUrl,
                        customValueWidget: CustomButton.documentOutline(
                          onPressed: () {
                            if (widget
                                .applicantDetail
                                .nreNroBankDetailsUrl
                                .isNotEmpty) {
                              showFilePreviewDialog(
                                title: "NRE / NRO Bank Details",
                                context,
                                widget.applicantDetail.nreNroBankDetailsUrl
                                    .split(","),
                              );
                            }
                          },
                          isDisable:
                              widget
                                  .applicantDetail
                                  .nreNroBankDetailsUrl
                                  .isEmpty,
                        ),
                      ),
                    ),
                    horizontalSpacing(),
                    Expanded(
                      child: buildColumnTitleValueNormal(
                        title: "Nominee Form \n",
                        value: widget.applicantDetail.nomineeFormUrl,
                        customValueWidget: CustomButton.documentOutline(
                          onPressed: () {
                            if (widget
                                .applicantDetail
                                .nomineeFormUrl
                                .isNotEmpty) {
                              showFilePreviewDialog(
                                title: "Nominee Form",
                                context,
                                widget.applicantDetail.nomineeFormUrl.split(
                                  ",",
                                ),
                              );
                            }
                          },
                          isDisable:
                              widget.applicantDetail.nomineeFormUrl.isEmpty,
                        ),
                      ),
                    ),
                  ],
                ),
                verticalSpacing(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: buildColumnTitleValueNormal(
                        title: "Statement Of Source Of Funds",
                        value:
                            widget.applicantDetail.statementOfSourceOfFundsUrl,
                        customValueWidget: CustomButton.documentOutline(
                          onPressed: () {
                            if (widget
                                .applicantDetail
                                .statementOfSourceOfFundsUrl
                                .isNotEmpty) {
                              showFilePreviewDialog(
                                title: "Statement Of Source Of Funds",
                                context,
                                widget
                                    .applicantDetail
                                    .statementOfSourceOfFundsUrl
                                    .split(","),
                              );
                            }
                          },
                          isDisable:
                              widget
                                  .applicantDetail
                                  .statementOfSourceOfFundsUrl
                                  .isEmpty,
                        ),
                      ),
                    ),
                    horizontalSpacing(),
                    Expanded(
                      child: buildColumnTitleValueNormal(
                        title: "Payment Proof \n",
                        value: widget.applicantDetail.paymentProofUrl,
                        customValueWidget: CustomButton.documentOutline(
                          onPressed: () {
                            if (widget
                                .applicantDetail
                                .paymentProofUrl
                                .isNotEmpty) {
                              showFilePreviewDialog(
                                title: "Payment Proof",
                                context,
                                widget.applicantDetail.paymentProofUrl.split(
                                  ",",
                                ),
                              );
                            }
                          },
                          isDisable:
                              widget.applicantDetail.paymentProofUrl.isEmpty,
                        ),
                      ),
                    ),
                  ],
                ),
                verticalSpacing(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: buildColumnTitleValueNormal(
                        title: "Created By",
                        value: widget.applicantDetail.createdBy,
                      ),
                    ),
                    horizontalSpacing(),
                    Expanded(
                      child: buildColumnTitleValueNormal(
                        title: "Created Date",
                        value: formatDateTimeAsDDMMMYYYY(
                          widget.applicantDetail.createdDate!,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
