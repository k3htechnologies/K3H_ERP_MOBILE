import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/procurement_master/sub_material_master/data/model/sub_material_master.model.dart';
import 'package:k3h_erp_app/features/masters/procurement_master/sub_material_master/presentation/cubit/sub_material_master_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class SubMaterialMasterScreen extends StatefulWidget {
  const SubMaterialMasterScreen({super.key});
  @override
  State<SubMaterialMasterScreen> createState() =>
      _SubMaterialMasterScreenState();
}

class _SubMaterialMasterScreenState extends State<SubMaterialMasterScreen> {
  // CUBIT
  late SubMaterialMasterCubit _subMaterialMasterCubit;
  // AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;
  // PAGINATION
  late ScrollController scrollController;
  Timer? _debounce;
  // TEXT EDITING CONTROLLERS
  late TextEditingController _searchC;
  @override
  void initState() {
    super.initState();
    _subMaterialMasterCubit = context.read<SubMaterialMasterCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.subMaterialMaster] ??
        AuthorizationModel();
    _initializeTextEditingController();
    _onScroll();
    _subMaterialMasterCubit.getSubMaterialMasterList(context, 1);
  }

  @override
  void dispose() {
    scrollController.dispose();
    _searchC.dispose();
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
          !(_subMaterialMasterCubit.state.isLoading ?? false) &&
          _subMaterialMasterCubit.state.subMaterialList.length <
              _subMaterialMasterCubit.state.totalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _subMaterialMasterCubit.getSubMaterialMasterList(
            context,
            _subMaterialMasterCubit.state.currentPage + 1,
          );
        });
      }
    });
  }

  Future<void> _showPopupToDeleteSubMaterialMaster(
    BuildContext context,
    SubMaterialMasterModel subMaterial,
    int currentPage,
    int index,
  ) async {
    var result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a Sub Material?',
      'Deleting this Sub Material will permanently remove all associated data.',
    );
    if (result && context.mounted) {
      _subMaterialMasterCubit.deleteSubMaterialMaster(
        context: context,
        subMaterialMasterId: subMaterial.subMaterialMasterId,
        uniqueKey: subMaterial.uniquekey,
        pageSize: 10,
        index: index,
      );
    }
  }

  Future<void> _showBottomSheetToFilterSubMaterialMaster(
    BuildContext context,
  ) async {
    final state = _subMaterialMasterCubit.state;  

    _searchC.text = state.searchText;

    String? selectedDirection =
        state.currentSortColumn == "Department Name"
            ? state.currentSortDirection
            : null;

    final String initialDepartmentName = _searchC.text;
    final String? initialDirection = selectedDirection;

    bool manualClose = false;
    bool applied = false;

    final ValueNotifier<bool> applyEnabled = ValueNotifier<bool>(false);

    void updateApplyState(StateSetter innerState) {
      innerState(() {
        manualClose =
            _searchC.text.trim() != initialDepartmentName ||
            selectedDirection != initialDirection;

        applyEnabled.value = manualClose;
      });
    }

    await DialogHelper.showCustomFilterBottomSheet(
      context,
      title: "Filter Department",
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
              Text("Sort By Department Name", style: AppTextStyle.ts14M()),
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
                hint: "Enter Sub Material Name",
                title: "Sub Material Name",
                onChangeFunction: (_) => updateApplyState(innerState),
              ),
            ],
          );
        },
      ),

      onClear: () {
        applied = true;

        _searchC.clear();
      },

      onApply: () {
        applied = true;
      },

      isApplyEnabled: applyEnabled.value,
      applyEnabledNotifier: applyEnabled,
    );

    // User closed bottom sheet without clicking Apply/Clear
    if (!applied && manualClose) {
      _searchC.text = initialDepartmentName;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.lightGreyBackground,
      appBar: CustomAppBar(
        screenTitle: 'Sub Material Master',
        authorization: _routeAuthorizationModel,
        onExportCallback: (value) {
          if (_subMaterialMasterCubit.state.totalNumberOfRecord == 0) {
            showErrorMessage(context, "Error", "No data found");
            return;
          }
          _subMaterialMasterCubit.exportExcelPdf(context, value);
        },
        onAddCallback: () {
          goRouter.pushNamed(AppRoutes.addSubMaterialMaster);
        },
        onSearchSubmit: (value) {
          _subMaterialMasterCubit.searchSubMaterial(context, value);
        },
        textController: _searchC,
        searchHintText: "Search by Sub Material Name",
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _searchC.clear();
          _subMaterialMasterCubit.searchSubMaterial(context, '');
        },
        child: BlocBuilder<SubMaterialMasterCubit, SubMaterialMasterState>(
          builder: (context, state) {
            if ((state.isLoading ?? true) && state.subMaterialList.isEmpty) {
              return Center(child: loader());
            }
            if (state.subMaterialList.isEmpty) {
              return ListView(
                physics: AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: Center(
                      child: noDataWidget(
                        message: "No Sub Materials Data Found",
                      ),
                    ),
                  ),
                ],
              );
            }
            return ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount:
                  _subMaterialMasterCubit.state.subMaterialList.length + 1,
              itemBuilder: (context, index) {
                if (index == state.subMaterialList.length) {
                  return state.subMaterialList.length <
                          state.totalNumberOfRecord
                      ? const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      )
                      : const SizedBox.shrink();
                }
                var subMaterial = state.subMaterialList[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
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
                                  AppRoutes.viewSubMaterialMaster,
                                  queryParameters: {
                                    "subMaterial": Uri.encodeQueryComponent(
                                      EncryptionManager.encryptData(
                                        jsonEncode(subMaterial.toJson()),
                                      ),
                                    ),
                                  },
                                );
                              },
                              child: Text(
                                subMaterial.subMaterialName,
                                style: AppTextStyle.ts16M(
                                  color: AppColor.primary,
                                ),
                              ),
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CustomIconButton.edit(
                                isDisabled: !_routeAuthorizationModel.isAction,
                                onPressed: () async {
                                  await goRouter.pushNamed(
                                    AppRoutes.addSubMaterialMaster,
                                    queryParameters: {
                                      "subMaterial": Uri.encodeQueryComponent(
                                        EncryptionManager.encryptData(
                                          jsonEncode(subMaterial.toJson()),
                                        ),
                                      ),
                                      'index': index.toString(),
                                    },
                                  );
                                },
                              ),
                              horizontalSpacing(),
                              CustomIconButton.delete(
                                isDisabled: !_routeAuthorizationModel.isAction,
                                onPressed: () {
                                  _showPopupToDeleteSubMaterialMaster(
                                    context,
                                    subMaterial,
                                    state.currentPage,
                                    index,
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      buildRowTitleValue(
                        title: "Material",
                        fixesWidth: 130.w,
                        singleLine: true,
                        value: subMaterial.materialName,
                      ),
                      buildRowTitleValue(
                        fixesWidth: 130.w,
                        title: "UOM",
                        singleLine: true,
                        value: subMaterial.uom,
                      ),
                      buildRowTitleValue(
                        fixesWidth: 130.w,
                        title: "Lead Time (Days)",
                        value: subMaterial.leadTimeInDays.toString(),
                      ),
                      buildRowTitleValue(
                        fixesWidth: 130.w,
                        title: "Is Tolerant",
                        value: subMaterial.isTolerant ? "Yes" : "No",
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
