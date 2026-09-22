import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/project_document/test_document_category/data/model/test_document_category.model.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';

class ViewTestDocumentCategoryScreen extends StatelessWidget {
  final TestDocumentCategoryModel testDocumentCategoryModel;
  const ViewTestDocumentCategoryScreen({
    super.key,
    required this.testDocumentCategoryModel,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Test Document Category",
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
                      "Test Document Category Details",
                      style: AppTextStyle.ts16SB(),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildColumnTitleValue(
                          title: "Document Category",
                          value:
                              testDocumentCategoryModel
                                  .testDocumentCategoryName,
                        ),
                        buildColumnTitleValue(
                          title: "Sequence",
                          value: testDocumentCategoryModel.orderBy.toString(),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildColumnTitleValue(
                          title: "Document Count",
                          value:
                              testDocumentCategoryModel.documentCount
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
                        buildColumnTitleValue(
                          title: "Created By",
                          value: testDocumentCategoryModel.createdBy,
                        ),
                        buildColumnTitleValue(
                          title: "Created Date",
                          value: formatDate(
                            testDocumentCategoryModel.createdDate,
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
                              testDocumentCategoryModel.modifiedBy.isNotEmpty
                                  ? testDocumentCategoryModel.modifiedBy
                                  : '-',
                        ),
                        buildColumnTitleValue(
                          title: "Modified Date",
                          value:
                              testDocumentCategoryModel.modifiedDate != null
                                  ? formatDate(
                                    testDocumentCategoryModel.modifiedDate!,
                                  )
                                  : '-',
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
