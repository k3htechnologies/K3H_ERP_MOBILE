import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/payment/presentation/cubit/payment_cubit.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/payment/presentation/cubit/payment_state.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/functions/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class PaymentScheduleDemandLetterSummary extends StatefulWidget {
  final int projectId;
  final int bookingId;
  final int bookingPaymentScheduleId;
  final String stageName;
  final String applicantName;
  const PaymentScheduleDemandLetterSummary({
    super.key,
    required this.projectId,
    required this.bookingId,
    required this.bookingPaymentScheduleId,
    required this.stageName,
    required this.applicantName,
  });

  @override
  State<PaymentScheduleDemandLetterSummary> createState() =>
      _PaymentScheduleDemandLetterSummaryState();
}

class _PaymentScheduleDemandLetterSummaryState
    extends State<PaymentScheduleDemandLetterSummary> {
  late PaymentCubit _paymentCubit;
  // AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;
  late ProjectModel _selectedProject;
  @override
  void initState() {
    super.initState();
    _paymentCubit = context.read<PaymentCubit>();
    _selectedProject = getProject();
    _paymentCubit.getPayTrackPaymentScheduleDemandSummaryList(
      context,
      widget.bookingId,
      widget.projectId,
      widget.bookingPaymentScheduleId,
    );
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes
            .paymentScheduleDemandSummary] ??
        AuthorizationModel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Pay Track",
        authorization: _routeAuthorizationModel,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
            child: showSiteSelectedWidget(
              projectName: _selectedProject.projectName,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22.0),
            child: Text(
              "${widget.applicantName}  >  ${widget.stageName}",
              style: AppTextStyle.ts16M(),
            ),
          ),
          verticalSpacing(),
          Expanded(
            child: BlocBuilder<PaymentCubit, PaymentState>(
              builder: (context, state) {
                if (state.isLoading ?? false) {
                  return loader();
                }
                if (state.payTrackPaymentScheduleDemandSummaryModel.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: commonCardDecoration(),
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                margin: const EdgeInsets.only(top: 2),
                                decoration: BoxDecoration(
                                  color: AppColor.lightBlue,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              horizontalSpacing(),
                              Text(
                                dateFormatterDDMMYYYYDAY(
                                  DateTime(2001),
                                  isDayNotRequired: true,
                                ),
                                style: AppTextStyle.ts12M(color: AppColor.grey),
                              ),
                              Spacer(),
                              Text(
                                "Next Follow-up",
                                style: AppTextStyle.ts12SB(
                                  color: AppColor.darkGrey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (state.payTrackPaymentScheduleDemandSummaryModel.isEmpty) {
                  return Center(child: noDataWidget());
                }
                final items = state.payTrackPaymentScheduleDemandSummaryModel;
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: commonCardDecoration(),
                  padding: const EdgeInsets.all(16.0),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: AlwaysScrollableScrollPhysics(),
                    itemCount:
                        state.payTrackPaymentScheduleDemandSummaryModel.length,
                    itemBuilder: (context, index) {
                      final isExtraDot = index == items.length;
                      final item = !isExtraDot ? items[index] : items[0];
                      final isLastItem = index == items.length - 1;
                      return IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  margin: const EdgeInsets.only(top: 2),
                                  decoration: BoxDecoration(
                                    color:
                                        isLastItem
                                            ? AppColor.lightBlue
                                            : AppColor.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
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
                            // Timeline Content
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 24),
                                child:
                                    isExtraDot
                                        ? Text(
                                          item.paymentScheduleDemandType,
                                          style: AppTextStyle.ts14R(
                                            color: AppColor.primary,
                                          ),
                                        )
                                        : Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 6.0,
                                                    vertical: 2.0,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          6.0,
                                                        ),
                                                    color: Color(0xFFE3ECFF),
                                                  ),
                                                  child: Text(
                                                    item.paymentScheduleDemandType,
                                                    style: AppTextStyle.ts14R(
                                                      color: AppColor.primary,
                                                    ),
                                                  ),
                                                ),
                                                horizontalSpacing(),
                                                CustomButton.documentOutline(
                                                  onPressed: () {
                                                    if (item
                                                        .paymentScheduleDemandSummaryUrl
                                                        .isNotEmpty) {
                                                      showFilePreviewDialog(
                                                        title:
                                                            item.paymentScheduleDemandType,
                                                        context,
                                                        item.paymentScheduleDemandSummaryUrl
                                                            .split(","),
                                                      );
                                                    }
                                                  },

                                                  isDisable:
                                                      item
                                                          .paymentScheduleDemandSummaryUrl
                                                          .isEmpty,
                                                ),
                                              ],
                                            ),
                                            Text(
                                              item.createdBy,
                                              style: AppTextStyle.ts12M(),
                                            ),
                                            Text(
                                              dateFormatterDDMMYYYYDAY(
                                                item.createdDate,
                                                isDayNotRequired: false,
                                              ),
                                              style: AppTextStyle.ts12M(),
                                            ),
                                          ],
                                        ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
