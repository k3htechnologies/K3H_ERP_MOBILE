import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/sales/booking/data/model/booking.model.dart';
import 'package:k3h_erp_app/features/sales/sales_reports/achievement/presentation/widget/common_achivement_widgets.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/custom_click_to_contact_widget.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AchievementDrillDownReportForBookingScreen extends StatelessWidget {
  final BookingModel bookingModel;
  final String? tabName;
  final String columnName;
  final String projectName;
  final String? employeeName;

  const AchievementDrillDownReportForBookingScreen({
    super.key,
    this.employeeName,
    required this.bookingModel,
    required this.projectName,
    required this.tabName,
    required this.columnName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Booking",
        authorization: AuthorizationModel(),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (projectName.isNotEmpty) ...[
              showSiteSelectedWidget(projectName: projectName),
              verticalSpacing(height: 12),
            ],
            if (employeeName != null && employeeName!.isNotEmpty) ...[
              Text(employeeName!, style: AppTextStyle.ts14M()),
              verticalSpacing(height: 12),
            ],
            RichText(
              text: TextSpan(
                style: AppTextStyle.ts14R(),
                children: [
                  if (tabName != null)
                    TextSpan(
                      text: "Tab: ",
                      style: AppTextStyle.ts14R(color: AppColor.grey),
                    ),

                  if (tabName != null)
                    TextSpan(text: tabName, style: AppTextStyle.ts14M()),

                  if (tabName != null)
                    TextSpan(
                      text: " | ",
                      style: AppTextStyle.ts14R(color: AppColor.grey),
                    ),

                  TextSpan(
                    text: "Column: ",
                    style: AppTextStyle.ts14R(color: AppColor.grey),
                  ),

                  TextSpan(
                    text: toTitleCase(columnName),
                    style: AppTextStyle.ts14M(),
                  ),
                ],
              ),
            ),
            verticalSpacing(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  spacing: 10,
                  children: [
                    buildCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 10,
                        children: [
                          buildSectionTitle("Booking Details"),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildColumnTitleValue(
                                title: "Applicant Name",
                                value: bookingModel.applicantName,
                              ),
                              buildColumnTitleValue(
                                title: "Enquiry Code",
                                value: bookingModel.systemGeneratedCode,
                              ),
                            ],
                          ),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildColumnTitleValue(
                                title: "Applicant Mobile Number",
                                value: bookingModel.applicantMobileNumber,
                                customValueWidget:
                                    bookingModel
                                            .applicantMobileNumber
                                            .isNotEmpty
                                        ? CustomClickToContactText(
                                          countryCode:
                                              bookingModel
                                                  .applicantMobileNumberCountryCode,
                                          value:
                                              bookingModel
                                                  .applicantMobileNumber,
                                          type: ContactType.phone,
                                        )
                                        : null,
                              ),
                              buildColumnTitleValue(
                                title: "Source",
                                value: bookingModel.source,
                              ),
                            ],
                          ),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildColumnTitleValue(
                                title: "Booking Type",
                                value: bookingModel.bookingType,
                              ),
                              buildColumnTitleValue(
                                title: "Flat",
                                value: bookingModel.flat,
                              ),
                            ],
                          ),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildColumnTitleValue(
                                title: "Wing",
                                value: bookingModel.wing,
                              ),
                              buildColumnTitleValue(
                                title: "Floor",
                                value: bookingModel.floor,
                              ),
                            ],
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildColumnTitleValue(
                                title: "Agreement Value (₹)",
                                value:
                                    bookingModel.agreementValue
                                        .toIndianCurrency(),
                              ),
                              buildColumnTitleValue(
                                title: "Expected Registration Date",
                                value: formatDateTimeAsDDMMMYYYY(
                                  bookingModel.registrationDate,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    actionCardWidget(
                      createdBy: bookingModel.createdBy,
                      createdDate: bookingModel.createdDate,
                      modifiedBy: bookingModel.modifiedBy,
                      modifiedDate: bookingModel.modifiedDate,
                    ),

                    verticalSpacing(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
