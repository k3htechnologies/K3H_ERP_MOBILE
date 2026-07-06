import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/holiday_master/data/model/holiday_master.model.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';

class HolidayMasterViewScreen extends StatelessWidget {
  final HolidayMasterModel holidayMaster;

  const HolidayMasterViewScreen({super.key, required this.holidayMaster});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Holiday Master",
        authorization: AuthorizationModel(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: Column(
            spacing: 10,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: commonCardDecoration(),
                child: Column(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Holiday Details", style: AppTextStyle.ts16SB()),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildColumnTitleValue(
                          title: "Holiday Name",
                          value: holidayMaster.holidayName,
                        ),
                      ],
                    ),
                    Row(
                      spacing: 10,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildColumnTitleValue(
                          title: "Holiday Document",
                          value: holidayMaster.holidayUrl,
                          customValueWidget: CustomButton.documentOutline(
                            onPressed: () {
                              if (holidayMaster.holidayUrl.isNotEmpty) {
                                showFilePreviewDialog(
                                  context,
                                  holidayMaster.holidayUrl.split(","),
                                );
                              }
                            },
                            isDisable: holidayMaster.holidayUrl.isEmpty,
                          ),
                        ),
                        Expanded(child: SizedBox()),
                      ],
                    ),
                  ],
                ),
              ),
              actionCardWidget(
                createdBy: holidayMaster.createdBy,
                createdDate: holidayMaster.createdDate,
                modifiedBy: holidayMaster.modifiedBy,
                modifiedDate: holidayMaster.modifiedDate,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
