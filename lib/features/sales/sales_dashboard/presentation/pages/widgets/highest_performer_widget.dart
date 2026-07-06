import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/features/sales/sales_dashboard/presentation/cubit/sales_dashboard_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

import '../../../data/model/sales.dashboard.model.dart';

class HighestPerformerWidget extends StatelessWidget {
  const HighestPerformerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SalesDashboardCubit, SalesDashboardState>(
      builder: (context, state) {
        final highestPerformerList =
            state.salesDashboardList.isNotEmpty
                ? state.salesDashboardList.first.table8
                : <Table8>[];
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: commonCardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "Highest Performer",
                      style: AppTextStyle.ts14M(
                        color: AppColor.greyTitleAndValueColor.withValues(
                          alpha: 0.50,
                        ),
                      ),
                    ),
                    TextSpan(
                      text: " (${highestPerformerList.length} Records)",
                      style: AppTextStyle.ts12R(
                        color: AppColor.greyTitleAndValueColor.withValues(
                          alpha: 0.50,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              verticalSpacing(),
              highestPerformerList.isNotEmpty
                  ? SizedBox(
                    height: highestPerformerList.length > 1 ? 300.h : 150.h,
                    child: ListView.separated(
                      itemCount: highestPerformerList.length,
                      separatorBuilder:
                          (context, index) =>
                              Divider(color: Colors.grey.shade300),
                      itemBuilder: (context, index) {
                        final highestPerformer = highestPerformerList[index];
                        return Container(
                          padding: const EdgeInsets.all(12),

                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 22.r,
                                    backgroundColor: const Color(0xffE7ECFF),
                                    child: Text(
                                      getInitials(highestPerformer.name),
                                      style: AppTextStyle.ts16B(),
                                    ),
                                  ),
                                  horizontalSpacing(),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          highestPerformer.name,
                                          style: AppTextStyle.ts16SB(),
                                        ),
                                        SizedBox(height: 2),
                                        Text(
                                          highestPerformer.department,
                                          style: AppTextStyle.ts12M(
                                            color: AppColor.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              verticalSpacing(),
                              IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  spacing: 16,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 10.w,
                                          vertical: 10.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColor.lightGrey.withValues(
                                            alpha: 0.4,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          border: Border.all(
                                            color: AppColor.grey.withValues(
                                              alpha: 0.2,
                                            ),
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              highestPerformer.department ==
                                                      'Sourcing Manager'
                                                  ? "Total OBM"
                                                  : "Revenue Amount",

                                              style: AppTextStyle.ts12M(
                                                color: AppColor.grey,
                                              ),
                                            ),
                                            verticalSpacing(),
                                            Text(
                                              highestPerformer.department ==
                                                      'Sourcing Manager'
                                                  ? highestPerformer.totalObm
                                                      .addCommas()
                                                  : formatToKLCr(
                                                    highestPerformer
                                                        .agreementValue,
                                                  ),
                                              style: AppTextStyle.ts16SB(),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 10.w,
                                          vertical: 10.h,
                                        ),

                                        decoration: BoxDecoration(
                                          color: AppColor.lightGrey.withValues(
                                            alpha: 0.4,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          border: Border.all(
                                            color: AppColor.grey.withValues(
                                              alpha: 0.2,
                                            ),
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              highestPerformer.department ==
                                                      'Sourcing Manager'
                                                  ? "Walkin By CP"
                                                  : "Booking Count",

                                              style: AppTextStyle.ts12M(
                                                color: AppColor.grey,
                                              ),
                                            ),
                                            verticalSpacing(),
                                            Text(
                                              highestPerformer.department ==
                                                      'Sourcing Manager'
                                                  ? highestPerformer.walkinsByCp
                                                      .addCommas()
                                                  : highestPerformer
                                                      .totalBooking
                                                      .addCommas(),
                                              style: AppTextStyle.ts16SB(),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  )
                  : Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: noDataWidget(
                        iconSize: 100,
                        message: "No Data Found",
                      ),
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }
}
