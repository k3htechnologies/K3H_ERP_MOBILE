import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/procurement_master/sub_material_master/data/model/sub_material_master.model.dart';
import 'package:k3h_erp_app/features/masters/procurement_master/sub_material_master/presentation/cubit/sub_material_master_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
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
    _subMaterialMasterCubit.getSubMaterialMasterList(context, 1, 10);
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

  // <---- PAGINATION ---->
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
            10,
          );
        });
      }
    });
  }

  // <---- DELETE SUB MATERIAL ---->
  Future<void> _showPopupToDeleteSubMaterialMaster(
    BuildContext context,
    SubMaterialMasterModel subMaterial,
    int currentPage,
    int index,
  ) async {
    var result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a sub material?',
      'Deleting this sub material will permanently remove its contents.',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.lightGreyBackground,
      appBar: CustomAppBar(
        screenTitle: 'Sub Material',
        authorization: _routeAuthorizationModel,
        onExportCallback: (value) {
          _subMaterialMasterCubit.exportExcelPdf(context, value);
        },
        onAddCallback: () async {
          await goRouter.pushNamed(AppRoutes.addSubMaterialMaster);
          // Refresh list when returning from add screen
          if (context.mounted) {
            _subMaterialMasterCubit.getSubMaterialMasterList(context, 1, 10);
          }
        },
        onSearchSubmit: (value) {
          _subMaterialMasterCubit.searchSubMaterial(context, value);
        },
        textController: _searchC,
        onSortOptionCallback: (value) async {
          _subMaterialMasterCubit.sortSubMaterial(context, value, "DESC");
        },
        sortOptionList: ["Created Date", "Sub Material Name", "Modified Date"],
        initialSortType: "Created Date",
      ),
      body: BlocBuilder<SubMaterialMasterCubit, SubMaterialMasterState>(
        builder: (context, state) {
          if ((state.isLoading ?? true) && state.subMaterialList.isEmpty) {
            return Center(child: loader());
          }
          if (state.subMaterialList.isEmpty) {
            return Center(child: noDataWidget());
          }
          return ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemCount: _subMaterialMasterCubit.state.subMaterialList.length + 1,
            itemBuilder: (context, index) {
              if (index == state.subMaterialList.length) {
                return state.subMaterialList.length < state.totalNumberOfRecord
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
                        Expanded(
                          child: Text(
                            subMaterial.subMaterialName,
                            style: AppTextStyle.ts16M(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomIconButton.edit(
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
                    verticalSpacing(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildInfoChip(
                          label: "Material",
                          value: subMaterial.materialName,
                        ),
                        _buildInfoChip(label: "UOM", value: subMaterial.uom),
                      ],
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
