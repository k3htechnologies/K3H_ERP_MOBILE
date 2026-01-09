import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/inventory/presentation/cubit/inventory_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
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

  // PROJECT
  late ProjectModel _project;

  // AUTHORIZATION
  late AuthorizationModel _routAuthorizationModel;

  // TEXT EDIT CONTROLLER
  late TextEditingController _searchC;

  // TAB CONTROLLERS
  TabController? _buildingTabController;
  TabController? _wingTabController;

  @override
  void initState() {
    super.initState();
    _routAuthorizationModel =
    Authorization.routeAuthorizationMap[AppRoutes.inventory]!;
    _initControllers();
    _project = getProject();
    _inventoryCubit = context.read<InventoryCubit>();
    _inventoryCubit.getInventory(context, 2);
  }

  @override
  void dispose() {
    _buildingTabController?.dispose();
    _wingTabController?.dispose();
    _searchC.dispose();
    super.dispose();
  }

  void _initControllers() {
    _searchC = TextEditingController();
  }

  void _initBuildingController(InventoryState state) {
    _buildingTabController?.dispose();

    _buildingTabController = TabController(
      length: state.buildingList.length,
      vsync: this,
      initialIndex: state.currentTabIndex,
    );

    _buildingTabController!.addListener(() {
      if (!_buildingTabController!.indexIsChanging) {
        _inventoryCubit.onTabChanged(
          _buildingTabController!.index,
          context,
        );
      }
    });
  }

  void _initWingController(List wingList) {
    _wingTabController?.dispose();

    _wingTabController = TabController(
      length: wingList.length,
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        screenTitle: "Project Inventory",
        authorization: _routAuthorizationModel,
        onSearchSubmit: (value) {},
        textController: _searchC,
        onAddCallback: () {},
        onExportCallback: (value) {},
      ),
      body: SafeArea(
        child: BlocBuilder<InventoryCubit, InventoryState>(
          builder: (context, state) {

            if (state.isLoading! && state.buildingList.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.buildingList.isEmpty) {
              return const Center(child: Text("No data"));
            }

            // -------- BUILDING CONTROLLER --------
            if (_buildingTabController == null ||
                _buildingTabController!.length != state.buildingList.length) {
              _buildingTabController = TabController(
                length: state.buildingList.length,
                vsync: this,
                initialIndex: state.currentTabIndex,
              );

              _buildingTabController!.addListener(() {
                if (!_buildingTabController!.indexIsChanging) {
                  _inventoryCubit.onTabChanged(
                    _buildingTabController!.index,
                    context,
                  );
                }
              });
            }

            // -------- WING CONTROLLER --------
            final selectedBuilding =
            state.buildingList[state.currentTabIndex];

            final wingList = selectedBuilding.wingList;

            if (wingList.isNotEmpty) {

              if (_wingTabController == null ||
                  _wingTabController!.length != wingList.length) {

                _wingTabController?.dispose();

                _wingTabController = TabController(
                  length: wingList.length,
                  vsync: this,
                );
              }
            }

            return Column(
              children: [

                _buildBuildingTab(state),

                verticalSpacing(),

                if (wingList.isNotEmpty) _buildWingTab(wingList),

                if (_wingTabController != null)
                  Expanded(
                    child: TabBarView(
                      controller: _wingTabController,
                      children: wingList
                          .map((w) => _buildFloorList(w.floorList))
                          .toList(),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFloorList(List floorList) {
    if (floorList.isEmpty) {
      return Center(child: Text("No floors found"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: floorList.length,
      itemBuilder: (context, index) {
        final floor = floorList[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColor.grey.withValues(alpha: 0.2),
            ),
          ),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 16),
            title: Text(
              "Floor : ${floor.floor}",
              style: AppTextStyle.ts14M(),
            ),
            subtitle: Text(
              "Total Flats : ${floor.flatList.length}",
              style: AppTextStyle.ts12R(color: AppColor.grey),
            ),
            children: [
              _buildFlatList(floor.flatList),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUI() {
    return BlocBuilder<InventoryCubit, InventoryState>(
      builder: (context, state) {
        if (state.isLoading == true &&
            state.buildingList.isEmpty) {
          return const SizedBox(height: 48);
        }

        if (state.buildingList.isEmpty) {
          return const SizedBox.shrink();
        }

        final selectedBuilding =
        state.buildingList[state.currentTabIndex];

        final wingList = selectedBuilding.wingList;

        return Column(
          children: [

            // BUILDING TAB
            _buildBuildingTab(state),

            verticalSpacing(),

            // WING TAB
            if (wingList.isNotEmpty) _buildWingTab(wingList),

            // FLOOR VIEW
            if (_wingTabController != null)
              Expanded(
                child: TabBarView(
                  controller: _wingTabController,
                  children: wingList
                      .map((wing) => _buildFloorList(wing.floorList))
                      .toList(),
                ),
              )
            else
              const SizedBox.shrink(),
          ],
        );
      },
    );
  }

  Widget _buildBuildingTab(InventoryState state) {
    if (_buildingTabController == null) {
      return const SizedBox.shrink(); // <-- IMPORTANT
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
            border: Border.all(
              color: AppColor.grey.withValues(alpha: 0.2),
            ),
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
            labelPadding:
            const EdgeInsets.symmetric(horizontal: 16),
            tabs: state.buildingList
                .map((b) => Tab(text: b.buildingNumber))
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildWingTab(List wingList) {
    if (_wingTabController == null) {
      return const SizedBox.shrink(); // <-- IMPORTANT
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
            border: Border.all(
              color: AppColor.grey.withValues(alpha: 0.2),
            ),
          ),
          child: TabBar(
            controller: _wingTabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: AppColor.primary,
            unselectedLabelColor: AppColor.grey,
            indicator: BoxDecoration(
              color: AppColor.grey10,
              borderRadius: BorderRadius.circular(8),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            labelStyle: AppTextStyle.ts14M(),
            unselectedLabelStyle: AppTextStyle.ts14M(),
            labelPadding:
            const EdgeInsets.symmetric(horizontal: 16),
            tabs: wingList
                .map((w) => Tab(text: w.wing))
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildFlatList(List flatList) {
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
      children: flatList.map((flat) {
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _statusColor(flat.flatStatus),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Unit No. : ${flat.flat}",
                    style: AppTextStyle.ts14M(),
                  ),
                  verticalSpacing(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: _buildColumnTitleValue(title: "Type", value: flat.flatType)),
                      Expanded(child: _buildColumnTitleValue(title: "Area(Sq.ft)", value: flat.reraCarpetAreaSqFt.toString())),
                      Expanded(child: _buildColumnTitleValue(title: "Configuration", value: flat.flatConfiguration)),
                    ],
                  ),
                ],
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor(flat.flatStatus),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  flat.flatStatus,
                  style: AppTextStyle.ts12M(color: AppColor.white),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildColumnTitleValue({required String title, required String value}){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyle.ts12R(color: AppColor.grey)),
        verticalSpacing(height: 5),
        Text(value, style: AppTextStyle.ts14M()),
      ],
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case "Available":
        return AppColor.lightGreen;
      case "Booked":
        return AppColor.red;
      case "Hold":
        return AppColor.yellow;
      default:
        return AppColor.grey;
    }
  }
}
