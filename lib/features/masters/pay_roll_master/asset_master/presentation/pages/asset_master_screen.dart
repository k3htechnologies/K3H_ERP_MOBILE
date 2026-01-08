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
  late TextEditingController _searchC;

  @override
  void initState() {
    super.initState();
    _assetMasterCubit = context.read<AssetMasterCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.assetMaster] ??
        AuthorizationModel();
    _initializeTextEditingController();
    _onScroll();
    _assetMasterCubit.getAssetsList(
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
      _assetMasterCubit.deleteAsset( obj, context);
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
        onAddCallback: () {
          goRouter.pushNamed(AppRoutes.addAssetMaster);
        },
        onExportCallback: (value) {
          _assetMasterCubit.exportExcelPdf(context, value);
        },
      ),
      body: BlocBuilder<AssetMasterCubit, AssetMasterState>(
        builder: (context, state) {
          if ((state.isLoading ?? true) && state.assetList.isEmpty) {
            return Center(child: loader());
          }
          if (state.assetList.isEmpty) {
            return Center(child: noDataWidget());
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
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: AppColor.primary),
                                ),
                              ),
                              child: Text(
                                asset.assetName,
                                style: AppTextStyle.ts16M(
                                  color: AppColor.primary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                        Row(
                          children: [
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
                            const SizedBox(width: 8),
                            CustomIconButton.delete(
                              onPressed: () {
                                _showPopupToDeleteAssetMaster(context, asset, state.currentPage, index);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    verticalSpacing(height: 8),
                    _buildRowTitleValue(
                      title: "Asset Type",
                      value: asset.assetType,
                    ),
                    _buildRowTitleValue(
                      title: "Brand",
                      value: asset.assetBrand,
                    ),
                    _buildRowTitleValue(
                      title: "Model",
                      value: asset.assetModel,
                    ),
                    _buildRowTitleValue(
                      title: "Serial Number",
                      value: asset.serialNumber,
                    ),
                    _buildRowTitleValue(
                      title: "Purchase Date",
                      value: formatDateTimeAsDDMMMYYYY(asset.purchaseDate),
                    ),
                    _buildRowTitleValue(
                      title: "Asset Cost",
                      value: "₹${asset.assetCost.toStringAsFixed(2)}",
                    ),
                    if (asset.supplierName.isNotEmpty)
                      _buildRowTitleValue(
                        title: "Supplier",
                        value: asset.supplierName,
                      ),
                    if (asset.warrantyExpiryDate != null)
                      _buildRowTitleValue(
                        title: "Warranty Expiry",
                        value: formatDateTimeAsDDMMMYYYY(
                          asset.warrantyExpiryDate!,
                        ),
                      ),
                    _buildStatusWidget(asset.status),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // BUILD ROW TITLE VALUE
  Widget _buildRowTitleValue({required String title, required String value}) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TITLE
          SizedBox(
            width: 120,
            child: Text(title, style: AppTextStyle.ts14R(color: AppColor.grey)),
          ),

          // COLON
          SizedBox(
            width: 20,
            child: Text(
              ":",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColor.grey),
            ),
          ),

          // VALUE
          Expanded(
            child: Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyle.ts14R(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusWidget(String status) {
    if (status.isEmpty) return const SizedBox.shrink();

    Color bgColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'active':
        bgColor = AppColor.lightGreen;
        textColor = AppColor.darkGreen;
        break;
      case 'inactive':
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
