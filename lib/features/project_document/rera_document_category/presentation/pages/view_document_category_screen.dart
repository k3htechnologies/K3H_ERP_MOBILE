import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/project_document/rera_document_category/data/model/rera_document_category.model.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class ViewRERADocumentCategoryScreen extends StatelessWidget {
  final RERADocumentCategoryModel reraDocumentCategoryModel;
  const ViewRERADocumentCategoryScreen({
    super.key,
    required this.reraDocumentCategoryModel,
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "RERA Document Category",
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
                      "Project Document Category Details",
                      style: AppTextStyle.ts16SB(),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildColumnTitleValue(
                          title: "RERA Document Category",
                          value:
                              reraDocumentCategoryModel
                                  .projectRERADocumentCategoryName,
                        ),
                        _buildColumnTitleValue(
                          title: "Order By",
                          value: reraDocumentCategoryModel.orderBy.toString(),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildColumnTitleValue(
                          title: "Document Count",
                          value:
                              reraDocumentCategoryModel.documentCount
                                  .toString(),
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
                        _buildColumnTitleValue(
                          title: "Created By",
                          value: reraDocumentCategoryModel.createdBy,
                        ),
                        _buildColumnTitleValue(
                          title: "Created Date",
                          value: formatDateTimeAsDDMMMYYYY(
                            reraDocumentCategoryModel.createdDate,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildColumnTitleValue(
                          title: "Modified By",
                          value:
                              reraDocumentCategoryModel.modifiedBy.isNotEmpty
                                  ? reraDocumentCategoryModel.modifiedBy
                                  : null,
                        ),
                        _buildColumnTitleValue(
                          title: "Modified Date",
                          value:
                              reraDocumentCategoryModel.modifiedDate != null
                                  ? formatDateTimeAsDDMMMYYYY(
                                    reraDocumentCategoryModel.modifiedDate!,
                                  )
                                  : null,
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

  Widget _buildColumnTitleValue({
    required String title,
    required String? value,
  }) {
    if (value == null) {
      return SizedBox.shrink();
    }
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyle.ts14M(color: AppColor.grey)),
          verticalSpacing(height: 4),
          Text(value, style: AppTextStyle.ts14M()),
        ],
      ),
    );
  }
}
