import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/legal/dashboard/presentation/cubit/litigation_dashboard_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/charts/custom_radial_chart.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class LitigationDashboardScreen extends StatefulWidget {
  const LitigationDashboardScreen({super.key});

  @override
  State<LitigationDashboardScreen> createState() =>
      _LitigationDashboardScreenState();
}

class _LitigationDashboardScreenState extends State<LitigationDashboardScreen> {
  // CUBIT
  late LitigationDashboardCubit _litigationDashboardCubit;
  // PROJECT MODEL
  late ProjectModel _selectedProject;

  @override
  void initState() {
    super.initState();
    _litigationDashboardCubit = context.read<LitigationDashboardCubit>();
    _selectedProject = getProject();
    _litigationDashboardCubit.getLitigationDashboardList(
      context,
      _selectedProject.projectId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LitigationDashboardCubit, LitigationDashboardState>(
      builder: (context, state) {
        if (state.isLoading!) {
          return Center(child: loader());
        }
        final litigationDashboardModel = state.litigationDashboardModel;
        final table0 = litigationDashboardModel?.table0.first;
        final table1 = litigationDashboardModel?.table1.first;
        return Scaffold(
          backgroundColor: AppColor.lightGreyBackground,
          appBar: CustomAppBarWithBackButton(
            screenTitle: "Litigation Dashbaord",
            isMenuButton: true,
            showNotification: true,
            authorization: AuthorizationModel(),
            onProjectChangeCallback: (value) {
              _selectedProject = value;
              _litigationDashboardCubit.getLitigationDashboardList(
                context,
                _selectedProject.projectId,
              );
            },
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
                    title: "Total Cases",
                    titleColor: AppColor.white,
                    value: table0?.totalCases ?? 0,
                    valueColor: AppColor.white,
                  ),
                  verticalSpacing(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: _buildTotalCasesWidget(
                          context,
                          bgColor: AppColor.white,
                          title: "Open Cases",
                          titleColor: AppColor.black.withValues(alpha: 0.5),
                          value: table0?.openCases ?? 0,
                          valueColor: AppColor.black,
                        ),
                      ),
                      horizontalSpacing(),
                      Expanded(
                        child: _buildTotalCasesWidget(
                          context,
                          bgColor: AppColor.white,
                          title: "Closed Cases",
                          titleColor: AppColor.black.withValues(alpha: 0.5),
                          value: table0?.closedCases ?? 0,
                          valueColor: AppColor.black,
                        ),
                      ),
                    ],
                  ),
                  verticalSpacing(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: _buildTotalCasesWidget(
                          context,
                          bgColor: AppColor.white,
                          title: "Reopened Cases",
                          titleColor: AppColor.black.withValues(alpha: 0.5),
                          value: table0?.reOpenCases ?? 0,
                          valueColor: AppColor.black,
                        ),
                      ),
                      horizontalSpacing(),
                      Expanded(
                        child: _buildTotalCasesWidget(
                          context,
                          bgColor: AppColor.white,
                          title: "Total Hearings",
                          titleColor: AppColor.black.withValues(alpha: 0.5),
                          value: table1?.totalHearings ?? 0,
                          valueColor: AppColor.black,
                        ),
                      ),
                    ],
                  ),
                  verticalSpacing(),
                  // CASE TYPE DISTRIBUTION WIDGET
                  _buildCaseTypeDistributionWidget(context),
                  verticalSpacing(),
                  // COURT DISTRIBUTION WIDGET
                  _buildCourtDistributionWidget(context),
                  verticalSpacing(),
                  // ACTIVE CASES WIDGET
                  _buildActiveCasesWidget(context),
                  verticalSpacing(),
                  // HEARING WIDGET
                  _buildHearingsWidget(context),
                  verticalSpacing(),
                  _buildRecentlyUploadedDocumentsWidget(context),
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
    Color? bgColor,
    String? title,
    Color? titleColor,
    int? value,
    Color? valueColor,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: bgColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title!, style: AppTextStyle.ts14M(color: titleColor)),
          verticalSpacing(height: 6.0),
          Text(value!.toString(), style: AppTextStyle.ts14M(color: valueColor)),
        ],
      ),
    );
  }

  Widget _buildCaseTypeDistributionWidget(BuildContext context) {
    return BlocBuilder<LitigationDashboardCubit, LitigationDashboardState>(
      builder: (context, state) {
        if (state.isLoading!) {
          return Center(child: loader());
        }
        final litigationDashboardModel = state.litigationDashboardModel;
        final table2List =
            (litigationDashboardModel?.table2.isNotEmpty ?? false)
                ? litigationDashboardModel!.table2
                : null;
        final civil =
            table2List
                ?.firstWhere((e) => e.caseType.toLowerCase() == "civil")
                .totalCases;

        final criminal =
            table2List
                ?.firstWhere((e) => e.caseType.toLowerCase() == "criminal")
                .totalCases;
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
                      "Case Type Distribution",
                      style: AppTextStyle.ts14M(
                        color: AppColor.black.withValues(alpha: 0.50),
                      ),
                    ),
                  ),
                ],
              ),
              verticalSpacing(),
              if (table2List != null) ...[
                CommonRadialChart(
                  items: [
                    RadialChartItem(
                      title: "Civil",
                      value: civil!,
                      color: AppColor.primary,
                    ),
                    RadialChartItem(
                      title: "Criminal",
                      value: criminal!,
                      color: AppColor.error,
                    ),
                  ],
                ),
              ] else ...[
                Center(
                  child: Text(
                    "No Case Type Distribution Available",
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

  Widget _buildCourtDistributionWidget(BuildContext context) {
    return BlocBuilder<LitigationDashboardCubit, LitigationDashboardState>(
      builder: (context, state) {
        if (state.isLoading!) {
          return Center(child: loader());
        }
        final litigationDashboardModel = state.litigationDashboardModel;
        final table3 = litigationDashboardModel?.table3;
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
                      "Court Distribution",
                      style: AppTextStyle.ts14M(
                        color: AppColor.black.withValues(alpha: 0.50),
                      ),
                    ),
                  ),
                ],
              ),
              verticalSpacing(),
              if (table3 != null && table3.isNotEmpty) ...[
                Column(
                  children:
                      table3.map((court) {
                        return _courtDistributionItem(
                          court.caseType,
                          court.totalCases,
                          court.openCases,
                        );
                      }).toList(),
                ),
              ] else ...[
                Center(
                  child: Text(
                    "No Court Distribution Available",
                    style: AppTextStyle.ts12M(
                      color: AppColor.black.withValues(alpha: .5),
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

  Widget _courtDistributionItem(String title, int total, int open) {
    final double totalPercent = total == 0 ? 0 : 1;
    final double openPercent = total == 0 ? 0 : open / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyle.ts14SB(
            color: AppColor.black.withValues(alpha: 0.5),
          ),
        ),

        verticalSpacing(),
        // TOTAL CASE BAR (BLUE COLOR INDICATION)
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  borderRadius: BorderRadius.circular(4.0),
                  value: totalPercent,
                  minHeight: 12,
                  backgroundColor: const Color(0xffAFC1DD),
                  valueColor: const AlwaysStoppedAnimation(AppColor.primary),
                ),
              ),
            ),
            horizontalSpacing(width: 10),
            Text(total.toString(), style: AppTextStyle.ts14M()),
          ],
        ),

        verticalSpacing(height: 8),

        /// OPEN CASE BAR (RED COLOR INDICATION)
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  borderRadius: BorderRadius.circular(4.0),
                  value: openPercent,
                  minHeight: 12,
                  backgroundColor: const Color(0xffAFC1DD),
                  valueColor: const AlwaysStoppedAnimation(AppColor.error),
                ),
              ),
            ),
            horizontalSpacing(width: 10),
            Text(open.toString(), style: AppTextStyle.ts14M()),
          ],
        ),
        verticalSpacing(),
      ],
    );
  }

  Widget _buildActiveCasesWidget(BuildContext context) {
    return BlocBuilder<LitigationDashboardCubit, LitigationDashboardState>(
      builder: (context, state) {
        if (state.isLoading!) {
          return Center(child: loader());
        }
        final litigationDashboardModel = state.litigationDashboardModel;
        final table4 = litigationDashboardModel?.table4;
        Color statusColor;

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
                      "Active Cases",
                      style: AppTextStyle.ts14M(
                        color: AppColor.black.withValues(alpha: 0.50),
                      ),
                    ),
                  ),
                ],
              ),
              verticalSpacing(),
              if (table4 != null && table4.isNotEmpty) ...[
                SizedBox(
                  height: 200.0,
                  child: ListView.builder(
                    itemCount: table4.length,
                    shrinkWrap: true,
                    physics: AlwaysScrollableScrollPhysics(),
                    itemBuilder: (context, int index) {
                      var item = table4[index];
                      switch (item.status.toLowerCase()) {
                        case "reopen":
                          statusColor = AppColor.warning;
                          break;

                        case "closed":
                          statusColor = AppColor.error;
                          break;

                        default:
                          statusColor = AppColor.green;
                      }
                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 13,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: AppColor.lightGreyBackground,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: _caseField("Case Title", item.title),
                                ),
                                horizontalSpacing(width: 20.0),
                                Expanded(
                                  child: _caseField(
                                    "Status",
                                    item.status,
                                    valueColor: statusColor,
                                  ),
                                ),
                              ],
                            ),
                            verticalSpacing(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: _caseField(
                                    "Case Number",
                                    item.caseNumber,
                                  ),
                                ),
                                horizontalSpacing(width: 20),
                                Expanded(
                                  child: _caseField("Case Type", item.caseType),
                                ),
                              ],
                            ),
                            verticalSpacing(),
                            _caseField(
                              "Hearing Date",
                              formatDate(item.hearingDate),
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
                    "No Active Cases Available",
                    style: AppTextStyle.ts12M(
                      color: AppColor.black.withValues(alpha: .5),
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

  Widget _caseField(String title, String value, {Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyle.ts12R(
            color: AppColor.black.withValues(alpha: .5),
          ),
        ),
        verticalSpacing(height: 4),
        Text(
          value,
          style: AppTextStyle.ts14M(color: valueColor ?? AppColor.black),
        ),
      ],
    );
  }

  Widget _buildHearingsWidget(BuildContext context) {
    return BlocBuilder<LitigationDashboardCubit, LitigationDashboardState>(
      builder: (context, state) {
        if (state.isLoading!) {
          return Center(child: loader());
        }
        final litigationDashboardModel = state.litigationDashboardModel;
        final table5 = litigationDashboardModel?.table5;
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
                      "Upcoming Hearings",
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
                    physics: AlwaysScrollableScrollPhysics(),
                    itemBuilder: (context, int index) {
                      final item = table5[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColor.purple, width: .8),
                          color: AppColor.lightPurple,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Case No: ${item.caseNumber}",
                                    style: AppTextStyle.ts14M(),
                                  ),
                                  verticalSpacing(height: 6.0),
                                  Text(
                                    item.caseType,
                                    style: AppTextStyle.ts12R(
                                      color: AppColor.black.withValues(
                                        alpha: 0.5,
                                      ),
                                    ),
                                  ),
                                  verticalSpacing(height: 6),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "At ${item.courtType}",
                                          style: AppTextStyle.ts12R(
                                            color: AppColor.black.withValues(
                                              alpha: 0.5,
                                            ),
                                          ),
                                        ),
                                      ),
                                      horizontalSpacing(),
                                      Align(
                                        alignment: Alignment.bottomRight,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                            color: AppColor.purple,
                                          ),
                                          child: Text(
                                            "in ${item.daysRemaining} Days",
                                            style: AppTextStyle.ts14M(
                                              color: AppColor.white,
                                            ),
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
                  child: Text(
                    "No Upcoming Hearings Available",
                    style: AppTextStyle.ts12M(
                      color: AppColor.black.withValues(alpha: .5),
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

  Widget _buildRecentlyUploadedDocumentsWidget(BuildContext context) {
    return BlocBuilder<LitigationDashboardCubit, LitigationDashboardState>(
      builder: (context, state) {
        if (state.isLoading!) {
          return Center(child: loader());
        }
        final litigationDashboardModel = state.litigationDashboardModel;
        final table6 = litigationDashboardModel?.table6;

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
                      "Recently Uploaded Documents",
                      style: AppTextStyle.ts14M(
                        color: AppColor.black.withValues(alpha: 0.50),
                      ),
                    ),
                  ),
                ],
              ),
              verticalSpacing(),
              if (table6 != null && table6.isNotEmpty) ...[
                SizedBox(
                  height: 200.0,
                  child: ListView.builder(
                    itemCount: table6.length,
                    shrinkWrap: true,
                    physics: AlwaysScrollableScrollPhysics(),
                    itemBuilder: (context, int index) {
                      var item = table6[index];
                      final bool isLast = index == table6.length - 1;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          verticalSpacing(height: 9.0),
                          Text(
                            "Structural Document",
                            style: AppTextStyle.ts16SB(color: AppColor.primary),
                          ),
                          verticalSpacing(height: 9.0),
                          Text(
                            "Case No: ",
                            style: AppTextStyle.ts14M(
                              color: AppColor.black.withValues(alpha: 0.5),
                            ),
                          ),
                          verticalSpacing(height: 9.0),
                          Text(
                            item.documentName,
                            style: AppTextStyle.ts14M(
                              color: AppColor.black.withValues(alpha: 0.5),
                            ),
                          ),
                          verticalSpacing(height: 9.0),
                          !isLast
                              ? Divider(
                                color: AppColor.black.withValues(alpha: 0.5),
                              )
                              : SizedBox.shrink(),
                        ],
                      );
                    },
                  ),
                ),
              ] else ...[
                Center(
                  child: Text(
                    "No Upcoming Hearings Available",
                    style: AppTextStyle.ts12M(
                      color: AppColor.black.withValues(alpha: .5),
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
