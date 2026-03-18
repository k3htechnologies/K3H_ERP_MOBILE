import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/asset_master_mapping/presentation/cubit/asset_mapping_master_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AssetMappingMasterScreen extends StatefulWidget {
  const AssetMappingMasterScreen({super.key});

  @override
  State<AssetMappingMasterScreen> createState() =>
      _AssetMappingMasterScreenState();
}

class _AssetMappingMasterScreenState extends State<AssetMappingMasterScreen> {
  // CUBIT
  late AssetMappingMasterCubit _assetMappingMasterCubit;

  // AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;

  // PAGINATION
  late ScrollController scrollController;
  Timer? _debounce;

  // TEXT EDITING CONTROLLERS
  late TextEditingController _searchC, _filterEmployeeNameC;

  @override
  void initState() {
    super.initState();
    _assetMappingMasterCubit = context.read<AssetMappingMasterCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.assetMappingMaster] ??
        AuthorizationModel();
    _initializeTextEditingController();
    _onScroll();
    _assetMappingMasterCubit.getAssetMappingList(
      context: context,
      pageNumber: 1,
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    _searchC.dispose();
    super.dispose();
  }

  // INITIALIZE TEXT EDITING CONTROLLERS
  void _initializeTextEditingController() {
    _searchC = TextEditingController();
    _filterEmployeeNameC = TextEditingController();
  }

  // <---- PAGINATION ---->
  void _onScroll() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !(_assetMappingMasterCubit.state.isLoading ?? false) &&
          _assetMappingMasterCubit.state.assetMappingList.length <
              _assetMappingMasterCubit.state.totalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _assetMappingMasterCubit.getAssetMappingList(
            context: context,
            pageNumber: _assetMappingMasterCubit.state.currentPage + 1,
          );
        });
      }
    });
  }

  // ASSET MAPPING FILTER
  Future<void> _showBottomSheetToFilterAssetMapping(
    BuildContext context,
  ) async {
    final state = _assetMappingMasterCubit.state;

    _filterEmployeeNameC.text = state.filterEmployeeName;

    String? selectedDirection =
        state.currentSortColumn == "Asset Name"
            ? state.currentSortDirection
            : null;

    final String initialEmployeeName = _filterEmployeeNameC.text;
    final String? initialDirection = selectedDirection;

    bool manualClose = false;
    final ValueNotifier<bool> applyEnabled = ValueNotifier<bool>(false);
    bool applied = false;

    void updateApplyState(StateSetter innerState) {
      innerState(() {
        manualClose =
            (_filterEmployeeNameC.text.trim() != initialEmployeeName) ||
            (selectedDirection != initialDirection);

        applyEnabled.value = manualClose;
      });
    }

    DialogHelper.showCustomFilterBottomSheet(
      context,
      title: "Filter Asset Mapping",
      contentWidget: StatefulBuilder(
        builder: (context, innerState) {
          void selectDirection(String direction) {
            innerState(() {
              selectedDirection = direction;
            });
            updateApplyState(innerState);
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Sort By Asset Name", style: AppTextStyle.ts14M()),
                verticalSpacing(),
                Row(
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
                  title: "Employee Name",
                  hint: "Enter Employee Name",
                  textController: _filterEmployeeNameC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
                verticalSpacing(),
              ],
            ),
          );
        },
      ),
      onClear: () {
        _assetMappingMasterCubit.applyFilterAndSort(
          context: context,
          filterEmployeeName: "",
          sortColumn: "Created Date",
          sortDirection: "DESC",
        );
      },
      onApply: () {
        applied = true;
        _assetMappingMasterCubit.applyFilterAndSort(
          context: context,
          filterEmployeeName: _filterEmployeeNameC.text,
          sortColumn: selectedDirection != null ? "Asset Name" : null,
          sortDirection: selectedDirection,
        );
      },
      isApplyEnabled: applyEnabled.value,
      applyEnabledNotifier: applyEnabled,
    );

    // IF CLOSED WITHOUT APPLY
    if (!applied && manualClose) {
      _filterEmployeeNameC.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        screenTitle: "Asset Mapping Master",
        authorization: _routeAuthorizationModel,
        onSearchSubmit: (value) {
          _assetMappingMasterCubit.searchAssetMapping(value, context);
        },
        textController: _searchC,
        searchHintText: "Search by Asset Name",
        onAddCallback: () async {
          await goRouter.pushNamed(AppRoutes.addAssetMappingMaster);
          if (context.mounted) {
            _assetMappingMasterCubit.searchAssetMapping("", context);
          }
        },
        onExportCallback: (value) {
          if (_assetMappingMasterCubit.state.totalNumberOfRecord == 0) {
            showErrorMessage(context, "Error", "No Data Found");
            return;
          }
          _assetMappingMasterCubit.exportExcelPdf(context, value);
        },
        isFilterOn: true,
        onFilterTap: () {
          _showBottomSheetToFilterAssetMapping(context);
        },
      ),
      body: SizedBox(
        child: BlocBuilder<AssetMappingMasterCubit, AssetMappingMasterState>(
          builder: (context, state) {
            if ((state.isLoading ?? true) && state.assetMappingList.isEmpty) {
              return Center(child: loader());
            }
            if (state.assetMappingList.isEmpty) {
              return ListView(
                physics: AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: Center(
                      child: noDataWidget(message: "No Asset Data Found"),
                    ),
                  ),
                ],
              );
            }
            return ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: state.assetMappingList.length + 1,
              itemBuilder: (context, index) {
                if (index == state.assetMappingList.length) {
                  return state.assetMappingList.length <
                          state.totalNumberOfRecord
                      ? const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      )
                      : const SizedBox.shrink();
                }
                var assetMapping = state.assetMappingList[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: commonCardDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: GestureDetector(
                              onTap: () {
                                goRouter.pushNamed(
                                  AppRoutes.viewAssetMappingMaster,
                                  queryParameters: {
                                    "assetMapping": Uri.encodeQueryComponent(
                                      EncryptionManager.encryptData(
                                        jsonEncode(assetMapping.toJson()),
                                      ),
                                    ),
                                  },
                                );
                              },
                              child: Text(
                                assetMapping.assetName,
                                style: AppTextStyle.ts16M(
                                  color: AppColor.primary,
                                ).copyWith(
                                  decoration: TextDecoration.underline,
                                  decorationColor: AppColor.primary,
                                ),
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              CustomIconButton.edit(
                                onPressed: () async {
                                  goRouter.pushNamed(
                                    AppRoutes.addAssetMappingMaster,
                                    queryParameters: {
                                      "assetMapping": Uri.encodeQueryComponent(
                                        EncryptionManager.encryptData(
                                          jsonEncode(assetMapping.toJson()),
                                        ),
                                      ),
                                      'index': index.toString(),
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      verticalSpacing(height: 8),
                      buildRowTitleValue(
                        title: "Employee",
                        value: assetMapping.employeeName,
                      ),
                      buildRowTitleValue(
                        title: "Assigned Date",
                        value: formatDateTimeAsDDMMMYYYY(
                          assetMapping.assignedDate,
                        ),
                      ),
                      if (assetMapping.conditionOnIssue.isNotEmpty)
                        buildRowTitleValue(
                          title: "Condition on Issue",
                          value: assetMapping.conditionOnIssue,
                        ),
                      if (assetMapping.conditionOnReturn.isNotEmpty)
                        buildRowTitleValue(
                          title: "Condition on Return",
                          value: assetMapping.conditionOnReturn,
                        ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
