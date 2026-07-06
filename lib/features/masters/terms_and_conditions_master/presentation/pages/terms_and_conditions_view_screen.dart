import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/terms_and_conditions_master/data/model/terms_and_conditions.model.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class TermsAndConditionsViewScreen extends StatelessWidget {
  final TermsAndConditionsModel termsAndCondition;
  const TermsAndConditionsViewScreen({
    super.key,
    required this.termsAndCondition,
  });

  @override
  Widget build(BuildContext context) {
    final isHtml =
        termsAndCondition.description.contains('<') &&
        termsAndCondition.description.contains('>');

    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Terms And Conditions Details",
        authorization: AuthorizationModel(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(termsAndCondition.title, style: AppTextStyle.ts16M()),
              verticalSpacing(),
              Container(
                padding: EdgeInsets.all(16),
                margin: EdgeInsets.only(bottom: 10),
                decoration: commonCardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Description", style: AppTextStyle.ts16SB()),
                    verticalSpacing(),
                    isHtml
                        ? Html(
                          data: termsAndCondition.description,
                          style: {
                            "body": Style(
                              fontSize: FontSize(14),
                              margin: Margins.zero,
                              padding: HtmlPaddings.zero,
                            ),
                          },
                        )
                        : Text(
                          termsAndCondition.description,
                          style: AppTextStyle.ts14R(color: AppColor.grey),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                  ],
                ),
              ),
              actionCardWidget(
                createdBy: termsAndCondition.createdBy,
                createdDate: termsAndCondition.createdDate,
                modifiedBy: termsAndCondition.modifiedBy,
                modifiedDate: termsAndCondition.modifiedDate,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
