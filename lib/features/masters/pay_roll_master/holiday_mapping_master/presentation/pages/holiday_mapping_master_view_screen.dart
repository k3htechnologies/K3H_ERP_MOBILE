import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/holiday_mapping_master/data/model/holiday_mapping_master.model.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';

class HolidayMappingMasterViewScreen extends StatelessWidget {
  final HolidayMappingModel holidayMapping;

  const HolidayMappingMasterViewScreen({
    super.key,
    required this.holidayMapping,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Holiday Mapping Master",
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
                    Text(
                      "Holiday Mapping Details",
                      style: AppTextStyle.ts16SB(),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildColumnTitleValue(
                          title: "Holiday Name",
                          value: holidayMapping.holidayName,
                        ),
                        buildColumnTitleValue(
                          title: "Holiday Date",
                          value: formatDateTimeAsDDMMMYYYY(
                            holidayMapping.holidayDate,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildColumnTitleValue(
                          title: "Branch Name",
                          value: holidayMapping.branchName,
                        ),
                        buildColumnTitleValue(
                          title: "Department Name",
                          value: holidayMapping.departmentName,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actionCardWidget(
                createdBy: holidayMapping.createdBy,
                createdDate: holidayMapping.createdDate,
                modifiedBy: holidayMapping.modifiedBy,
                modifiedDate: holidayMapping.modifiedDate,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
