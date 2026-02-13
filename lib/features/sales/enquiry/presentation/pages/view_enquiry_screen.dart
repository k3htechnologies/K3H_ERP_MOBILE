import 'package:flutter/material.dart';
import 'package:k3h_erp_app/features/sales/enquiry/data/model/enquiry.model.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class ViewEnquiryScreen extends StatefulWidget {
  final EnquiryModel enquiryModel; // Use your actual EnquiryModel
  final int index;

  const ViewEnquiryScreen({
    super.key,
    required this.enquiryModel,
    this.index = 0,
  });

  @override
  State<ViewEnquiryScreen> createState() => _ViewEnquiryScreenState();
}

class _ViewEnquiryScreenState extends State<ViewEnquiryScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("View Enquiry")),
      body: SafeArea(
        child: Column(
          children: [
            _buildEnquiryTabBar(),
            verticalSpacing(),
            Expanded(
              child: TabBarView(
                physics: NeverScrollableScrollPhysics(),
                controller: _tabController,
                children: [buildOverviewTab(), buildRemarkActivity()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===================== TAB BAR =====================
  Widget _buildEnquiryTabBar() {
    return Align(
      alignment: Alignment.centerLeft,
      child: IntrinsicWidth(
        child: Container(
          height: 35,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColor.grey.withValues(alpha: 0.2)),
          ),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: AppColor.primary,
            unselectedLabelColor: AppColor.grey,
            indicator: BoxDecoration(
              color: AppColor.lightBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            labelStyle: AppTextStyle.ts14M(),
            unselectedLabelStyle: AppTextStyle.ts14M(),
            labelPadding: const EdgeInsets.symmetric(horizontal: 16),
            tabs: const [Tab(text: "Overview"), Tab(text: "Remark & Activity")],
          ),
        ),
      ),
    );
  }

  // ===================== OVERVIEW TAB =====================
  Widget buildOverviewTab() {
    final enquiry = widget.enquiryModel;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: commonCardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  enquiry.systemGeneratedCode,
                  style: AppTextStyle.ts16SB(color: AppColor.primary),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColor.lightBlue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "Enquiry",
                    style: AppTextStyle.ts12SB(color: AppColor.primary),
                  ),
                ),
              ],
            ),
            verticalSpacing(),
            Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Full Name",
                      value: enquiry.name,
                    ),
                    buildColumnTitleValue(
                      title: "Contact No.",
                      value: enquiry.mobileNumber,
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "E-Mail ID",
                      value: enquiry.emailId,
                    ),
                    buildColumnTitleValue(
                      title: "Location",
                      value: enquiry.villageName,
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Lead Classification",
                      value: enquiry.customerClassification,
                    ),
                    buildColumnTitleValue(
                      title: "Project Name",
                      value: enquiry.referelProjectName,
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Current Accommodation",
                      value: enquiry.accommodation,
                    ),
                    buildColumnTitleValue(
                      title: "Nationality",
                      value: enquiry.nationality,
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Country Of Residence",
                      value: enquiry.countryOfResidence,
                    ),
                    buildColumnTitleValue(
                      title: "City Of Residence",
                      value: enquiry.cityOfResidence,
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Date Of Birth",
                      value:
                          enquiry.dateOfBirth != null
                              ? formatDateTimeAsDDMMMYYYY(enquiry.dateOfBirth!)
                              : "-",
                    ),
                    buildColumnTitleValue(
                      title: "Age",
                      value: enquiry.age.toString(),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Source",
                      value: enquiry.source,
                    ),
                    buildColumnTitleValue(
                      title: "Sub-Source",
                      value: enquiry.subSource,
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Possession Type",
                      value: enquiry.possessionType,
                    ),
                    buildColumnTitleValue(
                      title: "Area Preferred",
                      value: enquiry.areaPreferred.toString(),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Desired Floor Band",
                      value: enquiry.desiredFloorBand,
                    ),
                    buildColumnTitleValue(
                      title: "Budget",
                      value: enquiry.budget,
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Requirement",
                      value: enquiry.requirement,
                    ),
                    buildColumnTitleValue(
                      title: "Requirement Type",
                      value: enquiry.requirementType,
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Customer Classification",
                      value: enquiry.customerClassification,
                    ),
                    buildColumnTitleValue(
                      title: "Source Of Funding",
                      value: enquiry.sourceOfFunding,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildRemarkActivity() {
    return Container();
  }
}
