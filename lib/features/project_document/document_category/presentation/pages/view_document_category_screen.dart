import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/project_document/document/data/model/document.model.dart';
import 'package:k3h_erp_app/features/project_document/document_category/data/model/document_category.model.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class ViewDocumentCategoryScreen extends StatelessWidget {
  final DocumentCategoryModel documentCategoryModel;
  const ViewDocumentCategoryScreen({
    super.key,
    required this.documentCategoryModel,
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Document Category",
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
                          title: "Document Category",
                          value:
                              documentCategoryModel.projectDocumentCategoryName,
                        ),
                        _buildColumnTitleValue(
                          title: "Order By",
                          value: documentCategoryModel.orderBy.toString(),
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
                          value: documentCategoryModel.createdBy,
                        ),
                        _buildColumnTitleValue(
                          title: "Created Date",
                          value: formatDateTimeAsDDMMMYYYY(
                            documentCategoryModel.createdDate,
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
                              documentCategoryModel.modifiedBy.isNotEmpty
                                  ? documentCategoryModel.modifiedBy
                                  : null,
                        ),
                        _buildColumnTitleValue(
                          title: "Modified Date",
                          value:
                              documentCategoryModel.modifiedDate != null
                                  ? formatDateTimeAsDDMMMYYYY(
                                    documentCategoryModel.modifiedDate!,
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
