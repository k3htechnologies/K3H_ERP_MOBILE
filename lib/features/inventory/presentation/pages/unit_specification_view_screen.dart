import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/inventory/data/model/building.model.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';

class UnitSpecificationViewScreen extends StatefulWidget {
  final FlatModel flatModel;
  const UnitSpecificationViewScreen({super.key, required this.flatModel});

  @override
  State<UnitSpecificationViewScreen> createState() =>
      _UnitSpecificationViewScreenState();
}

class _UnitSpecificationViewScreenState
    extends State<UnitSpecificationViewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.greyBackground,
      appBar: CustomAppBarWithBackButton(
        screenTitle: 'Unit Specification',
        authorization: AuthorizationModel(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            children: [
              _buildBasicInformationSection(),
              _buildUnitDetailsSection(),
              _buildSpecificationSection(),
            ],
          ),
        ),
      ),
    );
  }

  // BUILD TITLE WIDGET
  Widget _buildTitle({required String title}) {
    return Text(title, style: AppTextStyle.ts16SB(color: AppColor.black));
  }

  // BASIC INFORMATION SECTION
  Widget _buildBasicInformationSection() {
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.only(bottom: 10),
      decoration: commonCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle(title: "Basic Information"),
          verticalSpacing(height: 15),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildColumnTitleValue(
                title: "Unit Number",
                value: widget.flatModel.flat,
              ),
              buildColumnTitleValue(
                title: "Building",
                value: widget.flatModel.buildingNumber,
              ),
            ],
          ),
          verticalSpacing(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildColumnTitleValue(
                title: "Wing",
                value: widget.flatModel.wing,
              ),
              buildColumnTitleValue(
                title: "Floor",
                value: widget.flatModel.floor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // UNIT DETAILS SECTION
  Widget _buildUnitDetailsSection() {
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.only(bottom: 10),
      decoration: commonCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle(title: "Unit Details"),
          verticalSpacing(height: 15),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildColumnTitleValue(
                title: "Unit Type",
                value: widget.flatModel.flatType,
              ),
              buildColumnTitleValue(
                title: "Unit Configuration",
                value: widget.flatModel.flatConfiguration,
              ),
            ],
          ),
          verticalSpacing(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildColumnTitleValue(
                title: "Unit Area (Sq. ft)",
                value:
                    widget.flatModel.reraCarpetAreaSqFt > 0
                        ? widget.flatModel.reraCarpetAreaSqFt.toStringAsFixed(2)
                        : "-",
              ),
              buildColumnTitleValue(
                title: "Facing",
                value: widget.flatModel.flatFacing,
              ),
            ],
          ),
          verticalSpacing(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildColumnTitleValue(
                title: "Status",
                value: widget.flatModel.flatStatus,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // SPECIFICATION SECTION
  Widget _buildSpecificationSection() {
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.only(bottom: 10),
      decoration: commonCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle(title: "Unit Layout Specifications"),
          verticalSpacing(height: 15),
          if (widget.flatModel.specificationList.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  "No specifications available",
                  style: AppTextStyle.ts14R(color: AppColor.grey),
                ),
              ),
            )
          else
            ...widget.flatModel.specificationList.map((spec) {
              return Container(
                margin: EdgeInsets.only(bottom: 12),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColor.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColor.grey30, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(spec.flatLayout, style: AppTextStyle.ts14M()),
                    verticalSpacing(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        buildColumnTitleValue(
                          title: "Area (Sq. ft)",
                          value: spec.flatLayoutAreaSqFt.toStringAsFixed(2),
                        ),
                        buildColumnTitleValue(
                          title: "Length (Sq. ft)",
                          value: spec.flatLayoutLengthSqFt.toStringAsFixed(2),
                        ),
                        buildColumnTitleValue(
                          title: "Width (Sq. ft)",
                          value: spec.flatLayoutWidthSqFt.toStringAsFixed(2),
                        ),
                      ],
                    ),
                    if (spec.note.isNotEmpty) ...[
                      verticalSpacing(height: 8),
                      Text(
                        "Note: ${spec.note}",
                        style: AppTextStyle.ts12R(color: AppColor.grey),
                      ),
                    ],
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
