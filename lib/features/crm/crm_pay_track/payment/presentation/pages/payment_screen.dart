import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/payment/presentation/cubit/payment_cubit.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/payment/presentation/cubit/payment_state.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/payment/presentation/pages/widget/custom_expansion_tile.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_export_button.dart';
import 'package:k3h_erp_app/widgets/app_bar/search_widget.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/chip_style_tab_bar.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

import '../../../../../../utils/functions/common_function.dart';

class PaymentScreen extends StatefulWidget {
  final int projectId;
  final int bookingId;
  final String applicantName;
  final String bookingApprovalStatus;
  final String approvalStatus;
  const PaymentScreen({
    super.key,
    required this.projectId,
    required this.bookingId,
    required this.applicantName,
    required this.bookingApprovalStatus,
    required this.approvalStatus,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late PaymentCubit _paymentCubit;
  // TabController? _primaryTabController;
  // TabController? _secondaryTabController;
  late TextEditingController _searchTextC;
  // final ValueNotifier<String> _searchTextNotifier = ValueNotifier<String>(
  //   'Search By Project Name',
  // );
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
    _paymentCubit = context.read<PaymentCubit>();
    _searchTextC = TextEditingController();
    _paymentCubit.getPaymentScheduleList(
      context,
      widget.projectId,
      widget.bookingId,
    );
  }

  // HANDLE TAB CHANGE
  void _handleTabChange() async {
    if (!_tabController.indexIsChanging) {
      switch (_tabController.index) {
        case 0:
          await _paymentCubit.getPaymentScheduleList(
            context,
            widget.projectId,
            widget.bookingId,
          );
          break;

        case 1:
          await _paymentCubit.getPaymentLedgerList(
            context,
            widget.bookingId,
            widget.projectId,
          );
          break;
      }
    }
  }

  @override
  void dispose() {
    _searchTextC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        verticalSpacing(),
        ChipStyleTabBar(
          controller: _tabController,
          tabs: ['Payment Schedule', 'Payment Ledger'],
        ),
        _buildSearchBar(),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            physics: NeverScrollableScrollPhysics(),
            children: [
              _buildPaymentScheduleWidget(context),
              _buildPaymentLedgerWidget(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentScheduleWidget(BuildContext context) {
    return BlocBuilder<PaymentCubit, PaymentState>(
      builder: (context, state) {
        if ((state.isLoading ?? true) &&
            state.payTrackPaymentScheduleList.isEmpty) {
          return Center(child: CircularProgressIndicator());
        }

        return Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: state.payTrackPaymentScheduleList.length,
                  itemBuilder: (context, index) {
                    final paymentSchedules =
                        state.payTrackPaymentScheduleList[index];
                    final breakdownTitles = [
                      "Agreement Amount ( Excluding TDS )",
                      "GST Amount",
                      "TDS Amount",
                    ];
                    final stageName =
                        paymentSchedules.name.trim().toLowerCase();
                    final hideDemand =
                        stageName == "stamp duty" ||
                        stageName == "registration fees";
                    final showTrackLetter =
                        stageName != "stamp duty" &&
                        stageName != "registration fees";

                    final isStageOrDate =
                        paymentSchedules.type.toLowerCase() == "stage" ||
                        paymentSchedules.type.toLowerCase() == "date";
                    final showDemand = !hideDemand && isStageOrDate;
                    final disableDemand =
                        widget.bookingApprovalStatus.trim().toLowerCase() ==
                            "cancel" ||
                        widget.bookingApprovalStatus.trim().toLowerCase() ==
                            "refund" ||
                        paymentSchedules.demandType.trim().isEmpty;
                    final hasDemandType =
                        paymentSchedules.demandType.trim().isNotEmpty;
                    return CustomExpandableCard(
                      header: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildRowTitleValue(
                            title: "Stage / Milestone",
                            value:
                                paymentSchedules.type.contains("Date")
                                    ? paymentSchedules.date != null
                                        ? formatDateTimeAsDDMMMYYYY(
                                          paymentSchedules.date!,
                                        )
                                        : "-"
                                    : paymentSchedules.name,
                            singleLine: false,
                          ),
                          verticalSpacing(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildRowTitleValue(
                                title: "Percentage",
                                value:
                                    paymentSchedules.name
                                                .trim()
                                                .toLowerCase() ==
                                            "registration fees"
                                        ? "-"
                                        : "${paymentSchedules.paymentSchedulePercentage} %",
                              ),
                              buildRowTitleValue(
                                title: "Total Amount",
                                value:
                                    paymentSchedules.paymentScheduleAmount
                                        .toIndianCurrency(),
                              ),
                            ],
                          ),

                          (paymentSchedules.type.toLowerCase() == "stage" ||
                                      paymentSchedules.type.toLowerCase() ==
                                          "date") &&
                                  paymentSchedules.demandType.trim().isNotEmpty
                              ? verticalSpacing()
                              : SizedBox.shrink(),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (hasDemandType && showDemand)
                                Expanded(
                                  child: CustomButton(
                                    text:
                                        paymentSchedules.demandType
                                                .trim()
                                                .isEmpty
                                            ? "-"
                                            : paymentSchedules.demandType
                                                .trim(),
                                    isDisable: disableDemand,
                                    onPressed: () {
                                      _paymentCubit.addDemandDraft(
                                        context: context,
                                        bookingPaymentScheduleId:
                                            paymentSchedules
                                                .bookingPaymentScheduleId,
                                        bookingId: widget.bookingId,
                                        projectId: widget.projectId,
                                        paymentScheduleDemandType:
                                            paymentSchedules.demandType,
                                      );
                                    },
                                  ),
                                ),

                              if (showDemand && showTrackLetter)
                                horizontalSpacing(),
                              if (showTrackLetter)
                                Expanded(
                                  child: CustomButton(
                                    text: "Track Letter",
                                    backgroundColor: AppColor.white,
                                    textColor: AppColor.primary,
                                    borderColor: AppColor.primary,
                                    onPressed: () {
                                      goRouter.pushNamed(
                                        AppRoutes.paymentScheduleDemandSummary,
                                        extra: {
                                          "projectId": widget.projectId,
                                          "bookingId": widget.bookingId,
                                          "bookingPaymentScheduleId":
                                              paymentSchedules
                                                  .bookingPaymentScheduleId,
                                          "stageName": paymentSchedules.name,
                                          "applicantName": widget.applicantName,
                                        },
                                      );
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                      body: Column(
                        children: [
                          Divider(
                            thickness: 0.3,
                            color: AppColor.black.withValues(alpha: 0.3),
                          ),
                          Column(
                            children: List.generate(breakdownTitles.length, (
                              breakdownIndex,
                            ) {
                              final title = breakdownTitles[breakdownIndex];

                              double totalAmount = 0;
                              double receivedAmount = 0;

                              if (breakdownIndex == 0) {
                                totalAmount =
                                    paymentSchedules.paymentScheduleAmount;
                                receivedAmount =
                                    paymentSchedules
                                        .paymentScheduleReceivedAmount;
                              } else if (breakdownIndex == 1) {
                                totalAmount =
                                    paymentSchedules.paymentScheduleGstAmount;
                                receivedAmount =
                                    paymentSchedules
                                        .paymentScheduleReceivedGstAmount;
                              } else if (breakdownIndex == 2) {
                                totalAmount =
                                    paymentSchedules.paymentScheduleTdsAmount;
                                receivedAmount =
                                    paymentSchedules
                                        .paymentScheduleReceivedTdsAmount;
                              }

                              final outstandingAmount =
                                  totalAmount - receivedAmount;

                              return Column(
                                spacing: 6.0,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (breakdownIndex != 0)
                                    Divider(
                                      thickness: 0.3,
                                      color: AppColor.black.withValues(
                                        alpha: 0.3,
                                      ),
                                    ),

                                  Text(title, style: AppTextStyle.ts14M()),

                                  buildRowTitleValue(
                                    title: "Total Amount",
                                    value: totalAmount.toIndianCurrency(),
                                  ),

                                  buildRowTitleValue(
                                    title: "Received Amount",
                                    value: receivedAmount.toIndianCurrency(),
                                  ),

                                  buildRowTitleValue(
                                    title: "Outstanding Amount",
                                    value: outstandingAmount.toIndianCurrency(),
                                  ),
                                ],
                              );
                            }),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: commonCardDecoration(),
                child: Builder(
                  builder: (_) {
                    double totalAmount = 0;
                    double totalOutstandingAmount = 0;
                    double grandTotal = 0;

                    for (final item in state.payTrackPaymentScheduleList) {
                      final agreementTotal = item.paymentScheduleAmount;
                      final agreementReceived =
                          item.paymentScheduleReceivedAmount;
                      final agreementOutstanding =
                          agreementTotal - agreementReceived;
                      final gstTotal = item.paymentScheduleGstAmount;
                      final gstReceived = item.paymentScheduleReceivedGstAmount;
                      final gstOutstanding = gstTotal - gstReceived;
                      final tdsTotal = item.paymentScheduleTdsAmount;
                      final tdsReceived = item.paymentScheduleReceivedTdsAmount;
                      final tdsOutstanding = tdsTotal - tdsReceived;
                      totalAmount += agreementTotal + gstTotal + tdsTotal;
                      totalOutstandingAmount +=
                          agreementOutstanding +
                          gstOutstanding +
                          tdsOutstanding;
                      grandTotal +=
                          agreementReceived + gstReceived + tdsReceived;
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        buildRowTitleValue(
                          title: "Total Amount",
                          value: totalAmount.toIndianCurrency(),
                          valueTextStyle: AppTextStyle.ts14SB(),
                        ),

                        Divider(
                          thickness: 0.3,
                          color: AppColor.black.withValues(alpha: 0.3),
                        ),

                        buildRowTitleValue(
                          title: "Total Outstanding Amount",
                          value: totalOutstandingAmount.toIndianCurrency(),
                          valueTextStyle: AppTextStyle.ts14SB(),
                        ),

                        Divider(
                          thickness: 0.3,
                          color: AppColor.black.withValues(alpha: 0.3),
                        ),

                        buildRowTitleValue(
                          title: "Grand Total",
                          value: grandTotal.toIndianCurrency(),
                          valueTextStyle: AppTextStyle.ts14SB(
                            color: AppColor.green,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaymentLedgerWidget(BuildContext context) {
    return BlocBuilder<PaymentCubit, PaymentState>(
      builder: (context, state) {
        if (state.isLoading ?? true && state.paymentLedger.isEmpty) {
          return Center(child: CircularProgressIndicator());
        }
        final showAddButton =
            widget.bookingApprovalStatus.toLowerCase() != "cancel" &&
            widget.bookingApprovalStatus.toLowerCase() != "refund";
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  spacing: 10.0,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    showAddButton
                        ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Add Payment Ledger",
                              style: AppTextStyle.ts14M(),
                            ),
                            horizontalSpacing(),
                            Align(
                              alignment: Alignment.centerRight,
                              child: CustomButton(
                                text: "Add",
                                onPressed: () {
                                  goRouter.pushNamed(
                                    AppRoutes.addPaymentLedger,
                                    queryParameters: {
                                      "paymentLedger": Uri.encodeComponent(
                                        jsonEncode(
                                          state.paymentLedger
                                              .map((e) => e.toJson())
                                              .toList(),
                                        ),
                                      ),
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        )
                        : SizedBox.shrink(),
                    Expanded(
                      child: ListView.builder(
                        itemCount: state.paymentLedger.length,
                        itemBuilder: (context, index) {
                          final ledger = state.paymentLedger[index];
                          return Container(
                            padding: EdgeInsets.all(16.0),
                            margin: EdgeInsets.only(bottom: 10.0),
                            decoration: commonCardDecoration(),
                            child: Column(
                              spacing: 10.0,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () async {
                                          goRouter.pushNamed(
                                            AppRoutes.viewPaymentLedger,
                                            queryParameters: {
                                              'paymentLedgerSummary':
                                                  Uri.encodeComponent(
                                                    jsonEncode(ledger.toJson()),
                                                  ),
                                            },
                                          );
                                        },
                                        child: Text(
                                          ledger.paymentFor,
                                          style: AppTextStyle.ts14M(
                                            color: AppColor.primary,
                                          ),
                                        ),
                                      ),
                                    ),
                                    horizontalSpacing(),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 12.0,
                                          vertical: 4.0,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            12.0,
                                          ),
                                          color: AppColor.lightBlue,
                                        ),
                                        child: Text(
                                          "${ledger.approvalPendingPaymentLedgerCount} Pending",
                                          style: AppTextStyle.ts12M(),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                buildRowTitleValue(
                                  title: "Total Amount",
                                  value: ledger.totalAmount.toIndianCurrency(),
                                ),
                                buildRowTitleValue(
                                  title: "Received Amount",
                                  value:
                                      ledger.receivedAmount.toIndianCurrency(),
                                ),

                                buildRowTitleValue(
                                  title: "Outstanding Amount",
                                  value:
                                      (ledger.totalAmount -
                                              ledger.receivedAmount)
                                          .toIndianCurrency(),
                                ),
                                buildRowTitleValue(
                                  title: "Ledger Count",
                                  value:
                                      ledger.uploadedPaymentLedgerCount
                                          .toString(),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: commonCardDecoration(),
                child: Builder(
                  builder: (_) {
                    double totalAmount = 0;
                    double totalOutstandingAmount = 0;
                    double grandTotal = 0;
                    double ledgerCountTotal = 0;
                    double approvalCountTotal = 0;

                    for (final item in state.paymentLedger) {
                      final total = item.totalAmount;
                      final paid = item.receivedAmount;
                      final pending = total - paid;
                      final totalLedgerCount = item.uploadedPaymentLedgerCount;
                      final totalApprovalCount =
                          item.approvalPendingPaymentLedgerCount;

                      totalAmount += total;

                      totalOutstandingAmount += pending;

                      grandTotal += paid;
                      ledgerCountTotal += totalLedgerCount;
                      approvalCountTotal += totalApprovalCount;
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        buildRowTitleValue(
                          title: "Total Amount",
                          value: totalAmount.toIndianCurrency(),
                          valueTextStyle: AppTextStyle.ts14SB(),
                        ),

                        Divider(
                          thickness: 0.3,
                          color: AppColor.black.withValues(alpha: 0.3),
                        ),

                        buildRowTitleValue(
                          title: "Total Outstanding Amount",
                          value: totalOutstandingAmount.toIndianCurrency(),
                          valueTextStyle: AppTextStyle.ts14SB(),
                        ),

                        Divider(
                          thickness: 0.3,
                          color: AppColor.black.withValues(alpha: 0.3),
                        ),

                        buildRowTitleValue(
                          title: "Grand Total",
                          value: grandTotal.toIndianCurrency(),
                          valueTextStyle: AppTextStyle.ts14SB(
                            color: AppColor.green,
                          ),
                        ),
                        Divider(
                          thickness: 0.3,
                          color: AppColor.black.withValues(alpha: 0.3),
                        ),

                        buildRowTitleValue(
                          title: "Ledger Count",
                          value: ledgerCountTotal.toIndianCurrency(),
                          valueTextStyle: AppTextStyle.ts14SB(),
                        ),
                        Divider(
                          thickness: 0.3,
                          color: AppColor.black.withValues(alpha: 0.3),
                        ),

                        buildRowTitleValue(
                          title: "Approval Count",
                          value: approvalCountTotal.toIndianCurrency(),
                          valueTextStyle: AppTextStyle.ts14SB(),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return BlocBuilder<PaymentCubit, PaymentState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: SearchWidget(
                  hintText: "Search by Stage / Milestone",
                  onSubmit: (value) {
                    _paymentCubit.search(
                      context: context,
                      searchText: value,
                      bookingId: widget.bookingId,
                      projectId: widget.projectId,
                      selectedTab: _tabController.index,
                    );
                  },
                  textController: _searchTextC,
                ),
              ),
              horizontalSpacing(),
              CustomExportButton(
                onExport: (type) {
                  if (_tabController.index == 1) {
                    _paymentCubit.exportPaymentLedger(
                      context,
                      widget.bookingId,
                      widget.projectId,
                      getProject().projectName,
                      type,
                    );
                  } else {
                    _paymentCubit.exportPaymentSchedule(
                      context,
                      widget.bookingId,
                      widget.projectId,
                      getProject().projectName,
                      type,
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
