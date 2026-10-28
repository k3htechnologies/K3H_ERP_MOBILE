import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/dashboard/data/model/module_approval.model.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/section_card.dart';


/// To make content dynamic switch case is used
class ApprovalField {
  final String title;
  final String value;
  const ApprovalField(this.title, this.value);
}

List<ApprovalField> approvalFieldsFor(ModuleApprovalModel d) {
  final moduleName = d.moduleName.split('~').first.trim();

  switch (moduleName) {
    // INVENTORY
    case "Inventory":
      return [
        ApprovalField("Building", d.buildingNumber),
        ApprovalField("Wing", d.wing),
      ];

    // PARKING
    case "Parking":
      return [
        ApprovalField("Building", d.buildingNumber),
        ApprovalField("Wing", d.wing),
        ApprovalField("Floor", d.floor),
      ];

    // BOOKING & CRM
    case "Booking":
    case "Booking Applicant Modification":
    case "Parking Modification":
    case "Refund Payment Ledger":
    case "Cancel Booking":
      return [
        ApprovalField("Flat", d.flat),
        ApprovalField("Applicant", d.applicantName),
      ];

    case "Flat Alteration":
      return [
        ApprovalField("Flat", d.flat),
        ApprovalField("Applicant", d.applicantName),
        ApprovalField("Flat Alteration Remark", d.flatAlterationRemark),
      ];

    case "Flat Handover":
      return [
        ApprovalField("Flat", d.flat),
        ApprovalField("Applicant", d.applicantName),
        ApprovalField("File Name", d.fileName),
      ];

    case "CRM Payment Ledger":
      return [
        ApprovalField("Flat", d.flat),
        ApprovalField("Applicant", d.applicantName),
        ApprovalField("Payment For", d.paymentFor),
      ];

    case "Tenant Booking":
      return [
        ApprovalField("Flat", d.flat),
        ApprovalField("Applicant", d.applicantName),
        ApprovalField("Tenant Code", d.systemGeneratedCode),
      ];

    // DOCUMENT / RERA / APPROVAL DOCUMENT
    case "Document":
    case "RERA Document":
    case "Approval Document":
      return [
        ApprovalField("Document", d.projectDocumentName),
        ApprovalField("Category", d.projectDocumentCategory),
      ];

    // BUDGET
    case "Budget":
      return [ApprovalField("Wing", d.wing)];

    // TERM SHEET
    case "Term Sheet":
      return [
        ApprovalField(
          "Name Of Institution / Bank / NBFC",
          d.nameOfInstitutionBankNbfc,
        ),
      ];

    // FINALIZED VENDOR / INVOICE APPROVAL
    case "Finalized Vendor":
    case "Invoice Approval":
      return [ApprovalField("MR Code", d.systemGeneratedCode)];

    default:
      return [];
  }
}

class ModuleApprovalOverallScreen extends StatefulWidget {
  final List<ModuleApprovalModel>? moduleApprovalModel;
  const ModuleApprovalOverallScreen({super.key, this.moduleApprovalModel});

  @override
  State<ModuleApprovalOverallScreen> createState() =>
      _ModuleApprovalOverallScreenState();
}

class _ModuleApprovalOverallScreenState
    extends State<ModuleApprovalOverallScreen> {
  @override
  Widget build(BuildContext context) {
    final approvals = widget.moduleApprovalModel ?? <ModuleApprovalModel>[];
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle:
            "My Approvals : ${widget.moduleApprovalModel!.first.moduleName}",
        authorization: AuthorizationModel(),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child:
                    approvals.isEmpty
                        ? const Center(child: Text('No module approval found'))
                        : ListView.builder(
                          itemCount: approvals.length,
                          itemBuilder: (context, index) {
                            final document = approvals[index];

                            final documentTitle =
                                document.moduleName.split('~').first.trim();
                            final fields = approvalFieldsFor(document);
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
                                  title: "Project",
                                  value: document.projectName,
                                  customValueWidget: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                      vertical: 2.0,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          document.projectName.isEmpty
                                              ? AppColor.white
                                              : AppColor.lightBlue2,
                                      borderRadius: BorderRadius.circular(4.0),
                                    ),
                                    child: Text(
                                      document.projectName.isEmpty
                                          ? "-"
                                          : document.projectName,
                                      style: AppTextStyle.ts12SB(
                                        color: AppColor.primary,
                                      ),
                                    ),
                                  ),
                                ),
                                ...fields.map(
                                  (f) => buildRowTitleValue(
                                    title: f.title,
                                    value:
                                        f.value.trim().isEmpty ? "-" : f.value,
                                  ),
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
