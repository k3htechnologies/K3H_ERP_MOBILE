// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/models/user.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/core/cubit/utils_cubit.dart';
import 'package:k3h_erp_app/features/inventory/data/model/building.model.dart';
import 'package:k3h_erp_app/features/inventory/presentation/cubit/inventory_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/approve_reject_widget.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/chip_style_tab_bar.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen>
    with TickerProviderStateMixin {
  // CUBIT
  late InventoryCubit _inventoryCubit;
  late UtilsCubit _utilsCubit;

  // AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;
  late AuthorizationModel _routeAuthorizationModelBooking;

  // CURRENT PROJECT
  late ProjectModel _project;
  late UserModel user;

  // TEXT EDIT CONTROLLER
  late TextEditingController _searchC;

  // TAB CONTROLLERS
  TabController? _buildingTabController;
  TabController? _wingTabController;

  // EXPANSION STATE
  final ValueNotifier<Set<String>> _expandedFloors = ValueNotifier({});
  bool _isDisposing = false;

  @override
  void initState() {
    super.initState();
    _project = getProject();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.inventory]!;
    _routeAuthorizationModelBooking =
        Authorization.routeAuthorizationMap[AppRoutes.booking]!;
    user = getCurrentUser();
    _initControllers();
    _inventoryCubit = context.read<InventoryCubit>();
    _utilsCubit = context.read<UtilsCubit>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        if (_inventoryCubit.state.buildingList.isEmpty) {
          if (_project.projectId == 0) {
            _inventoryCubit.reset();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showErrorMessage(context, "Error", "Please select a project");
            });
          } else {
            _inventoryCubit.getInventory(context, _project.projectId);
          }
        } else {
          _initializeControllersIfNeeded(_inventoryCubit.state);
        }
      }
    });
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
    _searchC.dispose();
    _expandedFloors.dispose();
    super.dispose();
  }

  // INITIALIZE CONTROLLERS
  void _initializeControllersIfNeeded(InventoryState state) {
    if (!mounted || _isDisposing) return;

    if (state.buildingList.isNotEmpty) {
      if (_buildingTabController == null ||
          _buildingTabController!.length != state.buildingList.length) {
        _initBuildingController(state);
      }
    }

    if (state.buildingList.isNotEmpty &&
        state.currentTabIndex < state.buildingList.length) {
      final selectedBuilding = state.buildingList[state.currentTabIndex];
      final wingList = selectedBuilding.wingList;

      if (wingList.isNotEmpty) {
        if (_wingTabController == null ||
            _wingTabController!.length != wingList.length) {
          _initWingController(wingList);
        }
      }
    }
  }

  // RESET CONTROLLERS
  void resetControllers() {
    if (_buildingTabController != null) {
      _buildingTabController!.dispose();
      _buildingTabController = null;
    }
    if (_wingTabController != null) {
      _wingTabController!.dispose();
      _wingTabController = null;
    }
  }

  // BUILDING TAB
  void _onBuildingTabChanged() {
    if (_buildingTabController == null || !mounted) return;
    if (!_buildingTabController!.indexIsChanging) {
      _expandedFloors.value = {};
      _inventoryCubit.onTabChanged(_buildingTabController!.index, context);
      _initializeControllersIfNeeded(_inventoryCubit.state);
    }
  }

  // WING TAB
  void _onWingTabChanged() {
    if (_wingTabController == null || !mounted) return;

    if (!_wingTabController!.indexIsChanging) {
      final state = _inventoryCubit.state;

      final selectedBuilding = state.buildingList[state.currentTabIndex];
      final wingList = selectedBuilding.wingList;

      final index = _wingTabController!.index;

      if (index >= 0 && index < wingList.length) {
        _inventoryCubit.updateWingSelection(index, wingList[index].wing);
        _initializeControllersIfNeeded(_inventoryCubit.state);
      }

      _expandedFloors.value = {};
    }
  }

  // INITIALIZE CONTROLLERS
  void _initControllers() {
    _searchC = TextEditingController();
  }

  // BUILDING CONTROLLER
  void _initBuildingController(InventoryState state) {
    if (!mounted || _isDisposing) return;
    if (state.buildingList.isEmpty) return;

    if (_buildingTabController != null) {
      _buildingTabController!.removeListener(_onBuildingTabChanged);
      _buildingTabController!.dispose();
      _buildingTabController = null;
    }

    if (!mounted || _isDisposing) return;

    try {
      _buildingTabController = TabController(
        length: state.buildingList.length,
        vsync: this,
        initialIndex:
            state.currentTabIndex < state.buildingList.length
                ? state.currentTabIndex
                : 0,
      );

      _buildingTabController!.addListener(_onBuildingTabChanged);
    } catch (e) {
      debugPrint('Error initializing building controller: $e');
    }
  }

  // WING CONTROLLER
  void _initWingController(List wingList) {
    if (!mounted || _isDisposing) return;

    if (_wingTabController != null) {
      _wingTabController!.removeListener(_onWingTabChanged);
      _wingTabController = null;
    }

    if (!mounted || _isDisposing) return;

    _wingTabController = TabController(length: wingList.length, vsync: this);
    _wingTabController!.addListener(_onWingTabChanged);
  }

  // DELETE INVENTORY FLAT
  Future<void> _showPopupToDeleteInventoryFlat(
    BuildContext context,
    FlatModel flat,
    int floorIndex,
    int wingIndex,
    int buildingIndex,
    int flatIndex,
  ) async {
    var result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a inventory unit ?',
      'Are you sure you want to delete unit "${flat.flat}"? This action cannot be undone.',
    );
    if (result && context.mounted) {
      _inventoryCubit.deleteInventoryFlat(
        context,
        floorIndex,
        wingIndex,
        buildingIndex,
        flatIndex,
        projectId: _project.projectId,
        inventoryBuildingId: flat.inventoryBuildingId,
        inventoryFlatFloorBasementPodiumWingId:
            flat.inventoryFlatFloorBasementPodiumWingId,
        inventoryFloorId: flat.inventoryFloorId,
        inventoryFlat: flat.inventoryFlatId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        screenTitle: "Inventory Management",
        authorization: _routeAuthorizationModel,
        searchHintText: "Search by Unit Number",
        onSearchSubmit: (value) {
          _inventoryCubit.searchInventory(value);
          resetControllers();
        },
        textController: _searchC,
        onExportCallback: (value) {
          if (_project.projectId == 0) {
            showErrorMessage(context, "Error", "Please Select a project");
            return;
          }
          if (_inventoryCubit.state.buildingList.isEmpty) {
            showErrorMessage(context, "", "No Data Found");
            return;
          }
          _inventoryCubit.exportInventory(context, _project.projectId, value);
        },
        onAddCallback: () {
          if (_project.projectId == 0) {
            showErrorMessage(context, "Error", "Please Select a project");
            return;
          }
          if (_inventoryCubit.state.buildingList.isEmpty) {
            showErrorMessage(context, "", "Inventory to be generated from web");
            return;
          }
          final state = _inventoryCubit.state;

          final selectedBuilding = state.buildingList[state.currentTabIndex];
          final wingList = selectedBuilding.wingList;

          final currentWingIndex = _wingTabController?.index ?? 0;
          final selectedWing = wingList[currentWingIndex];

          _inventoryCubit.addFloor(
            context,
            projectId: _project.projectId,
            inventoryBuildingId: selectedBuilding.inventoryBuildingId,
            inventoryFlatFloorBasementPodiumWingId:
                selectedWing.inventoryFlatFloorBasementPodiumWingId,
          );
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
          _expandedFloors.value.clear();
          _inventoryCubit.getInventory(context, value.projectId);
        },
      ),
      body: SafeArea(
        child: BlocListener<InventoryCubit, InventoryState>(
          listener: (context, state) {
            if (!mounted || _isDisposing) return;

            if (state.buildingList.isNotEmpty) {
              if (_buildingTabController == null ||
                  _buildingTabController!.length != state.buildingList.length) {
                _initBuildingController(state);
              }
            }

            if (state.buildingList.isNotEmpty &&
                state.currentTabIndex < state.buildingList.length) {
              final selectedBuilding =
                  state.buildingList[state.currentTabIndex];
              final wingList = selectedBuilding.wingList;
              if (_wingTabController != null &&
                  state.wingCurrentPage < _wingTabController!.length &&
                  _wingTabController!.index != state.wingCurrentPage) {
                _wingTabController!.index = state.wingCurrentPage;
              }
              if (wingList.isNotEmpty) {
                if (_wingTabController == null ||
                    _wingTabController!.length != wingList.length) {
                  _initWingController(wingList);
                }
              } else {
                if (_wingTabController != null && !_isDisposing) {
                  _wingTabController!.removeListener(_onWingTabChanged);
                  _wingTabController!.dispose();
                  _wingTabController = null;
                }
              }
            }
          },
          child: BlocBuilder<InventoryCubit, InventoryState>(
            builder: (context, state) {
              if (state.isLoading! && state.buildingList.isEmpty) {
                return loader();
              }

              if (state.buildingList.isEmpty) {
                return Center(child: noDataWidget());
              }

              _initializeControllersIfNeeded(state);

              // Ensure currentTabIndex is within bounds
              final int safeTabIndex =
                  state.currentTabIndex >= 0 &&
                          state.currentTabIndex < state.buildingList.length
                      ? state.currentTabIndex
                      : 0;

              final selectedBuilding = state.buildingList[safeTabIndex];

              final wingList = selectedBuilding.wingList;
              final wingIndex = state.wingCurrentPage.clamp(
                0,
                wingList.isEmpty ? 0 : wingList.length - 1,
              );

              final selectedWing =
                  wingList.isNotEmpty ? wingList[wingIndex] : null;

              final bool isActionAllowed = selectedWing?.isApproval ?? false;

              if (state.buildingList.isNotEmpty &&
                  (_buildingTabController == null ||
                      _buildingTabController!.length !=
                          state.buildingList.length)) {
                return const Center(child: CircularProgressIndicator());
              }
              return Column(
                children: [
                  verticalSpacing(),
                  // BUILDING TAB
                  _buildBuildingTab(state),
                  verticalSpacing(),
                  // WING TAB
                  if (wingList.isNotEmpty) _buildWingTab(wingList),
                  // COUNTS
                  verticalSpacing(),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: ApproveRejectWidget(
                      actionTitle: selectedWing?.approvalStatus ?? "",
                      isActionAlreadyPerformed: !isActionAllowed,
                      isMaster: true,
                      popupTitle:
                          "${selectedBuilding.buildingNumber} > ${selectedWing?.wing ?? ''}",

                      onApprove: (val) async {
                        await _utilsCubit.updateModulesWorkflowApproval(
                          context: context,
                          moduleName: 'INVENTORY APPROVAL',
                          id: selectedBuilding.inventoryBuildingId,
                          subId:
                              selectedWing
                                  ?.inventoryFlatFloorBasementPodiumWingId,
                          projectId: _project.projectId,
                          isApproved: true,
                          remark: val.trim(),
                        );
                        if (context.mounted) {
                          _inventoryCubit.getInventory(
                            context,
                            _project.projectId,
                          );
                        }
                      },

                      onReject: (val) async {
                        await _utilsCubit.updateModulesWorkflowApproval(
                          context: context,
                          moduleName: 'INVENTORY APPROVAL',
                          id: selectedBuilding.inventoryBuildingId,
                          subId:
                              selectedWing
                                  ?.inventoryFlatFloorBasementPodiumWingId,
                          projectId: _project.projectId,
                          isApproved: false,
                          remark: val.trim(),
                        );
                        if (context.mounted) {
                          _inventoryCubit.getInventory(
                            context,
                            _project.projectId,
                          );
                        }
                      },
                      onThirdTap:
                          selectedWing == null
                              ? null
                              : () async {
                                final approvalLogHistoryList = await _utilsCubit
                                    .getApprovalLogHistory(
                                      context: context,
                                      projectId: _project.projectId,
                                      id: selectedBuilding.inventoryBuildingId,
                                      subId:
                                          selectedWing
                                              .inventoryFlatFloorBasementPodiumWingId,
                                      moduleName: "INVENTORY APPROVAL",
                                    );

                                if (context.mounted) {
                                  goRouter.pushNamed(
                                    AppRoutes.approvalLogHistory,
                                    queryParameters: {
                                      "subTitle": Uri.encodeComponent(
                                        EncryptionManager.encryptData(
                                          "${selectedBuilding.buildingNumber} > ${selectedWing.wing}",
                                        ),
                                      ),
                                      "title": Uri.encodeComponent(
                                        EncryptionManager.encryptData(
                                          "Inventory Log History",
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
                  verticalSpacing(),
                  if (wingList.isNotEmpty &&
                      _wingTabController != null &&
                      _wingTabController!.length == wingList.length)
                    _buildCountsRow(wingList),

                  if (wingList.isNotEmpty)
                    Expanded(
                      child:
                          _wingTabController != null &&
                                  _wingTabController!.length ==
                                      wingList.length &&
                                  mounted
                              ? TabBarView(
                                controller: _wingTabController,
                                children:
                                    wingList
                                        .asMap()
                                        .entries
                                        .map(
                                          (entry) => _buildFloorList(
                                            entry.value.floorList,
                                            entry.value,
                                            selectedBuilding,
                                            safeTabIndex,
                                            entry.key,
                                          ),
                                        )
                                        .toList(),
                              )
                              : const Center(
                                child: CircularProgressIndicator(),
                              ),
                    )
                  else
                    const Expanded(
                      child: Center(child: Text("No wings found")),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // FLOOR LIST
  Widget _buildFloorList(
    List<FloorModel> floorList,
    WingModel wing,
    BuildingModel building,
    int buildingIndex,
    int wingIndex,
  ) {
    final selectedFilter =
        context.watch<InventoryCubit>().state.selectedFlatStatus;

    final filteredFloorList =
        selectedFilter?.toLowerCase() == 'total'
            ? floorList
            : floorList.where((floor) {
              return floor.flatList.any(
                (flat) =>
                    flat.flatStatus.toLowerCase() ==
                    selectedFilter?.toLowerCase(),
              );
            }).toList();

    if (filteredFloorList.isEmpty) {
      return Center(child: noDataWidget(message: "No floors found"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredFloorList.length,
      itemBuilder: (context, index) {
        final floor = filteredFloorList[index];
        final filteredFlats =
            selectedFilter == null || selectedFilter.toLowerCase() == 'total'
                ? floor.flatList
                : floor.flatList.where((flat) {
                  return flat.flatStatus.toLowerCase() ==
                      selectedFilter.toLowerCase();
                }).toList();
        return ValueListenableBuilder<Set<String>>(
          valueListenable: _expandedFloors,
          builder: (context, expandedSet, child) {
            final floorKey = "$buildingIndex-$wingIndex-$index";
            final isExpanded = expandedSet.contains(floorKey);

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColor.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColor.grey.withValues(alpha: 0.2)),
              ),
              child: Column(
                children: [
                  // Header - Clickable
                  InkWell(
                    onTap: () {
                      final newSet = Set<String>.from(expandedSet);

                      if (isExpanded) {
                        newSet.remove(floorKey);
                      } else {
                        newSet.add(floorKey);
                      }
                      _expandedFloors.value = newSet;
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        floor.floor,
                                        style: AppTextStyle.ts14M(),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        if (_routeAuthorizationModel.isAction)
                                          if (wing.approvalStatus !=
                                                  "Approved" &&
                                              wing.approvalStatus !=
                                                  "Partial Approved")
                                            GestureDetector(
                                              onTap: () async {
                                                await goRouter.pushNamed(
                                                  AppRoutes
                                                      .addInventorySpecification,
                                                  queryParameters: {
                                                    "flatModel": Uri.encodeQueryComponent(
                                                      EncryptionManager.encryptData(
                                                        jsonEncode(
                                                          FlatModel(
                                                            inventoryFlatId: 0,
                                                            uniquekey: "",
                                                            inventoryBuildingId:
                                                                floor
                                                                    .inventoryBuildingId,
                                                            buildingNumber:
                                                                building
                                                                    .buildingNumber,
                                                            inventoryFlatFloorBasementPodiumWingId:
                                                                floor
                                                                    .inventoryFlatFloorBasementPodiumWingId,
                                                            wing: wing.wing,
                                                            inventoryFloorId:
                                                                floor
                                                                    .inventoryFloorId,
                                                            floor: floor.floor,
                                                            slabHeight:
                                                                floor
                                                                    .slabHeight,
                                                            parkingCount:
                                                                floor
                                                                    .parkingCount,
                                                            flat: "",
                                                            reraCarpetAreaSqFt:
                                                                0,
                                                            flatType: "",
                                                            flatConfiguration:
                                                                "",
                                                            flatStatus: "",
                                                            ownerName: "",
                                                            flatFacing: "",
                                                            createdBy: "",
                                                            createdById: 0,
                                                            modifiedBy: "",
                                                            modifiedById: 0,
                                                            createdDate:
                                                                DateTime.now(),
                                                            modifiedDate:
                                                                DateTime.now(),
                                                            bookingId: 0,
                                                            bookingCreatedById:
                                                                0,
                                                            bookingCreatedBy:
                                                                "",
                                                            bookingCreatedDate:
                                                                DateTime.now(),
                                                            specificationList:
                                                                [],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    "floorModel":
                                                        Uri.encodeQueryComponent(
                                                          EncryptionManager.encryptData(
                                                            jsonEncode(floor),
                                                          ),
                                                        ),
                                                  },
                                                );
                                                if (context.mounted) {
                                                  await _inventoryCubit
                                                      .getInventory(
                                                        context,
                                                        _project.projectId,
                                                      );
                                                }
                                              },
                                              child: Icon(
                                                Icons.add,
                                                size: 18,
                                                color: AppColor.darkGreen,
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
                                  ],
                                ),
                                Text(
                                  "Total Flats : ${floor.flatList.length}",
                                  style: AppTextStyle.ts12R(
                                    color: AppColor.grey,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const SizedBox(height: 4),
                                    Expanded(
                                      child: Text(
                                        "Slab Height: ${floor.slabHeight} ft",
                                        style: AppTextStyle.ts12R(
                                          color: AppColor.grey,
                                        ),
                                      ),
                                    ),
                                    horizontalSpacing(),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SvgPicture.asset(
                                          AppAssets.car,
                                          height: 20.0,
                                          width: 20.0,
                                          color: AppColor.black.withValues(
                                            alpha: 0.4,
                                          ),
                                        ),
                                        horizontalSpacing(width: 3),
                                        Text(":", style: AppTextStyle.ts12R()),
                                        horizontalSpacing(width: 3),
                                        Text(
                                          "${floor.parkingCount}",
                                          style: AppTextStyle.ts12R(),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // EXPANDABLE CONTENT
                  ClipRect(
                    child: AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      alignment: Alignment.topCenter,
                      child:
                          isExpanded
                              ? Padding(
                                padding: const EdgeInsets.only(
                                  left: 16,
                                  right: 16,
                                  bottom: 16,
                                ),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: _buildFlatList(
                                    filteredFlats,
                                    floor,
                                    buildingIndex,
                                    wingIndex,
                                    index,
                                    wing.approvalStatus,
                                  ),
                                ),
                              )
                              : const SizedBox.shrink(),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // BUILDING TAB
  Widget _buildBuildingTab(InventoryState state) {
    if (_buildingTabController == null) {
      return const SizedBox.shrink();
    }

    if (_buildingTabController!.length != state.buildingList.length) {
      return const SizedBox.shrink();
    }

    return ChipStyleTabBar(
      margin: EdgeInsets.only(left: 10),
      controller: _buildingTabController!,
      tabs: state.buildingList.map((b) => b.buildingNumber).toList(),
    );
  }

  // WING TAB
  Widget _buildWingTab(List wingList) {
    if (_wingTabController == null) {
      return const SizedBox.shrink();
    }

    if (_wingTabController!.length != wingList.length) {
      return const SizedBox.shrink();
    }

    return ChipStyleTabBar(
      controller: _wingTabController!,
      isSecondaryStyle: true,
      tabs: wingList.map((w) => w.wing.toString()).toList(),
    );
  }

  // FLAT LIST
  Widget _buildFlatList(
    List<FlatModel> flatList,
    FloorModel floor,
    int buildingIndex,
    int wingIndex,
    int floorIndex,
    String approvalStatus,
  ) {
    if (flatList.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          "No flats available",
          style: AppTextStyle.ts12R(color: AppColor.grey),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: flatList.length,
      itemBuilder: (context, flatIndex) {
        final flat = flatList[flatIndex];

        return _buildFlatCard(
          flat,
          floor,
          buildingIndex,
          wingIndex,
          floorIndex,
          flatIndex,
          approvalStatus,
        );
      },
    );
  }

  Widget _buildFlatCard(
    FlatModel flat,
    FloorModel floor,
    int buildingIndex,
    int wingIndex,
    int floorIndex,
    int flatIndex,
    String approvalStatus,
  ) {
    final canView = _routeAuthorizationModel.isView;
    final canAction = _routeAuthorizationModel.isAction;

    if (!canView && !canAction) {
      return const SizedBox.shrink();
    }
    final status = flat.flatStatus.toLowerCase();

    final isApproved =
        approvalStatus.toLowerCase() == "approved" ||
        approvalStatus.toLowerCase() == "partial approved";

    final showView = (status == "booked" || status == "alloted");

    final showEdit =
        (canAction || _routeAuthorizationModelBooking.isAction) &&
        (status == "available" || status == "blocked" || status == "hold");

    final showDelete = canAction && status == "available" && !isApproved;

    final showBookBtn =
        status == "available" &&
        approvalStatus.toLowerCase() == "approved" &&
        flat.flatType != "" &&
        flat.reraCarpetAreaSqFt > 0 &&
        _routeAuthorizationModelBooking.isAction;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _statusColor(flat.flatStatus),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Unit No. : ${flat.flat}", style: AppTextStyle.ts14M()),
          verticalSpacing(height: 5),
          buildRowTitleValue(title: "Type", value: flat.flatType),
          buildRowTitleValue(
            title: "Area(Sq.ft)",
            value: flat.reraCarpetAreaSqFt.toString(),
          ),
          buildRowTitleValue(
            title: "Configuration",
            value: flat.flatConfiguration,
          ),
          verticalSpacing(),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColor.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      flat.flatStatus,
                      style: AppTextStyle.ts14M(
                        color:
                            flat.flatStatus.toLowerCase() == "booked"
                                ? AppColor.error
                                : flat.flatStatus.toLowerCase() == "alloted"
                                ? AppColor.purple
                                : flat.flatStatus.toLowerCase() == "hold"
                                ? AppColor.yellow
                                : flat.flatStatus.toLowerCase() == "available"
                                ? AppColor.darkGreen
                                : flat.flatStatus.toLowerCase() == "blocked"
                                ? AppColor.black
                                : AppColor.black,
                      ),
                    ),
                  ),
                ),
              ),

              horizontalSpacing(),

              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  //  VIEW (always if hasAccess)
                  if (showView)
                    GestureDetector(
                      onTap: () {
                        goRouter.pushNamed(
                          AppRoutes.addInventorySpecification,
                          queryParameters: {
                            "flatModel": Uri.encodeQueryComponent(
                              EncryptionManager.encryptData(jsonEncode(flat)),
                            ),
                            "floorModel": Uri.encodeQueryComponent(
                              EncryptionManager.encryptData(jsonEncode(floor)),
                            ),
                            "approval": Uri.encodeQueryComponent(
                              EncryptionManager.encryptData(approvalStatus),
                            ),
                          },
                        );
                      },
                      child: const Icon(
                        Icons.remove_red_eye_outlined,
                        size: 18,
                      ),
                    ),

                  if (showEdit) ...[
                    GestureDetector(
                      onTap: () async {
                        await goRouter.pushNamed(
                          AppRoutes.addInventorySpecification,
                          queryParameters: {
                            "flatModel": Uri.encodeQueryComponent(
                              EncryptionManager.encryptData(jsonEncode(flat)),
                            ),
                            "floorModel": Uri.encodeQueryComponent(
                              EncryptionManager.encryptData(jsonEncode(floor)),
                            ),
                            "approval": Uri.encodeQueryComponent(
                              EncryptionManager.encryptData(approvalStatus),
                            ),
                          },
                        );

                        if (mounted) {
                          _inventoryCubit.getInventory(
                            context,
                            _project.projectId,
                          );
                        }
                      },
                      child: const Icon(Icons.edit, size: 18),
                    ),
                  ],

                  if (showDelete) ...[
                    const SizedBox(width: 15),
                    GestureDetector(
                      onTap: () {
                        _showPopupToDeleteInventoryFlat(
                          context,
                          flat,
                          floorIndex,
                          wingIndex,
                          buildingIndex,
                          flatIndex,
                        );
                      },
                      child: SvgPicture.asset(
                        AppAssets.deleteIcon2,
                        height: 18,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          if (flat.ownerName.isNotEmpty &&
              flat.flatStatus.toLowerCase() == "booked") ...[
            verticalSpacing(),
            InkWell(
              onTap: () {
                goRouter.pushNamed(
                  AppRoutes.viewBooking,
                  queryParameters: {
                    "bookingId": Uri.encodeQueryComponent(
                      EncryptionManager.encryptData(flat.bookingId.toString()),
                    ),
                    "projectId": Uri.encodeQueryComponent(
                      EncryptionManager.encryptData(
                        _project.projectId.toString(),
                      ),
                    ),
                  },
                );
              },
              child: Text(
                "Owner : ${flat.ownerName}",
                style: AppTextStyle.ts14M(color: AppColor.primary).copyWith(
                  decoration: TextDecoration.underline,
                  decorationColor: AppColor.primary,
                ),
              ),
            ),
          ],
          if (showBookBtn) ...[
            verticalSpacing(),
            CustomButton(
              text: "Book",
              onPressed: () async {
                List<Map<String, dynamic>> list = [
                  {
                    "inventoryBuildingId": flat.inventoryBuildingId,
                    "inventoryFlatFloorBasementPodiumWingId":
                        flat.inventoryFlatFloorBasementPodiumWingId,
                    "inventoryFlatId": flat.inventoryFlatId,
                    "buildingNumber": flat.buildingNumber,
                    "wing": flat.wing,
                    "floor": flat.floor,
                    "flat": flat.flat,
                    "flatType": flat.flatType,
                    "flatConfiguration": flat.flatConfiguration,
                    "reraCarpetAreaSqFt": flat.reraCarpetAreaSqFt,
                    "buildingIndex": buildingIndex,
                    "wingIndex": wingIndex,
                    "floorIndex": floorIndex,
                    "flatIndex": flatIndex,
                  },
                ];

                final result = await goRouter.pushNamed(
                  AppRoutes.addBooking,
                  queryParameters: {
                    "inventoryObject": Uri.encodeComponent(
                      EncryptionManager.encryptData(jsonEncode(list)),
                    ),
                  },
                );

                if (result != null &&
                    result is Map<String, dynamic> &&
                    context.mounted) {
                  _inventoryCubit.updateFlatStatus(
                    inventoryFlatId: flat.inventoryFlatId,
                    flatStatus: result["status"],
                    ownerName: result["ownerName"],
                  );
                }
              },
            ),
          ],
          if (flat.flatStatus.toLowerCase() == "blocked") ...[
            verticalSpacing(),
            Text(
              "Blocked by ${flat.modifiedBy.isNotEmpty ? flat.modifiedBy : "Unknown"} on "
              "${formatDateTimeReadable(flat.modifiedDate)}",
              textAlign: TextAlign.center,
              style: AppTextStyle.ts12M(color: AppColor.black),
            ),
          ],
          if (flat.flatStatus.toLowerCase() == "hold") ...[
            verticalSpacing(),
            Text(
              "Hold by ${flat.modifiedBy.isNotEmpty ? flat.modifiedBy : "Unknown"} on "
              "${formatDateTimeReadable(flat.modifiedDate)}",
              textAlign: TextAlign.center,
              style: AppTextStyle.ts12M(color: AppColor.brown),
            ),
          ],
        ],
      ),
    );
  }

  // COUNTS ROW
  Widget _buildCountsRow(List wingList) {
    // Get current selected wing index
    final currentWingIndex = _wingTabController?.index ?? 0;

    if (currentWingIndex >= wingList.length) {
      return const SizedBox.shrink();
    }

    final selectedWing = wingList[currentWingIndex];
    final wingKey =
        "${selectedWing.inventoryBuildingId}_${selectedWing.inventoryFlatFloorBasementPodiumWingId}";

    final counts =
        context.read<InventoryCubit>().state.wingCounts[wingKey] ??
        {
          "total": 0,
          "available": 0,
          "blocked": 0,
          "booked": 0,
          "hold": 0,
          "alloted": 0,
        };

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
          _buildCountItem("Total", counts['total'] ?? 0, AppColor.black),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                spacing: 10,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCountItem(
                    "Available",
                    counts['available'] ?? 0,
                    Color(0xff28653F),
                  ),
                  _buildCountItem(
                    "Booked",
                    counts['booked'] ?? 0,
                    Color(0xffFF0000),
                  ),
                  _buildCountItem(
                    "Alloted",
                    counts['alloted'] ?? 0,
                    Color(0xff561F64),
                  ),
                  _buildCountItem("Hold", counts['hold'] ?? 0, AppColor.brown),
                  _buildCountItem(
                    "Blocked",
                    counts['blocked'] ?? 0,
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
        context.watch<InventoryCubit>().state.selectedFlatStatus;

    final isSelected = selectedFilter?.toLowerCase() == label.toLowerCase();

    return InkWell(
      onTap: () {
        final cubit = context.read<InventoryCubit>();

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

  // STATUS COLOR
  Color _statusColor(String status) {
    switch (status) {
      case "Available":
        return Color(0xff60D669).withValues(alpha: 0.15);
      case "Blocked":
        return Color(0xff1D1D1D).withValues(alpha: 0.15);
      case "Booked":
        return Color(0xffFF0000).withValues(alpha: 0.15);
      case "Hold":
        return AppColor.holdYellowColor.withValues(alpha: 0.15);
      case "Alloted":
        return AppColor.purple.withValues(alpha: 0.15);
      default:
        return Color(0xff1D1D1D).withValues(alpha: 0.15);
    }
  }
}
