import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/inventory/data/model/building.model.dart';
import 'package:k3h_erp_app/features/project_document/drawing_document/data/model/inventory_drawing_document.model.dart';
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
                          goRouter.pushNamed(
                            AppRoutes.inventoryDrawingOverall,
                            queryParameters: {
                              "inventoryDrawingDocumentModel":
                                  Uri.encodeQueryComponent(
                                    EncryptionManager.encryptData(
                                      jsonEncode(
                                        InventoryDrawingDocumentModel(
                                          drawingDocumentName:
                                              documents[index]
                                                  .drawingDocumentName,
                                          drawingDocumentUrl:
                                              documents[index]
                                                  .drawingDocumentUrl,
                                          drawingDocumentDwgurl:
                                              documents[index]
                                                  .drawingDocumentDwgurl,
                                          drawingDocumentCategory:
                                              documents[index]
                                                  .drawingDocumentCategory,
                                          drawingDocumentRevisionDate:
                                              documents[index]
                                                  .drawingDocumentRevisionDate,
                                          drawingDocumentRemark:
                                              documents[index]
                                                  .drawingDocumentRemark,
                                          drawingDocumentStatus:
                                              documents[index]
                                                  .drawingDocumentStatus,
                                          approvalStatus:
                                              documents[index].approvalStatus,
                                          createdBy: documents[index].createdBy,
                                          createdDate:
                                              documents[index].createdDate,
                                          modifiedBy:
                                              documents[index].modifiedBy,
                                          modifiedDate:
                                              documents[index].modifiedDate,
                                        ),
                                      ),
                                    ),
                                  ),
                              "flatModel": Uri.encodeQueryComponent(
                                EncryptionManager.encryptData(
                                  jsonEncode(
                                    FlatModel(
                                      inventoryFlatId: 0,
                                      uniquekey: "",
                                      inventoryBuildingId:
                                          widget.flatModel!.inventoryBuildingId,
                                      buildingNumber:
                                          widget.flatModel!.buildingNumber,
                                      inventoryFlatFloorBasementPodiumWingId:
                                          widget
                                              .flatModel!
                                              .inventoryFlatFloorBasementPodiumWingId,
                                      wing: widget.flatModel!.wing,
                                      inventoryFloorId:
                                          widget.flatModel!.inventoryFloorId,
                                      floor: widget.flatModel!.floor,
                                      slabHeight: widget.flatModel!.slabHeight,
                                      drawingCount:
                                          widget.flatModel!.drawingCount,
                                      parkingCount:
                                          widget.flatModel!.parkingCount,
                                      note: "",
                                      flat: "",
                                      reraCarpetAreaSqFt: 0,
                                      flatType: "",
                                      flatConfiguration: "",
                                      flatStatus: "",
                                      ownerName: "",
                                      flatFacing: "",
                                      createdBy: "",
                                      createdById: 0,
                                      modifiedBy: "",
                                      modifiedById: 0,
                                      createdDate: DateTime.now(),
                                      modifiedDate: DateTime.now(),
                                      bookingId: 0,
                                      bookingCreatedById: 0,
                                      bookingCreatedBy: "",
                                      bookingCreatedDate: DateTime.now(),
                                      specificationList: [],
                                    ),
                                  ),
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
                    style: AppTextStyle.ts16M(
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
              thickness: 1,
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
                ),
                horizontalSpacing(width: 12),
                buildColumnTitleValue(
                  title: "Good For Construction",
                  value: advanceCount.toString(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
