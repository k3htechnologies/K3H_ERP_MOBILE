import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/features/sales/sales_dashboard/data/model/sales.dashboard.model.dart';
import 'package:k3h_erp_app/features/sales/sales_dashboard/presentation/cubit/sales_dashboard_cubit.dart';
import 'package:k3h_erp_app/features/sales/sales_dashboard/presentation/pages/widgets/common_sales_dashboard_widgets.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/functions/utility_function.dart';
import 'package:k3h_erp_app/widgets/custom_click_to_contact_widget.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/status/enquiry_status.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AwaitingFollowUpsWidget extends StatelessWidget {
  const AwaitingFollowUpsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SalesDashboardCubit, SalesDashboardState>(
      builder: (context, state) {
        final data =
            (state.salesDashboardList.isNotEmpty)
                ? state.salesDashboardList.first.table1
                : <Table1>[];
        return Container(
          padding: const EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            top: 12.0,
            bottom: 8.0,
          ),
          decoration: commonCardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "Awaiting Follow ",
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
                  height: data.length > 1 ? 450.h : null,
                  child: ListView.separated(
                    itemCount: data.length,
                    shrinkWrap: true,
                    physics:
                        data.length > 1
                            ? AlwaysScrollableScrollPhysics()
                            : NeverScrollableScrollPhysics(),
                    separatorBuilder:
                        (context, index) => verticalSpacing(height: 12.h),
                    itemBuilder: (context, int index) {
                      final activeFollowUps = data[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 12,
                              color: Colors.black.withValues(alpha: 0.05),
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Status Header
                            _statusHeader(activeFollowUps.finalStage),

                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  InkWell(
                                    onTap: () async {
                                      await loadAndSelectProjectById(
                                        activeFollowUps.projectId,
                                      );
                                      goRouter.pushNamed(
                                        AppRoutes.enquiry,
                                        queryParameters: {
                                          "enquiryName":
                                              Uri.encodeQueryComponent(
                                                EncryptionManager.encryptData(
                                                  activeFollowUps.name,
                                                ),
                                              ),
                                          "enquiryCode":
                                              Uri.encodeQueryComponent(
                                                EncryptionManager.encryptData(
                                                  activeFollowUps
                                                      .systemGeneratedCode,
                                                ),
                                              ),
                                        },
                                      );
                                    },
                                    child: Text(
                                      activeFollowUps.name,
                                      style: AppTextStyle.ts16M(
                                        color:
                                            activeFollowUps.isAction == 1
                                                ? AppColor.primary
                                                : null,
                                      ),
                                    ),
                                  ),

                                  verticalSpacing(height: 2),

                                  Text(
                                    activeFollowUps.projectName,
                                    style: AppTextStyle.ts12M(
                                      color: AppColor.grey,
                                    ),
                                  ),

                                  verticalSpacing(height: 12),

                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xffEEF2F6),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      activeFollowUps.systemGeneratedCode,
                                      style: AppTextStyle.ts14M(),
                                    ),
                                  ),

                                  verticalSpacing(height: 12),

                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    spacing: 10,
                                    children: [
                                      Expanded(
                                        child: InfoColumn(
                                          title: "Mobile Number",
                                          value: activeFollowUps.mobileNumber,
                                          customWidget: CustomClickToContactText(
                                            countryCode:
                                                activeFollowUps
                                                    .mobileNumberCountryCode,
                                            value: activeFollowUps.mobileNumber,
                                          ),
                                        ),
                                      ),

                                      Expanded(
                                        child: InfoColumn(
                                          title: "Next Follow-up Date",
                                          value: formatDateTimeAsDDMMMYYYY(
                                            activeFollowUps.nextFollowUpDate!,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  verticalSpacing(height: 12),

                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    spacing: 10,
                                    children: [
                                      Expanded(
                                        child: InfoColumn(
                                          title: "Sales Advisor",
                                          value: activeFollowUps.salesAdvisor,
                                        ),
                                      ),

                                      Expanded(
                                        child: InfoColumn(
                                          title: "Sourcing Manager",
                                          value:
                                              activeFollowUps.sourcingManager,
                                        ),
                                      ),
                                    ],
                                  ),

                                  Divider(height: 24, color: AppColor.grey50),

                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    spacing: 10,
                                    children: [
                                      Expanded(
                                        child: InfoColumn(
                                          title: "Created Date",
                                          value: formatDateTimeAsDDMMMYYYY(
                                            activeFollowUps.createdDate,
                                          ),
                                        ),
                                      ),

                                      Expanded(
                                        child: InfoColumn(
                                          title: "Due Days",
                                          value:
                                              activeFollowUps
                                                  .enquiryFollowUpDays,
                                          customWidget:
                                              followUpStatusTextWidget(
                                                activeFollowUps
                                                    .enquiryFollowUpDays,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
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

Widget _statusHeader(String status) {
  final config = enquiryStatusConfig[status.trim().toLowerCase()];

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
    decoration: BoxDecoration(
      color: config?.backgroundColor ?? AppColor.lightGrey,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(14),
        topRight: Radius.circular(14),
      ),
    ),
    child: Text(
      status.isEmpty ? "-" : status,
      style: AppTextStyle.ts12SB(color: config?.textColor),
    ),
  );
}
