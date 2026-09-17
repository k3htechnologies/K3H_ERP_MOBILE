import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/procurement_master/uom_master/presentation/cubit/uom_master_cubit.dart';
import 'package:k3h_erp_app/features/masters/procurement_master/uom_master/presentation/pages/uom_datasource.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class UOMMasterScreen extends StatefulWidget {
  const UOMMasterScreen({super.key});

  @override
  State<UOMMasterScreen> createState() => _UOMMasterScreenState();
}

class _UOMMasterScreenState extends State<UOMMasterScreen> {
  // CUBIT
  late UOMMasterCubit _uomMasterCubit;

  // AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;

  // PAGINATION
  late ScrollController scrollController;
  Timer? _debounce;

  // TEXT EDITING CONTROLLERS
  late TextEditingController _searchC;
  final ValueNotifier<int> _filterCount = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    _uomMasterCubit = context.read<UOMMasterCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.uomMaster]!;
    _initializeTextEditingController();
    _onScroll();
    _uomMasterCubit.getUOMMasterList(context, 1);
  }

  @override
  void dispose() {
    _filterCount.dispose();
    scrollController.dispose();
    _searchC.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // INITIALIZE TEXT CONTROLLER
  void _initializeTextEditingController() {
    _searchC = TextEditingController();
  }

  // PAGINATION
  void _onScroll() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !_uomMasterCubit.state.isLoading! &&
          _uomMasterCubit.state.uomList.length <
              _uomMasterCubit.state.totalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _uomMasterCubit.getUOMMasterList(
            context,
            _uomMasterCubit.state.currentPage + 1,
          );
        });
      }
    });
  }

  Future<void> _showBottomSheetToFilterUomMaster(BuildContext context) async {
    final state = _uomMasterCubit.state;

    _searchC.text = state.searchText;

    String? selectedDirection =
        state.currentSortColumn == "UOM" ? state.currentSortDirection : null;

    final String initialMaterialName = _searchC.text;
    final String? initialDirection = selectedDirection;

    bool manualClose = false;
    bool applied = false;

    final ValueNotifier<bool> applyEnabled = ValueNotifier<bool>(false);

    void updateApplyState(StateSetter innerState) {
      innerState(() {
        manualClose =
            _searchC.text.trim() != initialMaterialName ||
            selectedDirection != initialDirection;

        applyEnabled.value = manualClose;
      });
    }

    await DialogHelper.showCustomFilterBottomSheet(
      context,
      title: "Filter - Material",
      contentWidget: StatefulBuilder(
        builder: (context, innerState) {
          void selectDirection(String direction) {
            innerState(() {
              selectedDirection = direction;
            });

            updateApplyState(innerState);
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Sort By Material Name", style: AppTextStyle.ts14M()),
              verticalSpacing(),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => selectDirection("ASC"),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color:
                            selectedDirection == "ASC"
                                ? AppColor.lightBlue
                                : Colors.transparent,
                        border: Border.all(color: AppColor.grey, width: .5),
                      ),
                      child: Text("A-Z", style: AppTextStyle.ts12R()),
                    ),
                  ),
                  horizontalSpacing(),
                  GestureDetector(
                    onTap: () => selectDirection("DESC"),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color:
                            selectedDirection == "DESC"
                                ? AppColor.lightBlue
                                : Colors.transparent,
                        border: Border.all(color: AppColor.grey, width: .5),
                      ),
                      child: Text("Z-A", style: AppTextStyle.ts12R()),
                    ),
                  ),
                ],
              ),

              verticalSpacing(height: 20),

              CustomTextField(
                textController: _searchC,
                hint: "Enter UOM Name",
                title: "UOM Name",
                onChangeFunction: (_) => updateApplyState(innerState),
              ),
            ],
          );
        },
      ),

      onClear: () {
        applied = true;

        _searchC.clear();

        _uomMasterCubit.applyFilterAndSortMaterial(
          context: context,
          column: "Created Date",
          direction: "DESC",
          uomName: '',
        );
      },

      onApply: () {
        applied = true;

        _uomMasterCubit.applyFilterAndSortMaterial(
          context: context,
          column: selectedDirection != null ? "UOM" : "Created Date",
          direction: selectedDirection ?? "DESC",
          uomName: _searchC.text.trim(),
        );
      },

      isApplyEnabled: applyEnabled.value,
      applyEnabledNotifier: applyEnabled,
    );

    // User closed bottom sheet without clicking Apply/Clear
    if (!applied && manualClose) {
      _searchC.text = initialMaterialName;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UOMMasterCubit, UOMMasterState>(
      listener: (context, state) {
        _filterCount.value = _uomMasterCubit.updateFilterCount(state);
      },
      child: Scaffold(
        backgroundColor: AppColor.lightGreyBackground,
        appBar: CustomAppBar(
          screenTitle: 'UOM Master',
          searchHintText: "Search by UOM Name",
          authorization: _routeAuthorizationModel,
          filterCountNotifier: _filterCount,
          onSearchSubmit: (value) {
            _uomMasterCubit.searchUOM(context, value);
          },
          isFilterOn: true,
          onFilterTap: () {
            _showBottomSheetToFilterUomMaster(context);
          },
          textController: _searchC,
          onExportCallback: (value) {
            if (_uomMasterCubit.state.totalNumberOfRecord == 0) {
              showErrorMessage(context, "Error", "No data found");
              return;
            }
            _uomMasterCubit.exportExcelPdf(context, value);
          },
        ),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              _searchC.clear();
              _uomMasterCubit.searchUOM(context, "");
            },
            child: BlocBuilder<UOMMasterCubit, UOMMasterState>(
              builder: (context, state) {
                if ((state.isLoading ?? true) && state.uomList.isEmpty) {
                  return Center(child: loader());
                }
                if (state.uomList.isEmpty) {
                  return Center(
                    child: noDataWidget(message: "No UOMs Data Found"),
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 12.0,
                        ),
                        child: Column(
                          children: [
                            state.uomList.isNotEmpty
                                ? Expanded(
                                  child: SfDataGridTheme(
                                    data: SfDataGridThemeData(
                                      headerColor: AppColor.lightBlue2
                                          .withValues(alpha: 0.3),
                                      gridLineColor: AppColor.grey50,
                                      gridLineStrokeWidth: 0.5,
                                    ),
                                    child: Column(
                                      children: [
                                        Expanded(
                                          child: Builder(
                                            builder: (context) {
                                              final dataSource =
                                                  UomScreenDataSource(
                                                    context: context,
                                                    rows: state.uomList,
                                                  );
                                              return SfDataGrid(
                                                source: dataSource,
                                                verticalScrollController:
                                                    scrollController,
                                                rowHeight: 48.h,
                                                headerRowHeight: 48.h,
                                                columnWidthMode:
                                                    ColumnWidthMode.fill,
                                                gridLinesVisibility:
                                                    GridLinesVisibility
                                                        .horizontal,
                                                headerGridLinesVisibility:
                                                    GridLinesVisibility
                                                        .horizontal,
                                                columns: [
                                                  GridColumn(
                                                    columnName: 'uom',
                                                    label: Center(
                                                      child: Text(
                                                        'UOM',
                                                        style:
                                                            AppTextStyle.ts12SB(),
                                                      ),
                                                    ),
                                                  ),
                                                  GridColumn(
                                                    columnName: 'code',
                                                    label: Center(
                                                      child: Text(
                                                        'UOM Code',
                                                        style:
                                                            AppTextStyle.ts12SB(),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          ),
                                        ),
                                        // PAGINATION LOADER
                                        if ((state.isLoading ?? false) &&
                                            state.uomList.length <
                                                state.totalNumberOfRecord)
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12.0,
                                            ),
                                            child: CircularProgressIndicator(),
                                          ),
                                      ],
                                    ),
                                  ),
                                )
                                : Expanded(
                                  child: Center(child: noDataWidget()),
                                ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
