import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/redevelopment/tenant/data/model/tenant.model.dart';
import 'package:k3h_erp_app/features/redevelopment/tenant/presentation/cubit/tenant_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_multi_select_pop_up.dart';
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

  // BUILDING SELECTION
  final ValueNotifier<List<Map<String, dynamic>>> _selectedBuildingNotifier =
      ValueNotifier([]);

  // SCROLL CONTROLLER
  final ScrollController scrollController = ScrollController();
  Timer? _debounce;

  // TEXT EDITING CONTROLLERS
  late TextEditingController _searchC;

  // FLAGS TO PREVENT INFINITE CALLS
  int? _lastFetchedBuildingId;

  @override
  void initState() {
    super.initState();
    _project = getProject();
    _tenantCubit = context.read<TenantCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.tenant] ??
        AuthorizationModel();
    _initializeTextEditingController();
    _onScroll();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadBuildingsForProject(_project.projectId);
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    scrollController.dispose();
    _searchC.dispose();
    _selectedBuildingNotifier.dispose();
    super.dispose();
  }

  // LOAD BUILDINGS FOR PROJECT
  Future<void> _loadBuildingsForProject(int projectId) async {
    if (_tenantCubit.state.buildingList.isEmpty ||
        _tenantCubit.state.buildingList.any((b) => b.projectId != projectId)) {
      await _tenantCubit.getBuildingList(context, 1, 15, projectId);
    }
    if (mounted) {
      _selectedBuildingNotifier.value = [];
      _lastFetchedBuildingId = null;
    }
  }

  // DELETE TENANT
  Future<void> _showPopupToDeleteTenant(
    BuildContext context,
    TenantModel obj,
    int page,
    int index,
  ) async {
    final shouldDelete = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a Tenant?',
      'Deleting this Tenant will permanently remove its contents.',
    );

    if (shouldDelete &&
        context.mounted &&
        _selectedBuildingNotifier.value.isNotEmpty) {
      _tenantCubit.deleteTenant(
        _project.projectId,
        _selectedBuildingNotifier.value.first["zAttributesId"] as int,
        obj,
        context,
        index,
      );
    }
  }

  // INITIALIZE TEXT EDITING CONTROLLERS
  void _initializeTextEditingController() {
    _searchC = TextEditingController();
  }

  // FETCH BUILDINGS
  Future<Map<String, dynamic>> _fetchBuildings(
    int pageNumber, {
    String? value,
  }) async {
    if (value != null && value.isNotEmpty) {
      final buildingList =
          _tenantCubit.state.buildingList
              .where((b) => b.projectId == _project.projectId)
              .toList();

      final filteredBuildings =
          buildingList
              .where(
                (building) => building.buildingName.toLowerCase().contains(
                  value.toLowerCase(),
                ),
              )
              .toList();

      return {
        "itemList":
            filteredBuildings.map((building) {
              return {
                "zAttributesId": building.buildingId,
                "DisplayName": building.buildingName,
              };
            }).toList(),
        "totalNumberOfRecord": filteredBuildings.length,
      };
    }

    final buildingList =
        _tenantCubit.state.buildingList
            .where((b) => b.projectId == _project.projectId)
            .toList();

    final currentLoadedCount = buildingList.length;
    final pageSize = 12;
    final expectedCount = pageNumber * pageSize;
    final totalCount = _tenantCubit.state.buildingTotalCount;

    if (currentLoadedCount < expectedCount &&
        (totalCount == 0 || currentLoadedCount < totalCount)) {
      await _tenantCubit.getBuildingList(
        context,
        pageNumber,
        pageSize,
        _project.projectId,
      );

      final updatedBuildingList =
          _tenantCubit.state.buildingList
              .where((b) => b.projectId == _project.projectId)
              .toList();

      return {
        "itemList":
            updatedBuildingList.map((building) {
              return {
                "zAttributesId": building.buildingId,
                "DisplayName": building.buildingName,
              };
            }).toList(),
        "totalNumberOfRecord":
            _tenantCubit.state.buildingTotalCount > 0
                ? _tenantCubit.state.buildingTotalCount
                : updatedBuildingList.length,
      };
    }

    return {
      "itemList":
          buildingList.map((building) {
            return {
              "zAttributesId": building.buildingId,
              "DisplayName": building.buildingName,
            };
          }).toList(),
      "totalNumberOfRecord": totalCount > 0 ? totalCount : buildingList.length,
    };
  }

  // <---- PAGINATION ---->
  void _onScroll() {
    scrollController.addListener(() {
      if (!scrollController.hasClients) return;

      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent &&
          !_tenantCubit.state.isLoading! &&
          _tenantCubit.state.tenantList.length <
              _tenantCubit.state.totalNumberOfRecord &&
          _selectedBuildingNotifier.value.isNotEmpty) {
        _tenantCubit.getTenantList(
          context: context,
          projectId: _project.projectId,
          buildingId:
              _selectedBuildingNotifier.value.first['zAttributesId'] as int,
          pageNumber: _tenantCubit.state.currentPage + 1,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        screenTitle: "Tenant",
        authorization: _routeAuthorizationModel,
        onSearchSubmit: (value) {
          if (_selectedBuildingNotifier.value.isNotEmpty) {
            _tenantCubit.searchTenant(
              value,
              context,
              _project.projectId,
              _selectedBuildingNotifier.value.first["zAttributesId"] as int,
            );
          }
        },
        textController: _searchC,
        searchHintText: "Search By Flat Number",
        onAddCallback: () {
          if (_selectedBuildingNotifier.value.isNotEmpty) {
            goRouter.pushNamed(
              AppRoutes.addTenant,
              queryParameters: {
                'projectId': _project.projectId.toString(),
                'buildingId':
                    _selectedBuildingNotifier.value.first["zAttributesId"]
                        .toString(),
              },
            );
          } else {
            showErrorMessage(context, "Error", "Please select building");
          }
        },
        onExportCallback: (value) {
          if (_selectedBuildingNotifier.value.isNotEmpty) {
            _tenantCubit.exportExcelPdf(
              context,
              value,
              _project.projectId,
              _selectedBuildingNotifier.value.first["zAttributesId"] as int,
            );
          } else {
            showErrorMessage(context, "Error", "Please select building");
          }
        },
        onProjectChangeCallback: (project) {
          _project = project;
          _selectedBuildingNotifier.value = [];
          _lastFetchedBuildingId = null;
          _loadBuildingsForProject(_project.projectId);
        },
        extraHeight: 90,
        widgets: BlocBuilder<TenantCubit, TenantState>(
          bloc: _tenantCubit,
          builder: (context, state) {
            return ValueListenableBuilder<List<Map<String, dynamic>>>(
              valueListenable: _selectedBuildingNotifier,
              builder: (context, selectedBuilding, child) {
                return CustomMultipleSelectPopup(
                  title: "Building",
                  isRequired: true,
                  isMultiSelect: false,
                  initialValue: selectedBuilding,
                  dataList: const [],
                  onSelected: (value) async {
                    _selectedBuildingNotifier.value = value;
                    if (value.isNotEmpty &&
                        value.first['zAttributesId'] != null &&
                        mounted) {
                      final newBuildingId = value.first['zAttributesId'] as int;
                      if (_lastFetchedBuildingId != newBuildingId) {
                        _lastFetchedBuildingId = newBuildingId;
                        await _tenantCubit.getTenantList(
                          context: context,
                          projectId: _project.projectId,
                          buildingId: newBuildingId,
                          pageNumber: 1,
                        );
                      }
                    } else if (mounted) {
                      _lastFetchedBuildingId = null;
                    }
                  },
                  dataFetchCallBack: _fetchBuildings,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Building is required";
                    }
                    return null;
                  },
                );
              },
            );
          },
        ),
      ),
      body: Column(
        children: [
          verticalSpacing(),
          Expanded(
            child: ValueListenableBuilder<List<Map<String, dynamic>>>(
              valueListenable: _selectedBuildingNotifier,
              builder: (context, selectedBuilding, child) {
                if (selectedBuilding.isEmpty) {
                  return Center(
                    child: Text(
                      'Please select a building',
                      style: AppTextStyle.ts14R(color: AppColor.grey),
                    ),
                  );
                }
                return BlocBuilder<TenantCubit, TenantState>(
                  bloc: _tenantCubit,
                  builder: (context, state) {
                    if ((state.isLoading ?? true) && state.tenantList.isEmpty) {
                      return Center(child: loader());
                    }
                    if (state.tenantList.isEmpty) {
                      return Center(child: noDataWidget());
                    }
                    return ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      itemCount: state.tenantList.length + 1,
                      itemBuilder: (context, index) {
                        if (index == state.tenantList.length) {
                          return state.tenantList.length <
                                  state.totalNumberOfRecord
                              ? const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: GestureDetector(
                                      onTap: () {
                                        goRouter.pushNamed(
                                          AppRoutes.viewTenant,
                                          queryParameters: {
                                            "tenant":
                                                EncryptionManager.encryptData(
                                                  jsonEncode(tenant.toJson()),
                                                ),
                                          },
                                        );
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 5,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              color: AppColor.primary,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          tenant.tenantApplicantData
                                              .firstWhere(
                                                (e) =>
                                                    e.applicantType
                                                        .toLowerCase() ==
                                                    "applicant",
                                              )
                                              .applicantName,
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
                                          if (_selectedBuildingNotifier
                                              .value
                                              .isEmpty) {
                                            showErrorMessage(
                                              context,
                                              'Error',
                                              'Please select a building',
                                            );
                                            return;
                                          }
                                          final buildingId =
                                              _selectedBuildingNotifier
                                                      .value
                                                      .first["zAttributesId"]
                                                  as int;
                                          await goRouter.pushNamed(
                                            AppRoutes.addTenant,
                                            queryParameters: {
                                              "tenant": Uri.encodeQueryComponent(
                                                EncryptionManager.encryptData(
                                                  jsonEncode(tenant.toJson()),
                                                ),
                                              ),
                                              'index': index.toString(),
                                              'projectId':
                                                  _project.projectId.toString(),
                                              'buildingId':
                                                  buildingId.toString(),
                                            },
                                          );
                                        },
                                      ),
                                      const SizedBox(width: 8),
                                      CustomIconButton.delete(
                                        onPressed: () {
                                          _showPopupToDeleteTenant(
                                            context,
                                            tenant,
                                            state.currentPage,
                                            index,
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              verticalSpacing(height: 8),
                              _buildRowTitleValue(
                                title: "Existing Flat No.",
                                value: tenant.flatNumber,
                              ),
                              _buildRowTitleValue(
                                title: "Existing Flat Type",
                                value: tenant.flatType,
                              ),
                              _buildRowTitleValue(
                                title: "New Flat No",
                                value:
                                    tenant.inventoryFlatType.isEmpty
                                        ? "-"
                                        : tenant.inventoryFlatType,
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // BUILD ROW TITLE VALUE
  Widget _buildRowTitleValue({required String title, required String value}) {
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
