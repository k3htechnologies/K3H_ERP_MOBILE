import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/features/sales/sales_dashboard/presentation/cubit/sales_dashboard_cubit.dart';
import 'package:k3h_erp_app/features/sales/sales_dashboard/presentation/pages/widgets/common_sales_dashboard_widgets.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_click_to_contact_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

import '../../../data/model/sales.dashboard.model.dart';

class EnquiriesWidget extends StatefulWidget {
  const EnquiriesWidget({super.key});

  @override
  State<EnquiriesWidget> createState() => _EnquiriesWidgetState();
}

class _EnquiriesWidgetState extends State<EnquiriesWidget> {
  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _showMarkAsTimeOutPopup({
    required BuildContext context,
    required Table0 item,
  }) async {
    final shouldRemove = await DialogHelper.showConfirmationDialog(
      context: context,
      title: 'Are you sure you want to mark Time Out?',
      message: '',
      confirmText: "Time Out",
    );
    if (shouldRemove == true && context.mounted) {
      context.read<SalesDashboardCubit>().markTimeOutEnquiry(
        context: context,
        enquiryId: item.enquiryId,
        projectId: item.projectId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SalesDashboardCubit, SalesDashboardState>(
      builder: (context, state) {
        final data =
            (state.salesDashboardList.isNotEmpty)
                ? state.salesDashboardList.first.table0
                : <Table0>[];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: commonCardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "Time-Out Enquiries ",
                      style: AppTextStyle.ts14M(
                        color: AppColor.greyTitleAndValueColor.withValues(
                          alpha: 0.50,
                        ),
                      ),
                    ),
                    TextSpan(
                      text: " (${data.length} Records)",
                      style: AppTextStyle.ts12R(
                        color: AppColor.greyTitleAndValueColor.withValues(
                          alpha: 0.50,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              verticalSpacing(height: 10.0),
              if (data.isNotEmpty) ...[
                SizedBox(
                  height: data.length > 1 ? 350.h : 270.h,
                  child: ListView.separated(
                    itemCount: data.length,
                    separatorBuilder:
                        (context, index) => verticalSpacing(height: 12.h),
                    itemBuilder: (context, index) {
                      final item = data[index];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColor.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColor.grey.withValues(alpha: .2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Color(0x140058BE),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          item.systemGeneratedCode,
                                          style: AppTextStyle.ts14M(),
                                        ),
                                      ),

                                      const SizedBox(height: 6),

                                      Text(
                                        item.projectName,
                                        style: AppTextStyle.ts12R(
                                          color:
                                              AppColor.greyTitleAndValueColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(
                                  height: 34,
                                  child: CustomButton(
                                    text: "Time-Out",
                                    backgroundColor:
                                        item.canTimeOut == 0
                                            ? AppColor.grey2
                                            : AppColor.primary,
                                    onPressed:
                                        item.canTimeOut == 0
                                            ? null
                                            : () {
                                              _showMarkAsTimeOutPopup(
                                                context: context,
                                                item: item,
                                              );
                                            },
                                  ),
                                ),
                              ],
                            ),

                            Divider(
                              height: 30,
                              color: AppColor.grey.withValues(alpha: .25),
                            ),

                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 10,
                              children: [
                                Expanded(
                                  child: InfoColumn(
                                    title: "Client Name",
                                    value: item.name,
                                  ),
                                ),
                                Expanded(
                                  child: InfoColumn(
                                    title: "Customer Time-in",
                                    value: item.enquiryTimeIn,
                                  ),
                                ),
                              ],
                            ),

                            verticalSpacing(height: 12),

                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 10,
                              children: [
                                Expanded(
                                  child: InfoColumn(
                                    title: "Mobile No.",
                                    customWidget: CustomClickToContactText(
                                      countryCode: item.mobileNumberCountryCode,
                                      value: item.mobileNumber,
                                    ),
                                    value: item.mobileNumber,
                                  ),
                                ),
                                Expanded(
                                  child: InfoColumn(
                                    title: "Date",
                                    value: formatDateTimeAsDDMMMYYYY(
                                      item.enquiryDate,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            verticalSpacing(height: 12),

                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 10,
                              children: [
                                Expanded(
                                  child: InfoColumn(
                                    title: "Sales Advisor",
                                    value: item.salesAdvisor,
                                  ),
                                ),
                                Expanded(
                                  child: InfoColumn(
                                    title: "Sourcing Manager",
                                    value:
                                        item.sourcingManager.isEmpty
                                            ? "-"
                                            : item.sourcingManager,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ] else ...[
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: noDataWidget(
                      iconSize: 100,
                      message: "No Data Found",
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
