import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/models/company.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_click_to_contact_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';

class CompanyMasterViewScreen extends StatefulWidget {
  final CompanyModel? company;
  const CompanyMasterViewScreen({super.key, this.company});

  @override
  State<CompanyMasterViewScreen> createState() =>
      _CompanyMasterViewMobileScreenState();
}

class _CompanyMasterViewMobileScreenState
    extends State<CompanyMasterViewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.greyBackground,
      appBar: CustomAppBarWithBackButton(
        screenTitle: 'Company',
        authorization: AuthorizationModel(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            children: [
              _buildBasicInformationSection(),
              _buildRegistrationAndCompliance(),
              _buildAddressSection(),
              _buildDocumentSection(),
              _buildActionDetailsSection(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 70,
          padding: EdgeInsets.all(16),
          color: AppColor.white,
          child: CustomButton(
            text: "View Company Partner",
            onPressed: () {
              if (widget.company == null) return;
              goRouter.pushNamed(
                AppRoutes.viewCompanyPartner,
                queryParameters: {
                  "company": Uri.encodeQueryComponent(
                    EncryptionManager.encryptData(jsonEncode(widget.company)),
                  ),
                },
              );
            },
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
                title: "Company Name",
                value: widget.company!.companyName,
              ),
              buildColumnTitleValue(
                title: "Firms Type",
                value: widget.company!.firmsType,
              ),
            ],
          ),
          verticalSpacing(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildColumnTitleValue(
                title: "Contact Person",
                value: widget.company!.contactPerson,
              ),
              buildColumnTitleValue(
                title: "E-mail ID",
                customValueWidget: CustomClickToContactText(
                  value: widget.company!.emailId,
                  type: ContactType.email,
                ),
                value: widget.company!.emailId,
              ),
            ],
          ),
          verticalSpacing(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildColumnTitleValue(
                title: "Mobile Number",
                value: widget.company!.mobileNumber,
                customValueWidget:
                    widget.company!.mobileNumber.isNotEmpty
                        ? CustomClickToContactText(
                          value: widget.company!.mobileNumber,
                        )
                        : null,
              ),
              buildColumnTitleValue(
                title: "Landline Number",
                value:
                    widget.company!.landLineNumber.isEmpty
                        ? "-"
                        : widget.company!.landLineNumber,
                customValueWidget: CustomClickToContactText(
                  value: widget.company!.landLineNumber,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // REGISTRATION AND COMPLIANCE SECTION
  _buildRegistrationAndCompliance() {
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.only(bottom: 10),
      decoration: commonCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle(title: "Registration & Compliance"),
          verticalSpacing(height: 15),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildColumnTitleValue(
                title: "PAN Card Number",
                value:
                    widget.company!.panNumber.isEmpty
                        ? "-"
                        : widget.company!.panNumber,
              ),
              buildColumnTitleValue(
                title: "GST Number",
                value:
                    widget.company!.gstNumber.isEmpty
                        ? "-"
                        : widget.company!.gstNumber,
              ),
            ],
          ),
          verticalSpacing(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildColumnTitleValue(
                title: "CIN Number",
                value:
                    widget.company!.cinNumber.isEmpty
                        ? "-"
                        : widget.company!.cinNumber,
              ),
              buildColumnTitleValue(
                title: "TAN Number",
                value:
                    widget.company!.tanNumber.isEmpty
                        ? "-"
                        : widget.company!.tanNumber,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ADDRESS SECTION
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
          Row(children: [buildColumnTitleValue(title: "Address", value: "")]),
          verticalSpacing(),
          Row(
            children: [
              buildColumnTitleValue(
                title: "Country",
                value: widget.company!.countryName,
              ),
              buildColumnTitleValue(
                title: "State",
                value: widget.company!.stateName,
              ),
            ],
          ),
          verticalSpacing(),
          Row(
            children: [
              buildColumnTitleValue(
                title: "District",
                value: widget.company!.districtName,
              ),
              buildColumnTitleValue(
                title: "City",
                value: widget.company!.cityName,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // DOCUMENT SECTION
  Widget _buildDocumentSection() {
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.only(bottom: 10),
      decoration: commonCardDecoration(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildTitle(title: "Document"),
          CustomIconButton(
            onPressed: () async {
              await goRouter.pushNamed(
                AppRoutes.viewCompanyDocument,
                queryParameters: {
                  "company": Uri.encodeQueryComponent(
                    EncryptionManager.encryptData(jsonEncode(widget.company)),
                  ),
                },
              );
            },
            icon: Icon(Icons.file_copy, size: 16, color: AppColor.primary),
            backgroundColor: AppColor.lightBlue,
          ),
        ],
      ),
    );
  }

  // ACTION DETAILS SECTION
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
              buildColumnTitleValue(
                title: "Created By",
                value: widget.company!.createdBy,
              ),
              buildColumnTitleValue(
                title: "Created On",
                value: formatDateTimeAsDDMMMYYYY(widget.company!.createdDate),
              ),
            ],
          ),
          verticalSpacing(),
          Row(
            children: [
              buildColumnTitleValue(
                title: "Modified By",
                value:
                    widget.company!.modifiedBy.isEmpty
                        ? "-"
                        : widget.company!.modifiedBy,
              ),
              buildColumnTitleValue(
                title: "Modified On",
                value:
                    widget.company!.modifiedDate != null
                        ? formatDateTimeAsDDMMMYYYY(
                          widget.company!.modifiedDate!,
                        )
                        : "-",
              ),
            ],
          ),
        ],
      ),
    );
  }
}
