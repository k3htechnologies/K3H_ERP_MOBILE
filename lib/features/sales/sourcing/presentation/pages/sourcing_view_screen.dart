// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/channel_partner/data/model/channel_partner.model.dart';
import 'package:k3h_erp_app/features/sales/sourcing/data/model/sourcing.model.dart';
import 'package:k3h_erp_app/features/sales/sourcing/presentation/cubit/sourcing_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_click_to_contact_widget.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
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

  // AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;

  // CUBIT
  late SourcingCubit _sourcingCubit;

  // TEXT CONTROLLER
  late TextEditingController _remarkC;

  // FORM KEY
  final _formKey = GlobalKey<FormState>();

  late Map<String, dynamic> selectedSupport;

  // STATIC SUPPORT LIST
  List<Map<String, dynamic>> supportList = [
    {"zAttributesId": -1, "DisplayName": "Select Support"},
    {"zAttributesId": 1, "DisplayName": "Below The Line (BTL)"},
    {"zAttributesId": 2, "DisplayName": "Paper Insert"},
    {"zAttributesId": 3, "DisplayName": "Standee Require"},
    {"zAttributesId": 4, "DisplayName": "Video Recording"},
  ];

  @override
  void initState() {
    super.initState();
    _sourcingCubit = context.read<SourcingCubit>();

    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.sourcing]!;
    _remarkC = TextEditingController();
    selectedSupport = supportList.first;
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
    _remarkC.dispose();
    _sourcingCubit.clearSourcingList();
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

  // CLEAR BOTTOM SHEET
  void _clearBottomSheet() {
    selectedSupport = supportList.first;
    _remarkC.clear();
  }

  // <---- DELETE DEPARTMENT ---->
  Future<void> _showPopupToDeleteRemark(
    BuildContext context,
    SourcingModel obj,
  ) async {
    var result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a Remark ?',
      'Deleting this Remark will permanently remove all associated data.',
    );
    if (result && context.mounted) {
      _sourcingCubit.deleteDepartmentMaster(
        context: context,
        channelPartnerSourcingId: obj.channelPartnerSourcingId!,
        channelPartnerId: obj.channelPartnerId!,
        projectId: widget.projectId,
        uniqueKey: obj.uniquekey!,
      );
    }
  }

  // UPDATE REMARK BOTTOM SHEET
  Future<void> _showBottomSheetToUpdateRemark(
    BuildContext context,
    SourcingModel obj,
  ) async {
    // Prefill values
    _remarkC.text = obj.sourcingRemark ?? "";
    selectedSupport = supportList.firstWhere(
      (e) => e["DisplayName"] == (obj.support ?? ""),
      orElse: () => supportList.first,
    );
    bool isIBM = (obj.ibmObm ?? "").toUpperCase() == "IBM";

    await DialogHelper.showCustomBottomSheet(
      context,
      "Update Remark",
      StatefulBuilder(
        builder: (context, innerState) {
          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // IBM/OBM RADIO BUTTONS
                    Row(
                      children: [
                        Radio<bool>(
                          value: true,
                          groupValue: isIBM,
                          onChanged: (value) {
                            if (value == null) return;
                            innerState(() {
                              isIBM = value;
                            });
                          },
                        ),
                        Text("IBM", style: AppTextStyle.ts14M()),
                        const SizedBox(width: 16),
                        Radio<bool>(
                          value: false,
                          groupValue: isIBM,
                          onChanged: (value) {
                            if (value == null) return;
                            innerState(() {
                              isIBM = value;
                            });
                          },
                        ),
                        Text("OBM", style: AppTextStyle.ts14M()),
                      ],
                    ),
                    verticalSpacing(height: 12),

                    // REMARK
                    CustomTextField(
                      title: "Remark",
                      hint: "Enter remark",
                      isRequired: true,
                      textController: _remarkC,
                      minLines: 3,
                      maxLines: 3,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter remark";
                        }
                        return null;
                      },
                    ),

                    // SUPPORT
                    CustomDropDownWidget(
                      title: "Support",
                      hintText: "Select Support",
                      dataList: supportList,
                      initialValue: selectedSupport,
                      onSelected: (value) {
                        selectedSupport = value;
                      },
                    ),

                    // Update button
                    SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        text: "Update",
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _submitForm(isIBM, obj);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );

    _clearBottomSheet();
  }

  // ADD REMARK BOTTOM SHEET
  Future<void> _showBottomSheetToAddRemark(BuildContext context) async {
    final currentFilter = _sourcingCubit.state.selectedFilter;

    bool isIBM =
        currentFilter == "IBM"
            ? true
            : currentFilter == "OBM"
            ? false
            : true;

    await DialogHelper.showCustomBottomSheet(
      context,
      "Add Remark",
      StatefulBuilder(
        builder: (context, innerState) {
          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // IBM/OBM RADIO BUTTONS
                    Row(
                      children: [
                        Radio<bool>(
                          value: true,
                          groupValue: isIBM,
                          onChanged: (value) {
                            if (value == null) return;
                            innerState(() {
                              isIBM = value;
                            });
                          },
                        ),
                        Text("IBM", style: AppTextStyle.ts14M()),
                        const SizedBox(width: 16),
                        Radio<bool>(
                          value: false,
                          groupValue: isIBM,
                          onChanged: (value) {
                            if (value == null) return;
                            innerState(() {
                              isIBM = value;
                            });
                          },
                        ),
                        Text("OBM", style: AppTextStyle.ts14M()),
                      ],
                    ),
                    verticalSpacing(height: 12),

                    // REMARK
                    CustomTextField(
                      title: "Remark",
                      hint: "Enter remark",
                      isRequired: true,
                      textController: _remarkC,
                      minLines: 3,
                      maxLines: 3,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter remark";
                        }
                        return null;
                      },
                    ),

                    // SUPPORT
                    CustomDropDownWidget(
                      title: "Support",
                      hintText: "Select Support",
                      dataList: supportList,
                      onSelected: (value) {
                        selectedSupport = value;
                      },
                    ),

                    // Save button
                    SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        text: "Save",
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _submitForm(isIBM, null);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
    _clearBottomSheet();
  }

  void _submitForm(bool isIBM, SourcingModel? obj) {
    if (!_formKey.currentState!.validate()) return;

    if (obj == null) {
      _sourcingCubit.addRemark(
        context: context,
        channelPartnerId: widget.channelPartner.channelPartnerId,
        type: isIBM ? "IBM" : "OBM",
        projectId: widget.projectId,
        remark: _remarkC.text,
        support:
            selectedSupport["zAttributesId"] == -1
                ? ""
                : selectedSupport["DisplayName"],
      );
    } else {
      _sourcingCubit.updateRemark(
        context: context,
        channelPartnerSourcingId: obj.channelPartnerSourcingId ?? 0,
        uniqueKey: obj.uniquekey!,
        channelPartnerId:
            obj.channelPartnerId ?? widget.channelPartner.channelPartnerId,
        type: isIBM ? "IBM" : "OBM",
        projectId: widget.projectId,
        remark: _remarkC.text,
        support:
            selectedSupport["zAttributesId"] == -1
                ? ""
                : selectedSupport["DisplayName"],
      );
    }
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: showSiteSelectedWidget(),
            ),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          verticalSpacing(height: 5),
          Text(
            widget.channelPartner.systemGeneratedCode,
            style: AppTextStyle.ts16SB(color: AppColor.primary),
          ),
          verticalSpacing(),
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
                    buildColumnTitleValue(
                      title: "Country",
                      value: widget.channelPartner.countryName,
                    ),
                    buildColumnTitleValue(
                      title: "State",
                      value: widget.channelPartner.stateName,
                    ),
                  ],
                ),
                Row(
                  spacing: 5,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "District",
                      value: widget.channelPartner.districtName,
                    ),
                    buildColumnTitleValue(
                      title: "City",
                      value: widget.channelPartner.cityName,
                    ),
                  ],
                ),
                Row(
                  spacing: 5,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Village",
                      value: widget.channelPartner.villageName,
                    ),
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
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Document Details",
                  style: AppTextStyle.ts14M(color: AppColor.grey),
                ),
                verticalSpacing(),
                _buildDocumentCard(context, widget.channelPartner),
              ],
            ),
          ),
          actionCardWidget(
            createdBy: widget.channelPartner.createdBy,
            createdDate: widget.channelPartner.createdDate,
            modifiedBy: widget.channelPartner.modifiedBy,
            modifiedDate: widget.channelPartner.modifiedDate,
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
            state.selectedFilter == "ALL"
                ? state.sourcingList
                : state.sourcingList
                    .where((e) => e.ibmObm == state.selectedFilter)
                    .toList();

        final displayList = [...data]..sort(
          (a, b) => (b.createdDate ?? DateTime(0)).compareTo(
            a.createdDate ?? DateTime(0),
          ),
        );

        return Column(
          children: [
            verticalSpacing(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  _buildFilterTab("ALL", state),
                  horizontalSpacing(),
                  _buildFilterTab("IBM", state),
                  horizontalSpacing(),
                  _buildFilterTab("OBM", state),
                  Spacer(),
                  if (_routeAuthorizationModel.isAction)
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
                  state.isLoading == true
                      ? loader()
                      : displayList.isEmpty
                      ? Center(child: noDataWidget())
                      : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        itemCount: displayList.length,
                        itemBuilder: (_, index) {
                          final item = displayList[index];

                          final isLast = index == displayList.length - 1;

                          return IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // TIMELINE
                                Column(
                                  children: [
                                    Container(
                                      width: 14,
                                      height: 14,
                                      margin: const EdgeInsets.only(top: 2),
                                      decoration: const BoxDecoration(
                                        color: AppColor.primary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),

                                    if (!isLast)
                                      Expanded(
                                        child: Container(
                                          width: 2,
                                          margin: const EdgeInsets.symmetric(
                                            vertical: 2,
                                          ),
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
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                formatDate(item.createdDate),
                                                style: AppTextStyle.ts14M(),
                                              ),
                                            ),

                                            Visibility(
                                              visible:
                                                  index == 0 &&
                                                  (item.isAction &&
                                                      _routeAuthorizationModel
                                                          .isAction),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  CustomIconButton.edit(
                                                    onPressed: () {
                                                      _showBottomSheetToUpdateRemark(
                                                        context,
                                                        item,
                                                      );
                                                    },
                                                  ),
                                                  horizontalSpacing(),
                                                  CustomIconButton.delete(
                                                    onPressed: () {
                                                      _showPopupToDeleteRemark(
                                                        context,
                                                        item,
                                                      );
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Row(
                                                children: [
                                                  Text(
                                                    '${item.createdBy}',
                                                    style: AppTextStyle.ts12M(),
                                                  ),
                                                  horizontalSpacing(),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 12,
                                                          vertical: 3,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          item.isIBM
                                                              ? AppColor
                                                                  .purple20
                                                              : AppColor.yellow
                                                                  .withValues(
                                                                    alpha: .2,
                                                                  ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      item.isIBM
                                                          ? "IBM"
                                                          : "OBM",
                                                      style: AppTextStyle.ts12M(
                                                        color:
                                                            item.isIBM
                                                                ? AppColor
                                                                    .purple
                                                                : AppColor
                                                                    .orange,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 4),
                                        if ((item.support ?? "").isNotEmpty)
                                          Text(
                                            'Support: ${item.support}',
                                            style: AppTextStyle.ts12M(),
                                          ),

                                        const SizedBox(height: 4),
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

  Widget _buildFilterTab(String value, SourcingState state) {
    final isSelected = state.selectedFilter == value;

    return GestureDetector(
      onTap: () {
        _sourcingCubit.onFilterChanged(value);
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? AppColor.lightBlue : AppColor.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppColor.primary, width: .5),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Text(
          value,
          style: AppTextStyle.ts12M(
            color: isSelected ? AppColor.black : AppColor.grey,
          ),
        ),
      ),
    );
  }

  // DOCUMENT CARD
  Widget _buildDocumentCard(
    BuildContext context,
    ChannelPartnerModel channelPartner,
  ) {
    final List<Map<String, String>> documents = [
      {
        "title": "PAN Card",
        "number": channelPartner.panNumber,
        "url": channelPartner.panCardUrl,
      },
      {
        "title": "Aadhaar Card",
        "number": channelPartner.aadhaarCardNumber,
        "url": channelPartner.aadhaarCardUrl,
      },
      {
        "title": "GST Certificate",
        "number": channelPartner.gstNumber,
        "url": channelPartner.gstCertificateUrl,
      },
    ];

    final validDocuments =
        documents.where((doc) => (doc["url"] ?? "").isNotEmpty).toList();

    if (validDocuments.isEmpty) {
      return Center(
        child: noDataWidget(message: "No Documents Available", iconSize: 100),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 10,
      children:
          List.generate((validDocuments.length / 2).ceil(), (index) {
            final first = validDocuments[index * 2];
            final second =
                (index * 2 + 1 < validDocuments.length)
                    ? validDocuments[index * 2 + 1]
                    : null;
            return Row(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildColumnTitleValue(
                  title: first['title'] ?? "-",
                  value:
                      (first['number'] != null && first['number']!.isNotEmpty)
                          ? first['number']!
                          : "-",
                  customValueWidget: buildDocumentRow(
                    context: context,
                    docNumber:
                        (first['number'] != null && first['number']!.isNotEmpty)
                            ? first['number']!
                            : "-",
                    url: first['url'] ?? "-",
                  ),
                ),
                second != null
                    ? buildColumnTitleValue(
                      title: second['title'] ?? "-",
                      value:
                          (second['number'] != null &&
                                  second['number']!.isNotEmpty)
                              ? second['number']!
                              : "-",
                      customValueWidget: buildDocumentRow(
                        context: context,
                        docNumber:
                            (second['number'] != null &&
                                    second['number']!.isNotEmpty)
                                ? second['number']!
                                : "-",
                        url: second['url'] ?? "-",
                      ),
                    )
                    : SizedBox.shrink(),
              ],
            );
          }).toList(),
    );
  }
}
