import 'dart:async';
import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/business_development/building/data/model/building.model.dart';
import 'package:k3h_erp_app/features/business_development/building/data/repository/building.repository.dart';
import 'package:k3h_erp_app/features/business_development/temporary_alternate_accommodation/data/model/temporary_alternate_accommodation.model.dart';
import 'package:k3h_erp_app/features/business_development/temporary_alternate_accommodation/presentation/cubit/temporary_alternate_accommodation_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/functions/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/chip_style_tab_bar.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_multi_select_pop_up.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class TemporaryAlternateAccommodationScreen extends StatefulWidget {
  const TemporaryAlternateAccommodationScreen({super.key});
  @override
  State<TemporaryAlternateAccommodationScreen> createState() =>
      _TemporaryAlternateAccommodationScreenState();
}

class _TemporaryAlternateAccommodationScreenState
    extends State<TemporaryAlternateAccommodationScreen>
    with TickerProviderStateMixin {
  // CUBIT
  late TemporaryAlternateAccommodationCubit
  _temporaryAlternateAccommodationCubit;
  // PROJECT
  late ProjectModel _project;
  // TAB CONTROLLERS
  late TabController _tabController;
  late TabController _tenureTabController;
  // BUILDING SELECTION
  final ValueNotifier<List<Map<String, dynamic>>> _selectedBuildingNotifier =
      ValueNotifier([]);
  // PAGINATION
  late ScrollController _scrollController;
  Timer? _debounce;
  // STATIC TAB LIST
  final List<String> tabTitles = [
    'Additional TAA',
    'TAA',
    'Hardship',
    'Brokerage',
    'Shifting',
  ];

  final BuildingRepository _buildingRepository =
      serviceLocator<BuildingRepository>();

  @override
  void initState() {
    super.initState();
    _temporaryAlternateAccommodationCubit =
        context.read<TemporaryAlternateAccommodationCubit>();
    _project = getProject();
    _tabController = TabController(length: 5, vsync: this);
    _tenureTabController = TabController(length: 0, vsync: this);
    _tabController.addListener(_handleTabChange);
    _tenureTabController.addListener(_handleTenureTabChange);
    _initializeScrollController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _tenureTabController.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // INITIALIZE SCROLL CONTROLLER
  void _initializeScrollController() {
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      final state = _temporaryAlternateAccommodationCubit.state;
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 100 &&
          !(state.isLoading ?? false) &&
          state.rentList.length < state.totalNumberOfRecord &&
          state.currentPage * 5 < state.totalNumberOfRecord) {
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          if (mounted) {
            final currentState = _temporaryAlternateAccommodationCubit.state;
            if (!(currentState.isLoading ?? false) &&
                currentState.rentList.length <
                    currentState.totalNumberOfRecord) {
              final int tabIndex = _tabController.index;
              final String tabName = tabTitles[tabIndex];
              final int projectId = _project.projectId;
              final int? buildingId =
                  _selectedBuildingNotifier.value.isNotEmpty
                      ? _selectedBuildingNotifier.value.first['zAttributesId']
                      : null;
              if (buildingId != null) {
                final String selectedTenure = currentState.selectedTenure;
                _temporaryAlternateAccommodationCubit.pullChargesDetails(
                  context: context,
                  pageNumber: currentState.currentPage + 1,
                  projectId: projectId,
                  buildingId: buildingId,
                  chargeName: tabName,
                  tenure: selectedTenure,
                );
              }
            }
          }
        });
      }
    });
  }

  // HANDLE TAB CHANGES
  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      final int tabIndex = _tabController.index;
      final String tabName = tabTitles[tabIndex];
      final int projectId = _project.projectId;
      final int? buildingId =
          _selectedBuildingNotifier.value.isNotEmpty
              ? _selectedBuildingNotifier.value.first['zAttributesId']
              : null;
      if (buildingId != null) {
        _temporaryAlternateAccommodationCubit.onTabChanged(
          tabIndex,
          context,
          projectId: projectId,
          buildingId: buildingId,
          tabName: tabName,
          tenure: "",
        );
      }
    }
  }

  // HANDLE TENURE TAB CHANGES
  void _handleTenureTabChange() {
    if (!_tenureTabController.indexIsChanging) {
      final int tenureIndex = _tenureTabController.index;
      final List<String> tenureList =
          _temporaryAlternateAccommodationCubit.state.tenureList;
      if (tenureIndex >= 0 && tenureIndex < tenureList.length) {
        final String selectedTenure = tenureList[tenureIndex];
        final int tabIndex = _tabController.index;
        final String tabName = tabTitles[tabIndex];
        final int projectId = _project.projectId;
        final int? buildingId =
            _selectedBuildingNotifier.value.isNotEmpty
                ? _selectedBuildingNotifier.value.first['zAttributesId']
                : null;
        if (buildingId != null) {
          final String tenureForApi = "Tenure $selectedTenure";
          _temporaryAlternateAccommodationCubit.onTenureChanged(
            context,
            projectId: projectId,
            buildingId: buildingId,
            tabName: tabName,
            tenure: tenureForApi,
            tenureIndex: tenureIndex,
          );
        }
      }
    }
  }

  // UPDATE TENURE TAB CONTROLLER
  void _updateTenureTabController(int length, {int? initialIndex}) {
    if (_tenureTabController.length != length) {
      _tenureTabController.removeListener(_handleTenureTabChange);
      _tenureTabController.dispose();
      int safeInitialIndex = 0;
      if (initialIndex != null && initialIndex >= 0 && length > 0) {
        safeInitialIndex = initialIndex < length ? initialIndex : 0;
      }
      _tenureTabController = TabController(
        length: length,
        vsync: this,
        initialIndex: safeInitialIndex,
      );
      _tenureTabController.addListener(_handleTenureTabChange);
      if (length > 0 && safeInitialIndex > 0 && safeInitialIndex < length) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _tenureTabController.length == length) {
            _tenureTabController.animateTo(safeInitialIndex);
          }
        });
      }
    }
  }

  // FETCH BUILDINGS
  Future<Map<String, dynamic>> _fetchBuildings(
    int pageNumber, {
    String? value,
  }) async {
    final result = await _buildingRepository.pullBuilding(
      pageNumber: pageNumber,
      pageSize: 15,
      projectId: _project.projectId,
      queryParams:
          value != null && value.isNotEmpty
              ? {"BuildingName": value, "isCheckPermission": false}
              : {"isCheckPermission": false},
    );
    return result.fold(
      (failure) => {
        "itemList": <Map<String, dynamic>>[],
        "totalNumberOfRecord": 0,
      },
      (response) {
        final project =
            response['data'] as List<BusinessDevelopmentBuildingModel>;
        return {
          "itemList":
              project.map((pr) {
                return {
                  "zAttributesId": pr.buildingId,
                  "DisplayName": pr.buildingName,
                };
              }).toList(),
          "totalNumberOfRecord": response['totalNumberOfRecord'] ?? 0,
        };
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Temporary Alternate\nAccommodation",
        authorization: AuthorizationModel(),
        isMenuButton: true,
        onProjectChangeCallback: (project) {
          _project = project;
        },
      ),
      body: Column(
        children: [
          verticalSpacing(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: BlocBuilder<
              TemporaryAlternateAccommodationCubit,
              TemporaryAlternateAccommodationState
            >(
              bloc: _temporaryAlternateAccommodationCubit,
              builder: (context, state) {
                return ValueListenableBuilder<List<Map<String, dynamic>>>(
                  valueListenable: _selectedBuildingNotifier,
                  builder: (context, selectedBuilding, child) {
                    return CustomMultipleSelectPopup(
                      title: "Building",
                      isRequired: true,
                      isMultiSelect: false,
                      initialValue: selectedBuilding,
                      dataList: const [],
                      onSelected: (value) async {
                        _selectedBuildingNotifier.value = value;
                        if (value.isNotEmpty &&
                            value.first['zAttributesId'] != null &&
                            mounted) {
                          final int buildingId = value.first['zAttributesId'];
                          final int projectId = _project.projectId;
                          await _temporaryAlternateAccommodationCubit
                              .pullTemporaryAccommodationAlternativeDetails(
                                context: context,
                                projectId: projectId,
                                buildingId: buildingId,
                              );
                          final int tabIndex = _tabController.index;
                          final String tabName = tabTitles[tabIndex];
                          if (context.mounted) {
                            _temporaryAlternateAccommodationCubit.onTabChanged(
                              tabIndex,
                              context,
                              projectId: projectId,
                              buildingId: buildingId,
                              tabName: tabName,
                              tenure: "",
                            );
                          }
                          _updateTenureTabController(0);
                        }
                      },
                      dataFetchCallBack: _fetchBuildings,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Building is required";
                        }
                        return null;
                      },
                    );
                  },
                );
              },
            ),
          ),

          Expanded(
            child: ValueListenableBuilder<List<Map<String, dynamic>>>(
              valueListenable: _selectedBuildingNotifier,
              builder: (context, selectedBuilding, child) {
                final bool isBuildingSelected = selectedBuilding.isNotEmpty;
                if (!isBuildingSelected) {
                  return Center(
                    child: Text(
                      'Please select a building',
                      style: AppTextStyle.ts14R(color: AppColor.grey),
                    ),
                  );
                }
                return Column(
                  children: [
                    // MAIN TAB BAR
                    ChipStyleTabBar(
                      controller: _tabController,
                      tabs: tabTitles,
                    ),
                    // TENURE TAB BAR
                    BlocBuilder<
                      TemporaryAlternateAccommodationCubit,
                      TemporaryAlternateAccommodationState
                    >(
                      bloc: _temporaryAlternateAccommodationCubit,
                      builder: (context, state) {
                        final int currentTabIndex = _tabController.index;
                        final bool showTenureTabs =
                            currentTabIndex == 1 || currentTabIndex == 3;
                        final List<String> tenureList = state.tenureList;
                        if (showTenureTabs && tenureList.isNotEmpty) {
                          if (_tenureTabController.length !=
                              tenureList.length) {
                            _updateTenureTabController(
                              tenureList.length,
                              initialIndex:
                                  state.selectedTenureIndex >= 0 &&
                                          state.selectedTenureIndex <
                                              tenureList.length
                                      ? state.selectedTenureIndex
                                      : 0,
                            );
                          }
                        } else {
                          if (_tenureTabController.length != 0) {
                            _updateTenureTabController(0);
                          }
                        }
                        if (showTenureTabs &&
                            tenureList.isNotEmpty &&
                            _tenureTabController.length == tenureList.length &&
                            _tenureTabController.length > 0) {
                          return ChipStyleTabBar(
                            controller: _tenureTabController,
                            style: ChipTabBarStyle.underline,
                            tabs:
                                tenureList
                                    .map((tenure) => "Tenure $tenure")
                                    .toList(),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    // TAB CONTENT
                    Expanded(
                      child: TabBarView(
                        physics: NeverScrollableScrollPhysics(),
                        controller: _tabController,
                        children: [
                          _buildRentListWidget(), // Additional Rent
                          _buildRentListWidget(), // Rent
                          _buildRentListWidget(), // Corpus
                          _buildRentListWidget(), // Brokerage
                          _buildRentListWidget(), // Shifting
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // HELPER FUNCTIONS
  Widget _amountColumn({
    required String title,
    required num amount,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyle.ts12M(color: AppColor.grey)),
        const SizedBox(height: 2),
        Text(
          amount.toIndianCurrency(),
          style: AppTextStyle.ts14SB(color: color),
        ),
      ],
    );
  }

  // BUILD COMMON RENT TAB CARD
  Widget _buildRentTABExpansionTileCard({
    required String tabName,
    required String flatNumber,
    required num totalAmount,
    required num paidAmount,
    required Widget expandedContent,
    VoidCallback? onAddPayment,
    VoidCallback? onViewPayment,
  }) {
    final ValueNotifier<bool> isExpanded = ValueNotifier(false);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: commonCardDecoration(),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ValueListenableBuilder<bool>(
          valueListenable: isExpanded,
          builder: (context, expanded, _) {
            return ExpansionTile(
              key: PageStorageKey(flatNumber),
              initiallyExpanded: expanded,
              onExpansionChanged: (value) => isExpanded.value = value,
              // HIDE DEFAULT ARROW
              trailing: const SizedBox.shrink(),
              tilePadding: const EdgeInsets.fromLTRB(16, 12, 0, 8),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              // CUSTOM HEADER
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(flatNumber, style: AppTextStyle.ts16M()),
                      ),
                      InkWell(
                        onTap: () {
                          isExpanded.value = !expanded;
                        },
                        child: AnimatedRotation(
                          turns: expanded ? 0.5 : 0.0,
                          duration: const Duration(milliseconds: 200),
                          child: const Icon(
                            Icons.keyboard_arrow_down,
                            size: 26,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // TOTAL & PAID
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _amountColumn(
                        title: 'Total',
                        amount: totalAmount,
                        color: AppColor.slightDarkBlue,
                      ),
                      _amountColumn(
                        title: 'Paid',
                        amount: paidAmount,
                        color: Colors.green,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Action Buttons
                  Row(
                    children: [
                      if (totalAmount != paidAmount) ...[
                        CustomButton(
                          onPressed: onAddPayment,
                          text: "Add Payment",
                        ),
                        horizontalSpacing(),
                      ],
                      CustomButton(
                        onPressed: onViewPayment,
                        text: "View Summary",
                      ),
                    ],
                  ),
                ],
              ),
              children: [expandedContent],
            );
          },
        ),
      ),
    );
  }

  // BUILD COMMON RENT LIST WIDGET
  Widget _buildRentListWidget() {
    return BlocBuilder<
      TemporaryAlternateAccommodationCubit,
      TemporaryAlternateAccommodationState
    >(
      bloc: _temporaryAlternateAccommodationCubit,
      builder: (context, state) {
        if ((state.isLoading ?? false) && state.rentList.isEmpty) {
          return Center(child: loader());
        }
        if (state.rentList.isEmpty) {
          return Center(child: noDataWidget());
        }
        final int currentTabIndex = _tabController.index;
        final String tabName = tabTitles[currentTabIndex];
        List<TemporaryAlternativeAccommodationModel> filteredList =
            state.rentList;
        if ((currentTabIndex == 1 || currentTabIndex == 3) &&
            state.selectedTenure.isNotEmpty) {
          filteredList =
              state.rentList
                  .where((e) => e.tenure == state.selectedTenure)
                  .toList();
        }
        final groupedByTenant = groupBy(filteredList, (e) => e.tenantId);
        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: groupedByTenant.length + 1,
          itemBuilder: (context, index) {
            if (index == groupedByTenant.length) {
              return state.rentList.length < state.totalNumberOfRecord
                  ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                  : const SizedBox.shrink();
            }
            final entry = groupedByTenant.entries.elementAt(index);
            final tenantRecords = entry.value;
            // BUILD CARD BASED ON TAB NAME
            switch (tabName) {
              case 'TAA':
                return _buildTAACard(tenantRecords, state, tabName);
              case 'Hardship':
                return _buildCorpusCard(tenantRecords);
              case 'Brokerage':
                return _buildBrokerageCard(tenantRecords);
              case 'Shifting':
                return _buildShiftingCard(tenantRecords);
              case 'Additional TAA':
              default:
                return _buildAdditionalRentCard(tenantRecords);
            }
          },
        );
      },
    );
  }

  // COMMON EXPANSION TILE CARD
  Widget _buildExpansionTileCard({
    required String flatNumber,
    required Widget expandedContent,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: commonCardDecoration(),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Text(flatNumber, style: AppTextStyle.ts16M()),
          children: [expandedContent],
        ),
      ),
    );
  }

  // BUILD ADDITIONAL RENT CARD
  Widget _buildAdditionalRentCard(
    List<TemporaryAlternativeAccommodationModel> tenantRecords,
  ) {
    return BlocBuilder<
      TemporaryAlternateAccommodationCubit,
      TemporaryAlternateAccommodationState
    >(
      bloc: _temporaryAlternateAccommodationCubit,
      builder: (context, state) {
        final first = tenantRecords.first;
        // CALCULATE TOTAL AMOUNT
        final totalAmount = tenantRecords.fold<num>(
          0,
          (sum, r) => sum + r.amount,
        );
        // Find paid amount (date year == 1997, month == 1, day == 2)
        final paidRecord = state.rentList.firstWhereOrNull((e) {
          try {
            final date = DateTime.parse(e.date.toString());
            return date.year == 1997 &&
                date.month == 1 &&
                date.day == 2 &&
                e.tenantId == first.tenantId;
          } catch (_) {
            return false;
          }
        });
        final paidAmount = paidRecord?.amount ?? 0.0;
        return _buildExpansionTileCard(
          flatNumber: first.flatNumber,
          expandedContent: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Divider(color: AppColor.grey, thickness: .5),
              _buildInfoRow("Applicant Name", first.applicantName),
              _buildInfoRow("Flat Type", first.flatType),
              _buildInfoRow("Flat Configuration", first.flatConfiguration),
              _buildInfoRow(
                "Carpet Area (SqFt)",
                first.flatCarpetAreaSqFt.toStringAsFixed(2),
              ),
              _buildInfoRow(
                "Proposed Offer Amount",
                first.proposedOfferAmount.toString(),
              ),
              Divider(color: AppColor.grey, thickness: .5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total', style: AppTextStyle.ts16M()),
                  Text(
                    totalAmount.toIndianCurrency(),
                    style: AppTextStyle.ts16SB(color: AppColor.slightDarkBlue),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Paid', style: AppTextStyle.ts16M()),
                  Text(
                    paidAmount.toIndianCurrency(),
                    style: AppTextStyle.ts16SB(color: Colors.green),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // BUILD TAA LIST WIDGET
  Widget _buildTAACard(
    List<TemporaryAlternativeAccommodationModel> tenantRecords,
    TemporaryAlternateAccommodationState state,
    String tabName,
  ) {
    final first = tenantRecords.first;
    final dateRange =
        tenantRecords
            .map((e) => DateTime.parse(e.date.toString()))
            .toSet()
            .toList()
          ..sort((a, b) => a.compareTo(b));
    final totalRecord = state.rentList.firstWhereOrNull((e) {
      try {
        final date = DateTime.parse(e.date.toString());
        return date.year == 1997 &&
            date.month == 1 &&
            date.day == 1 &&
            e.tenantId == first.tenantId;
      } catch (_) {
        return false;
      }
    });
    final totalAmount = totalRecord?.amount ?? 0.0;
    final paidRecord = state.rentList.firstWhereOrNull((e) {
      try {
        final date = DateTime.parse(e.date.toString());
        return date.year == 1997 &&
            date.month == 1 &&
            date.day == 2 &&
            e.tenantId == first.tenantId;
      } catch (_) {
        return false;
      }
    });
    final paidAmount = paidRecord?.amount ?? 0.0;
    return _buildRentTABExpansionTileCard(
      tabName: tabName,
      flatNumber: first.flatNumber,
      totalAmount: totalAmount,
      paidAmount: paidAmount,
      onAddPayment: () {
        final rentModelEnc = Uri.encodeQueryComponent(
          EncryptionManager.encryptData(jsonEncode(first.toJson())),
        );
        final rentDetailsEnc = Uri.encodeQueryComponent(
          EncryptionManager.encryptData(
            jsonEncode(state.rentDetails.map((e) => e.toJson()).toList()),
          ),
        );
        goRouter.pushNamed(
          AppRoutes.addPayment,
          queryParameters: <String, String>{
            'totalAmount': totalAmount.toString(),
            'paidAmount': paidAmount.toString(),
            'buildingId': first.buildingId.toString(),
            'rentModel': rentModelEnc,
            'rentDetails': rentDetailsEnc,
          },
          extra: <String, dynamic>{
            'buildingId': first.buildingId,
            'rentDetails': state.rentDetails,
            'rentModel': first,
            'totalAmount': totalAmount.toDouble(),
            'paidAmount': paidAmount.toDouble(),
          },
        );
      },
      onViewPayment: () async {
        final rentModelEnc = Uri.encodeQueryComponent(
          EncryptionManager.encryptData(jsonEncode(first.toJson())),
        );
        await goRouter.pushNamed(
          AppRoutes.viewSummary,
          queryParameters: <String, String>{'rentModel': rentModelEnc},
          extra: {'rentModel': first},
        );
        if (mounted) {
          await _temporaryAlternateAccommodationCubit.pullChargesDetails(
            context: context,
            pageNumber: state.currentPage,
            projectId: first.projectId,
            buildingId: first.buildingId,
            chargeName: tabName,
            tenure: first.tenure,
          );
        }
      },
      expandedContent: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: AppColor.grey, thickness: 0.5),
          _buildInfoRow("Applicant Name", first.applicantName),
          _buildInfoRow("Flat Type", first.flatType),
          _buildInfoRow("Flat Configuration", first.flatConfiguration),
          _buildInfoRow(
            "Carpet Area (SqFt)",
            first.flatCarpetAreaSqFt.toStringAsFixed(2),
          ),
          _buildInfoRow(
            "Proposed Offer Amount",
            '${first.proposedOfferAmount} ${first.unit}',
          ),
          Divider(color: AppColor.grey, thickness: 0.5),
          // DATE WISE AMOUNT ( EXCLUDE 1997-01-01 AND 1997-01-02 )
          ...dateRange
              .where(
                (date) =>
                    !(date.year == 1997 &&
                        date.month == 1 &&
                        (date.day == 1 || date.day == 2)),
              )
              .map((date) {
                final match = tenantRecords.firstWhereOrNull((r) {
                  final rDate = DateTime.parse(r.date.toString());
                  return rDate.year == date.year &&
                      rDate.month == date.month &&
                      rDate.day == date.day;
                });
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('dd MMM yyyy').format(date),
                        style: AppTextStyle.ts14M(),
                      ),
                      Text(
                        match?.amount != null && match?.amount != 0
                            ? match!.amount.toIndianCurrency()
                            : '-',
                        style: AppTextStyle.ts14B(),
                      ),
                    ],
                  ),
                );
              }),
        ],
      ),
    );
  }

  // BUILD CORPUS CARD
  Widget _buildCorpusCard(
    List<TemporaryAlternativeAccommodationModel> tenantRecords,
  ) {
    return BlocBuilder<
      TemporaryAlternateAccommodationCubit,
      TemporaryAlternateAccommodationState
    >(
      bloc: _temporaryAlternateAccommodationCubit,
      builder: (context, state) {
        final first = tenantRecords.first;
        final allStages =
            state.rentList
                .map((e) => e.stage)
                .where((s) => s.isNotEmpty)
                .toSet()
                .toList();
        final stageMap = {for (var e in tenantRecords) e.stage: e.amount};
        final totalAmount = stageMap.values.fold<num>(
          0,
          (sum, amount) => sum + amount,
        );
        // Find paid amount (date year == 1997, month == 1, day == 2)
        final paidRecord = state.rentList.firstWhereOrNull((e) {
          try {
            final date = DateTime.parse(e.date.toString());
            return date.year == 1997 &&
                date.month == 1 &&
                date.day == 2 &&
                e.tenantId == first.tenantId;
          } catch (_) {
            return false;
          }
        });
        final paidAmount = paidRecord?.amount ?? 0.0;
        return _buildExpansionTileCard(
          flatNumber: first.flatNumber,
          expandedContent: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Divider(color: AppColor.grey, thickness: 0.5),
              _buildInfoRow("Applicant Name", first.applicantName),
              _buildInfoRow("Flat Type", first.flatType),
              _buildInfoRow("Flat Configuration", first.flatConfiguration),
              _buildInfoRow(
                "Carpet Area (SqFt)",
                first.flatCarpetAreaSqFt.toStringAsFixed(2),
              ),
              Divider(color: AppColor.grey, thickness: 0.5),
              ...allStages.map((stageName) {
                final amount = stageMap[stageName] ?? 0.0;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: _buildInfoRow(
                    stageName,
                    amount > 0 ? (amount).toIndianCurrency() : '0',
                  ),
                );
              }),
              Divider(color: AppColor.grey, thickness: 0.5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total', style: AppTextStyle.ts16M()),
                  Text(
                    totalAmount.toIndianCurrency(),
                    style: AppTextStyle.ts16SB(color: AppColor.slightDarkBlue),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Paid', style: AppTextStyle.ts16M()),
                  Text(
                    paidAmount.toIndianCurrency(),
                    style: AppTextStyle.ts16SB(color: Colors.green),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // BUILD BROKERAGE CARD
  Widget _buildBrokerageCard(
    List<TemporaryAlternativeAccommodationModel> tenantRecords,
  ) {
    return BlocBuilder<
      TemporaryAlternateAccommodationCubit,
      TemporaryAlternateAccommodationState
    >(
      bloc: _temporaryAlternateAccommodationCubit,
      builder: (context, state) {
        final first = tenantRecords.first;
        final totalAmount = tenantRecords.fold<num>(
          0,
          (sum, r) => sum + r.amount,
        );
        // Find paid amount (date year == 1997, month == 1, day == 2)
        final paidRecord = state.rentList.firstWhereOrNull((e) {
          try {
            final date = DateTime.parse(e.date.toString());
            return date.year == 1997 &&
                date.month == 1 &&
                date.day == 2 &&
                e.tenantId == first.tenantId &&
                e.tenure == first.tenure;
          } catch (_) {
            return false;
          }
        });
        final paidAmount = paidRecord?.amount ?? 0.0;
        return _buildExpansionTileCard(
          flatNumber: first.flatNumber,
          expandedContent: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Divider(color: AppColor.grey, thickness: 0.5),
              _buildInfoRow("Applicant Name", first.applicantName),
              _buildInfoRow("Flat Type", first.flatType),
              _buildInfoRow("Flat Configuration", first.flatConfiguration),
              _buildInfoRow(
                "Carpet Area (SqFt)",
                first.flatCarpetAreaSqFt.toStringAsFixed(2),
              ),
              Divider(color: AppColor.grey, thickness: 0.5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total', style: AppTextStyle.ts16M()),
                  Text(
                    totalAmount.toIndianCurrency(),
                    style: AppTextStyle.ts16SB(color: AppColor.slightDarkBlue),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Paid', style: AppTextStyle.ts16M()),
                  Text(
                    paidAmount.toIndianCurrency(),
                    style: AppTextStyle.ts16SB(color: Colors.green),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // BUILD SHIFTING CARD
  Widget _buildShiftingCard(
    List<TemporaryAlternativeAccommodationModel> tenantRecords,
  ) {
    return BlocBuilder<
      TemporaryAlternateAccommodationCubit,
      TemporaryAlternateAccommodationState
    >(
      bloc: _temporaryAlternateAccommodationCubit,
      builder: (context, state) {
        final first = tenantRecords.first;
        final allStages =
            state.rentList
                .map((e) => e.stage)
                .where((s) => s.isNotEmpty)
                .toSet()
                .toList();
        final stageMap = {for (var e in tenantRecords) e.stage: e.amount};
        final totalAmount = stageMap.values.fold<num>(
          0,
          (sum, amount) => sum + amount,
        );
        final paidRecord = state.rentList.firstWhereOrNull((e) {
          try {
            final date = DateTime.parse(e.date.toString());
            return date.year == 1997 &&
                date.month == 1 &&
                date.day == 2 &&
                e.tenantId == first.tenantId;
          } catch (_) {
            return false;
          }
        });
        final paidAmount = paidRecord?.amount ?? 0.0;
        return _buildExpansionTileCard(
          flatNumber: first.flatNumber,
          expandedContent: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Divider(color: AppColor.grey, thickness: 0.5),
              _buildInfoRow("Applicant Name", first.applicantName),
              _buildInfoRow("Flat Type", first.flatType),
              _buildInfoRow("Flat Configuration", first.flatConfiguration),
              _buildInfoRow(
                "Carpet Area (SqFt)",
                first.flatCarpetAreaSqFt.toStringAsFixed(2),
              ),
              _buildInfoRow(
                "Proposed Offer Amount",
                first.proposedOfferAmount.toStringAsFixed(2),
              ),
              Divider(color: AppColor.grey, thickness: 0.5),
              ...allStages.map((stageName) {
                final amount = stageMap[stageName] ?? 0.0;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: _buildInfoRow(
                    stageName,
                    amount > 0 ? '₹ ${amount.toStringAsFixed(2)}' : '0',
                  ),
                );
              }),
              Divider(color: AppColor.grey, thickness: 0.5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total', style: AppTextStyle.ts16M()),
                  Text(
                    totalAmount.toIndianCurrency(),
                    style: AppTextStyle.ts16SB(color: AppColor.slightDarkBlue),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Paid', style: AppTextStyle.ts16M()),
                  Text(
                    paidAmount.toIndianCurrency(),
                    style: AppTextStyle.ts16SB(color: Colors.green),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // HELPER METHODS
  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(title, style: AppTextStyle.ts14R(color: AppColor.grey)),
          ),
          Text(": "),
          Expanded(flex: 3, child: Text(value, style: AppTextStyle.ts14M())),
        ],
      ),
    );
  }
}
