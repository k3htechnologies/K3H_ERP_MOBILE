import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/local_storage_manager.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/models/user.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/masters/project_master/data/repository/project_master.repository.dart';
import 'package:k3h_erp_app/features/redevelopment/tenant/data/model/tenant.model.dart';
import 'package:k3h_erp_app/features/redevelopment/tenant/presentation/cubit/tenant_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/storage_key.dart';
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

  // REPOSITORY
  final ProjectMasterRepository _projectMasterRepository =
      serviceLocator<ProjectMasterRepository>();

  // AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;

  // PROJECT SELECTION
  final ValueNotifier<List<Map<String, dynamic>>> _selectedProjectNotifier =
      ValueNotifier([]);
  final ValueNotifier<List<ProjectModel>> _projectListNotifier = ValueNotifier(
    [],
  );

  // BUILDING SELECTION
  final ValueNotifier<List<Map<String, dynamic>>> _selectedBuildingNotifier =
      ValueNotifier([]);

  // PAGINATION
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
    _tenantCubit = serviceLocator<TenantCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.tenant] ??
        AuthorizationModel();
    _initializeTextEditingController();
    _onScroll();
    _loadProjectsAndSetDefault();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    scrollController.dispose();
    _searchC.dispose();
    _selectedProjectNotifier.dispose();
    _projectListNotifier.dispose();
    _selectedBuildingNotifier.dispose();
    super.dispose();
  }

  // LOAD PROJECTS AND SET DEFAULT
  Future<void> _loadProjectsAndSetDefault() async {
    await _fetchProjects(1);
  }

  // LOAD BUILDINGS FOR PROJECT
  Future<void> _loadBuildingsForProject(int projectId) async {
    if (_tenantCubit.state.buildingList.isEmpty ||
        _tenantCubit.state.buildingList.any((b) => b.projectId != projectId)) {
      await _tenantCubit.getBuildingList(context, 1, 100, projectId);
    }
    if (mounted) {
      _selectedBuildingNotifier.value = [];
      _lastFetchedBuildingId = null;
    }
  }

  // FETCH PROJECTS
  Future<Map<String, dynamic>> _fetchProjects(
    int pageNumber, {
    String? value,
  }) async {
    final userJson = jsonDecode(
      LocalStorageManager().getString(StorageKey.currentUser) ?? '',
    );
    final user = UserModel.fromJson(userJson);

    final result = await _projectMasterRepository.getProjectList(
      pageNumber: pageNumber,
      pageSize: 100,
      queryParams: {
        'EmployeeId': user.employeeId.toString(),
        if (value != null && value.isNotEmpty) 'ProjectName': value,
      },
    );

    return result.fold(
      (failure) => {
        "itemList": <Map<String, dynamic>>[],
        "totalNumberOfRecord": 0,
      },
      (response) {
        final projects = (response['data'] as List<ProjectModel>);

        if (pageNumber == 1) {
          _projectListNotifier.value = projects;
        } else {
          _projectListNotifier.value = [
            ..._projectListNotifier.value,
            ...projects,
          ];
        }

        return {
          "itemList":
              projects.map((project) {
                return {
                  "zAttributesId": project.projectId,
                  "DisplayName": project.projectName,
                };
              }).toList(),
          "totalNumberOfRecord": response['totalNumberOfRecord'] ?? 0,
        };
      },
    );
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

    if (shouldDelete && context.mounted) {
      _tenantCubit.deleteTenant(
        _selectedProjectNotifier.value.first['zAttributesId'] as int,
        _selectedBuildingNotifier.value.first["zAttributesId"] as int,
        obj,
        context,
      );
    }
  }

  // INITIALIZE TEXT EDITING CONTROLLERS
  void _initializeTextEditingController() {
    _searchC = TextEditingController();
  }

  Future<Map<String, dynamic>> _fetchBuildings(
    int pageNumber, {
    String? value,
  }) async {
    if (_selectedProjectNotifier.value.isEmpty) {
      return {"itemList": <Map<String, dynamic>>[], "totalNumberOfRecord": 0};
    }

    final projectId =
        _selectedProjectNotifier.value.first['zAttributesId'] as int;
    final buildingList =
        _tenantCubit.state.buildingList
            .where((b) => b.projectId == projectId)
            .toList();

    if (value != null && value.isNotEmpty) {
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

    return {
      "itemList":
          buildingList.map((building) {
            return {
              "zAttributesId": building.buildingId,
              "DisplayName": building.buildingName,
            };
          }).toList(),
      "totalNumberOfRecord": buildingList.length,
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
          projectId:
          _selectedProjectNotifier.value.first['zAttributesId'] as int,
          buildingId:
          _selectedBuildingNotifier.value.first['zAttributesId'] as int,
          pageNumber: _tenantCubit.state.currentPage + 1,
          pageSize: 10,
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
          if (_selectedProjectNotifier.value.isNotEmpty &&
              _selectedBuildingNotifier.value.isNotEmpty) {
            _tenantCubit.searchTenant(
              value,
              context,
              _selectedProjectNotifier.value.first['zAttributesId'] as int,
              _selectedBuildingNotifier.value.first["zAttributesId"] as int,
            );
          }
        },
        textController: _searchC,
        onAddCallback: () {
          if (_selectedProjectNotifier.value.isNotEmpty &&
              _selectedBuildingNotifier.value.isNotEmpty) {
            goRouter.pushNamed(
              AppRoutes.addTenant,
              queryParameters: {
                'projectId':
                    _selectedProjectNotifier.value.first['zAttributesId']
                        .toString(),
                'buildingId':
                    _selectedBuildingNotifier.value.first["zAttributesId"]
                        .toString(),
              },
            );
          } else {
            showErrorMessage(
              context,
              "Error",
              "Please select project and building",
            );
          }
        },
        onExportCallback: (value) {
          if (_selectedProjectNotifier.value.isNotEmpty &&
              _selectedBuildingNotifier.value.isNotEmpty) {
            _tenantCubit.exportExcelPdf(
              context,
              value,
              _selectedProjectNotifier.value.first['zAttributesId'] as int,
              _selectedBuildingNotifier.value.first["zAttributesId"] as int,
            );
          } else {
            showErrorMessage(
              context,
              "Error",
              "Please select project and building",
            );
          }
        },
        extraHeight: 90,
        widgets: Row(
          children: [
            Expanded(
              child: ValueListenableBuilder<List<ProjectModel>>(
                valueListenable: _projectListNotifier,
                builder: (context, projectList, child) {
                  return projectList.isEmpty
                      ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: Text(
                            'No projects available',
                            style: AppTextStyle.ts14R(color: AppColor.grey),
                          ),
                        ),
                      )
                      : ValueListenableBuilder<List<Map<String, dynamic>>>(
                        valueListenable: _selectedProjectNotifier,
                        builder: (context, selectedProject, child) {
                          return CustomMultipleSelectPopup(
                            title: 'Project',
                            isRequired: true,
                            isMultiSelect: false,
                            initialValue: selectedProject,
                            dataList: const [],
                            onSelected: (value) async {
                              _selectedProjectNotifier.value = value;
                              if (value.isNotEmpty && mounted) {
                                final projectId =
                                    value.first['zAttributesId'] as int;
                                _selectedBuildingNotifier.value = [];
                                _lastFetchedBuildingId = null;
                                await _loadBuildingsForProject(projectId);
                              } else if (mounted) {
                                _selectedBuildingNotifier.value = [];
                                _lastFetchedBuildingId = null;
                              }
                            },
                            dataFetchCallBack: _fetchProjects,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Project is required";
                              }
                              return null;
                            },
                          );
                        },
                      );
                },
              ),
            ),
            horizontalSpacing(width: 12),
            Expanded(
              child: ValueListenableBuilder<List<Map<String, dynamic>>>(
                valueListenable: _selectedProjectNotifier,
                builder: (context, selectedProject, child) {
                  return BlocBuilder<TenantCubit, TenantState>(
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
                                final newBuildingId =
                                    value.first['zAttributesId'] as int;
                                if (_lastFetchedBuildingId != newBuildingId) {
                                  _lastFetchedBuildingId = newBuildingId;
                                  await _tenantCubit.getTenantList(
                                    context: context,
                                    projectId:
                                        selectedProject.first['zAttributesId']
                                            as int,
                                    buildingId: newBuildingId,
                                    pageNumber: 1,
                                    pageSize: 10,
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
                  );
                },
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          verticalSpacing(),
          Expanded(
            child: ValueListenableBuilder<List<Map<String, dynamic>>>(
              valueListenable: _selectedProjectNotifier,
              builder: (context, selectedProject, child) {
                if (selectedProject.isEmpty) {
                  return Center(
                    child: Text(
                      'Please select a project',
                      style: AppTextStyle.ts14R(color: AppColor.grey),
                    ),
                  );
                }
                return ValueListenableBuilder<List<Map<String, dynamic>>>(
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
                        if ((state.isLoading ?? true) &&
                            state.tenantList.isEmpty) {
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
                                                      jsonEncode(
                                                        tenant.toJson(),
                                                      ),
                                                    ),
                                              },
                                            );
                                          },
                                          child: Container(
                                            padding: EdgeInsets.symmetric(horizontal: 5,vertical: 3),
                                            decoration: BoxDecoration(
                                              border: Border(
                                                bottom: BorderSide(
                                                  color: AppColor.primary
                                                )
                                              )
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
                                              if (_selectedProjectNotifier
                                                      .value
                                                      .isEmpty ||
                                                  _selectedBuildingNotifier
                                                      .value
                                                      .isEmpty) {
                                                showErrorMessage(
                                                  context,
                                                  'Error',
                                                  'Please select a project and building',
                                                );
                                                return;
                                              }
                                              final projectId =
                                                  _selectedProjectNotifier
                                                          .value
                                                          .first['zAttributesId']
                                                      as int;
                                              final buildingId =
                                                  _selectedBuildingNotifier
                                                          .value
                                                          .first["zAttributesId"]
                                                      as int;
                                              await goRouter.pushNamed(
                                                AppRoutes.addTenant,
                                                queryParameters: {
                                                  "tenant":
                                                      Uri.encodeQueryComponent(
                                                        EncryptionManager.encryptData(
                                                          jsonEncode(
                                                            tenant.toJson(),
                                                          ),
                                                        ),
                                                      ),
                                                  'index': index.toString(),
                                                  'projectId':
                                                      projectId.toString(),
                                                  'buildingId':
                                                      buildingId.toString(),
                                                },
                                              );
                                              if (context.mounted &&
                                                  _selectedProjectNotifier
                                                      .value
                                                      .isNotEmpty &&
                                                  _selectedBuildingNotifier
                                                      .value
                                                      .isNotEmpty) {
                                                _tenantCubit.getTenantList(
                                                  context: context,
                                                  pageNumber: state.currentPage,
                                                  pageSize: 10,
                                                  projectId:
                                                      _selectedProjectNotifier
                                                              .value
                                                              .first['zAttributesId']
                                                          as int,
                                                  buildingId:
                                                      _selectedBuildingNotifier
                                                              .value
                                                              .first["zAttributesId"]
                                                          as int,
                                                );
                                              }
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
