import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/features/masters/company_master/presentation/cubit/company_master/company_master_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/custom_click_to_contact_widget.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/network_image_widget.dart';
import 'package:k3h_erp_app/widgets/section_card.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class CompanyOverview extends StatefulWidget {
  const CompanyOverview({super.key});

  @override
  State<CompanyOverview> createState() => _CompanyOverviewState();
}

class _CompanyOverviewState extends State<CompanyOverview> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CompanyMasterCubit, CompanyMasterState>(
      builder: (context, state) {
        if ((state.isLoading ?? false) || state.companyOverview == null) {
          return loader();
        }
        final company = state.companyOverview;
        final partners = company?.companyPartnerData ?? [];
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            children: [
              SectionCard(
                title: 'Basic Information',
                children: [
                  Row(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "Company Name",
                        value: company!.companyName,
                      ),
                      buildColumnTitleValue(
                        title: "Firms Type",
                        value: company.firmsType,
                      ),
                    ],
                  ),
                  Row(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "Contact Person",
                        value: company.contactPerson,
                      ),
                      buildColumnTitleValue(
                        title: "Mobile Number",
                        value: company.mobileNumber,
                        customValueWidget:
                            company.mobileNumber.isNotEmpty
                                ? CustomClickToContactText(
                                  countryCode: "+91",
                                  value: company.mobileNumber,
                                )
                                : null,
                      ),
                    ],
                  ),
                  Row(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "E-mail ID",
                        customValueWidget: CustomClickToContactText(
                          value: company.emailId,
                          type: ContactType.email,
                        ),
                        value: company.emailId,
                      ),
                      buildColumnTitleValue(
                        title: "Landline Number",
                        value:
                            company.landLineNumber.isEmpty
                                ? "-"
                                : company.landLineNumber,
                        customValueWidget: CustomClickToContactText(
                          countryCode: "",
                          type: ContactType.landLine,
                          value: company.landLineNumber,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SectionCard(
                title: 'Government Identifiers',
                titleTextColor: AppColor.orange,
                headerBackgroundColor: AppColor.lightOrangeBg.withValues(
                  alpha: 0.5,
                ),
                children: [
                  Row(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "PAN Card Number",
                        value:
                            company.panNumber.isEmpty ? "-" : company.panNumber,
                        customValueWidget: buildDocumentRow(
                          iconWithoutBg: true,

                          title: "PAN Card",
                          context: context,
                          docNumber:
                              company.panNumber.isEmpty
                                  ? "-"
                                  : company.panNumber,
                          url: company.panCardURL,
                        ),
                      ),
                      buildColumnTitleValue(
                        title: "GST Number",
                        value:
                            company.gstNumber.isEmpty ? "-" : company.gstNumber,
                        customValueWidget: buildDocumentRow(
                          iconWithoutBg: true,

                          title: "GST Document",
                          context: context,
                          docNumber:
                              company.gstNumber.isEmpty
                                  ? "-"
                                  : company.gstNumber,
                          url: company.gstCertificateURL,
                        ),
                      ),
                    ],
                  ),

                  Row(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "CIN Number",
                        value:
                            company.cinNumber.isEmpty ? "-" : company.cinNumber,
                        customValueWidget: buildDocumentRow(
                          iconWithoutBg: true,

                          title: "CIN Document",
                          context: context,
                          docNumber:
                              company.cinNumber.isEmpty
                                  ? "-"
                                  : company.cinNumber,
                          url: company.cinURL,
                        ),
                      ),
                      buildColumnTitleValue(
                        title: "TAN Number",
                        value:
                            company.tanNumber.isEmpty ? "-" : company.tanNumber,
                        customValueWidget: buildDocumentRow(
                          iconWithoutBg: true,

                          title: "TAN Document",
                          context: context,
                          docNumber:
                              company.tanNumber.isEmpty
                                  ? "-"
                                  : company.tanNumber,
                          url: company.tanURL,
                        ),
                      ),
                    ],
                  ),

                  Row(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "Company Letter Head",
                        value: "",
                        customValueWidget: buildDocumentRow(
                          iconWithoutBg: true,

                          title: "Company Letter Head",
                          context: context,
                          docNumber: "View Letter Head",
                          url: company.companyLetterheadHeaderURL,
                        ),
                      ),
                      buildColumnTitleValue(
                        title: "Company Letter Footer",
                        value: "",
                        customValueWidget: buildDocumentRow(
                          iconWithoutBg: true,

                          title: "Company Letter Footer",
                          context: context,
                          docNumber: "View Letter Footer",
                          url: company.companyLetterheadFooterURL,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SectionCard(
                title: 'Address Details',
                titleTextColor: Colors.blue,
                headerBackgroundColor: Colors.blue.shade100.withValues(
                  alpha: 0.5,
                ),
                children: [
                  Row(
                    spacing: 10,
                    children: [
                      buildColumnTitleValue(
                        title: "Country",
                        value: company.countryName,
                      ),
                      buildColumnTitleValue(
                        title: "State",
                        value: company.stateName,
                      ),
                    ],
                  ),
                  Row(
                    spacing: 10,
                    children: [
                      buildColumnTitleValue(
                        title: "District",
                        value: company.districtName,
                      ),
                      buildColumnTitleValue(
                        title: "City",
                        value: company.cityName,
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                decoration: commonCardDecoration(),
                margin: EdgeInsets.only(bottom: 16.h),
                height: partners.isNotEmpty ? 350.h : 250.h,
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.lightPurpleBg2,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                      ),
                      child: Text(
                        "Partners (${partners.length})",
                        style: AppTextStyle.ts14SB(color: AppColor.purple700),
                      ),
                    ),
                    verticalSpacing(),
                    Expanded(
                      child: Container(
                        child:
                            partners.isEmpty
                                ? Center(
                                  child: noDataWidget(
                                    iconSize: 120.h,
                                    message: "No Partner Data Available",
                                  ),
                                )
                                : ListView.builder(
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  itemCount: partners.length,
                                  itemBuilder: (context, index) {
                                    final p = partners[index];
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.grey.shade300,
                                        ),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Color(0x08000000),
                                            blurRadius: 3,
                                            offset: Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              NetworkImageWidget(
                                                imageUrl: p.photoURL,
                                                width: 60,
                                                height: 60,
                                                fit: BoxFit.cover,
                                                borderRadius:
                                                    BorderRadius.circular(55),
                                              ),
                                              horizontalSpacing(width: 16),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      p.fullName,
                                                      style:
                                                          AppTextStyle.ts16M(),
                                                    ),
                                                    if (p.partnerPercentage > 0)
                                                      Container(
                                                        margin: EdgeInsets.only(
                                                          top: 5,
                                                        ),
                                                        padding:
                                                            EdgeInsets.symmetric(
                                                              horizontal: 8,
                                                              vertical: 2,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: AppColor
                                                              .darkGreen10
                                                              .withValues(
                                                                alpha: 0.1,
                                                              ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                10,
                                                              ),
                                                        ),
                                                        child: Text(
                                                          "${p.partnerPercentage.addCommas()}% Share",
                                                          style: AppTextStyle.ts12M(
                                                            color:
                                                                AppColor
                                                                    .darkGreen10,
                                                          ),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          Divider(
                                            height: 20.h,
                                            color: AppColor.lightBlue,
                                          ),
                                          Row(
                                            children: [
                                              buildColumnTitleValue(
                                                title: "Mobile Number",
                                                value: p.mobileNumber,
                                                customValueWidget:
                                                    CustomClickToContactText(
                                                      countryCode: "+91",
                                                      value: p.mobileNumber,
                                                    ),
                                              ),
                                              buildColumnTitleValue(
                                                title: "E-mail ID",
                                                value: p.emailId,
                                                customValueWidget:
                                                    CustomClickToContactText(
                                                      value: p.emailId,
                                                      type: ContactType.email,
                                                    ),
                                              ),
                                            ],
                                          ),
                                          verticalSpacing(),
                                          Row(
                                            children: [
                                              buildColumnTitleValue(
                                                title: "DOB",
                                                value:
                                                    formatDateTimeAsDDMMMYYYY(
                                                      p.dateOfBirth,
                                                    ),
                                              ),
                                              buildColumnTitleValue(
                                                title: "Gender",
                                                value: p.gender,
                                              ),
                                            ],
                                          ),
                                          verticalSpacing(),
                                          Row(
                                            spacing: 10,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              buildColumnTitleValue(
                                                title: "PAN Card Number",
                                                value:
                                                    p.panNumber.isEmpty
                                                        ? "-"
                                                        : p.panNumber,
                                                customValueWidget:
                                                    buildDocumentRow(
                                                      iconWithoutBg: true,

                                                      title: "PAN Card",
                                                      context: context,
                                                      docNumber:
                                                          p.panNumber.isEmpty
                                                              ? "-"
                                                              : p.panNumber,
                                                      url: p.panCardURL,
                                                    ),
                                              ),
                                              buildColumnTitleValue(
                                                title: "Aadhar Number",
                                                value:
                                                    p.aadharCardNumber.isEmpty
                                                        ? "-"
                                                        : p.aadharCardNumber,
                                                customValueWidget:
                                                    buildDocumentRow(
                                                      iconWithoutBg: true,
                                                      title: "Aadhar Number",
                                                      context: context,
                                                      docNumber:
                                                          p
                                                                  .aadharCardURL
                                                                  .isEmpty
                                                              ? "-"
                                                              : p.aadharCardNumber,
                                                      url: p.aadharCardURL,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                      ),
                    ),
                  ],
                ),
              ),
              SectionCard(
                title: 'Action Details',
                titleTextColor: AppColor.black,
                headerBackgroundColor: AppColor.grey20,
                children: [
                  Row(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "Created By",
                        value: company.createdBy,
                      ),
                      buildColumnTitleValue(
                        title: "Created Date",
                        value: formatDate(company.createdDate),
                      ),
                    ],
                  ),
                  Row(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "Modified By",
                        value: company.modifiedBy,
                      ),
                      buildColumnTitleValue(
                        title: "Modified Date",
                        value: formatDate(company.modifiedDate),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
