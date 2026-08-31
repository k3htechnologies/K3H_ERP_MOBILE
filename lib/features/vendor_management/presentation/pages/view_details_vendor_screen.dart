import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/vendor_management/data/model/vendor.model.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/chip_style_tab_bar.dart';
import 'package:k3h_erp_app/widgets/custom_click_to_contact_widget.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/section_card.dart';
import 'package:k3h_erp_app/widgets/status/status.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../widgets/custom_chip_for_status_widget.dart';

class ViewDetailsVendorScreen extends StatefulWidget {
  final VendorModel vendor;
  const ViewDetailsVendorScreen({super.key, required this.vendor});

  @override
  State<ViewDetailsVendorScreen> createState() =>
      _ViewDetailsVendorScreenState();
}

class _ViewDetailsVendorScreenState extends State<ViewDetailsVendorScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: 'Vendor Management',
        authorization: AuthorizationModel(),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Container(
                decoration: commonCardDecoration(),
                padding: const EdgeInsets.all(16),
                margin: EdgeInsets.only(bottom: 12.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 25.r,
                              child: Text(
                                getInitials(widget.vendor.vendorName),
                                style: AppTextStyle.ts18SB(
                                  color: AppColor.white,
                                ),
                              ),
                            ),
                            if (widget.vendor.verifiedNonVerified
                                    .toLowerCase() ==
                                'verified')
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    LucideIcons.badgeCheck,
                                    size: 18,
                                    color: AppColor.primary,
                                  ),
                                ),
                              ),
                          ],
                        ),

                        horizontalSpacing(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      widget.vendor.vendorName,
                                      style: AppTextStyle.ts18SB(),
                                    ),
                                  ),
                                  activeInactiveStatusWidget(
                                    widget.vendor.verifiedNonVerified,
                                  ),
                                ],
                              ),

                              verticalSpacing(height: 2),

                              Text(
                                widget.vendor.companyName,
                                style: AppTextStyle.ts14R(color: AppColor.grey),
                              ),

                              verticalSpacing(height: 4),

                              Row(
                                children: [
                                  Icon(
                                    LucideIcons.mapPin,
                                    size: 14,
                                    color: AppColor.grey,
                                  ),
                                  horizontalSpacing(width: 4),
                                  Expanded(
                                    child: Text(
                                      "${widget.vendor.cityName}, ${widget.vendor.stateName}",
                                      style: AppTextStyle.ts12R(
                                        color: AppColor.grey,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    verticalSpacing(),
                    statusChip(
                      widget.vendor.vendorType,
                      AppColor.lightOrangeBg.withValues(alpha: 0.5),
                      AppColor.orange,
                      textStyle: AppTextStyle.ts12M().copyWith(
                        color: AppColor.orange,
                      ),
                      leading: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppColor.orange,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildBasicInformationSection(),
                      _buildGovernmentIdentifiersSection(),
                      _buildAddressSection(),
                      _buildMaterialAndContractSection(),
                      _buildActionDetailsSection(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // BUILD BASIC INFORMATION SECTION
  Widget _buildBasicInformationSection() {
    return SectionCard(
      title: "Personal Information",
      iconContainerColor: AppColor.lightBlue,
      iconColor: AppColor.primary,
      icon: LucideIcons.user,
      childSpacing: 0,
      children: [
        buildRowTitleValue(
          title: "Vendor Name",
          fixesWidth: 120.w,
          value: widget.vendor.vendorName,
          singleLine: false,
        ),

        buildRowTitleValue(
          title: "Company Name",
          fixesWidth: 120.w,
          value: widget.vendor.companyName,
          singleLine: false,
        ),
        buildRowTitleValue(
          fixesWidth: 120.w,
          title: "Company Type",
          value: widget.vendor.companyType,
          singleLine: false,
        ),
        buildRowTitleValue(
          title: "Mobile Number",
          fixesWidth: 120.w,
          value: widget.vendor.mobileNumber,
          customValueWidget: CustomClickToContactText(
            countryCode: widget.vendor.mobileNumberCountryCode,
            value: widget.vendor.mobileNumber,
          ),
        ),  
        buildRowTitleValue(
          title: "E-mail ID",
          fixesWidth: 120.w,
          value: widget.vendor.emailId,
          customValueWidget: CustomClickToContactText(
            value: widget.vendor.emailId,
            type: ContactType.email,
          ),
        ),
      ],
    );
  }

  // BUILD GOVERNMENT IDENTIFIERS SECTION
  Widget _buildGovernmentIdentifiersSection() {
    final List<Map<String, String>> documents = [
      {
        "title": "PAN Card",
        "number": widget.vendor.panCardNumber,
        "url": widget.vendor.panCardUrl,
      },
      {
        "title": "Aadhaar Card",
        "number": widget.vendor.aadharCardNumber,
        "url": widget.vendor.aadharCardUrl,
      },
      {
        "title": "GST Certificate",
        "number": widget.vendor.gstNumber,
        "url": widget.vendor.gstCertificateUrl,
      },
    ];

    final validDocuments =
        documents.where((doc) => (doc["url"] ?? "").isNotEmpty).toList();

    if (validDocuments.isEmpty) {
      return Center(
        child: noDataWidget(message: "No Documents Available", iconSize: 100),
      );
    }
    return SectionCard(
      title: "Government Identifiers",
      iconColor: AppColor.darkGreen10,
      iconContainerColor: AppColor.darkGreen10.withValues(alpha: 0.1),
      icon: LucideIcons.badgeCheck,
      childSpacing: 0,
      children:
          List.generate((validDocuments.length), (index) {
            final doc = validDocuments[index];

            return buildRowTitleValue(
              title: doc['title'] ?? "-",
              value:
                  (doc['number'] != null && doc['number']!.isNotEmpty)
                      ? doc['number']!
                      : "-",
              fixesWidth: 120.w,
              customValueWidget: buildDocumentRow(
                iconWithoutBg: true,
                context: context,
                docNumber:
                    (doc['number'] != null && doc['number']!.isNotEmpty)
                        ? doc['number']!
                        : "-",
                url: doc['url'] ?? "-",
                title: doc['title']!,
              ),
            );
          }).toList(),
    );
  }

  // BUILD ADDRESS SECTION
  Widget _buildAddressSection() {
    return SectionCard(
      title: "Address Details",
      iconContainerColor: AppColor.lightOrange.withValues(alpha: 0.4),
      iconColor: AppColor.rustOrange,
      icon: LucideIcons.mapPin,
      childSpacing: 0,
      children: [
        buildRowTitleValue(
          singleLine: false,
          title: "Country",
          fixesWidth: 120.w,
          value: widget.vendor.countryName,
        ),
        buildRowTitleValue(
          singleLine: false,
          title: "State",
          fixesWidth: 120.w,
          value: widget.vendor.stateName,
        ),

        buildRowTitleValue(
          singleLine: false,
          title: "District",
          fixesWidth: 120.w,
          value: widget.vendor.districtName,
        ),
        buildRowTitleValue(
          singleLine: false,
          title: "City",
          fixesWidth: 120.w,
          value: widget.vendor.cityName,
        ),

        buildRowTitleValue(
          singleLine: false,
          title: "Office Address",
          fixesWidth: 120.w,
          value: widget.vendor.address,
        ),
      ],
    );
  }

  // BUILD MATERIAL AND CONTRACT SECTION
  Widget _buildMaterialAndContractSection() {
    return SectionCard(
      title: "Material and Contract Management",
      icon: LucideIcons.filePenLine300,
      iconColor: AppColor.darkGreen10,
      iconContainerColor: AppColor.darkGreen10.withValues(alpha: 0.1),
      children: [
        Column(
          children: [
            ChipStyleTabBar(
              controller: _tabController,
              tabs: [
                'Material (${widget.vendor.submaterialList.length})',
                'Contract',
              ],
              margin: EdgeInsets.zero,
              style: ChipTabBarStyle.underline,
            ),
            verticalSpacing(),
            SizedBox(
              height: widget.vendor.submaterialList.length > 1 ? 320.h : 200.h,
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildMaterialTabContent(),
                  _buildContractTabContent(),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMaterialTabContent() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Builder(
              builder: (context) {
                if (widget.vendor.submaterialList.isEmpty) {
                  return Center(
                    child: noDataWidget(
                      message: 'No data found',
                      iconSize: 120,
                    ),
                  );
                }
                final list = widget.vendor.submaterialList;
                return ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: list.length,
                  separatorBuilder: (_, __) => verticalSpacing(height: 8),
                  itemBuilder: (context, index) {
                    final item = list[index];

                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColor.lightGrey),
                      ),
                      child: Row(
                        spacing: 10,
                        children: [
                          CircleAvatar(
                            backgroundColor: AppColor.lightBlue,
                            child: Icon(
                              LucideIcons.package,
                              size: 18,
                              color: AppColor.primary,
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.subMaterialName,
                                  style: AppTextStyle.ts14M(
                                    color: AppColor.black,
                                  ),
                                ),
                                Text(
                                  item.materialName,
                                  style: AppTextStyle.ts12R(
                                    color: AppColor.grey,
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContractTabContent() {
    return Center(child: noDataWidget(iconSize: 140));
  }

  // BUILD ACTION DETAILS SECTION
  Widget _buildActionDetailsSection() {
    return SectionCard(
      title: "Action Details",
      iconContainerColor: AppColor.greyBackground,
      iconColor: AppColor.grey,
      icon: LucideIcons.history,
      childSpacing: 0,
      children: [
        buildRowTitleValue(
          title: "Created By",
          value: widget.vendor.createdBy,
          fixesWidth: 120.w,
          singleLine: false,
        ),
        buildRowTitleValue(
          title: "Created Date",
          value: formatDate(widget.vendor.createdDate),
          fixesWidth: 120.w,
          singleLine: false,
        ),

        buildRowTitleValue(
          title: "Modified By",
          fixesWidth: 120.w,
          value:
              (widget.vendor.modifiedBy.isNotEmpty)
                  ? widget.vendor.modifiedBy
                  : "-",
          singleLine: false,
        ),
        buildRowTitleValue(
          title: "Modified Date",
          fixesWidth: 120.w,
          value:
              (widget.vendor.modifiedDate == null ||
                      widget.vendor.modifiedDate.toString().trim().isEmpty)
                  ? "-"
                  : formatDate(widget.vendor.modifiedDate),
          singleLine: false,
        ),
      ],
    );
  }
}
