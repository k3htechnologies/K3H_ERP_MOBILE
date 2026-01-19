import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/parking/data/model/parking.model.dart';
import 'package:k3h_erp_app/features/parking/presentation/cubit/parking_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class ParkingScreen extends StatefulWidget {
  const ParkingScreen({super.key});

  @override
  State<ParkingScreen> createState() => _ParkingScreenState();
}

class _ParkingScreenState extends State<ParkingScreen>
    with TickerProviderStateMixin {
  // CUBIT
  late ParkingCubit _parkingCubit;

  // AUTHORIZATION
  late AuthorizationModel _routAuthorizationModel;

  // PARKING
  late ProjectModel _project;

  // TEXT EDITING CONTROLLERS
  late TextEditingController _searchC;

  // TAB CONTROLLERS
  TabController? _buildingTabController;
  TabController? _wingTabController;

  // FILTER STATE
  final Set<String> _selectedParkingFilter = {};

  bool _isDisposing = false;

  @override
  void initState() {
    super.initState();
    _parkingCubit = context.read<ParkingCubit>();
    _initializeTextEditingControllers();
    _project = getProject();
    _routAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.parking]!;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final state = _parkingCubit.state;
        if (state.parkingList.isEmpty) {
          _parkingCubit.getParking(context, _project.projectId);
        } else {
          _initializeControllersIfNeeded(state);
        }
      }
    });
  }

  void _initializeControllersIfNeeded(ParkingState state) {
    if (!mounted || _isDisposing) return;

    bool needsRebuild = false;

    // Initialize building controller if we have data
    if (state.groupedData != null && state.groupedData!.isNotEmpty) {
      final buildingKeys = state.groupedData!.keys.toList();
      if (_buildingTabController == null ||
          _buildingTabController!.length != buildingKeys.length) {
        _initBuildingController(buildingKeys.length);
        needsRebuild = true;
      }
    }

    // Initialize wing controller if we have wings
    if (state.wingGroupedData != null && state.wingGroupedData!.isNotEmpty) {
      final wingKeys = state.wingGroupedData!.keys.toList();
      if (_wingTabController == null ||
          _wingTabController!.length != wingKeys.length) {
        _initWingController(wingKeys.length);
        needsRebuild = true;
      }
    }

    if (needsRebuild && mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _isDisposing = true;
    if (_buildingTabController != null) {
      _buildingTabController!.removeListener(_onBuildingTabChanged);
      _buildingTabController!.dispose();
      _buildingTabController = null;
    }
    if (_wingTabController != null) {
      _wingTabController!.removeListener(_onWingTabChanged);
      _wingTabController!.dispose();
      _wingTabController = null;
    }
    _disposeTextEditingControllers();
    super.dispose();
  }

  // BUILDING TAB CHANGED
  void _onBuildingTabChanged() {
    if (_buildingTabController == null || !mounted) return;
    if (!_buildingTabController!.indexIsChanging) {
      final state = _parkingCubit.state;
      if (state.groupedData != null) {
        final buildingKeys = state.groupedData!.keys.toList().reversed.toList();
        final tabIndex = _buildingTabController!.index;
        if (tabIndex >= 0 && tabIndex < buildingKeys.length) {
          // Reverse index to match the original order
          final actualIndex = buildingKeys.length - 1 - tabIndex;
          _parkingCubit.handleBuildingTabChange(
            actualIndex,
            buildingKeys[tabIndex],
          );
        }
      }
    }
  }

  // WING TAB CHANGED
  void _onWingTabChanged() {
    if (_wingTabController == null || !mounted) return;
    if (!_wingTabController!.indexIsChanging) {
      final state = _parkingCubit.state;
      if (state.wingGroupedData != null) {
        final wingKeys = state.wingGroupedData!.keys.toList();
        final index = _wingTabController!.index;
        if (index >= 0 && index < wingKeys.length) {
          _parkingCubit.handleWingTabChange(index, wingKeys[index]);
        }
      }
    }
  }

  // INITIALIZE BUILDING CONTROLLER
  void _initBuildingController(int length) {
    if (!mounted || _isDisposing || length == 0) return;

    if (_buildingTabController != null) {
      _buildingTabController!.removeListener(_onBuildingTabChanged);
      _buildingTabController!.dispose();
      _buildingTabController = null;
    }

    if (!mounted || _isDisposing) return;

    try {
      _buildingTabController = TabController(
        length: length,
        vsync: this,
        initialIndex: 0,
      );
      _buildingTabController!.addListener(_onBuildingTabChanged);
    } catch (e) {
      debugPrint('Error initializing building tab controller: $e');
    }
  }

  // INITIALIZE WING CONTROLLER
  void _initWingController(int length) {
    if (!mounted || _isDisposing || length == 0) return;

    if (_wingTabController != null) {
      _wingTabController!.removeListener(_onWingTabChanged);
      _wingTabController!.dispose();
      _wingTabController = null;
    }

    if (!mounted || _isDisposing) return;

    try {
      _wingTabController = TabController(
        length: length,
        vsync: this,
        initialIndex: 0,
      );
      _wingTabController!.addListener(_onWingTabChanged);
    } catch (e) {
      debugPrint('Error initializing wing tab controller: $e');
    }
  }

  // INITIALIZE TEXT EDITING CONTROLLERS
  void _initializeTextEditingControllers() {
    _searchC = TextEditingController();
  }

  // DISPOSE TEXT EDITING CONTROLLERS
  void _disposeTextEditingControllers() {
    _searchC.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        screenTitle: "Parking",
        authorization: _routAuthorizationModel,
        textController: _searchC,
        onSearchSubmit: (value) {
          _parkingCubit.searchParking(context, value, _project.projectId);
        },
        onProjectChangeCallback: (project) {
          _project = project;
          // Reset controllers when project changes
          if (_buildingTabController != null) {
            _buildingTabController!.removeListener(_onBuildingTabChanged);
            _buildingTabController!.dispose();
            _buildingTabController = null;
          }
          if (_wingTabController != null) {
            _wingTabController!.removeListener(_onWingTabChanged);
            _wingTabController!.dispose();
            _wingTabController = null;
          }
          _selectedParkingFilter.clear();
          _parkingCubit.getParking(context, _project.projectId);
        },
        onExportCallback: (value) {
          _parkingCubit.exportParking(context, _project.projectId, value);
        },
      ),
      body: SafeArea(
        child: BlocListener<ParkingCubit, ParkingState>(
          listener: (context, state) {
            if (!mounted || _isDisposing) return;

            bool needsRebuild = false;

            // Initialize building controller if we have data
            if (state.groupedData != null && state.groupedData!.isNotEmpty) {
              final buildingKeys = state.groupedData!.keys.toList();
              if (_buildingTabController == null ||
                  _buildingTabController!.length != buildingKeys.length) {
                _initBuildingController(buildingKeys.length);
                needsRebuild = true;
              } else {
                // Sync TabController index with state
                final reversedKeys = buildingKeys.reversed.toList();
                final tabIndex =
                    reversedKeys.length - 1 - state.buildingCurrentPage;
                if (_buildingTabController!.index != tabIndex &&
                    tabIndex >= 0 &&
                    tabIndex < reversedKeys.length) {
                  _buildingTabController!.index = tabIndex;
                }
              }
            }

            // Initialize wing controller if we have wings
            if (state.wingGroupedData != null &&
                state.wingGroupedData!.isNotEmpty) {
              final wingKeys = state.wingGroupedData!.keys.toList();
              if (_wingTabController == null ||
                  _wingTabController!.length != wingKeys.length) {
                _initWingController(wingKeys.length);
                needsRebuild = true;
              } else {
                // Sync TabController index with state
                if (_wingTabController!.index != state.wingCurrentPage &&
                    state.wingCurrentPage >= 0 &&
                    state.wingCurrentPage < wingKeys.length) {
                  _wingTabController!.index = state.wingCurrentPage;
                }
              }
            } else {
              if (_wingTabController != null && !_isDisposing) {
                _wingTabController!.removeListener(_onWingTabChanged);
                _wingTabController!.dispose();
                _wingTabController = null;
                needsRebuild = true;
              }
            }

            if (needsRebuild && mounted && !_isDisposing) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && !_isDisposing) {
                  setState(() {});
                }
              });
            }
          },
          child: BlocBuilder<ParkingCubit, ParkingState>(
            builder: (context, state) {
              if (state.isLoading! && state.parkingList.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.parkingList.isEmpty) {
                return Center(child: noDataWidget());
              }

              if (state.groupedData == null || state.groupedData!.isEmpty) {
                return Center(child: noDataWidget());
              }

              final buildingKeys =
                  state.groupedData!.keys.toList().reversed.toList();

              // Show loading if building controller is not initialized yet
              if (state.groupedData!.isNotEmpty &&
                  (_buildingTabController == null ||
                      _buildingTabController!.length != buildingKeys.length)) {
                return const Center(child: CircularProgressIndicator());
              }

              // Get current wing data
              final wingKeys = state.wingGroupedData?.keys.toList() ?? [];
              final wingData =
                  state.wingGroupedData?[state.wingCurrentPageKey] ?? [];

              return Column(
                children: [
                  verticalSpacing(),
                  // BUILDING TAB
                  _buildBuildingTab(state, buildingKeys),
                  verticalSpacing(),
                  // WING TAB
                  if (wingKeys.isNotEmpty) _buildWingTab(wingKeys),
                  // PARKING LIST
                  if (wingData.isNotEmpty)
                    Expanded(child: _buildParkingList(wingData))
                  else
                    Expanded(child: Center(child: noDataWidget())),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // BUILDING TAB
  Widget _buildBuildingTab(ParkingState state, List<String> buildingKeys) {
    if (_buildingTabController == null) {
      return const SizedBox.shrink();
    }

    if (_buildingTabController!.length != buildingKeys.length) {
      return const SizedBox.shrink();
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: IntrinsicWidth(
        child: Container(
          height: 48,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColor.grey.withValues(alpha: 0.2)),
          ),
          child: TabBar(
            controller: _buildingTabController,
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
            tabs: buildingKeys.map((b) => Tab(text: b)).toList(),
          ),
        ),
      ),
    );
  }

  // WING TAB
  Widget _buildWingTab(List<String> wingKeys) {
    if (_wingTabController == null) {
      return const SizedBox.shrink();
    }

    if (_wingTabController!.length != wingKeys.length) {
      return const SizedBox.shrink();
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: IntrinsicWidth(
        child: Container(
          height: 44,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColor.grey.withValues(alpha: 0.2)),
          ),
          child: TabBar(
            controller: _wingTabController,
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
            tabs: wingKeys.map((w) => Tab(text: w)).toList(),
          ),
        ),
      ),
    );
  }

  // PARKING LIST
  Widget _buildParkingList(List<ParkingModel> parkingList) {
    // Filter parking list based on selected filters
    final filteredList =
        _selectedParkingFilter.isEmpty
            ? parkingList
            : parkingList
                .where((e) => _selectedParkingFilter.contains(e.parkingStatus))
                .toList();

    if (filteredList.isEmpty) {
      return Center(child: noDataWidget());
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _buildParkingCard(filteredList[index], index),
        );
      },
    );
  }

  // PARKING CARD
  Widget _buildParkingCard(ParkingModel parking, int index) {
    Color statusColor;
    switch (parking.parkingStatus) {
      case 'Available':
        statusColor = AppColor.green;
        break;
      case 'Booked':
        statusColor = AppColor.red;
        break;
      case 'Block':
      case 'Blocked':
        statusColor = AppColor.grey;
        break;
      case 'Hold':
        statusColor = AppColor.yellow;
        break;
      case 'Member':
        statusColor = AppColor.slightDarkBlue;
        break;
      default:
        statusColor = AppColor.grey;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColor.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  parking.parkingNumber,
                  style: AppTextStyle.ts16M(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              CustomIconButton.edit(
                onPressed: () {
                  goRouter.pushNamed(
                    AppRoutes.editParking,
                    queryParameters: {
                      'parking': Uri.encodeComponent(
                        EncryptionManager.encryptData(
                          jsonEncode(parking.toJson()),
                        ),
                      ),
                      'index': index.toString(),
                    },
                  );
                },
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  parking.parkingStatus,
                  style: AppTextStyle.ts12M(color: statusColor),
                ),
              ),
            ],
          ),
          verticalSpacing(height: 8),
          if (parking.floor.isNotEmpty)
            Text(
              'Floor: ${parking.floor}',
              style: AppTextStyle.ts12R(color: AppColor.grey),
            ),
          if (parking.ownerName.isNotEmpty) ...[
            verticalSpacing(height: 4),
            Text(
              'Owner: ${parking.ownerName}',
              style: AppTextStyle.ts12R(color: AppColor.grey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (parking.parkingStatus == "Hold" ||
              parking.parkingStatus == "Member")
            Text(
              "Hold on ${formatDateTimeAsDDMMMYYYY(parking.modifiedDate!)} by ${parking.modifiedBy}",
              style: AppTextStyle.ts12R(),
            ),
        ],
      ),
    );
  }
}
