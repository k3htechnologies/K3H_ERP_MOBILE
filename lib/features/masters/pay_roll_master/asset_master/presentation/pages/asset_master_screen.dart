import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/asset_master/presentation/cubit/asset_master_cubit.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/asset_master/data/model/asset_master.model.dart';
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

class AssetMasterScreen extends StatefulWidget {
  const AssetMasterScreen({super.key});

  @override
  State<AssetMasterScreen> createState() => _AssetMasterScreenState();
}

class _AssetMasterScreenState extends State<AssetMasterScreen> {
  // CUBIT
  late AssetMasterCubit _assetMasterCubit;

  // AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;

  // PAGINATION
  late ScrollController scrollController;
  Timer? _debounce;
  // TEXT EDITING CONTROLLERS
  late TextEditingController _searchC,
      _filterAssetStatusC,
      _filterAssetTypeC,
      _filterAssetBrandC,
      _filterAssetModelC,
      _filterSerialNumberC;

  @override
  void initState() {
    super.initState();
    _assetMasterCubit = context.read<AssetMasterCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.assetMaster] ??
        AuthorizationModel();
    _initializeTextEditingController();
    _onScroll();
    _assetMasterCubit.getAssetsList(context: context, pageNumber: 1);
  }

  @override
  void dispose() {
    scrollController.dispose();
    _searchC.dispose();
    _filterAssetStatusC.dispose();
    super.dispose();
  }

  // INITIALIZE TEXT EDITING CONTROLLERS
  void _initializeTextEditingController() {
    _searchC = TextEditingController();
    _filterAssetStatusC = TextEditingController();
    _filterAssetTypeC = TextEditingController();
    _filterAssetBrandC = TextEditingController();
    _filterAssetModelC = TextEditingController();
    _filterSerialNumberC = TextEditingController();
  }

  // <---- PAGINATION ---->
  void _onScroll() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !(_assetMasterCubit.state.isLoading ?? false) &&
          _assetMasterCubit.state.assetList.length <
              _assetMasterCubit.state.totalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _assetMasterCubit.getAssetsList(
            context: context,
            pageNumber: _assetMasterCubit.state.currentPage + 1,
          );
        });
      }
    });
  }

  // <---- DELETE ASSET MAPPING ---->
  Future<void> _showPopupToDeleteAssetMaster(
    BuildContext context,
    AssetMasterModel obj,
    int currentPage,
    int index,
  ) async {
    var result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a Asset Mapping?',
      'Deleting this Asset Mapping will permanently remove its contents.',
    );
    if (result && context.mounted) {
      _assetMasterCubit.deleteAsset(obj, context, index);
    }
  }

  // ASSET FILTER
  Future<void> _showBottomSheetToFilterAsset(BuildContext context) async {
    final state = _assetMasterCubit.state;

    _filterAssetStatusC.text = state.filterAssetStatus;
    _filterAssetTypeC.text = state.filterAssetType;
    _filterAssetBrandC.text = state.filterAssetBrand;
    _filterAssetModelC.text = state.filterAssetModel;
    _filterSerialNumberC.text = state.filterSerialNumber;

    String? selectedDirection =
        state.currentSortColumn == "Asset Name"
            ? state.currentSortDirection
            : null;

    final String initialAssetStatus = _filterAssetStatusC.text;
    final String initialAssetType = _filterAssetTypeC.text;
    final String initialAssetBrand = _filterAssetBrandC.text;
    final String initialAssetModel = _filterAssetModelC.text;
    final String initialSerialNumber = _filterSerialNumberC.text;
    final String? initialDirection = selectedDirection;

    bool manualClose = false;
    final ValueNotifier<bool> applyEnabled = ValueNotifier<bool>(false);
    bool applied = false;

    void updateApplyState(StateSetter innerState) {
      innerState(() {
        manualClose =
            (_filterAssetStatusC.text.trim() != initialAssetStatus) ||
            (_filterAssetTypeC.text.trim() != initialAssetType) ||
            (_filterAssetBrandC.text.trim() != initialAssetBrand) ||
            (_filterAssetModelC.text.trim() != initialAssetModel) ||
            (_filterSerialNumberC.text.trim() != initialSerialNumber) ||
            (selectedDirection != initialDirection);

        applyEnabled.value = manualClose;
      });
    }

    DialogHelper.showCustomFilterBottomSheet(
      context,
      title: "Filter Asset",
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
                  title: "Asset Type",
                  hint: "Enter Asset Type",
                  textController: _filterAssetTypeC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
                CustomTextField(
                  title: "Asset Brand",
                  hint: "Enter Asset Brand",
                  textController: _filterAssetBrandC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
                CustomTextField(
                  title: "Asset Model",
                  hint: "Enter Asset Model",
                  textController: _filterAssetModelC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
                CustomTextField(
                  title: "Asset Serial Number",
                  hint: "Enter Asset Serial Number",
                  textController: _filterSerialNumberC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
                CustomTextField(
                  title: "Asset Status",
                  hint: "Enter Asset Status",
                  textController: _filterAssetStatusC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
              ],
            ),
          );
        },
      ),
      onClear: () {
        _assetMasterCubit.applyFilterAndSort(
          context: context,
          filterAssetStatus: "",
          filterAssetType: "",
          filterAssetBrand: "",
          filterAssetModel: "",
          filterSerialNumber: "",
          sortColumn: "Created Date",
          sortDirection: "DESC",
        );
      },
      onApply: () {
        applied = true;
        _assetMasterCubit.applyFilterAndSort(
          context: context,
          filterAssetStatus: _filterAssetStatusC.text,
          filterAssetType: _filterAssetTypeC.text,
          filterAssetBrand: _filterAssetBrandC.text,
          filterAssetModel: _filterAssetModelC.text,
          filterSerialNumber: _filterSerialNumberC.text,
          sortColumn: selectedDirection != null ? "Asset Name" : null,
          sortDirection: selectedDirection,
        );
      },
      isApplyEnabled: applyEnabled.value,
      applyEnabledNotifier: applyEnabled,
    );

    if (!applied && manualClose) {
      _filterAssetStatusC.clear();
      _filterAssetTypeC.clear();
      _filterAssetBrandC.clear();
      _filterAssetModelC.clear();
      _filterSerialNumberC.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.lightGreyBackground,
      appBar: CustomAppBar(
        screenTitle: "Asset Master",
        authorization: _routeAuthorizationModel,
        onSearchSubmit: (value) {
          _assetMasterCubit.searchAsset(value, context);
        },
        textController: _searchC,
        searchHintText: "Search by Asset Name",
        onAddCallback: () async {
          await goRouter.pushNamed(AppRoutes.addAssetMaster);
          if (context.mounted) {
            _assetMasterCubit.searchAsset("", context);
          }
        },
        onExportCallback: (value) {
          if (_assetMasterCubit.state.totalNumberOfRecord == 0) {
            showErrorMessage(context, "Error", "No Data Found");
            return;
          }
          _assetMasterCubit.exportExcelPdf(context, value);
        },
        isFilterOn: true,
        onFilterTap: () {
          _showBottomSheetToFilterAsset(context);
        },
      ),
      body: BlocBuilder<AssetMasterCubit, AssetMasterState>(
        builder: (context, state) {
          if ((state.isLoading ?? true) && state.assetList.isEmpty) {
            return Center(child: loader());
          }
          if (state.assetList.isEmpty) {
            return Center(child: noDataWidget(message: "No Assets Found"));
          }
          return ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemCount: state.assetList.length + 1,
            itemBuilder: (context, index) {
              if (index == state.assetList.length) {
                return state.assetList.length < state.totalNumberOfRecord
                    ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    )
                    : const SizedBox.shrink();
              }
              var asset = state.assetList[index];
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
                                AppRoutes.viewAssetMaster,
                                queryParameters: {
                                  "asset": Uri.encodeQueryComponent(
                                    EncryptionManager.encryptData(
                                      jsonEncode(asset.toJson()),
                                    ),
                                  ),
                                },
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 0,
                                vertical: 4,
                              ),
                              child: Text(
                                asset.assetName,
                                style: AppTextStyle.ts16M(
                                  color: AppColor.primary,
                                ).copyWith(
                                  decoration: TextDecoration.underline,
                                  decorationColor: AppColor.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Row(
                          spacing: 10,
                          children: [
                            if (asset.status.toLowerCase() != "booked") ...[
                              CustomIconButton.edit(
                                onPressed: () async {
                                  await goRouter.pushNamed(
                                    AppRoutes.addAssetMaster,
                                    queryParameters: {
                                      "asset": Uri.encodeQueryComponent(
                                        EncryptionManager.encryptData(
                                          jsonEncode(asset.toJson()),
                                        ),
                                      ),
                                      'index': index.toString(),
                                    },
                                  );
                                },
                              ),
                              CustomIconButton.delete(
                                onPressed: () {
                                  _showPopupToDeleteAssetMaster(
                                    context,
                                    asset,
                                    state.currentPage,
                                    index,
                                  );
                                },
                              ),
                            ],
                            _buildStatusWidget(asset.status),
                          ],
                        ),
                      ],
                    ),
                    verticalSpacing(height: 8),
                    buildRowTitleValue(title: "Code", value: asset.assetCode),
                    buildRowTitleValue(title: "Type", value: asset.assetType),
                    buildRowTitleValue(title: "Brand", value: asset.assetBrand),
                    buildRowTitleValue(title: "Model", value: asset.assetModel),
                    buildRowTitleValue(
                      title: "Serial Number",
                      value: asset.serialNumber,
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // <---- BUILD STATUS WIDGET ---->
  Widget _buildStatusWidget(String status) {
    if (status.isEmpty) return const SizedBox.shrink();

    Color bgColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'available':
        bgColor = AppColor.lightGreen;
        textColor = AppColor.darkGreen;
        break;
      case 'booked':
        bgColor = AppColor.lightRed;
        textColor = AppColor.error;
        break;
      default:
        bgColor = AppColor.lightBlue;
        textColor = AppColor.primary;
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        margin: EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          status,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyle.ts12R(color: textColor),
        ),
      ),
    );
  }
}
