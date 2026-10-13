import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/inventory/data/model/building.model.dart';
import 'package:k3h_erp_app/features/project_document/drawing_document/presentation/cubit/drawing_document_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class InventoryDrawingScreen extends StatefulWidget {
  final FlatModel? flatModel;

  const InventoryDrawingScreen({super.key, this.flatModel});

  @override
  State<InventoryDrawingScreen> createState() => _InventoryDrawingScreenState();
}

class _InventoryDrawingScreenState extends State<InventoryDrawingScreen> {
  late DrawingDocumentCubit _drawingDocumentCubit;

  @override
  void initState() {
    super.initState();

    _drawingDocumentCubit = context.read<DrawingDocumentCubit>();
    _drawingDocumentCubit.getInventoryDrawingDocumentList(
      context: context,
      pageNumber: 1,
      projectId: getProject().projectId,
      inventoryFloorId: widget.flatModel?.inventoryFloorId,
      floor: widget.flatModel?.floor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Inventory Drawing Report",
        authorization: AuthorizationModel(),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: showSiteSelectedWidget(),
            ),
            verticalSpacing(),
            Expanded(
              child: BlocBuilder<DrawingDocumentCubit, DrawingDocumentState>(
                builder: (context, state) {
                  if (state.isLoading == true &&
                      state.inventoryDrawingDocumentList.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final documents = state.inventoryDrawingDocumentList;
                  final Map<String, int> categoryCounts = {};
                  for (final document in documents) {
                    final category = document.drawingDocumentCategory;

                    categoryCounts[category] =
                        (categoryCounts[category] ?? 0) + 1;
                  }

                  final categories = categoryCounts.keys.toList();
                  if (documents.isEmpty) {
                    return const Center(
                      child: Text('No drawing categories found'),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.all(20),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return _buildDrawingCategoryCard(
                        title: category,
                        totalCount: categoryCounts[category]!,
                        advanceCount:
                            documents
                                .where(
                                  (document) =>
                                      document.drawingDocumentCategory ==
                                          category &&
                                      document.drawingDocumentStatus ==
                                          'Advance',
                                )
                                .length,
                        constructionCount:
                            documents
                                .where(
                                  (document) =>
                                      document.drawingDocumentCategory ==
                                          category &&
                                      document.drawingDocumentStatus
                                          .toLowerCase()
                                          .contains('good for construction'),
                                )
                                .length,
                        onTap: () {
                          final categoryDocuments =
                              documents
                                  .where(
                                    (document) =>
                                        document.drawingDocumentCategory ==
                                        category,
                                  )
                                  .toList();

                          goRouter.pushNamed(
                            AppRoutes.inventoryDrawingOverall,
                            queryParameters: {
                              "inventoryDrawingDocumentModel":
                                  Uri.encodeQueryComponent(
                                    EncryptionManager.encryptData(
                                      jsonEncode(
                                        categoryDocuments.map((document) {
                                          return {
                                            "DrawingDocumentName":
                                                document.drawingDocumentName,
                                            "DrawingDocumentURL":
                                                document.drawingDocumentUrl,
                                            "DrawingDocumentDWGURL":
                                                document.drawingDocumentDwgurl,
                                            "DrawingDocumentCategory":
                                                document
                                                    .drawingDocumentCategory,
                                            "DrawingDocumentRevisionDate":
                                                document
                                                    .drawingDocumentRevisionDate
                                                    ?.toIso8601String(),
                                            "DrawingDocumentRemark":
                                                document.drawingDocumentRemark,
                                            "DrawingDocumentStatus":
                                                document.drawingDocumentStatus,
                                            "ApprovalStatus":
                                                document.approvalStatus,
                                            "CreatedBy": document.createdBy,
                                            "CreatedDate":
                                                document.createdDate
                                                    .toIso8601String(),
                                            "ModifiedBy": document.modifiedBy,
                                            "ModifiedDate":
                                                document.modifiedDate
                                                    ?.toIso8601String(),
                                          };
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                              "flatModel": Uri.encodeQueryComponent(
                                EncryptionManager.encryptData(
                                  jsonEncode(widget.flatModel!.toJson()),
                                ),
                              ),
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawingCategoryCard({
    required String title,
    required int totalCount,
    required int advanceCount,
    required int constructionCount,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 20.0),
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: AppColor.primary, width: 4)),
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: AppColor.white.withValues(alpha: 0.5),
              spreadRadius: 0,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyle.ts14M(
                      color: AppColor.greyTitleAndValueColor,
                    ),
                  ),
                ),
                horizontalSpacing(width: 20),
                Container(
                  constraints: const BoxConstraints(minWidth: 32),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xffF0DEFF),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6.0,
                    vertical: 4.0,
                  ),
                  child: Text(
                    '$totalCount',
                    style: AppTextStyle.ts12SB(color: const Color(0xff7E22CE)),
                  ),
                ),

                horizontalSpacing(),
                Icon(LucideIcons.chevronRight, size: 20, color: AppColor.black),
              ],
            ),
            verticalSpacing(height: 12.0),
            Divider(
              height: 1,
              thickness: 0.2,
              color: AppColor.primary.withValues(alpha: 0.50),
            ),
            verticalSpacing(height: 12.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildColumnTitleValue(
                  title: "Advance",
                  value: advanceCount.toString(),
                  removeExpanded: true,
                ),
                buildColumnTitleValue(
                  title: "Good For Construction",
                  value: advanceCount.toString(),
                  removeExpanded: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
