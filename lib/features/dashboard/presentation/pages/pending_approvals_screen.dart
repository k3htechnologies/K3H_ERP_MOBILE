import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';

class PendingApprovalsScreen extends StatelessWidget {
  final String pageTitle;
  final String onViewRoute;

  final List<List<Map<String, String>>> data;

  const PendingApprovalsScreen({
    super.key,
    required this.pageTitle,
    required this.onViewRoute,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: pageTitle,
        authorization: AuthorizationModel(),
        secondaryWidget: SizedBox(
          height: 25.h,
          child: CustomButton(
            text: "View",
            onPressed: () {
              goRouter.goNamed(onViewRoute);
            },
          ),
        ),
      ),

      body: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        itemCount: data.length,

        itemBuilder: (context, index) {
          final cardData = data[index];

          return Container(
            decoration: commonCardDecoration(),
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(12),

              child: Column(
                children:
                    cardData.map((item) {
                      return buildRowTitleValue(
                        fixesWidth: 110,
                        title: item["title"] ?? "",
                        value: item["value"] ?? "",
                      );
                    }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}
