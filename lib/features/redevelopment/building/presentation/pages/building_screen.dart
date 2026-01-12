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
import 'package:k3h_erp_app/features/redevelopment/building/data/model/building.model.dart';
import 'package:k3h_erp_app/features/redevelopment/building/presentation/cubit/building_cubit.dart';
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

class BuildingScreen extends StatefulWidget {
  const BuildingScreen({super.key});

  @override
  State<BuildingScreen> createState() => _BuildingScreenState();
}

class _BuildingScreenState extends State<BuildingScreen> {
  // CUBIT
  late BuildingCubit _buildingCubit;

  // AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;

  // SCROLL CONTROLLER
  final ScrollController scrollController = ScrollController();

  // TEXT EDITING CONTROLLER
  late TextEditingController _searchC;

  // PROJECT MASTER REPOSITORY
  final ProjectMasterRepository _projectMasterRepository =
      serviceLocator<ProjectMasterRepository>();

  // PROJECT SELECTION
  final ValueNotifier<List<Map<String, dynamic>>> _selectedProjectNotifier =
      ValueNotifier([]);
  final ValueNotifier<List<ProjectModel>> _projectListNotifier = ValueNotifier(
    [],
  );

  final ValueNotifier<bool> _isProjectLoading = ValueNotifier(true);

  @override
  void initState() {
    super.initState();
    _buildingCubit = serviceLocator<BuildingCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.building] ??
        AuthorizationModel();
    _initializeTextEditingController();
    _onScroll();
    _loadProjectsAndSetDefault();
  }

  @override
  void dispose() {
    scrollController.dispose();
    _searchC.dispose();
    super.dispose();
  }

  // FETCH PROJECTS
  Future<void> _loadProjectsAndSetDefault() async {
    await _fetchProjects(1);
  }

  // FETCH PROJECTS
  Future<Map<String, dynamic>> _fetchProjects(
    int pageNumber, {
    String? value,
  }) async {
    _isProjectLoading.value = true;
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
      (failure) {
        _isProjectLoading.value = false;

        return {"itemList": <Map<String, dynamic>>[], "totalNumberOfRecord": 0};
      },
      (response) {
        final List<ProjectModel> projects =
            (response['data'] as List<ProjectModel>);
        if (pageNumber == 1) {
          _projectListNotifier.value = projects;
        } else {
          _projectListNotifier.value = [
            ..._projectListNotifier.value,
            ...projects,
          ];
        }
        final List<Map<String, dynamic>> itemList =
            projects
                .map(
                  (project) => {
                    'zAttributesId': project.projectId,
                    'DisplayName': project.projectName,
                  },
                )
                .toList();
        _isProjectLoading.value = false;

        return {
          "itemList": itemList,
          "totalNumberOfRecord": response['totalNumberOfRecord'] ?? 0,
        };
      },
    );
  }

  // INITIALIZE TEXT EDITING CONTROLLER
  void _initializeTextEditingController() {
    _searchC = TextEditingController();
  }

  // PAGINATION
  void _onScroll() {
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent &&
          !_buildingCubit.state.isLoading! &&
          _buildingCubit.state.buildingList.length <
              _buildingCubit.state.totalNumberOfRecord) {
        if (_selectedProjectNotifier.value.isNotEmpty) {
          _buildingCubit.getBuildingList(
            context,
            _buildingCubit.state.currentPage + 1,
            10,
            _selectedProjectNotifier.value.first['zAttributesId'] as int,
          );
        }
      }
    });
  }

  // DELETE BUILDING
  Future<void> _showPopupToDeleteBuilding(
    BuildContext context,
    RedevelopmentBuildingModel obj,
    int page,
    int index,
  ) async {
    final shouldDelete = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a Building?',
      'Deleting this Building will permanently remove its contents.',
    );

    if (shouldDelete && context.mounted) {
      _buildingCubit.deleteBuilding(
        _selectedProjectNotifier.value.first['zAttributesId'] as int,
        obj,
        context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        screenTitle: "Building",
        authorization: _routeAuthorizationModel,
        onSearchSubmit: (value) {
          if (_selectedProjectNotifier.value.isNotEmpty) {
            _buildingCubit.searchBuilding(
              context,
              _selectedProjectNotifier.value.first['zAttributesId'] as int,
              value,
            );
          }
        },
        textController: _searchC,
        onAddCallback: () {
          if (_selectedProjectNotifier.value.isEmpty) {
            showErrorMessage(context, 'Error', 'Please select a project');
            return;
          }
          final projectId =
              _selectedProjectNotifier.value.first['zAttributesId'] as int;
          goRouter.pushNamed(
            AppRoutes.addBuilding,
            queryParameters: {'projectId': projectId.toString()},
          );
        },
        onExportCallback: (value) {
          if (_selectedProjectNotifier.value.isNotEmpty) {
            _buildingCubit.exportExcelPdf(
              context,
              value,
              _selectedProjectNotifier.value.first['zAttributesId'] as int,
            );
          } else {
            showErrorMessage(context, 'Error', 'Please select a project');
          }
        },
        extraHeight: 90,
        widgets: ValueListenableBuilder<List<ProjectModel>>(
          valueListenable: _projectListNotifier,
          builder: (context, projectList, child) {
            return (projectList.isEmpty & !_isProjectLoading.value)
                ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
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
                        if (!mounted) return;
                        _selectedProjectNotifier.value = value;
                        await Future.delayed(const Duration(milliseconds: 100));
                        if (!mounted) return;
                        if (value.isNotEmpty) {
                          final projectId = value.first['zAttributesId'] as int;
                          // RESET SCROLL POSITION
                          if (scrollController.hasClients) {
                            scrollController.jumpTo(0);
                          }
                          // CALL BUILDING LIST API WHEN PROJECT IS SELECTED
                          if (context.mounted) {
                            _buildingCubit.getBuildingList(
                              context,
                              1,
                              10,
                              projectId,
                            );
                          }
                        } else {
                          if (mounted) {
                            _buildingCubit.clearBuildingList();
                          }
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
      body: Column(
        children: [
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
                final currentProjectId =
                    selectedProject.isNotEmpty
                        ? selectedProject.first['zAttributesId'] as int
                        : 0;
                return BlocBuilder<BuildingCubit, BuildingState>(
                  key: ValueKey('building_list_$currentProjectId'),
                  bloc: _buildingCubit,
                  builder: (context, state) {
                    if ((state.isLoading ?? true) &&
                        state.buildingList.isEmpty) {
                      return Center(child: loader());
                    }
                    if (state.buildingList.isEmpty) {
                      return Center(child: noDataWidget());
                    }
                    return ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      itemCount: state.buildingList.length + 1,
                      itemBuilder: (context, index) {
                        if (index == state.buildingList.length) {
                          return state.buildingList.length <
                                  state.totalNumberOfRecord
                              ? const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                              : const SizedBox.shrink();
                        }
                        var building = state.buildingList[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: commonCardDecoration(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                spacing: 10,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: GestureDetector(
                                      onTap: () {
                                        goRouter.pushNamed(
                                          AppRoutes.viewBuilding,
                                          queryParameters: {
                                            "building":
                                                Uri.encodeQueryComponent(
                                                  EncryptionManager.encryptData(
                                                    jsonEncode(
                                                      building.toJson(),
                                                    ),
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
                                            bottom: BorderSide(
                                              color: AppColor.primary,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          building.buildingName,
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
                                              .isEmpty) {
                                            showErrorMessage(
                                              context,
                                              'Error',
                                              'Please select a project',
                                            );
                                            return;
                                          }
                                          final projectId =
                                              _selectedProjectNotifier
                                                      .value
                                                      .first['zAttributesId']
                                                  as int;
                                          await goRouter.pushNamed(
                                            AppRoutes.addBuilding,
                                            queryParameters: {
                                              "building":
                                                  Uri.encodeQueryComponent(
                                                    EncryptionManager.encryptData(
                                                      jsonEncode(
                                                        building.toJson(),
                                                      ),
                                                    ),
                                                  ),
                                              'index': index.toString(),
                                              'projectId': projectId.toString(),
                                            },
                                          );
                                          if (context.mounted &&
                                              _selectedProjectNotifier
                                                  .value
                                                  .isNotEmpty) {
                                            _buildingCubit.getBuildingList(
                                              context,
                                              1,
                                              10,
                                              _selectedProjectNotifier
                                                      .value
                                                      .first['zAttributesId']
                                                  as int,
                                            );
                                          }
                                        },
                                      ),
                                      const SizedBox(width: 8),
                                      CustomIconButton.delete(
                                        onPressed: () {
                                          _showPopupToDeleteBuilding(
                                            context,
                                            building,
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
                                title: "CTS Number",
                                value: building.ctsNumber,
                              ),
                              _buildRowTitleValue(
                                title: "Total Plot Area(Sq. ft)",
                                value: building.totalPlotAreaSqFt.toString(),
                              ),
                              _buildRowTitleValue(
                                title: "Road Width",
                                value: building.roadWidth,
                              ),
                              _buildRowTitleValue(
                                title: "Total Floor",
                                value: building.numberOfFloors.toString(),
                              ),
                              _buildRowTitleValue(
                                title: "Total Units",
                                value: building.totalNumberOfUnits.toString(),
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
          Expanded(child: Text(value, style: AppTextStyle.ts14R())),
        ],
      ),
    );
  }
}
