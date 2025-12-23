import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/vendor_management/data/model/vendor.model.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class ViewDetailsVendorScreen extends StatefulWidget {
  final VendorModel vendor;
  const ViewDetailsVendorScreen({super.key, required this.vendor});

  @override
  State<ViewDetailsVendorScreen> createState() =>
      _ViewDetailsVendorScreenState();
}

class _ViewDetailsVendorScreenState extends State<ViewDetailsVendorScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: 'Vendor Management',
        authorization: AuthorizationModel(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            children: [
              _buildBasicInformationSection(),
              _buildGovernmentIdentifiersSection(),
              _buildAddressSection(),
              _buildDocumentSection(),
              _buildMaterialAndContractSection(),
              _buildActionDetailsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle({required String title}) {
    return Text(title, style: AppTextStyle.ts16SB(color: AppColor.black));
  }

  Widget _buildColumnTitleValue({
    required String title,
    required String value,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyle.ts14M(color: AppColor.grey)),
          Text(value, style: AppTextStyle.ts14M(color: AppColor.black)),
        ],
      ),
    );
  }

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
              _buildColumnTitleValue(
                title: "Vendor Name",
                value: widget.vendor.vendorName,
              ),
              Expanded(child: SizedBox()),
            ],
          ),
          verticalSpacing(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildColumnTitleValue(
                title: "Company Name",
                value: widget.vendor.companyName,
              ),
              _buildColumnTitleValue(
                title: "Company Type",
                value: widget.vendor.companyType,
              ),
            ],
          ),
          verticalSpacing(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildColumnTitleValue(
                title: "Mobile Number",
                value: widget.vendor.mobileNumber,
              ),
              _buildColumnTitleValue(
                title: "E-mail ID",
                value: widget.vendor.emailId,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGovernmentIdentifiersSection() {
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.only(bottom: 10),
      decoration: commonCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle(title: "Government Identifiers"),
          verticalSpacing(height: 15),
          Row(
            children: [
              _buildColumnTitleValue(
                title: "Aadhaar Card Number",
                value: widget.vendor.aadharCardNumber,
              ),
            ],
          ),
          verticalSpacing(),
          Row(
            children: [
              _buildColumnTitleValue(
                title: "PAN Card Number",
                value: widget.vendor.panCardNumber,
              ),
            ],
          ),
          verticalSpacing(),
          Row(
            children: [
              _buildColumnTitleValue(
                title: "GST Number",
                value: widget.vendor.gstNumber,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddressSection() {
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.only(bottom: 10),
      decoration: commonCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle(title: "Address Details"),
          verticalSpacing(height: 15),
          Row(
            children: [
              _buildColumnTitleValue(
                title: "Address",
                value: widget.vendor.address,
              ),
            ],
          ),
          verticalSpacing(),
          Row(
            children: [
              _buildColumnTitleValue(
                title: "Country",
                value: widget.vendor.countryName,
              ),
              _buildColumnTitleValue(
                title: "State",
                value: widget.vendor.stateName,
              ),
            ],
          ),
          verticalSpacing(),
          Row(
            children: [
              _buildColumnTitleValue(
                title: "District",
                value: widget.vendor.districtName,
              ),
              _buildColumnTitleValue(
                title: "City",
                value: widget.vendor.cityName,
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildDocumentSection() {
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.only(bottom: 10),
      decoration: commonCardDecoration(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildTitle(title: "Document"),
          CustomIconButton(onPressed: () async {
            await goRouter.pushNamed(
              AppRoutes.viewVendorDocument,
              queryParameters: {
                "vendor": Uri.encodeQueryComponent(
                  EncryptionManager.encryptData(
                    jsonEncode(widget.vendor),
                  ),
                ),
              },
            );
          }, icon: Icon(Icons.file_copy,size: 16,color: AppColor.primary,),backgroundColor: AppColor.lightBlue,)
        ],
      ),
    );
  }

  Widget _buildMaterialAndContractSection() {
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.only(bottom: 10),
      decoration: commonCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle(title: "Material & Contract"),
          verticalSpacing(height: 15),
          Row(
            children: [
              _buildColumnTitleValue(
                title: "Available Material",
                value: widget.vendor.submaterialList
                    .map((e) => e.materialName)
                    .join(", "),
              ),
            ],
          ),
          verticalSpacing(),
          Row(
            children: [
              _buildColumnTitleValue(title: "Available Contract", value: "--"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionDetailsSection() {
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.only(bottom: 10),
      decoration: commonCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle(title: "Action Details"),
          verticalSpacing(height: 15),
          Row(
            children: [
              _buildColumnTitleValue(
                title: "Created By",
                value: widget.vendor.createdBy,
              ),
              _buildColumnTitleValue(
                title: "Created On",
                value: formatDateTimeAsDDMMMYYYY(widget.vendor.createdDate),
              ),
            ],
          ),
          Row(
            children: [
              _buildColumnTitleValue(
                title: "Modified By",
                value:
                    widget.vendor.modifiedBy.isEmpty
                        ? "-"
                        : widget.vendor.modifiedBy,
              ),
              _buildColumnTitleValue(
                title: "Modified On",
                value:
                    widget.vendor.modifiedDate != null
                        ? formatDateTimeAsDDMMMYYYY(widget.vendor.modifiedDate!)
                        : "-",
              ),
            ],
          ),
        ],
      ),
    );
  }
}
