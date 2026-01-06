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
import 'package:k3h_erp_app/features/redevelopment/tenant/presentation/cubit/tenant_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/storage_key.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/app_bar/search_widget.dart';
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
  final ValueNotifier<List<ProjectModel>> _projectListNotifier =
      ValueNotifier([]);
  // late ProjectModel _project;

  // BUILDING SELECTION
  final ValueNotifier<List<Map<String, dynamic>>> _selectedBuildingNotifier =
      ValueNotifier([]);

  // PAGINATION
  late ScrollController scrollController;
  Timer? _debounce;

  // TEXT EDITING CONTROLLERS
  late TextEditingController _searchC;

  // FLAGS TO PREVENT INFINITE CALLS
  int? _lastFetchedBuildingId;

  @override
  void initState() {
    super.initState();
    _tenantCubit = context.read<TenantCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.tenant] ??
        AuthorizationModel();
    // _project = getProject();
    _initializeTextEditingController();
    _onScroll();
    _loadProjectsAndSetDefault();
  }

  Future<void> _loadProjectsAndSetDefault() async {
    await _fetchProjects(1);
    // Don't auto-select project or fetch buildings
    // Buildings will only be fetched when user selects a project from dropdown
  }

  Future<void> _loadBuildingsForProject(int projectId) async {
    if (_tenantCubit.state.buildingList.isEmpty ||
        _tenantCubit.state.buildingList.any(
          (b) => b.projectId != projectId,
        )) {
      await _tenantCubit.getBuildingList(context, 1, 100, projectId);
    }

    // Clear building selection when project changes
    // User needs to manually select a building
    if (mounted) {
      _selectedBuildingNotifier.value = [];
      _lastFetchedBuildingId = null;
    }
  }

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
          "itemList": projects.map((project) {
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

  // INITIALIZE TEXT EDITING CONTROLLERS
  void _initializeTextEditingController() {
    _searchC = TextEditingController();
  }

  Future<Map<String, dynamic>> _fetchBuildings(
    int pageNumber, {
    String? value,
  }) async {
    if (_selectedProjectNotifier.value.isEmpty) {
      return {
        "itemList": <Map<String, dynamic>>[],
        "totalNumberOfRecord": 0,
      };
    }

    final projectId = _selectedProjectNotifier.value.first['zAttributesId'] as int;
    final buildingList = _tenantCubit.state.buildingList
        .where((b) => b.projectId == projectId)
        .toList();

    if (value != null && value.isNotEmpty) {
      final filteredBuildings = buildingList
          .where(
            (building) => building.buildingName.toLowerCase().contains(
              value.toLowerCase(),
            ),
          )
          .toList();

      return {
        "itemList": filteredBuildings.map((building) {
          return {
            "zAttributesId": building.buildingId,
            "DisplayName": building.buildingName,
          };
        }).toList(),
        "totalNumberOfRecord": filteredBuildings.length,
      };
    }

    return {
      "itemList": buildingList.map((building) {
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
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (!mounted || !scrollController.hasClients) return;

      final maxScroll = scrollController.position.maxScrollExtent;
      final currentScroll = scrollController.position.pixels;

      if (currentScroll >= maxScroll - 100 &&
          maxScroll > 0 &&
          !(_tenantCubit.state.isLoading ?? false) &&
          _tenantCubit.state.tenantList.length <
              _tenantCubit.state.totalNumberOfRecord &&
          _selectedBuildingNotifier.value.isNotEmpty) {
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          if (!mounted) return;
          if (_selectedBuildingNotifier.value.isEmpty) return;
          if (_tenantCubit.state.isLoading ?? false) return;

          _tenantCubit.getTenantList(
            context: context,
            pageNumber: _tenantCubit.state.currentPage + 1,
            pageSize: 10,
            projectId: _selectedProjectNotifier.value.first['zAttributesId'] as int,
            buildingId: _selectedBuildingNotifier.value.first["zAttributesId"] as int,
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Tenant",
        authorization: _routeAuthorizationModel,
      ),
      body: Column(
        children: [
          verticalSpacing(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                // Project and Building Selectors in Row
                Row(
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
                                          final projectId = value.first['zAttributesId'] as int;
                                          // Clear building selection and load buildings for new project
                                          _selectedBuildingNotifier.value = [];
                                          _lastFetchedBuildingId = null;
                                          await _loadBuildingsForProject(projectId);
                                        } else if (mounted) {
                                          // If no project selected, clear building selection and tenant list
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
                                            projectId: selectedProject.first['zAttributesId'] as int,
                                            buildingId: newBuildingId,
                                            pageNumber: 1,
                                            pageSize: 10,
                                          );
                                        }
                                      } else if (mounted) {
                                        // If no building selected, clear the last fetched building ID
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
                    Container(
                      height: 40,
                      color: AppColor.white,
                      child: Row(
                        children: [
                          Expanded(
                            child: SearchWidget(
                              isFilterOn: false,
                              onSubmit: (value) {
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
                            ),
                          ),
                          horizontalSpacing(),
                          CustomIconButton(
                            onPressed: () {
                              if (_selectedProjectNotifier.value.isNotEmpty &&
                                  _selectedBuildingNotifier.value.isNotEmpty) {
                                goRouter.pushNamed(
                                  AppRoutes.addTenant,
                                  queryParameters: {
                                    'projectId': _selectedProjectNotifier.value
                                        .first['zAttributesId']
                                        .toString(),
                                    'buildingId': _selectedBuildingNotifier.value
                                        .first["zAttributesId"]
                                        .toString(),
                                  },
                                );
                              }
                            },
                            icon: Icon(
                              Icons.add,
                              size: 16,
                              color: AppColor.darkGreen,
                            ),
                            backgroundColor: AppColor.lightGreen,
                          ),
                          horizontalSpacing(),
                          CustomIconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.file_download,
                              size: 16,
                              color: AppColor.primary,
                            ),
                            backgroundColor: AppColor.lightBlue,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
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
                                    child: Text(
                                      tenant.tenantApplicantData
                                          .firstWhere(
                                            (e) =>
                                                e.applicantType.toLowerCase() ==
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
                                  Row(
                                    children: [
                                      CustomIconButton.edit(
                                        onPressed: () async {
                                            await goRouter.pushNamed(
                                              AppRoutes.addTenant,
                                              queryParameters: {
                                                "tenant": Uri.encodeQueryComponent(
                                                  EncryptionManager.encryptData(
                                                    jsonEncode(tenant.toJson()),
                                                  ),
                                                ),
                                                'index': index.toString(),
                                              },
                                            );
                                            if (context.mounted &&
                                                _selectedProjectNotifier.value.isNotEmpty &&
                                                _selectedBuildingNotifier.value.isNotEmpty) {
                                              _tenantCubit.getTenantList(
                                                context: context,
                                                pageNumber: 1,
                                                pageSize: 10,
                                                projectId: _selectedProjectNotifier.value
                                                    .first['zAttributesId'] as int,
                                                buildingId: _selectedBuildingNotifier.value
                                                    .first["zAttributesId"] as int,
                                              );
                                            }
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
