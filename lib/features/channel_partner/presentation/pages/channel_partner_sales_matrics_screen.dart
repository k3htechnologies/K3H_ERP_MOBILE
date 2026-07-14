import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/channel_partner/data/model/channel_partner_aop.model.dart';
import 'package:k3h_erp_app/features/channel_partner/presentation/cubit/channel_partner_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/status/status.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class ChannelPartnerSalesMatricsScreen extends StatefulWidget {
  final int channelPartnerId;
  final String channelPartnerName;
  const ChannelPartnerSalesMatricsScreen({
    super.key,
    required this.channelPartnerId,
    required this.channelPartnerName,
  });

  @override
  State<ChannelPartnerSalesMatricsScreen> createState() =>
      _ChannelPartnerSalesMatricsScreenState();
}

class _ChannelPartnerSalesMatricsScreenState
    extends State<ChannelPartnerSalesMatricsScreen> {
  late ChannelPartnerCubit _channelPartnerCubit;
  // PAGINATION
  late ScrollController scrollController;
  Timer? _debounce;
  @override
  void initState() {
    super.initState();
    _channelPartnerCubit = context.read<ChannelPartnerCubit>();
    _onScroll();
    _channelPartnerCubit.getChannelPartnerAopList(
      channelPartnerId: widget.channelPartnerId,
      context: context,
      pageNumber: 1,
    );
  }

  void _onScroll() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !_channelPartnerCubit.state.isLoading! &&
          _channelPartnerCubit.state.channelPartnerList.length <
              _channelPartnerCubit.state.totalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _channelPartnerCubit.getChannelPartnerAopList(
            context: context,
            channelPartnerId: widget.channelPartnerId,
            pageNumber:
                _channelPartnerCubit.state.currentChannelPartnerAopPage + 1,
          );
        });
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Channel Partner",
        authorization: AuthorizationModel(),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Column(
          spacing: 12.h,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.channelPartnerName,
              style: AppTextStyle.ts14SB(color: AppColor.grey),
            ),
            Expanded(
              child: BlocBuilder<ChannelPartnerCubit, ChannelPartnerState>(
                builder: (context, state) {
                  if (state.isLoading == true &&
                      state.channelPartnerAopList.isEmpty) {
                    return Center(child: loader());
                  }

                  if (state.channelPartnerAopList.isEmpty) {
                    return Center(
                      child: noDataWidget(message: "No Data Found."),
                    );
                  }

                  return ListView.separated(
                    controller: scrollController,
                    itemCount: state.channelPartnerAopList.length + 1,
                    separatorBuilder: (_, __) => verticalSpacing(height: 12),
                    itemBuilder: (_, index) {
                      if (index == state.channelPartnerAopList.length) {
                        return state.channelPartnerAopList.length <
                                state.totalNumberOfChannelPartnerAopRecord
                            ? Padding(
                              padding: const EdgeInsets.all(16),
                              child: Center(child: CircularProgressIndicator()),
                            )
                            : const SizedBox.shrink();
                      }
                      final item = state.channelPartnerAopList[index];

                      return _AopCard(
                        model: item,
                        initiallyExpanded: index == 0,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AopCard extends StatelessWidget {
  final ChannelPartnerAopModel model;
  final bool initiallyExpanded;

  const _AopCard({required this.model, required this.initiallyExpanded});

  @override
  Widget build(BuildContext context) {
    final fy = "FY ${model.aopFromDate.year}–${model.aopToDate.year}";

    final paidPercent =
        model.brokerageAmount == 0
            ? 0.0
            : model.paidBrokerageAmount / model.brokerageAmount;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border:
            initiallyExpanded
                ? Border(left: BorderSide(color: AppColor.darkBlue, width: 4))
                : null,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xffF2F4FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.calendar_today_outlined, size: 18),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(fy, style: AppTextStyle.ts14SB()),
              aopStatusWidget(model.aopStatus),
            ],
          ),
          children:
              initiallyExpanded
                  ? [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "${formatDateTimeForApi(model.aopFromDate)} – ${formatDateTimeForApi(model.aopToDate)}",
                        style: AppTextStyle.ts12M(color: AppColor.grey),
                      ),
                    ),

                    verticalSpacing(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _item("ENQUIRY", model.noOfEnquiry.toString()),
                        ),
                        Expanded(
                          child: _item(
                            "BOOKINGS",
                            model.noOfBooking.toString(),
                          ),
                        ),
                      ],
                    ),

                    verticalSpacing(height: 12),

                    Row(
                      children: [
                        Expanded(child: _item("IBM", model.noOfIbm.toString())),
                        Expanded(child: _item("OBM", model.noOfObm.toString())),
                      ],
                    ),

                    verticalSpacing(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _item(
                            "ACCRUED",
                            model.brokerageAmount.toIndianCurrency(),
                          ),
                        ),
                        Expanded(
                          child: _item(
                            "BROKERAGE",
                            "${model.brokeragePercentage}%",
                          ),
                        ),
                      ],
                    ),

                    verticalSpacing(height: 12),

                    Row(
                      children: [
                        Text(
                          model.paidBrokerageAmount.toIndianCurrency(),
                          style: AppTextStyle.ts14SB(color: AppColor.primary),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Paid",
                          style: AppTextStyle.ts14SB(
                            color: AppColor.primary.withValues(alpha: .5),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          "${(paidPercent * 100).toStringAsFixed(0)}% of ${formatToKLCr(model.brokerageAmount)}",

                          style: AppTextStyle.ts12M(color: AppColor.grey),
                        ),
                      ],
                    ),

                    verticalSpacing(height: 8),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: paidPercent,
                        backgroundColor: AppColor.lightBlue.withValues(
                          alpha: 0.5,
                        ),
                        color: AppColor.primary,
                        minHeight: 8,
                      ),
                    ),

                    verticalSpacing(height: 12),

                    CustomButton(
                      isDisable: model.aopDocumentUrl.isEmpty,
                      backgroundColor: AppColor.white,
                      borderColor: AppColor.primary.withValues(alpha: 0.3),
                      textColor: AppColor.primary.withValues(alpha: .9),
                      text: 'View Document',
                      onPressed: () {
                        if (model.aopDocumentUrl.isNotEmpty) {
                          showFilePreviewDialog(
                            title: "AOP Document",
                            context,
                            model.aopDocumentUrl.split(","),
                          );
                        }
                      },
                    ),
                  ]
                  : [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "${formatDateTimeForApi(model.aopFromDate)} – ${formatDateTimeForApi(model.aopToDate)}",
                        style: AppTextStyle.ts12M(color: AppColor.grey),
                      ),
                    ),

                    verticalSpacing(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _item("ENQUIRY", model.noOfEnquiry.toString()),
                        ),
                        Expanded(
                          child: _item(
                            "BOOKINGS",
                            model.noOfBooking.toString(),
                          ),
                        ),
                      ],
                    ),

                    verticalSpacing(height: 12),

                    Row(
                      children: [
                        Expanded(child: _item("IBM", model.noOfIbm.toString())),
                        Expanded(child: _item("OBM", model.noOfObm.toString())),
                      ],
                    ),

                    verticalSpacing(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _item(
                            "ACCRUED",
                            model.brokerageAmount.toIndianCurrency(),
                          ),
                        ),
                        Expanded(
                          child: _item(
                            "BROKERAGE",
                            "${model.brokeragePercentage}%",
                          ),
                        ),
                      ],
                    ),

                    verticalSpacing(height: 12),

                    Row(
                      children: [
                        Text(
                          model.paidBrokerageAmount.toIndianCurrency(),
                          style: AppTextStyle.ts14SB(color: AppColor.primary),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Paid",
                          style: AppTextStyle.ts14SB(
                            color: AppColor.primary.withValues(alpha: .5),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          "${(paidPercent * 100).toStringAsFixed(0)}% of ${formatToKLCr(model.brokerageAmount)}",

                          style: AppTextStyle.ts12M(color: AppColor.grey),
                        ),
                      ],
                    ),

                    verticalSpacing(height: 12),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: paidPercent,
                        backgroundColor: AppColor.lightBlue.withValues(
                          alpha: 0.5,
                        ),
                        color: AppColor.primary,
                        minHeight: 8,
                      ),
                    ),

                    verticalSpacing(height: 12),

                    CustomButton(
                      isDisable: model.aopDocumentUrl.isEmpty,
                      backgroundColor: AppColor.white,
                      borderColor: AppColor.primary.withValues(alpha: 0.3),
                      textColor: AppColor.primary.withValues(alpha: .9),
                      text: 'View Document',
                      onPressed: () {
                        if (model.aopDocumentUrl.isNotEmpty) {
                          showFilePreviewDialog(
                            title: "AOP Document",
                            context,
                            model.aopDocumentUrl.split(","),
                          );
                        }
                      },
                    ),
                  ],
        ),
      ),
    );
  }

  Widget _item(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyle.ts12SB(color: AppColor.grey)),
        verticalSpacing(height: 4),
        Text(value, style: AppTextStyle.ts14M()),
      ],
    );
  }

  String formatDateTimeForApi(DateTime date) {
    const months = [
      "",
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];

    return "${date.day.toString().padLeft(2, '0')} ${months[date.month]} ${date.year}";
  }
}
