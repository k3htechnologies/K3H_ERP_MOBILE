import 'dart:async';

import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/channel_partner/data/model/channel_partner.model.dart';
import 'package:k3h_erp_app/features/channel_partner/data/repository/channel_partner.repository.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_click_to_contact_widget.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class ChannelPartnerViewScreen extends StatefulWidget {
  final ChannelPartnerModel channelPartnerModel;
  const ChannelPartnerViewScreen({
    super.key,
    required this.channelPartnerModel,
  });

  @override
  State<ChannelPartnerViewScreen> createState() =>
      _ChannelPartnerViewScreenState();
}

class _ChannelPartnerViewScreenState extends State<ChannelPartnerViewScreen>
    with TickerProviderStateMixin {
  final ChannelPartnerRepository _channelPartnerRepository =
      serviceLocator<ChannelPartnerRepository>();
  late final ValueNotifier<List<ChannelPartnerModel>> _teamMembersNotifier;
  late final ValueNotifier<bool> _isLoadingNotifier;
  late TabController _tabController;
  late ScrollController _teamScrollController;
  Timer? _teamDebounce;
  int _currentTeamPage = 1;
  int _totalTeamRecords = 0;
  bool _isTeamLoadingMore = false;
  @override
  void initState() {
    super.initState();
    _teamMembersNotifier = ValueNotifier(<ChannelPartnerModel>[]);
    _isLoadingNotifier = ValueNotifier(false);
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    _initializeTeamPagination();
  }

  void _initializeTeamPagination() {
    _teamScrollController = ScrollController();
    _teamScrollController.addListener(_onTeamScroll);
  }

  void _onTeamScroll() {
    if (_teamScrollController.position.pixels >=
            _teamScrollController.position.maxScrollExtent - 100 &&
        !_isTeamLoadingMore &&
        _teamMembersNotifier.value.length < _totalTeamRecords) {
      // DEBOUNCE - EXACTLY LIKE LITIGATIONSCREEN
      if (_teamDebounce?.isActive ?? false) _teamDebounce?.cancel();
      _teamDebounce = Timer(const Duration(milliseconds: 300), () {
        _loadMoreTeamMembers();
      });
    }
  }

  Future<void> _loadMoreTeamMembers() async {
    _isTeamLoadingMore = true;
    try {
      final result = await _channelPartnerRepository.getChannelPartnerList(
        pageNumber: _currentTeamPage + 1,
        pageSize: 20, // Smaller page size for pagination
        queryParams: {"CompanyName": widget.channelPartnerModel.companyName},
      );

      result.fold(
        (failure) => debugPrint("❌ Load more error: ${failure.message}"),
        (response) {
          final newPartners = List<ChannelPartnerModel>.from(
            response['data'] ?? [],
          );
          final newTeamMembers =
              newPartners
                  .where(
                    (p) =>
                        p.channelPartnerId !=
                        widget.channelPartnerModel.channelPartnerId,
                  )
                  .toList();

          // APPEND to existing list
          final currentTeam = List<ChannelPartnerModel>.from(
            _teamMembersNotifier.value,
          );
          currentTeam.addAll(newTeamMembers);

          _teamMembersNotifier.value = currentTeam;
          _currentTeamPage++;
          _totalTeamRecords = response['totalNumberOfRecord'] ?? 0;
        },
      );
    } finally {
      _isTeamLoadingMore = false;
    }
  }

  void _onTabChanged() {
    if (_tabController.index == 1) {
      _pullChannelPartnerMaster();
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _teamMembersNotifier.dispose();
    _isLoadingNotifier.dispose();
    super.dispose();
  }

  Future<void> _pullChannelPartnerMaster() async {
    _isLoadingNotifier.value = true;
    try {
      final result = await _channelPartnerRepository.getChannelPartnerList(
        pageNumber: 1,
        pageSize: 100,
        queryParams: {"CompanyName": widget.channelPartnerModel.companyName},
      );

      result.fold(
        (failure) {
          _teamMembersNotifier.value = <ChannelPartnerModel>[];
        },
        (response) {
          final List<ChannelPartnerModel> partners =
              List<ChannelPartnerModel>.from(response['data'] ?? []);

          final List<ChannelPartnerModel> teamMembers =
              partners
                  .where(
                    (partner) =>
                        partner.channelPartnerId !=
                        widget.channelPartnerModel.channelPartnerId,
                  )
                  .toList();

          _teamMembersNotifier.value = teamMembers;
        },
      );
    } catch (error) {
      debugPrint("Pull Channel Partner Error: $error");
      _teamMembersNotifier.value = <ChannelPartnerModel>[];
    } finally {
      _isLoadingNotifier.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Channel Partner",
        authorization: AuthorizationModel(),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tab Bar
          IntrinsicWidth(
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
                tabs: [
                  const Tab(text: "Overview"),
                  ValueListenableBuilder<List<ChannelPartnerModel>>(
                    valueListenable: _teamMembersNotifier,
                    builder: (context, teamMembers, child) {
                      return Tab(text: "Team Members");
                    },
                  ),
                ],
              ),
            ),
          ),

          // Tab Bar View
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                // OVERVIEW TAB
                SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      verticalSpacing(),
                      Container(
                        decoration: commonCardDecoration(),
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Basic Details",
                              style: AppTextStyle.ts14M(color: AppColor.grey),
                            ),
                            verticalSpacing(),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildColumnTitleValue(
                                  title: "Full Name",
                                  value: widget.channelPartnerModel.name,
                                ),
                                buildColumnTitleValue(
                                  title: "Contact No.",
                                  value:
                                      widget.channelPartnerModel.mobileNumber,
                                  customValueWidget: CustomClickToContactText(
                                    value:
                                        widget.channelPartnerModel.mobileNumber,
                                    type: ContactType.phone,
                                  ),
                                ),
                              ],
                            ),
                            verticalSpacing(),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildColumnTitleValue(
                                  title: "E-Mail ID",
                                  value: widget.channelPartnerModel.emailId,
                                  customValueWidget: CustomClickToContactText(
                                    value: widget.channelPartnerModel.emailId,
                                    type: ContactType.email,
                                  ),
                                ),
                                buildColumnTitleValue(
                                  title: "Company Name",
                                  value: widget.channelPartnerModel.companyName,
                                ),
                              ],
                            ),
                            verticalSpacing(),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildColumnTitleValue(
                                  title: "Alternate Contact No.",
                                  value:
                                      widget
                                          .channelPartnerModel
                                          .alternativeMobileNumber,
                                  customValueWidget: CustomClickToContactText(
                                    value:
                                        widget
                                            .channelPartnerModel
                                            .alternativeMobileNumber,
                                  ),
                                ),
                                buildColumnTitleValue(
                                  title: "Speciality",
                                  value: widget.channelPartnerModel.speciality,
                                ),
                              ],
                            ),
                            verticalSpacing(),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                buildColumnTitleValue(
                                  title: "Firm Type",
                                  value: widget.channelPartnerModel.firmsType,
                                ),
                                buildColumnTitleValue(
                                  title: "Type",
                                  value: widget.channelPartnerModel.type,
                                ),
                              ],
                            ),
                            verticalSpacing(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                buildColumnTitleValue(
                                  title: "Designation",
                                  value: widget.channelPartnerModel.designation,
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
                              "RERA Details",
                              style: AppTextStyle.ts14M(color: AppColor.grey),
                            ),
                            verticalSpacing(),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                buildColumnTitleValue(
                                  title: "Available RERA No.",
                                  value:
                                      widget
                                              .channelPartnerModel
                                              .reraNumber
                                              .isEmpty
                                          ? "No"
                                          : "Yes",
                                ),
                                buildColumnTitleValue(
                                  title: "RERA Number",
                                  value: widget.channelPartnerModel.reraNumber,
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
                              "Address Details",
                              style: AppTextStyle.ts14M(color: AppColor.grey),
                            ),
                            verticalSpacing(),
                            Row(
                              children: [
                                buildColumnTitleValue(
                                  title: "Country",
                                  value: widget.channelPartnerModel.countryName,
                                ),
                                buildColumnTitleValue(
                                  title: "State",
                                  value: widget.channelPartnerModel.stateName,
                                ),
                              ],
                            ),
                            verticalSpacing(),
                            Row(
                              children: [
                                buildColumnTitleValue(
                                  title: "District",
                                  value:
                                      widget.channelPartnerModel.districtName,
                                ),
                                buildColumnTitleValue(
                                  title: "City",
                                  value: widget.channelPartnerModel.cityName,
                                ),
                              ],
                            ),
                            verticalSpacing(),
                            Row(
                              children: [
                                buildColumnTitleValue(
                                  title: "Village",
                                  value: widget.channelPartnerModel.villageName,
                                ),
                              ],
                            ),
                            verticalSpacing(),
                            Row(
                              children: [
                                buildColumnTitleValue(
                                  title: "Office Address",
                                  value:
                                      widget.channelPartnerModel.officeAddress,
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
                            _buildDocumentCard(
                              context,
                              widget.channelPartnerModel,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: commonCardDecoration(),
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Column(
                          spacing: 10,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Action Details",
                              style: AppTextStyle.ts16SB(),
                            ),
                            Row(
                              spacing: 10,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildColumnTitleValue(
                                  title: "Created By",
                                  value: widget.channelPartnerModel.createdBy,
                                ),
                                buildColumnTitleValue(
                                  title: "Created Date",
                                  value: formatDate(
                                    widget.channelPartnerModel.createdDate,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              spacing: 10,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildColumnTitleValue(
                                  title: "Modified By",
                                  value:
                                      widget
                                              .channelPartnerModel
                                              .modifiedBy
                                              .isNotEmpty
                                          ? widget
                                              .channelPartnerModel
                                              .modifiedBy
                                          : "-",
                                ),
                                buildColumnTitleValue(
                                  title: "Modified Date",
                                  value:
                                      widget.channelPartnerModel.modifiedDate !=
                                              null
                                          ? formatDate(
                                            widget
                                                .channelPartnerModel
                                                .modifiedDate!,
                                          )
                                          : "-",
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // TEAM MEMBERS TAB
                ValueListenableBuilder<List<ChannelPartnerModel>>(
                  valueListenable: _teamMembersNotifier,
                  builder: (context, teamMembers, child) {
                    if (_isLoadingNotifier.value) {
                      return Center(child: loader());
                    }

                    if (teamMembers.isEmpty) {
                      return Center(child: noDataWidget());
                    }

                    return ListView.builder(
                      controller: _teamScrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 20,
                      ),
                      itemCount:
                          teamMembers.length +
                          (_isTeamLoadingMore ||
                                  teamMembers.length >= _totalTeamRecords
                              ? 0
                              : 1),
                      itemBuilder: (context, index) {
                        if (index == teamMembers.length) {
                          return _isTeamLoadingMore
                              ? const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                              : const SizedBox.shrink();
                        }

                        final member = teamMembers[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(16),
                          decoration: commonCardDecoration(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Name & Designation
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    member.name,
                                    style: AppTextStyle.ts16SB(),
                                  ),
                                  Text(
                                    member.designation,
                                    style: AppTextStyle.ts12M(
                                      color: AppColor.grey,
                                    ),
                                  ),
                                ],
                              ),
                              verticalSpacing(),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 7,
                                    child: Text(
                                      "Mobile Number",
                                      style: AppTextStyle.ts14R(
                                        color: AppColor.grey,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      ":",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 6,
                                    child: CustomClickToContactText(
                                      value: member.mobileNumber,
                                    ),
                                  ),
                                ],
                              ),
                              verticalSpacing(),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 7,
                                    child: Text(
                                      "Email ID",
                                      style: AppTextStyle.ts14R(
                                        color: AppColor.grey,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      ":",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 6,
                                    child:
                                        member.emailId.isNotEmpty
                                            ? CustomClickToContactText(
                                              value: member.emailId,
                                              type: ContactType.email,
                                            )
                                            : Text(
                                              "-",
                                              style: AppTextStyle.ts12M(
                                                color: Colors.grey,
                                              ),
                                            ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// DOCUMENT CARD
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
        "title": "Aadhar Card",
        "number": channelPartner.aadharCardNumber,
        "url": channelPartner.aadharCardUrl,
      },
      {
        "title": "GST Certificate",
        "number": channelPartner.gstNumber,
        "url": channelPartner.gstCertificateUrl,
      },
    ];

    final validDocuments =
        documents.where((doc) => (doc["url"] ?? "").isNotEmpty).toList();

    if (validDocuments.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children:
          validDocuments.map((doc) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColor.white,
                border: Border.all(color: AppColor.primary, width: 0.3),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.black.withValues(alpha: 0.05),
                    blurRadius: 2,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doc["title"] ?? "",
                        style: AppTextStyle.ts14M(color: AppColor.grey),
                      ),
                      const SizedBox(height: 8),
                      Text(doc["number"] ?? "", style: AppTextStyle.ts14M()),
                    ],
                  ),
                  CustomButton.documentOutline(
                    onPressed: () {
                      final url = doc["url"] ?? "";
                      if (url.isNotEmpty) {
                        showFilePreviewDialog(context, url.split(","));
                      }
                    },
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }
}
