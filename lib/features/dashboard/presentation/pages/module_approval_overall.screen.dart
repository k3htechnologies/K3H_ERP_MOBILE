import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/dashboard/data/model/module_approval.model.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/section_card.dart';

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

                                buildRowTitleValue(
                                  title: "Building",
                                  value: document.buildingNumber,
                                ),
                                buildRowTitleValue(
                                  title: "Wing",
                                  value: document.wing,
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
