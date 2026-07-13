// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/crm/dashboard/data/model/crm_dashboard.model.dart';
import 'package:k3h_erp_app/features/crm/dashboard/presentation/cubit/crm_dashboard_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/functions/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/charts/custom_radial_chart.dart';
import 'package:k3h_erp_app/widgets/chip_style_tab_bar.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class CrmDashboardScreen extends StatefulWidget {
  const CrmDashboardScreen({super.key});

  @override
  State<CrmDashboardScreen> createState() => _CrmDashboardScreenState();
}

class _CrmDashboardScreenState extends State<CrmDashboardScreen>
    with TickerProviderStateMixin {
  late CrmDashboardCubit _crmDashboardCubit;
  // TAB CONTROLLERS
  late TabController _tabController;

  late ProjectModel _selectedProject;

  DateTime? fromDate;
  DateTime? toDate;

  final ValueNotifier<DateTime?> fromDateNotifier = ValueNotifier(null);
  final ValueNotifier<DateTime?> toDateNotifier = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    _selectedProject = getProject();
    _crmDashboardCubit = context.read<CrmDashboardCubit>();
    _crmDashboardCubit.getCrmDashboardList(
      context,
      filterType: "TODAY",
      projectId: _selectedProject.projectId,
    );
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  // HANDLE TAB CHANGE
  void _handleTabChange() {
    if (_tabController.indexIsChanging) return;

    String filterType = "TODAY";

    switch (_tabController.index) {
      case 0:
        filterType = "TODAY";
        break;

      case 1:
        filterType = "WEEKLY";
        break;

      case 2:
        filterType = "MONTHLY";
        break;

      case 3:
        filterType = "DATEWISE";
        break;

      case 4:
        filterType = "OVERALL";
        break;
    }
    if (filterType == "DATEWISE") {
      _crmDashboardCubit.emit(
        _crmDashboardCubit.state.copyWith(selectedFilterType: "DATEWISE"),
      );
      return;
    }

    _crmDashboardCubit.getCrmDashboardList(
      context,
      filterType: filterType,
      projectId: _selectedProject.projectId,
    );
  }

  String selectedSummaryType = "Agreement";
  @override
  void dispose() {
    fromDateNotifier.dispose();
    toDateNotifier.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CrmDashboardCubit, CrmDashboardState>(
      builder: (context, state) {
        if ((state.isLoading ?? false) && state.crmDashboardList.isEmpty) {
          return Center(child: loader());
        }

        final userData = state.crmDashboardModel;
        final table0 =
            (userData != null && userData.table0.isNotEmpty)
                ? userData.table0.first
                : null;
        return Scaffold(
          appBar: CustomAppBarWithBackButton(
            screenTitle: "Crm Dashbaord",
            authorization: AuthorizationModel(),
            isMenuButton: true,
            onProjectChangeCallback: (value) {
              _selectedProject = value;
              _crmDashboardCubit.getCrmDashboardList(
                context,
                filterType: state.selectedFilterType,
                projectId: _selectedProject.projectId,
              );
            },
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ChipStyleTabBar(
                style: ChipTabBarStyle.underline,
                controller: _tabController,
                tabs: ["Today", "Weekly", "Monthly", "Datewise", "Overall"],
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (state.selectedFilterType == "DATEWISE") ...[
                        verticalSpacing(),
                        ValueListenableBuilder<DateTime?>(
                          valueListenable: fromDateNotifier,
                          builder: (context, fromDate, _) {
                            return ValueListenableBuilder<DateTime?>(
                              valueListenable: toDateNotifier,
                              builder: (context, toDate, _) {
                                return Row(
                                  children: [
                                    Expanded(
                                      child: CustomDatePicker(
                                        hint: "Select From Date",
                                        title: "From Date",
                                        initialDate: fromDate,
                                        setValue: (value) {
                                          fromDateNotifier.value = value;
                                          toDateNotifier.value = null;
                                        },
                                      ),
                                    ),
                                    horizontalSpacing(),
                                    Expanded(
                                      child: CustomDatePicker(
                                        hint: "Select To Date",
                                        title: "To Date",
                                        initialDate: toDate,
                                        startDate: fromDate,
                                        endDate:
                                            fromDate != null
                                                ? DateTime(
                                                  fromDate.year,
                                                  fromDate.month + 1,
                                                  fromDate.day,
                                                )
                                                : DateTime.now(),

                                        setValue: (value) async {
                                          toDateNotifier.value = value;

                                          if (fromDateNotifier.value != null &&
                                              toDateNotifier.value != null) {
                                            await _crmDashboardCubit
                                                .getCrmDashboardList(
                                                  context,
                                                  filterType: "DATEWISE",
                                                  projectId:
                                                      _selectedProject
                                                          .projectId,

                                                  fromDate:
                                                      formatDateTimeForApi(
                                                        fromDateNotifier.value!,
                                                      ),
                                                  toDate: formatDateTimeForApi(
                                                    toDateNotifier.value!,
                                                  ),
                                                );
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                      if (table0 != null) ...{
                        _projectWiseCollectionWidget(context, state),
                        verticalSpacing(height: 16.0),
                        Row(
                          children: [
                            Expanded(
                              child: _totalValue(
                                context,
                                state,
                                "Total Agreement\nValue",
                                formattedAmount(table0.totalAgreementAmount),
                              ),
                            ),
                            horizontalSpacing(),
                            Expanded(
                              child: _totalValue(
                                context,
                                state,
                                "Total Received\nAmount",
                                formattedAmount(
                                  table0.totalReceivedAgreementAmount,
                                ),
                              ),
                            ),
                          ],
                        ),
                        verticalSpacing(height: 16.0),
                        Row(
                          children: [
                            Expanded(
                              child: _totalValue(
                                context,
                                state,
                                "Total\nOutstanding",
                                formattedAmount(
                                  table0.totalOutstandingAgreementValue,
                                ),
                              ),
                            ),
                            horizontalSpacing(),
                            Expanded(
                              child: _totalValue(
                                context,
                                state,
                                "Total Booking",
                                formattedAmount(table0.totalBooking),
                              ),
                            ),
                          ],
                        ),
                      } else ...{
                        Center(
                          child: Text(
                            "No Data Found",
                            style: AppTextStyle.ts12M(
                              color: AppColor.greyTitleAndValueColor.withValues(
                                alpha: 0.50,
                              ),
                            ),
                          ),
                        ),
                      },
                      verticalSpacing(height: 16.0),
                      _collectionSummaryWidget(context, state),
                      _bookingSummaryWidget(context, state),
                      _recentBookingSummaryWidget(context, state),
                      _brokerageSummaryWidget(context, state),
                      _accountSummaryWidget(context, state),
                      _modifiedRequestsWidget(context, state),
                      _recentTransactionWidget(context, state),
                      _alertsWidget(context, state),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _projectWiseCollectionWidget(
    BuildContext context,
    CrmDashboardState state,
  ) {
    if (state.crmDashboardList.isEmpty ||
        state.crmDashboardList.first.table0.isEmpty) {
      return const SizedBox.shrink();
    }

    final list = state.crmDashboardList.first.table0;
    final table0 = list.first;

    final totalCollectionPercentage =
        table0.collectionAgreementReceived +
        table0.collectionGst +
        table0.collectionTds;
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: commonCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Collection %",
                    style: AppTextStyle.ts14M(
                      color: AppColor.greyTitleAndValueColor.withValues(
                        alpha: 0.5,
                      ),
                    ),
                  ),
                  verticalSpacing(height: 6),
                  Text(
                    formattedAmount(
                      totalCollectionPercentage,
                      showRupeeSymbol: false,
                    ),
                    style: AppTextStyle.ts20SB(),
                  ),
                ],
              ),
              horizontalSpacing(),
              Container(
                padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
                decoration: BoxDecoration(
                  color: AppColor.lightBlue,
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Text(
                  "Last 3 days",
                  style: AppTextStyle.ts12R(color: AppColor.primary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _totalValue(
    BuildContext context,
    CrmDashboardState state,
    String title,
    String value,
  ) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(16.0),
      decoration: commonCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyle.ts14M(
              color: AppColor.greyTitleAndValueColor.withValues(alpha: 0.5),
            ),
          ),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyle.ts20SB(color: AppColor.black),
          ),
        ],
      ),
    );
  }

  Widget _collectionSummaryWidget(
    BuildContext context,
    CrmDashboardState state,
  ) {
    if (state.crmDashboardList.isEmpty ||
        state.crmDashboardList.first.table0.isEmpty) {
      return Center(
        child: Text(
          "No Data Found",
          style: AppTextStyle.ts12M(
            color: AppColor.greyTitleAndValueColor.withValues(alpha: 0.50),
          ),
        ),
      );
    }

    final list = state.crmDashboardList.first.table0;
    final table0 = list.first;
    final totalCollectionPercentage =
        table0.collectionAgreementReceived +
        table0.collectionGst +
        table0.collectionTds;
    return Container(
      margin: EdgeInsets.only(bottom: 16.0),
      padding: EdgeInsets.all(16.0),
      decoration: commonCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Collection Summary",
            style: AppTextStyle.ts14M(
              color: AppColor.greyTitleAndValueColor.withValues(alpha: 0.5),
            ),
          ),
          verticalSpacing(height: 16.0),
          Container(
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: AppColor.darkBlue10,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  blurRadius: 10,
                  offset: Offset(2, 0),
                  color: AppColor.black.withValues(alpha: 0.05),
                ),
                BoxShadow(
                  blurRadius: 0,
                  offset: Offset(0, 0),
                  color: AppColor.black.withValues(alpha: 0),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        "Total Collection",
                        style: AppTextStyle.ts14M(color: AppColor.white),
                      ),
                    ),
                    horizontalSpacing(),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          totalCollectionPercentage.toIndianCurrency(),
                          style: AppTextStyle.ts16SB(color: AppColor.white),
                        ),
                      ),
                    ),
                  ],
                ),
                verticalSpacing(height: 16.0),
                Divider(thickness: 0.5, color: AppColor.white),
                verticalSpacing(height: 12.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        "Agreement",
                        style: AppTextStyle.ts14M(color: AppColor.white),
                      ),
                    ),
                    horizontalSpacing(),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          formattedAmount(table0.collectionAgreementReceived),
                          style: AppTextStyle.ts16SB(color: AppColor.white),
                        ),
                      ),
                    ),
                  ],
                ),
                verticalSpacing(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        "GST",
                        style: AppTextStyle.ts14M(color: AppColor.white),
                      ),
                    ),
                    horizontalSpacing(),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          formattedAmount(table0.collectionGst),
                          style: AppTextStyle.ts16SB(color: AppColor.white),
                        ),
                      ),
                    ),
                  ],
                ),
                verticalSpacing(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        "TDS",
                        style: AppTextStyle.ts14M(color: AppColor.white),
                      ),
                    ),
                    horizontalSpacing(),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          formattedAmount(table0.collectionTds),
                          style: AppTextStyle.ts16SB(color: AppColor.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: 180,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: WeeklyCollectionChart(
                data: state.crmDashboardList.first.table4,
                selectedType: selectedSummaryType,
                filterType: state.selectedFilterType,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bookingSummaryWidget(BuildContext context, CrmDashboardState state) {
    final list = state.crmDashboardList.first.table0;
    final table0 = list.first;

    return Container(
      margin: EdgeInsets.only(bottom: 16.0),
      padding: EdgeInsets.all(16.0),
      decoration: commonCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Booking Summary",
            style: AppTextStyle.ts14M(
              color: AppColor.greyTitleAndValueColor.withValues(alpha: 0.5),
            ),
          ),
          verticalSpacing(height: 10.0),
          CommonRadialChart(
            total: table0.totalBooking,
            items: [
              RadialChartItem(
                title: "Registered Bookings",
                value: table0.registeredBooking,
                color: AppColor.green,
              ),
              RadialChartItem(
                title: "Non-Registered Bookings",
                value: table0.nonRegisteredBooking,
                color: AppColor.yellow,
              ),
              RadialChartItem(
                title: "Upcoming Registrations",
                value: table0.upcomingRegistration,
                color: AppColor.primary,
              ),
            ],
          ),
          verticalSpacing(),
          Divider(thickness: 0.8, color: AppColor.black.withValues(alpha: 0.1)),
          verticalSpacing(),
          buildRowTitleValue(
            title: "Total Registration",
            value: table0.totalBooking.toString(),
          ),
        ],
      ),
    );
  }

  Widget _recentBookingSummaryWidget(
    BuildContext context,
    CrmDashboardState state,
  ) {
    final list = state.crmDashboardList.first.table2;

    return Container(
      margin: EdgeInsets.only(bottom: 16.0),
      padding: EdgeInsets.all(16.0),
      decoration: commonCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Recent Booking",
            style: AppTextStyle.ts14M(
              color: AppColor.greyTitleAndValueColor.withValues(alpha: 0.5),
            ),
          ),
          verticalSpacing(),
          if (list.isNotEmpty) ...[
            ListView.builder(
              itemCount: list.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final value = list[index];
                final bool isLast = index == list.length - 1;
                return Container(
                  margin:
                      isLast ? EdgeInsets.zero : EdgeInsets.only(bottom: 16.0),
                  padding: EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6.0),
                    border: Border.all(width: 0.8, color: Color(0xffE5E7EB)),
                    color: AppColor.lightGreyBackground,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: buildColumnTitleValueNormal(
                              title: "Unit No.",
                              value: value.flat,
                            ),
                          ),
                          horizontalSpacing(),
                          Expanded(
                            child: buildColumnTitleValueNormal(
                              title: "Applicant Name",
                              value: value.applicantName,
                            ),
                          ),
                        ],
                      ),
                      verticalSpacing(),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: buildColumnTitleValueNormal(
                              title: "Amount",
                              value: value.agreementValue.toIndianCurrency(),
                            ),
                          ),
                          horizontalSpacing(),
                          Expanded(
                            child: buildColumnTitleValueNormal(
                              title: "Date",
                              value: formatDateTimeReadable(value.createdDate),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ] else ...[
            Center(
              child: Text(
                "No Data Found",
                style: AppTextStyle.ts12M(
                  color: AppColor.greyTitleAndValueColor.withValues(
                    alpha: 0.50,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _brokerageSummaryWidget(
    BuildContext context,
    CrmDashboardState state,
  ) {
    final list = state.crmDashboardList.first.table0;
    final table0 = list.first;

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: commonCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Brokerage Summary",
            style: AppTextStyle.ts14M(
              color: AppColor.greyTitleAndValueColor.withValues(alpha: 0.5),
            ),
          ),
          verticalSpacing(),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 18.0,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: AppColor.lightGreyBackground,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total Channel Partner",
                  style: AppTextStyle.ts14M(
                    color: AppColor.black.withValues(alpha: 0.5),
                  ),
                ),
                Text(
                  table0.totalChannelPartner.toString(),
                  style: AppTextStyle.ts12M(color: AppColor.black),
                ),
              ],
            ),
          ),
          verticalSpacing(),
          _brokerRow(
            title: "Total Brokerage Amount",
            value: formattedAmount(table0.totalBrokerageAmount),
            titleColor: AppColor.black,
            valueColor: AppColor.black,
          ),
          Divider(
            height: 28,
            thickness: 0.5,
            color: AppColor.black.withValues(alpha: 0.12),
          ),
          _brokerRow(
            title: "Paid Amount",
            value: formattedAmount(table0.paidBrokerageAmount),
            titleColor: Colors.green,
            valueColor: Colors.green,
          ),
          Divider(
            height: 28,
            thickness: 0.5,
            color: AppColor.black.withValues(alpha: 0.12),
          ),
          _brokerRow(
            title: "Outstanding Amount",
            value: formattedAmount(table0.outstandingBrokerageAmount),
            titleColor: Colors.red,
            valueColor: Colors.red,
          ),
          verticalSpacing(),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 18.0,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: AppColor.lightGreyBackground,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "Top Brokers",
                      style: AppTextStyle.ts14M(
                        color: AppColor.black.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
                verticalSpacing(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        "Rajesh Kumar & Assoc.",
                        style: AppTextStyle.ts14M(color: AppColor.black),
                      ),
                    ),
                    horizontalSpacing(),
                    Text(
                      formattedAmount(2400005760),
                      style: AppTextStyle.ts14M(color: AppColor.black),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _brokerRow({
    required String title,
    required String value,
    required Color titleColor,
    required Color valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(title, style: AppTextStyle.ts14M(color: titleColor)),
        ),
        horizontalSpacing(),
        Text(value, style: AppTextStyle.ts14M(color: valueColor)),
      ],
    );
  }

  Widget _accountSummaryWidget(BuildContext context, CrmDashboardState state) {
    final list = state.crmDashboardList.first.table0;
    final table0 = list.first;

    double totalAmount = 0;
    double totalReceived = 0;

    switch (selectedSummaryType) {
      case "GST":
        totalAmount = table0.totalAgreementGstAmount;
        totalReceived = table0.collectionGst;
        break;

      case "TDS":
        totalAmount = table0.totalAgreementTdsAmount;
        totalReceived = table0.collectionTds;
        break;

      case "Agreement":
      default:
        totalAmount = table0.totalAgreementAmount;
        totalReceived = table0.collectionAgreementReceived;
        break;
    }

    final totalPending = (totalAmount - totalReceived).clamp(
      0.0,
      double.infinity,
    );

    final progress =
        totalAmount <= 0 ? 0.0 : (totalReceived / totalAmount).clamp(0.0, 1.0);

    return Container(
      margin: EdgeInsets.only(bottom: 16.0),
      padding: EdgeInsets.all(16.0),
      decoration: commonCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Account Summary",
            style: AppTextStyle.ts14M(
              color: AppColor.black.withValues(alpha: 0.5),
            ),
          ),
          verticalSpacing(),
          Container(
            padding: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              color: AppColor.lightBlue,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _summaryTypeChip(title: "Agreement"),
                _summaryTypeChip(title: "GST"),
                _summaryTypeChip(title: "TDS"),
              ],
            ),
          ),
          verticalSpacing(),
          buildRowTitleValue(
            title: "Total Amount",
            value: formattedAmount(totalAmount),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(30.0),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 16.0,
              backgroundColor: AppColor.lightBlue,
              valueColor: AlwaysStoppedAnimation(
                selectedSummaryType == "Agreement"
                    ? AppColor.primary
                    : selectedSummaryType == "GST"
                    ? AppColor.green
                    : AppColor.orange,
              ),
            ),
          ),
          verticalSpacing(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Total Received",
                      style: AppTextStyle.ts14R(
                        color: AppColor.black.withValues(alpha: 0.5),
                      ),
                    ),
                    verticalSpacing(height: 4),
                    Text(
                      formattedAmount(totalReceived),
                      style: AppTextStyle.ts14SB(color: AppColor.green),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              horizontalSpacing(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "Total Pending",
                      style: AppTextStyle.ts14R(
                        color: AppColor.black.withValues(alpha: 0.5),
                      ),
                    ),
                    verticalSpacing(height: 4),
                    Text(
                      formattedAmount(totalPending),
                      style: AppTextStyle.ts14SB(color: AppColor.red),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryTypeChip({required String title}) {
    final isSelected = selectedSummaryType == title;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedSummaryType = title;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 6.0),
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: isSelected ? AppColor.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(
          title,
          style: AppTextStyle.ts14M(
            color:
                isSelected
                    ? AppColor.white
                    : AppColor.black.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }

  Widget _modifiedRequestsWidget(
    BuildContext context,
    CrmDashboardState state,
  ) {
    final list = state.crmDashboardList.first.table6;
    return Container(
      margin: EdgeInsets.only(bottom: 16.0),
      padding: EdgeInsets.all(16.0),
      decoration: commonCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Modified Requests",
            style: AppTextStyle.ts14M(
              color: AppColor.black.withValues(alpha: 0.5),
            ),
          ),
          verticalSpacing(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6.0),
              color: AppColor.lightGreyBackground,
            ),
            child: Text(
              "${list.first.totalCount} Total",
              style: AppTextStyle.ts14M(),
            ),
          ),
          verticalSpacing(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6.0),
                    color: AppColor.green.withValues(alpha: 0.25),
                  ),
                  child: Text(
                    "${list.first.approvedCount} Approved",
                    style: AppTextStyle.ts14M(color: AppColor.green),
                  ),
                ),
              ),
              horizontalSpacing(),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6.0),
                    color: AppColor.lightYellow,
                  ),
                  child: Text(
                    "${list.first.pendingCount} Pending",
                    style: AppTextStyle.ts14M(color: AppColor.brown),
                  ),
                ),
              ),
            ],
          ),
          verticalSpacing(height: 20.0),
          ListView.builder(
            itemCount: list.length,
            shrinkWrap: true,
            physics: AlwaysScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final requests = list[index];
              final bool isLast = index == list.length - 1;
              return Padding(
                padding: EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
                child: Column(
                  spacing: isLast ? 0.0 : 10.0,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          requests.name,
                          style: AppTextStyle.ts14M(
                            color: AppColor.black.withValues(alpha: 0.5),
                          ),
                        ),
                        horizontalSpacing(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              list[index].approvedCount.toString(),
                              style: AppTextStyle.ts14M(),
                            ),
                          ],
                        ),
                      ],
                    ),
                    !isLast
                        ? Divider(
                          thickness: 0.5,
                          color: AppColor.black.withValues(alpha: 0.5),
                        )
                        : SizedBox.shrink(),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _recentTransactionWidget(
    BuildContext context,
    CrmDashboardState state,
  ) {
    final list = state.crmDashboardList.first.table3;
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: commonCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Recent Transaction",
            style: AppTextStyle.ts14M(
              color: AppColor.black.withValues(alpha: 0.5),
            ),
          ),

          verticalSpacing(height: 16),
          if (list.isNotEmpty && list != []) ...[
            SizedBox(
              height: 200.0,
              child: ListView.builder(
                itemCount: list.length,
                shrinkWrap: true,
                physics: const AlwaysScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final item = list[index];
                  final isLast = index == list.length - 1;
                  Color statusBgColor;
                  Color statusTextColor;
                  switch (item.approvalStatus) {
                    case "Approved":
                      statusBgColor = AppColor.green20.withValues(alpha: 0.1);
                      statusTextColor = AppColor.green20;
                      break;

                    case "Pending":
                      statusBgColor = AppColor.lightYellow.withValues(
                        alpha: 0.12,
                      );
                      statusTextColor = AppColor.yellow;
                      break;

                    case "Rejected":
                      statusBgColor = AppColor.lightRed;
                      statusTextColor = AppColor.missingInformationRed;
                      break;

                    default:
                      statusBgColor = AppColor.grey.withValues(alpha: 0.12);
                      statusTextColor = AppColor.grey;
                  }
                  return IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: AppColor.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            if (!isLast)
                              Expanded(
                                child: Container(
                                  width: 2,
                                  color: AppColor.primary,
                                ),
                              ),
                          ],
                        ),
                        horizontalSpacing(),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 24.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text:
                                                  "${formattedAmount(item.receivedAmount)} : ",
                                              style: AppTextStyle.ts16M(
                                                color: AppColor.black,
                                              ),
                                            ),
                                            TextSpan(
                                              text: item.flat,
                                              style: AppTextStyle.ts18M(
                                                color: AppColor.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        item.applicantName.isEmpty
                                            ? '-'
                                            : item.applicantName,
                                        style: AppTextStyle.ts14R(
                                          color: AppColor.black.withValues(
                                            alpha: 0.5,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        item.paymentMode,
                                        style: AppTextStyle.ts14R(
                                          color: AppColor.black.withValues(
                                            alpha: 0.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                horizontalSpacing(),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: statusBgColor,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        item.approvalStatus,
                                        style: AppTextStyle.ts12SB(
                                          color: statusTextColor,
                                        ),
                                      ),
                                    ),
                                    verticalSpacing(height: 10),
                                    Text(
                                      formatDateTimeAsDDMMMYYYY(
                                        item.createdDate,
                                      ),
                                      style: AppTextStyle.ts14R(),
                                    ),
                                  ],
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
  }

  Widget _alertsWidget(BuildContext context, CrmDashboardState state) {
    final list = state.crmDashboardList.first.table7;
    return Container(
      margin: EdgeInsets.only(bottom: 16.0),
      padding: EdgeInsets.all(16.0),
      decoration: commonCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Alerts",
            style: AppTextStyle.ts14M(
              color: AppColor.black.withValues(alpha: 0.5),
            ),
          ),
          verticalSpacing(),
          if (list.isNotEmpty) ...[
            SizedBox(
              height: 200.0,
              child: ListView.builder(
                itemCount: list.length,
                shrinkWrap: true,
                itemBuilder: (context, int index) {
                  final isLast = index == list.length - 1;
                  final alerts = list[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: isLast ? 0.0 : 10.0),
                    padding: EdgeInsets.symmetric(
                      vertical: 12.0,
                      horizontal: 16.0,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6.0),
                      color: Color(0xffFFF7F7),
                      border: Border(
                        left: BorderSide(
                          width: 4,
                          color: AppColor.missingInformationRed,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(alerts.title, style: AppTextStyle.ts14M()),
                        verticalSpacing(),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                alerts.content,
                                style: AppTextStyle.ts14R(),
                              ),
                            ),
                            horizontalSpacing(),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: 5,
                                  horizontal: 6,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4.0),
                                  color: AppColor.lightRed,
                                ),
                                child: Text(
                                  alerts.subContent,
                                  style: AppTextStyle.ts10B(
                                    color: AppColor.priorityHighColor,
                                  ),
                                ),
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
  }
}

class WeeklyCollectionChart extends StatelessWidget {
  final List<Table4> data;
  final String selectedType;
  final String filterType;

  const WeeklyCollectionChart({
    super.key,
    required this.data,
    required this.selectedType,
    required this.filterType,
  });

  double _getValue(Table4 item) {
    switch (selectedType) {
      case "GST":
        return item.gst.toDouble();

      case "TDS":
        return item.tds.toDouble();

      case "Agreement":
      default:
        return item.agreement.toDouble();
    }
  }

  String _formatLabel(String label) {
    try {
      final date = DateTime.parse(label);

      switch (filterType) {
        case "TODAY":
          return formatDateTimeAsDDMMMYYYY(date);

        case "WEEKLY":
          return formatDateTimeAsDDMMMYYYY(date);

        case "MONTHLY":
          return formatDateTimeAsDDMMMYYYY(date);

        case "DATEWISE":
          return formatDateTimeAsDDMMMYYYY(date);

        case "OVERALL":
          return formatDateTimeAsDDMMMYYYY(date);

        default:
          return formatDateTimeAsDDMMMYYYY(date);
      }
    } catch (e) {
      return label;
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxValue =
        data.isEmpty
            ? 0.0
            : data.map((e) => _getValue(e)).reduce((a, b) => a > b ? a : b);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(data.length, (index) {
        final item = data[index];

        final value = _getValue(item);

        final barHeight =
            maxValue == 0
                ? 50.0
                : ((value / maxValue) * 120).clamp(20.0, 120.0);
        DateTime? parsedDate;

        try {
          parsedDate = DateFormat("dd MMM yyyy").parse(item.label);
        } catch (e) {
          parsedDate = null;
        }

        final isToday =
            parsedDate != null &&
            formatDateTimeAsDDMMMYYYY(DateTime.now()) ==
                formatDateTimeAsDDMMMYYYY(parsedDate);

        return Container(
          width: 110,
          margin: const EdgeInsets.only(right: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                height: 130,
                alignment: Alignment.bottomCenter,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: barHeight,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors:
                              isToday
                                  ? [Colors.orange.shade200, Colors.orange]
                                  : [
                                    AppColor.primary.withValues(alpha: 0.85),
                                    AppColor.primary,
                                  ],
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(14),
                          topRight: Radius.circular(14),
                        ),
                      ),
                    ),
                    if (value > 0)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          formattedAmount(value, showRupeeSymbol: true),
                          style: AppTextStyle.ts14SB(color: AppColor.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),

              verticalSpacing(height: 12),

              Text(
                _formatLabel(item.label),
                style: AppTextStyle.ts14M(),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }),
    );
  }
}
