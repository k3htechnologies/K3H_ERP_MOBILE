import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/channel_partner/data/model/channel_partner.model.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/custom_click_to_contact_widget.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class ChannelPartnerViewScreen extends StatelessWidget {
  final ChannelPartnerModel channelPartnerModel;
  const ChannelPartnerViewScreen({
    super.key,
    required this.channelPartnerModel,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Channel Partner",
        authorization: AuthorizationModel(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Overview", style: AppTextStyle.ts16SB()),
            verticalSpacing(),
            Container(
              decoration: commonCardDecoration(),
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Basic Details",
                    style: AppTextStyle.ts14M(color: AppColor.grey),
                  ),
                  verticalSpacing(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "Full Name",
                        value: channelPartnerModel.name,
                      ),
                      buildColumnTitleValue(
                        title: "Contact No.",
                        value: channelPartnerModel.mobileNumber,
                        customValueWidget: CustomClickToContactText(
                          value: channelPartnerModel.mobileNumber,
                          type: ContactType.phone,
                        ),
                      ),
                    ],
                  ),
                  verticalSpacing(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "E-Mail ID",
                        value: channelPartnerModel.emailId,
                        customValueWidget: CustomClickToContactText(
                          value: channelPartnerModel.emailId,
                          type: ContactType.email,
                        ),
                      ),
                      buildColumnTitleValue(
                        title: "Company Name",
                        value: channelPartnerModel.companyName,
                      ),
                    ],
                  ),
                  verticalSpacing(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "Alternate Contact No.",
                        value: channelPartnerModel.alternativeMobileNumber,
                        customValueWidget: CustomClickToContactText(
                          value: channelPartnerModel.alternativeMobileNumber,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              decoration: commonCardDecoration(),
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Document Details",
                    style: AppTextStyle.ts14M(color: AppColor.grey),
                  ),
                  verticalSpacing(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(title: "RERA Number", value: channelPartnerModel.reraNumber)
                    ],
                  )
                ],
              ),
            ),
            Container(
              decoration: commonCardDecoration(),
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Project Details",
                    style: AppTextStyle.ts14M(color: AppColor.grey),
                  ),
                  verticalSpacing(),
                  Row(
                    children: [
                      buildColumnTitleValue(title: "Project", value: channelPartnerModel.projectName)
                    ],
                  )
                ],
              ),
            ),
            Container(
              decoration: commonCardDecoration(),
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Address Details",
                    style: AppTextStyle.ts14M(color: AppColor.grey),
                  ),
                  verticalSpacing(),
                  Row(
                    children: [
                      buildColumnTitleValue(title: "Office Address", value: channelPartnerModel.officeAddress)
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
