import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/request_management/data/model/booking_applicant_modification_request.model.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/request_management/presentation/pages/widgets/document_preview.screen.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/custom_click_to_contact_widget.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class ViewBookingApplicantHistoryScreen extends StatefulWidget {
  final String version;
  final List<BookingApplicantModificationRequestModel> applicants;
  const ViewBookingApplicantHistoryScreen({
    super.key,
    required this.version,
    required this.applicants,
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
        screenTitle: "Modified Requests > Activity > Version ${widget.version}",
        authorization: AuthorizationModel(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: List.generate(widget.applicants.length, (index) {
            final applicant = widget.applicants[index];
            return Container(
              margin: EdgeInsets.only(bottom: 10.0),
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
                            value: applicant.applicantType,
                          ),
                        ),
                        horizontalSpacing(),
                        Expanded(
                          child: buildColumnTitleValueNormal(
                            title: "Proof Of Document",
                            value: applicant.proofOfDocumentUrl,
                            customValueWidget: DocumentPreviewText(
                              title: "Proof Of Document",
                              text:
                                  applicant.proofOfDocumentUrl.isEmpty
                                      ? "-"
                                      : "View",
                              fileUrl: applicant.proofOfDocumentUrl,
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
                            value: applicant.applicantName,
                            customValueWidget: DocumentPreviewText(
                              title: "Profile Photo",
                              text: applicant.applicantName,
                              fileUrl: applicant.photoUrl,
                            ),
                          ),
                        ),
                        horizontalSpacing(),
                        Expanded(
                          child: buildColumnTitleValueNormal(
                            title: "Mobile Number",
                            value: applicant.applicantMobileNumber,
                            customValueWidget: CustomClickToContactText(
                              countryCode:
                                  applicant.applicantMobileNumberCountryCode,
                              value: applicant.applicantMobileNumber,
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
                            value: applicant.applicantEmailId,
                          ),
                        ),
                        horizontalSpacing(),
                        Expanded(
                          child: buildColumnTitleValueNormal(
                            title: "Aadhaar Card No.",
                            value: applicant.aadharCardNumber,
                            customValueWidget: DocumentPreviewText(
                              title: "Aadhaar Card No.",
                              text: applicant.aadharCardNumber,
                              fileUrl: applicant.aadharCardUrl,
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
                            value: applicant.panNumber,
                            customValueWidget: DocumentPreviewText(
                              title: "PAN No.",
                              text: applicant.panNumber,
                              fileUrl: applicant.panCardUrl,
                            ),
                          ),
                        ),
                        horizontalSpacing(),
                        Expanded(
                          child: buildColumnTitleValueNormal(
                            title: "Driving License",
                            value: applicant.drivingLicenseNumber,
                            customValueWidget: DocumentPreviewText(
                              title: "Driving License",
                              text: applicant.drivingLicenseNumber,
                              fileUrl: applicant.drivingLicenseUrl,
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
                            value: applicant.votingIdNumber,
                            customValueWidget: DocumentPreviewText(
                              title: "Voting ID No.",
                              text: applicant.votingIdNumber,
                              fileUrl: applicant.votingIdUrl,
                            ),
                          ),
                        ),
                        horizontalSpacing(),
                        Expanded(
                          child: buildColumnTitleValueNormal(
                            title: "Passport No.",
                            value: applicant.passportNumber,
                            customValueWidget: DocumentPreviewText(
                              title: "Passport No.",
                              text: applicant.passportNumber,
                              fileUrl: applicant.passportUrl,
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
                            value: applicant.gstNumber,
                            customValueWidget: DocumentPreviewText(
                              title: "GST No.",
                              text: applicant.gstNumber,
                              fileUrl: applicant.gstNumberUrl,
                            ),
                          ),
                        ),
                        horizontalSpacing(),
                        Expanded(
                          child: buildColumnTitleValueNormal(
                            title: "Cancelled Cheque",
                            value: applicant.cancelledChequeUrl,
                            customValueWidget: DocumentPreviewText(
                              title: "Cancelled Cheque",
                              text:
                                  applicant.cancelledChequeUrl.isEmpty
                                      ? "-"
                                      : "View",
                              fileUrl: applicant.cancelledChequeUrl,
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
                            value: applicant.poaurl,
                            customValueWidget: DocumentPreviewText(
                              title: "POA (if NRI Execution)",
                              text: applicant.poaurl.isEmpty ? "-" : "View",
                              fileUrl: applicant.poaurl,
                            ),
                          ),
                        ),
                        horizontalSpacing(),
                        Expanded(
                          child: buildColumnTitleValueNormal(
                            title: "Income Docs (Form 16 / ITR)",
                            value: applicant.incomeForm16Itrurl,
                            customValueWidget: DocumentPreviewText(
                              title: "Income Docs (Form 16 / ITR)",
                              text:
                                  applicant.incomeForm16Itrurl.isEmpty
                                      ? "-"
                                      : "View",
                              fileUrl: applicant.incomeForm16Itrurl,
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
                            value: applicant.nreNroBankDetailsUrl,
                            customValueWidget: DocumentPreviewText(
                              title: "NRE / NRO Bank Details",
                              text:
                                  applicant.nreNroBankDetailsUrl.isEmpty
                                      ? "-"
                                      : "View",
                              fileUrl: applicant.nreNroBankDetailsUrl,
                            ),
                          ),
                        ),
                        horizontalSpacing(),
                        Expanded(
                          child: buildColumnTitleValueNormal(
                            title: "Nominee Form \n",
                            value: applicant.nomineeFormUrl,
                            customValueWidget: DocumentPreviewText(
                              title: "Nominee Form \n",
                              text:
                                  applicant.nomineeFormUrl.isEmpty
                                      ? "-"
                                      : "View",
                              fileUrl: applicant.nomineeFormUrl,
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
                            value: applicant.statementOfSourceOfFundsUrl,
                            customValueWidget: DocumentPreviewText(
                              title: "Statement Of Source Of Funds",
                              text:
                                  applicant.statementOfSourceOfFundsUrl.isEmpty
                                      ? "-"
                                      : "View",
                              fileUrl: applicant.statementOfSourceOfFundsUrl,
                            ),
                          ),
                        ),
                        horizontalSpacing(),
                        Expanded(
                          child: buildColumnTitleValueNormal(
                            title: "Payment Proof \n",
                            value: applicant.paymentProofUrl,
                            customValueWidget: DocumentPreviewText(
                              title: "Payment Proof \n",
                              text:
                                  applicant.paymentProofUrl.isEmpty
                                      ? "-"
                                      : "View",
                              fileUrl: applicant.paymentProofUrl,
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
                            value: applicant.createdBy,
                          ),
                        ),
                        horizontalSpacing(),
                        Expanded(
                          child: buildColumnTitleValueNormal(
                            title: "Created Date",
                            value: formatDateTimeAsDDMMMYYYY(
                              applicant.createdDate!,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
