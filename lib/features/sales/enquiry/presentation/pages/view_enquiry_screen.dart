import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/features/sales/enquiry/data/model/enquiry.model.dart';
import 'package:k3h_erp_app/features/sales/enquiry/data/model/enquiry_followup.model.dart';
import 'package:k3h_erp_app/features/sales/enquiry/presentation/cubit/enquiry_cubit.dart';
import 'package:k3h_erp_app/features/sales/enquiry/presentation/cubit/enquiry_state.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';
import 'package:timelines_plus/timelines_plus.dart';

class ViewEnquiryScreen extends StatefulWidget {
  final EnquiryModel enquiryModel;
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
  late EnquiryCubit _enquiryCubit;
  final GlobalKey<FormState> _statusFormKey = GlobalKey<FormState>();

  Map<String, dynamic>? _selectedStatus;
  Map<String, dynamic>? _selectedLostReason;
  DateTime? _nextFollowupDate;

  final TextEditingController _remarkC = TextEditingController();
  final ValueNotifier<int> _tabIndexNotifier = ValueNotifier(0);

  final List<Map<String, dynamic>> _statusList = [
    {'zAttributesId': 1, 'DisplayName': 'Site Visit'},
    {'zAttributesId': 2, 'DisplayName': 'Re-Visit Proposed'},
    {'zAttributesId': 3, 'DisplayName': 'Re-Visit Scheduled'},
    {'zAttributesId': 4, 'DisplayName': 'Negotiation'},
    {'zAttributesId': 5, 'DisplayName': 'Unit Selection / Blocked'},
    {'zAttributesId': 6, 'DisplayName': 'Blocked'},
    {'zAttributesId': 7, 'DisplayName': 'Booking Done'},
    {'zAttributesId': 8, 'DisplayName': 'Retention'},
    {'zAttributesId': 9, 'DisplayName': 'Lost'},
    {'zAttributesId': 10, 'DisplayName': 'Cancelled'},
  ];

  final List<Map<String, dynamic>> _lostReasonList = [
    {"DisplayName": "Price Issue"},
    {"DisplayName": "Location Issue"},
    {"DisplayName": "Competitor"},
    {"DisplayName": "Budget"},
    {"DisplayName": "Other"},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _enquiryCubit = context.read<EnquiryCubit>();
    _enquiryCubit.clearEnquiryFollowUp();
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _tabIndexNotifier.value = _tabController.index;
        _loadFollowUpsIfNeeded();
      }
    });
  }

  void _loadFollowUpsIfNeeded() {
    if (_tabController.index == 1 && !_tabController.indexIsChanging) {
      _enquiryCubit.clearEnquiryFollowUp();
      _enquiryCubit.fetchEnquiryFollowUps(
        enquiryId: widget.enquiryModel.enquiryId,
        projectId: getProject().projectId,
      );
    }
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
                physics: const NeverScrollableScrollPhysics(),
                controller: _tabController,
                children: [buildOverviewTab(), buildRemarkActivityTimeline()],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: ValueListenableBuilder<int>(
        valueListenable: _tabIndexNotifier,
        builder: (context, index, _) {
          if (index != 1) return const SizedBox.shrink();

          return SafeArea(
            child: Container(
              height: 70,
              padding: const EdgeInsets.all(16),
              child: CustomButton(
                text: "Set Next Activity",
                onPressed: () {
                  _showStatusBottomSheet(context);
                },
              ),
            ),
          );
        },
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
    final bool isChannelPartner = enquiry.source == "Channel Partner";

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        spacing: 10,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                enquiry.systemGeneratedCode,
                style: AppTextStyle.ts16SB(color: AppColor.primary),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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

          /// Lead Info
          _buildCard(
            child: Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle("Lead Information"),

                Row(
                  children: [
                    buildColumnTitleValue(
                      title: "Enquiry Date",
                      value:
                          enquiry.enquiryDate != null
                              ? formatDateTimeAsDDMMMYYYY(enquiry.enquiryDate!)
                              : "-",
                    ),
                    buildColumnTitleValue(
                      title: "Next Follow-Up Date",
                      value:
                          enquiry.nextFollowUpDate != null
                              ? formatDateTimeAsDDMMMYYYY(
                                enquiry.nextFollowUpDate!,
                              )
                              : "-",
                    ),
                  ],
                ),

                Row(
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
                  children: [
                    buildColumnTitleValue(
                      title: "E-Mail ID",
                      value: enquiry.emailId.isNotEmpty ? enquiry.emailId : "-",
                    ),
                    buildColumnTitleValue(
                      title: "Date of Birth",
                      value:
                          enquiry.dateOfBirth != null
                              ? formatDateTimeAsDDMMMYYYY(enquiry.dateOfBirth!)
                              : "-",
                    ),
                  ],
                ),

                Row(
                  children: [
                    buildColumnTitleValue(
                      title: "Age",
                      value: enquiry.age.toString(),
                    ),
                    buildColumnTitleValue(
                      title: "Accommodation",
                      value: enquiry.accommodation,
                    ),
                  ],
                ),

                Row(
                  children: [
                    buildColumnTitleValue(
                      title: "Occupation Type",
                      value: enquiry.occupationType,
                    ),
                    buildColumnTitleValue(
                      title: "Nationality",
                      value: enquiry.nationality,
                    ),
                  ],
                ),

                Row(
                  children: [
                    buildColumnTitleValue(
                      title: "Customer Time In",
                      value: enquiry.enquiryTimeIn,
                    ),
                    buildColumnTitleValue(
                      title: "Customer Time Out",
                      value: enquiry.enquiryTimeOut,
                    ),
                  ],
                ),
              ],
            ),
          ),

          /// Source Info
          _buildCard(
            child: Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle("Source Information"),

                Row(
                  children: [
                    buildColumnTitleValue(
                      title: "Source",
                      value: enquiry.source,
                    ),
                    buildColumnTitleValue(
                      title: "Sub Source",
                      value: enquiry.subSource,
                    ),
                  ],
                ),

                if (isChannelPartner) ...[
                  Row(
                    children: [
                      buildColumnTitleValue(
                        title: "Channel Partner",
                        value: enquiry.channelPartnerName,
                      ),
                      buildColumnTitleValue(
                        title: "Channel Partner Number",
                        value: enquiry.channelPartnerMobileNumber,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      buildColumnTitleValue(
                        title: "Team Member Name",
                        value: enquiry.channelPartnerTeamMemberName,
                      ),
                      buildColumnTitleValue(
                        title: "Team Member Mobile",
                        value: enquiry.channelPartnerTeamMemberMobileNumber,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          /// Property
          _buildCard(
            child: Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle("Property Preferences"),

                Row(
                  children: [
                    buildColumnTitleValue(
                      title: "Budget (In CR)",
                      value: enquiry.budget,
                    ),
                    buildColumnTitleValue(
                      title: "Possession Type",
                      value: enquiry.possessionType,
                    ),
                  ],
                ),

                Row(
                  children: [
                    buildColumnTitleValue(
                      title: "Requirement",
                      value: enquiry.requirement,
                    ),

                    buildColumnTitleValue(
                      title: "Type",
                      value: enquiry.requirementType,
                    ),
                  ],
                ),

                Row(
                  children: [
                    buildColumnTitleValue(
                      title: "Location",
                      value: enquiry.currentLocation,
                    ),

                    buildColumnTitleValue(
                      title: "Timeline",
                      value: enquiry.timeline,
                    ),
                  ],
                ),

                Row(
                  children: [
                    buildColumnTitleValue(
                      title: "Area Preferred (SqFt)",
                      value: enquiry.areaPreferred.toString(),
                    ),
                    buildColumnTitleValue(
                      title: "Desired Floor Band",
                      value: enquiry.desiredFloorBand,
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

  // ── Shared card wrapper ───────────────────────────────────────────
  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: commonCardDecoration(),
      child: child,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Text(title, style: AppTextStyle.ts14SB(color: AppColor.black)),
    );
  }

  Widget buildRemarkActivityTimeline() {
    return BlocBuilder<EnquiryCubit, EnquiryState>(
      builder: (context, state) {
        if (state.isLoading!) {
          return loader();
        }

        if (state.enquiryFollowUpList.isEmpty) {
          return noDataWidget();
        }

        final items = state.enquiryFollowUpList;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: Column(
            children: [
              Container(
                decoration: commonCardDecoration(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.enquiryModel.systemGeneratedCode),
                    verticalSpacing(),
                    FixedTimeline.tileBuilder(
                      theme: TimelineThemeData(nodePosition: 0),
                      builder: TimelineTileBuilder.connected(
                        itemCount: items.length + 1,
                        connectionDirection: ConnectionDirection.before,

                        indicatorPositionBuilder: (context, index) => 0.0,

                        /// 🔵 / ⚪ Indicator
                        indicatorBuilder: (context, index) {
                          final isLastExtra = index == items.length;

                          return DotIndicator(
                            color:
                                isLastExtra
                                    ? AppColor.lightBlue
                                    : AppColor.primary,
                            size: 16,
                          );
                        },

                        /// 🔵 / ⚪ Connector
                        connectorBuilder: (context, index, type) {
                          final isBeforeLast = index == items.length;

                          return SolidLineConnector(
                            color:
                                isBeforeLast
                                    ? AppColor.lightBlue
                                    : AppColor.primary,
                            thickness: 2,
                          );
                        },

                        // Content
                        contentsBuilder: (context, index) {
                          // EXTRA LAST DOT
                          if (index == items.length) {
                            final firstFollowUp = items[0];

                            return Padding(
                              padding: const EdgeInsets.only(
                                left: 12,
                                bottom: 24,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    dateFormatterDDMMYYYYDAY(
                                      firstFollowUp.nextFollowUpDate!,
                                      isDayNotRequired: true,
                                    ),
                                    style: AppTextStyle.ts12M(
                                      color: AppColor.grey,
                                    ),
                                  ),
                                  Text(
                                    "Next Follow-up",
                                    style: AppTextStyle.ts12M(
                                      color: AppColor.grey,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          // NORMAL FOLLOWUPS
                          final followUp = items[index];

                          return Padding(
                            padding: const EdgeInsets.only(
                              left: 12,
                              bottom: 24,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: RichText(
                                        text: TextSpan(
                                          text: dateFormatterDDMMYYYYDAY(
                                            followUp.createdDate!,
                                          ),
                                          style: AppTextStyle.ts12M(
                                            color: AppColor.black,
                                          ),
                                          children: [
                                            const TextSpan(text: "  "),
                                            TextSpan(
                                              text: dateFormatterHhMmAm(
                                                followUp.createdDate!,
                                              ),
                                              style: AppTextStyle.ts12M(
                                                color: AppColor.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    if (index == 0 &&
                                        followUp.status.toLowerCase() !=
                                            'booking done' &&
                                        followUp.status.toLowerCase() !=
                                            'cancelled')
                                      Row(
                                        spacing: 5,
                                        children: [
                                          CustomIconButton.edit(
                                            onPressed: () {
                                              _showStatusBottomSheet(
                                                context,
                                                followUpModel: followUp,
                                                index: index,
                                              );
                                            },
                                          ),
                                          CustomIconButton.delete(
                                            onPressed: () {
                                              _showPopupToDeleteFollowUp(
                                                index: index,
                                                followUpModel: followUp,
                                                enquiryId:
                                                    widget
                                                        .enquiryModel
                                                        .enquiryId,
                                                context: context,
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                                verticalSpacing(height: 4),

                                // Status chip
                                statusWidget(followUp.status),

                                Text(
                                  followUp.remark,
                                  style: AppTextStyle.ts14R(),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget statusWidget(String status) {
    final trimmed = status.trim();

    // If empty → show dash
    if (trimmed.isEmpty) {
      return statusChip("-", AppColor.lightGreyBackground, AppColor.black);
    }

    final s = trimmed.toLowerCase();

    switch (s) {
      case 'booking done':
        return statusChip(status, AppColor.green20, AppColor.green);

      case 'blocked':
        return statusChip(status, AppColor.purple20, AppColor.purple);

      case 'cancelled':
        return statusChip(status, AppColor.black10, AppColor.darkGrey);

      case 'negotiation':
        return statusChip(status, AppColor.lightYellow, AppColor.brown);

      case 'lost':
        return statusChip(status, AppColor.lightRed, AppColor.red);

      case 'retention':
        return statusChip(status, AppColor.lightBlue2, AppColor.info);

      case 're - visit scheduled':
        return statusChip(status, AppColor.lightGreenBg, AppColor.darkGreen);

      case 're - visit proposed':
        return statusChip(status, AppColor.lightOrangenBg, AppColor.orange);

      case 'site visit':
        return statusChip(
          status,
          AppColor.lightRed,
          AppColor.priorityHighColor,
        );

      case 'unit selection / blocked':
        return statusChip(
          status,
          AppColor.lightRed,
          AppColor.priorityHighColor,
        );

      default:
        return statusChip(status, AppColor.lightGreyBackground, AppColor.black);
    }
  }

  Future<void> _showStatusBottomSheet(
    BuildContext context, {
    EnquiryFollowUpModel? followUpModel,
    int? index,
  }) async {
    // ===================== PREFILL FOR EDIT =====================
    if (followUpModel != null) {
      _selectedStatus = _statusList.firstWhere(
        (e) => e['DisplayName'] == followUpModel.status,
        orElse: () => {},
      );

      _selectedLostReason =
          (followUpModel.lostReason != null)
              ? _lostReasonList.firstWhere(
                (e) => e['DisplayName'] == followUpModel.lostReason,
                orElse: () => {},
              )
              : null;

      _remarkC.text = followUpModel.remark ?? "";
      _nextFollowupDate = followUpModel.nextFollowUpDate;
    }

    // ===================== STATUS IDs THAT REQUIRE NEXT FOLLOWUP DATE =====================
    final followUpStatusIds = [
      1, // Site Visit
      2, // Re-Visit Proposed
      3, // Re-Visit Scheduled
      4, // Negotiation
      5, // Unit Selection / Blocked
      6, // Blocked
      8, // Retention
    ];

    await DialogHelper.showCustomBottomSheet(
      context,
      index != null ? "Update Follow Up" : "Add Follow Up",
      StatefulBuilder(
        builder: (context, setState) {
          final statusId = _selectedStatus?['zAttributesId'];
          final statusName = _selectedStatus?['DisplayName'];

          // ===================== CONDITIONAL WIDGETS =====================
          Widget followUpDateWidget() =>
              (statusId != null && followUpStatusIds.contains(statusId))
                  ? CustomDatePicker(
                    title: "Next Followup Date",
                    initialDate: _nextFollowupDate,
                    setValue:
                        (date) => setState(() => _nextFollowupDate = date),
                    validator:
                        (value) =>
                            value == null ? "Next Followup Date is req" : null,
                  )
                  : const SizedBox.shrink();

          Widget lostReasonWidget() =>
              (statusName == "Lost")
                  ? CustomDropDownWidget(
                    title: "Lost Reason",
                    isRequired: true,
                    dataList: _lostReasonList,
                    initialValue: _selectedLostReason,
                    onSelected:
                        (val) => setState(() => _selectedLostReason = val),
                    validator:
                        (val) => val == null ? "Lost reason is required" : null,
                  )
                  : const SizedBox.shrink();

          // ===================== FORM =====================
          return Form(
            key: _statusFormKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // --- Status dropdown ---
                  CustomDropDownWidget(
                    title: "Status",
                    isRequired: true,
                    dataList: _statusList,
                    initialValue: _selectedStatus,
                    onSelected:
                        (val) => setState(() {
                          _selectedStatus = val;
                          _selectedLostReason = null;
                          _nextFollowupDate = null;
                        }),
                    validator:
                        (val) => val == null ? "Status is required" : null,
                  ),

                  // --- Conditional fields ---
                  followUpDateWidget(),
                  lostReasonWidget(),

                  // --- Remark ---
                  CustomTextField(
                    title: 'Remark',
                    hint: "Enter remark",
                    textController: _remarkC,
                    maxLines: 3,
                    validator:
                        (val) =>
                            val == null || val.trim().isEmpty
                                ? "Remark is required"
                                : null,
                  ),
                  // --- Save / Update button ---
                  CustomButton(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    text: index != null ? "Update" : "Save",
                    onPressed: () {
                      if (!_statusFormKey.currentState!.validate()) return;

                      _submitForm(followUpModel: followUpModel, index: index);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    _clearStatusSheet();
  }

  void _clearStatusSheet() {
    _selectedStatus = null;
    _selectedLostReason = null;
    _nextFollowupDate = null;
    _remarkC.clear();
  }

  void _submitForm({EnquiryFollowUpModel? followUpModel, int? index}) {
    if (!_statusFormKey.currentState!.validate()) return;

    final statusName = _selectedStatus?['DisplayName'];
    final lostReasonName = _selectedLostReason?['DisplayName'];

    final payload = {
      "EnquiryFollowUpId":
          (index != null) ? followUpModel!.enquiryFollowUpId : 0,

      if (index != null) "Uniquekey": followUpModel!.uniquekey ?? "",

      "EnquiryId": widget.enquiryModel.enquiryId,
      "ProjectId": getProject().projectId,

      "Status": statusName ?? "",
      "LostReason": statusName == "Lost" ? lostReasonName ?? "" : "",

      "NextFollowUpDate":
          _nextFollowupDate != null ? _nextFollowupDate!.toIso8601String() : "",

      "Remark": _remarkC.text,
    };

    _enquiryCubit.addUpdateEnquiryFollowUp(
      context: context,
      body: payload,
      index: index,
    );
  }

  Future<void> _showPopupToDeleteFollowUp({
    required int index,
    required EnquiryFollowUpModel followUpModel,
    required int enquiryId,

    required BuildContext context,
  }) async {
    // Show confirmation dialog
    var result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete this Follow-Up?',
      'Deleting this Follow-Up will permanently remove its contents.',
    );

    // If user confirms and context is still valid
    if (result && context.mounted) {
      _enquiryCubit.deleteFollowUp(
        index: index,
        followUpModel: followUpModel,
        enquiryId: enquiryId,
        context: context,
      );
    }
  }
}
