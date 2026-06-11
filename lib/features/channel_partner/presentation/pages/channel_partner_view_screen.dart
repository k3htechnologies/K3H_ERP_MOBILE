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
import 'package:k3h_erp_app/widgets/chip_style_tab_bar.dart';
import 'package:k3h_erp_app/widgets/custom_click_to_contact_widget.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

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

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _teamMembersNotifier.dispose();
    _isLoadingNotifier.dispose();
    super.dispose();
  }

  // INITIALIZE TEAM PAGINATION
  void _initializeTeamPagination() {
    _teamScrollController = ScrollController();
    _teamScrollController.addListener(_onTeamScroll);
  }

  void _onTeamScroll() {
    if (_teamScrollController.position.pixels >=
            _teamScrollController.position.maxScrollExtent - 100 &&
        !_isTeamLoadingMore &&
        _teamMembersNotifier.value.length < _totalTeamRecords) {
      // DEBOUNCE - EXACTLY LIKE LITIGATION SCREEN
      if (_teamDebounce?.isActive ?? false) _teamDebounce?.cancel();
      _teamDebounce = Timer(const Duration(milliseconds: 300), () {
        _loadMoreTeamMembers();
      });
    }
  }

  // LOAD MORE TEAM MEMBERS
  Future<void> _loadMoreTeamMembers() async {
    _isTeamLoadingMore = true;
    try {
      final result = await _channelPartnerRepository.getChannelPartnerList(
        pageNumber: _currentTeamPage + 1,
        pageSize: 20,
        queryParams: {"CompanyName": widget.channelPartnerModel.companyName},
      );

      result.fold(
        (failure) => debugPrint("Load more error: ${failure.message}"),
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

  // TAB CHANGE METHOD
  void _onTabChanged() {
    if (_tabController.index == 1) {
      _pullChannelPartnerMaster();
    }
  }

  // PULL CHANNEL PARTNER MASTER
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
          // TAB BAR
          ChipStyleTabBar(
            controller: _tabController,
            tabs: ["Overview", "Team Members"],
          ),

          // TAB BAR VIEW
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
                      verticalSpacing(height: 5),
                      Text(
                        widget.channelPartnerModel.systemGeneratedCode,
                        style: AppTextStyle.ts16SB(color: AppColor.primary),
                      ),
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
                              style: AppTextStyle.ts16SB(color: AppColor.black),
                            ),
                            verticalSpacing(),
                            Row(
                              spacing: 10,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildColumnTitleValue(
                                  title: "Full Name",
                                  value: widget.channelPartnerModel.name,
                                ),
                                buildColumnTitleValue(
                                  title: "DOB",
                                  value:
                                      widget.channelPartnerModel.dob != null
                                          ? formatDateTimeAsDDMMMYYYY(
                                            widget.channelPartnerModel.dob!,
                                          )
                                          : "-",
                                ),
                              ],
                            ),
                            verticalSpacing(),
                            Row(
                              spacing: 10,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildColumnTitleValue(
                                  title: "Mobile No.",
                                  value:
                                      widget.channelPartnerModel.mobileNumber,
                                  customValueWidget: CustomClickToContactText(
                                    value:
                                        "${widget.channelPartnerModel.mobileNumberCountryCode} ${widget.channelPartnerModel.mobileNumber}",
                                    type: ContactType.phone,
                                  ),
                                ),
                                buildColumnTitleValue(
                                  title: "E-Mail ID",
                                  value: widget.channelPartnerModel.emailId,
                                  customValueWidget: CustomClickToContactText(
                                    value: widget.channelPartnerModel.emailId,
                                    type: ContactType.email,
                                  ),
                                ),
                              ],
                            ),
                            verticalSpacing(),
                            Row(
                              spacing: 10,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildColumnTitleValue(
                                  title: "Company Name",
                                  value: widget.channelPartnerModel.companyName,
                                ),
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
                              ],
                            ),
                            verticalSpacing(),
                            Row(
                              spacing: 10,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildColumnTitleValue(
                                  title: "Speciality",
                                  value: widget.channelPartnerModel.speciality,
                                ),
                                buildColumnTitleValue(
                                  title: "Firm Type",
                                  value: widget.channelPartnerModel.firmsType,
                                ),
                              ],
                            ),
                            verticalSpacing(),
                            Row(
                              spacing: 10,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                buildColumnTitleValue(
                                  title: "Type",
                                  value: widget.channelPartnerModel.type,
                                ),
                                buildColumnTitleValue(
                                  title: "Designation",
                                  value: widget.channelPartnerModel.designation,
                                ),
                              ],
                            ),
                            verticalSpacing(),
                            Row(
                              spacing: 10,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                buildColumnTitleValue(
                                  title: "Website URL",
                                  value: widget.channelPartnerModel.websiteURL,
                                  customValueWidget: GestureDetector(
                                    onTap: () async {
                                      final url =
                                          widget.channelPartnerModel.websiteURL;

                                      if (url.isNotEmpty) {
                                        final Uri uri = Uri.parse(url);
                                        if (await canLaunchUrl(uri)) {
                                          await launchUrl(
                                            uri,
                                            mode:
                                                LaunchMode.externalApplication,
                                          );
                                        } else {
                                          debugPrint(
                                            "Could not launch URL: $url",
                                          );
                                        }
                                      }
                                    },
                                    child: Text(
                                      widget
                                              .channelPartnerModel
                                              .websiteURL
                                              .isEmpty
                                          ? "-"
                                          : widget
                                              .channelPartnerModel
                                              .websiteURL,
                                      style: AppTextStyle.ts14M(
                                        color: AppColor.primary,
                                      ).copyWith(
                                        decoration: TextDecoration.underline,
                                        decorationColor: AppColor.primary,
                                      ),
                                    ),
                                  ),
                                ),
                                Spacer(),
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
                              style: AppTextStyle.ts16SB(color: AppColor.black),
                            ),
                            verticalSpacing(),
                            Row(
                              spacing: 10,
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                              style: AppTextStyle.ts16SB(color: AppColor.black),
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
                              style: AppTextStyle.ts16SB(color: AppColor.black),
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
                        padding: EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Column(
                          spacing: 10,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Enquiry, Booking, IBM & OBM Details",
                              style: AppTextStyle.ts16SB(),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildColumnTitleValue(
                                  title: "No Of Enquiry",
                                  value:
                                      widget.channelPartnerModel.noOfEnquiry
                                          .toString(),
                                ),
                                buildColumnTitleValue(
                                  title: "No Of Booking",
                                  value:
                                      widget.channelPartnerModel.noOfBooking
                                          .toString(),
                                ),
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildColumnTitleValue(
                                  title: "Brokerage Percentage (%)",
                                  value:
                                      widget
                                          .channelPartnerModel
                                          .brokeragePercentage
                                          .toString(),
                                ),
                                buildColumnTitleValue(
                                  title: "Brokerage Amount (₹)",
                                  value:
                                      widget.channelPartnerModel.brokerageAmount
                                          .toIndianCurrency(),
                                ),
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildColumnTitleValue(
                                  title: "Paid Brokerage Amount (₹)",
                                  value:
                                      widget
                                          .channelPartnerModel
                                          .paidBrokerageAmount
                                          .toIndianCurrency(),
                                ),
                                buildColumnTitleValue(
                                  title: "No Of IBM",
                                  value:
                                      widget.channelPartnerModel.noOfIbm
                                          .toString(),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                buildColumnTitleValue(
                                  title: "No Of OBM",
                                  value:
                                      widget.channelPartnerModel.noOfObm
                                          .toString(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: commonCardDecoration(),
                        padding: EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Column(
                          spacing: 10,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Primary & Secondary Project Portfolio",
                              style: AppTextStyle.ts16SB(),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildColumnTitleValue(
                                  title: "Primary",
                                  value:
                                      widget
                                          .channelPartnerModel
                                          .primaryProjectPortfolio,
                                ),
                                buildColumnTitleValue(
                                  title: "Secondary",
                                  value:
                                      widget
                                          .channelPartnerModel
                                          .secondaryProjectPortfolio,
                                ),
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildColumnTitleValue(
                                  title: "Micromarket Proximity",
                                  value:
                                      widget
                                          .channelPartnerModel
                                          .micromarketProximity,
                                ),
                                Spacer(),
                              ],
                            ),
                          ],
                        ),
                      ),
                      actionCardWidget(
                        createdBy: widget.channelPartnerModel.createdBy,
                        createdDate: widget.channelPartnerModel.createdDate,
                        modifiedBy: widget.channelPartnerModel.modifiedBy,
                        modifiedDate: widget.channelPartnerModel.modifiedDate,
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
                                    flex: 4,
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
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: CustomClickToContactText(
                                        value:
                                            "${member.mobileNumberCountryCode} ${member.mobileNumber}",
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              verticalSpacing(),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 4,
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
                                            ? Align(
                                              alignment: Alignment.centerRight,
                                              child: CustomClickToContactText(
                                                value: member.emailId,
                                                type: ContactType.email,
                                              ),
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
      return SizedBox(
        height: 180,
        child: Center(
          child: noDataWidget(message: "No Documents Available", iconSize: 100),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
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
