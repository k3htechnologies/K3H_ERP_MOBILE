import 'dart:async';
import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
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
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/chip_style_tab_bar.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
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
  late AuthorizationModel _routeAuthorizationModel;
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

  final ValueNotifier<int> totalNumberOfRecords = ValueNotifier(0);
  @override
  void initState() {
    super.initState();
    _temporaryAlternateAccommodationCubit =
        context.read<TemporaryAlternateAccommodationCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.rent] ??
        AuthorizationModel();
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

      final int tabIndex = _tabController.index;
      final String tabName = tabTitles[tabIndex];

      final int currentRecordCount =
          state.rentList.map((e) => e.tenantId).toSet().length;

      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 100 &&
          !(state.isLoading ?? false) &&
          currentRecordCount < state.totalNumberOfRecord &&
          state.currentPage * 5 < state.totalNumberOfRecord) {
        if (_debounce?.isActive ?? false) {
          _debounce?.cancel();
        }

        _debounce = Timer(const Duration(milliseconds: 300), () {
          if (!mounted) return;

          final currentState = _temporaryAlternateAccommodationCubit.state;

          final int currentCount =
              currentState.rentList.map((e) => e.tenantId).toSet().length;

          if ((currentState.isLoading ?? false) ||
              currentCount >= currentState.totalNumberOfRecord) {
            return;
          }

          final int? buildingId =
              _selectedBuildingNotifier.value.isNotEmpty
                  ? _selectedBuildingNotifier.value.first['zAttributesId']
                  : null;

          if (buildingId == null) return;

          _temporaryAlternateAccommodationCubit.pullChargesDetails(
            context: context,
            pageNumber: currentState.currentPage + 1,
            projectId: _project.projectId,
            buildingId: buildingId,
            chargeName: tabName,
          );
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
          _temporaryAlternateAccommodationCubit.onTenureChanged(
            context,
            projectId: projectId,
            buildingId: buildingId,
            tabName: tabName,
            tenure: selectedTenure,
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

  TemporaryAlternativeAccommodationModel? _findTotalRecord(
    List<TemporaryAlternativeAccommodationModel> rentList,
    int tenantId, {
    String? tenure,
  }) {
    return rentList.firstWhereOrNull((e) {
      try {
        final date = DateTime.parse(e.date.toString());
        final matchesDate =
            date.year == 1997 && date.month == 1 && date.day == 1;
        final matchesTenant = e.tenantId == tenantId;
        final matchesTenure = tenure == null || e.tenure == tenure;
        return matchesDate && matchesTenant && matchesTenure;
      } catch (_) {
        return false;
      }
    });
  }

  TemporaryAlternativeAccommodationModel? _findPaidRecord(
    List<TemporaryAlternativeAccommodationModel> rentList,
    int tenantId, {
    String? tenure,
  }) {
    return rentList.firstWhereOrNull((e) {
      try {
        final date = DateTime.parse(e.date.toString());
        final matchesDate =
            date.year == 1997 && date.month == 1 && date.day == 2;
        final matchesTenant = e.tenantId == tenantId;
        final matchesTenure = tenure == null || e.tenure == tenure;
        return matchesDate && matchesTenant && matchesTenure;
      } catch (_) {
        return false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<
      TemporaryAlternateAccommodationCubit,
      TemporaryAlternateAccommodationState
    >(
      listener: (context, state) {
        totalNumberOfRecords.value = state.totalNumberOfRecord;
      },
      child: Scaffold(
        appBar: CustomAppBarWithBackButton(
          screenTitle: "Temporary Alternate\nAccommodation",
          authorization: _routeAuthorizationModel,
          isMenuButton: true,
          onProjectChangeCallback: (project) {
            _project = project;
          },
          onExportCallback: (value) {
            if (_project.projectId == 0) {
              showErrorMessage(context, "Error", "Please select a project");
              return;
            } else if (_selectedBuildingNotifier.value.isEmpty) {
              showErrorMessage(context, "Error", "Please select a building");
              return;
            } else if (totalNumberOfRecords.value == 0) {
              showErrorMessage(context, "Error", "No Data Found");
              return;
            }
            _temporaryAlternateAccommodationCubit.exportExcelPdf(
              context,
              value,
              projectId: _project.projectId,
              buildingId:
                  _selectedBuildingNotifier.value.first['zAttributesId'],
              chargeType: tabTitles[_tabController.index],
            );
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
                            final int tabIndex = _tabController.index;
                            final String tabName = tabTitles[tabIndex];
                            if (context.mounted) {
                              _temporaryAlternateAccommodationCubit
                                  .onTabChanged(
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
                              _tenureTabController.length ==
                                  tenureList.length &&
                              _tenureTabController.length > 0) {
                            return ChipStyleTabBar(
                              controller: _tenureTabController,
                              style: ChipTabBarStyle.underline,
                              tabs: tenureList.map((tenure) => tenure).toList(),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                      // TAB CONTENT
                      Expanded(child: _buildRentListWidget()),
                    ],
                  );
                },
              ),
            ),
          ],
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

        if (state.selectedTenure.isNotEmpty) {
          filteredList =
              state.rentList
                  .where((e) => e.tenure == state.selectedTenure)
                  .toList();
        }

        final groupedByTenant = groupBy(
          filteredList,
          (TemporaryAlternativeAccommodationModel e) => e.tenantId,
        );

        final int currentCount =
            state.rentList.map((e) => e.tenantId).toSet().length;

        final bool hasMoreData = currentCount < state.totalNumberOfRecord;

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),

          itemCount: groupedByTenant.length + 1,

          itemBuilder: (context, index) {
            if (index == groupedByTenant.length) {
              if ((state.isLoading ?? false) && hasMoreData) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              return const SizedBox.shrink();
            }

            final entry = groupedByTenant.entries.elementAt(index);

            final tenantRecords = entry.value;

            // BUILD CARD BASED ON TAB NAME
            switch (tabName) {
              case 'TAA':
                return _buildTAACard(tenantRecords, state);

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

  Widget _buildCommonAccommodationCard({
    required TemporaryAlternativeAccommodationModel tenantRecord,
    required String secondaryFieldTitle,
    required String secondaryFieldValue,
    required num paidAmount,
    required num totalAmount,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: commonCardDecoration(),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              Row(
                spacing: 10,
                children: [
                  Container(
                    width: 4.w,
                    height: 24.h,
                    decoration: BoxDecoration(
                      color: AppColor.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        if (_tabController.index == 1) {
                          goRouter.pushNamed(
                            AppRoutes.viewRent,
                            queryParameters: {
                              'rent': Uri.encodeComponent(
                                EncryptionManager.encryptData(
                                  jsonEncode(tenantRecord.toJson()),
                                ),
                              ),
                            },
                          );
                        }
                      },
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              tenantRecord.flatNumber,
                              style: AppTextStyle.ts16M(
                                color:
                                    _tabController.index == 1
                                        ? AppColor.primary
                                        : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  CustomIconButton.add(onPressed: () {}),
                ],
              ),
              Row(
                spacing: 10,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildColumnTitleValue(
                    title: 'Applicant Type',
                    value: tenantRecord.applicantType,
                  ),
                  buildColumnTitleValue(
                    title: 'Applicant Name',
                    value: tenantRecord.applicantName,
                  ),
                ],
              ),
              Row(
                spacing: 10,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildColumnTitleValue(
                    title: "Existing Unit Type",
                    value: tenantRecord.flatType,
                  ),
                  buildColumnTitleValue(
                    title: "Existing Carpet Area (SqFt)",
                    value: tenantRecord.flatCarpetAreaSqFt.toStringAsFixed(2),
                  ),
                ],
              ),
              Row(
                spacing: 10,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildColumnTitleValue(
                    title: secondaryFieldTitle,
                    value: secondaryFieldValue,
                  ),
                  buildColumnTitleValue(
                    title: "Paid Amount",
                    value: paidAmount.toString(),
                  ),
                ],
              ),
              Row(
                spacing: 10,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildColumnTitleValue(
                    title: "Total",
                    value: totalAmount.toIndianCurrency(),
                  ),
                ],
              ),
            ],
          ),
          Divider(height: 25, color: AppColor.grey2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'View Summary',
                style: AppTextStyle.ts12R(color: AppColor.primary),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColor.primary,
                size: 16,
              ),
            ],
          ),
          verticalSpacing(height: 5),
        ],
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
        final tenantRecord = tenantRecords.first;
        final totalAmount =
            _findTotalRecord(state.rentList, tenantRecord.tenantId)?.amount ??
            0.0;
        final paidAmount =
            _findPaidRecord(state.rentList, tenantRecord.tenantId)?.amount ??
            0.0;
        return _buildCommonAccommodationCard(
          tenantRecord: tenantRecord,
          secondaryFieldTitle: "Proposed Offer Amount (₹)",
          secondaryFieldValue: tenantRecord.proposedOfferAmount.toString(),
          paidAmount: paidAmount,
          totalAmount: totalAmount,
        );
      },
    );
  }

  // BUILD TAA CARD
  Widget _buildTAACard(
    List<TemporaryAlternativeAccommodationModel> tenantRecords,
    TemporaryAlternateAccommodationState state,
  ) {
    final tenantRecord = tenantRecords.first;

    final totalAmount =
        _findTotalRecord(state.rentList, tenantRecord.tenantId)?.amount ?? 0.0;
    final paidAmount =
        _findPaidRecord(state.rentList, tenantRecord.tenantId)?.amount ?? 0.0;

    return _buildCommonAccommodationCard(
      tenantRecord: tenantRecord,
      secondaryFieldTitle: "Proposed Offer Amount (₹)",
      secondaryFieldValue: tenantRecord.proposedOfferAmount.toString(),
      paidAmount: paidAmount,
      totalAmount: totalAmount,
    );
  }

  // BUILD CORPUS (HARDSHIP) CARD
  Widget _buildCorpusCard(
    List<TemporaryAlternativeAccommodationModel> tenantRecords,
  ) {
    return BlocBuilder<
      TemporaryAlternateAccommodationCubit,
      TemporaryAlternateAccommodationState
    >(
      bloc: _temporaryAlternateAccommodationCubit,
      builder: (context, state) {
        final tenantRecord = tenantRecords.first;
        final allStages =
            state.rentList
                .map((e) => e.stage)
                .where((s) => s.isNotEmpty)
                .toSet()
                .toList();
        final totalAmount =
            _findTotalRecord(state.rentList, tenantRecord.tenantId)?.amount ??
            0.0;
        final paidAmount =
            _findPaidRecord(state.rentList, tenantRecord.tenantId)?.amount ??
            0.0;
        return _buildCommonAccommodationCard(
          tenantRecord: tenantRecord,
          secondaryFieldTitle: allStages.first,
          secondaryFieldValue: tenantRecord.amount.toString(),
          paidAmount: paidAmount,
          totalAmount: totalAmount,
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
        final tenantRecord = tenantRecords.first;
        final totalAmount =
            _findTotalRecord(
              state.rentList,
              tenantRecord.tenantId,
              tenure: tenantRecord.tenure,
            )?.amount ??
            0.0;
        final paidAmount =
            _findPaidRecord(
              state.rentList,
              tenantRecord.tenantId,
              tenure: tenantRecord.tenure,
            )?.amount ??
            0.0;
        return _buildCommonAccommodationCard(
          tenantRecord: tenantRecord,
          secondaryFieldTitle: "Proposed Offer Amount (₹)",
          secondaryFieldValue: tenantRecord.proposedOfferAmount.toString(),
          paidAmount: paidAmount,
          totalAmount: totalAmount,
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
        final tenantRecord = tenantRecords.first;
        final allStages =
            state.rentList
                .map((e) => e.stage)
                .where((s) => s.isNotEmpty)
                .toSet()
                .toList();
        final totalAmount =
            _findTotalRecord(state.rentList, tenantRecord.tenantId)?.amount ??
            0.0;
        final paidAmount =
            _findPaidRecord(state.rentList, tenantRecord.tenantId)?.amount ??
            0.0;
        return _buildCommonAccommodationCard(
          tenantRecord: tenantRecord,
          secondaryFieldTitle: allStages.first,
          secondaryFieldValue: tenantRecord.amount.toString(),
          paidAmount: paidAmount,
          totalAmount: totalAmount,
        );
      },
    );
  }
}
