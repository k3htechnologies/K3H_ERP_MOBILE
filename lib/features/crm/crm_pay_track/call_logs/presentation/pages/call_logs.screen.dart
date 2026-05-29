import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/pay_track/presentation/cubit/pay_track_cubit.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/pay_track/presentation/cubit/pay_track_state.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class CallLogsScreen extends StatefulWidget {
  final int projectId;
  final int bookingId;
  const CallLogsScreen({
    super.key,
    required this.projectId,
    required this.bookingId,
  });

  @override
  State<CallLogsScreen> createState() => _CallLogsScreenState();
}

class _CallLogsScreenState extends State<CallLogsScreen> {
  late PayTrackCubit _payTrackCubit;

  @override
  void initState() {
    super.initState();
    _payTrackCubit = context.read<PayTrackCubit>();
    _payTrackCubit.getPayTrackCallLog(
      context,
      1,
      widget.projectId,
      widget.bookingId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PayTrackCubit, PayTrackState>(
      builder: (context, state) {
        if (state.isLoading ?? true && (state.payTrackCallLogList.isEmpty)) {
          return Center(child: CircularProgressIndicator());
        }
        return Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListView.builder(
                itemCount: state.payTrackCallLogList.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final callLog = state.payTrackCallLogList[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: 10.0),
                    padding: EdgeInsets.all(12.0),
                    decoration: commonCardDecoration(),
                    child: Theme(
                      data: Theme.of(
                        context,
                      ).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        childrenPadding: EdgeInsets.zero,
                        expandedCrossAxisAlignment: CrossAxisAlignment.start,
                        iconColor: AppColor.black,
                        collapsedIconColor: AppColor.black,
                        shape: const Border(),
                        collapsedShape: const Border(),
                        title: Text(
                          callLog.applicantName,
                          style: AppTextStyle.ts16M(color: AppColor.primary),
                        ),
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.0,
                              vertical: 16.0,
                            ),
                            decoration: BoxDecoration(
                              color: AppColor.lightGreyBackground,
                              borderRadius: BorderRadius.circular(6.0),
                              border: Border.all(
                                width: 0.3,
                                color: AppColor.black.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          6.0,
                                        ),
                                        color:
                                            callLog.callStatus.toLowerCase() ==
                                                    "pending"
                                                ? AppColor.grey.withValues(
                                                  alpha: 0.3,
                                                )
                                                : AppColor.green.withValues(
                                                  alpha: 0.3,
                                                ),
                                      ),
                                      child: Text(
                                        callLog.callStatus.toLowerCase() ==
                                                "pending"
                                            ? "Pending"
                                            : callLog.callStatus,
                                        style: AppTextStyle.ts12SB(
                                          color:
                                              callLog.callStatus
                                                          .toLowerCase() ==
                                                      "pending"
                                                  ? AppColor.black
                                                  : AppColor.green,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                verticalSpacing(),
                                buildRowTitleValue(
                                  title: "Applicant Type",
                                  value: callLog.applicantType,
                                ),
                                buildRowTitleValue(
                                  title: "Applicant Mobile Number",
                                  value: callLog.applicantMobileNumber,
                                ),
                                buildRowTitleValue(
                                  title: "Call Time",
                                  value: formatDateTimeReadable(
                                    callLog.callDate,
                                  ),
                                  singleLine: false,
                                ),
                                buildRowTitleValue(
                                  title: "Duration",
                                  value: callLog.duration,
                                ),
                                buildRowTitleValue(
                                  title: "Call Purpose",
                                  value: callLog.callPurpose,
                                  singleLine: false,
                                ),
                                buildRowTitleValue(
                                  title: "Reschedule Date",
                                  value: formatDateTimeAsDDMMMYYYY(
                                    callLog.rescheduleDate,
                                  ),
                                ),
                                buildRowTitleValue(
                                  title: "Registration Date",
                                  value: formatDateTimeAsDDMMMYYYY(
                                    callLog.registrationDate,
                                  ),
                                ),
                                buildRowTitleValue(
                                  title: "Promise Amount",
                                  value:
                                      callLog.promiseAmount.toIndianCurrency(),
                                ),
                                buildRowTitleValue(
                                  title: "Remark",
                                  value: callLog.remark,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
