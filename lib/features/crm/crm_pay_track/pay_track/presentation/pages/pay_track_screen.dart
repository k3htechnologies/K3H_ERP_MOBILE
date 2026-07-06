import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/pay_track/presentation/cubit/pay_track_cubit.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/pay_track/presentation/cubit/pay_track_state.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class PayTrackScreen extends StatefulWidget {
  const PayTrackScreen({super.key});

  @override
  State<PayTrackScreen> createState() => _PayTrackScreenState();
}

class _PayTrackScreenState extends State<PayTrackScreen> {
  late PayTrackCubit _payTrackCubit;
  late ProjectModel _selectedProject;
  late TextEditingController _searchC;
  // PAGINATION
  late ScrollController scrollController;
  Timer? _debounce;
  @override
  void initState() {
    super.initState();
    _payTrackCubit = context.read<PayTrackCubit>();
    _selectedProject = getProject();
    _searchC = TextEditingController();
    _payTrackCubit.getPayTrackList(context, 1, _selectedProject.projectId);
    _onScroll();
  }

  @override
  void dispose() {
    _searchC.dispose();
    scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // PAGINATION
  void _onScroll() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !(_payTrackCubit.state.isLoading ?? false) &&
          _payTrackCubit.state.payTrackList.length <
              _payTrackCubit.state.totalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _payTrackCubit.getPayTrackList(
            context,
            _payTrackCubit.state.currentPage + 1,
            _selectedProject.projectId,
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        screenTitle: 'Pay Track',
        authorization: AuthorizationModel(),
        onProjectChangeCallback: (value) {
          _selectedProject = value;
          _payTrackCubit.getPayTrackList(
            context,
            1,
            _selectedProject.projectId,
          );
        },
        searchHintText: "Search by Name",
        onSearchSubmit: (value) {},
        textController: _searchC,
      ),
      body: BlocBuilder<PayTrackCubit, PayTrackState>(
        builder: (context, state) {
          return ListView.builder(
            controller: scrollController,
            itemCount: state.payTrackList.length,
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemBuilder: (context, index) {
              if (index == state.payTrackList.length) {
                return state.payTrackList.length < state.totalNumberOfRecord
                    ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    )
                    : const SizedBox.shrink();
              }
              final payTrack = state.payTrackList[index];
              final List<Map<String, dynamic>> summaryItems = [
                {
                  "type": "Stamp Duty",
                  "total": payTrack.stampDutyAmount,
                  "paid": payTrack.receivedStampDutyAmount,
                },
                {
                  "type": "Registration Fees",
                  "total": payTrack.registrationFees,
                  "paid": payTrack.receivedRegistrationFees,
                },
                {
                  "type": "Agreement Value",
                  "total": payTrack.agreementValue,
                  "paid": payTrack.receivedAgreementValue,
                },
                {
                  "type": "Agreement Value GST",
                  "total": payTrack.agreementValueGstAmount,
                  "paid": payTrack.receivedAgreementValueGstAmount,
                },
                {
                  "type": "Agreement Value TDS",
                  "total": payTrack.agreementValueTds,
                  "paid": payTrack.receivedAgreementValueTds,
                },
                {
                  "type": "Other Charges Value",
                  "total": payTrack.otherChargesAmount,
                  "paid": payTrack.receivedOtherChargesAmount,
                },
                {
                  "type": "Other Charges GST",
                  "total": payTrack.otherChargesGstAmount,
                  "paid": payTrack.receivedOtherChargesGstAmount,
                },
              ];
              double totalAmount = 0;
              double totalPaidAmount = 0;
              double totalPendingAmount = 0;

              for (final item in summaryItems) {
                final total = (item["total"] as num).toDouble();
                final paid = (item["paid"] as num).toDouble();
                final pending = total - paid;

                totalAmount += total;
                totalPaidAmount += paid;
                totalPendingAmount += pending;
              }
              return Container(
                padding: EdgeInsets.all(16.0),
                margin: EdgeInsets.only(bottom: 10.0),
                decoration: commonCardDecoration(),
                child: Column(
                  spacing: 10.0,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            await _payTrackCubit.resetOverview();
                            await goRouter.pushNamed(
                              AppRoutes.viewPayTrackMaster,
                              queryParameters: {
                                "applicantName": Uri.encodeQueryComponent(
                                  EncryptionManager.encryptData(
                                    payTrack.applicantName,
                                  ),
                                ),
                                "projectId": Uri.encodeQueryComponent(
                                  EncryptionManager.encryptData(
                                    payTrack.projectId.toString(),
                                  ),
                                ),
                                "bookingId": Uri.encodeQueryComponent(
                                  EncryptionManager.encryptData(
                                    payTrack.bookingId.toString(),
                                  ),
                                ),
                                "enquiryId": Uri.encodeQueryComponent(
                                  EncryptionManager.encryptData(
                                    payTrack.enquiryId.toString(),
                                  ),
                                ),
                              },
                            );
                          },
                          child: Text(
                            payTrack.applicantName.isNotEmpty
                                ? payTrack.applicantName
                                : '-',
                            style: AppTextStyle.ts16M(color: AppColor.primary),
                          ),
                        ),
                      ],
                    ),
                    buildRowTitleValue(
                      title: "Enquiry Code",
                      value: payTrack.systemGeneratedCode.toString(),
                    ),
                    buildRowTitleValue(
                      title: "Mobile No.",
                      value: payTrack.applicantMobileNumber.toString(),
                    ),
                    buildRowTitleValue(
                      title: "Registration Date",
                      value: formatDateTimeAsDDMMMYYYY(
                        payTrack.registrationDate,
                      ),
                    ),
                    buildRowTitleValue(title: "Flat", value: payTrack.flat),
                    ExpansionTile(
                      tilePadding: EdgeInsets.symmetric(horizontal: 6.0),
                      childrenPadding: EdgeInsets.zero,
                      backgroundColor: AppColor.lightBlue,
                      collapsedBackgroundColor: AppColor.lightBlue,
                      expandedCrossAxisAlignment: CrossAxisAlignment.start,
                      iconColor: AppColor.black,
                      collapsedIconColor: AppColor.black,
                      shape: const Border(),
                      collapsedShape: const Border(),
                      title: Text(
                        "Cost & Tax Summary",
                        style: AppTextStyle.ts14M(),
                      ),
                      children: [
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColor.lightBlue,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 250.0,
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      ...summaryItems.map((item) {
                                        final total =
                                            (item["total"] as num).toDouble();
                                        final paid =
                                            (item["paid"] as num).toDouble();
                                        final pending = total - paid;
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            left: 16.0,
                                            bottom: 16.0,
                                            right: 16.0,
                                          ),
                                          child: _buildSummaryItem(
                                            type: item["type"],
                                            totalAmount:
                                                "₹${total.toStringAsFixed(2)}",
                                            paidAmount:
                                                "₹${paid.toStringAsFixed(2)}",
                                            pendingAmount:
                                                "₹${pending.toStringAsFixed(2)}",
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: AppColor.white,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 14,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColor.blue,
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(8),
                                          topRight: Radius.circular(8),
                                        ),
                                      ),
                                      child: Text(
                                        "Total Summary",
                                        style: AppTextStyle.ts14M(
                                          color: AppColor.lightBlue,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                        top: 12.0,
                                        left: 12.0,
                                        right: 12.0,
                                      ),
                                      child: Column(
                                        children: [
                                          _summaryRow(
                                            "Total Amount",
                                            "₹${totalAmount.toStringAsFixed(2)}",
                                          ),
                                          verticalSpacing(height: 6),
                                          Divider(
                                            height: 1,
                                            thickness: 0.3,
                                            color: AppColor.black.withValues(
                                              alpha: 0.5,
                                            ),
                                          ),
                                          verticalSpacing(height: 6),
                                          _summaryRow(
                                            "Total Pending Amount",
                                            "₹${totalPendingAmount.toStringAsFixed(2)}",
                                            valueColor: AppColor.orange,
                                          ),
                                          verticalSpacing(height: 6),
                                          Divider(
                                            height: 1,
                                            thickness: 0.3,
                                            color: AppColor.black.withValues(
                                              alpha: 0.5,
                                            ),
                                          ),
                                          verticalSpacing(height: 6),
                                          _summaryRow(
                                            "Grand Total",
                                            "₹${totalPaidAmount.toStringAsFixed(2)}",
                                            isBold: true,
                                            valueColor: AppColor.green,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _summaryRow(
    String title,
    String value, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style:
              isBold
                  ? AppTextStyle.ts14B()
                  : AppTextStyle.ts14R(
                    color: AppColor.black.withValues(alpha: 0.5),
                  ),
        ),
        Text(value, style: AppTextStyle.ts14M(color: valueColor)),
      ],
    );
  }

  Widget _buildSummaryItem({
    required String type,
    required String totalAmount,
    required String paidAmount,
    required String pendingAmount,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _titleValue("Type", type)),
            horizontalSpacing(),
            Expanded(child: _titleValue("Total Amount", totalAmount)),
          ],
        ),
        verticalSpacing(),
        Row(
          children: [
            Expanded(child: _titleValue("Paid Amount", paidAmount)),
            horizontalSpacing(),
            Expanded(child: _titleValue("Pending Amount", pendingAmount)),
          ],
        ),
        verticalSpacing(),
        Divider(
          height: 1,
          thickness: 0.3,
          color: AppColor.black.withValues(alpha: 0.5),
        ),
      ],
    );
  }

  Widget _titleValue(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyle.ts12M(
            color: AppColor.black.withValues(alpha: 0.5),
          ),
        ),
        verticalSpacing(height: 6),
        Text(value, style: AppTextStyle.ts14M()),
      ],
    );
  }
}
