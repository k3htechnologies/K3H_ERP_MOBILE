import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/features/channel_partner/data/model/channel_partner.model.dart';
import 'package:k3h_erp_app/features/channel_partner/presentation/cubit/channel_partner_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/custom_click_to_contact_widget.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/status/status.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

Widget channelPartnerOverview(ChannelPartnerModel channelPartnerModel) {
  return Builder(
    builder: (context) {
      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: commonCardDecoration(),
              padding: const EdgeInsets.all(16),
              margin: EdgeInsets.only(bottom: 12.h),
              child: Column(
                spacing:
                    (channelPartnerModel.reraNumber.trim().isNotEmpty ||
                            channelPartnerModel.gstNumber.trim().isNotEmpty)
                        ? 12
                        : 0,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            child: Text(
                              getInitials(channelPartnerModel.name),
                              style: AppTextStyle.ts18SB(color: AppColor.white),
                            ),
                          ),
                          if (channelPartnerModel.verifiedNonVerified
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
                                    channelPartnerModel.name,
                                    style: AppTextStyle.ts18SB(),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        (channelPartnerModel.noOfEnquiry > 0)
                                            ? AppColor.lightGreenBg.withValues(
                                              alpha: .3,
                                            )
                                            : AppColor.lightRed2,
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(
                                      color:
                                          channelPartnerModel.noOfEnquiry > 0
                                              ? AppColor.darkGreen.withValues(
                                                alpha: 0.2,
                                              )
                                              : AppColor.red.withValues(
                                                alpha: 0.2,
                                              ),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color:
                                              (channelPartnerModel.noOfEnquiry >
                                                      0)
                                                  ? AppColor.darkGreen
                                                      .withValues(alpha: 0.8)
                                                  : AppColor.red,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      horizontalSpacing(width: 6),
                                      Text(
                                        channelPartnerModel.noOfEnquiry > 0
                                            ? "ACTIVE"
                                            : "INACTIVE",
                                        style: AppTextStyle.ts12SB(
                                          color:
                                              channelPartnerModel.noOfEnquiry >
                                                      0
                                                  ? AppColor.darkGreen
                                                      .withValues(alpha: 0.8)
                                                  : AppColor.darkRed,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            verticalSpacing(height: 2),

                            Text(
                              "${channelPartnerModel.designation} at ${channelPartnerModel.companyName}",
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
                                    "${channelPartnerModel.cityName}, ${channelPartnerModel.stateName}",
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

                  Row(
                    children: [
                      if (channelPartnerModel.reraNumber.trim().isNotEmpty) ...[
                        _verificationChip(
                          "RERA Verified",
                          LucideIcons.badgeCheck,
                        ),
                        horizontalSpacing(width: 10),
                      ],
                      if (channelPartnerModel.gstNumber.trim().isNotEmpty)
                        _verificationChip(
                          "GST Verified",
                          LucideIcons.badgeCheck,
                        ),
                    ],
                  ),
                ],
              ),
            ),

            _sectionCard(
              title: "Compliance Status",
              bgColor: AppColor.lightPurple,
              iconColor: AppColor.purple,
              icon: LucideIcons.handshake,
              children: [
                GestureDetector(
                  onTap: () {
                    if (channelPartnerModel.aopDocumentUrl.isNotEmpty) {
                      showFilePreviewDialog(
                        title: "AOP Document",
                        context,
                        channelPartnerModel.aopDocumentUrl.split(","),
                      );
                    }
                  },
                  child: buildRowTitleValue(
                    singleLine: false,
                    title: "Status",
                    value: channelPartnerModel.aopStatus,
                    customValueWidget: aopStatusWidget(
                      channelPartnerModel.aopStatus,
                      trailing:
                          channelPartnerModel.aopStatus.toLowerCase() ==
                                  "non - aop"
                              ? null
                              : Icon(
                                Icons.remove_red_eye_outlined,
                                color:
                                    channelPartnerModel
                                            .aopDocumentUrl
                                            .isNotEmpty
                                        ? AppColor.primary
                                        : AppColor.grey,
                                size: 16,
                              ),
                    ),
                  ),
                ),
                buildRowTitleValue(
                  singleLine: false,
                  title: "Validity",
                  value:
                      (channelPartnerModel.aopFromDate == null &&
                              channelPartnerModel.aopToDate == null)
                          ? "-"
                          : "${formatDateTimeAsDDMMMYYYY(channelPartnerModel.aopFromDate)} - ${formatDateTimeAsDDMMMYYYY(channelPartnerModel.aopToDate)}",
                ),
                verticalSpacing(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        goRouter.pushNamed(
                          AppRoutes.channelPartnerSalesMatrics,
                          queryParameters: {
                            "channelPartnerId": Uri.encodeQueryComponent(
                              EncryptionManager.encryptData(
                                channelPartnerModel.channelPartnerId.toString(),
                              ),
                            ),
                            "channelPartnerName": Uri.encodeQueryComponent(
                              EncryptionManager.encryptData(
                                channelPartnerModel.name,
                              ),
                            ),
                          },
                        );
                        await context
                            .read<ChannelPartnerCubit>()
                            .resetAopState();
                      },
                      child: Text(
                        "View Status Matrics",
                        style: AppTextStyle.ts12SB(
                          color: AppColor.primary,
                        ).copyWith(
                          decorationColor: AppColor.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            _sectionCard(
              title: "Personal Information",
              bgColor: AppColor.lightBlue,
              iconColor: AppColor.primary,
              icon: LucideIcons.user,
              children: [
                buildRowTitleValue(
                  singleLine: false,
                  title: "Full Name",
                  value: channelPartnerModel.name,
                ),
                buildRowTitleValue(
                  singleLine: false,
                  title: "DOB",
                  value:
                      channelPartnerModel.dob != null
                          ? formatDateTimeAsDDMMMYYYY(channelPartnerModel.dob!)
                          : "-",
                ),
                buildRowTitleValue(
                  singleLine: false,
                  title: "Mobile Number",
                  value: channelPartnerModel.mobileNumber,
                  customValueWidget: CustomClickToContactText(
                    countryCode: channelPartnerModel.mobileNumberCountryCode,
                    value: channelPartnerModel.mobileNumber,
                    type: ContactType.phone,
                  ),
                ),
                buildRowTitleValue(
                  singleLine: false,
                  title: "E-Mail ID",
                  value: channelPartnerModel.emailId,
                  customValueWidget: CustomClickToContactText(
                    value: channelPartnerModel.emailId,
                    type: ContactType.email,
                  ),
                ),
                buildRowTitleValue(
                  singleLine: false,
                  title: "Website",
                  value: channelPartnerModel.websiteURL,
                  customValueWidget: GestureDetector(
                    onTap: () async {
                      final url = channelPartnerModel.websiteURL;

                      if (url.isNotEmpty) {
                        final Uri uri = Uri.parse(url);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(
                            uri,
                            mode: LaunchMode.externalApplication,
                          );
                        } else {
                          debugPrint("Could not launch URL: $url");
                        }
                      }
                    },
                    child: Text(
                      channelPartnerModel.websiteURL.isEmpty
                          ? "-"
                          : channelPartnerModel.websiteURL,
                      style: AppTextStyle.ts14M(
                        color:
                            channelPartnerModel.websiteURL.isEmpty
                                ? null
                                : AppColor.primary,
                      ).copyWith(
                        decoration:
                            channelPartnerModel.websiteURL.isEmpty
                                ? TextDecoration.none
                                : TextDecoration.underline,
                        decorationColor:
                            channelPartnerModel.websiteURL.isEmpty
                                ? null
                                : AppColor.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            _sectionCard(
              title: "Business Information",
              bgColor: AppColor.lightGreenBg.withValues(alpha: 0.2),
              iconColor: AppColor.darkGreen,
              icon: LucideIcons.briefcaseBusiness,
              children: [
                buildRowTitleValue(
                  singleLine: false,
                  title: "Company Name",
                  value: channelPartnerModel.companyName,
                ),
                buildRowTitleValue(
                  singleLine: false,
                  title: "Firm Type",
                  value: channelPartnerModel.firmsType,
                ),
                buildRowTitleValue(
                  singleLine: false,
                  title: "Speciality",
                  value: channelPartnerModel.speciality,
                ),
                buildRowTitleValue(
                  singleLine: false,
                  title: "RERA Number",
                  value: channelPartnerModel.reraNumber,
                ),

                buildRowTitleValue(
                  singleLine: false,
                  title: "Type",
                  value: channelPartnerModel.type,
                ),
                buildRowTitleValue(
                  singleLine: false,
                  title: "Designation",
                  value: channelPartnerModel.designation,
                ),
                buildRowTitleValue(
                  singleLine: false,
                  title: "Alternate Contact No.",
                  value: channelPartnerModel.alternativeMobileNumber,
                  customValueWidget: CustomClickToContactText(
                    value: channelPartnerModel.alternativeMobileNumber,
                  ),
                ),
              ],
            ),
            _sectionCard(
              title: "Address Details",
              bgColor: AppColor.lightOrange.withValues(alpha: 0.4),
              iconColor: AppColor.rustOrange,
              icon: LucideIcons.map,
              children: [
                buildRowTitleValue(
                  singleLine: false,
                  title: "Country",
                  value: channelPartnerModel.countryName,
                ),
                buildRowTitleValue(
                  singleLine: false,
                  title: "State",
                  value: channelPartnerModel.stateName,
                ),

                buildRowTitleValue(
                  singleLine: false,
                  title: "District",
                  value: channelPartnerModel.districtName,
                ),
                buildRowTitleValue(
                  singleLine: false,
                  title: "City",
                  value: channelPartnerModel.cityName,
                ),

                buildRowTitleValue(
                  singleLine: false,
                  title: "Village",
                  value: channelPartnerModel.villageName,
                ),

                buildRowTitleValue(
                  singleLine: false,
                  title: "Office Address",
                  value: channelPartnerModel.officeAddress,
                ),
              ],
            ),
            _sectionCard(
              title: "Sales Matrix",
              bgColor: AppColor.lightGreyBackground,
              iconColor: AppColor.grey,
              icon: LucideIcons.chartNoAxesCombined,
              children: [
                buildRowTitleValue(
                  singleLine: false,
                  title: "No Of Enquiry",
                  value: channelPartnerModel.noOfEnquiry.addCommas(),
                ),
                buildRowTitleValue(
                  singleLine: false,
                  title: "No Of Booking",
                  value: channelPartnerModel.noOfBooking.addCommas(),
                ),

                buildRowTitleValue(
                  singleLine: false,
                  title: "Brokerage Percentage (%)",
                  value: channelPartnerModel.brokeragePercentage.addCommas(),
                ),
                buildRowTitleValue(
                  singleLine: false,
                  title: "Brokerage Amount (₹)",
                  value: channelPartnerModel.brokerageAmount.toIndianCurrency(),
                ),

                buildRowTitleValue(
                  singleLine: false,
                  title: "No Of IBM",
                  value: channelPartnerModel.noOfIbm.addCommas(),
                ),

                buildRowTitleValue(
                  singleLine: false,
                  title: "No Of OBM",
                  value: channelPartnerModel.noOfObm.addCommas(),
                ),
              ],
            ),
            _sectionCard(
              title: "Assigned Project",
              bgColor: AppColor.lightBlue,
              iconColor: AppColor.primary,
              icon: LucideIcons.building2,
              children: [
                _projectPortfolioWidget(
                  primaryProject: channelPartnerModel.primaryProjectPortfolio,
                  secondaryProjects:
                      channelPartnerModel.secondaryProjectPortfolio,
                  micromarketProximity:
                      channelPartnerModel.micromarketProximity,
                ),
              ],
            ),
            _sectionCard(
              title: "Action Details",
              bgColor: AppColor.greyBackground,
              iconColor: AppColor.grey,
              icon: LucideIcons.history,
              children: [
                buildRowTitleValue(
                  title: "Created By",
                  value: channelPartnerModel.createdBy,
                  singleLine: false,
                ),
                buildRowTitleValue(
                  title: "Created Date",
                  value: formatDate(channelPartnerModel.createdDate),
                  singleLine: false,
                ),

                buildRowTitleValue(
                  title: "Modified By",
                  value:
                      (channelPartnerModel.modifiedBy.isNotEmpty)
                          ? channelPartnerModel.modifiedBy
                          : "-",
                  singleLine: false,
                ),
                buildRowTitleValue(
                  title: "Modified Date",
                  value:
                      (channelPartnerModel.modifiedDate == null ||
                              channelPartnerModel.modifiedDate
                                  .toString()
                                  .trim()
                                  .isEmpty)
                          ? "-"
                          : formatDate(channelPartnerModel.modifiedDate),
                  singleLine: false,
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

Widget _sectionCard({
  required String title,
  required IconData icon,
  required Color? iconColor,
  required Color? bgColor,
  required List<Widget> children,
}) {
  return Container(
    decoration: commonCardDecoration(),
    margin: EdgeInsets.only(bottom: 12.h),
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 10,
          children: [
            Container(
              height: 32.h,
              width: 32.w,
              decoration: BoxDecoration(
                color: bgColor ?? AppColor.lightBlue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor ?? AppColor.primary, size: 22),
            ),
            Text(title, style: AppTextStyle.ts14SB(color: AppColor.grey)),
          ],
        ),
        verticalSpacing(height: 4),
        ...children,
      ],
    ),
  );
}

Widget _verificationChip(String title, IconData icon) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: const Color(0xffEEF2FF),
      borderRadius: BorderRadius.circular(30),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColor.primary),
        horizontalSpacing(width: 5),
        Text(title, style: AppTextStyle.ts12M(color: AppColor.primary)),
      ],
    ),
  );
}

Widget _projectPortfolioWidget({
  required String primaryProject,
  required String secondaryProjects,
  required String micromarketProximity,
}) {
  if (primaryProject.isEmpty && secondaryProjects.isEmpty) {
    return noDataWidget(message: "No Assigned Project Found.", iconSize: 100);
  }
  final secondaryList =
      secondaryProjects
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      verticalSpacing(height: 5),
      Text("PRIMARY PROJECT", style: AppTextStyle.ts12SB(color: AppColor.grey)),
      verticalSpacing(height: 10),
      _primaryProjectCard(primaryProject),

      if (secondaryList.isNotEmpty) ...[
        verticalSpacing(height: 24),
        Text(
          "SECONDARY PROJECTS (${secondaryList.length})",
          style: AppTextStyle.ts12SB(color: AppColor.grey),
        ),
        verticalSpacing(height: 10),
        SizedBox(
          height: secondaryList.length > 6 ? 350.h : null,
          child: SingleChildScrollView(
            child: Column(
              children: secondaryList.map(_secondaryProjectCard).toList(),
            ),
          ),
        ),
        verticalSpacing(height: 10),
      ],

      Text(
        "MICROMARKET PROXIMICITY",
        style: AppTextStyle.ts12SB(color: AppColor.grey),
      ),
      verticalSpacing(height: 10),
      Text(
        micromarketProximity.trim().isEmpty ? "-" : micromarketProximity,
        style: AppTextStyle.ts14M(),
      ),
    ],
  );
}

Widget _primaryProjectCard(String project) {
  return Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFFEFF3FF),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        Container(
          width: 52.w,
          height: 52.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.apartment,
            color: Color(0xFF4A57E8),
            size: 28,
          ),
        ),
        horizontalSpacing(width: 14),
        Expanded(child: Text(project, style: AppTextStyle.ts16SB())),
      ],
    ),
  );
}

Widget _secondaryProjectCard(String project) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: Row(
      children: [Expanded(child: Text(project, style: AppTextStyle.ts16M()))],
    ),
  );
}
