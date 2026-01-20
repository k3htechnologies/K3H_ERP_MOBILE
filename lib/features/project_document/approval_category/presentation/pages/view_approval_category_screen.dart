import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/project_document/approval_category/data/model/approval_category.model.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';

class ViewApprovalCategoryScreen extends StatelessWidget {
  final ApprovalDocumentCategoryModel approvalCategoryModel;
  const ViewApprovalCategoryScreen({
    super.key,
    required this.approvalCategoryModel,
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Approval Document Category",
        authorization: AuthorizationModel(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: Column(
            spacing: 10,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: commonCardDecoration(),
                child: Column(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Approval Document Category Master Details",
                      style: AppTextStyle.ts16SB(),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildColumnTitleValue(
                          title: "Document Category",
                          value:
                              approvalCategoryModel
                                  .approvalDocumentCategoryName,
                        ),
                        buildColumnTitleValue(
                          title: "Order By",
                          value: approvalCategoryModel.orderBy.toString(),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildColumnTitleValue(
                          title: "Document Count",
                          value: approvalCategoryModel.documentCount.toString(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Container(
                padding: EdgeInsets.all(16),
                decoration: commonCardDecoration(),
                child: Column(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Action Details", style: AppTextStyle.ts16SB()),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildColumnTitleValue(
                          title: "Created By",
                          value: approvalCategoryModel.createdBy,
                        ),
                        buildColumnTitleValue(
                          title: "Created Date",
                          value: formatDateTimeAsDDMMMYYYY(
                            approvalCategoryModel.createdDate,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildColumnTitleValue(
                          title: "Modified By",
                          value:
                              approvalCategoryModel.modifiedBy.isNotEmpty
                                  ? approvalCategoryModel.modifiedBy
                                  : "",
                        ),
                        buildColumnTitleValue(
                          title: "Modified Date",
                          value:
                              approvalCategoryModel.modifiedDate != null
                                  ? formatDateTimeAsDDMMMYYYY(
                                    approvalCategoryModel.modifiedDate!,
                                  )
                                  : "",
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
