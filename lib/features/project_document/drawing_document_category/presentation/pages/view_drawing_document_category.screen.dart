import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/project_document/drawing_document_category/data/model/drawing_document_category.model.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class ViewDrawingDocumentCategoryScreen extends StatelessWidget {
  final DrawingDocumentCategoryModel drawingDocumentCategoryModel;
  const ViewDrawingDocumentCategoryScreen({
    super.key,
    required this.drawingDocumentCategoryModel,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Drawing Document Category",
        authorization: AuthorizationModel(),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            verticalSpacing(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: showSiteSelectedWidget(),
            ),
            Expanded(
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
                            "Drawing Document Category Details",
                            style: AppTextStyle.ts16SB(),
                          ),
                          buildColumnTitleValue(
                            title: "Document Category",
                            value:
                                drawingDocumentCategoryModel
                                    .drawingDocumentCategoryName,
                            removeExpanded: true,
                          ),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildColumnTitleValue(
                                title: "Sequence",
                                value:
                                    drawingDocumentCategoryModel.orderBy
                                        .toString(),
                              ),
                              buildColumnTitleValue(
                                title: "Document Count",
                                value:
                                    drawingDocumentCategoryModel.documentCount
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
                                value: drawingDocumentCategoryModel.createdBy,
                              ),
                              buildColumnTitleValue(
                                title: "Created Date",
                                value: formatDate(
                                  drawingDocumentCategoryModel.createdDate,
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
                                    drawingDocumentCategoryModel
                                            .modifiedBy
                                            .isNotEmpty
                                        ? drawingDocumentCategoryModel
                                            .modifiedBy
                                        : '-',
                              ),
                              buildColumnTitleValue(
                                title: "Modified Date",
                                value:
                                    drawingDocumentCategoryModel.modifiedDate !=
                                            null
                                        ? formatDate(
                                          drawingDocumentCategoryModel
                                              .modifiedDate!,
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
          ],
        ),
      ),
    );
  }
}
