import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/channel_partner/presentation/cubit/channel_partner_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class ChannelPartnerDashboardScreen extends StatefulWidget {
  const ChannelPartnerDashboardScreen({super.key});

  @override
  State<ChannelPartnerDashboardScreen> createState() =>
      _ChannelPartnerDashboardScreenState();
}

class _ChannelPartnerDashboardScreenState
    extends State<ChannelPartnerDashboardScreen> {
  // CUBIT
  late ChannelPartnerCubit _channelPartnerCubit;
  @override
  void initState() {
    _channelPartnerCubit = context.read<ChannelPartnerCubit>();
    _channelPartnerCubit.getChannelPartnerDashboardList(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChannelPartnerCubit, ChannelPartnerState>(
      builder: (context, state) {
        if (state.isLoading!) {
          return Center(child: loader());
        }
        final channelPartnerDashboardModel = state.channelPartnerDashboardModel;
        final table0 = channelPartnerDashboardModel?.table0.first;
        return Scaffold(
          backgroundColor: AppColor.lightGreyBackground,
          appBar: CustomAppBarWithBackButton(
            screenTitle: "Channel Partner Dashbaord",
            isMenuButton: true,
            showNotification: true,
            authorization: AuthorizationModel(),
          ),
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTotalCasesWidget(
                    context,
                    bgColor: AppColor.blueBgColor,
                    title: "Total Channel Partner",
                    titleColor: AppColor.white,
                    value: table0!.totalChannelPartner,
                    valueColor: AppColor.white,
                  ),
                  verticalSpacing(),
                  _buildTotalCasesWidget(
                    context,
                    bgColor: AppColor.white,
                    title: "Active Channel Partner",
                    titleColor: AppColor.black.withValues(alpha: 0.5),
                    value: table0.activeChannelPartner,
                    valueColor: AppColor.black,
                  ),
                  verticalSpacing(),
                  _buildTotalCasesWidget(
                    context,
                    bgColor: AppColor.white,
                    title: "New Added Channel Partner",
                    titleColor: AppColor.black.withValues(alpha: 0.5),
                    value: table0.thisMonthAddedChannelPartner,
                    valueColor: AppColor.black,
                    subText: "this month",
                    valuesubTextColor: AppColor.green,
                  ),
                  verticalSpacing(),
                  _buildTotalCasesWidget(
                    context,
                    bgColor: AppColor.missingInformationRed.withValues(
                      alpha: 0.1,
                    ),
                    title: "Missing Information",
                    titleColor: AppColor.black.withValues(alpha: 0.5),
                    value: table0.missingInfoChannelPartner,
                    valueColor: AppColor.missingInformationRed,
                    borderColor: AppColor.missingInformationRed,
                  ),
                  verticalSpacing(),
                  // CHANNEL PARTNER DISTRIBUTION WIDGET
                  _buildChannelPartnerDistributionWidget(context),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTotalCasesWidget(
    BuildContext context, {
    required Color bgColor,
    required String title,
    required Color titleColor,
    required int value,
    required Color valueColor,
    String? subText,
    Color? valuesubTextColor,
    Color? borderColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        color: bgColor,
        border:
            borderColor != null
                ? Border.all(color: borderColor, width: 1)
                : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyle.ts14M(color: titleColor.withValues(alpha: 0.7)),
          ),
          const SizedBox(height: 8),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value.toString(),
                style: AppTextStyle.ts20SB(color: valueColor),
              ),
              if (subText != null) ...[
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    subText,
                    style: AppTextStyle.ts12R(
                      color: valuesubTextColor ?? Colors.green,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChannelPartnerDistributionWidget(BuildContext context) {
    return BlocBuilder<ChannelPartnerCubit, ChannelPartnerState>(
      builder: (context, state) {
        if (state.isLoading!) {
          return Center(child: loader());
        }
        final channelPartnerDashboardModel = state.channelPartnerDashboardModel;
        final table2 = channelPartnerDashboardModel?.table2;
        final totalSum = table2?.fold<int>(
          0,
          (sum, item) => sum + item.totalCount,
        );
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          decoration: commonCardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      "Channel Partner Distribution",
                      style: AppTextStyle.ts14M(
                        color: AppColor.black.withValues(alpha: 0.50),
                      ),
                    ),
                  ),
                ],
              ),
              Divider(
                thickness: 0.3,
                color: AppColor.black.withValues(alpha: 0.5),
              ),
              verticalSpacing(),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      "Partner Type Distribution",
                      style: AppTextStyle.ts14SB(color: AppColor.black),
                    ),
                  ),
                ],
              ),
              verticalSpacing(),
              if (table2 != null && table2.isNotEmpty) ...[
                SizedBox(
                  height: 200.0,
                  child: ListView.builder(
                    itemCount: table2.length,
                    shrinkWrap: true,
                    physics: AlwaysScrollableScrollPhysics(),
                    itemBuilder: (context, int index) {
                      final partnerTypeDistribution = table2[index];
                      return _buildParkingRow(
                        title: partnerTypeDistribution.type,
                        count: partnerTypeDistribution.totalCount,
                        totalSum: totalSum!,
                      );
                    },
                  ),
                ),
              ] else
                ...[],
            ],
          ),
        );
      },
    );
  }

  Widget _buildParkingRow({
    required String title,
    required int count,
    required int totalSum,
  }) {
    final double progress =
        totalSum == 0 ? 0 : (count / totalSum).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyle.ts14M(
                    color: AppColor.black.withValues(alpha: 0.7),
                  ),
                ),
              ),
              Text(
                "$count",
                style: AppTextStyle.ts14M(
                  color: AppColor.black.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              borderRadius: BorderRadius.circular(8.0),
              value: progress,
              minHeight: 8,
              backgroundColor: AppColor.primary.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation(AppColor.primary),
            ),
          ),
        ],
      ),
    );
  }
}
