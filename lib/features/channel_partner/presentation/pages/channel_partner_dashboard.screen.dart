import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/channel_partner/data/model/channel_partner_dashboard.model.dart';
import 'package:k3h_erp_app/features/channel_partner/presentation/cubit/channel_partner_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/charts/custom_radial_chart.dart';
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
  // AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;
  @override
  void initState() {
    _channelPartnerCubit = context.read<ChannelPartnerCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.channelPartner]!;
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
            screenTitle: "Channel Partner Dashboard",
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
                  if (_routeAuthorizationModel.isAction) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CustomButton(
                          leading: Icon(
                            Icons.add,
                            size: 18,
                            color: AppColor.white,
                          ),
                          text: "Add Channel Partner",
                          onPressed: () {
                            goRouter.pushNamed(AppRoutes.addChannelPartner);
                          },
                        ),
                      ],
                    ),
                    verticalSpacing(),
                  ],

                  _buildTotalCasesWidget(
                    context,
                    bgColor: AppColor.blueBgColor,
                    title: "Total Channel Partner",
                    titleColor: AppColor.white,
                    value: table0?.totalChannelPartner ?? 0,
                    valueColor: AppColor.white,
                  ),
                  verticalSpacing(),
                  _buildTotalCasesWidget(
                    context,
                    bgColor: AppColor.white,
                    title: "Enquiry By CP",
                    titleColor: AppColor.black.withValues(alpha: 0.5),
                    value: table0?.activeChannelPartner ?? 0,
                    subText: "this month",
                    valueColor: AppColor.black,
                  ),
                  verticalSpacing(),
                  _buildTotalCasesWidget(
                    context,
                    bgColor: AppColor.white,
                    title: "CP Onboard",
                    titleColor: AppColor.black.withValues(alpha: 0.5),
                    value: table0?.thisMonthAddedChannelPartner ?? 0,
                    valueColor: AppColor.black,
                    subText: "this month",
                    valuesubTextColor: AppColor.green,
                  ),
                  verticalSpacing(),
                  _buildTotalCasesWidget(
                    context,
                    bgColor: AppColor.priorityHighColor.withValues(alpha: 0.1),
                    title: "Missing Information",
                    titleColor: AppColor.black.withValues(alpha: 0.5),
                    value: table0?.missingInfoChannelPartner ?? 0,
                    valueColor: AppColor.priorityHighColor,
                    borderColor: AppColor.priorityHighColor,
                  ),
                  verticalSpacing(),
                  // CHANNEL PARTNER DISTRIBUTION WIDGET
                  _buildChannelPartnerDistributionWidget(context),
                  verticalSpacing(),
                  // RECENTLY ADDED CHANNEL PARTNER WIDGET
                  _buildRecentlyAddedChannelPartnerWidget(context),
                  verticalSpacing(),
                  // MISSING DETAILS WIDGET
                  _buildMissingDetailsWidget(context),
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
        final table1 = channelPartnerDashboardModel?.table1;
        final table3 = channelPartnerDashboardModel?.table3;
        final totalSum = table2?.fold<int>(
          0,
          (sum, item) => sum + item.totalCount,
        );

        final maxValue =
            (table3 == null || table3.isEmpty)
                ? 0
                : table3
                    .map((e) => e.totalChannelPartner)
                    .reduce((a, b) => a > b ? a : b);

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
                Column(
                  children:
                      table2.map((partnerTypeDistribution) {
                        return _buildParkingRow(
                          title: partnerTypeDistribution.type,
                          count: partnerTypeDistribution.totalCount,
                          totalSum: totalSum!,
                        );
                      }).toList(),
                ),
              ] else ...[
                Center(
                  child: Text(
                    "No Data Found",
                    style: AppTextStyle.ts12M(
                      color: AppColor.black.withValues(alpha: 0.50),
                    ),
                  ),
                ),
              ],
              Divider(
                thickness: 0.3,
                color: AppColor.black.withValues(alpha: 0.5),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      "Firm Type Distribution",
                      style: AppTextStyle.ts14SB(color: AppColor.black),
                    ),
                  ),
                ],
              ),
              verticalSpacing(),
              if (table1 != null && table1.isNotEmpty) ...[
                CommonRadialChart(items: _buildFirmTypeChart(table1)),
              ] else ...[
                Center(
                  child: Text(
                    "No Data Found",
                    style: AppTextStyle.ts12M(
                      color: AppColor.black.withValues(alpha: 0.50),
                    ),
                  ),
                ),
              ],

              Divider(
                thickness: 0.3,
                color: AppColor.black.withValues(alpha: 0.5),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      "Micromarket",
                      style: AppTextStyle.ts14SB(color: AppColor.black),
                    ),
                  ),
                ],
              ),
              verticalSpacing(),

              if (table3 != null) ...[
                ...table3.map((item) {
                  final widthFactor =
                      maxValue == 0 ? 0.0 : item.totalChannelPartner / maxValue;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 90,
                          child: Text(
                            item.name,
                            style: AppTextStyle.ts14M(
                              color: AppColor.black.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final barWidth =
                                  constraints.maxWidth *
                                  widthFactor.clamp(0.0, 1.0);

                              return Stack(
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 500),
                                    width: barWidth,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: AppColor.primary.withValues(
                                        alpha: 0.35,
                                      ),
                                    ),
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    child: Text(
                                      item.totalChannelPartner.toString(),
                                      style: AppTextStyle.ts16SB(
                                        color: AppColor.primary,
                                      ),
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
                }),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecentlyAddedChannelPartnerWidget(BuildContext context) {
    return BlocBuilder<ChannelPartnerCubit, ChannelPartnerState>(
      builder: (context, state) {
        if (state.isLoading!) {
          return Center(child: loader());
        }
        final channelPartnerDashboardModel = state.channelPartnerDashboardModel;
        final table4 = channelPartnerDashboardModel?.table4;
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          decoration: commonCardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Recently Added Channel Partner",
                          style: AppTextStyle.ts14M(
                            color: AppColor.black.withValues(alpha: 0.50),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "(Last 7 Days)",
                    style: AppTextStyle.ts12M(
                      color: AppColor.black.withValues(alpha: 0.50),
                    ),
                  ),
                ],
              ),
              verticalSpacing(),
              if (table4 != null && table4.isNotEmpty) ...[
                SizedBox(
                  height: 300.0,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: table4.length,
                    itemBuilder: (context, index) {
                      final addedChannelPartner = table4[index];
                      final bool isLast = index == table4.length - 1;
                      return Container(
                        margin:
                            isLast
                                ? EdgeInsets.zero
                                : EdgeInsets.only(bottom: 12),
                        padding: EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.0),
                          color: AppColor.lightGreyBackground,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _infoColumn(
                              "Channel Partner Name",
                              addedChannelPartner.name,
                              valueColor: AppColor.primary,
                            ),
                            verticalSpacing(height: 16),
                            _infoColumn(
                              "Channel Partner Code",
                              addedChannelPartner.systemGeneratedCode,
                              customValueWidge: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    addedChannelPartner.systemGeneratedCode,
                                    style: AppTextStyle.ts14M(),
                                  ),
                                  horizontalSpacing(width: 2),
                                  InkWell(
                                    onTap: () {
                                      copy(
                                        context: context,
                                        text:
                                            addedChannelPartner
                                                .systemGeneratedCode,
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(5),
                                      child: Icon(
                                        Icons.copy,
                                        size: 16,
                                        color: AppColor.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            verticalSpacing(height: 16),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _infoColumn(
                                  "Company",
                                  addedChannelPartner.companyName,
                                ),
                              ],
                            ),
                            verticalSpacing(height: 16.0),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _infoColumn(
                                    "Date",
                                    formatDateTimeAsDDMMMYYYY(
                                      addedChannelPartner.createdDate,
                                    ),
                                  ),
                                ),
                                horizontalSpacing(),
                                Expanded(
                                  child: _infoColumn(
                                    "Type",
                                    addedChannelPartner.type,
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
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildMissingDetailsWidget(BuildContext context) {
    return BlocBuilder<ChannelPartnerCubit, ChannelPartnerState>(
      builder: (context, state) {
        if (state.isLoading!) {
          return Center(child: loader());
        }
        final channelPartnerDashboardModel = state.channelPartnerDashboardModel;
        final table5 = channelPartnerDashboardModel?.table5;
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
                      "Missing Details",
                      style: AppTextStyle.ts14M(
                        color: AppColor.black.withValues(alpha: 0.50),
                      ),
                    ),
                  ),
                ],
              ),
              verticalSpacing(),
              if (table5 != null && table5.isNotEmpty) ...[
                SizedBox(
                  height: 200.0,
                  child: ListView.builder(
                    itemCount: table5.length,
                    shrinkWrap: true,
                    itemBuilder: (context, int index) {
                      final alerts = table5[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: 6.0),
                        padding: EdgeInsets.symmetric(
                          vertical: 12.0,
                          horizontal: 16.0,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6.0),
                          color: AppColor.red.withValues(alpha: 0.1),
                          border: Border(
                            left: BorderSide(width: 4, color: AppColor.red),
                          ),
                        ),
                        child: Column(
                          spacing: 5,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${alerts.systemGeneratedCode} - ${alerts.name}",
                              style: AppTextStyle.ts14M(),
                            ),
                            Text(
                              alerts.missingFields,
                              style: AppTextStyle.ts14R(),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ] else ...[
                Center(
                  child: Text(
                    "No Data Found",
                    style: AppTextStyle.ts12M(
                      color: AppColor.black.withValues(alpha: 0.50),
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

  Widget _infoColumn(
    String title,
    String value, {
    Color? valueColor,
    Widget? customValueWidge,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyle.ts12R(
            color: AppColor.black.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: 4),
        customValueWidge ??
            Text(
              value,
              style: AppTextStyle.ts14M(color: valueColor ?? AppColor.black),
            ),
      ],
    );
  }

  List<RadialChartItem> _buildFirmTypeChart(List<Table1> table1) {
    final colors = [
      AppColor.primary,
      AppColor.blueBgColor,
      AppColor.darkBackground.withValues(alpha: 0.4),
    ];

    return List.generate(table1.length, (index) {
      final item = table1[index];

      return RadialChartItem(
        title: _mapFirmType(item.firmsType),
        value: item.totalCount,
        color: colors[index % colors.length],
      );
    });
  }

  String _mapFirmType(String type) {
    switch (type.toUpperCase()) {
      case "PVT":
        return "Private Limited";
      case "LLP":
        return "LLP";
      case "PROP":
        return "Proprietorship";
      default:
        return type;
    }
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
