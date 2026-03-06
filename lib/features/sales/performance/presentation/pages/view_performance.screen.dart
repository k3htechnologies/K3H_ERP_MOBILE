import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class ViewPerformanceScreen extends StatefulWidget {
  const ViewPerformanceScreen({super.key});

  @override
  State<ViewPerformanceScreen> createState() => _ViewPerformanceScreenState();
}

class _ViewPerformanceScreenState extends State<ViewPerformanceScreen>
    with SingleTickerProviderStateMixin {
  // TABS
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBarWithBackButton(
          screenTitle: "View Performance",
          authorization: AuthorizationModel(),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20.0, top: 20.0),
              child: Text(
                "Prachin Bari",
                style: AppTextStyle.ts16SB(color: AppColor.primary),
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
              padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6.0),
                border: Border.all(
                  width: 0.8,
                  color: AppColor.black.withValues(alpha: 0.15),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Overall Target",
                    style: AppTextStyle.ts14M(
                      color: AppColor.black.withValues(alpha: 0.7),
                    ),
                  ),
                  Text(
                    "200",
                    style: AppTextStyle.ts16SB(color: AppColor.black),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
              padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6.0),
                border: Border.all(
                  width: 0.8,
                  color: AppColor.black.withValues(alpha: 0.15),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Overall Achieved",
                    style: AppTextStyle.ts14M(
                      color: AppColor.black.withValues(alpha: 0.7),
                    ),
                  ),
                  Text(
                    "200",
                    style: AppTextStyle.ts16SB(color: AppColor.black),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
              padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6.0),
                border: Border.all(
                  width: 0.8,
                  color: AppColor.black.withValues(alpha: 0.15),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Overall Performance",
                    style: AppTextStyle.ts14M(
                      color: AppColor.black.withValues(alpha: 0.7),
                    ),
                  ),
                  Text(
                    "80%",
                    style: AppTextStyle.ts16SB(color: AppColor.green),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              child: TabBar(
                controller: _tabController,
                labelColor: AppColor.primary,
                unselectedLabelColor: AppColor.black.withValues(alpha: 0.5),
                indicatorColor: AppColor.primary.withValues(alpha: 0.3),
                dividerColor: AppColor.primary,
                labelStyle: AppTextStyle.ts16SB(),
                unselectedLabelStyle: AppTextStyle.ts14M(),
                indicatorWeight: 4,
                dividerHeight: 0.5,
                tabs: const [
                  Tab(text: "Walkins"),
                  Tab(text: "Booking"),
                  Tab(text: "Ratio"),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_walkinsTab(), _bookingTab(), _ratioTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _walkinsTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      children: [
        _performanceCard("Total Walkins", "100", "80", "80%"),
        _performanceCard("Walkins By CP", "50", "40", "80%"),
        _performanceCard("Direct Walkins", "50", "40", "80%"),
        _performanceCard("Fresh Visit", "20", "15", "75%"),
        _performanceCard("Revisit", "20", "15", "75%"),
      ],
    );
  }

  Widget _bookingTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      children: [
        _performanceCard("Total Bookings", "100", "80", "80%"),
        _performanceCard("Booking By CPs", "50", "40", "80%"),
        _performanceCard("Direct Bookings", "50", "40", "80%"),
        _performanceCard("Target Amount", "20", "15", "75%"),
        _performanceCard("Revenue", "20", "15", "75%"),
      ],
    );
  }

  Widget _ratioTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      children: [
        _performanceCard("Revisit Ratio", "100", "80", "80%"),
        _performanceCard("Walkin To Booking by CP", "50", "40", "80%"),
        _performanceCard("Walkin To Booking by Direct", "50", "40", "75%"),
      ],
    );
  }

  Widget _performanceCard(
    String title,
    String target,
    String achieved,
    String performance,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: AppColor.white,
        border: Border.all(color: AppColor.black.withValues(alpha: .08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyle.ts14M(color: AppColor.black)),

          verticalSpacing(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _valueColumn("Target", target),

              _valueColumn("Achieved", achieved),
              _valueColumn(
                "Performance",
                performance,
                valueColor:
                    performance == "75%" ? Colors.orange : AppColor.green,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _valueColumn(String title, String value, {Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyle.ts12R(color: AppColor.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyle.ts14M(color: valueColor ?? AppColor.black),
        ),
      ],
    );
  }
}
