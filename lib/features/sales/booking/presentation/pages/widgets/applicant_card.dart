import 'package:flutter/material.dart';
import 'package:k3h_erp_app/features/business_development/tenant/data/model/tenant.model.dart';
import 'package:k3h_erp_app/features/sales/booking/data/model/booking.model.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_click_to_contact_widget.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AdditionalKey {
  final String title;
  final String value;

  const AdditionalKey({required this.title, required this.value});
}

class ApplicantCard extends StatelessWidget {
  final BookingApplicantData? applicant;
  final Widget? suffixActionWidgets;
  final TenantApplicantData? tenantApplicant;
  final List<AdditionalKey>? additionalKeys;

  const ApplicantCard({
    super.key,
    this.applicant,
    this.suffixActionWidgets,
    this.tenantApplicant,
    this.additionalKeys,
  });

  @override
  Widget build(BuildContext context) {
    final applicantName =
        applicant?.applicantName ?? tenantApplicant?.applicantName ?? "";

    final applicantType =
        applicant?.applicantType ?? tenantApplicant?.applicantType ?? "";

    final mobileNumber =
        applicant?.applicantMobileNumber ??
        tenantApplicant?.applicantMobileNumber ??
        "";

    final mobileCountryCode =
        applicant?.applicantMobileNumberCountryCode ??
        tenantApplicant?.applicantMobileNumberCountryCode ??
        "";

    final email =
        applicant?.applicantEmailId ?? tenantApplicant?.applicantEmailId ?? "";

    final aadharNumber =
        applicant?.aadharCardNumber ?? tenantApplicant?.aadharCardNumber ?? "";

    final aadharUrl =
        applicant?.aadharCardURL ?? tenantApplicant?.aadharCardURL ?? "";

    final panNumber = applicant?.panNumber ?? tenantApplicant?.panNumber ?? "";

    final panUrl = applicant?.panCardURL ?? tenantApplicant?.panCardURL ?? "";

    final drivingLicenseNumber =
        applicant?.drivingLicenseNumber ??
        tenantApplicant?.drivingLicenseNumber ??
        "";

    final drivingLicenseUrl =
        applicant?.drivingLicenseURL ??
        tenantApplicant?.drivingLicenseURL ??
        "";

    final votingIdNumber =
        applicant?.votingIdNumber ?? tenantApplicant?.votingIdNumber ?? "";

    final votingIdUrl =
        applicant?.votingIdURL ?? tenantApplicant?.votingIdURL ?? "";

    final passportNumber =
        applicant?.passportNumber ?? tenantApplicant?.passportNumber ?? "";

    final passportUrl =
        applicant?.passportURL ?? tenantApplicant?.passportURL ?? "";

    final gstNumber = applicant?.gstNumber ?? tenantApplicant?.gstNumber ?? "";

    final gstUrl =
        applicant?.gstNumberURL ?? tenantApplicant?.gstNumberURL ?? "";

    return infoCard(
      bgColor: AppColor.white,
      borderColor: AppColor.primary,
      titleWidget: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(applicantName, style: AppTextStyle.ts14M()),
                if (suffixActionWidgets != null)
                  Text(
                    applicantType,
                    style: AppTextStyle.ts12M(color: AppColor.grey),
                  ),
              ],
            ),
          ),
          horizontalSpacing(width: 5),
          if (suffixActionWidgets != null)
            suffixActionWidgets!
          else
            _buildApplicantTypeWidget(applicantType),
        ],
      ),
      [
        {
          "title": "Mobile Number",
          "value": mobileNumber,
          "widget": CustomClickToContactText(
            countryCode: mobileCountryCode,
            value: mobileNumber,
            type: ContactType.phone,
          ),
        },
        {
          "title": "E-Mail ID",
          "value": email,
          "widget": CustomClickToContactText(
            value: email,
            type: ContactType.email,
          ),
        },
        {
          "title": "Aadhaar Card No.",
          "value": aadharNumber,
          "widget": buildDocumentRow(
            context: context,
            docNumber: aadharNumber,
            url: aadharUrl,
            title: "Aadhaar Card",
            fileBytes:
                applicant?.aadhaarImage.fileBytesList ??
                tenantApplicant?.aadhaarImage.fileBytesList ??
                [],
          ),
        },
        {
          "title": "PAN Card No.",
          "value": panNumber,
          "widget": buildDocumentRow(
            context: context,
            docNumber: panNumber,
            url: panUrl,
            title: "PAN Card",
            fileBytes:
                applicant?.panImage.fileBytesList ??
                tenantApplicant?.panImage.fileBytesList ??
                [],
          ),
        },
        {
          "title": "Driving License No.",
          "value": drivingLicenseNumber,
          "widget": buildDocumentRow(
            context: context,
            docNumber: drivingLicenseNumber,
            url: drivingLicenseUrl,
            title: "Driving License",
            fileBytes:
                applicant?.drivingLicenseImage.fileBytesList ??
                tenantApplicant?.drivingLicenseImage.fileBytesList ??
                [],
          ),
        },
        {
          "title": "Voting ID No.",
          "value": votingIdNumber,
          "widget": buildDocumentRow(
            context: context,
            docNumber: votingIdNumber,
            url: votingIdUrl,
            title: "Voting ID",
            fileBytes:
                applicant?.votingIdImage.fileBytesList ??
                tenantApplicant?.votingIdImage.fileBytesList ??
                [],
          ),
        },
        {
          "title": "Passport No.",
          "value": passportNumber,
          "widget": buildDocumentRow(
            context: context,
            docNumber: passportNumber,
            url: passportUrl,
            title: "Passport",
            fileBytes:
                applicant?.passportImage.fileBytesList ??
                tenantApplicant?.passportImage.fileBytesList ??
                [],
          ),
        },
        {
          "title": "GST No.",
          "value": gstNumber,
          "widget": buildDocumentRow(
            context: context,
            docNumber: gstNumber,
            url: gstUrl,
            title: "GST Certificate",
            fileBytes:
                applicant?.gstImage.fileBytesList ??
                tenantApplicant?.gstImage.fileBytesList ??
                [],
          ),
        },
        if (tenantApplicant != null) ...[
          _docEntry(context, "Profile Photo", tenantApplicant?.photoURL ?? ""),
          {"title": "Bank", "value": tenantApplicant?.bankName ?? ""},
          {"title": "IFSC", "value": tenantApplicant?.ifscCode ?? ""},
          {
            "title": "Account No.",
            "value": tenantApplicant?.accountNumber ?? "",
            "widget": buildDocumentRow(
              context: context,
              docNumber: tenantApplicant?.accountNumber ?? "",
              url: tenantApplicant?.chequeURL ?? "",
              title: "Cancel Cheque",
            ),
          },
        ] else ...[
          _docEntry(
            context,
            "Cancelled Cheque",
            applicant?.cancelledChequeUrl ?? "",
          ),
          _docEntry(context, "POA (if NRI Execution)", applicant?.poaurl ?? ""),
          _docEntry(
            context,
            "Income Docs (Form 16 / ITR)",
            applicant?.incomeForm16Itrurl ?? "",
          ),
          _docEntry(
            context,
            "NRE / NRO Bank Details",
            applicant?.nreNroBankDetailsUrl ?? "",
          ),
          _docEntry(context, "Nominee Form", applicant?.nomineeFormUrl ?? ""),
          _docEntry(
            context,
            "Statement Of Source Of Funds",
            applicant?.statementOfSourceOfFundsURL ?? "",
          ),
          _docEntry(context, "Payment Proof", applicant?.paymentProofURL ?? ""),
          _docEntry(context, "Profile Photo", applicant?.photoURL ?? ""),
        ],
        if (additionalKeys != null)
          ...additionalKeys!.map(
            (item) => {"title": item.title, "value": item.value},
          ),
      ],
    );
  }

  Map<String, dynamic> _docEntry(
    BuildContext context,
    String title,
    String url,
  ) {
    return {
      "title": title,
      "value": url,
      "widget":
          url.isEmpty
              ? null
              : CustomIconButton(
                onPressed: () {
                  showFilePreviewDialog(context, title: title, url.split(","));
                },
                isDisable: url.isEmpty,
                backgroundColor: AppColor.white,
                icon: Icon(
                  Icons.remove_red_eye_outlined,
                  size: 18,
                  color: AppColor.primary,
                ),
              ),
    };
  }

  Widget _buildApplicantTypeWidget(String type) {
    final isApplicant = type.toLowerCase() == "applicant";

    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color:
            isApplicant
                ? AppColor.lightBlue
                : AppColor.purple.withValues(alpha: .2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        type,
        style: AppTextStyle.ts12M(
          color: isApplicant ? AppColor.primary : AppColor.purple,
        ),
      ),
    );
  }
}
