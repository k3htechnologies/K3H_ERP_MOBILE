import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/request_management/presentation/pages/widgets/document_preview.screen.dart';
import 'package:k3h_erp_app/features/estimation_and_budget/construction_area/data/model/building_summary.model.dart';
import 'package:k3h_erp_app/features/estimation_and_budget/construction_area/presentation/cubit/construction_area_cubit.dart';
import 'package:k3h_erp_app/features/estimation_and_budget/construction_area/presentation/pages/widgets/wing_section.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/functions/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_export_button.dart';
import 'package:k3h_erp_app/widgets/app_bar/search_widget.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/chip_style_tab_bar.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/expansion_tile/custom_expansion_tile.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ConstructionAreaScreen extends StatefulWidget {
  const ConstructionAreaScreen({super.key});

  @override
  State<ConstructionAreaScreen> createState() => _ConstructionAreaScreenState();
}

class _ConstructionAreaScreenState extends State<ConstructionAreaScreen>
    with TickerProviderStateMixin {
  // CUBIT
  late ConstructionAreaCubit _constructionAreaCubit;
  // AUTHORIZATION MODEL
  late AuthorizationModel _routeAuthorizationModel;

  // TEXT EDIT CONTROLLER
  late TextEditingController _searchConstructionAreaC, _searchComparativeC;

  //PAGINATION
  late ScrollController scrollController;
  Timer? _debounce;

  // TAB CONTROLLERS
  late TabController _tabController;
  late List<String> _tabs;
  final ValueNotifier<int> _filterConstructionAreaCount = ValueNotifier(0);
  final ValueNotifier<int> _filterComparativeCount = ValueNotifier(0);
  late ValueNotifier<ProjectModel> _selectedProjectNotifier;
  @override
  void initState() {
    super.initState();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.constructionArea]!;
    _constructionAreaCubit = context.read<ConstructionAreaCubit>();
    _selectedProjectNotifier = ValueNotifier<ProjectModel>(getProject());
    _tabs = ["Construction Area", "Comparative"];
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    _initControllers();
    _onScroll();
    _loadData();
  }

  @override
  void dispose() {
    _searchConstructionAreaC.dispose();
    _searchComparativeC.dispose();
    scrollController.dispose();
    _filterConstructionAreaCount.dispose();
    _filterComparativeCount.dispose();
    _selectedProjectNotifier.dispose();
    super.dispose();
  }

  void _loadData() {
    _constructionAreaCubit.getConstructionAreaList(
      context,
      1,
      projectId: _selectedProjectNotifier.value.projectId,
    );
  }

  void _initControllers() {
    _searchConstructionAreaC = TextEditingController();
    _searchComparativeC = TextEditingController();
  }

  // TAB CHANGE METHOD
  void _onTabChanged() async {
    if (_tabController.indexIsChanging) return;
    final selectedTab = _tabs[_tabController.index];
    _searchConstructionAreaC.clear();
    _searchComparativeC.clear();
    if (selectedTab == "Construction Area") {
      _constructionAreaCubit.getConstructionAreaList(
        context,
        1,
        projectId: _selectedProjectNotifier.value.projectId,
      );
    } else if (selectedTab == "Comparative") {
      _constructionAreaCubit.getConstructionAreaComparativeList(
        context,
        projectId: _selectedProjectNotifier.value.projectId,
      );
    }
  }

  void _onScroll() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !_constructionAreaCubit.state.isLoading! &&
          _constructionAreaCubit.state.constructionAreaList.length <
              _constructionAreaCubit.state.totalNumberOfRecord) {
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _constructionAreaCubit.getConstructionAreaList(
            context,
            _constructionAreaCubit.state.currentPage + 1,
            projectId: _selectedProjectNotifier.value.projectId,
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        screenTitle: "Construction Area",
        authorization: _routeAuthorizationModel,
        onProjectChangeCallback: (value) {
          final selectedTab = _tabs[_tabController.index];
          _searchConstructionAreaC.clear();
          _searchComparativeC.clear();
          if (selectedTab == "Construction Area") {
            _constructionAreaCubit.getConstructionAreaList(
              context,
              1,
              projectId: _selectedProjectNotifier.value.projectId,
            );
          } else if (selectedTab == "Comparative") {
            _constructionAreaCubit.getConstructionAreaComparativeList(
              context,
              projectId: _selectedProjectNotifier.value.projectId,
            );
          }
        },
      ),
      body: BlocBuilder<ConstructionAreaCubit, ConstructionAreaState>(
        builder: (context, state) {
          final pages = [
            _buildConstructionAreaWidget(context),
            _buildComparativeWidget(context),
          ];
          return SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ChipStyleTabBar(controller: _tabController, tabs: _tabs),
                _buildSearchBar(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: pages,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildConstructionAreaWidget(BuildContext context) {
    return BlocBuilder<ConstructionAreaCubit, ConstructionAreaState>(
      builder: (context, state) {
        if (state.isLoading == true && state.constructionAreaList.isEmpty) {
          return Center(child: loader());
        }
        if (state.constructionAreaList.isEmpty) {
          return Center(
            child: noDataWidget(message: "No Construction Area Data Found"),
          );
        }

        final groups = _constructionAreaCubit.groupByBuildingFloor(
          state.constructionAreaList,
        );

        return ListView.separated(
          controller: scrollController,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.all(20.0),
          itemCount: groups.length + 1,
          separatorBuilder: (_, __) => verticalSpacing(height: 12.sp),
          itemBuilder: (context, index) {
            if (index == groups.length) {
              return state.constructionAreaList.length <
                      state.totalNumberOfRecord
                  ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                  : const SizedBox.shrink();
            }
            return _buildFloorCard(groups[index]);
          },
        );
      },
    );
  }

  Widget _buildFloorCard(BuildingFloorGroup group) {
    final wings = _constructionAreaCubit.wingsOfFloor(
      group.buildingNumber,
      group.floor,
    );

    return CustomExpandableCard(
      key: PageStorageKey('${group.buildingNumber}||${group.floor}'),
      padding: EdgeInsets.all(12.sp),
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconContainer(
                containerSize: 28.sp,
                iconSize: 12.sp,
                icon: LucideIcons.building2,
                backgroundColor: AppColor.lightBlue,
                iconColor: AppColor.primary,
              ),
              horizontalSpacing(width: 8.sp),
              Expanded(
                child: Text(
                  "${group.buildingNumber} - ${group.floor}",
                  style: AppTextStyle.ts16SB(),
                ),
              ),
            ],
          ),
          verticalSpacing(height: 10.sp),
          Divider(thickness: 1.sp, color: AppColor.dividerColor),
          verticalSpacing(height: 10.sp),
          Row(
            children: [
              _countCell("Units", group.unitCount),
              _countCell("Wings", group.wingCount),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          for (int i = 0; i < wings.length; i++)
            WingSection(
              key: ValueKey(
                '${group.buildingNumber}||${group.floor}||${wings[i].wing}',
              ),
              wing: wings[i],
              initiallyExpanded: i == 0,
            ),
        ],
      ),
    );
  }

  Widget _countCell(String title, int value) {
    return Expanded(
      child: Column(
        children: [
          Text(title, style: AppTextStyle.ts12R(color: AppColor.grey)),
          verticalSpacing(height: 4.sp),
          Text(value.toString(), style: AppTextStyle.ts14SB()),
        ],
      ),
    );
  }

  Widget _buildComparativeWidget(BuildContext context) {
    return BlocBuilder<ConstructionAreaCubit, ConstructionAreaState>(
      builder: (context, state) {
        if (state.isComparativeLoading &&
            state.constructionAreaComparativeList.isEmpty) {
          return Center(child: loader());
        }
        if (state.constructionAreaComparativeList.isEmpty) {
          return Center(child: noDataWidget(message: "No Data Found"));
        }
        return ListView.builder(
          controller: scrollController,
          padding: EdgeInsets.all(20.0),
          itemCount: state.constructionAreaComparativeList.length,
          itemBuilder: (context, index) {
            final item = state.constructionAreaComparativeList[index];
            return Container(
              margin: EdgeInsets.only(bottom: 16.sp),
              padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 16.sp),
              decoration: commonCardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Color(0xff0058BE),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          horizontalSpacing(width: 12.sp),
                          Text(
                            item.type,
                            style: AppTextStyle.ts16M(color: AppColor.black),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          CustomIconButton.edit(
                            onPressed: () async {
                              await goRouter.pushNamed(
                                AppRoutes.addConstructionAreaComparative,
                                queryParameters: {
                                  "constructionAreaComparative":
                                      Uri.encodeQueryComponent(
                                        EncryptionManager.encryptData(
                                          jsonEncode(item.toJson()),
                                        ),
                                      ),
                                  "index": index.toString(),
                                  "isEdit": Uri.encodeQueryComponent(
                                    EncryptionManager.encryptData(
                                      true.toString(),
                                    ),
                                  ),
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  verticalSpacing(height: 12.sp),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      buildColumnTitleValue(
                        title: "Area By PL Line (SqMt)",
                        value: "${item.areaByPlLineSqMt} SqMt",
                      ),
                      buildColumnTitleValue(
                        title: "Variation (%)",
                        value: item.variationInPercentage.toString(),
                      ),
                    ],
                  ),
                  verticalSpacing(height: 12.sp),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      buildColumnTitleValue(
                        title: "Annexure",
                        value: "View",
                        customValueWidget: DocumentPreviewText(
                          title: "Term Sheet Document",
                          text: item.annexureUrl.isEmpty ? "-" : "View",
                          fileUrl: item.annexureUrl,
                        ),
                      ),
                      buildColumnTitleValue(
                        title: "Remark",
                        value:
                            item.remark.trim().isEmpty
                                ? "-"
                                : item.remark.trim(),
                        customValueWidget:
                            item.remark.trim().isNotEmpty
                                ? GestureDetector(
                                  onTap: () {
                                    DialogHelper.showNoteDialog(
                                      context,
                                      note: item.remark,
                                      title: "Remark",
                                    );
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 10.sp),
                                    child: Icon(
                                      Icons.info_outline,
                                      size: 18,
                                      color: AppColor.primary,
                                    ),
                                  ),
                                )
                                : null,
                      ),
                    ],
                  ),
                  verticalSpacing(height: 12.sp),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      buildColumnTitleValue(
                        title: "Last Modified By",
                        value: item.modifiedBy,
                      ),
                      buildColumnTitleValue(
                        title: "Last Modified Date",
                        value: formatDateTimeAsDDMMMYYYY(item.modifiedDate),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showBottomSheetToFilterConstructionArea(
    BuildContext context,
  ) async {
    bool manualClose = false;
    final ValueNotifier<bool> applyEnabled = ValueNotifier<bool>(false);
    bool applied = false;

    await DialogHelper.showCustomFilterBottomSheet(
      context,
      title: "Filter - Construction Area",
      contentWidget: StatefulBuilder(
        builder: (context, innerState) {
          return SingleChildScrollView(
            padding: EdgeInsets.only(right: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [],
            ),
          );
        },
      ),
      onClear: () {},
      onApply: () {
        applied = true;
      },
      isApplyEnabled: applyEnabled.value,
      applyEnabledNotifier: applyEnabled,
    );
    if (!applied && manualClose) {}
  }

  Widget _buildSearchBar() {
    return ListenableBuilder(
      listenable: _tabController,
      builder: (context, _) {
        return BlocBuilder<ConstructionAreaCubit, ConstructionAreaState>(
          builder: (context, state) {
            final selectedTab = _tabs[_tabController.index];

            final isConstructionArea = selectedTab == "Construction Area";

            final isComparative = selectedTab == "Comparative";
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: SearchWidget(
                      key: ValueKey(_tabController.index),
                      hintText:
                          isConstructionArea
                              ? "Search by Floor"
                              : "Search by Type",

                      textController:
                          isConstructionArea
                              ? _searchConstructionAreaC
                              : _searchComparativeC,

                      onSubmit: (value) {},
                      isFilterOn: isConstructionArea ? true : false,
                      filterCountNotifier: _filterConstructionAreaCount,
                      onFilterTap: () {
                        if (isConstructionArea) {
                          _showBottomSheetToFilterConstructionArea(context);
                        }
                      },
                    ),
                  ),
                  horizontalSpacing(),
                  CustomExportButton(
                    onExport: (type) {
                      if (isConstructionArea) {
                      } else if (isConstructionArea) {}
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
