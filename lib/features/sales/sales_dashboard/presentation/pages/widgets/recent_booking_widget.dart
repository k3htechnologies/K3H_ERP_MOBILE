import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/features/sales/sales_dashboard/presentation/cubit/sales_dashboard_cubit.dart';
import 'package:k3h_erp_app/features/sales/sales_dashboard/presentation/pages/widgets/common_sales_dashboard_widgets.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

import '../../../data/model/sales.dashboard.model.dart';

class RecentBookingWidget extends StatelessWidget {
  final BuildContext context;
  const RecentBookingWidget({super.key, required this.context});

  @override
  Widget build(context) {
    return BlocBuilder<SalesDashboardCubit, SalesDashboardState>(
      builder: (context, state) {
        final recentBookingList =
            state.salesDashboardList.isNotEmpty
                ? state.salesDashboardList.first.table6
                : <Table6>[];
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
                      text: "Recent Booking",
                      style: AppTextStyle.ts14M(
                        color: AppColor.greyTitleAndValueColor.withValues(
                          alpha: 0.50,
                        ),
                      ),
                    ),
                    TextSpan(
                      text: " (${recentBookingList.length} Records)",
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
              recentBookingList.isNotEmpty
                  ? SizedBox(
                    height: 300.h,
                    child: ListView.separated(
                      itemCount: recentBookingList.length,
                      separatorBuilder: (context, index) => verticalSpacing(),
                      itemBuilder: (context, index) {
                        final recentBooking = recentBookingList[index];
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 22.r,
                                    backgroundColor: const Color(0xffE7ECFF),
                                    child: Text(
                                      getInitials(recentBooking.applicantName),
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
                                          recentBooking.applicantName,
                                          style: AppTextStyle.ts16SB(),
                                        ),
                                        SizedBox(height: 2),
                                        Text(
                                          recentBooking.projectName,
                                          style: AppTextStyle.ts12M(
                                            color: AppColor.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12.w,
                                      vertical: 6.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xffDCE8FF),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      recentBooking.flat,
                                      style: AppTextStyle.ts14M(),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 10),

                              Divider(color: Colors.grey.shade300),

                              const SizedBox(height: 8),

                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: InfoColumn(
                                      title: "Amount",
                                      value: formatToKLCr(
                                        recentBooking.agreementValue,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: InfoColumn(
                                      title: "Date",
                                      value: formatDate(
                                        recentBooking.createdDate,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              verticalSpacing(height: 12.h),
                              Row(
                                children: [
                                  Expanded(
                                    child: InfoColumn(
                                      title: "Sales Advisor",
                                      value: recentBooking.salesAdvisor,
                                    ),
                                  ),
                                  Expanded(
                                    child: InfoColumn(
                                      title: "Sourcing Manager",
                                      value: recentBooking.sourcingManager,
                                    ),
                                  ),
                                ],
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
