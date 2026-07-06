import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class EmployeeAttendanceScreen extends StatefulWidget {
  final String type;
  final String title;
  final String? subTitle;
  final Map<String, dynamic> queryParams;
  final List<dynamic> allEmployees;

  const EmployeeAttendanceScreen({
    super.key,
    required this.type,
    required this.title,
    this.subTitle,
    required this.queryParams,
    required this.allEmployees,
  });

  @override
  State<EmployeeAttendanceScreen> createState() =>
      _EmployeeAttendanceScreenState();
}

class _EmployeeAttendanceScreenState extends State<EmployeeAttendanceScreen> {
  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final allEmployees = widget.allEmployees;

        final list =
            allEmployees.where((e) {
              switch (widget.type.toUpperCase()) {
                case "PRESENT":
                  return e.status.toLowerCase() == "present";

                case "ABSENT":
                  return e.status.toLowerCase() == "absent";

                case "LEAVE":
                  return e.status.toLowerCase() == "leave";

                default:
                  return true;
              }
            }).toList();
        return Scaffold(
          appBar: CustomAppBarWithBackButton(
            screenTitle: widget.title,
            authorization: AuthorizationModel(),
          ),
          body: Padding(
            padding: EdgeInsetsGeometry.symmetric(
              horizontal: 20.0,
              vertical: 20.0,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Total : ${list.length}",
                    style: AppTextStyle.ts14M(
                      color: AppColor.greyTitleAndValueColor.withValues(
                        alpha: 0.5,
                      ),
                    ),
                  ),
                  verticalSpacing(),
                  ListView.builder(
                    itemCount: list.length,
                    shrinkWrap: true,
                    physics: BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      final attendance = list[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: 16.0),
                        padding: EdgeInsets.symmetric(
                          vertical: 12.0,
                          horizontal: 16.0,
                        ),
                        decoration: commonCardDecoration(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: buildColumnTitleValueNormal(
                                    title: "Employee Code",
                                    value: attendance.employeeCode,
                                  ),
                                ),
                                horizontalSpacing(),
                                Expanded(
                                  child: buildColumnTitleValueNormal(
                                    title: "Employee Name",
                                    value: attendance.name,
                                  ),
                                ),
                              ],
                            ),
                            verticalSpacing(),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: buildColumnTitleValueNormal(
                                    title: "Designation",
                                    value: attendance.designationName,
                                  ),
                                ),
                                horizontalSpacing(),
                                Expanded(
                                  child: buildColumnTitleValueNormal(
                                    title: "Status",
                                    value: attendance.status,
                                  ),
                                ),
                              ],
                            ),
                            verticalSpacing(),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: buildColumnTitleValueNormal(
                                    title: "Punch In",
                                    value:
                                        attendance.punchIn == "{}" ||
                                                attendance.punchIn.isEmpty
                                            ? "-"
                                            : attendance.punchIn,
                                  ),
                                ),
                                horizontalSpacing(),
                                Expanded(
                                  child: buildColumnTitleValueNormal(
                                    title: "Punch Out",
                                    value:
                                        attendance.punchOut == "{}" ||
                                                attendance.punchOut.isEmpty
                                            ? "-"
                                            : attendance.punchOut,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
