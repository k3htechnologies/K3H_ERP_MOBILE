import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/specification_and_budget/specification_master/data/model/specification_master.model.dart';
import 'package:k3h_erp_app/features/masters/specification_and_budget/specification_master/presentation/cubit/specification_master_cubit.dart';
import 'package:k3h_erp_app/features/masters/specification_and_budget/specification_master/presentation/cubit/specification_master_state.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_date_function.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/chip_style_tab_bar.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/expansion_tile/custom_expansion_tile.dart';
import 'package:k3h_erp_app/widgets/status/budget_level_status.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class SpecificationMasterScreen extends StatefulWidget {
  const SpecificationMasterScreen({super.key});

  @override
  State<SpecificationMasterScreen> createState() =>
      _SpecificationMasterScreenState();
}

class _SpecificationMasterScreenState extends State<SpecificationMasterScreen>
    with SingleTickerProviderStateMixin {
  // CUBIT
  late SpecificationMasterCubit _specificationMasterCubit;

  // AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;

  // PAGINATION
  late ScrollController scrollController;
  Timer? _debounce;

  // TEXT EDITING CONTROLLERS
  late TextEditingController _searchC;
  late TabController _tabController;
  List<String> tabs = ['L1', 'L2', 'L3', 'L4'];
  @override
  void initState() {
    super.initState();
    _specificationMasterCubit = context.read<SpecificationMasterCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.specificationMaster]!;
    _initializeTextEditingController();
    _onScroll();
    _tabController = TabController(length: tabs.length, vsync: this);
    _tabController.addListener(_handleTabChange);
    _specificationMasterCubit.getSpecificationList(context, 1);
  }

  @override
  void dispose() {
    super.dispose();
    _searchC.dispose();
    scrollController.dispose();
    _debounce?.cancel();
    _tabController.dispose();
  }

  void _initializeTextEditingController() {
    _searchC = TextEditingController();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      String selectedTab = tabs[_tabController.index];
      _specificationMasterCubit.onTabChange(context, selectedTab);
      _searchC.clear();
    }
  }

  // PAGINATION
  void _onScroll() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !_specificationMasterCubit.state.isLoading! &&
          _specificationMasterCubit.state.specificationList.length <
              _specificationMasterCubit.state.totalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _specificationMasterCubit.getSpecificationList(
            context,
            _specificationMasterCubit.state.currentPage + 1,
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        screenTitle: 'Specification Master',
        authorization: _routeAuthorizationModel,
        onExportCallback: (value) {
          _specificationMasterCubit.exportExcelPdf(context, value);
        },
        searchHintText: "Search by Specification Name",
        onSearchSubmit: (value) {
          _specificationMasterCubit.searchSpecification(context, value);
        },
        textController: _searchC,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          children: [
            ChipStyleTabBar(
              controller: _tabController,
              margin: EdgeInsets.zero,
              tabs: ['L1', 'L2', 'L3', 'L4'],
            ),
            verticalSpacing(height: 8.h),
            Expanded(
              child: BlocBuilder<
                SpecificationMasterCubit,
                SpecificationMasterState
              >(
                builder: (context, state) {
                  if ((state.isLoading ?? false) &&
                      state.specificationList.isEmpty) {
                    return Center(child: loader());
                  } else if (state.specificationList.isEmpty) {
                    return Center(
                      child: noDataWidget(
                        message: "No Specification Data Found",
                      ),
                    );
                  } else {
                    return ListView.builder(
                      controller: scrollController,
                      itemCount: state.specificationList.length + 1,
                      itemBuilder: (context, index) {
                        if (index == state.specificationList.length) {
                          return state.specificationList.length <
                                  state.totalNumberOfRecord
                              ? const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                              : const SizedBox.shrink();
                        }
                        final item = state.specificationList[index];
                        return _tabController.index == 0
                            ? estimatedCard(item)
                            : _estimatedExpansionCard(
                              item,
                              _tabController.index,
                            );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget estimatedCard(SpecificationMasterModel specification) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
      decoration: commonCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_levelHeader(specification), _modifiedInfo(specification)],
      ),
    );
  }

  Widget _estimatedExpansionCard(
    SpecificationMasterModel specification,
    int level,
  ) {
    return CustomExpandableCard(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_levelHeader(specification), _modifiedInfo(specification)],
      ),
      onExpansionChanged: (expanded) {
        if (expanded) {
          _specificationMasterCubit.getSpecificationViewList(
            context,
            specification.specificationMasterId,
            1,
          );
        }
      },
      body: _childrenList(specification, level + 1),
    );
  }

  Widget _childrenList(SpecificationMasterModel parent, int childLevel) {
    final key = parent.specificationMasterId.toString();

    return BlocBuilder<SpecificationMasterCubit, SpecificationMasterState>(
      buildWhen:
          (prev, curr) =>
              prev.childrenMap[key] != curr.childrenMap[key] ||
              prev.loadingIds.contains(key) != curr.loadingIds.contains(key),
      builder: (context, state) {
        final children = state.childrenMap[key] ?? [];
        final isLoading = state.loadingIds.contains(key);

        return Column(
          children: [
            for (final child in children)
              Container(
                decoration: BoxDecoration(
                  color: AppColor.lightGreyBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                margin: EdgeInsets.symmetric(vertical: 6.h),
                child: Column(
                  children: [
                    _levelHeader(child, isChild: true),
                    if (child.levelType == 'L2')
                      buildRowTitleValue(
                        title: 'Sub Category',
                        value: child.categoryName,
                        singleLine: false,
                      ),
                    if (child.levelType == 'L3') ...[
                      buildRowTitleValue(
                        title: 'Description',
                        value: child.categoryName,
                        singleLine: false,
                      ),
                      buildRowTitleValue(
                        title: 'UOM',
                        value: child.uomCode,
                        singleLine: false,
                      ),
                    ],
                    if (child.levelType == 'L4') ...[
                      buildRowTitleValue(
                        title: 'Material',
                        value: child.materialName,
                        singleLine: false,
                      ),
                      buildRowTitleValue(
                        title: 'Sub Material',
                        value: child.subMaterialName,
                        singleLine: false,
                      ),
                      buildRowTitleValue(
                        title: 'Quantity',
                        value: "${child.quantity} ${child.subMaterialUomCode}",
                        singleLine: false,
                      ),
                      buildRowTitleValue(
                        title: 'Lead Time (Days)',
                        value: "${child.leadTimeInDays} Days",
                        singleLine: false,
                      ),
                      buildRowTitleValue(
                        title: 'Is Tolerant',
                        value: child.isTolerant ? "Yes" : "No",
                        singleLine: false,
                      ),
                    ],
                    _modifiedInfo(child),
                  ],
                ),
              ),

            if (isLoading)
              Padding(
                padding: EdgeInsets.all(8.h),
                child: SizedBox(
                  height: 20.h,
                  width: 20.h,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                ),
              ),

            if (!isLoading && children.isEmpty)
              Padding(
                padding: EdgeInsets.all(8.h),
                child: noDataWidget(iconSize: 100),
              ),
          ],
        );
      },
    );
  }

  Widget _levelHeader(SpecificationMasterModel spec, {bool isChild = false}) {
    final config = budgetLevelConfig[spec.levelType];
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: config?.backgroundColor ?? AppColor.primary,
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Text(
            spec.levelType,
            style: AppTextStyle.ts12M(color: config?.textColor ?? Colors.white),
          ),
        ),
        SizedBox(width: 10.w),
        if (!isChild)
          Expanded(
            child: Text(
              spec.categoryName,
              style: AppTextStyle.ts14SB(color: AppColor.darkBlue900),
            ),
          ),
      ],
    );
  }

  Widget _modifiedInfo(SpecificationMasterModel spec) {
    return Column(
      children: [
        buildRowTitleValue(
          title: 'Modified By',
          value: spec.modifiedBy.isEmpty ? spec.createdBy : spec.modifiedBy,
          singleLine: false,
        ),
        buildRowTitleValue(
          title: 'Modified Date',
          value: formatDateTimeAsDDMMMYYYY(
            spec.modifiedDate ?? spec.createdDate,
          ),
          singleLine: false,
        ),
      ],
    );
  }
}
