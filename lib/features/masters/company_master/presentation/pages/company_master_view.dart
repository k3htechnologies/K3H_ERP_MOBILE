import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:k3h_erp_app/core/models/company.model.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';

class CompanyMasterViewScreen extends StatefulWidget {
  final CompanyModel? company;
  const CompanyMasterViewScreen({super.key, this.company});

  @override
  State<CompanyMasterViewScreen> createState() =>
      _CompanyMasterViewMobileScreenState();
}

class _CompanyMasterViewMobileScreenState
    extends State<CompanyMasterViewScreen> {

  // FILE SPECIFIC REUSABLE WIDGET
  Widget _buildCommonCard({required String title, required Widget content}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColor.white,
        border: Border(
          bottom: BorderSide(color: AppColor.grey.withValues(alpha: 0.3)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          verticalSpacing(),
          Text(title, style: AppTextStyle.ts16R()),
          verticalSpacing(),
          content,
          verticalSpacing(),
        ],
      ),
    );
  }

  Widget _buildRow({
    required String title,
    required String value,
    String? valueUrl,
    bool isUrl = false,
    Function? onTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(title, style: AppTextStyle.ts12R(color: AppColor.grey)),
        ),
        Flexible(
          child: GestureDetector(
            onTap: () {
              if (onTap != null) {
                onTap();
              }
            },
            child: Text(
              value,
              style: AppTextStyle.ts14R(
                color: isUrl ? AppColor.slightDarkBlue : AppColor.black,
              ).copyWith(
                decoration: valueUrl != null ? TextDecoration.underline : null,
                decorationColor: AppColor.slightDarkBlue,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompanyPartnerCard({
    required CompanyPartnerModel companyPartnerModel,
  }) {
    return StatefulBuilder(
      builder: (context, localSetState) {
        var isExpanded = ValueNotifier(false);

        return ValueListenableBuilder<bool>(
          valueListenable: isExpanded,
          builder: (context, value, _) {
            return Container(
              margin: EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: AppColor.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColor.grey.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.pink.shade100,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Name :",
                                    style: AppTextStyle.ts12R(
                                      color: AppColor.grey,
                                    ),
                                  ),
                                  Text(
                                    companyPartnerModel.fullName,
                                    style: AppTextStyle.ts14R(),
                                  ),
                                ],
                              ),
                            ),
                            Spacer(),
                            Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColor.grey.withValues(
                                          alpha: 0.4,
                                        ),
                                        spreadRadius: 2,
                                        blurRadius: 20,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: SizedBox(
                                    width: 40,
                                    height: 40,
                                    child: SimpleCircularProgressBar(
                                      progressColors: [AppColor.green],
                                      maxValue: 100,
                                      backStrokeWidth: 4,
                                      progressStrokeWidth: 4,
                                      valueNotifier: ValueNotifier(
                                        companyPartnerModel.partnerPercentage,
                                      ),
                                      size: 60,
                                      backColor: AppColor.grey.withValues(
                                        alpha: 0.2,
                                      ),
                                      mergeMode: true,
                                      onGetText:
                                          (double value) => Text(
                                        '${value.toInt()}%',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text("Share", style: AppTextStyle.ts12M()),
                              ],
                            ),
                          ],
                        ),
                        verticalSpacing(),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Gender :",
                                    style: AppTextStyle.ts12R(
                                      color: AppColor.grey,
                                    ),
                                  ),
                                  Text(
                                    companyPartnerModel.gender,
                                    style: AppTextStyle.ts14R(),
                                  ),
                                ],
                              ),
                            ),
                            Spacer(),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Mobile Number :",
                                    style: AppTextStyle.ts12R(
                                      color: AppColor.grey,
                                    ),
                                  ),
                                  Text(
                                    companyPartnerModel.mobileNumber,
                                    style: AppTextStyle.ts14R(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  if (value)
                    AnimatedSize(
                      alignment: Alignment.centerLeft,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.ease,
                      child:
                      isExpanded.value
                          ? Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "DOB :",
                                        style: AppTextStyle.ts12R(
                                          color: AppColor.grey,
                                        ),
                                      ),
                                      Text(
                                        formatDateTimeAsDDMMMYYYY(
                                          companyPartnerModel
                                              .dateOfBirth,
                                        ),
                                        style: AppTextStyle.ts14R(),
                                      ),
                                    ],
                                  ),
                                ),
                                Spacer(),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Email Id :",
                                        style: AppTextStyle.ts12R(
                                          color: AppColor.grey,
                                        ),
                                      ),
                                      Text(
                                        (companyPartnerModel.emailId.isNotEmpty)?
                                        companyPartnerModel.emailId:"-",
                                        style: AppTextStyle.ts14R(),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "PAN Card :",
                                        style: AppTextStyle.ts12R(
                                          color: AppColor.grey,
                                        ),
                                      ),
                                      Text(
                                        companyPartnerModel
                                            .panNumber
                                            .isNotEmpty
                                            ? companyPartnerModel
                                            .panNumber
                                            : "-",
                                        style: AppTextStyle.ts14R(),
                                      ),
                                    ],
                                  ),
                                ),
                                Spacer(),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Aadhaar Card :",
                                        style: AppTextStyle.ts12R(
                                          color: AppColor.grey,
                                        ),
                                      ),
                                      Text(
                                        companyPartnerModel
                                            .aadharCardNumber
                                            .isNotEmpty
                                            ? companyPartnerModel
                                            .aadharCardNumber
                                            : "-",
                                        style: AppTextStyle.ts14R(),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                          : SizedBox.shrink(),
                    ),

                  Container(
                    color: AppColor.grey.withValues(alpha: 0.05),
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {},
                              child: SvgPicture.asset(
                                AppAssets.editIcon,
                                height: 24,
                              ),
                            ),
                            horizontalSpacing(width: 20),
                            GestureDetector(
                              onTap: () {},
                              child: SvgPicture.asset(
                                AppAssets.deleteIcon,
                                height: 24,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => isExpanded.value = !isExpanded.value,
                          child: AnimatedRotation(
                            turns: isExpanded.value ? 0.5 : 0,
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColor.primary),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Icon(
                                Icons.keyboard_arrow_down,
                                size: 24,
                                color: AppColor.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.greyBackground,
      appBar: AppBar(
        centerTitle: true,
        leading: GestureDetector(
          onTap: () {
            goRouter.pop();
          },
          child: Icon(Icons.arrow_back_ios, color: AppColor.black),
        ),
        title: Text('View Details', style: AppTextStyle.ts16R()),
      ),
      body: ListView(
        children: [
          verticalSpacing(),
          // BASIC DETAILS
          _buildCommonCard(
            title: "Basic Details",
            content: Column(
              spacing: 12,
              children: [
                _buildRow(
                  title: "Company Name :",
                  value:(widget.company?.companyName != null &&
                      widget.company!.companyName.isNotEmpty)? widget.company!.companyName:'-',
                ),
                _buildRow(
                  title: "Company Type :",
                  value:(widget.company?.companyType != null &&
                      widget.company!.companyType.isNotEmpty)? widget.company!.companyType:'-',
                ),
                _buildRow(
                  title: "Mobile Number :",
                  value:(widget.company?.mobileNumber != null &&
                      widget.company!.mobileNumber.isNotEmpty)? widget.company!.mobileNumber:'-',
                ),
                _buildRow(
                  title: "Landline Number :",
                  value:
                  (widget.company?.landLineNumber != null &&
                      widget.company!.landLineNumber.isNotEmpty)
                      ?
                  widget.company!.landLineNumber
                      : "-",
                ),
                _buildRow(title: "Email :", value: widget.company!.emailId),
              ],
            ),
          ),
          verticalSpacing(height: 4),
          // GOVERNMENT IDENTIFIERS
          _buildCommonCard(
            title: "Government Identifiers",
            content: Column(
              spacing: 12,
              children: [
                _buildRow(
                  title: "CIN Number :",
                  value: widget.company?.cinNumber??'-',
                  valueUrl: widget.company!.cinURL,
                  isUrl: true,
                  // onTap:
                ),
                _buildRow(
                  title: "PAN Card Number :",
                  value: widget.company?.panNumber??'-',
                ),
                _buildRow(
                  title: "GST Certificate Number :",
                  value:
                  (widget.company?.gstNumber != null &&
                      widget.company!.gstNumber.isNotEmpty)
                      ? widget.company!.gstNumber
                      : "-",
                  valueUrl: widget.company!.gstCertificateURL,
                  isUrl: true,
                  // onTap:
                ),
                _buildRow(
                  title: "RERA Number :",
                  value: widget.company?.reraNumber??'-',
                ),
              ],
            ),
          ),
          verticalSpacing(height: 4),
          // ADDRESS
          _buildCommonCard(
            title: "Address",
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "State",
                        style: AppTextStyle.ts12R(color: AppColor.grey),
                      ),
                      Text(
                        widget.company?.stateName??'-',
                        style: AppTextStyle.ts14R(),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "District",
                        style: AppTextStyle.ts12R(color: AppColor.grey),
                      ),
                      Text(
                        widget.company?.districtName??'-',
                        style: AppTextStyle.ts14R(),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "City",
                        style: AppTextStyle.ts12R(color: AppColor.grey),
                      ),
                      Text(
                        (widget.company?.cityName!=null && widget.company!.cityName.isNotEmpty)? widget.company!.cityName:'-',
                        style: AppTextStyle.ts14R(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          verticalSpacing(height: 4),

          // COMPANY PARTNERS
          widget.company?.companyPartnerData != null
              ?
          _buildCommonCard(
              title: "Company Partners",
              content:
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: widget.company!.companyPartnerData.length,
                itemBuilder: (context, index) {
                  final partner =
                  widget.company!.companyPartnerData[index];

                  return _buildCompanyPartnerCard(
                    companyPartnerModel: partner,
                  );
                },
              )
          ):
          Container(),
        ],
      ),
    );
  }
}