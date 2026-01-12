import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/inventory/data/model/building.model.dart';
import 'package:k3h_erp_app/features/inventory/presentation/cubit/inventory_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
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

  // AUTHORIZATION
  late AuthorizationModel _routAuthorizationModel;

  // CURRENT PROJECT
  late ProjectModel _project;

  // TEXT EDIT CONTROLLER
  late TextEditingController _searchC;

  // TAB CONTROLLERS
  TabController? _buildingTabController;
  TabController? _wingTabController;

  // EXPANSION STATE
  final Set<int> _expandedFloors = {};
  bool _isDisposing = false;

  @override
  void initState() {
    super.initState();
    _project = getProject();
    _routAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.inventory]!;
    _initControllers();
    _inventoryCubit = context.read<InventoryCubit>();

    // Call API directly in initState, similar to DepartmentMasterScreen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final state = _inventoryCubit.state;
        if (state.buildingList.isEmpty) {
          _inventoryCubit.getInventory(context, _project.projectId);
        } else {
          // Initialize controllers if data already exists
          _initializeControllersIfNeeded(state);
        }
      }
    });
  }

  void _initializeControllersIfNeeded(InventoryState state) {
    if (!mounted || _isDisposing) return;

    bool needsRebuild = false;

    // Initialize building controller if we have data
    if (state.buildingList.isNotEmpty) {
      if (_buildingTabController == null ||
          _buildingTabController!.length != state.buildingList.length) {
        _initBuildingController(state);
        needsRebuild = true;
      }
    }

    // Initialize wing controller if we have wings
    if (state.buildingList.isNotEmpty &&
        state.currentTabIndex < state.buildingList.length) {
      final selectedBuilding = state.buildingList[state.currentTabIndex];
      final wingList = selectedBuilding.wingList;

      if (wingList.isNotEmpty) {
        if (_wingTabController == null ||
            _wingTabController!.length != wingList.length) {
          _initWingController(wingList);
          needsRebuild = true;
        }
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
    _searchC.dispose();
    super.dispose();
  }

  // BUILDING TAB
  void _onBuildingTabChanged() {
    if (_buildingTabController == null || !mounted) return;
    if (!_buildingTabController!.indexIsChanging) {
      _inventoryCubit.onTabChanged(_buildingTabController!.index, context);
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
      print('Error initializing building controller: $e');
    }
  }

  // WING CONTROLLER
  void _initWingController(List wingList) {
    if (!mounted || _isDisposing) return;

    if (_wingTabController != null) {
      _wingTabController!.removeListener(_onWingTabChanged);
      _wingTabController!.dispose();
      _wingTabController = null;
    }

    if (!mounted || _isDisposing) return;

    _wingTabController = TabController(length: wingList.length, vsync: this);
    _wingTabController!.addListener(_onWingTabChanged);
  }

  // WING TAB
  void _onWingTabChanged() {
    if (_wingTabController == null || !mounted) return;
    if (!_wingTabController!.indexIsChanging) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Project Inventory",
        authorization: _routAuthorizationModel,
        onExportCallback: (value) {
          _inventoryCubit.exportInventory(context, _project.projectId, value);
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
          _expandedFloors.clear();
          _inventoryCubit.getInventory(context, _project.projectId);
        },
      ),
      body: SafeArea(
        child: BlocListener<InventoryCubit, InventoryState>(
          listener: (context, state) {
            if (!mounted || _isDisposing) return;

            bool needsRebuild = false;

            // Initialize building controller if we have data
            if (state.buildingList.isNotEmpty) {
              if (_buildingTabController == null ||
                  _buildingTabController!.length != state.buildingList.length) {
                _initBuildingController(state);
                needsRebuild = true;
              }
            }

            // Initialize wing controller if we have wings
            if (state.buildingList.isNotEmpty &&
                state.currentTabIndex < state.buildingList.length) {
              final selectedBuilding =
                  state.buildingList[state.currentTabIndex];
              final wingList = selectedBuilding.wingList;

              if (wingList.isNotEmpty) {
                if (_wingTabController == null ||
                    _wingTabController!.length != wingList.length) {
                  _initWingController(wingList);
                  needsRebuild = true;
                }
              } else {
                if (_wingTabController != null && !_isDisposing) {
                  _wingTabController!.removeListener(_onWingTabChanged);
                  _wingTabController!.dispose();
                  _wingTabController = null;
                  needsRebuild = true;
                }
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
          child: BlocBuilder<InventoryCubit, InventoryState>(
            builder: (context, state) {
              if (state.isLoading! && state.buildingList.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.buildingList.isEmpty) {
                return const Center(child: Text("No data"));
              }

              final selectedBuilding =
                  state.buildingList[state.currentTabIndex];

              final wingList = selectedBuilding.wingList;

              // Show loading if building controller is not initialized yet
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
                                        .map(
                                          (w) => _buildFloorList(
                                            w.floorList,
                                            w,
                                            selectedBuilding,
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
    List floorList,
    WingModel wing,
    BuildingModel building,
  ) {
    if (floorList.isEmpty) {
      return Center(child: Text("No floors found"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: floorList.length,
      itemBuilder: (context, index) {
        final floor = floorList[index];
        final isExpanded = _expandedFloors.contains(index);

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
                  setState(() {
                    if (isExpanded) {
                      _expandedFloors.remove(index);
                    } else {
                      _expandedFloors.add(index);
                    }
                  });
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
                            Text(
                              "Floor : ${floor.floor}",
                              style: AppTextStyle.ts14M(),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Total Flats : ${floor.flatList.length}",
                              style: AppTextStyle.ts12R(color: AppColor.grey),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              goRouter.pushNamed(
                                AppRoutes.addInventorySpecification,
                                queryParameters: {
                                  "flatModel": Uri.encodeQueryComponent(
                                    EncryptionManager.encryptData(
                                      jsonEncode(
                                        FlatModel(
                                          inventoryFlatId: 0,
                                          uniquekey: "",
                                          inventoryBuildingId:
                                              floor.inventoryBuildingId,
                                          buildingNumber:
                                              building.buildingNumber,
                                          inventoryFlatFloorBasementPodiumWingId:
                                              floor
                                                  .inventoryFlatFloorBasementPodiumWingId,
                                          wing: wing.wing,
                                          inventoryFloorId:
                                              floor.inventoryFloorId,
                                          floor: floor.floor,
                                          flat: "",
                                          reraCarpetAreaSqFt: 0,
                                          flatType: "",
                                          flatConfiguration: "",
                                          flatStatus: "",
                                          ownerName: "",
                                          flatFacing: "",
                                          bookingId: 0,
                                          bookingCreatedById: 0,
                                          bookingCreatedBy: "",
                                          bookingCreatedDate: DateTime.now(),
                                          specificationList: [
                                            FlatSpecificationModel(
                                              inventoryFlatSpecificationId: 0,
                                              uniquekey: "",
                                              inventoryBuildingId:
                                                  floor.inventoryBuildingId,
                                              inventoryFlatFloorBasementPodiumWingId:
                                                  floor
                                                      .inventoryFlatFloorBasementPodiumWingId,
                                              inventoryFloorId:
                                                  floor.inventoryFloorId,
                                              inventoryFlatId: 0,
                                              flatLayout: "Bedroom 1",
                                              flatLayoutAreaSqFt: 0,
                                              flatLayoutLengthSqFt: 0,
                                              flatLayoutWidthSqFt: 0,
                                              note: "",
                                            ),
                                            FlatSpecificationModel(
                                              inventoryFlatSpecificationId: 0,
                                              uniquekey: "",
                                              inventoryBuildingId:
                                                  floor.inventoryBuildingId,
                                              inventoryFlatFloorBasementPodiumWingId:
                                                  floor
                                                      .inventoryFlatFloorBasementPodiumWingId,
                                              inventoryFloorId:
                                                  floor.inventoryFloorId,
                                              inventoryFlatId: 0,
                                              flatLayout: "Hall",
                                              flatLayoutAreaSqFt: 0,
                                              flatLayoutLengthSqFt: 0,
                                              flatLayoutWidthSqFt: 0,
                                              note: "",
                                            ),
                                            FlatSpecificationModel(
                                              inventoryFlatSpecificationId: 0,
                                              uniquekey: "",
                                              inventoryBuildingId:
                                                  floor.inventoryBuildingId,
                                              inventoryFlatFloorBasementPodiumWingId:
                                                  floor
                                                      .inventoryFlatFloorBasementPodiumWingId,
                                              inventoryFloorId:
                                                  floor.inventoryFloorId,
                                              inventoryFlatId: 0,
                                              flatLayout: "Kitchen",
                                              flatLayoutAreaSqFt: 0,
                                              flatLayoutLengthSqFt: 0,
                                              flatLayoutWidthSqFt: 0,
                                              note: "",
                                            ),
                                            FlatSpecificationModel(
                                              inventoryFlatSpecificationId: 0,
                                              uniquekey: "",
                                              inventoryBuildingId:
                                                  floor.inventoryBuildingId,
                                              inventoryFlatFloorBasementPodiumWingId:
                                                  floor
                                                      .inventoryFlatFloorBasementPodiumWingId,
                                              inventoryFloorId:
                                                  floor.inventoryFloorId,
                                              inventoryFlatId: 0,
                                              flatLayout: "Common Toilet",
                                              flatLayoutAreaSqFt: 0,
                                              flatLayoutLengthSqFt: 0,
                                              flatLayoutWidthSqFt: 0,
                                              note: "",
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  "floorModel": Uri.encodeQueryComponent(
                                    EncryptionManager.encryptData(
                                      jsonEncode(floor),
                                    ),
                                  ),
                                },
                              );
                            },
                            icon: Icon(
                              Icons.add,
                              size: 16,
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
                              child: _buildFlatList(floor.flatList, floor),
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
  }

  // BUILDING TAB
  Widget _buildBuildingTab(InventoryState state) {
    if (_buildingTabController == null) {
      return const SizedBox.shrink();
    }

    if (_buildingTabController!.length != state.buildingList.length) {
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
            tabs:
                state.buildingList
                    .map((b) => Tab(text: b.buildingNumber))
                    .toList(),
          ),
        ),
      ),
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
            tabs: wingList.map((w) => Tab(text: w.wing)).toList(),
          ),
        ),
      ),
    );
  }

  // FLAT LIST
  Widget _buildFlatList(List flatList, FloorModel floor) {
    if (flatList.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          "No flats available",
          style: AppTextStyle.ts12R(color: AppColor.grey),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children:
          flatList.map((flat) {
            return Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _statusColor(flat.flatStatus),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Unit No. : ${flat.flat}",
                          style: AppTextStyle.ts14M(),
                        ),
                        verticalSpacing(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: _buildColumnTitleValue(
                                title: "Type",
                                value:
                                    flat.flatType != "" ? flat.flatType : "-",
                              ),
                            ),
                            Expanded(
                              child: _buildColumnTitleValue(
                                title: "Area(Sq.ft)",
                                value:
                                    flat.reraCarpetAreaSqFt.toString().isEmpty
                                        ? "-"
                                        : flat.reraCarpetAreaSqFt.toString(),
                              ),
                            ),
                            Expanded(
                              child: _buildColumnTitleValue(
                                title: "Configuration",
                                value:
                                    flat.flatConfiguration.toString().isEmpty
                                        ? "-"
                                        : flat.flatConfiguration,
                              ),
                            ),
                          ],
                        ),
                        verticalSpacing(),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 5),
                                decoration: BoxDecoration(
                                  color: AppColor.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    flat.flatStatus,
                                    style: AppTextStyle.ts14M(
                                      color:
                                          flat.flatStatus == "Blocked"
                                              ? AppColor.error
                                              : flat.flatStatus == "Member"
                                              ? AppColor.purple
                                              : flat.flatStatus == "Hold"
                                              ? AppColor.yellow
                                              : flat.flatStatus == "Available"
                                              ? AppColor.darkGreen
                                              : AppColor.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            horizontalSpacing(),
                            flat.flatStatus == "Blocked"
                                ? Icon(Icons.remove_red_eye_outlined, size: 18)
                                : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  spacing: 15,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        goRouter.pushNamed(
                                          AppRoutes.addInventorySpecification,
                                          queryParameters: {
                                            "flatModel":
                                                Uri.encodeQueryComponent(
                                                  EncryptionManager.encryptData(
                                                    jsonEncode(flat),
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
                                      },
                                      child: Icon(Icons.edit, size: 18),
                                    ),
                                    SvgPicture.asset(
                                      AppAssets.deleteIcon2,
                                      height: 18,
                                    ),
                                  ],
                                ),
                          ],
                        ),
                        if (flat.ownerName != "") verticalSpacing(),
                        if (flat.ownerName != "")
                          Text(
                            "Owner : ${flat.ownerName}",
                            style: AppTextStyle.ts12R(color: AppColor.primary),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  // COUNTS
  Map<String, int> _calculateFlatCounts(dynamic wing) {
    int totalFlats = 0;
    int availableCount = 0;
    int blockedCount = 0;
    int holdCount = 0;
    int memberCount = 0;

    for (var floor in wing.floorList) {
      for (var flat in floor.flatList) {
        totalFlats++;
        switch (flat.flatStatus) {
          case "Available":
            availableCount++;
            break;
          case "Blocked":
            blockedCount++;
            break;
          case "Hold":
            holdCount++;
            break;
          case "Member":
            memberCount++;
            break;
        }
      }
    }

    return {
      'total': totalFlats,
      'available': availableCount,
      'member': memberCount,
      'hold': holdCount,
      'blocked': blockedCount,
    };
  }

  // COUNTS ROW
  Widget _buildCountsRow(List wingList) {
    // Get current selected wing index
    final currentWingIndex = _wingTabController?.index ?? 0;

    if (currentWingIndex >= wingList.length) {
      return const SizedBox.shrink();
    }

    final selectedWing = wingList[currentWingIndex];
    final counts = _calculateFlatCounts(selectedWing);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColor.grey.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildCountItem("Total", counts['total']!, AppColor.primary),
          _buildCountItem(
            "Available",
            counts['available']!,
            AppColor.darkGreen,
          ),
          _buildCountItem("Member", counts['member']!, AppColor.purple),
          _buildCountItem("Hold", counts['hold']!, AppColor.yellow),
          _buildCountItem("Blocked", counts['blocked']!, AppColor.error),
        ],
      ),
    );
  }

  // COUNT ITEM
  Widget _buildCountItem(String label, int count, Color color) {
    return Row(
      children: [
        Text(
          count.toString(),
          style: AppTextStyle.ts12R().copyWith(fontSize: 10, color: color),
        ),
        horizontalSpacing(width: 5),
        Text(
          label,
          style: AppTextStyle.ts12R().copyWith(fontSize: 10, color: color),
        ),
      ],
    );
  }

  // COLUMN TITLE VALUE
  Widget _buildColumnTitleValue({
    required String title,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyle.ts12R(color: AppColor.grey)),
        verticalSpacing(height: 5),
        Text(value, style: AppTextStyle.ts14M()),
      ],
    );
  }

  // STATUS COLOR
  Color _statusColor(String status) {
    switch (status) {
      case "Available":
        return AppColor.lightGreen;
      case "Blocked":
        return AppColor.lightRed;
      case "Hold":
        return AppColor.lightYellow;
      case "Member":
        return AppColor.purple.withValues(alpha: .2);
      default:
        return AppColor.grey;
    }
  }
}
