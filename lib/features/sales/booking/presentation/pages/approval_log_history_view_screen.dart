import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/models/approval_log_history.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class ApprovalLogHistoryScreen extends StatelessWidget {
  final String subTitle;
  final List<ApprovalLogHistory> items;

  const ApprovalLogHistoryScreen({
    super.key,
    required this.subTitle,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Approval Log History",
        authorization: AuthorizationModel(),
      ),
      backgroundColor: Colors.grey.shade100,
      body:
          items.isEmpty
              ? const Center(child: Text("No Data Found"))
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // SUB TITLE
                      Text(
                        subTitle,
                        style: AppTextStyle.ts16M(color: AppColor.grey),
                      ),
                      const SizedBox(height: 16),

                      /// TIMELINE
                      ListView.builder(
                        itemCount: items.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          final isExtraDot = index == items.length;
                          final isLastItem = index == items.length - 1;

                          return IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Column(
                                  children: [
                                    // Dot
                                    Container(
                                      width: 16,
                                      height: 16,
                                      margin: const EdgeInsets.only(top: 2),
                                      decoration: BoxDecoration(
                                        color:
                                            isExtraDot
                                                ? AppColor.lightBlue
                                                : AppColor.primary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),

                                    // Connector
                                    if (!isExtraDot)
                                      Expanded(
                                        child: Container(
                                          width: 2,
                                          margin: const EdgeInsets.symmetric(
                                            vertical: 2,
                                          ),
                                          color:
                                              isLastItem
                                                  ? AppColor.lightBlue
                                                  : AppColor.primary,
                                        ),
                                      ),
                                  ],
                                ),
                                horizontalSpacing(),

                                /// RIGHT SIDE CONTENT
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        /// NAME + STATUS
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    item.fullName,
                                                    style: AppTextStyle.ts14M(),
                                                  ),
                                                  Text(formatDate(item.date)),
                                                ],
                                              ),
                                            ),

                                            statusWidget(item.approvalStatus),
                                          ],
                                        ),

                                        const SizedBox(height: 6),

                                        /// DESIGNATION + DEPARTMENT
                                        Text(
                                          "(${item.designation} | ${item.department})",
                                          style: AppTextStyle.ts14R(
                                            color: AppColor.grey,
                                          ),
                                        ),
                                        if (item.remarks.isNotEmpty) ...[
                                          const SizedBox(height: 6),
                                          Text(
                                            item.remarks,
                                            style: AppTextStyle.ts14R(),
                                          ),
                                        ],
                                        const SizedBox(height: 6),
                                      ],
                                    ),
                                  ),
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
  }

  /// STATUS CHIP
  Widget statusWidget(String status) {
    final trimmed = status.trim();

    final s = trimmed.toLowerCase();

    switch (s) {
      case 'approved':
        return statusChip(status, AppColor.green20, AppColor.green);

      case 'rejected':
        return statusChip(status, AppColor.lightRed, AppColor.red);

      case 'pending':
        return statusChip(status, AppColor.lightYellow, AppColor.brown);

      case 'partially approved':
        return statusChip(status, AppColor.lightPurple, AppColor.purple);

      default:
        return statusChip(status, AppColor.lightGreyBackground, AppColor.black);
    }
  }
}
