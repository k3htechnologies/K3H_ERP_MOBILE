import 'dart:async';

import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/channel_partner/data/model/channel_partner.model.dart';
import 'package:k3h_erp_app/features/channel_partner/data/repository/channel_partner.repository.dart';
import 'package:k3h_erp_app/features/channel_partner/presentation/pages/widgets/channel_partner_documents_view.dart';
import 'package:k3h_erp_app/features/channel_partner/presentation/pages/widgets/channel_partner_overview.dart';
import 'package:k3h_erp_app/features/channel_partner/presentation/pages/widgets/channel_partner_team_member_view.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/chip_style_tab_bar.dart';
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
    _tabController = TabController(length: 3, vsync: this);
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
        pageSize: 10,
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
    if (_tabController.indexIsChanging) return;
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
        pageSize: 10,
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
          _totalTeamRecords = response["totalNumberOfRecord"];
          _currentTeamPage = 1;
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
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              widget.channelPartnerModel.systemGeneratedCode,
              style: AppTextStyle.ts16SB(color: AppColor.primary),
            ),
          ), // TAB BAR
          verticalSpacing(),
          ChipStyleTabBar(
            controller: _tabController,
            tabs: ["Overview", "Team Members", "Documents"],
          ),

          // TAB BAR VIEW
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                // OVERVIEW TAB
                channelPartnerOverview(widget.channelPartnerModel),
                // TEAM MEMBERS TAB
                AnimatedBuilder(
                  animation: Listenable.merge([
                    _teamMembersNotifier,
                    _isLoadingNotifier,
                    _isLoadingNotifier,
                  ]),
                  builder: (context, _) {
                    return teamMemberTabView(
                      teamMembersNotifier: _teamMembersNotifier,
                      isLoadingNotifier: _isLoadingNotifier,
                      teamScrollController: _teamScrollController,
                      isTeamLoadingMore: _isTeamLoadingMore,
                      totalTeamRecords: _totalTeamRecords,
                    );
                  },
                ),
                channelPartnerDocumentView(
                  channelPartner: widget.channelPartnerModel,
                  context: context,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
