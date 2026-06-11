import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/chip_style_tab_bar.dart';

class ViewTaxTrackerScreen extends StatefulWidget {
  const ViewTaxTrackerScreen({super.key});

  @override
  State<ViewTaxTrackerScreen> createState() => _ViewTaxTrackerScreenState();
}

class _ViewTaxTrackerScreenState extends State<ViewTaxTrackerScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
  }

  // TAB CHANGE METHOD
  void _onTabChanged() {
    if (_tabController.index == 1) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Income Tax",
        authorization: AuthorizationModel(),
        isMenuButton: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("ITR ACK /Revised Return", style: AppTextStyle.ts14M()),
          ChipStyleTabBar(
            controller: _tabController,
            tabs: ["Details", "Tracking"],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [Container(), Container()],
            ),
          ),
        ],
      ),
    );
  }
}
