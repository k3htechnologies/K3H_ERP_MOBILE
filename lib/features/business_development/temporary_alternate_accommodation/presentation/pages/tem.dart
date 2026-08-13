import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/business_development/building/data/model/building.model.dart';
import 'package:k3h_erp_app/features/business_development/building/data/repository/building.repository.dart';
import 'package:k3h_erp_app/features/business_development/temporary_alternate_accommodation/presentation/cubit/temporary_alternate_accommodation_cubit.dart';
import 'package:k3h_erp_app/utils/functions/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_multi_select_pop_up.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class Tem extends StatefulWidget {
  const Tem({super.key});

  @override
  State<Tem> createState() => _TemState();
}

class _TemState extends State<Tem> with TickerProviderStateMixin {
  // CUBIT
  late TemporaryAlternateAccommodationCubit
  _temporaryAlternateAccommodationCubit;
  // PROJECT
  late ProjectModel _project;
  // TAB CONTROLLERS
  late TabController _tabController;
  late TabController _tenureTabController;
  // PAGINATION
  late ScrollController _scrollController;
  Timer? _debounce;
  final ValueNotifier<List<Map<String, dynamic>>> _selectedBuildingNotifier =
      ValueNotifier([]);
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
      appBar: CustomAppBar(
        screenTitle: "Temporary Alternate",
        authorization: AuthorizationModel(),
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
        ],
      ),
    );
  }
}
