import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/inventory/data/model/building.model.dart';
import 'package:k3h_erp_app/features/project_document/drawing_document/data/model/inventory_drawing_document.model.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class InventoryDrawingDocumentOverallScreen extends StatefulWidget {
  final FlatModel? flatModel;
  final InventoryDrawingDocumentModel? inventoryDrawingDocumentModel;
  const InventoryDrawingDocumentOverallScreen({
    super.key,
    this.inventoryDrawingDocumentModel,
    this.flatModel,
  });

  @override
  State<InventoryDrawingDocumentOverallScreen> createState() =>
      _InventoryDrawingDocumentOverallScreenState();
}

class _InventoryDrawingDocumentOverallScreenState
    extends State<InventoryDrawingDocumentOverallScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Inventory Drawing Report",
        authorization: AuthorizationModel(),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              showSiteSelectedWidget(),
              verticalSpacing(),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: widget.flatModel!.buildingNumber,
                      style: AppTextStyle.ts12M(color: AppColor.grey),
                    ),
                    TextSpan(
                      text: " : ",
                      style: AppTextStyle.ts14M(color: AppColor.grey),
                    ),
                    TextSpan(
                      text: widget.flatModel!.wing,
                      style: AppTextStyle.ts12M(color: AppColor.black),
                    ),
                    TextSpan(
                      text: " > ",
                      style: AppTextStyle.ts14M(color: AppColor.grey),
                    ),
                    TextSpan(
                      text: widget.flatModel!.floor,
                      style: AppTextStyle.ts14M(color: AppColor.grey),
                    ),
                    TextSpan(
                      text: " > ",
                      style: AppTextStyle.ts14M(color: AppColor.grey),
                    ),
                    TextSpan(
                      text:
                          widget
                              .inventoryDrawingDocumentModel!
                              .drawingDocumentCategory,
                      style: AppTextStyle.ts14M(color: AppColor.grey),
                    ),
                  ],
                ),
              ),
              verticalSpacing(),
            ],
          ),
        ),
      ),
    );
  }
}
