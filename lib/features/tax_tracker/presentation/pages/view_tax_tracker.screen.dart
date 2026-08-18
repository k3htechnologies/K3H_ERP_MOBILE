import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/tax_tracker/data/model/tracking_item.model.dart';
import 'package:k3h_erp_app/features/tax_tracker/presentation/pages/widget/container_decoration.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/chip_style_tab_bar.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

import '../../../../utils/functions/common_function.dart';

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
              children: [_detailsWidget(context), _trackingWidget(context)],
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
              buildColumnTitleValue(
                title: "Company Name",
                value: "Rishabraj Chambers",
              ),
              horizontalSpacing(width: 16.0),
              buildColumnTitleValue(
                title: "Company Name",
                value: "Rishabraj Chambers",
              ),
            ],
          ),
          verticalSpacing(height: 16.0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildColumnTitleValue(title: "Financial Year ", value: "2025-26"),
              horizontalSpacing(width: 16.0),
              buildColumnTitleValue(title: "Notice U/S", value: "143 (1)"),
            ],
          ),
          verticalSpacing(height: 16.0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildColumnTitleValue(
                title: "Responsible Person",
                value: "Prachin Bari",
              ),
              horizontalSpacing(width: 16.0),
              buildColumnTitleValue(
                title: "Status",
                value: "Reply Pending",
                customValueWidget: Container(
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 12.0),
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
              buildColumnTitleValue(
                title: "Notice Date",
                value: "09 June 2026",
              ),
              horizontalSpacing(width: 16.0),
              buildColumnTitleValue(title: "Due Date", value: "29 June 2026"),
            ],
          ),
          verticalSpacing(height: 16.0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildColumnTitleValue(
                title: "Authority",
                value: "Assessing Officer ( AO )",
              ),
              horizontalSpacing(width: 16.0),
              buildColumnTitleValue(title: "Notice Type", value: "Processing"),
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
              buildColumnTitleValue(title: "Reply Date", value: "16 June 2026"),
              horizontalSpacing(width: 16.0),
              buildColumnTitleValue(
                title: "Reply Submitted By",
                value: "Prachin Bari",
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
              buildColumnTitleValue(title: "Remark Type", value: "Notice"),
              horizontalSpacing(width: 16.0),
              buildColumnTitleValue(
                title: "Remark Date",
                value: "16 June 2026",
              ),
            ],
          ),
          verticalSpacing(height: 16.0),
          buildRowWrapper(
            child: buildColumnTitleValue(
              title: "Remark",
              value:
                  "Notice received regarding mismatch in reported turnover for FY 2024-25.  Initial review completed by internal accounts team and supporting ledger copies collected.  Draft reply prepared by tax consultant and reviewed by finance head on 22-Apr-2026.",
            ),
          ),
        ],
      ),
    );
  }

  Widget _trackingWidget(BuildContext context) {
    final List<TrackingItem> trackingList = [
      TrackingItem(
        title: "Notice Received",
        authority: "Assessing Officer ( AO )",
        date: "09 June 2026",
        uploadedBy: "Rahul Sharma",
        isCompleted: true,
        url:
            "http://202.168.146.8:402/documents/1/Employee/scaled_578e39fb-9192-40b8-bbb6-1119883db5361794365537003268879_4f265af9-d3af-4be9-9e00-195ab9fe779b.jpg",
      ),
      TrackingItem(
        title: "Reply Submitted",
        authority: "Assessing Officer ( AO )",
        date: "12 June 2026",
        uploadedBy: "Rahul Sharma",
        isCompleted: true,
        url:
            "http://202.168.146.8:402/documents/1/Employee/scaled_578e39fb-9192-40b8-bbb6-1119883db5361794365537003268879_4f265af9-d3af-4be9-9e00-195ab9fe779b.jpg",
      ),
      TrackingItem(
        title: "Order Uploaded",
        authority: "",
        date: "",
        uploadedBy: "",
        isCompleted: false,
        url: "",
      ),
    ];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListView.builder(
          itemCount: trackingList.length,
          itemBuilder: (context, index) {
            final item = trackingList[index];
            return _trackingTimelineItem(
              item: item,
              isLast: index == trackingList.length - 1,
            );
          },
        ),
      ),
    );
  }

  Widget _trackingTimelineItem({
    required TrackingItem item,
    required bool isLast,
  }) {
    return IntrinsicHeight(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  padding: EdgeInsets.all(6.25),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        item.isCompleted
                            ? const Color(0xffEFFFF5)
                            : const Color(0xffE5E7EB),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 1,
                        offset: Offset(1, 1),
                        color: AppColor.black.withValues(alpha: 0.12),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    AppAssets.tickIcon,
                    color:
                        item.isCompleted
                            ? Color(0xff15803D)
                            : AppColor.black.withValues(alpha: 0.3),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(width: 2, color: const Color(0xffE5E7EB)),
                  ),
              ],
            ),
          ),
          horizontalSpacing(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child:
                  item.isCompleted
                      ? _trackingCard(item)
                      : Text(item.title, style: AppTextStyle.ts12M()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _trackingCard(TrackingItem item) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xffE8F0FF).withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.title, style: AppTextStyle.ts12M()),
          verticalSpacing(height: 6),
          buildRowTitleValueNormal(
            title: "Authority",
            value: item.authority,
            singleLine: false,
          ),
          verticalSpacing(height: 6),
          buildRowTitleValueNormal(
            title: "Date",
            value: item.date,
            singleLine: false,
          ),
          verticalSpacing(height: 6),
          buildRowTitleValueNormal(
            title: "Uploaded By",
            value: item.uploadedBy,
            singleLine: false,
          ),
          verticalSpacing(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CustomButton.documentOutline(
                onPressed: () {
                  if (item.url.isNotEmpty) {
                    showFilePreviewDialog(context, item.url.split(","));
                  }
                },
                isDisable: item.url.isEmpty,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildRowTitleValueNormal({
    required String title,
    required String value,
    TextStyle? valueTextStyle,
    Widget? customValueWidget,
    bool singleLine = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              title,
              style: AppTextStyle.ts12R(
                color: AppColor.grey.withValues(alpha: 0.5),
              ),
            ),
          ),
          Text(
            ":",
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColor.grey),
          ),
          horizontalSpacing(),
          Expanded(
            child:
                customValueWidget ??
                Text(
                  value.isNotEmpty ? value : "-",
                  maxLines: singleLine ? 1 : null,
                  overflow:
                      singleLine ? TextOverflow.ellipsis : TextOverflow.visible,
                  style:
                      valueTextStyle ??
                      AppTextStyle.ts12R(
                        color: AppColor.greyTitleAndValueColor,
                      ),
                ),
          ),
        ],
      ),
    );
  }
}
