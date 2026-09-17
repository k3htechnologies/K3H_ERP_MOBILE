import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/procurement_master/material_master/data/model/material_master.model.dart';
import 'package:k3h_erp_app/features/masters/procurement_master/material_master/presentation/cubit/material_master_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class MaterialMasterScreen extends StatefulWidget {
  const MaterialMasterScreen({super.key});
  @override
  State<MaterialMasterScreen> createState() => _MaterialMasterScreenState();
}

class _MaterialMasterScreenState extends State<MaterialMasterScreen> {
  // CUBIT
  late MaterialMasterCubit _materialMasterCubit;
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
    _materialMasterCubit = context.read<MaterialMasterCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.materialMaster] ??
        AuthorizationModel();
    _initializeTextEditingController();
    _onScroll();
    _materialMasterCubit.getMaterialMasterList(context, 1);
  }

  @override
  void dispose() {
    scrollController.dispose();
    _searchC.dispose();
    _filterCount.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _initializeTextEditingController() {
    _searchC = TextEditingController();
  }

  void _onScroll() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !_materialMasterCubit.state.isLoading! &&
          _materialMasterCubit.state.materialList.length <
              _materialMasterCubit.state.totalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _materialMasterCubit.getMaterialMasterList(
            context,
            _materialMasterCubit.state.currentPage + 1,
          );
        });
      }
    });
  }

  Future<void> _showPopupToDeleteMaterialMaster(
    BuildContext context,
    MaterialMasterModel material,
    int currentPage,
    int index,
  ) async {
    var result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a material?',
      'Deleting this material will permanently remove its contents.',
    );
    if (result && context.mounted) {
      _materialMasterCubit.deleteMaterialMaster(
        context: context,
        materialMasterId: material.materialMasterId,
        uniqueKey: material.uniquekey,
        index: index,
      );
    }
  }

  Future<void> _showBottomSheetToFilterMaterialMaster(
    BuildContext context,
  ) async {
    final state = _materialMasterCubit.state;

    _searchC.text = state.searchText;

    String? selectedDirection =
        state.currentSortColumn == "Material Name"
            ? state.currentSortDirection
            : null;

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
                hint: "Enter Material Name",
                title: "Material Name",
                onChangeFunction: (_) => updateApplyState(innerState),
              ),
            ],
          );
        },
      ),

      onClear: () {
        applied = true;

        _searchC.clear();

        _materialMasterCubit.applyFilterAndSortMaterial(
          context: context,
          column: "Created Date",
          direction: "DESC",
          materialName: '',
        );
      },

      onApply: () {
        applied = true;

        _materialMasterCubit.applyFilterAndSortMaterial(
          context: context,
          column: selectedDirection != null ? "Material Name" : "Created Date",
          direction: selectedDirection ?? "DESC",
          materialName: _searchC.text.trim(),
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
    return BlocListener<MaterialMasterCubit, MaterialMasterState>(
      listener: (context, state) {
        _filterCount.value = _materialMasterCubit.updateFilterCount(state);
      },
      child: Scaffold(
        backgroundColor: AppColor.lightGreyBackground,
        appBar: CustomAppBar(
          screenTitle: 'Material Master',
          authorization: _routeAuthorizationModel,
          filterCountNotifier: _filterCount,
          isFilterOn: true,
          onFilterTap: () {
            _showBottomSheetToFilterMaterialMaster(context);
          },
          onExportCallback: (value) {
            if (_materialMasterCubit.state.totalNumberOfRecord == 0) {
              showErrorMessage(context, "Error", "No data found");
              return;
            }
            _materialMasterCubit.exportExcelPdf(context, value);
          },
          onAddCallback: () async {
            await goRouter.pushNamed(AppRoutes.addMaterialMaster);
          },
          onSearchSubmit: (value) {
            _materialMasterCubit.searchMaterial(context, value);
          },
          textController: _searchC,
          searchHintText: "Search by Material Name",
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            _searchC.clear();
            _materialMasterCubit.searchMaterial(context, "");
          },
          child: BlocBuilder<MaterialMasterCubit, MaterialMasterState>(
            builder: (context, state) {
              if ((state.isLoading ?? true) && state.materialList.isEmpty) {
                return Center(child: loader());
              }
              if (state.materialList.isEmpty) {
                return ListView(
                  physics: AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height,
                      child: Center(
                        child: noDataWidget(message: "No Materials Data Found"),
                      ),
                    ),
                  ],
                );
              }
              return ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                itemCount: _materialMasterCubit.state.materialList.length + 1,
                itemBuilder: (context, index) {
                  if (index == state.materialList.length) {
                    return state.materialList.length < state.totalNumberOfRecord
                        ? const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        )
                        : const SizedBox.shrink();
                  }
                  var material = state.materialList[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: commonCardDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: GestureDetector(
                                onTap: () {
                                  goRouter.pushNamed(
                                    AppRoutes.viewMaterialMaster,
                                    queryParameters: {
                                      'material': Uri.encodeQueryComponent(
                                        EncryptionManager.encryptData(
                                          jsonEncode(material.toJson()),
                                        ),
                                      ),
                                    },
                                  );
                                },
                                child: Text(
                                  material.materialName,
                                  style: AppTextStyle.ts16M(
                                    color: AppColor.primary,
                                  ),
                                ),
                              ),
                            ),
                            horizontalSpacing(),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CustomIconButton.edit(
                                  isDisabled:
                                      !_routeAuthorizationModel.isAction,
                                  onPressed: () async {
                                    await goRouter.pushNamed(
                                      AppRoutes.addMaterialMaster,
                                      queryParameters: {
                                        'material': Uri.encodeQueryComponent(
                                          EncryptionManager.encryptData(
                                            jsonEncode(material.toJson()),
                                          ),
                                        ),
                                        'index': index.toString(),
                                      },
                                    );
                                  },
                                ),
                                horizontalSpacing(),
                                CustomIconButton.delete(
                                  isDisabled:
                                      !_routeAuthorizationModel.isAction,
                                  onPressed: () {
                                    _showPopupToDeleteMaterialMaster(
                                      context,
                                      material,
                                      state.currentPage,
                                      index,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        verticalSpacing(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColor.grey10,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Code : ",
                                style: AppTextStyle.ts12R(color: AppColor.grey),
                              ),
                              Text(
                                material.materialCode,
                                style: AppTextStyle.ts12R(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
