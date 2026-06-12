import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/core/cubit/utils_cubit.dart';
import 'package:k3h_erp_app/features/parking/data/model/parking.model.dart';
import 'package:k3h_erp_app/features/parking/presentation/cubit/parking_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/approve_reject_widget.dart';
import 'package:k3h_erp_app/widgets/chip_style_tab_bar.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
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
  late UtilsCubit _utilsCubit;

  // AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;

  // PARKING
  late ProjectModel _project;

  // TEXT EDITING CONTROLLERS
  late TextEditingController _searchC;

  // TAB CONTROLLERS
  TabController? _buildingTabController;
  TabController? _wingTabController;

  bool _isDisposing = false;

  final ValueNotifier<Set<String>> _expandedParking = ValueNotifier({});

  @override
  void initState() {
    super.initState();
    _parkingCubit = context.read<ParkingCubit>();

    _initializeTextEditingControllers();
    _project = getProject();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.parking]!;
    _utilsCubit = context.read<UtilsCubit>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final state = _parkingCubit.state;
        _parkingCubit.getParking(context, _project.projectId);
        if (state.parkingList.isNotEmpty) {
          _initializeControllersIfNeeded(state);
        }
      }
    });
  }

  // INITIALIZE CONTROLLERS IF NEEDED
  void _initializeControllersIfNeeded(ParkingState state) {
    if (!mounted || _isDisposing) return;

    // Initialize building controller if we have data
    if (state.groupedData != null && state.groupedData!.isNotEmpty) {
      final buildingKeys = state.groupedData!.keys.toList();
      if (_buildingTabController == null ||
          _buildingTabController!.length != buildingKeys.length) {
        _initBuildingController(buildingKeys.length);
      }
    }

    // Initialize wing controller if we have wings
    if (state.wingGroupedData != null && state.wingGroupedData!.isNotEmpty) {
      final wingKeys = state.wingGroupedData!.keys.toList();
      if (_wingTabController == null ||
          _wingTabController!.length != wingKeys.length) {
        _initWingController(wingKeys.length);
      }
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
        final buildingKeys = state.groupedData!.keys.toList();
        final tabIndex = _buildingTabController!.index;

        if (tabIndex >= 0 && tabIndex < buildingKeys.length) {
          _expandedParking.value = {};
          _parkingCubit.handleBuildingTabChange(
            tabIndex,
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
          _expandedParking.value = {};
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
        authorization: _routeAuthorizationModel,
        searchHintText: "Search By Parking Number",
        textController: _searchC,
        onSearchSubmit: (value) {
          _parkingCubit.searchParking(context, value, _project.projectId);
        },
        onProjectChangeCallback: (value) {
          _project = value;
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
          _parkingCubit.getParking(context, value.projectId);
        },
        onExportCallback: (value) {
          if (_project.projectId == 0) {
            showErrorMessage(context, "", "Please select a project");
            return;
          }
          if (_parkingCubit.state.parkingList.isEmpty) {
            showErrorMessage(context, "", "No data found");
            return;
          }
          _parkingCubit.exportParking(context, _project.projectId, value);
        },
      ),
      body: SafeArea(
        child: BlocListener<ParkingCubit, ParkingState>(
          listener: (context, state) {
            if (!mounted || _isDisposing) return;

            if (state.groupedData != null && state.groupedData!.isNotEmpty) {
              final buildingKeys = state.groupedData!.keys.toList();
              if (_buildingTabController == null ||
                  _buildingTabController!.length != buildingKeys.length) {
                _initBuildingController(buildingKeys.length);
              } else {
                final tabIndex = state.buildingCurrentPage;

                if (_buildingTabController!.index != tabIndex &&
                    tabIndex >= 0 &&
                    tabIndex < buildingKeys.length) {
                  _buildingTabController!.index = tabIndex;
                }
              }
            }

            if (state.wingGroupedData != null &&
                state.wingGroupedData!.isNotEmpty) {
              final wingKeys = state.wingGroupedData!.keys.toList();
              if (_wingTabController == null ||
                  _wingTabController!.length != wingKeys.length) {
                _initWingController(wingKeys.length);
              } else {
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
              }
            }
          },
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: showSiteSelectedWidget(
                  projectName: _project.projectName,
                ),
              ),
              Expanded(
                child: BlocBuilder<ParkingCubit, ParkingState>(
                  builder: (context, state) {
                    if (state.isLoading! && state.parkingList.isEmpty) {
                      return loader();
                    }

                    if (state.parkingList.isEmpty) {
                      return Center(child: noDataWidget());
                    }

                    if (state.groupedData == null ||
                        state.groupedData!.isEmpty) {
                      return Center(child: noDataWidget());
                    }

                    final buildingKeys = state.groupedData!.keys.toList();

                    if (state.groupedData!.isNotEmpty &&
                        (_buildingTabController == null ||
                            _buildingTabController!.length !=
                                buildingKeys.length)) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final wingKeys = state.wingGroupedData?.keys.toList() ?? [];
                    final wingData =
                        state.wingGroupedData?[state.wingCurrentPageKey] ?? [];
                    final ParkingModel? selectedParking =
                        wingData.isNotEmpty ? wingData.first : null;

                    final bool isActionAllowed =
                        selectedParking?.isApproval ?? false;
                    return Column(
                      children: [
                        verticalSpacing(),
                        // BUILDING TAB
                        _buildBuildingTab(state, buildingKeys),
                        verticalSpacing(),
                        // WING TAB
                        if (wingKeys.isNotEmpty) _buildWingTab(wingKeys),
                        // PARKING LIST
                        if (wingData.isNotEmpty) ...[
                          verticalSpacing(),
                          _buildCountsRow(wingData),
                          verticalSpacing(),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: ApproveRejectWidget(
                              actionTitle:
                                  selectedParking?.approvalStatus ?? "",
                              isActionAlreadyPerformed: !isActionAllowed,
                              popupTitle:
                                  "${selectedParking?.buildingNumber} > ${selectedParking?.wing} / ${selectedParking?.floor}",
                              isMaster: true,
                              onApprove: (val) async {
                                final isSuccess = await _utilsCubit
                                    .updateModulesWorkflowApproval(
                                      context: context,
                                      moduleName: 'PARKING APPROVAL',
                                      id: selectedParking!.inventoryBuildingId,
                                      subId:
                                          selectedParking
                                              .inventoryFlatFloorBasementPodiumWingId,
                                      subSubId:
                                          selectedParking.inventoryFloorId,
                                      projectId: _project.projectId,
                                      isApproved: true,
                                      remark: val.trim(),
                                    );

                                if (context.mounted && isSuccess) {
                                  _parkingCubit.getParking(
                                    context,
                                    _project.projectId,
                                  );
                                  _parkingCubit.handleWingTabChange(
                                    _wingTabController!.index,
                                    selectedParking.wing,
                                  );
                                }
                              },
                              onReject: (val) async {
                                final isSuccess = await _utilsCubit
                                    .updateModulesWorkflowApproval(
                                      context: context,
                                      moduleName: 'PARKING APPROVAL',
                                      id: selectedParking!.inventoryBuildingId,
                                      subId:
                                          selectedParking
                                              .inventoryFlatFloorBasementPodiumWingId,
                                      subSubId:
                                          selectedParking.inventoryFloorId,
                                      projectId: _project.projectId,
                                      isApproved: false,
                                      remark: val.trim(),
                                    );

                                if (context.mounted && isSuccess) {
                                  _parkingCubit.getParking(
                                    context,
                                    _project.projectId,
                                  );
                                }
                              },
                              onThirdTap: () async {
                                final approvalLogHistoryList = await _utilsCubit
                                    .getApprovalLogHistory(
                                      context: context,
                                      projectId: _project.projectId,
                                      id: selectedParking!.inventoryBuildingId,
                                      subId:
                                          selectedParking
                                              .inventoryFlatFloorBasementPodiumWingId,
                                      subSubId:
                                          selectedParking.inventoryFloorId,
                                      moduleName: "PARKING APPROVAL",
                                    );

                                if (context.mounted) {
                                  goRouter.pushNamed(
                                    AppRoutes.approvalLogHistory,
                                    queryParameters: {
                                      "subTitle": Uri.encodeComponent(
                                        EncryptionManager.encryptData(
                                          "${selectedParking.buildingNumber} > ${selectedParking.wing} / ${selectedParking.floor}",
                                        ),
                                      ),
                                      "title": Uri.encodeComponent(
                                        EncryptionManager.encryptData(
                                          "Parking Log History",
                                        ),
                                      ),
                                      "approvalList": Uri.encodeComponent(
                                        EncryptionManager.encryptData(
                                          jsonEncode(
                                            approvalLogHistoryList
                                                .map((e) => e.toJson())
                                                .toList(),
                                          ),
                                        ),
                                      ),
                                    },
                                  );
                                }
                              },
                            ),
                          ),
                          verticalSpacing(height: 2.h),
                          Expanded(child: _buildParkingList(wingData)),
                        ] else
                          Expanded(child: Center(child: noDataWidget())),
                      ],
                    );
                  },
                ),
              ),
            ],
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

    return ChipStyleTabBar(
      controller: _buildingTabController!,
      tabs: buildingKeys.map((b) => b).toList(),
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

    return ChipStyleTabBar(
      controller: _wingTabController!,
      isSecondaryStyle: true,
      tabs: wingKeys.map((w) => w).toList(),
    );
  }

  // PARKING LIST
  Widget _buildParkingList(List<ParkingModel> parkingList) {
    final selectedFilter =
        context.watch<ParkingCubit>().state.selectedFlatStatus;

    final filteredList =
        selectedFilter?.toLowerCase() == 'total'
            ? parkingList
            : parkingList.where((parking) {
              return parking.parkingStatus.toLowerCase() ==
                  selectedFilter?.toLowerCase();
            }).toList();

    if (filteredList.isEmpty) {
      return Center(child: noDataWidget());
    }

    return ValueListenableBuilder<Set<String>>(
      valueListenable: _expandedParking,
      builder: (context, expandedSet, child) {
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          itemCount: filteredList.length,
          itemBuilder: (context, index) {
            final parking = filteredList[index];
            final parkingKey = "${parking.parkingId}-$index";
            final isExpanded = expandedSet.contains(parkingKey);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColor.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColor.grey.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  children: [
                    /// HEADER
                    InkWell(
                      onTap: () {
                        final newSet = Set<String>.from(expandedSet);

                        if (isExpanded) {
                          newSet.remove(parkingKey);
                        } else {
                          newSet.add(parkingKey);
                        }

                        _expandedParking.value = newSet;
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Parking No: ${parking.parkingNumber}",
                                    style: AppTextStyle.ts14M(),
                                  ),
                                  Text(
                                    "Floor: ${parking.floor}",
                                    style: AppTextStyle.ts12M(
                                      color: AppColor.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              isExpanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: AppColor.grey,
                            ),
                          ],
                        ),
                      ),
                    ),

                    /// EXPAND CONTENT
                    ClipRect(
                      child: AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        alignment: Alignment.topCenter,
                        child:
                            isExpanded
                                ? Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: _buildParkingCard(
                                    parking,
                                    index,
                                  ), // your existing UI
                                )
                                : const SizedBox.shrink(),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
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
        statusColor = AppColor.error;
        break;
      case 'Block':
      case 'Blocked':
        statusColor = AppColor.grey;
        break;
      case 'Hold':
        statusColor = AppColor.yellow;
        break;
      case 'Alloted':
        statusColor = AppColor.purple;
        break;
      default:
        statusColor = AppColor.grey;
    }
    final status = parking.parkingStatus.toLowerCase();
    final showView = (status == "booked" || status == "alloted");
    final canAction = _routeAuthorizationModel.isAction;

    final showEdit =
        canAction &&
        (status == "available" || status == "blocked" || status == "hold");

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildRowTitleValue(
            title: "Category",
            value: parking.parkingCategory,
            fixesWidth: 100,
          ),
          buildRowTitleValue(
            title: "Type",
            value: parking.parkingType,
            fixesWidth: 100,
          ),
          buildRowTitleValue(
            title: "EV Charging",
            value: parking.isEVChargingAvailable ? "Yes" : "No",
            fixesWidth: 100,
          ),
          buildRowTitleValue(
            title: "Dimensions",
            value: parking.parkingDimensions,
            fixesWidth: 100,
          ),
          buildRowTitleValue(
            title: "Size",
            value: parking.parkingSubType,
            fixesWidth: 100,
          ),
          verticalSpacing(height: 8),
          Row(
            spacing: 10,
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColor.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Text(
                      parking.parkingStatus,
                      style: AppTextStyle.ts12M(color: statusColor),
                    ),
                  ),
                ),
              ),
              if (parking.approvalStatus != "Approved")
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (showView)
                      GestureDetector(
                        onTap: () async {
                          await goRouter.pushNamed(
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
                        child: const Icon(
                          Icons.remove_red_eye_outlined,
                          size: 18,
                        ),
                      ),

                    if (showEdit)
                      GestureDetector(
                        onTap: () async {
                          await goRouter.pushNamed(
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
                        child: const Icon(Icons.edit, size: 18),
                      ),
                  ],
                ),
            ],
          ),
          if (parking.ownerName.isNotEmpty) ...[
            verticalSpacing(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Owner: ${parking.ownerName}',
                  style: AppTextStyle.ts12R(color: AppColor.primary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
          if (parking.parkingStatus == "Hold")
            Text(
              "Hold by ${parking.modifiedBy} on ${formatDate(parking.modifiedDate!)}",
              style: AppTextStyle.ts12R(color: AppColor.yellow),
            ),
          if (parking.parkingStatus == "Blocked")
            Text(
              "Blocked by ${parking.modifiedBy} on ${formatDate(parking.modifiedDate!)}",
              style: AppTextStyle.ts12R(color: AppColor.grey),
            ),
        ],
      ),
    );
  }

  // COUNTS ROW
  Widget _buildCountsRow(List<ParkingModel> wingList) {
    final state = context.read<ParkingCubit>().state;

    final total = wingList.length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColor.grey.withValues(alpha: 0.2)),
      ),
      child: Row(
        spacing: 10,
        children: [
          _buildCountItem("Total", total, AppColor.black),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                spacing: 10,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCountItem(
                    "Available",
                    state.availableParking,
                    Color(0xff28653F),
                  ),
                  _buildCountItem(
                    "Booked",
                    state.bookedParking,
                    Color(0xffFF0000),
                  ),
                  _buildCountItem(
                    "Alloted",
                    state.allotedParking,
                    Color(0xff561F64),
                  ),
                  _buildCountItem("Hold", state.holdParking, AppColor.brown),
                  _buildCountItem(
                    "Blocked",
                    state.blockedParking,
                    Color(0xff1D1D1D),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // COUNT ITEM
  Widget _buildCountItem(String label, int count, Color color) {
    final selectedFilter =
        context.watch<ParkingCubit>().state.selectedFlatStatus;

    final isSelected = selectedFilter?.toLowerCase() == label.toLowerCase();

    return InkWell(
      onTap: () {
        final cubit = context.read<ParkingCubit>();

        // Reset filter when same item tapped
        if (isSelected) {
          cubit.updateStatusFilter(null);
        } else {
          cubit.updateStatusFilter(label);
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              count.toString(),
              style: AppTextStyle.ts12SB().copyWith(color: color),
            ),

            horizontalSpacing(width: 5),

            Text(
              label,
              style:
                  isSelected
                      ? AppTextStyle.ts12SB().copyWith(color: color)
                      : AppTextStyle.ts12R().copyWith(color: AppColor.black),
            ),
          ],
        ),
      ),
    );
  }
}
