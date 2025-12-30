import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/employee_master/data/model/asset_mapping.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/asset_master_mapping/presentation/cubit/asset_mapping_master_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AssetMappingMasterScreen extends StatefulWidget {
  const AssetMappingMasterScreen({super.key});

  @override
  State<AssetMappingMasterScreen> createState() => _AssetMappingMasterScreenState();
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
  late TextEditingController _searchC;

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
      pageSize: 10,
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    _searchC.dispose();
    super.dispose();
  }

  void _initializeTextEditingController() {
    _searchC = TextEditingController();
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
            pageSize: 10,
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.lightGreyBackground,
      appBar: CustomAppBar(
        screenTitle: "Asset Mapping Master",
        authorization: _routeAuthorizationModel,
        onSearchSubmit: (value) {
          _assetMappingMasterCubit.searchAssetMapping(value, context);
        },
        textController: _searchC,
        onAddCallback: () {
          goRouter.pushNamed(AppRoutes.addAssetMappingMaster);
        },
        onExportCallback: (value) {
          _assetMappingMasterCubit.exportExcelPdf(context, value);
        },
      ),
      body: BlocBuilder<AssetMappingMasterCubit, AssetMappingMasterState>(
        builder: (context, state) {
          if ((state.isLoading ?? true) && state.assetMappingList.isEmpty) {
            return Center(child: loader());
          }
          if (state.assetMappingList.isEmpty) {
            return Center(child: noDataWidget());
          }
          return ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemCount: state.assetMappingList.length + 1,
            itemBuilder: (context, index) {
              if (index == state.assetMappingList.length) {
                return state.assetMappingList.length < state.totalNumberOfRecord
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                assetMapping.assetName,
                                style: AppTextStyle.ts16M(
                                  color: AppColor.primary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (assetMapping.assetCode.isNotEmpty)
                                Text(
                                  assetMapping.assetCode,
                                  style: AppTextStyle.ts12R(
                                    color: AppColor.grey,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            CustomIconButton.edit(
                              onPressed: () async {
                                await goRouter.pushNamed(
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
                                if (context.mounted) {
                                  _assetMappingMasterCubit.getAssetMappingList(
                                    context: context,
                                    pageNumber: 1,
                                    pageSize: 10,
                                  );
                                }
                              },
                            ),
                            const SizedBox(width: 8),
                            CustomIconButton.delete(
                              onPressed: () {
                                _showDeleteDialog(assetMapping, index);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    verticalSpacing(height: 8),
                    _buildRowTitleValue(
                      title: "Employee",
                      value: assetMapping.employeeName,
                    ),
                    _buildRowTitleValue(
                      title: "Assigned Date",
                      value: formatDateTimeAsDDMMMYYYY(assetMapping.assignedDate),
                    ),
                    _buildRowTitleValue(
                      title: "Return Date",
                      value: formatDateTimeAsDDMMMYYYY(assetMapping.returnDate),
                    ),
                    if (assetMapping.conditionOnIssue.isNotEmpty)
                      _buildRowTitleValue(
                        title: "Condition on Issue",
                        value: assetMapping.conditionOnIssue,
                      ),
                    if (assetMapping.conditionOnReturn.isNotEmpty)
                      _buildRowTitleValue(
                        title: "Condition on Return",
                        value: assetMapping.conditionOnReturn,
                      ),
                    if (assetMapping.remarks.isNotEmpty)
                      _buildRowTitleValue(
                        title: "Remarks",
                        value: assetMapping.remarks,
                      ),
                    _buildStatusWidget(assetMapping.status),
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
            width: 140,
            child: Text(
              title,
              style: AppTextStyle.ts14R(color: AppColor.grey),
            ),
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

  void _showDeleteDialog(AssetMappingModel assetMapping, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Delete Asset Mapping',
            style: AppTextStyle.ts16M(),
          ),
          content: Text(
            'Are you sure you want to delete this asset mapping?',
            style: AppTextStyle.ts14R(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: AppTextStyle.ts14R(color: AppColor.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _assetMappingMasterCubit.deleteAssetMapping(
                  index,
                  assetMapping,
                  context,
                );
              },
              child: Text(
                'Delete',
                style: AppTextStyle.ts14R(color: AppColor.error),
              ),
            ),
          ],
        );
      },
    );
  }
}

