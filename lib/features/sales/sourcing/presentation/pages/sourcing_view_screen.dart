import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/channel_partner/data/model/channel_partner.model.dart';
import 'package:k3h_erp_app/features/sales/sourcing/presentation/cubit/sourcing_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_click_to_contact_widget.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class SourcingViewScreen extends StatefulWidget {
  final ChannelPartnerModel channelPartner;
  final int projectId;

  const SourcingViewScreen({
    super.key,
    required this.channelPartner,
    required this.projectId,
  });

  @override
  State<SourcingViewScreen> createState() => _SourcingViewScreenState();
}

class _SourcingViewScreenState extends State<SourcingViewScreen>
    with SingleTickerProviderStateMixin {
  // TAB CONTROLLER
  late TabController _tabController;

  // CUBIT
  late SourcingCubit _sourcingCubit;

  @override
  void initState() {
    super.initState();
    _sourcingCubit = context.read<SourcingCubit>();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  // HANDLE TAB CHANGE
  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      _sourcingCubit.onTabChanged(
        _tabController.index,
        context,
        channelPartnerId: widget.channelPartner.channelPartnerId,
        projectId: widget.projectId,
      );
    }
  }

  // ADD REMARK BOTTOM SHEET
  Future<void> _showBottomSheetToAddRemark(BuildContext context) async {
    DialogHelper.showCustomBottomSheet(
      context,
      "Add Remark",
      Column(children: [

      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Sourcing",
        authorization: AuthorizationModel(),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IntrinsicWidth(
                child: Container(
                  height: 35,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColor.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColor.grey.withValues(alpha: 0.2),
                    ),
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
                    padding: EdgeInsets.zero,
                    tabs: const [
                      Tab(text: 'Overview'),
                      Tab(text: 'Remark & Activity'),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                physics: NeverScrollableScrollPhysics(),
                controller: _tabController,
                children: [_buildOverviewTab(), _buildRemarkAndActivityTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // BUILD OVERVIEW TAB
  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        children: [
          Container(
            decoration: commonCardDecoration(),
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.only(bottom: 10),
            child: Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Basic Details",
                  style: AppTextStyle.ts14M(color: AppColor.grey),
                ),
                Row(
                  spacing: 5,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Full Name",
                      value: widget.channelPartner.name,
                    ),
                    buildColumnTitleValue(
                      title: "Contact No.",
                      value: widget.channelPartner.mobileNumber,
                      customValueWidget: CustomClickToContactText(
                        value: widget.channelPartner.mobileNumber,
                      ),
                    ),
                  ],
                ),
                Row(
                  spacing: 5,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "E-Mail ID",
                      value: widget.channelPartner.emailId,
                      customValueWidget: CustomClickToContactText(
                        value: widget.channelPartner.emailId,
                        type: ContactType.email,
                      ),
                    ),
                    buildColumnTitleValue(
                      title: "Company Name",
                      value: widget.channelPartner.companyName,
                    ),
                  ],
                ),
                Row(
                  spacing: 5,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Alternate Contact No.",
                      value: widget.channelPartner.alternativeMobileNumber,
                      customValueWidget: CustomClickToContactText(
                        value: widget.channelPartner.alternativeMobileNumber,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            decoration: commonCardDecoration(),
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.only(bottom: 10),
            child: Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "RERA Details",
                  style: AppTextStyle.ts14M(color: AppColor.grey),
                ),
                Row(
                  spacing: 5,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Available RERA Number",
                      value:
                          widget.channelPartner.reraNumber.isNotEmpty
                              ? "Yes"
                              : "No",
                    ),
                    buildColumnTitleValue(
                      title: "RERA Number",
                      value: widget.channelPartner.reraNumber,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            decoration: commonCardDecoration(),
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.only(bottom: 10),
            child: Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Address",
                  style: AppTextStyle.ts14M(color: AppColor.grey),
                ),
                Row(
                  spacing: 5,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(title: "Country", value: ""),
                    buildColumnTitleValue(title: "State", value: ""),
                  ],
                ),
                Row(
                  spacing: 5,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(title: "District", value: ""),
                    buildColumnTitleValue(title: "City", value: ""),
                  ],
                ),
                Row(
                  spacing: 5,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(title: "Village", value: ""),
                    buildColumnTitleValue(
                      title: "Office Address",
                      value: widget.channelPartner.officeAddress,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            decoration: commonCardDecoration(),
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.only(bottom: 10),
            child: Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Document Details",
                  style: AppTextStyle.ts14M(color: AppColor.grey),
                ),
                Row(
                  spacing: 5,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "PAN Number",
                      value: widget.channelPartner.panNumber,
                    ),
                    buildColumnTitleValue(
                      title: "Aadhaar Number",
                      value: widget.channelPartner.adharCardNumber,
                    ),
                  ],
                ),
                Row(
                  spacing: 5,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "GST Number",
                      value: widget.channelPartner.gstNumber,
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

  // BUILD REMARK AND ACTIVITY TAB
  Widget _buildRemarkAndActivityTab() {
    return BlocBuilder<SourcingCubit, SourcingState>(
      builder: (context, state) {
        final data =
            state.sourcingList
                .where((e) => e.ibmObm == (state.isIBM ? "IBM" : "OBM"))
                .toList();

        return Column(
          children: [
            verticalSpacing(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      _sourcingCubit.onIBMTabChanged("IBM", context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color:
                            state.isIBM ? AppColor.lightBlue : AppColor.white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColor.primary, width: .5),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: Text(
                        "IBM",
                        style: AppTextStyle.ts12M(
                          color: state.isIBM ? AppColor.black : AppColor.grey,
                        ),
                      ),
                    ),
                  ),
                  horizontalSpacing(),
                  GestureDetector(
                    onTap: () {
                      _sourcingCubit.onIBMTabChanged("OBM", context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color:
                            (!state.isIBM)
                                ? AppColor.lightBlue
                                : AppColor.white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColor.primary, width: .5),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: Text(
                        "OBM",
                        style: AppTextStyle.ts12M(
                          color:
                              (!state.isIBM) ? AppColor.black : AppColor.grey,
                        ),
                      ),
                    ),
                  ),
                  Spacer(),
                  CustomButton(
                    leading: Icon(Icons.add, size: 18, color: AppColor.white),
                    text: "Add Remark",
                    onPressed: () {
                      _showBottomSheetToAddRemark(context);
                    },
                  ),
                ],
              ),
            ),

            Divider(color: AppColor.grey, thickness: .2),

            Expanded(
              child:
                  data.isEmpty
                      ? Center(child: noDataWidget())
                      : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        itemCount: data.length,
                        itemBuilder: (_, index) {
                          final item = data[index];

                          final isLast = index == data.length - 1;

                          return IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // TIME LINE
                                Column(
                                  children: [
                                    Container(
                                      width: 14,
                                      height: 14,
                                      decoration: const BoxDecoration(
                                        color: AppColor.primary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    if (!isLast)
                                      Expanded(
                                        child: Container(
                                          width: 2,
                                          color: AppColor.primary.withValues(
                                            alpha: .2,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),

                                horizontalSpacing(),

                                // CONTENT
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // DATE AND TIME
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                formatDate(item.createdDate),
                                                style: AppTextStyle.ts14M(),
                                              ),
                                            ),
                                            horizontalSpacing(),
                                            Text(
                                              formatTime(item.createdDate),
                                              style: AppTextStyle.ts12M(
                                                color: AppColor.grey,
                                              ),
                                            ),
                                          ],
                                        ),

                                        // SUPPORT
                                        if ((item.support ?? "").isNotEmpty)
                                          Text(
                                            'Support: ${item.support ?? ""}',
                                            style: AppTextStyle.ts12M(),
                                          ),

                                        // REMARK
                                        if ((item.sourcingRemark ?? "")
                                            .isNotEmpty)
                                          Text(
                                            item.sourcingRemark ?? "",
                                            style: AppTextStyle.ts14R(
                                              color: AppColor.grey,
                                            ),
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
          ],
        );
      },
    );
  }
}
