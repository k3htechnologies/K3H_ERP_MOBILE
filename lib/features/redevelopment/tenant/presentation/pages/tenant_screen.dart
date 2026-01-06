import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/redevelopment/tenant/presentation/cubit/tenant_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class TenantScreen extends StatefulWidget {
  const TenantScreen({super.key});

  @override
  State<TenantScreen> createState() => _TenantScreenState();
}

class _TenantScreenState extends State<TenantScreen> {
  // CUBIT
  late TenantCubit _tenantCubit;

  // AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;

  // PROJECT
  late ProjectModel _project;

  // PAGINATION
  late ScrollController scrollController;
  Timer? _debounce;

  // TEXT EDITING CONTROLLERS
  late TextEditingController _searchC;

  // DEFAULT BUILDING ID
  int selectedBuildingId = 0;

  // DEFAULT TAB
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tenantCubit = context.read<TenantCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.tenant] ??
        AuthorizationModel();
    _project = getProject();
    _initialMethod();
    _initializeTextEditingController();
    _onScroll();
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

  void _initialMethod() async {
    await _tenantCubit.getBuildingList(context, 1, 100, _project.projectId);

    await Future.delayed(const Duration(milliseconds: 100));

    final buildingList = _tenantCubit.state.buildingList;

    if (buildingList.isNotEmpty) {
      selectedBuildingId = buildingList.first.buildingId;

      if (mounted) {
        await _tenantCubit.getTenantList(
          context: context,
          projectId: _project.projectId,
          buildingId: selectedBuildingId,
          pageNumber: 1,
          pageSize: 10,
        );
      }
    }
  }

  // <---- PAGINATION ---->
  void _onScroll() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !(_tenantCubit.state.isLoading ?? false) &&
          _tenantCubit.state.tenantList.length <
              _tenantCubit.state.totalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _tenantCubit.getTenantList(
            context: context,
            pageNumber: _tenantCubit.state.currentPage + 1,
            pageSize: 10,
            projectId: _project.projectId,
            buildingId: selectedBuildingId,
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        screenTitle: "Tenant",
        authorization: _routeAuthorizationModel,
      ),
      body: BlocBuilder<TenantCubit, TenantState>(
        builder: (context, state) {
          if ((state.isLoading ?? true) && state.tenantList.isEmpty) {
            return Center(child: loader());
          }
          if (state.tenantList.isEmpty) {
            return Center(child: noDataWidget());
          }
          return ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemCount: state.tenantList.length + 1,
            itemBuilder: (context, index) {
              if (index == state.tenantList.length) {
                return state.tenantList.length < state.totalNumberOfRecord
                    ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    )
                    : const SizedBox.shrink();
              }
              var tenant = state.tenantList[index];
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
                              // goRouter.pushNamed(
                              //   AppRoutes.viewAssetMaster,
                              //   queryParameters: {
                              //     "asset": Uri.encodeQueryComponent(
                              //       EncryptionManager.encryptData(
                              //         jsonEncode(asset.toJson()),
                              //       ),
                              //     ),
                              //   },
                              // );
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
                                tenant.buildingNumber,
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
                                //   await goRouter.pushNamed(
                                //     AppRoutes.addAssetMaster,
                                //     queryParameters: {
                                //       "asset": Uri.encodeQueryComponent(
                                //         EncryptionManager.encryptData(
                                //           jsonEncode(asset.toJson()),
                                //         ),
                                //       ),
                                //       'index': index.toString(),
                                //     },
                                //   );
                                //   if (context.mounted) {
                                //     _assetMasterCubit.getAssetsList(
                                //       context: context,
                                //       pageNumber: 1,
                                //       pageSize: 15,
                                //     );
                                //   }
                              },
                            ),
                            const SizedBox(width: 8),
                            CustomIconButton.delete(
                              onPressed: () {
                                // _showPopupToDeleteAssetMaster(context, asset, state.currentPage, index);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    verticalSpacing(height: 8),
                    _buildRowTitleValue(
                      title: "Asset Type",
                      value: tenant.facing,
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
}
