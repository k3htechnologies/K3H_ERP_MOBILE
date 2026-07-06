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
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
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

  @override
  void initState() {
    super.initState();
    _materialMasterCubit = context.read<MaterialMasterCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.materialMaster]!;
    _initializeTextEditingController();
    _onScroll();
    _materialMasterCubit.getMaterialMasterList(context, 1, 10);
  }

  @override
  void dispose() {
    scrollController.dispose();
    _searchC.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // INITIALIZE TEXT EDITING CONTROLLERS
  void _initializeTextEditingController() {
    _searchC = TextEditingController();
  }

  // PAGINATION
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
            10,
          );
        });
      }
    });
  }

  // DELETE MATERIAL
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
        pageSize: 10,
        index: index,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.lightGreyBackground,
      appBar: CustomAppBar(
        screenTitle: 'Material Master',
        authorization: _routeAuthorizationModel,
        onExportCallback: (value) {
          if (_materialMasterCubit.state.totalNumberOfRecord == 0) {
            showErrorMessage(context, "Error", "No data found");
            return;
          }
          _materialMasterCubit.exportExcelPdf(context, value);
        },
        onAddCallback: () async {
          await goRouter.pushNamed(AppRoutes.addMaterialMaster);
          if (context.mounted) {
            _materialMasterCubit.searchMaterial(context, "");
          }
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                                ).copyWith(
                                  decoration: TextDecoration.underline,
                                  decorationColor: AppColor.primary,
                                ),
                              ),
                            ),
                          ),
                          horizontalSpacing(),
                          if (_routeAuthorizationModel.isAction) ...[
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CustomIconButton.edit(
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
                        ],
                      ),
                      verticalSpacing(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildInfoChip(
                            label: "Code",
                            value: material.materialCode,
                          ),
                        ],
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

  // BUILD INFO CHIP
  Widget _buildInfoChip({required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColor.grey10,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("$label: ", style: AppTextStyle.ts12R(color: AppColor.grey)),
          Text(value, style: AppTextStyle.ts12R()),
        ],
      ),
    );
  }
}
