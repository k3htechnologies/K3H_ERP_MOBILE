import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/tax_tracker/presentation/pages/widget/container_decoration.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/chip_style_tab_bar.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

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
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 20.0,
            ),
            child: Text("ITR ACK /Revised Return", style: AppTextStyle.ts14M()),
          ),
          ChipStyleTabBar(
            controller: _tabController,
            tabs: ["Details", "Tracking"],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [_detailsWidget(context), Container()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailsWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _basicDetailsWidget(),
            _noticeDetailsWidget(),
            _replyAndComplianceWidget(),
            _remarksWidget(),
          ],
        ),
      ),
    );
  }

  Widget _basicDetailsWidget() {
    return TaxTrackerSection(
      title: "Basic Details",
      headerBgColor: AppColor.lightBlueBg2,
      titleColor: AppColor.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: buildColumnTitleValueNormal(
                  title: "Company Name",
                  value: "Rishabraj Chambers",
                ),
              ),
              horizontalSpacing(width: 16.0),
              Expanded(
                child: buildColumnTitleValueNormal(
                  title: "Company Name",
                  value: "Rishabraj Chambers",
                ),
              ),
            ],
          ),
          verticalSpacing(height: 16.0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: buildColumnTitleValueNormal(
                  title: "Financial Year ",
                  value: "2025-26",
                ),
              ),
              horizontalSpacing(width: 16.0),
              Expanded(
                child: buildColumnTitleValueNormal(
                  title: "Notice U/S",
                  value: "143 (1)",
                ),
              ),
            ],
          ),
          verticalSpacing(height: 16.0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: buildColumnTitleValueNormal(
                  title: "Responsible Person",
                  value: "Prachin Bari",
                ),
              ),
              horizontalSpacing(width: 16.0),
              Expanded(
                child: buildColumnTitleValueNormal(
                  title: "Status",
                  value: "Reply Pending",
                  customValueWidget: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 12.0,
                    ),
                    decoration: BoxDecoration(
                      color: Color(0xffFFEDD5),
                      borderRadius: BorderRadius.circular(9999.0),
                    ),
                    child: Text(
                      "Reply Pending",
                      style: AppTextStyle.ts10M(color: Color(0xffC2410C)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _noticeDetailsWidget() {
    return TaxTrackerSection(
      title: "Notice Details",
      headerBgColor: AppColor.lightPurpleBg2,
      titleColor: AppColor.purpleColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: buildColumnTitleValueNormal(
                  title: "Notice Date",
                  value: "09 June 2026",
                ),
              ),
              horizontalSpacing(width: 16.0),
              Expanded(
                child: buildColumnTitleValueNormal(
                  title: "Due Date",
                  value: "29 June 2026",
                ),
              ),
            ],
          ),
          verticalSpacing(height: 16.0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: buildColumnTitleValueNormal(
                  title: "Authority",
                  value: "Assessing Officer ( AO )",
                ),
              ),
              horizontalSpacing(width: 16.0),
              Expanded(
                child: buildColumnTitleValueNormal(
                  title: "Notice Type",
                  value: "Processing",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _replyAndComplianceWidget() {
    return TaxTrackerSection(
      title: "Reply & Compliance",
      headerBgColor: AppColor.lightYellowBg2,
      titleColor: AppColor.brownYellowText,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: buildColumnTitleValueNormal(
                  title: "Reply Date",
                  value: "16 June 2026",
                ),
              ),
              horizontalSpacing(width: 16.0),
              Expanded(
                child: buildColumnTitleValueNormal(
                  title: "Reply Submitted By",
                  value: "Prachin Bari",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _remarksWidget() {
    return TaxTrackerSection(
      title: "Remark",
      headerBgColor: AppColor.lightBluebg,
      titleColor: AppColor.blueBgColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: buildColumnTitleValueNormal(
                  title: "Remark Type",
                  value: "Notice",
                ),
              ),
              horizontalSpacing(width: 16.0),
              Expanded(
                child: buildColumnTitleValueNormal(
                  title: "Remark Date",
                  value: "16 June 2026",
                ),
              ),
            ],
          ),
          verticalSpacing(height: 16.0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: buildColumnTitleValueNormal(
                  title: "Remark",
                  value:
                      "Notice received regarding mismatch in reported turnover for FY 2024-25.  Initial review completed by internal accounts team and supporting ledger copies collected.  Draft reply prepared by tax consultant and reviewed by finance head on 22-Apr-2026.",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
