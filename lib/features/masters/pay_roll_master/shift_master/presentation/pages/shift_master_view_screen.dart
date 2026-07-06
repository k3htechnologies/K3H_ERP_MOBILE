import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/shift_master/data/model/shift_master.model.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';

class ShiftMasterViewScreen extends StatelessWidget {
  final ShiftMasterModel shiftMaster;
  const ShiftMasterViewScreen({super.key, required this.shiftMaster});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Shift Master",
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
                    Text("Shift Details", style: AppTextStyle.ts16SB()),
                    Row(
                      spacing: 10,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildColumnTitleValue(
                          title: "Shift Name",
                          value: shiftMaster.shiftName,
                        ),
                        buildColumnTitleValue(
                          title: "Shift Code",
                          value: shiftMaster.shiftCode,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(16),
                decoration: commonCardDecoration(),
                child: Column(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Time Details", style: AppTextStyle.ts16SB()),
                    Row(
                      spacing: 10,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildColumnTitleValue(
                          title: "Shift Begin Time",
                          value: shiftMaster.shiftBeginTime,
                        ),
                        buildColumnTitleValue(
                          title: "Shift End Time",
                          value: shiftMaster.shiftEndTime,
                        ),
                      ],
                    ),
                    Row(
                      spacing: 10,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildColumnTitleValue(
                          title: "Shift Duration Time",
                          value: shiftMaster.shiftDurationTime,
                        ),
                        buildColumnTitleValue(
                          title: "Shift Work Duration Time",
                          value: shiftMaster.shiftWorkDurationTime,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(16),
                decoration: commonCardDecoration(),
                child: Column(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Break Details", style: AppTextStyle.ts16SB()),
                    Row(
                      spacing: 10,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildColumnTitleValue(
                          title: "Break Begin Time",
                          value: shiftMaster.breakBeginTime,
                        ),
                        buildColumnTitleValue(
                          title: "Break End Time",
                          value: shiftMaster.breakEndTime,
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildColumnTitleValue(
                          title: "Break Duration Time",
                          value: shiftMaster.breakDurationTime,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(16),
                decoration: commonCardDecoration(),
                child: Column(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Advance Settings", style: AppTextStyle.ts16SB()),
                    Row(
                      spacing: 10,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildColumnTitleValue(
                          title: "First Half Up To",
                          value: shiftMaster.firstHalfUpTo,
                        ),
                        buildColumnTitleValue(
                          title: "Mark Absent If Working Hour less than",
                          value: shiftMaster.absentWorkingHours,
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 10,
                      children: [
                        buildColumnTitleValue(
                          title: "Mark Half Day if Intime After",
                          value: shiftMaster.halfDayInTimeAfter,
                        ),
                        buildColumnTitleValue(
                          title: "Mark Half Day if Outtime Before",
                          value: shiftMaster.halfDayOutTimeBefore,
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildColumnTitleValue(
                          title: "Mark Half Day If Working Hour Less than",
                          value: shiftMaster.halfDayWorkingHours,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(16),
                decoration: commonCardDecoration(),
                child: Column(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Time Allowed for Late Entry Details",
                      style: AppTextStyle.ts16SB(),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildColumnTitleValue(
                          title: "Grace Time In Minutes",
                          value: shiftMaster.graceTime,
                        ),
                        buildColumnTitleValue(
                          title: "Late Arrival Action",
                          value: shiftMaster.lateArrivalAction,
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildColumnTitleValue(
                          title: "Late Arrival Count",
                          value: shiftMaster.lateCount.toString(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(16),
                decoration: commonCardDecoration(),
                child: Column(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Remarks", style: AppTextStyle.ts16SB()),
                    Row(
                      children: [
                        buildColumnTitleValue(
                          title: "Remarks",
                          value: shiftMaster.remarks,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              actionCardWidget(
                createdBy: shiftMaster.createdBy,
                createdDate: shiftMaster.createdDate,
                modifiedBy: shiftMaster.modifiedBy,
                modifiedDate: shiftMaster.modifiedDate,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
